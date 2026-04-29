resource "google_sql_database_instance" "main" {
  name             = "sinapsek-fin-${var.environment}"
  database_version = "POSTGRES_15"
  region           = var.region
  depends_on       = [var.db_depends_on]

  settings {
    tier = "db-f1-micro" # Free tier eligible

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.vpc_id
    }

    backup_configuration {
      enabled    = true
      start_time = "04:00"
    }
    insights_config {
      query_insights_enabled = true
    }
  }

  deletion_protection = var.environment == "prod"
}

resource "google_sql_database" "app" {
  name     = "sinapsek_fin"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}

output "connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
