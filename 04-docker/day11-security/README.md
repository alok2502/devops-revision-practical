# Day 11 — Docker in Production (Security & Optimization)

## Hardening (shrink what an attacker can do after escape)
- Containers run as ROOT by default (uid=0). Fix: create + USER a non-root user (uid=1000).
- Runtime lockdown: --user, --cap-drop ALL (root's power = ~40 capabilities, drop unused),
  --read-only rootfs + --tmpfs /tmp for scratch. Well-behaved apps run fine locked down.
- Maps to Kubernetes securityContext (next week).

## Scanning (Trivy)
- CVEs = known vulns in image packages. Trivy scans against vuln DBs.
- python-slim: perl/util-linux CVEs (OS baggage I don't even use; many fix_deferred).
- distroless goapp: only golang stdlib CVEs (my actual deps) — all have Fixed Versions.
- Insight: minimal images narrow vulns to only YOUR deps = the ones you can actually patch.
- CI gate: `trivy image --exit-code 1 --severity CRITICAL img` fails build on criticals.

## Dockerfile review — 8 problems to catch
1. ubuntu:latest = too big AND unpinned (not reproducible). Use python:3.12-slim.
2. Multiple RUN = extra layers + apt update/install split = stale cache. Combine + rm apt lists.
3. COPY . /app leaks .env/.git/keys. Use .dockerignore.
4. WORKDIR after COPY = wrong order.
5. Hardcoded password = baked into image layer forever (docker history). Inject at runtime.
6. Deps after code = every code change rebuilds deps. Copy requirements + install BEFORE code.
7. CMD shell form = app not PID 1, ignores SIGTERM. Use exec form ["python3","app.py"].
8. Runs as root. Add non-root USER.

## Hardened order: base -> user -> WORKDIR -> deps -> code -> USER -> CMD
(stable stuff first for caching; drop privileges last)
