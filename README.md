# Internal Developer Platform (IDP)

Welcome to the caps360 Internal Developer Platform (IDP). This repository is a comprehensive, cloud-native showcase of modern Platform Engineering, DevOps, SRE, and GitOps capabilities. It provisions scalable infrastructure, sets up a complete Kubernetes platform layer, automates application delivery via Argo CD, and provides a developer portal using Backstage.

## Architecture Highlights

This platform is designed to be highly modular, scalable, and enterprise-ready.

- **Infrastructure as Code (IaC)**: Provisioned using Terraform (AWS EKS).
- **GitOps Deployment**: Powered by Argo CD utilizing the "App of Apps" pattern.
- **Observability Stack**: Integrated Prometheus, Grafana, and Loki for metrics and centralized logging.
- **Security & Governance**: Kyverno for policy enforcement (e.g., non-root containers) and robust RBAC.
- **Developer Portal**: Backstage instance for service cataloging and scaffolding.
- **CI/CD Automation**: GitHub Actions for building, scanning (Trivy), and deploying microservices.

## Repository Structure

The repository follows a clean, monorepo architecture suitable for platform engineering teams:

- `infrastructure/`: Terraform code for AWS EKS clusters and VPCs across multiple environments (`dev`, `staging`, `prod`).
- `platform-services/`: Argo CD application definitions and base Kubernetes manifests (Namespaces, Quotas, RBAC, Ingress, Security, Observability, Backstage).
- `apps/`: Source code for our example microservice (`example-microservice`), demonstrating developer onboarding.
- `ci-cd/`: GitHub Actions workflows for continuous integration and continuous deployment.
- `helm-charts/`: Standardized, "golden-path" Helm charts for deploying stateless microservices securely and consistently.
- `docs/`: Comprehensive architecture and setup guides.

## Getting Started

To explore this platform, please refer to the detailed documentation:

1. **[Architecture Overview](docs/architecture.md)**: Deep dive into the platform layers.
2. **[Setup & Deployment Guide](docs/setup.md)**: Instructions on provisioning the infrastructure and bootstrapping Argo CD.
3. **[GitOps Workflow](docs/gitops-workflow.md)**: Learn how applications are automatically synchronized from Git to Kubernetes.

## Core Technologies

- **Kubernetes** (AWS EKS)
- **Terraform**
- **Argo CD**
- **Helm**
- **GitHub Actions**
- **Prometheus & Grafana**
- **Loki & Promtail**
- **Kyverno**
- **Backstage**

## Contributing

This platform is managed by the Platform Engineering team. All changes to infrastructure and platform services should be submitted via Pull Requests and will be validated by CI before merging. Application teams are encouraged to utilize the `golden-path-service` Helm chart for standard deployments.
