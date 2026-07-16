# Day 10 — Docker Networking, Volumes, Compose, Multi-stage

## Networking
- Drivers: bridge (default, isolated + port publish), host (shares host stack, no isolation), none.
- DEFAULT bridge = NO name resolution (IP only). USER-DEFINED bridge = Docker embedded
  DNS at 127.0.0.11, containers reach each other BY NAME. Always use user-defined nets.
- Debug tip: on a "DNS fail" check WHICH resolver answered + what name was queried
  (nslookup appended .ec2.internal = false alarm; ping/getent resolved fine).

## Volumes (containers are ephemeral!)
- Writable layer dies with the container. Proved: no volume -> data gone on recreate.
- Named volume (-v pgdata:/path) -> data SURVIVES container destroy/recreate.
- Named volume (Docker-managed) vs bind mount (host dir, good for dev/config).
- Never run a stateful service without a volume. Seed of K8s PersistentVolumes.

## Docker Compose
- Whole multi-container app in one declarative YAML (services/networks/volumes/env).
- `docker compose up -d --build`. Auto-creates a user-defined net -> name resolution free.
- depends_on for start order. Built a real web+db 2-tier app (visit counter, persisted).
- Declarative = same philosophy as Terraform + Kubernetes.

## Multi-stage builds (the big win)
- Go app: naive (full toolchain) = 1.34GB. Multi-stage + distroless = 17.9MB (~75x!).
- Stage 1 (AS builder) compiles; stage 2 COPY --from=builder just the binary into distroless.
- Toolchain discarded. Benefits: fast pulls, tiny attack surface (no shell), lower cost.
- Size ladder: full -> slim -> alpine -> distroless -> scratch.
