# Day 21 — CI/CD Part 1: Concepts + GitHub Actions

## CI vs CD vs CD
- CI = auto build + test every change. "Is the code good?"
- Continuous Delivery = passing builds ready to ship; MANUAL approval to deploy prod.
- Continuous Deployment = same but AUTO-deploys, no human gate.
- Key diff (Delivery vs Deployment) = the manual approval gate.

## Pipeline stages
lint -> test -> build (Docker) -> scan (Trivy) -> push (registry) -> deploy.
Any stage fails -> pipeline stops -> broken/insecure code never ships.

## Deployment strategies
- Rolling (K8s default): gradual pod replace, zero downtime.
- Blue-Green: 2 full envs, switch traffic at once, instant rollback, 2x cost.
- Canary: small % users first (5->10->100), watch metrics, limit blast radius.

## GitHub Actions
- Workflow (.yml) in .github/workflows/ AT REPO ROOT (nested = ignored! gotcha).
- on: (trigger) -> job -> steps -> actions (reusable). Runners = GitHub VMs.
- Built: checkout -> python -> deps -> lint -> test -> build+push GHCR -> Trivy scan.

## Security gate (Trivy)
- exit-code '1' on CRITICAL = FAIL build (blocks vulnerable image). Saw RED on 4 criticals.
- ignore-unfixed: true = only fail on FIXABLE vulns (unfixable = no patch = noise).
- CVEs still exist; we just don't block on unfixable ones.

## Registry push + secrets (CI->CD bridge)
- Image discarded when runner stops -> PUSH to registry to deploy.
- docker/login-action + build-push-action (push:true). Tags: commit SHA (traceable) + latest.
- NEVER hardcode creds. GITHUB_TOKEN = auto-created per run, scoped, auto-deleted.
  Same principle as EC2 instance role / IRSA: short-lived scoped creds > long-lived hardcoded.
- github.sha tag = trace image to exact commit + roll back to known image.
