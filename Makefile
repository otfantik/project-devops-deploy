test:
	./gradlew test

start: run

run:
	./gradlew bootRun

update-gradle:
	./gradlew wrapper --gradle-version 9.2.1

update-deps:
	./gradlew refreshVersions

install:
	./gradlew dependencies

build:
	./gradlew build

lint:
	./gradlew spotlessCheck

lint-fix:
	./gradlew spotlessApply

.PHONY: build

docker-push:
	docker tag project-devops-deploy ghcr.io/otfantik/project-devops-deploy:latest
	docker push ghcr.io/otfantik/project-devops-deploy:latest