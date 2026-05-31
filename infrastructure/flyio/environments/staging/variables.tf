variable "fly_api_token" {
  description = "Fly.io API token"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "caps-idp-example-staging"
}

variable "docker_image" {
  description = "Docker image URL"
  type        = string
}

variable "region" {
  description = "Fly.io region"
  type        = string
  default     = "iad"
}

variable "machine_count" {
  description = "Number of machines"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "Number of CPUs"
  type        = number
  default     = 1
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 512
}

variable "domain" {
  description = "Custom domain"
  type        = string
  default     = null
}

variable "app_secrets" {
  description = "Application secrets"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "create_volume" {
  description = "Create persistent volume"
  type        = bool
  default     = true
}

variable "volume_size_gb" {
  description = "Volume size in GB"
  type        = number
  default     = 20
}
