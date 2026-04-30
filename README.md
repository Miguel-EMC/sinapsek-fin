# Sinapsek Fin

Modern financial management monorepo.

## Stack

- **Mobile:** Flutter (Dart)
- **Admin:** Angular (TypeScript)
- **Backend:** FastAPI (Python 3.11)
- **Infra:** Terraform (GCP)
- **Orchestration:** Nx

## Project Structure

```
sinapsek_fin/
├── apps/
│   ├── admin/          # Angular admin UI
│   └── mobile/        # Flutter mobile app
├── services/
│   └── api/           # FastAPI backend
├── infra/              # Terraform IaC
└── .github/
    └── workflows/     # CI/CD pipelines
```

## Prerequisites

- Node.js 18+
- Python 3.11+
- Flutter 3.x
- Docker & Docker Compose
- npm or pnpm

## Quick Start

```bash
# Install dependencies
npm install

# Start local development stack
make dev

# Or manually start services
docker-compose up -d  # Starts: PostgreSQL, Redis, API
```

## Environment Variables

### API (services/api)

| Variable | Description | Default |
|----------|------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://user:password@localhost:5432/sinapsek` |
| `SECRET_KEY` | JWT signing key | `your-default-secret-key-for-dev` |
| `GEMINI_API_KEY` | Google Gemini API key | - |
| `CORS_ORIGINS` | Allowed CORS origins | `*` |

### Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f api

# Stop services
docker-compose down
```

## Development Commands

```bash
# Using Make
make dev      # Start local stack
make build    # Build all projects
make test     # Run all tests
make migrate # Run database migrations
make deploy  # Deploy all projects

# Using Nx
npx nx run-many -t build
npx nx run-many -t test

# Individual services
npx nx run api:serve       # Start FastAPI (port 8000)
npx nx run admin:serve     # Start Angular admin
npx nx run api:migrate    # Apply Alembic migrations
```

## Running Services Locally

### Backend (FastAPI)

```bash
cd services/api
uvicorn app.main:app --reload --port 8000
```

Or with Nx:

```bash
npx nx serve api
```

### Mobile (Flutter)

```bash
cd apps/mobile
flutter run
```

### Admin (Angular)

```bash
cd apps/admin
npm start
```

## Testing

```bash
# API (pytest)
cd services/api
pytest

# Mobile (Flutter)
cd apps/mobile
flutter test

# Admin (Vitest)
cd apps/admin
npm test
```

## Linting

```bash
# API (Ruff)
cd services/api
ruff check .

# Mobile (Flutter)
cd apps/mobile
flutter analyze

# Admin
cd apps/admin
npm run lint
```

## Deployment

### Environments

| Branch | Environment | URL |
|--------|-------------|-----|
| `main` | Production | prod.sinapsek.com |
| `demo` | Demo | demo.sinapsek.com |

### CI/CD Workflows

1. **CI Pipeline** (`.github/workflows/ci.yml`)
   - Runs on: PRs and non-main branches
   - Jobs: API lint, Mobile analyze, Mobile tests

2. **Deploy Pipeline** (`.github/workflows/deploy-terraform.yml`)
   - Runs on: `main`, `demo` branches
   - Jobs: Terraform init, Build API image, Terraform apply

### Manual Deployment

```bash
# Trigger from GitHub Actions or
gh workflow run deploy-terraform.yml -f ref=main
```

## Infrastructure

- **Cloud:** Google Cloud Platform (GCP)
- **Region:** us-central1
- **Compute:** Cloud Run
- **Database:** Cloud SQL (PostgreSQL)
- **Cache:** Cloud Memorystore (Redis)
- **Container Registry:** Artifact Registry
- **State Storage:** Cloud Storage (GCS)

## License

Private - All rights reserved