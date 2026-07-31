# Day 20 — Monitoring & Observability (Prometheus + Grafana)

## Three pillars of observability
- Metrics: numeric over time (CPU, req rate, errors). Dashboards + alerts. -> Prometheus.
- Logs: timestamped event records. WHY it happened. -> Loki/ELK.
- Traces: one request across services. WHERE latency is. -> Jaeger/Tempo.
Metrics say SOMETHING is wrong (+alert), logs say WHAT, traces say WHERE.

## Prometheus (PULL model)
- Scrapes /metrics endpoints on a schedule (pull). Scrape fails = target down.
- Pieces: server (scrape+TSDB+rules), exporters (node-exporter=host, kube-state-metrics=K8s state),
  PromQL, Alertmanager (route/group/silence), Grafana (viz).
- kube-prometheus-stack via Helm: prometheus/alertmanager=StatefulSets, node-exporter=DaemonSet,
  grafana=Deployment, operator manages all.

## PromQL
- metric{label="x"} filter; count/sum/avg(metric) by (label) group.
- rate(counter[5m]) = per-second avg increase over window. Counters only go up; rate converts
  cumulative -> current rate (what you graph/alert on).
- kube_pod_status_phase{phase="Pending"}==1 = unhealthy pods.

## Node golden signals (Node Exporter dashboard)
CPU, memory, disk, network + load average. Load > #cores = CPU bottleneck. Disk >80% ->
DiskPressure -> Pending pods. Memory red -> OOMKills/evictions.

## Alerting
- Rules (PromQL) fire when true for `for: 5m` (anti-flap) -> Alertmanager routes/groups.
- Stack ships 30+ groups: KubePodCrashLooping, KubePodNotReady, NodeMemoryHigh, KubeletDown
  = the Day 18-19 failure modes, automated.

## Full circle
Monitoring + debugging = same knowledge, 2 directions. Alert on CrashLoop/NotReady/OOM ->
debug method (describe/exit-code/logs) finds root cause.
