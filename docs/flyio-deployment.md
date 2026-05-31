# Fly.io Deployment Guide

This guide covers how to deploy and manage the CAPS IDP on Fly.io platform.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Architecture](#architecture)
4. [Setup Instructions](#setup-instructions)
5. [Deployment](#deployment)
6. [Infrastructure as Code](#infrastructure-as-code)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Monitoring & Management](#monitoring--management)
9. [Scaling & Configuration](#scaling--configuration)
10. [Cost Optimization](#cost-optimization)

## Overview

Fly.io is a modern platform that allows you to deploy applications globally on edge computing infrastructure. This setup replaces the previous AWS EKS (Kubernetes) infrastructure with a simpler, more cost-effective alternative.

### Key Differences from Kubernetes Setup

| Aspect | AWS EKS | Fly.io |
|--------|---------|--------|
| **Deployment Model** | Kubernetes clusters | Lightweight VMs (Machines) |
| **Scaling** | Manual node provisioning | Automatic based on load |
| **Networking** | VPC + Security Groups | Built-in networking & TLS |
| **Cost** | Higher (compute + networking) | Pay per hour + storage |
| **Complexity** | High (requires K8s knowledge) | Low (simple config files) |
| **Global Presence** | Multi-region with ALB | Native edge locations |

## Prerequisites

### Required Tools

1. **Fly.io Account**: Sign up at [fly.io](https://fly.io)
2. **Flyctl CLI**: Download from [fly.io/docs/getting-started/installing-flyctl](https://fly.io/docs/getting-started/installing-flyctl/)
3. **Terraform**: Version 1.5 or higher
4. **GitHub Account**: For hosting and CI/CD
5. **Docker**: For local testing (optional but recommended)

### Set Up Fly.io CLI

```bash
# Install flyctl
curl -L https://fly.io/install.sh | sh

# Authenticate
flyctl auth login

# Create API token for CI/CD
flyctl tokens create deploy
```

Save the API token as `FLY_API_TOKEN` in your GitHub repository secrets.

## Architecture

### Components

```
┌─────────────────────────────────────────────────────────┐
│               GitHub Actions (CI/CD)                     │
│  • Build application                                     │
│  • Run tests                                             │
│  • Deploy to Fly.io                                      │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────────┐
        │      Fly.io Platform           │
        │                                │
        │  ┌──────────────────────────┐  │
        │  │  Development App         │  │
        │  │  • 1 Machine             │  │
        │  │  • 256MB RAM             │  │
        │  │  • Auto-stop when idle   │  │
        │  └──────────────────────────┘  │
        │                                │
        │  ┌──────────────────────────┐  │
        │  │  Staging App             │  │
        │  │  • 2 Machines            │  │
        │  │  • 512MB RAM each        │  │
        │  │  • Persistent volume     │  │
        │  └──────────────────────────┘  │
        │                                │
        │  ┌──────────────────────────┐  │
        │  │  Production App          │  │
        │  │  • 3 Machines            │  │
        │  │  • 1GB RAM each          │  │
        │  │  • 50GB persistent vol   │  │
        │  │  • TLS + custom domain   │  │
        │  └──────────────────────────┘  │
        └────────────────────────────────┘
```

## Setup Instructions

### 1. Initialize Fly.io Apps

```bash
cd apps/example-microservice

# Development
flyctl apps create caps-idp-example-dev
cp fly.toml.dev fly.toml
flyctl deploy

# Staging
flyctl apps create caps-idp-example-staging
cp fly.toml.staging fly.toml
flyctl deploy

# Production
flyctl apps create caps-idp-example-prod
cp fly.toml.prod fly.toml
flyctl deploy
```

### 2. Set Up GitHub Secrets

In your GitHub repository settings, add:

```
FLY_API_TOKEN=<token from flyctl tokens create deploy>
SLACK_WEBHOOK=<optional, for notifications>
```

### 3. Configure Environment Variables

Edit environment-specific `fly.toml` files:

```toml
# fly.toml
[env]
  APP_ENV = "development"
  PORT = "8080"
  # Add other environment variables here
```

### 4. Set Secrets (Sensitive Data)

```bash
# For each environment:
flyctl secrets set DATABASE_URL="postgres://..." -a caps-idp-example-dev
flyctl secrets set API_KEY="secret-key" -a caps-idp-example-dev
```

## Deployment

### Manual Deployment

```bash
cd apps/example-microservice

# Deploy to dev
cp fly.toml.dev fly.toml
flyctl deploy -a caps-idp-example-dev

# Deploy to staging
cp fly.toml.staging fly.toml
flyctl deploy -a caps-idp-example-staging

# Deploy to production
cp fly.toml.prod fly.toml
flyctl deploy -a caps-idp-example-prod
```

### Automated Deployment (GitHub Actions)

The repository includes GitHub Actions workflows that automatically deploy to Fly.io:

**Trigger**: Push to `main`, `staging`, or `develop` branches

**Workflow**: `.github/workflows/deploy-flyio.yaml`

```bash
# Push to trigger deployment
git push origin main  # Deploys to production
git push origin staging  # Deploys to staging
git push origin develop  # Deploys to development
```

### Deployment Process

1. GitHub Actions checks out the code
2. Determines target environment based on branch
3. Deploys using `flyctl deploy --remote-only`
4. Runs health checks
5. Executes smoke tests
6. Notifies results to Slack (if configured)

## Infrastructure as Code

### Terraform Setup

We provide Terraform modules for managing Fly.io infrastructure:

```bash
cd infrastructure/flyio/environments/dev

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

### Terraform Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `fly_api_token` | Fly.io API token | `abc123...` |
| `app_name` | Application name | `caps-idp-example-dev` |
| `docker_image` | Docker image URL | `ghcr.io/.../image:latest` |
| `machine_count` | Number of machines | `1`, `2`, `3` |
| `cpu` | CPU cores per machine | `1`, `2` |
| `memory_mb` | RAM per machine | `256`, `512`, `1024` |
| `region` | Fly.io region | `iad`, `ord`, `lax` |
| `domain` | Custom domain | `example.com` |

### Environment Configurations

**Development**
```
machines: 1
cpu: 1
memory: 256MB
region: iad
auto-stop: yes
```

**Staging**
```
machines: 2
cpu: 1
memory: 512MB
region: iad
auto-stop: no
```

**Production**
```
machines: 3
cpu: 2
memory: 1GB
region: iad
auto-stop: no
domain: example.com (custom)
```

## CI/CD Pipeline

### GitHub Actions Workflows

#### 1. Deploy to Fly.io (`deploy-flyio.yaml`)

**Triggers**: Push to main/staging/develop

**Steps**:
1. Checkout code
2. Determine environment from branch
3. Deploy to Fly.io
4. Run health checks
5. Execute smoke tests
6. Send notifications

**Secrets Required**:
- `FLY_API_TOKEN`
- `SLACK_WEBHOOK` (optional)

#### 2. Build & Push Registry (`build-registry.yaml`)

Optional workflow for building Docker images for container registry (useful for multi-app scenarios).

**Triggers**: Push to main

**Steps**:
1. Checkout code
2. Build Go application
3. Build Docker image
4. Push to GHCR
5. Scan for vulnerabilities (Trivy)
6. Upload SARIF report

### Branch Strategy

```
main (production)
  └─ Auto-deploy to production
staging (staging)
  └─ Auto-deploy to staging
develop (development)
  └─ Auto-deploy to development
```

## Monitoring & Management

### Check Deployment Status

```bash
# List all apps
flyctl apps list

# Check app status
flyctl status -a caps-idp-example-prod

# View recent deployments
flyctl releases -a caps-idp-example-prod

# View logs
flyctl logs -a caps-idp-example-prod
```

### Monitor Metrics

```bash
# SSH into machine
flyctl ssh console -a caps-idp-example-prod

# Real-time metrics
flyctl metrics -a caps-idp-example-prod
```

### Health Checks

Each app has HTTP health checks configured:

```
Endpoint: /health
Interval: 30 seconds
Timeout: 5 seconds
```

Check health status:
```bash
curl https://caps-idp-example-prod.fly.dev/health
```

## Scaling & Configuration

### Horizontal Scaling

Scale number of machines:

```bash
# Using flyctl
flyctl machines list -a caps-idp-example-prod
flyctl scale count 5 -a caps-idp-example-prod  # Scale to 5 machines

# Using Terraform
# Edit terraform.tfvars:
# machine_count = 5
terraform apply -var="machine_count=5"
```

### Vertical Scaling

Increase CPU and memory:

```bash
# Edit fly.toml and redeploy
# OR using Terraform:
terraform apply -var="cpu=4" -var="memory_mb=2048"
```

### Regional Deployment

Deploy to multiple regions:

```bash
# Edit fly.toml
[build]
  ...

# Add regions (via API or flyctl)
flyctl regions add syd  # Sydney
flyctl regions add ams  # Amsterdam
```

## Cost Optimization

### Recommendations

1. **Development**: Use auto-stop machines to save costs
   ```toml
   auto_start_machines = true
   auto_stop_machines = true
   ```

2. **Staging**: Use shared CPU (vs dedicated)
   ```toml
   [[vm]]
     cpu_kind = "shared"  # Cheaper than "performance"
   ```

3. **Production**: Use dedicated CPUs for consistent performance
   ```toml
   [[vm]]
     cpu_kind = "dedicated"
   ```

4. **Storage**: Only create volumes when needed
5. **Monitoring**: Use Fly.io dashboards instead of external services

### Estimated Monthly Costs (May 2024)

| Environment | Machines | Config | Est. Cost |
|-------------|----------|--------|-----------|
| Development | 1 | 1CPU, 256MB | $2-5 |
| Staging | 2 | 1CPU, 512MB | $10-15 |
| Production | 3 | 2CPU, 1GB | $50-75 |
| **Total** | - | - | **$60-95/month** |

*Costs vary based on region and data transfer*

## Troubleshooting

### Deployment Fails

```bash
# Check logs
flyctl logs -a caps-idp-example-prod

# Check app status
flyctl status -a caps-idp-example-prod

# Rollback to previous deployment
flyctl releases -a caps-idp-example-prod
flyctl releases rollback -a caps-idp-example-prod
```

### App Won't Start

1. Check health endpoint is responding
2. Verify PORT environment variable is set
3. Check logs for startup errors
4. Ensure Dockerfile/application is correct

### Persistent Volume Issues

```bash
# List volumes
flyctl volumes list -a caps-idp-example-prod

# Create new volume
flyctl volumes create myvolume -a caps-idp-example-prod

# Mount in fly.toml
[mounts]
  source = "myvolume"
  destination = "/data"
```

## Additional Resources

- [Fly.io Documentation](https://fly.io/docs/)
- [Fly.io API Reference](https://api.fly.io/graphql)
- [Fly.io Community](https://community.fly.io)
- [Terraform Fly Provider](https://registry.terraform.io/providers/superfly/fly/latest/docs)

## Migration from Kubernetes

If migrating from the previous EKS setup:

1. **Remove Kubernetes resources**
   - Delete Argo CD apps
   - Remove Helm charts
   - Decommission EKS cluster

2. **Deploy on Fly.io**
   - Use new `fly.toml` files
   - Deploy via GitHub Actions or manual `flyctl deploy`

3. **Migrate Data**
   - Export from RDS/managed databases
   - Import to Fly.io Postgres app (if needed)
   - Or use managed database services

4. **Update DNS**
   - Point domain to Fly.io app
   - Update CNAME or A records

See [Fly.io Migration Guide](https://fly.io/docs/migrations/) for detailed steps.
