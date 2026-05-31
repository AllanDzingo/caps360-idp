terraform {
  required_version = ">= 1.5"

  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.1"
    }
  }

  # Uncomment and configure for remote state management
  # backend "remote" {
  #   organization = "your-org"
  #   workspaces {
  #     name = "caps-idp-flyio-dev"
  #   }
  # }
}

provider "fly" {
  api_token = var.fly_api_token
}
