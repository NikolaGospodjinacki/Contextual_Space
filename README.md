# Contextual Space

> Real-time collaborative text canvas - place notes anywhere, visible to everyone.

**Live Demo**: https://d3q2b06rnr38b0.cloudfront.net

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- Docker & Docker Compose (optional, for containerized development)

### Local Development

**Terminal 1 - Backend:**
```bash
cd backend
npm install
npm run dev
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm install
npm run dev
```

Open http://localhost:5173 in your browser.

### Docker Development

```bash
docker-compose up --build
```

Open http://localhost:5173 in your browser.

## 📁 Project Structure

```
├── backend/          # Express + Socket.IO server
├── frontend/         # React + Vite + Tailwind app
├── infrastructure/   # Terraform + GitHub Actions
│   └── terraform/    # AWS infrastructure as code
├── .github/
│   └── workflows/    # CI/CD pipelines
└── docker-compose.yml
```

## 🎯 Features

- [x] Real-time cursor sharing
- [x] Place text notes anywhere on infinite canvas
- [x] Edit and delete your own notes
- [x] See other users' notes in real-time
- [x] Reserved areas (hide content from others)
- [x] Search/filter by username or content
- [x] DynamoDB persistence
- [x] AWS deployment (App Runner, S3, CloudFront)
- [x] CI/CD with GitHub Actions
- [ ] Custom domain (optional)

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | React 18, TypeScript, Vite, Tailwind CSS |
| Backend | Node.js, Express, Socket.IO, TypeScript |
| Database | AWS DynamoDB |
| Infra | AWS App Runner, S3, CloudFront, ECR |
| CI/CD | GitHub Actions with OIDC authentication |
| IaC | Terraform |

## 🚀 CI/CD Pipeline

Deployments are automated via GitHub Actions:

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| `deploy-backend.yml` | Push to `backend/**` | Build Docker → Push to ECR → Deploy to App Runner |
| `deploy-frontend.yml` | Push to `frontend/**` | Build → Sync to S3 → Invalidate CloudFront |

### Setup

1. **Add GitHub Secret** (one-time):
   ```
   AWS_ROLE_ARN = arn:aws:iam::871981698300:role/contextual-space-github-actions
   ```

2. **Push to main** - deployments happen automatically!

### Manual Deployment

You can also trigger deployments manually from the Actions tab in GitHub.

## 🏗️ Infrastructure

All infrastructure is managed with Terraform in `infrastructure/terraform/`:

```bash
cd infrastructure/terraform
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### AWS Resources

- **ECR**: Container registry for backend images
- **App Runner**: Serverless container hosting (min 1 instance)
- **DynamoDB**: NoSQL database for textboxes
- **S3**: Static hosting for frontend
- **CloudFront**: CDN for frontend
- **IAM**: OIDC provider for GitHub Actions (no access keys!)

### Estimated Monthly Cost

| Resource | Cost |
|----------|------|
| App Runner (1 min instance) | ~$5-10 |
| DynamoDB (on-demand) | ~$0-1 |
| S3 + CloudFront | ~$0-2 |
| **Total** | **~$7-15/month** |

## 📝 License

MIT
