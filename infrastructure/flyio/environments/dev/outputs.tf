output "app_id" {
  value       = module.example_microservice.app_id
  description = "Application ID"
}

output "app_name" {
  value       = module.example_microservice.app_name
  description = "Application name"
}

output "app_url" {
  value       = module.example_microservice.app_url
  description = "Application URL"
}

output "ipv4" {
  value       = module.example_microservice.ipv4_address
  description = "IPv4 address"
}

output "ipv6" {
  value       = module.example_microservice.ipv6_address
  description = "IPv6 address"
}
