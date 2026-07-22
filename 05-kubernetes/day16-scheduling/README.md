# Day 16 — Kubernetes Scheduling & Workload Management

## requests vs limits
- requests = guaranteed reservation; SCHEDULER uses it to pick a node. Too high=waste,
  too low=overcommit+kills. Also the DENOMINATOR for HPA utilization %.
- limits = hard ceiling, enforced at RUNTIME by cgroups.
  - Memory over limit -> OOMKilled (Exit Code 137 = 128+9/SIGKILL). Incompressible.
  - CPU over limit -> THROTTLED (slowed, not killed). Compressible.
- KEY: memory=incompressible->kill; CPU=compressible->throttle.

## QoS classes (auto-derived, sets eviction order under node pressure)
- Guaranteed: requests==limits. Killed LAST.
- Burstable: requests<limits. Medium.
- BestEffort: no requests/limits. Killed FIRST.

## Placement control
- nodeSelector: simple label match (hard).
- affinity/anti-affinity: node affinity (required/preferred), pod affinity (schedule NEAR),
  pod anti-affinity (schedule AWAY — spread replicas for HA).
- taints (on NODE) = repel pods unless tolerated. tolerations (on POD) = permission to land.
  Control-plane node tainted by default (kind removes it for single-node).
- affinity=pods attracted to nodes; taints=nodes repel pods. Debug: FailedScheduling event
  "node(s) had untolerated taint(s)" = pod Pending due to taint.
- Default tolerations (not-ready/unreachable :NoExecute 300s) = 5-min grace on node blips.

## HPA (Horizontal Pod Autoscaler)
- Watches a metric (CPU default), scales replicas to keep it near target %.
- Needs metrics-server + resources.requests set (utilization = usage/request; no request
  = <unknown> = never scales). Can scale on CPU/memory/custom.
- Control loop: over target -> add pods -> per-pod % drops -> settles at target. Scales
  down slowly to avoid flapping. Watched 1->5 replicas find equilibrium at ~50%.
