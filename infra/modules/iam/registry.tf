resource "google_artifact_registry_repository" "api_repo" {
  location      = var.region
  repository_id = "api-repo"
  description   = "Docker repository for Sinapsek API"
  format        = "DOCKER"
}

output "repository_url" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.api_repo.repository_id}"
}
