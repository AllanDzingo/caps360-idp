# Setup & Deployment Guide

This guide covers the initial provisioning of the IDP. Because this platform utilizes GitOps, manual interaction with the cluster is kept to an absolute minimum.

## Prerequisites

- AWS CLI configured with administrator access
- Terraform (v1.5+)
- `kubectl`
- Helm (v3+)

## 1. Provision Infrastructure

Navigate to the desired environment and run Terraform.

```bash
cd infrastructure/environments/dev
terraform init
terraform plan
terraform apply
```

This step provisions the VPC and the EKS cluster. The Terraform output will provide the `cluster_endpoint` and command to configure `kubectl`.

```bash
aws eks update-kubeconfig --region af-south-1 --name caps360-idp-dev
```

## 2. Bootstrap Argo CD

While Terraform sets up the base Argo CD installation via the Helm provider, we need to apply the root "App of Apps" to kick off the GitOps synchronization.

```bash
kubectl apply -f platform-services/bootstrap.yaml
```

Once applied, Argo CD will reach out to this Git repository, read the `platform-services/argo-apps` directory, and begin deploying all platform components (Ingress, Observability, Security, Backstage) and configured applications automatically.

## 3. Accessing Services

You can access the services via port-forwarding or through the Ingress controller once DNS is configured to point to the AWS Network Load Balancer created by the NGINX Ingress Controller.

**Get Argo CD Admin Password:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Port Forward Argo CD:**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Open `https://localhost:8080` in your browser.

## 4. Teardown

To destroy the cluster, you must first remove the Argo CD applications to ensure load balancers and volumes are cleanly deleted.

```bash
kubectl delete -f platform-services/bootstrap.yaml
# Wait for apps to be removed...
cd infrastructure/environments/dev
terraform destroy
```
