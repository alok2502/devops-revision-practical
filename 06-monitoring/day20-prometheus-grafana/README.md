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

## SLI / SLO / SLA & Error Budgets (reliability framing)
- SLI = Service Level INDICATOR = the MEASUREMENT (e.g. "99.95% requests succeeded",
  "p95 latency 200ms"). The reading on the gauge. Comes FROM your metrics (PromQL).
- SLO = Service Level OBJECTIVE = your internal TARGET for an SLI ("aim for 99.9%").
  Drives engineering decisions.
- SLA = Service Level AGREEMENT = customer CONTRACT with penalties/refunds if missed.
  Always looser than SLO (keep SLO stricter for a safety buffer).
- Ordering: SLA (loosest, customer) >= SLO (stricter, internal) >= actual SLI performance.

## Error Budget (the clever bit)
- SLO 99.9% => allowed 0.1% unreliability = the error BUDGET you can "spend".
- Budget remaining -> ship fast, take risks. Budget exhausted -> freeze deploys, fix stability.
- Objective referee for the dev(ship) vs ops(stable) tension. Data-driven, not arguing.
- "Nines": 99.9% ~= 43min/month down, 99.99% ~= 4.3min, 99.999% ~= 26sec. Each nine = 10x harder.
  Pick SLO by BUSINESS need — every extra nine costs exponentially more.
- Burn-rate alert = fires when error budget is being consumed too fast
  (saw kube-apiserver-burnrate.rules yesterday = exactly this).
- Chain: metrics -> SLI -> SLO target -> error budget -> burn-rate alerts.
