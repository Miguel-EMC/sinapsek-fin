# --- Secrets ---

resource "google_secret_manager_secret" "db_url" {
  secret_id = "db-url-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_url_v1" {
  secret      = google_secret_manager_secret.db_url.id
  secret_data = "postgresql+psycopg2://app_user:${var.db_password}@/sinapsek_fin?host=/cloudsql/${var.db_connection}"

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret_iam_member" "api_secret_access" {
  secret_id = google_secret_manager_secret.db_url.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_sa_email}"
}

resource "random_password" "app_secret_key" {
  length  = 64
  special = false
}

resource "google_secret_manager_secret" "app_secret_key" {
  secret_id = "app-secret-key-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "app_secret_key_v1" {
  secret      = google_secret_manager_secret.app_secret_key.id
  secret_data = random_password.app_secret_key.result

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret_iam_member" "api_app_secret_access" {
  secret_id = google_secret_manager_secret.app_secret_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_sa_email}"
}

# Gemini API key — value must be set manually in Secret Manager after first apply
resource "google_secret_manager_secret" "gemini_api_key" {
  secret_id = "gemini-api-key-${var.environment}"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "gemini_api_key_v1" {
  secret      = google_secret_manager_secret.gemini_api_key.id
  secret_data = "REPLACE_WITH_REAL_GEMINI_API_KEY"

  lifecycle {
    ignore_changes = [secret_data]
  }
}

resource "google_secret_manager_secret_iam_member" "api_gemini_access" {
  secret_id = google_secret_manager_secret.gemini_api_key.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.api_sa_email}"
}

# --- Cloud Run v2 Service ---

resource "google_cloud_run_v2_service" "api" {
  name     = "sinapsek-api-${var.environment}"
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.api_sa_email

    scaling {
      min_instance_count = 0
      max_instance_count = 10
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [var.db_connection]
      }
    }

    containers {
      image = var.api_image_url

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_url.secret_id
            version = "latest"
          }
        }
      }

      env {
        name  = "ENVIRONMENT"
        value = var.environment
      }

      env {
        name = "SECRET_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.app_secret_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.gemini_api_key.secret_id
            version = "latest"
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

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_secret_manager_secret_version.db_url_v1,
    google_secret_manager_secret_version.app_secret_key_v1,
    google_secret_manager_secret_version.gemini_api_key_v1,
  ]
}

resource "google_cloud_run_v2_service_iam_member" "public" {
  project  = var.project_id
  location = google_cloud_run_v2_service.api.location
  name     = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# --- Custom Domain Mapping ---
# Requires domain ownership verified in Google Search Console:
# https://search.google.com/search-console → verify migueldev11.com

resource "google_cloud_run_domain_mapping" "api" {
  location = var.region
  name     = var.custom_domain

  metadata {
    namespace = var.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.api.name
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

# --- Outputs ---

output "api_url" {
  value = google_cloud_run_v2_service.api.uri
}

output "api_sa_email" {
  value = var.api_sa_email
}

output "dns_records" {
  value = try(google_cloud_run_domain_mapping.api.status[0].resource_records, [])
}
