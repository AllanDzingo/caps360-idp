# Fly.io Terraform Guide

Using Infrastructure as Code to manage Fly.io deployments.

## Directory Structure

```
infrastructure/
├── flyio/
│   ├── modules/
│   │   └── flyio-app/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
```

## Quick Start

### 1. Set Up Development Environment

```bash
cd infrastructure/flyio/environments/dev

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

### 2. Configure terraform.tfvars

```hcl
fly_api_token = "your-api-token-here"
docker_image  = "ghcr.io/your-org/caps-idp/example-microservice:latest"
region        = "iad"
machine_count = 1
cpu           = 1
memory_mb     = 256
domain        = null
app_secrets   = {}
create_volume = false
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply configuration
terraform apply
```

### 4. View Outputs

```bash
terraform output
```

## Modules

### flyio-app Module

Manages a complete Fly.io application deployment.

**Inputs:**

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `app_name` | string | - | Application name |
| `region` | string | `iad` | Fly.io region |
| `docker_image` | string | - | Docker image URL |
| `cpu` | number | `1` | CPU cores |
| `memory_mb` | number | `256` | Memory in MB |
| `machine_count` | number | `1` | Number of machines |
| `internal_port` | number | `8080` | App port |
| `external_port` | number | `80` | External port |
| `app_env_variables` | map(string) | `{}` | Environment variables |
| `app_secrets` | map(string) | `{}` | Secrets (sensitive) |
| `domain` | string | `null` | Custom domain |
| `health_check_path` | string | `/health` | Health check endpoint |
| `create_volume` | bool | `false` | Create storage volume |
| `volume_size_gb` | number | `10` | Volume size |

**Outputs:**

| Output | Description |
|--------|-------------|
| `app_id` | Application ID |
| `app_name` | Application name |
| `ipv4_address` | IPv4 address |
| `ipv6_address` | IPv6 address |
| `machine_ids` | Machine IDs |
| `app_url` | Application URL |

## Environment Configurations

### Development

```hcl
# dev/terraform.tfvars
fly_api_token = "..."
app_name      = "caps-idp-example-dev"
docker_image  = "ghcr.io/.../example-microservice:latest"
region        = "iad"
machine_count = 1
cpu           = 1
memory_mb     = 256
create_volume = false
```

### Staging

```hcl
# staging/terraform.tfvars
fly_api_token = "..."
app_name      = "caps-idp-example-staging"
docker_image  = "ghcr.io/.../example-microservice:latest"
region        = "iad"
machine_count = 2
cpu           = 1
memory_mb     = 512
create_volume = true
```

### Production

```hcl
# prod/terraform.tfvars
fly_api_token = "..."
app_name      = "caps-idp-example-prod"
docker_image  = "ghcr.io/.../example-microservice:latest"
region        = "iad"
machine_count = 3
cpu           = 2
memory_mb     = 1024
domain        = "example.com"
create_volume = true
```

## Common Tasks

### Deploy New App

```bash
cd infrastructure/flyio/environments/prod

# Set up configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

# Deploy
terraform init
terraform apply
```

### Scale Application

```bash
# Update machine count
terraform apply -var="machine_count=5"

# Or update in terraform.tfvars
nano terraform.tfvars
terraform apply
```

### Increase Resources

```bash
# Scale CPU and memory
terraform apply -var="cpu=4" -var="memory_mb=2048"
```

### Add Custom Domain

```bash
# Update domain in terraform.tfvars
terraform apply -var="domain=example.com"
```

### Set Secrets

```bash
# Add secret to terraform.tfvars
# app_secrets = {
#   DATABASE_URL = "postgres://..."
#   API_KEY = "secret"
# }

terraform apply
```

### Remove Application

```bash
# Destroy all resources
terraform destroy
```

## State Management

### Local State (Development)

Default setup uses local state file (`.terraform/` directory).

```bash
# View state
terraform state show

# List resources
terraform state list

# Remove resource
terraform state rm 'fly_app.app'
```

### Remote State (Recommended for Teams)

Configure remote backend in `providers.tf`:

```hcl
terraform {
  backend "remote" {
    organization = "your-org"
    workspaces {
      name = "caps-idp-flyio-prod"
    }
  }
}
```

Then:

```bash
# Log in to Terraform Cloud
terraform login

# Initialize
terraform init
```

## Best Practices

### 1. Use Environment-Specific Configurations

- Separate `terraform.tfvars` per environment
- Use consistent naming conventions
- Store secrets in CI/CD or Terraform Cloud

### 2. Lock Terraform Version

```hcl
terraform {
  required_version = ">= 1.5"
  required_providers {
    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.1"
    }
  }
}
```

### 3. Organize Modules

```
infrastructure/
├── flyio/
│   ├── modules/
│   │   ├── flyio-app/          # App module
│   │   ├── flyio-postgres/     # Database (future)
│   │   └── flyio-redis/        # Cache (future)
│   └── environments/
```

### 4. Use Workspaces (Optional)

```bash
# Create workspace
terraform workspace new production

# Switch workspace
terraform workspace select production

# List workspaces
terraform workspace list
```

## Troubleshooting

### API Token Issues

```bash
# Generate new token
flyctl tokens create deploy

# Update in terraform.tfvars or environment variable
export TF_VAR_fly_api_token="new-token"
```

### State Lock

```bash
# Force unlock (use with caution!)
terraform force-unlock LOCK_ID
```

### Destroy and Recreate

```bash
# Remove from state
terraform state rm fly_app.app

# Recreate
terraform apply
```

### Check What Changed

```bash
# Show planned changes
terraform plan

# Show differences in state
terraform plan -refresh-only
```

## CI/CD Integration

### GitHub Actions

Store Fly API token as GitHub secret:

```yaml
env:
  TF_VAR_fly_api_token: ${{ secrets.FLY_API_TOKEN }}
```

Then deploy:

```bash
cd infrastructure/flyio/environments/prod
terraform init
terraform apply -auto-approve
```

See `.github/workflows/deploy-flyio.yaml` for full example.

## Resources

- [Terraform Fly Provider Docs](https://registry.terraform.io/providers/superfly/fly/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/language/index.html)
- [Fly.io Terraform Examples](https://github.com/superfly/terraform-provider-fly)
