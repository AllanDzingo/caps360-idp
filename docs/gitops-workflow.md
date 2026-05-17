# GitOps Workflow

This platform implements a strict GitOps workflow, treating Git as the single source of truth for both application code and infrastructure configuration.

## Overview

We use **Argo CD** to continuously monitor this Git repository and synchronize changes into the Kubernetes cluster. Direct `kubectl apply` commands are discouraged and should only be used for the initial cluster bootstrap or emergency break-glass scenarios.

## Application Deployment Lifecycle

1. **Code Commit**: A developer commits application code to the `apps/example-microservice` directory.
2. **Continuous Integration**: GitHub Actions detects the change and triggers the `ci.yaml` workflow.
3. **Build & Scan**: The workflow builds a new Docker image, tags it with the Git SHA, pushes it to the registry, and scans it for vulnerabilities using Trivy.
4. **GitOps Update**: The final step of the CI pipeline uses `sed` to update the image tag in the application's Helm `values.yaml` file (`apps/example-microservice/manifests/values-dev.yaml`). The pipeline then commits and pushes this change back to the repository.
5. **Synchronization**: Argo CD detects the updated `values-dev.yaml` file in the Git repository and automatically synchronizes the new state into the `dev` namespace in the Kubernetes cluster.

## Environment Promotion

Promoting an application from `dev` to `prod` involves updating the `values-prod.yaml` file to reflect the image tag that was successfully tested in development.

In a mature setup, this promotion process is handled via Pull Requests. A developer or release manager creates a PR updating the production manifests, and upon merge, Argo CD synchronizes the changes to the production namespace.

## Rollbacks

Because all state is tracked in Git, rolling back an application or platform component is as simple as reverting a Git commit.

```bash
git revert <bad-commit-hash>
git push origin main
```

Argo CD will immediately sync the reverted state back to the cluster.
