# Capstone — Linkly Polyglot Microservices Platform
Repo: github.com/alok2502/linkly-platform

## Part 1 (DONE) — Build + Containerize
4 microservices, 4 languages, 4 Dockerfile patterns:
- api-gateway (Go)    -> multi-stage build + distroless static. 18MB. USER nonroot (built-in).
- user-service (Python/Flask) -> slim base + pip requirements-FIRST caching. 200MB.
  Non-root = RUN useradd + USER (slim has no nonroot user).
- link-service (Node/Express) -> alpine + package.json-FIRST npm caching. 208MB.
  USER node (built-in). --chown for write access if needed.
- analytics-service (Java/Spring) -> multi-stage Maven+JDK build -> JRE runtime. ~280MB.
  Build stage compiles jar, runtime stage only RUNS it (java -jar, not javac).

## Key Dockerfile lessons
- Caching principle SAME for all: copy dependency manifest FIRST, install, THEN copy code
  (deps change rarely -> cached layer; code changes often).
- Non-root MECHANICS differ per base: distroless/node = built-in user; debian-slim = create it.
- Compiled (Go 18MB) vs interpreted/JVM (Python 200 / Java 280): compiled ships a static binary,
  others ship their runtime -> inherently bigger.
- EXPOSE is DOCS ONLY — doesn't set the listen port. App decides (Spring defaulted 8080;
  fixed via SERVER_PORT env). "Container up but connection reset" -> docker logs -> check bound port.

## docker-compose
- build: per service. environment: declarative config (SERVER_PORT etc).
- depends_on + condition: service_healthy -> wait for postgres healthcheck before starting.
- named volume pgdata (persistent DB). Same default network -> services reach each other by name.

## Part 2 (TODO) — CI/CD + K8s + ArgoCD + Monitoring
