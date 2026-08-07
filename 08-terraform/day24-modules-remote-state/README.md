# Day 24 — Terraform Part 2: Modules + Remote State

## Modules (reusable infra = DRY)
- Module = reusable parameterized package of resources. Analogy: a FUNCTION.
  input variables = parameters, outputs = return values, calling module = calling function.
- Structure: modules/<name>/ with main.tf + variables.tf (no hardcoded values) + outputs.tf.
- Root module CALLS it: module "dev_network" { source="./modules/vpc" vpc_cidr=... }.
  Called SAME module twice (dev 10.0/16, staging 10.1/16) -> 2 networks from 1 definition.
- Read module output: module.dev_network.vpc_id.
- Real world: dev.tfvars/staging.tfvars/prod.tfvars feed same modules per environment.

## Remote state + locking (team collaboration)
- Local state breaks for teams: not shared + no locking (concurrent apply = corruption).
- Fix: S3 backend (shared, versioned, encrypted) + DynamoDB locking (one apply at a time).
- backend "s3" { bucket, key, region, dynamodb_table, encrypt=true }. terraform init MIGRATES
  local state -> S3 (asks yes to copy).
- Lock mechanism: apply writes lock to DynamoDB ("Acquiring state lock"), releases at end.
  Concurrent apply gets "state locked" error. DynamoDB = atomic conditional writes.
- MODERN: dynamodb_table deprecated -> use_lockfile=true (S3-native locking, no DynamoDB needed).
  Resume bullet (DynamoDB) still valid/common; knowing use_lockfile = current/senior.
- State NEVER in git (has secrets). Code -> git, state -> S3.

## Bootstrap chicken-and-egg + teardown order
- S3 bucket + DynamoDB table hold state -> can't be managed by the TF that uses them.
  Bootstrap separately (CLI). 
- Teardown ORDER: terraform destroy FIRST (needs state+backend), THEN delete bucket+table.
  Delete backend first = strand the infra.
- Versioned bucket won't delete via `s3 rb --force`; delete all versions first (boto3 or CLI).
