# 🏗️ Infrastructure Documentation

This document describes all AWS resources used by Contextual Space and how they're managed with Terraform.

---

## AWS Resources Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AWS Account: 871981698300                          │
│                              Region: us-east-1                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│     ECR         │  │   App Runner    │  │    DynamoDB     │  │   CloudFront    │
│                 │  │                 │  │                 │  │                 │
│ contextual-     │  │ contextual-     │  │ contextual-     │  │ E2V9NWK252L441  │
│ space-backend   │──│ space-backend-  │──│ space-textboxes │  │                 │
│                 │  │ dev             │  │ -dev            │  │       │         │
└─────────────────┘  └─────────────────┘  └─────────────────┘  └───────┼─────────┘
                                                                       │
                                                               ┌───────▼─────────┐
                                                               │       S3        │
                                                               │                 │
                                                               │ contextual-     │
                                                               │ space-frontend- │
                                                               │ dev-871981698300│
                                                               └─────────────────┘
```

---

## Resource Details

### ECR (Elastic Container Registry)

**Repository**: `contextual-space-backend`

| Property | Value |
|----------|-------|
| URI | `871981698300.dkr.ecr.us-east-1.amazonaws.com/contextual-space-backend` |
| Image scanning | Enabled |
| Lifecycle policy | Keep last 10 images |

**Terraform**: `infrastructure/terraform/ecr.tf`

```hcl
resource "aws_ecr_repository" "backend" {
  name                 = "contextual-space-backend"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
}
```

---

### App Runner

**Service**: `contextual-space-backend-dev`

| Property | Value |
|----------|-------|
| URL | `https://uj6er332a8.us-east-1.awsapprunner.com` |
| CPU | 0.25 vCPU |
| Memory | 512 MB |
| Min instances | 1 (always warm) |
| Max instances | 5 |
| Port | 3001 |
| Auto-deploy | Yes (on ECR push) |

**Environment Variables**:
| Variable | Value |
|----------|-------|
| `NODE_ENV` | `development` |
| `PORT` | `3001` |
| `DYNAMODB_TABLE_NAME` | `contextual-space-textboxes-dev` |
| `AWS_REGION` | `us-east-1` |
| `FRONTEND_URL` | `https://d3q2b06rnr38b0.cloudfront.net` |
| `USE_DYNAMODB` | `true` |

**Terraform**: `infrastructure/terraform/apprunner.tf`

---

### DynamoDB

**Table**: `contextual-space-textboxes-dev`

| Property | Value |
|----------|-------|
| Partition Key | `type` (String) |
| Sort Key | `id` (String) |
| Billing Mode | On-demand (PAY_PER_REQUEST) |
| Encryption | AWS-owned key |

**Global Secondary Index**:
| Index | Partition Key | Projection |
|-------|---------------|------------|
| `UserIdIndex` | `userId` | ALL |

**Terraform**: `infrastructure/terraform/dynamodb.tf`

```hcl
resource "aws_dynamodb_table" "textboxes" {
  name         = "contextual-space-textboxes-dev"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "type"
  range_key    = "id"
  
  attribute {
    name = "type"
    type = "S"
  }
  
  attribute {
    name = "id"
    type = "S"
  }
  
  attribute {
    name = "userId"
    type = "S"
  }
  
  global_secondary_index {
    name            = "UserIdIndex"
    hash_key        = "userId"
    projection_type = "ALL"
  }
}
```

---

### S3 Bucket

**Bucket**: `contextual-space-frontend-dev-871981698300`

| Property | Value |
|----------|-------|
| Region | us-east-1 |
| Access | Private (CloudFront OAC only) |
| Versioning | Enabled |
| Public access | Blocked |

**Terraform**: `infrastructure/terraform/s3_cloudfront.tf`

---

### CloudFront Distribution

**Distribution ID**: `E2V9NWK252L441`

| Property | Value |
|----------|-------|
| Domain | `d3q2b06rnr38b0.cloudfront.net` |
| Origin | S3 bucket |
| Origin Access | OAC (Origin Access Control) |
| Price Class | PriceClass_100 (US, Canada, Europe) |
| Default TTL | 86400 (24 hours) |
| Viewer Protocol | Redirect HTTP to HTTPS |
| Compress | Yes |

**Cache Behavior**:
- `*.html` - No cache (always fresh)
- `assets/*` - Long cache (immutable)
- Default - Standard caching

**Terraform**: `infrastructure/terraform/s3_cloudfront.tf`

---

### IAM Roles & Policies

#### App Runner ECR Access Role
**Name**: `contextual-space-apprunner-ecr-access`

Allows App Runner to pull images from ECR.

```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:BatchCheckLayerAvailability"
  ],
  "Resource": "arn:aws:ecr:us-east-1:871981698300:repository/contextual-space-backend"
}
```

#### App Runner Instance Role
**Name**: `contextual-space-apprunner-instance`

Allows the backend container to access DynamoDB.

```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:PutItem",
    "dynamodb:GetItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:Query",
    "dynamodb:Scan"
  ],
  "Resource": [
    "arn:aws:dynamodb:us-east-1:871981698300:table/contextual-space-textboxes-dev",
    "arn:aws:dynamodb:us-east-1:871981698300:table/contextual-space-textboxes-dev/index/*"
  ]
}
```

