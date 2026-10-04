# syntax=docker/dockerfile:1.7

###############################################################################
# Stage 1 — frontend (React Admin + Vite)
###############################################################################
FROM node:24-alpine AS frontend
WORKDIR /build/frontend

COPY frontend/package.json frontend/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY frontend/ ./
RUN npm run build

###############################################################################
# Stage 2 — backend (Spring Boot fat jar, SPA в classpath:/static)
###############################################################################
FROM eclipse-temurin:25-jdk AS backend
WORKDIR /build

COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle ./gradle
RUN chmod +x gradlew

COPY src ./src

# SPA из стейджа frontend → classpath:/static, Spring Boot её отдаст
COPY --from=frontend /build/frontend/dist ./src/main/resources/static

RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew --no-daemon bootJar \
 && cp build/libs/*.jar /build/app.jar

###############################################################################
# Stage 3 — runtime
###############################################################################
FROM eclipse-temurin:25-jre-alpine

WORKDIR /app
RUN addgroup -S app && adduser -S app -G app

COPY --from=backend /build/app.jar /app/app.jar

USER app
EXPOSE 8080 9090

ENV JAVA_OPTS="" \
    SPRING_PROFILES_ACTIVE=prod \
    MANAGEMENT_SERVER_PORT=9090

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD wget -qO- "http://127.0.0.1:${MANAGEMENT_SERVER_PORT}/actuator/health" \
      | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["sh","-c","exec java $JAVA_OPTS -jar /app/app.jar"]