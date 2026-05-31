# Fly.io Quick Start

Get up and running with Fly.io in 5 minutes.

## 1. Install Tools

```bash
# Install Fly CLI
curl -L https://fly.io/install.sh | sh

# Or using Homebrew (macOS)
brew install flyctl

# Verify installation
flyctl version
```

## 2. Authenticate

```bash
flyctl auth login
# Opens browser to log in or sign up
```

## 3. Create API Token for CI/CD

```bash
# Generate token
flyctl tokens create deploy

# Copy the token and add to GitHub Secrets as FLY_API_TOKEN
```

## 4. Deploy App

### Option A: Automatic (Recommended for CI/CD)

```bash
# Push to main branch - GitHub Actions automatically deploys
git push origin main
```

### Option B: Manual

```bash
cd apps/example-microservice

# Development
cp fly.toml.dev fly.toml
flyctl deploy -a caps-idp-example-dev

# Staging
cp fly.toml.staging fly.toml
flyctl deploy -a caps-idp-example-staging

# Production
cp fly.toml.prod fly.toml
flyctl deploy -a caps-idp-example-prod
```

## 5. Verify Deployment

```bash
# Check status
flyctl status -a caps-idp-example-dev

# View logs
flyctl logs -a caps-idp-example-dev

# Test health endpoint
curl https://caps-idp-example-dev.fly.dev/health

# Test application
curl https://caps-idp-example-dev.fly.dev
```

## 6. Set Environment Variables

```bash
# Set regular variables (plaintext)
flyctl config set APP_ENV=development -a caps-idp-example-dev

# Set secrets (encrypted)
flyctl secrets set DATABASE_URL="postgres://..." -a caps-idp-example-dev
flyctl secrets set API_KEY="secret" -a caps-idp-example-dev

# List current secrets
flyctl secrets list -a caps-idp-example-dev
```

## 7. Scale Your App

```bash
# View machines
flyctl machines list -a caps-idp-example-prod

# Scale machines
flyctl scale count 5 -a caps-idp-example-prod

# Check metrics
flyctl metrics -a caps-idp-example-prod
```

## 8. Set Custom Domain

```bash
# Add domain
flyctl certs add example.com -a caps-idp-example-prod

# Update DNS records as instructed
# You should get A and AAAA records to update with your registrar

# Verify certificate
flyctl certs list -a caps-idp-example-prod
```

## Troubleshooting

### Can't Deploy

```bash
# Check if app exists
flyctl apps list

# Create app if missing
flyctl apps create caps-idp-example-dev

# Check fly.toml syntax
flyctl validate
```

### App Won't Start

```bash
# View detailed logs
flyctl logs -a caps-idp-example-dev --follow

# SSH into machine
flyctl ssh console -a caps-idp-example-dev

# Check health endpoint is returning 200
curl -v https://caps-idp-example-dev.fly.dev/health
```

### Need Help?

- Docs: https://fly.io/docs/
- Community: https://community.fly.io
- CLI Help: `flyctl help`
- Specific Command: `flyctl deploy --help`
