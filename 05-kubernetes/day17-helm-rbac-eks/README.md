# Day 17 — Helm, RBAC & Security on EKS

## Helm (K8s package manager = apt/npm for clusters)
- Chart (templates/package), Values (config filling templates), Release (installed instance).
- Templating: {{ .Values.x }} + values.yaml -> same chart, diff config per env.
- helm install/upgrade --set replicaCount=3/uninstall. Revisions tracked (helm rollback).
- Note: Bitnami restricted free charts (Aug 2025) — use official/own charts increasingly.

## RBAC (= IAM least-privilege, K8s flavor)
- Role (namespaced perms) / ClusterRole (cluster-wide) = WHAT is allowed.
- RoleBinding / ClusterRoleBinding = WHO gets it (grants Role to subject).
- Role does nothing without a Binding (like IAM policy vs attachment). Decoupled for reuse.
- ServiceAccount = identity for PODS (in-cluster equivalent of EC2 instance role).
- Debug: kubectl auth can-i <verb> <resource> --as=system:serviceaccount:ns:sa

## securityContext (RUN-TIME hardening; distinct from build-time image hygiene)
- runAsNonRoot/runAsUser, capabilities.drop:[ALL], readOnlyRootFilesystem:true, allowPrivilegeEscalation:false.
- = Day 11 docker run --user --cap-drop ALL --read-only.
- Read-only rootfs needs emptyDir volumes for scratch (/tmp, /var/cache, /var/run).
- Proved: uid=1000, write to rootfs BLOCKED, /tmp writable. (gid=0 -> also set runAsGroup.)
- Build-time (multi-stage/distroless/scan = what's IN image) vs run-time (securityContext = what it CAN DO).

## EKS (real managed K8s on AWS)
- AWS manages control plane (apiserver/etcd/scheduler, multi-AZ). You manage nodes + workloads.
- Worker nodes = real EC2 (cost). kind node = a container (free).
- AWS VPC CNI = pods get REAL VPC IPs -> can talk to RDS. LoadBalancer svc -> real ELB.
- IRSA = ServiceAccount tied to IAM role. eksctl builds it via CloudFormation.
- LESSON: node-group provisioning FAILED (control plane OK, nodes didn't join). Real-world common.
  Skill = diagnose which part failed + eksctl delete cluster + VERIFY no billing
  (cloudformation stacks, NAT gateways, unattached EIPs). Teardown discipline > clean first try.
