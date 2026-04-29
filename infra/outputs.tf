output "api_url" {
  value = module.cloud_run.api_url
}

output "godaddy_dns_instructions" {
  description = "Configura estos registros en el panel DNS de GoDaddy"
  value       = module.cloud_run.dns_records
}
