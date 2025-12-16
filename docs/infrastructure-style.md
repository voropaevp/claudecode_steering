# Infrastructure & DevOps Style Guide

**Version:** 1.0
**Last Updated:** 2025-12-16

This document defines standards for infrastructure as code (Terraform), CI/CD pipelines, deployment practices, and operational procedures.

---

## Table of Contents

### Part I: Infrastructure as Code (Terraform)
1. [Terraform Principles](#1-terraform-principles)
2. [File Organization](#2-file-organization)
3. [Naming Conventions](#3-naming-conventions)
4. [Module Design](#4-module-design)
5. [State Management](#5-state-management)
6. [Security Practices](#6-security-practices)

### Part II: CI/CD & Deployment
7. [Pipeline Architecture](#7-pipeline-architecture)
8. [Deployment Strategies](#8-deployment-strategies)
9. [Environment Management](#9-environment-management)

### Part III: Operations
10. [Monitoring & Observability](#10-monitoring--observability)
11. [Incident Response](#11-incident-response)
12. [Disaster Recovery](#12-disaster-recovery)

---

# Part I: Infrastructure as Code (Terraform)

## 1. Terraform Principles

### DRY and Modularity

**ALWAYS use modules for reusable infrastructure components**

```hcl
# ❌ BAD - Duplicated configuration
resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_vpc" "staging" {
  cidr_block = "10.1.0.0/16"
  enable_dns_hostnames = true
}

# ✅ GOOD - Reusable module
module "vpc_prod" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  environment = "prod"
}

module "vpc_staging" {
  source = "./modules/vpc"
  cidr_block = "10.1.0.0/16"
  environment = "staging"
}
```

### Immutable Infrastructure

- **NEVER** modify resources in place
- **ALWAYS** prefer `create_before_destroy`
- **USE** blue-green or canary deployments

```hcl
resource "aws_launch_template" "app" {
  name_prefix = "app-"

  lifecycle {
    create_before_destroy = true
  }
}
```

### Explicit Over Implicit

**ALWAYS specify versions**

```hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

---

## 2. File Organization

### Standard Module Structure

```
infrastructure/
├── terraform/
│   ├── environments/
│   │   ├── prod/
│   │   ├── staging/
│   │   └── dev/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── compute/
│   │   └── database/
│   └── global/
├── kubernetes/
│   ├── base/
│   └── overlays/
└── scripts/
```

### Standard Files

- `main.tf` - Primary resources
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `versions.tf` - Version constraints
- `backend.tf` - State backend
- `locals.tf` - Local values
- `data.tf` - Data sources

---

## 3. Naming Conventions

### Resources

**Format:** `<resource_type>_<descriptive_name>`

```hcl
# ✅ GOOD
resource "aws_security_group" "web_server" {
  name = "${var.environment}-web-sg"
}

# ❌ BAD
resource "aws_security_group" "sg1" {
  name = "sg1"
}
```

### Variables

**Use snake_case**

```hcl
# ✅ GOOD
variable "vpc_cidr_block" {
  type = string
}

# ❌ BAD
variable "vpcCidrBlock" {  # camelCase
  type = string
}
```

### Tags

**ALWAYS include:**
- `Environment` - prod, staging, dev
- `ManagedBy` - terraform
- `Project` - project name
- `Owner` - team name

```hcl
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
    Owner       = var.team_name
  }
}
```

---

## 4. Module Design

### Input Validation

**ALWAYS validate inputs**

```hcl
variable "environment" {
  type = string

  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "Environment must be prod, staging, or dev"
  }
}
```

### Strong Typing

```hcl
# ✅ GOOD
variable "subnet_config" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    public            = bool
  }))
}

# ❌ BAD
variable "subnet_config" {
  type = any  # Too permissive
}
```

### Documented Outputs

```hcl
output "vpc_id" {
  description = "VPC ID for use in other modules"
  value       = aws_vpc.main.id
}
```

---

## 5. State Management

### Remote State with Locking

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Separate State Files

**USE separate states for:**
- Different environments
- Different infrastructure layers
- Independent lifecycle components

---

## 6. Security Practices

### Never Hardcode Secrets

```hcl
# ❌ BAD
resource "aws_db_instance" "main" {
  password = "SuperSecret123!"
}

# ✅ GOOD
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/database/password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
}
```

### Least Privilege IAM

```hcl
# ✅ GOOD
data "aws_iam_policy_document" "s3_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.data.arn,
      "${aws_s3_bucket.data.arn}/*"
    ]
  }
}
```

### Security Scanning

**ALWAYS run before deployment:**

```bash
# Format and validate
terraform fmt -check -recursive
terraform validate

# Security scanning
tfsec .
checkov -d .
```

---

# Part II: CI/CD & Deployment

## 7. Pipeline Architecture

### Pipeline Stages

**EVERY pipeline MUST have these stages:**

1. **Validate** - Syntax, linting, formatting
2. **Test** - Unit tests, integration tests
3. **Build** - Compile, package, containerize
4. **Security Scan** - SAST, dependency scanning, container scanning
5. **Deploy** - To target environment
6. **Verify** - Smoke tests, health checks

### GitHub Actions Example

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint
        run: |
          ruff check .
          mypy .

      - name: Format check
        run: ruff format --check .

  test:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: |
          pytest tests/ --cov --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  security:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dependency scan
        run: |
          pip install safety
          safety check

      - name: SAST scan
        uses: github/codeql-action/analyze@v2

  build:
    needs: security
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: |
          docker build -t myapp:${{ github.sha }} .

      - name: Scan container
        run: |
          trivy image myapp:${{ github.sha }}

      - name: Push to registry
        run: |
          docker push myregistry/myapp:${{ github.sha }}

  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - name: Deploy to staging
        run: |
          kubectl set image deployment/myapp \
            myapp=myregistry/myapp:${{ github.sha }} \
            --namespace=staging

      - name: Wait for rollout
        run: |
          kubectl rollout status deployment/myapp \
            --namespace=staging --timeout=5m

  deploy-prod:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    environment: production
    steps:
      - name: Deploy to production
        run: |
          # Blue-green or canary deployment
          kubectl apply -f k8s/prod/
```

### Pipeline Rules

**NEVER:**
- Deploy without tests passing
- Skip security scans
- Deploy without approval for production
- Hardcode secrets in pipeline files

**ALWAYS:**
- Use environment-specific variables
- Require manual approval for prod
- Run smoke tests after deployment
- Rollback automatically on failure

---

## 8. Deployment Strategies

### Blue-Green Deployment

**USE for zero-downtime deployments**

```bash
# Deploy green environment
kubectl apply -f k8s/green/deployment.yaml

# Wait for green to be healthy
kubectl wait --for=condition=available deployment/myapp-green

# Switch traffic
kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'

# Verify
curl https://myapp.example.com/health

# Cleanup blue (after verification period)
kubectl delete deployment myapp-blue
```

### Canary Deployment

**USE for gradual rollout**

```yaml
# Canary with 10% traffic
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
    # No version selector - both stable and canary
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-stable
spec:
  replicas: 9  # 90% traffic
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-canary
spec:
  replicas: 1  # 10% traffic
```

### Rolling Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
spec:
  replicas: 10
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1  # At most 1 pod down
      maxSurge: 2        # At most 2 extra pods
```

---

## 9. Environment Management

### Environment Parity

**Keep environments as similar as possible**

```
prod/
├── infrastructure/  # Same as staging
├── config/          # Environment-specific values
└── secrets/         # Environment-specific secrets

staging/
├── infrastructure/  # Same as prod
├── config/
└── secrets/
```

### Configuration Management

**USE environment variables, NEVER hardcode**

```yaml
# ❌ BAD - Hardcoded
apiVersion: v1
kind: Deployment
spec:
  containers:
  - name: app
    env:
    - name: DATABASE_URL
      value: "postgres://prod-db:5432/mydb"

# ✅ GOOD - From ConfigMap/Secret
apiVersion: v1
kind: Deployment
spec:
  containers:
  - name: app
    envFrom:
    - configMapRef:
        name: app-config
    - secretRef:
        name: app-secrets
```

### Secrets Management

**NEVER commit secrets to git**

```bash
# ✅ GOOD - Use secret management tools
# AWS Secrets Manager
aws secretsmanager create-secret \
  --name prod/database/password \
  --secret-string "$(openssl rand -base64 32)"

# Kubernetes sealed-secrets
kubeseal --format yaml < secret.yaml > sealed-secret.yaml
git add sealed-secret.yaml  # Safe to commit

# HashiCorp Vault
vault kv put secret/prod/database password="$(openssl rand -base64 32)"
```

---

# Part III: Operations

## 10. Monitoring & Observability

### The Three Pillars

**ALWAYS implement:**
1. **Metrics** - Quantitative measurements
2. **Logs** - Event records
3. **Traces** - Request flows

### Metrics

**USE Prometheus/CloudWatch for metrics**

```python
# Application metrics
from prometheus_client import Counter, Histogram, Gauge

# Business metrics
requests_total = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

# Performance metrics
request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# Resource metrics
active_connections = Gauge(
    'active_connections',
    'Number of active connections'
)
```

### Logging

**USE structured logging**

```python
import structlog

logger = structlog.get_logger()

# ✅ GOOD - Structured logs
logger.info(
    "user_login_attempt",
    user_id=user_id,
    ip_address=request.remote_addr,
    success=True,
    duration_ms=duration
)

# ❌ BAD - Unstructured logs
logger.info(f"User {user_id} logged in from {ip}")
```

### Tracing

**USE distributed tracing for microservices**

```python
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor

tracer = trace.get_tracer(__name__)

@app.get("/api/users/{user_id}")
async def get_user(user_id: str):
    with tracer.start_as_current_span("get_user") as span:
        span.set_attribute("user.id", user_id)

        # Automatically traces downstream calls
        user = await database.get_user(user_id)

        return user
```

### Dashboards

**CREATE dashboards for:**
- System health (CPU, memory, disk, network)
- Application metrics (requests, errors, latency)
- Business metrics (users, transactions, revenue)

```yaml
# Grafana dashboard as code
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard
data:
  application.json: |
    {
      "title": "Application Metrics",
      "panels": [
        {
          "title": "Request Rate",
          "targets": [{"expr": "rate(http_requests_total[5m])"}]
        },
        {
          "title": "Error Rate",
          "targets": [{"expr": "rate(http_requests_total{status=~'5..'}[5m])"}]
        }
      ]
    }
```

---

## 11. Incident Response

### Incident Severity Levels

| Severity | Description | Response Time | Examples |
|----------|-------------|---------------|----------|
| P0 | Critical outage | Immediate | Complete service down |
| P1 | Major degradation | < 15 min | Core feature broken |
| P2 | Minor degradation | < 1 hour | Non-critical feature broken |
| P3 | Low impact | < 1 day | Cosmetic issues |

### Incident Response Workflow

1. **Detect** - Monitoring alerts trigger
2. **Acknowledge** - On-call engineer acknowledges
3. **Communicate** - Update status page
4. **Diagnose** - Identify root cause
5. **Mitigate** - Restore service (rollback, scale, etc.)
6. **Resolve** - Fix root cause
7. **Postmortem** - Document lessons learned

### On-Call Runbooks

**CREATE runbooks for common issues**

```markdown
# Runbook: High CPU Usage

## Symptoms
- CloudWatch alarm: CPU > 80%
- Application slow response times
- Increased error rates

## Diagnosis
1. Check current CPU usage:
   ```bash
   kubectl top pods -n production
   ```

2. Check recent deployments:
   ```bash
   kubectl rollout history deployment/myapp
   ```

3. Check logs for errors:
   ```bash
   kubectl logs -n production deployment/myapp --tail=100
   ```

## Mitigation
1. Scale up replicas:
   ```bash
   kubectl scale deployment/myapp --replicas=10
   ```

2. If caused by recent deployment, rollback:
   ```bash
   kubectl rollout undo deployment/myapp
   ```

## Prevention
- Review application performance
- Optimize slow queries
- Add caching layer
```

---

## 12. Disaster Recovery

### Backup Strategy

**3-2-1 Rule:**
- **3** copies of data
- **2** different storage types
- **1** offsite backup

```bash
# Database backups
# Daily automated backups
aws rds create-db-snapshot \
  --db-instance-identifier prod-db \
  --db-snapshot-identifier prod-db-$(date +%Y%m%d)

# Point-in-time recovery enabled
aws rds modify-db-instance \
  --db-instance-identifier prod-db \
  --backup-retention-period 30
```

### Recovery Time Objective (RTO)

**Define RTO for each component:**

| Component | RTO | Strategy |
|-----------|-----|----------|
| Database | < 15 min | Multi-AZ with automated failover |
| Application | < 5 min | Auto-scaling, health checks |
| Static assets | < 1 min | CloudFront CDN |

### Recovery Point Objective (RPO)

**Define maximum data loss acceptable:**

| Component | RPO | Strategy |
|-----------|-----|----------|
| Database | < 5 min | Continuous replication |
| User uploads | < 1 hour | Hourly S3 syncs |
| Logs | < 1 min | Real-time streaming |

### Disaster Recovery Testing

**TEST DR procedures quarterly**

```bash
# DR drill script
#!/bin/bash
set -e

echo "Starting DR drill..."

# 1. Failover database to secondary region
aws rds failover-db-cluster --db-cluster-identifier prod-cluster

# 2. Update DNS to secondary region
aws route53 change-resource-record-sets \
  --hosted-zone-id Z123456 \
  --change-batch file://dr-dns-change.json

# 3. Verify application health
curl -f https://app.example.com/health || exit 1

# 4. Verify data integrity
./scripts/verify-data-integrity.sh

echo "DR drill completed successfully"
```

---

## Checklist for Infrastructure Changes

Before deploying infrastructure changes:

- [ ] Terraform formatted and validated
- [ ] Security scanning (tfsec, checkov) passed
- [ ] State backend configured
- [ ] Plan reviewed and approved
- [ ] Changes applied in staging first
- [ ] Monitoring and alerts configured
- [ ] Rollback plan documented
- [ ] On-call runbook updated
- [ ] Backup verified
- [ ] DR procedure tested

---

## References

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [12-Factor App](https://12factor.net/)
- [SRE Book](https://sre.google/sre-book/table-of-contents/)
- [The Phoenix Project](https://itrevolution.com/product/the-phoenix-project/)
