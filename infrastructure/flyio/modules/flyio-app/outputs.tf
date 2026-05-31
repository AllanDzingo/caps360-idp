output "app_id" {
  description = "Fly.io application ID"
  value       = fly_app.app.id
}

output "app_name" {
  description = "Fly.io application name"
  value       = fly_app.app.name
}

output "ipv4_address" {
  description = "IPv4 address of the application"
  value       = fly_ip_address.ipv4.address
}

output "ipv6_address" {
  description = "IPv6 address of the application"
  value       = fly_ip_address.ipv6.address
}

output "machine_ids" {
  description = "IDs of the deployed machines"
  value       = fly_machine.app[*].id
}

output "domain_name" {
  description = "Custom domain name"
  value       = try(fly_domain.domain[0].name, null)
}

output "domain_status" {
  description = "Domain status"
  value       = try(fly_domain.domain[0].*, null)
}

output "app_url" {
  description = "Application URL"
  value       = var.domain != null ? "https://${var.domain}" : "https://${fly_app.app.name}.fly.dev"
}
