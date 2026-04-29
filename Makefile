.PHONY: dev build test deploy migrate

dev:
	docker-compose up

build:
	npx nx run-many -t build

test:
	npx nx run-many -t test

migrate:
	npx nx run api:migrate

deploy:
	npx nx run-many -t deploy
