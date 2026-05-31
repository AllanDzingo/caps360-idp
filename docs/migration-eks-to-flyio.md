# Migration Guide: EKS to Fly.io

This guide helps you migrate from the existing AWS EKS setup to Fly.io.

## Overview

This is a **side-by-side migration** - you can run both platforms simultaneously during testing, then switch traffic to Fly.io once verified.

## Pre-Migration Checklist

- [ ] Review [Fly.io Architecture](flyio-architecture.md)
- [ ] Understand [Fly.io Deployment](flyio-deployment.md)
- [ ] Have Fly.io account and flyctl CLI installed
- [ ] Review GitHub Actions setup requirements
- [ ] Document current DNS configuration
- [ ] Backup current application state
- [ ] Identify all environment variables and secrets

## Phase 1: Preparation (Day 1)

### 1.1 Set Up Fly.io Infrastructure

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Authenticate
flyctl auth login

# Generate API token for CI/CD
flyctl tokens create deploy
# Save token as FLY_API_TOKEN in GitHub Secrets
```

### 1.2 Configure Terraform

```bash
cd infrastructure/flyio/environments/dev

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit configuration (your values)
nano terraform.tfvars

# Initialize Terraform
terraform init

# Review changes
terraform plan
```

### 1.3 Set Up GitHub Actions

Add GitHub Secrets:
- `FLY_API_TOKEN` = Your Fly API token
- `SLACK_WEBHOOK` = (optional) Slack notification webhook

See [GitHub Actions Setup](github-actions-setup.md) for details.

## Phase 2: Development Environment (Day 1-2)

### 2.1 Deploy Development App

```bash
cd infrastructure/flyio/environments/dev

# Apply Terraform configuration
terraform apply

# Or manually:
cd apps/example-microservice
cp fly.toml.dev fly.toml
flyctl deploy -a caps-idp-example-dev
```

### 2.2 Configure Secrets (if needed)

```bash
# Set any secrets your app needs
flyctl secrets set DATABASE_URL="postgres://..." -a caps-idp-example-dev
flyctl secrets set API_KEY="your-key" -a caps-idp-example-dev
```

### 2.3 Test Development Deployment

```bash
# Check status
flyctl status -a caps-idp-example-dev

# View logs
flyctl logs -a caps-idp-example-dev

# Health check
curl https://caps-idp-example-dev.fly.dev/health

# Smoke test
curl https://caps-idp-example-dev.fly.dev
```

### 2.4 Verify CI/CD Pipeline

```bash
# Push to develop branch to trigger GitHub Actions
git push origin develop

# Watch the workflow run
# GitHub → Actions → deploy-flyio workflow
```

## Phase 3: Staging Environment (Day 2-3)

### 3.1 Deploy Staging App

```bash
cd infrastructure/flyio/environments/staging

# Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars

# Deploy
terraform init
terraform apply
```

### 3.2 Load Testing

```bash
# Install load testing tool (optional)
# Using Apache Bench
ab -n 1000 -c 10 https://caps-idp-example-staging.fly.dev/

# Or using hey
go install github.com/rakyll/hey@latest
hey -n 1000 -c 10 https://caps-idp-example-staging.fly.dev/
```

### 3.3 Verify Auto-Scaling

```bash
# Monitor metrics
flyctl metrics -a caps-idp-example-staging

# Watch machines scale up/down
watch flyctl machines list -a caps-idp-example-staging
```

## Phase 4: Production Environment (Day 3-4)

### 4.1 Deploy Production App

```bash
cd infrastructure/flyio/environments/prod

# Configure for production
cp terraform.tfvars.example terraform.tfvars

# Edit with production values
nano terraform.tfvars
# - Set domain to your production domain
# - Set machine_count to 3
# - Set cpu to 2
# - Set memory_mb to 1024

# Deploy
terraform init
terraform apply
```

### 4.2 Set Custom Domain (Optional)

```bash
# Add custom domain to Fly app
flyctl certs add example.com -a caps-idp-example-prod

# Follow instructions to update DNS:
# Add these records to your domain registrar:
# Type A:    XXXX.XXXX.example.com
# Type AAAA: XXXX:XXXX:XXXX:XXXX::XXXX

# Verify certificate
flyctl certs list -a caps-idp-example-prod
```

### 4.3 Smoke Tests

```bash
# Health check
curl https://caps-idp-example-prod.fly.dev/health

# Application test
curl https://caps-idp-example-prod.fly.dev

# If using custom domain:
curl https://example.com/health
```

### 4.4 Monitor Production

```bash
# Real-time metrics
flyctl metrics -a caps-idp-example-prod

# Logs
flyctl logs -a caps-idp-example-prod --follow

# Machine status
flyctl machines list -a caps-idp-example-prod
```

## Phase 5: DNS Cutover (Day 4-5)

### 5.1 Traffic Shifting Strategy

**Recommended: Gradual cutover**

1. Update DNS TTL to 5 minutes (low value)
2. Update DNS to point 10% to Fly.io, 90% to EKS
3. Monitor errors for 1 hour
4. Shift 50% traffic
5. Monitor for 2 hours
6. Shift 100% to Fly.io

### 5.2 Update DNS Records

If using custom domain:

```bash
# Previous DNS records pointed to EKS ALB
# example.com CNAME → ALB-xxx.elb.us-east-1.amazonaws.com

