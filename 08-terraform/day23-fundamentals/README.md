# Day 23 — Terraform Part 1: Fundamentals + AWS Build

## What Terraform is
Declarative IaC — describe desired infra in .tf, Terraform reconciles (same model as K8s/GitOps).
Beats console: repeatable, version-controlled, documented, reproducible across envs.

## Lifecycle
- terraform init  = download provider plugins
- terraform plan  = DRY-RUN preview (create/update/destroy) — safety net, see blast radius first
- terraform apply = make the changes
- terraform destroy = tear down (reverse dependency order, clean, no orphans)

## STATE (the big interview concept)
- terraform.tfstate = record/mapping of what TF created (code resource name <-> real AWS ID).
  "Brain of the infra." How TF knows to UPDATE vs CREATE vs DESTROY on next apply.
- plan compares 3 things: code (desired) <-> state (what TF thinks) <-> real AWS (actual).
- State can hold SECRETS (plaintext) -> store securely. Teams -> remote (S3) + lock (DynamoDB)
  so concurrent applies don't corrupt it (Day 24). NEVER hand-edit state.
- TF only manages resources in ITS state; pre-existing infra invisible unless `terraform import`.

## Syntax
- resource "TYPE" "LOCAL_NAME" { ... }. Reference: aws_vpc.main.id.
- No creds in code — uses EC2 instance role automatically.

## Dependency graph
TF infers creation order from references (subnet refs vpc.id -> vpc first). Parallelizes
independent resources. `depends_on` for deps not expressed via reference. (Solves the Day 3
NAT ordering pain automatically.)

## Variables + Outputs
- variables.tf = parameterize (reusable: same code, -var environment=prod). type + default + description.
- outputs.tf = expose values (VPC id) for other modules/humans. `terraform output`.
- Refactor hardcoded -> variables with SAME values = plan shows "No changes" (safe refactor).
