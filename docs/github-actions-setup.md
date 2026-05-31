# GitHub Actions Setup for Fly.io

## Required Secrets

Add the following secrets to your GitHub repository settings:

### 1. Fly.io API Token

**Name**: `FLY_API_TOKEN`

**Value**: Your Fly.io API token

**How to create**:
```bash
flyctl tokens create deploy
```

**Where to add**:
- Repository Settings → Secrets and variables → Actions → New repository secret

### 2. Optional: Slack Webhook (for notifications)

**Name**: `SLACK_WEBHOOK`

**Value**: Your Slack webhook URL

**How to create**:
1. Go to https://api.slack.com/apps
2. Create new app or select existing
3. Go to "Incoming Webhooks" → "Add New Webhook to Workspace"
4. Select channel and authorize

## Secrets Configuration

### Step-by-Step

1. Navigate to your GitHub repository
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following:

| Name | Value | Notes |
|------|-------|-------|
| `FLY_API_TOKEN` | `flydeploy_...` | Required. From `flyctl tokens create deploy` |
| `SLACK_WEBHOOK` | `https://hooks.slack.com/...` | Optional. For deployment notifications |

## Workflow Environment Variables

The workflows use GitHub's environment variables feature:

```yaml
env:
  FLY_REGISTRY_HOST: registry.fly.io
  FLY_ORG: personal
```

Update `FLY_ORG` if your Fly.io organization has a different name.

## Deploying via GitHub Actions

### Automatic Deployments

Simply push to trigger automatic deployment:

```bash
# Deploy to production
git push origin main

# Deploy to staging
git push origin staging

# Deploy to development
git push origin develop
```

### Workflow Files

Located in `.github/workflows/`:

- **`deploy-flyio.yaml`** - Main deployment workflow
- **`build-registry.yaml`** - Optional: build and push Docker images

## Monitoring Deployments

### View Workflow Run

1. Go to your repository
2. Click **Actions** tab
3. Select workflow run to view logs

### Debug Failed Deployments

1. Click the failed workflow
2. Click the failed job
3. Expand steps to see error logs
4. Common issues:
   - Invalid `FLY_API_TOKEN`
   - Branch not found
   - Image build failure
   - Health check timeout

## Manual Deployments

If you prefer manual control:

```bash
cd apps/example-microservice

# Dev
cp fly.toml.dev fly.toml
flyctl deploy -a caps-idp-example-dev

# Staging
cp fly.toml.staging fly.toml
flyctl deploy -a caps-idp-example-staging

# Production
cp fly.toml.prod fly.toml
flyctl deploy -a caps-idp-example-prod
```

## Rollback Previous Deployment

```bash
# View deployment history
flyctl releases -a caps-idp-example-prod

# Rollback to previous
flyctl releases rollback -a caps-idp-example-prod
```

## Troubleshooting

### Workflow Won't Run

- Check branch name matches trigger conditions (main, staging, develop)
- Verify files modified are in `apps/example-microservice/`
- Check workflow file syntax is valid

### Deployment Fails

```
Error: unauthorized: 401 Unauthorized
```
→ `FLY_API_TOKEN` is invalid or expired. Generate new one with `flyctl tokens create deploy`

```
Error: machine failed to start: timeout waiting for TCP connection on 8080
```
→ Application not starting. Check logs: `flyctl logs -a caps-idp-example-prod`

```
Error: health check failed
```
→ Health endpoint not responding. Verify `/health` endpoint is implemented.

## Best Practices

1. ✅ **Keep tokens secure** - Never commit tokens to Git
2. ✅ **Use branch protection** - Require approvals before deploying to prod
3. ✅ **Monitor logs** - Check deployment logs for errors
4. ✅ **Test locally** - Run `flyctl deploy` locally before pushing
5. ✅ **Backup state** - Keep Terraform state backed up

## Advanced Configuration

### Deploy on Release Only

Edit `.github/workflows/deploy-flyio.yaml`:

```yaml
on:
  release:
    types: [created, edited]
```

### Manual Approval for Production

Add to workflow:

```yaml
jobs:
  deploy:
    environment:
      name: production
      required-reviewers:
        - your-username
```

### Deploy to Multiple Regions

Create separate workflow for each region or use matrix:

```yaml
strategy:
  matrix:
    region: [iad, ord, lax, syd]
```

## Reference

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Fly.io CI/CD Guide](https://fly.io/docs/app-guides/continuous-deployment-with-github-actions/)
- [Secrets Management](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
