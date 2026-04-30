# Secrets
resource "google_secret_manager_secret" "db_url" {
  secret_id = "db-url-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_url_v1" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = "postgresql+psycopg2://app_user:${var.db_password}@/sinapsek_fin?host=/cloudsql/${var.db_connection}"
}

resource "google_secret_manager_secret_iam_member" "api_secret_access" {
  secret_id = google_secret_manager_secret.db_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_sa_email}"
}

resource "google_secret_manager_secret" "app_secret_key" {
  secret_id = "app-secret-key-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_secret_key_v1" {
  secret      = google_secret_manager_secret.app_secret_key.id
  secret_data = "generate-your-secure-random-key-here"
}

resource "google_secret_manager_secret_iam_member" "api_app_secret_access" {
  secret_id = google_secret_manager_secret.app_secret_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_sa_email}"
}

# Cloud Run Service
resource "google_cloud_run_service" "api" {
  name     = "sinapsek-api-${var.environment}"
  location = var.region

  template {
    spec {
      service_account_name = var.api_sa_email

      containers {
        image = var.api_image_url

        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_url.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        env {
          name = "SECRET_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.app_secret_key.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "CORS_ORIGINS"
          value = "https://*.sinapsek.com,https://admin.sinapsek.com"
        }
        env {
          name  = "LOG_LEVEL"
          value = "INFO"
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = var.db_connection
        "autoscaling.knative.dev/maxScale"      = "10"
        "autoscaling.knative.dev/minScale"      = "0"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_domain_mapping" "api" {
  location = var.region
  name     = var.custom_domain

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_service.api.name
  }
}

resource "google_cloud_run_service_iam_member" "public" {
  service  = google_cloud_run_service.api.name
  location = google_cloud_run_service.api.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_job" "migrate" {
  name     = "migrate-${var.environment}"
  location = var.region

  template {
    template {
      service_account_name = var.api_sa_email

      containers {
        image = var.api_image_url

        env {
          name = "DATABASE_URL"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.db_url.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name  = "ENVIRONMENT"
          value = var.environment
        }
        env {
          name = "SECRET_KEY"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.app_secret_key.secret_id
              key  = "latest"
            }
          }
        }

        command = ["alembic", "upgrade", "head"]
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
    }
  }

  labels = {
    environment = var.environment
    app         = "sinapsek-api"
  }
}

resource "google_cloud_run_v2_job_execution" "migrate" {
  name    = "migrate-${var.environment}-${formatdate("YYYYMMDD", timestamp())}"
  job    = google_cloud_run_v2_job.migrate.name
  location = var.region
}

output "api_url" {
  value = google_cloud_run_service.api.status[0].url
}

output "api_sa_email" {
  value = var.api_sa_email
}

output "dns_records" {
  value = google_cloud_run_domain_mapping.api.status[0].resource_records
}
