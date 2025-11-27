# 🤝 Contributing Guide

Welcome to Contextual Space! This guide will help you get started as a developer.

---

## 📋 Prerequisites

Before you begin, ensure you have:

- **Node.js 20+** - [Download](https://nodejs.org/)
- **Docker Desktop** - [Download](https://docker.com/products/docker-desktop)
- **Git** - [Download](https://git-scm.com/)
- **VS Code** (recommended) - [Download](https://code.visualstudio.com/)

Optional (for deployment):
- **AWS CLI** - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Terraform** - [Download](https://terraform.io/downloads)
- **GitHub CLI** - `winget install GitHub.cli`

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/NikolaGospodjinacki/Contextual_Space.git
cd Contextual_Space
```

### 2. Start Development Environment

**Option A: Separate Terminals (Recommended for debugging)**

```bash
# Terminal 1 - Backend
cd backend
npm install
npm run dev

# Terminal 2 - Frontend
cd frontend
npm install
npm run dev
```

**Option B: Docker Compose**

```bash
docker-compose up --build
```

### 3. Open the App

Navigate to [http://localhost:5173](http://localhost:5173)

---

## 📁 Project Structure

```
Contextual_Space/
├── backend/          # Node.js + Express + Socket.IO server
│   ├── src/
│   │   ├── index.ts          # Entry point
│   │   ├── socket/handlers.ts # WebSocket events
│   │   ├── store/            # Data layer
│   │   └── types/            # TypeScript types
│   └── package.json
│
├── frontend/         # React + Vite + Tailwind app
│   ├── src/
│   │   ├── App.tsx           # Root component
│   │   ├── components/       # UI components
│   │   ├── hooks/            # React hooks
│   │   ├── services/         # Socket.IO client
│   │   └── types/            # TypeScript types
│   └── package.json
│
├── infrastructure/   # Terraform IaC
│   └── terraform/
│
├── .github/workflows/# CI/CD pipelines
├── docs/             # Documentation
└── docker-compose.yml
```

---

## 🔧 Development Workflow

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**

3. **Test locally**
   ```bash
   # Backend tests
   cd backend && npm test
   
   # Frontend tests
   cd frontend && npm test
   ```

4. **Commit with clear message**
   ```bash
   git add -A
   git commit -m "feat: add your feature description"
   ```

5. **Push and create PR**
   ```bash
   git push origin feature/your-feature-name
   ```

### Commit Message Convention

We use [Conventional Commits](https://conventionalcommits.org/):

| Prefix | Usage |
|--------|-------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation only |
| `style:` | Formatting, no code change |
| `refactor:` | Code change without fix or feature |
| `perf:` | Performance improvement |
| `test:` | Adding tests |
| `chore:` | Build, CI, dependencies |

Example: `feat: add user authentication with Cognito`

---

## 🛠️ Tech Stack Details

### Frontend

| Tech | Purpose | Docs |
|------|---------|------|
| React 18 | UI framework | [react.dev](https://react.dev) |
| TypeScript | Type safety | [typescriptlang.org](https://typescriptlang.org) |
| Vite | Build tool | [vitejs.dev](https://vitejs.dev) |
| Tailwind CSS | Styling | [tailwindcss.com](https://tailwindcss.com) |
| Socket.IO Client | WebSocket | [socket.io/docs/v4/client-api](https://socket.io/docs/v4/client-api) |

### Backend

| Tech | Purpose | Docs |
|------|---------|------|
| Node.js | Runtime | [nodejs.org](https://nodejs.org) |
| Express | HTTP server | [expressjs.com](https://expressjs.com) |
| Socket.IO | WebSocket server | [socket.io/docs/v4/server-api](https://socket.io/docs/v4/server-api) |
| TypeScript | Type safety | [typescriptlang.org](https://typescriptlang.org) |
| AWS SDK v3 | DynamoDB client | [docs.aws.amazon.com/sdk-for-javascript](https://docs.aws.amazon.com/sdk-for-javascript) |

---

## 🗄️ Working with the Database

### Local Development (No DynamoDB)

By default, the backend uses in-memory storage when `USE_DYNAMODB` is not set:

```bash
# Backend runs with in-memory store
npm run dev
```

### Using DynamoDB Locally

1. **Start DynamoDB Local**
   ```bash
   docker run -p 8000:8000 amazon/dynamodb-local
   ```

2. **Set environment variables**
   ```bash
   export USE_DYNAMODB=true
   export DYNAMODB_ENDPOINT=http://localhost:8000
   export AWS_REGION=us-east-1
   export AWS_ACCESS_KEY_ID=local
   export AWS_SECRET_ACCESS_KEY=local
   ```

3. **Create the table**
   ```bash
   aws dynamodb create-table \
     --table-name contextual-space-textboxes-dev \
     --attribute-definitions \
       AttributeName=type,AttributeType=S \
       AttributeName=id,AttributeType=S \
     --key-schema \
       AttributeName=type,KeyType=HASH \
       AttributeName=id,KeyType=RANGE \
     --billing-mode PAY_PER_REQUEST \
     --endpoint-url http://localhost:8000
   ```

---

## 🧪 Testing

### Backend Tests

```bash
cd backend
npm test          # Run tests
npm run test:watch # Watch mode
```

### Frontend Tests

```bash
cd frontend
npm test          # Run tests
npm run test:watch # Watch mode
```

### Manual Testing

1. Open the app in two different browsers (or incognito)
2. Enter different usernames
3. Test features:
   - Create textboxes (click anywhere)
   - Edit textboxes (double-click)
   - Delete textboxes (click X)
   - Drag textboxes
   - Create reserved areas (draw a rectangle)
   - Toggle hidden areas
   - Search/filter notes
   - See other user's cursor

---

## 🚀 Deployment

### Automatic (CI/CD)

Just push to `main`:
- Changes in `backend/**` → Backend deploys
- Changes in `frontend/**` → Frontend deploys

### Manual Deployment

See [docs/INFRASTRUCTURE.md](INFRASTRUCTURE.md) for manual deployment commands.

---

## 🐛 Debugging

### Backend Logs

```bash
# Local
npm run dev  # Logs appear in terminal

# AWS
# Check CloudWatch Logs in AWS Console
# Log group: /aws/apprunner/contextual-space-backend-dev/.../application
```

### Frontend Debugging

1. Open Chrome DevTools (F12)
2. Check Console tab for errors
3. Check Network tab for WebSocket messages
4. React DevTools extension for component state

### Common Issues

| Issue | Solution |
|-------|----------|
| `CORS error` | Check backend `allowedOrigins` includes your frontend URL |
| `WebSocket connection failed` | Ensure backend is running, check BACKEND_URL |
| `Types not found` | Run `npm run build` in the package with type errors |
| `Module not found` | Run `npm install` |

---

## 📝 Code Style

### TypeScript

- Use explicit types (avoid `any`)
- Prefer interfaces over types for objects
- Use enums for fixed sets of values

### React

- Functional components only
- Use hooks for state and effects
- Keep components small and focused
- Extract reusable logic into custom hooks

### Tailwind CSS

- Use utility classes
- Extract repeated patterns to components
- Use `@apply` sparingly

---

## 🔒 Security Guidelines

1. **Never commit secrets** - Use environment variables
2. **Validate user input** - Especially on the backend
3. **Use HTTPS** - Always in production
4. **Sanitize content** - Prevent XSS attacks

---

## 📚 Additional Resources

- [Architecture Documentation](ARCHITECTURE.md)
- [Infrastructure Documentation](INFRASTRUCTURE.md)
- [Socket.IO Guide](https://socket.io/docs/v4/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [App Runner Documentation](https://docs.aws.amazon.com/apprunner/)

---

## 🆘 Getting Help

1. Check existing documentation
2. Search closed GitHub issues
3. Open a new issue with:
   - Clear description of the problem
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment details (OS, Node version, etc.)

---

## 🎉 Thank You!

Thank you for contributing to Contextual Space! Every contribution helps make this project better.
