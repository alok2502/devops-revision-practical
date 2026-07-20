# Day 14 — Kubernetes Services & Networking

## Why Services exist
Pods are ephemeral -> IPs change on every restart -> can't hardcode pod IPs.
Service = stable virtual IP (ClusterIP) + DNS name that auto-routes to healthy pods
matching its label selector. Proved: deleted all pods (new IPs), Service IP unchanged,
Endpoints auto-updated. Stable front door, shifting backends.

## Mechanism
Service -> label selector -> EndpointSlices (live pod IPs, modern replacement for
Endpoints) -> kube-proxy routes. Two IP ranges: pods 10.244.x (real, per CNI),
services 10.96.x (VIRTUAL — kube-proxy routing rule, not a real interface = why stable).

## Three Service types (layered, each builds on last)
- ClusterIP (default): internal only, pod-to-pod. 90% of use.
- NodePort: ClusterIP + static port (30000-32767) on every node IP. External via node
  (only reachable by things that can route to nodes — e.g. within the VPC).
- LoadBalancer: NodePort + cloud LB in front. Production external access from internet.

## DNS (CoreDNS = Docker's 127.0.0.11 at cluster scale)
Full name: <service>.<namespace>.svc.cluster.local. Same namespace -> short name works
(resolv.conf search domains auto-append). Cross-namespace -> need <svc>.<namespace>.
busybox nslookup shows NXDOMAIN noise per search-domain; read the one that RESOLVED.

## Ingress (L7 — Day 2 ALB path-routing, in K8s)
- Two parts: Ingress RESOURCE (rules) + Ingress CONTROLLER (running proxy). Rules inert
  without a controller (kind has none -> empty ADDRESS = the proof).
- Routes among MULTIPLE services by host/path through ONE entry point. Why over many
  LoadBalancers: one cloud LB instead of one-per-service = cheaper.
- north-south (external in) = Ingress. east-west (internal service-to-service) = ClusterIP.
- Hierarchy: Ingress -> Services -> Pods.

## NetworkPolicy (pod firewall = Security Groups for pods)
Default: all pods talk to all pods. NetworkPolicy = label-based allow/deny.
Empty ingress: [] = deny all inbound to selected pods. ONLY enforced if CNI supports it
(Calico/Cilium yes; kindnet no).