#### GitHub Actions Role
**Name**: `contextual-space-github-actions`

Allows GitHub Actions to deploy via OIDC (no access keys!).

**Trust Policy**:
```json
{
  "Effect": "Allow",
  "Principal": {
    "Federated": "arn:aws:iam::871981698300:oidc-provider/token.actions.githubusercontent.com"
  },
  "Action": "sts:AssumeRoleWithWebIdentity",
  "Condition": {
    "StringEquals": {
      "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
    },
    "StringLike": {
      "token.actions.githubusercontent.com:sub": "repo:NikolaGospodjinacki/Contextual_Space:*"
    }
  }
}
```

**Permissions**:
- ECR: Push/pull images
- S3: Sync frontend files
- CloudFront: Create invalidations
- App Runner: Describe services

**Terraform**: `infrastructure/terraform/github_oidc.tf`

---

## Terraform State

**State Storage**: Local file (`terraform.tfstate`)

> ⚠️ For production, consider using S3 backend with DynamoDB locking.

### Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | Provider configuration, tags |
| `variables.tf` | Input variable definitions |
| `outputs.tf` | Output values |
| `ecr.tf` | ECR repository |
| `apprunner.tf` | App Runner service + auto-scaling |
| `dynamodb.tf` | DynamoDB table |
| `s3_cloudfront.tf` | S3 bucket + CloudFront distribution |
| `iam.tf` | IAM roles for App Runner |
| `github_oidc.tf` | OIDC provider + GitHub Actions role |

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region | `us-east-1` |
| `environment` | Environment name | `dev` |
| `app_name` | Application name | `contextual-space` |
| `github_repo` | GitHub repository | `NikolaGospodjinacki/Contextual_Space` |

### Usage

```bash
cd infrastructure/terraform

# Initialize Terraform
terraform init

# Preview changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars

# Destroy everything (careful!)
terraform destroy -var-file=terraform.tfvars
```

---

## Cost Estimation

| Resource | Unit | Price | Est. Monthly |
|----------|------|-------|--------------|
| **App Runner** | | | |
| - Provisioned (1 instance) | Per hour | $0.007/vCPU-hr + $0.0009/GB-hr | $5-8 |
| - Active (requests) | Per request | $0.000001 | <$1 |
| **DynamoDB** | | | |
| - Write | Per million | $1.25 | <$1 |
| - Read | Per million | $0.25 | <$1 |
| - Storage | Per GB | $0.25 | <$1 |
| **S3** | | | |
| - Storage | Per GB | $0.023 | <$1 |
| - Requests | Per 1000 | $0.0004 | <$1 |
| **CloudFront** | | | |
| - Data transfer | Per GB | $0.085 | $0-2 |
| - Requests | Per 10,000 | $0.01 | <$1 |
| **ECR** | | | |
| - Storage | Per GB | $0.10 | <$1 |
| | | **Total** | **~$7-15** |

---

## Networking

### Endpoints

| Service | Endpoint | Protocol |
|---------|----------|----------|
| Frontend | `https://d3q2b06rnr38b0.cloudfront.net` | HTTPS |
| Backend | `https://uj6er332a8.us-east-1.awsapprunner.com` | HTTPS/WSS |
| Health | `https://uj6er332a8.us-east-1.awsapprunner.com/health` | HTTPS |

### CORS Configuration

Backend allows requests from:
- `http://localhost:5173` (local dev)
- `http://localhost:3000` (local dev)
- `https://d3q2b06rnr38b0.cloudfront.net` (production)

---

## Backups & Recovery

| Resource | Backup Strategy |
|----------|-----------------|
| DynamoDB | Point-in-time recovery (not enabled by default) |
| S3 | Versioning enabled |
| ECR | Last 10 images retained |

### Enabling DynamoDB Backup

```hcl
resource "aws_dynamodb_table" "textboxes" {
  # ... existing config ...
  
  point_in_time_recovery {
    enabled = true
  }
}
```

---

## Monitoring

### CloudWatch Logs

| Log Group | Source |
|-----------|--------|
| `/aws/apprunner/contextual-space-backend-dev/.../application` | Backend stdout/stderr |

### CloudWatch Metrics

| Metric | Service |
|--------|---------|
| `RequestCount` | App Runner |
| `Latency` | App Runner |
| `ActiveInstances` | App Runner |
| `ConsumedReadCapacityUnits` | DynamoDB |
| `ConsumedWriteCapacityUnits` | DynamoDB |
| `Requests` | CloudFront |
| `BytesDownloaded` | CloudFront |

---

## Security Checklist

- [x] S3 bucket is private
- [x] CloudFront uses HTTPS only
- [x] No AWS credentials in GitHub (OIDC)
- [x] IAM follows least privilege
- [x] ECR image scanning enabled
- [ ] WAF not configured (consider for production)
- [ ] DynamoDB encryption with CMK (uses AWS-owned key)
- [ ] VPC endpoints not configured (public endpoints used)

---

## Cleanup

To destroy all resources:

```bash
cd infrastructure/terraform
terraform destroy -var-file=terraform.tfvars
```

**Order of deletion** (Terraform handles this automatically):
1. App Runner service
2. ECR repository (images must be deleted first)
3. DynamoDB table
4. CloudFront distribution
5. S3 bucket (must be empty)
6. IAM roles and policies
7. OIDC provider
