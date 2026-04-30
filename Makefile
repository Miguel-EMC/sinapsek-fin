.PHONY: dev build test migrate deploy deploy-demo deploy-prod

dev:
	docker-compose up

build:
	npx nx run-many -t build

test:
	npx nx run-many -t test

migrate:
	docker-compose run api alembic upgrade head

deploy:
	npx nx run-many -t deploy

deploy-demo:
	gh workflow run deploy-terraform.yml -f ref=demo

deploy-prod:
	gh workflow run deploy-terraform.yml -f ref=main