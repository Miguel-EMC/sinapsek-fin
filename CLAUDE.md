# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sinapsek Fin is a financial management platform: Flutter mobile app + Angular 21 admin dashboard, backed by a FastAPI API with AI-powered bank statement parsing (Google Gemini). Monorepo managed with Nx.

## Common Commands

### Local Dev
```bash
make dev                      # Start full local stack (docker-compose: pg:5442, redis:6379, api:8000)
npx nx run api:serve          # FastAPI with hot reload only
npx nx run admin:serve        # Angular dev server only
cd apps/mobile && flutter run # Flutter app
```

### Testing
```bash
make test                     # All projects via Nx
cd services/api && pytest     # API unit tests
cd apps/admin && npm test     # Vitest (Angular)
cd apps/mobile && flutter test
```

### Single Test
```bash
cd services/api && pytest tests/path/test_file.py::test_function -v
cd apps/admin && npx vitest run src/path/file.spec.ts
```

### Linting
```bash
cd services/api && ruff check .
cd apps/admin && npm run lint
cd apps/mobile && flutter analyze
```

### Database Migrations
```bash
make migrate                  # alembic upgrade head
# Create new migration:
cd services/api && alembic revision --autogenerate -m "description"
```

### Deployment
```bash
make deploy-demo   # Triggers GitHub Actions on demo branch
make deploy-prod   # Triggers GitHub Actions on main branch

# Local Terraform (use tfbackend files)
cd infra
terraform init -backend-config=demo.tfbackend
terraform plan -var="environment=demo" -var="project_id=sinapsek-fin" -var="region=us-central1" -var="api_image_url=<IMAGE_URL>"
terraform apply ...
```

## Architecture

### Monorepo Structure
- `apps/admin/` — Angular 21 SPA (TypeScript, Vitest)
- `apps/mobile/` — Flutter app (clean architecture: `lib/core`, `lib/features/{domain}/{data,domain,presentation}`)
- `services/api/` — FastAPI backend (Python 3.11)
- `infra/` — Terraform for GCP (modules: networking, iam, cloud_sql, storage, cloud_run)

### API Structure (`services/api/`)
```
app/
├── api/v1/endpoints/   # auth.py, profile.py, transactions.py
├── api/deps.py         # DB session + JWT current_user injection
├── core/
│   ├── db/             # SQLAlchemy base + session
│   ├── security.py     # JWT (python-jose) + bcrypt
│   └── parser.py       # PDF/Excel → Gemini → structured transactions
├── models/             # SQLAlchemy ORM (User, FinancialProfile, Transaction)
├── schemas/            # Pydantic schemas
└── main.py             # App factory, router registration
alembic/                # Migrations
```

### Key Data Models
- **User**: UUID PK, email, hashed_password → 1:1 FinancialProfile, 1:many Transaction
- **FinancialProfile**: JSONB fields (debts, goals, habits), income
- **Transaction**: date, amount, description, category (AI-assigned), source_file, raw_data

### Transaction Upload Flow
`POST /api/v1/transactions/upload` → JWT auth → parse PDF/Excel → Gemini API (structured JSON extraction) → validate → bulk insert Transactions

### GCP Deployment
- Cloud Run (min 0, max 10 instances) per environment
- Cloud SQL PostgreSQL 15 on private VPC (socket connection, not TCP)
- Secrets via Cloud Secret Manager: `db-url-{env}`, `app-secret-key-{env}`
- Prod: `api.sinapsek-fin.migueldev11.com` (main branch)
- Demo: `api.demo.sinapsek-fin.migueldev11.com` (demo branch)

## Conventions

### Python
- Type hints everywhere, async endpoints
- Pydantic schemas for request/response validation
- Dependency injection via FastAPI `Depends()`
- 4-space indent, ruff for linting

### TypeScript (Angular)
- Prettier: 100 char width, single quotes
- `PascalCase` classes, `snake_case` files

### Flutter
- Clean architecture per feature: `data/` (repos, sources), `domain/` (entities, use cases), `presentation/` (widgets, blocs)
- 4-space indent

### Commits
Conventional Commits: `feat:`, `fix:`, `chore:`, `security:`. Flag migration or env-var changes explicitly in PR notes.

## Environment Variables

Set in docker-compose for local dev. In production, injected via GCP Secret Manager. Key vars:
- `DATABASE_URL` — PostgreSQL connection string
- `SECRET_KEY` — JWT signing key
- `GEMINI_API_KEY` — Google Gemini for transaction parsing
- `REDIS_URL` — Cache connection
