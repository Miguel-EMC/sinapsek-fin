resource "google_compute_network" "vpc" {
  name                    = "sinapsek-vpc-${var.environment}"
  auto_create_subnetworks = true
}

# Reservar un rango de IPs privadas para servicios de Google (como Cloud SQL)
resource "google_compute_global_address" "private_ip_address" {
  name          = "sinapsek-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}

# Crear la conexión privada entre tu VPC y los servicios de Google
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

# Salida para asegurar que la conexión esté lista antes de crear la DB
output "network_self_link" {
  value = google_compute_network.vpc.self_link
}

output "private_network_connection_id" {
  value = google_service_networking_connection.private_vpc_connection.id
}