# Update to Fly.io
# example.com CNAME → caps-idp-example-prod.fly.dev
# OR if Fly assigned A records:
# example.com A XXXX.XXXX...
```

### 5.3 Monitor Cutover

```bash
# Watch logs for errors
flyctl logs -a caps-idp-example-prod --follow

# Check metrics
flyctl metrics -a caps-idp-example-prod

# Test from multiple locations
curl https://example.com
curl https://example.com/health
```

## Phase 6: Verification & Cleanup (Day 5+)

### 6.1 Verification Checklist

- [ ] Production app responding to requests
- [ ] Health checks passing
- [ ] No increase in error rate
- [ ] Performance metrics acceptable
- [ ] Custom domain resolving correctly
- [ ] TLS certificates valid
- [ ] Auto-scaling working
- [ ] Logs being collected

### 6.2 Run Integration Tests

```bash
# If you have test suite
cd apps/example-microservice
go test ./...

# Manual test script
#!/bin/bash
domain="example.com"
for i in {1..100}; do
  response=$(curl -s $domain)
  if echo "$response" | grep -q "Hello from the caps360"; then
    echo "✓ Test $i passed"
  else
    echo "✗ Test $i failed"
  fi
done
```

### 6.3 Archive EKS (Keep for 30 Days)

```bash
# Keep EKS running as fallback for 30 days
# Do NOT delete immediately

# Actions:
# 1. Update EKS cluster to minimal state
# 2. Scale down Argo CD
# 3. Document decommissioning steps
# 4. Keep backups
# 5. Set calendar reminder for day 30

# On day 30:
# 1. Verify no traffic to EKS
# 2. Run final backups
# 3. Delete Terraform state: terraform destroy
# 4. Clean up AWS resources
```

### 6.4 Cost Comparison

```bash
# Track costs for 30 days
# AWS EKS: $X/month
# Fly.io: $Y/month
# Savings: $(X-Y)/month

echo "Monthly savings: \$(200 - 55) = \$145"
```

## Rollback Plan

If you encounter critical issues during migration:

### Immediate Rollback

```bash
# DNS: Point back to EKS ALB
# Time: ~5 minutes (depends on TTL)

# Database: If data was written to Fly.io volume
# 1. Export data from Fly.io volume
# 2. Import to EKS database
# 3. Verify data integrity
```

### Selective Rollback

```bash
# If only one environment is problematic:

# Dev issues → Keep running EKS dev only
# Staging issues → Keep running on EKS staging
# Prod issues → Full rollback to EKS

# Note: Requires DNS pointing to correct endpoints
```

## Post-Migration Tasks

### 1. Update Documentation

- [ ] Update README (mark EKS as legacy)
- [ ] Update team runbooks
- [ ] Document Fly.io specific procedures
- [ ] Create troubleshooting guides

### 2. Training

- [ ] Train team on Fly.io CLI
- [ ] Share best practices
- [ ] Document common tasks
- [ ] Set up team runbooks

### 3. Monitoring Setup

- [ ] Set up alerts for deployment failures
- [ ] Configure health check monitoring
- [ ] Set up performance baselines
- [ ] Create dashboard

### 4. Optimize Costs

- [ ] Review machine sizes
- [ ] Adjust auto-scaling thresholds
- [ ] Consider reserved capacity
- [ ] Monitor data transfer

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|-----------------|
| Preparation | 1 day | Tools installed, secrets configured |
| Development | 1-2 days | App deployed and tested |
| Staging | 1 day | Load testing complete, scaling verified |
| Production | 1 day | App deployed with monitoring |
| DNS Cutover | 1 day | Gradual traffic shift completed |
| Verification | 1+ day | All systems stable |
| Cleanup | 30 days | EKS decommissioned |
| **Total** | **~1 week** | Full migration complete |

## Troubleshooting

### Deployment Fails

```bash
# Check logs
flyctl logs -a caps-idp-example-prod

# Check app status
flyctl status -a caps-idp-example-prod

# Validate Dockerfile
docker build apps/example-microservice
```

### Metrics Abnormal

```bash
# Monitor machines
flyctl machines list -a caps-idp-example-prod

# Check resources
flyctl ssh console -a caps-idp-example-prod
top

# Scale up if needed
flyctl scale count 5 -a caps-idp-example-prod
```

### DNS Not Resolving

```bash
# Check Fly.io DNS
flyctl info -a caps-idp-example-prod

# Test DNS
dig example.com
nslookup example.com

# Wait for TTL (up to 24 hours)
```

## Support

- Fly.io Docs: https://fly.io/docs/
- Community: https://community.fly.io
- Issues: GitHub Issues
- Slack: #platform-team channel

## Lessons Learned Document

After migration, create a document with:
- What went well
- What was challenging
- Time estimates vs actual
- Cost comparisons
- Recommendations for others
