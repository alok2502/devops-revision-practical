# Day 13 — Kubernetes Workloads

## The workload types (when to use each)
- Deployment: stateless apps (APIs, web). Rolling updates + rollback. Random pod names. 95% of use.
- StatefulSet: stateful apps needing stable identity (DBs, queues). Ordered names db-0,db-1;
  each pod its OWN persistent volume (volumeClaimTemplates); ordered startup.
- DaemonSet: one pod per node (log collectors, monitoring, CNI). No replica count — tied to nodes.
- Job: run-to-completion (migrations, backups). Runs once, exits Completed, no restart.
- CronJob: Job on a cron schedule (nightly cleanup, reports). Spawns a Job each interval.

## Deployment mechanics (rolling update + rollback)
- YAML anatomy: selector.matchLabels must match template labels. resources.requests
  (scheduler guarantee) vs limits (hard ceiling; exceed mem = OOMKilled). Limits = cgroups.
- Rolling update: `kubectl set image` -> NEW ReplicaSet scaled up while OLD scaled down,
  one at a time. Zero downtime: old healthy pods serve until new ones Ready.
- Two ReplicaSets after update: old at 0 (parked), new at 3. Old kept = instant rollback.
- Bad image (ImagePullBackOff/ErrImagePull) STALLS safely — old pods keep running.
- Rollback: `kubectl rollout undo` = scale the parked old ReplicaSet back up. Fast (no
  re-pull/re-schedule) + safe (readiness-gated, returns to known-good). Revisions tracked.
- Gotcha: mixing imperative (set image / rollout undo) with declarative (apply -f) causes
  drift. GitOps way = revert in git + re-apply YAML.

## Why Postgres != Deployment
Deployment pods are identical + may share one volume -> multiple postgres writing same
data dir -> corruption. StatefulSet = each pod own volume + stable identity + ordered start.
