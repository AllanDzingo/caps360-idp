module "example_microservice" {
  source = "../../modules/flyio-app"

  app_name    = var.app_name
  docker_image = var.docker_image
  region      = var.region
  machine_count = var.machine_count

  cpu       = var.cpu
  memory_mb = var.memory_mb

  internal_port = 8080
  external_port = 80

  app_env_variables = {
    APP_ENV  = "development"
    LOG_LEVEL = "debug"
  }

  app_secrets = var.app_secrets

  domain = var.domain

  create_volume = var.create_volume
  volume_size_gb = var.volume_size_gb

  depends_on = []
}
