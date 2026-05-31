terraform {
  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.1"
    }
  }
}

# Create Fly.io App
resource "fly_app" "app" {
  name = var.app_name
}

# Set Environment Variables
resource "fly_ip_address" "ipv4" {
  app  = fly_app.app.name
  type = "v4"
}

resource "fly_ip_address" "ipv6" {
  app  = fly_app.app.name
  type = "v6"
}

# Create secrets for environment variables
resource "fly_app_secret" "secrets" {
  for_each = var.app_secrets

  app_id = fly_app.app.id
  name   = each.key
  value  = each.value
}

# Deploy application from Docker image
resource "fly_machine" "app" {
  count    = var.machine_count
  app      = fly_app.app.name
  name     = "${var.app_name}-${var.region}-${count.index}"
  region   = var.region
  image    = var.docker_image
  cpus     = var.cpu
  memorymb = var.memory_mb
  
  services = [
    {
      protocol     = "tcp"
      internal_port = var.internal_port
      ports = [
        {
          port     = var.external_port
          handlers = ["http"]
        },
        {
          port     = 443
          handlers = ["tls", "http"]
        }
      ]
      checks = [
        {
          kind     = "http"
          path     = var.health_check_path
          interval = "30s"
          timeout  = "5s"
        }
      ]
    }
  ]

  env = merge(
    var.app_env_variables,
    {
      PORT = tostring(var.internal_port)
    }
  )

  depends_on = [fly_app.app]
}

# Create volume if needed
resource "fly_volume" "storage" {
  count           = var.create_volume ? 1 : 0
  name            = "${var.app_name}-storage"
  app             = fly_app.app.name
  region          = var.region
  size_gb         = var.volume_size_gb
}

# DNS record
resource "fly_domain" "domain" {
  count   = var.domain != null ? 1 : 0
  name    = var.domain
  app_id  = fly_app.app.id
}

resource "fly_certificate" "certificate" {
  count      = var.domain != null ? 1 : 0
  app_id     = fly_app.app.id
  domain_name = var.domain
}
