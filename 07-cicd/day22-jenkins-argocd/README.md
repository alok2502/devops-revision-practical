# Day 22 — CI/CD Part 2: Jenkins + GitOps/ArgoCD

## Jenkins
- Controller (brain): schedule jobs, UI, config, distribute work. Agents (workers): run builds.
  Same brain/muscle split as K8s control plane vs nodes. Scale by adding agents.
- Jenkinsfile (pipeline as code). Declarative (structured, preferred) vs Scripted (raw Groovy).
- Same chain as GH Actions. post{} = notify on success/fail. Creds from Jenkins credential store.

## GitOps
- Git = SINGLE SOURCE OF TRUTH. Controller IN cluster PULLS from Git + continuously reconciles.
  Same reconciliation philosophy as K8s control plane; desired state lives in Git.

## Push vs Pull CD
- Push: pipeline runs kubectl apply -> cluster creds OUTSIDE cluster (in CI). Compromise CI =
  cluster access. Drift possible.
- Pull (ArgoCD): controller in cluster pulls from Git. Cluster creds NEVER leave cluster. CI only
  pushes to Git+registry. Auto drift-correction.

## Why GitOps (3 benefits)
1. Security: cluster creds stay in cluster, CI has no cluster access, smaller blast radius.
2. Auditability: every change = Git commit (who/what/when). Rollback = git revert.
3. Drift correction: selfHeal reverts manual changes back to Git.

## ArgoCD demo (proved live)
- ArgoCD runs as pods IN cluster. Application = "watch repoURL/path, deploy to cluster/ns".
  syncPolicy.automated + prune + selfHeal. SYNC STATUS (matches Git?) vs HEALTH (running ok?).
- Deleted deployment -> recreated in ~20s. Scaled to 5 -> forced back to 1. Cluster can't drift.
