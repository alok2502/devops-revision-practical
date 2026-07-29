# Day 19 — Kubernetes Debugging II: Cluster, Node & Network

## Cluster/systems-tier failure modes (4/4 diagnosed)
- Service returns nothing -> kubectl get endpoints (EMPTY = smoking gun) -> selector != pod labels.
- Nothing resolves DNS cluster-wide -> kubectl get pods -n kube-system -l k8s-app=kube-dns -> CoreDNS down.
- Pod stuck Pending -> describe Events -> insufficient resources OR untolerated taint.
- CreateContainerConfigError -> describe Events -> missing/wrong ConfigMap or Secret.

## Key insights
- "Service returns nothing" -> check ENDPOINTS FIRST. Empty = selector/label mismatch (90%).
  Populated but still failing = look elsewhere. Decision tree.
- CoreDNS = pods in kube-system. ALL pods use the ONE shared CoreDNS (resolv.conf -> 10.96.0.10),
  so if down, DNS fails CLUSTER-WIDE. Single point of failure -> 2 replicas for redundancy.
  Real cause usually OOMKill/eviction.
- Pending = never scheduled = NO LOGS. Cause in describe Events. Read the EVENT: "Insufficient
  memory" vs "untolerated taint" = different fixes.
- CreateContainerConfigError = referenced ConfigMap/Secret missing. No logs -> describe Events.
  Common "deployed but nothing started" (forgot to apply CM / wrong namespace).

## Meta-skill (whole debugging block)
Match tool to symptom:
- Container RAN then failed -> logs (--previous for crashed).
- Container NEVER ran (Pending/ConfigError/ImagePull) -> describe Events, NOT logs.
- Service issue -> get endpoints. DNS issue -> CoreDNS in kube-system.
Status = symptom; Events/exit-code/endpoints = actual cause.

## Prod incident response
Stabilize FIRST (rollback to last-good = keep serving), THEN diagnose calmly.
