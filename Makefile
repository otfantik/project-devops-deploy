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

deploy:
	ansible-playbook -i inventory.yml ansible/deploy.yml --ask-vault-pass -e "docker_image_version=$(VERSION)"

deploy-latest:
	ansible-playbook -i inventory.yml ansible/deploy.yml --ask-vault-pass -e "docker_image_version=latest"

ansible-deps:
	ansible-galaxy collection install -r requirements.yml

code-setup:
	ansible-galaxy collection install -r requirements.yml

setup:
	ansible-galaxy collection install -r requirements.yml