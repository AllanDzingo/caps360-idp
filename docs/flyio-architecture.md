# Fly.io Platform Architecture

Updated architecture for Fly.io deployment.

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Clients / Users                         │
│                      (Global Internet Traffic)                  │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
        ┌─────────────────────────────────────┐
        │      Fly.io Global Edge Nodes       │
        │  • Anycast routing                  │
        │  • Edge caching                     │
        │  • DDoS protection                  │
        └─────────────────┬───────────────────┘
                          │
        ┌─────────────────┴───────────────────┐
        │                                     │
        ▼                                     ▼
    ┌─────────────────┐         ┌─────────────────────┐
    │   IAD Region    │         │  Additional Regions │
    │ (Washington DC) │         │  (ORD, LAX, SYD...)│
    │                 │         │                     │
    │ ┌─────────────┐ │         │ ┌─────────────────┐│
    │ │   Dev App   │ │         │ │  Staging Replicas││
    │ │  • 1 VM     │ │         │ │  • 2+ VMs       ││
    │ │  • 256 MB   │ │         │ │  • 512 MB+      ││
    │ └─────────────┘ │         │ └─────────────────┘│
    │                 │         │                     │
    │ ┌─────────────┐ │         │ ┌─────────────────┐│
    │ │Staging App  │ │         │ │  Prod Replicas  ││
    │ │  • 2 VMs    │ │         │ │  • 2-3 VMs      ││
    │ │  • 512 MB   │ │         │ │  • 1GB+         ││
    │ └─────────────┘ │         │ └─────────────────┘│
    │                 │         │                     │
    │ ┌─────────────┐ │         │                     │
    │ │  Prod App   │ │         │                     │
    │ │  • 3 VMs    │ │         │                     │
    │ │  • 1 GB     │ │         │                     │
    │ └─────────────┘ │         │                     │
    │                 │         │                     │
    │ ┌─────────────┐ │         │                     │
    │ │  Volumes    │ │         │                     │
    │ │ • 10-50 GB  │ │         │                     │
    │ └─────────────┘ │         │                     │
    └─────────────────┘         └─────────────────────┘
            ▲                            ▲
            │                            │
            └────────────────┬───────────┘
                             │
                    ┌────────▼─────────┐
                    │  Fly.io Network  │
                    │  • Private VPC   │
                    │  • Service mesh  │
                    │  • Auto-scaling  │
                    └──────────────────┘
