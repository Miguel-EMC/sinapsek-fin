# Repository Guidelines

## Project Structure & Module Organization
This repository is an Nx-managed monorepo. Use `apps/` for frontends, `services/` for backend services, and `infra/` for Terraform.

- `apps/admin`: Angular admin UI (`src/app`, `public/`)
- `apps/mobile`: Flutter app (`lib/core`, `lib/features`, `test/`)
- `services/api`: FastAPI service (`app/api`, `app/core`, `app/models`, `app/schemas`, `alembic/`)
- `infra`: Terraform root plus reusable modules under `infra/modules/`

Keep new code inside the existing feature boundaries. For Flutter, prefer `features/<domain>/{data,domain,presentation}`. For FastAPI, keep routes in `app/api/v1/endpoints` and shared configuration in `app/core`.

## Build, Test, and Development Commands
- `npm install`: install root Nx tooling
- `make dev`: start the local stack with `docker-compose`
- `make build`: run Nx build targets across projects
- `make test`: run Nx test targets across projects
- `npx nx run api:serve`: start FastAPI with reload from `services/api`
- `npx nx run api:migrate`: apply Alembic migrations
- `npx nx run admin:serve`: start the Angular dev server
- `npx nx run mobile:test`: run Flutter tests

If you work inside a project directly, use its native commands too: `npm test` in `apps/admin`, `flutter test` in `apps/mobile`, and `pytest` in `services/api`.

## Coding Style & Naming Conventions
Use 4 spaces in Python and Dart; keep TypeScript formatting consistent with Prettier (`printWidth: 100`, single quotes in `apps/admin/package.json`). Use `snake_case` for Python and Dart file names, `PascalCase` for Flutter widgets/classes, and `PascalCase` class names with Angular’s standard `.ts/.html/.css` file grouping. Keep imports local and feature-oriented; avoid cross-feature shortcuts.

## Testing Guidelines
Admin tests use Vitest via `npm test` and live beside source as `*.spec.ts`. Mobile tests use `flutter_test`; keep widget and feature tests under `apps/mobile/test` or near the feature when appropriate. API tests run with `pytest`; add new tests under `services/api/tests` and cover endpoints, auth, and DB-facing logic for any changed behavior.

## Commit & Pull Request Guidelines
Recent history follows Conventional Commits: `feat:`, `fix:`, `chore:`, `security:`. Keep commit subjects imperative and scoped to one change. PRs should include a short summary, impacted areas (`admin`, `mobile`, `api`, `infra`), linked issues, and screenshots for UI work. Mention migration or environment-variable changes explicitly.

## Security & Configuration Tips
Do not commit secrets. Backend settings and tokens belong in environment variables; Terraform state and cloud credentials should stay outside the repo. When changing auth, database config, or AI integrations, update both runtime config and deployment files together.
