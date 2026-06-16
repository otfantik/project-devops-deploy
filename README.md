[![CI/CD Pipeline](https://github.com/otfantik/project-devops-deploy/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/otfantik/project-devops-deploy/actions/workflows/ci-cd.yml)

# Project DevOps Deploy

Bulletin board service.

> **Fork policy**: this upstream repository is read-only. We do not review or merge pull requests and we do not accept infrastructure changes (Dockerfiles, Ansible roles, CI/CD workflows, etc.). To experiment or extend the project, fork it and work inside your own repository.

## Доступ к приложению

Приложение доступно по адресу:
- **HTTPS**: [https://hexletmazov.ddns.net](https://hexletmazov.ddns.net)
- **API**: [https://hexletmazov.ddns.net/api/bulletins](https://hexletmazov.ddns.net/api/bulletins)
- **Swagger UI**: [https://hexletmazov.ddns.net/swagger-ui/index.html](https://hexletmazov.ddns.net/swagger-ui/index.html)

HTTP автоматически редиректится на HTTPS.

## Project layout

- Backend (Spring Boot) lives in the repository root.
- Frontend (React Admin + Vite) is located in `frontend/`.
- Shared static assets for the backend are served from `src/main/resources/static` (populated by the frontend build when needed).
- Infrastructure as Code via Ansible roles in `ansible/`.

## Environment variables

Key variables are read directly by Spring Boot (see `src/main/resources/application.yml` and `application-prod.yml` for defaults). All sensitive values are stored in **Ansible Vault** and injected during deployment.

| Variable | Description | Default |
|----------|-------------|---------|
| `SPRING_PROFILES_ACTIVE` | Active Spring profile (`dev`, `prod`, etc.) | `dev` |
| `SPRING_DATASOURCE_URL` | JDBC URL for PostgreSQL in `prod` | `jdbc:postgresql://localhost:5432/bulletins` |
| `SPRING_DATASOURCE_USERNAME` | DB username | `bulletin_user` |
| `SPRING_DATASOURCE_PASSWORD` | DB password | **from Ansible Vault** |
| `STORAGE_S3_BUCKET` | Bucket name for bulletin images | `bulletins` |
| `STORAGE_S3_REGION` | Region for the S3-compatible storage | `us-east-1` |
| `STORAGE_S3_ENDPOINT` | Custom endpoint for MinIO | `http://minio:9000` |
| `STORAGE_S3_ACCESSKEY` | Access key ID | **from Ansible Vault** |
| `STORAGE_S3_SECRETKEY` | Secret key | **from Ansible Vault** |
| `STORAGE_S3_CDNURL` | Public CDN prefix for images | **from Ansible Vault** |
| `MANAGEMENT_SERVER_PORT` | Port for Spring Actuator endpoints | `9090` |
| `JAVA_OPTS` | Extra JVM parameters | empty |

All other variables supported by Spring Boot can be overridden the same way.

## Requirements

- JDK 21+
- Gradle 9.2.1
- Make
- NodeJS 20+
- Docker & Docker Compose
- Ansible (for deployment)

## Deployment

### Prerequisites

1. Install Ansible dependencies:
   ```bash
   make ansible-deps
Configure Ansible vault with secrets:


ansible-vault edit ansible/vault.yml
Required secrets in vault:


ghcr_username: your_github_username
ghcr_password: your_github_token
db_password: your_db_password
minio_root_user: minioadmin
minio_root_password: your_minio_password
minio_bucket: bulletins
domain_name: your.domain
certbot_email: your_email@example.com
Set up inventory:


cp inventory.example.yml inventory.yml
# Edit inventory.yml with your server details
Deploy


make deploy-latest
This will:

Pull the latest Docker image
Run database migrations
Start PostgreSQL, MinIO, and the application
Configure Nginx as reverse proxy with HTTPS
Local Development

backend

bash
make run

Frontend

cd frontend
make install
make start
Docker

Image

The application image is available at:


ghcr.io/otfantik/project-devops-deploy:latest
Run container


docker run --rm -p 8080:8080 -p 9090:9090 ghcr.io/otfantik/project-devops-deploy:latest
Infrastructure

The project uses Ansible for infrastructure provisioning with the following roles:

deploy: Sets up PostgreSQL, MinIO, and the Spring Boot application
nginx: Configures Nginx as reverse proxy
nginx-ssl: Handles Let's Encrypt SSL certificates with auto-renewal
SSL/TLS

HTTPS is enabled with Let's Encrypt:

Certificate auto-renewal via cron (every Monday at 3 AM)
Modern TLS 1.2/1.3 only
Strong cipher suites
HTTP to HTTPS redirect
Monitoring

Management endpoints are available on port 9090:

Health: https://hexletmazov.ddns.net/actuator/health

Useful Commands

See Makefile for all available commands:


make deploy-latest   # Full deployment
make ansible-deps    # Install Ansible dependencies
make docker-build    # Build Docker image
make docker-push     # Push image to registry
License

This project is licensed under the MIT License - see the LICENSE file for details.