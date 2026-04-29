resource "google_service_account" "api_runner" {
  account_id   = "api-runner-${var.environment}"
  display_name = "Sinapsek API Runner"
}

resource "google_project_iam_member" "api_roles" {
  for_each = toset([
    "roles/cloudsql.client",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/storage.objectViewer",
    "roles/storage.objectCreator"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.api_runner.email}"
}

output "api_sa_email" {
  value = google_service_account.api_runner.email
}
