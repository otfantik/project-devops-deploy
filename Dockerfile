FROM gradle:8.10-jdk21 AS backend-build
WORKDIR /app
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle gradle/
RUN gradle dependencies --no-daemon || true
COPY src src/
RUN gradle bootJar --no-daemon

FROM node:20-alpine AS frontend-build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm ci || npm install
COPY frontend/ ./
RUN npm run build

FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
RUN apk add --no-cache curl
COPY --from=backend-build /app/build/libs/*.jar app.jar
RUN mkdir -p /app/static
COPY --from=frontend-build /app/dist /app/static
RUN mkdir -p /tmp/bulletin-images && chown -R appuser:appgroup /tmp/bulletin-images
USER appuser
EXPOSE 8080 9090
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar app.jar"]