```

## Application Architecture

### Stack Components

```
┌──────────────────────────────────────────────────────────────┐
│              Application Layer (Go HTTP Server)              │
│  • Express health checks                                     │
│  • Environment-aware logging                                │
│  • Graceful shutdown                                        │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│            Fly.io Machine Layer (Docker Container)           │
│  • Lightweight Alpine Linux base                            │
│  • Multi-stage build (optimize size)                        │
│  • Health checks (HTTP GET /health)                         │
│  • Restart policies                                         │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│             Networking Layer (Fly.io Network)               │
│  • Built-in TLS termination                                 │
│  • HTTP/2 support                                           │
│  • Load balancing across machines                           │
│  • Automatic certificate renewal (Let's Encrypt)           │
│  • Custom domain support                                    │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────┐
│            Storage Layer (Persistent Volumes)               │
│  • NVMe-backed block storage                                │
│  • 10-1000 GB options                                       │
│  • Automatic backups                                        │
│  • Mountable as filesystem                                  │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow

### Request Path

```
Client Request
    │
    ▼
Fly.io Anycast Edge
    │
    ▼
Global Load Balancer (Nearest Region)
    │
    ├─→ Healthy Machine Check
    │
    ▼
Region-Specific Load Balancer (IAD, ORD, etc)
    │
    ├─→ HTTP/2 Upgrade
    ├─→ TLS Termination
    ├─→ Cookie/Session Affinity (optional)
    │
    ▼
Application Machine Pool
    │
    ├─→ Machine 1 (Active)
    ├─→ Machine 2 (Standby/Active)
    └─→ Machine N (Auto-scaling)
    │
    ▼
Application Process
    │
    ├─→ Request Handler
    ├─→ Business Logic
    └─→ Data Access (if needed)
    │
    ▼
Response
    │
    ├─→ TLS Encryption
    ├─→ HTTP/2 Stream
    └─→ Return to Client
```

## Environment Configurations

### Development Environment

```yaml
App Name: caps-idp-example-dev
Region: iad (Washington DC)
Configuration:
  Machines: 1 (cost-optimized)
  CPU: 1 shared core
  Memory: 256 MB
  Auto-stop: Yes (on idle)
  Volume: Optional
Costs: ~$2-5/month

Features:
  - Rapid iteration
  - Debug logging
  - Health checks every 30s
  - Auto-scaling disabled
```

### Staging Environment

```yaml
App Name: caps-idp-example-staging
Region: iad
Configuration:
  Machines: 2 (load testing capable)
  CPU: 1 core
  Memory: 512 MB per machine
  Auto-stop: No
  Volume: 20 GB (data persistence)
Costs: ~$10-15/month

Features:
  - Production-like setup
  - Health checks every 30s
  - Basic autoscaling (0-4 machines)
  - Persistent storage for testing
```

### Production Environment

```yaml
App Name: caps-idp-example-prod
Region: iad (+ optional: ord, lax, syd)
Configuration:
  Machines: 3+ (HA setup)
  CPU: 2 cores (dedicated)
  Memory: 1 GB per machine
  Auto-stop: No (24/7)
  Volume: 50 GB (backups enabled)
  Domain: example.com (custom)
Costs: ~$50-75/month (single region)

Features:
  - High availability (3 machines minimum)
  - TLS with custom domain
  - Dedicated CPU for performance
  - Health checks with grace period
  - Auto-scaling (3-10 machines)
  - Scheduled scaling (peak hours)
  - Monitoring and alerts
```

## Scaling Strategies

### Vertical Scaling (CPU/Memory)

- **Development** → **Staging**: 256MB → 512MB
- **Staging** → **Production**: 1CPU → 2CPU, 512MB → 1GB

### Horizontal Scaling (Machine Count)

```
Traffic Level      Dev    Staging    Production
────────────────────────────────────────────
Very Low           1      1          2
Low               1      1-2        2-3
Normal            1      2          3-5
High              1-2    3-4        5-8
Peak              2-3    4-5        8-10
```

### Auto-Scaling (Future)

```yaml
# fly.toml configuration
[services]
  processes = ["app"]
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  
  # Optional: scheduled scaling
  [[services.checks]]
    type = "http"
    grace_period = "30s"
    interval = "15s"
```

## High Availability Design

### Multi-Region Deployment

For global redundancy:

```
Fly.io Global
├── IAD (Primary)
│   ├── caps-idp-example-prod [3 machines]
│   └── Failover: Active
├── ORD (Chicago - Secondary)
│   ├── caps-idp-example-prod [2 machines]
│   └── Failover: Standby
└── LX (Los Angeles - Tertiary)
    ├── caps-idp-example-prod [1 machine]
    └── Failover: Last resort
```

DNS Configuration:
```
example.com → Fly.io Load Balancer
             ├─ 30% → IAD
             ├─ 50% → ORD
             └─ 20% → LAX
```

## Disaster Recovery

### Backup Strategy

```
Application Code:
├── Git repository (GitHub) - Primary backup
├── Release tags (GitHub Releases)
└── Container images (GHCR)

Data:
├── Persistent volumes - Daily snapshots
├── Database backups - Every 6 hours
└── Point-in-time restore - 7 days

Configuration:
├── Terraform state - Version controlled
├── fly.toml - In Git
└── Environment variables - Secrets manager
```

### Recovery Time Objective (RTO)

| Failure | Recovery Time | Method |
|---------|---------------|--------|
| Machine crash | 2-5 min | Auto-restart |
| App error | 5-10 min | Manual redeploy or rollback |
| Region failure | 30 sec | Failover to next region |
| Data loss | 24 hours | Restore from backup |

## Security Architecture

### Network Security

```
┌─────────────────────────────────────────┐
│         Fly.io Edge (DDoS protected)    │
│         • WAF rules                     │
│         • Rate limiting                 │
│         • Geographic blocking           │
└────────────────────┬────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   Fly.io VPC           │
        │  • Private networking  │
        │  • Service discovery   │
        │  • Encrypted tunnels   │
        └────────────────┬───────┘
                         │
                         ▼
        ┌────────────────────────┐
        │   Application Machines │
        │  • No public IP        │
        │  • Encrypted storage   │
        │  • Secrets management  │
        └────────────────────────┘
```

### Secrets Management

- **Fly.io Secrets**: Encrypted environment variables
- **GitHub Secrets**: CI/CD pipeline secrets
- **Terraform Variables**: Sensitive marked variables
- **Credentials**: Never hardcoded, always externalized

## Monitoring & Observability

### Built-in Fly.io Metrics

```
flyctl metrics -a caps-idp-example-prod

Metrics:
├── CPU usage (per machine)
├── Memory usage (per machine)
├── Network bandwidth
├── Request count
└── Error rate
```

### Application Health Checks

```
Endpoint: GET /health
Interval: 30 seconds
Timeout: 5 seconds
Grace Period: 30 seconds (new machines)
Healthy Response: 200 OK
```

### Logging

Logs available via:
```bash
flyctl logs -a caps-idp-example-prod --follow
```

Logs captured from:
- STDOUT
- STDERR
- System logs

## Cost Model

### Fixed Costs

| Component | Cost | Notes |
|-----------|------|-------|
| App (3 machines, prod) | $30/month | ~$10 per machine |
| Persistent volume (50GB) | $20/month | $0.40 per GB |
| Data transfer | ~$5/month | Varies by traffic |
| **Total** | **~$55/month** | Single region |

### Variable Costs

- Scaling: +$10 per additional machine
- Storage: +$0.40 per GB
- Data transfer: $0.02 per GB (outbound)

### Savings vs. Kubernetes

| Aspect | Kubernetes | Fly.io |
|--------|------------|--------|
| Base infrastructure | $100+/month | Included |
| Node management | Manual | Automatic |
| Networking | $30+/month | Included |
| Load balancing | $20+/month | Included |
| TLS certificates | $50+/month | Free |
| **Total** | **$200+/month** | **$55/month** |

## Migration from EKS

### Steps

1. **Prepare**: Test application on Fly.io locally
2. **Deploy**: Set up dev/staging/prod environments
3. **Verify**: Health checks and smoke tests pass
4. **DNS**: Point domain to Fly.io
5. **Monitor**: Watch metrics during traffic shift
6. **Decomission**: Remove old EKS infrastructure
7. **Archive**: Keep backups for 30 days

### Rollback Plan

If issues arise:
- Revert DNS to previous endpoint
- Scale down Fly.io (but keep running)
- Scale up EKS (if still available)

## Future Enhancements

- [ ] Multi-region deployment
- [ ] Database (PostgreSQL) on Fly.io
- [ ] Redis cache cluster
- [ ] Custom monitoring/alerting
- [ ] Performance optimization
- [ ] Advanced CI/CD features
