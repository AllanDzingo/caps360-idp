# Internal Developer Platform (IDP)

Welcome to the caps360 Internal Developer Platform (IDP). This repository demonstrates modern Platform Engineering, DevOps, and cloud-native deployment practices. It supports multiple deployment targets:

- **Fly.io** (Recommended): Simplified, cost-effective edge platform
- **AWS EKS** (Original): Enterprise Kubernetes setup with full observability stack

## Deployment Options

### 🚀 Fly.io (Recommended)

A modern, edge-based deployment platform offering:
- Simple configuration with `fly.toml`
- Global reach with edge computing
- Built-in TLS, load balancing, and auto-scaling
- ~$55/month for production setup
- No Kubernetes complexity

**Get Started**: [Fly.io Quick Start](docs/flyio-quickstart.md)

### ☸️ AWS EKS (Original)

Enterprise Kubernetes setup with:
- Full observability stack (Prometheus, Grafana, Loki)
- GitOps via Argo CD
- Kyverno policy enforcement
- Backstage developer portal
- Higher operational complexity

**Get Started**: [Setup & Deployment Guide](docs/setup.md)

## Repository Structure

```
infrastructure/
├── flyio/                    # Fly.io Terraform modules & configs
│   ├── modules/
│   │   └── flyio-app/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
└── environments/            # AWS EKS (Legacy)
    ├── dev/
    ├── staging/
    └── prod/

apps/
└── example-microservice/
    ├── main.go              # Go HTTP server
    ├── Dockerfile           # Container definition
    ├── fly.toml.dev         # Fly.io dev config
    ├── fly.toml.staging     # Fly.io staging config
    └── fly.toml.prod        # Fly.io prod config

ci-cd/
└── .github/workflows/
    ├── deploy-flyio.yaml    # Fly.io deployment
    └── build-registry.yaml  # Optional: Container registry

docs/
├── flyio-quickstart.md      # Get running in 5 minutes
├── flyio-deployment.md      # Full deployment guide
├── flyio-terraform.md       # Infrastructure as Code
├── flyio-architecture.md    # System design & scaling
└── github-actions-setup.md  # CI/CD configuration
```

## Quick Start

### Fly.io (5 minutes)

```bash
# 1. Install flyctl
curl -L https://fly.io/install.sh | sh

# 2. Authenticate
flyctl auth login

# 3. Deploy
cd apps/example-microservice
flyctl deploy

# 4. View logs
flyctl logs -a <app-name>
```

See [Fly.io Quick Start](docs/flyio-quickstart.md) for detailed instructions.

### AWS EKS (Enterprise)

Follow the [Setup & Deployment Guide](docs/setup.md)

## Documentation

### Fly.io Deployment
- [Quick Start (5 min setup)](docs/flyio-quickstart.md)
- [Full Deployment Guide](docs/flyio-deployment.md)
- [Infrastructure as Code (Terraform)](docs/flyio-terraform.md)
- [Platform Architecture](docs/flyio-architecture.md)
- [GitHub Actions Setup](docs/github-actions-setup.md)

### AWS EKS (Original)
- [Architecture Overview](docs/architecture.md)
- [Setup & Deployment](docs/setup.md)
- [GitOps Workflow](docs/gitops-workflow.md)

## Core Technologies

### Fly.io Stack
- **Fly.io** - Edge computing platform
- **Terraform** - Infrastructure as Code
- **GitHub Actions** - CI/CD
- **Docker** - Containerization
- **Go** - Application runtime

### AWS EKS Stack
- **AWS EKS** - Kubernetes service
- **Terraform** - Infrastructure as Code
- **Argo CD** - GitOps orchestration
- **Helm** - Package management
- **GitHub Actions** - CI/CD
- **Prometheus & Grafana** - Metrics
- **Loki & Promtail** - Logging
- **Kyverno** - Policy enforcement
- **Backstage** - Developer portal

## Deployment Comparison

| Feature | Fly.io | AWS EKS |
|---------|--------|---------|
| **Complexity** | Simple | High |
| **Cost/Month** | $55-95 | $200+ |
| **Setup Time** | 5 minutes | 2-3 hours |
| **Global Distribution** | Built-in | Multi-region setup |
| **Observability** | Basic | Full stack |
| **Developer Portal** | None | Backstage |
| **Kubernetes** | No | Yes |
| **Best For** | Startups, MVP | Enterprise, complex apps |

## Getting Started

Choose your deployment platform:

### Option 1: Fly.io (Recommended for new projects)

1. Read [Fly.io Quick Start](docs/flyio-quickstart.md) (5 minutes)
2. Follow [Full Deployment Guide](docs/flyio-deployment.md)
3. Deploy with GitHub Actions or `flyctl deploy`

### Option 2: AWS EKS (Enterprise setup)

1. Read [Architecture Overview](docs/architecture.md)
2. Follow [Setup & Deployment Guide](docs/setup.md)
3. Deploy infrastructure with Terraform
4. Bootstrap Argo CD

## Contributing

### Fly.io Changes
- Modify `infrastructure/flyio/` for infrastructure
- Update `apps/example-microservice/fly.toml.*` for configuration
- Edit `.github/workflows/deploy-flyio.yaml` for CI/CD

### EKS Changes
- Modify `infrastructure/environments/` for infrastructure
- Update `platform-services/` for platform components
- Edit `helm-charts/` for application deployment
- Update `.github/workflows/ci.yaml` for CI/CD

All changes require Pull Requests and pass CI validation before merging.

## Support & Resources

- 📚 [Full Documentation](docs/)
- 🚀 [Fly.io Docs](https://fly.io/docs/)
- ☸️ [Kubernetes Docs](https://kubernetes.io/docs/)
- 🔄 [Argo CD Docs](https://argo-cd.readthedocs.io/)
- 💬 [Community Chat](https://community.fly.io)
