variable "app_name" {
  description = "Name of the Fly.io application"
  type        = string
}

variable "region" {
  description = "Fly.io region"
  type        = string
  default     = "iad"
}

variable "docker_image" {
  description = "Docker image URL"
  type        = string
}

variable "cpu" {
  description = "Number of CPUs"
  type        = number
  default     = 1
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 256
}

variable "machine_count" {
  description = "Number of machines to create"
  type        = number
  default     = 1
}

variable "internal_port" {
  description = "Internal application port"
  type        = number
  default     = 8080
}

variable "external_port" {
  description = "External port"
  type        = number
  default     = 80
}

variable "app_env_variables" {
  description = "Environment variables for the application"
  type        = map(string)
  default     = {}
}

variable "app_secrets" {
  description = "Secrets to be set as environment variables"
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "domain" {
  description = "Custom domain name"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Health check endpoint path"
  type        = string
  default     = "/health"
}

variable "create_volume" {
  description = "Whether to create a persistent volume"
  type        = bool
  default     = false
}

variable "volume_size_gb" {
  description = "Volume size in GB"
  type        = number
  default     = 10
}
