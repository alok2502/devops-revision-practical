# Day 12 — Kubernetes Architecture

## Core idea
Declarative desired state + continuous reconciliation. You declare "I want 3",
controllers drive actual -> desired forever. Never imperative "start this container".

## Control plane (brain)
- kube-apiserver: the front door / hub. EVERYTHING watches it; ONLY it touches etcd.
- etcd: distributed key-value store = single source of truth (desired + actual state).
- kube-scheduler: watches apiserver for unscheduled pods, DECIDES which node (writes a
  field — nothing runs yet).
- kube-controller-manager: runs reconciliation loops (Deployment ctrl, ReplicaSet ctrl...).

## Data plane (muscle, per node)
- kubelet: watches apiserver for pods assigned to its node, tells containerd to run them,
  reports status back. (PULL/WATCH model — apiserver does not push.)
- container runtime (containerd): actually runs containers.
- kube-proxy: Service networking rules on the node.

## kubectl apply flow (THE interview question)
kubectl -> apiserver (auth/validate) -> etcd (desired state). Deployment ctrl (watching
apiserver) creates ReplicaSet OBJECT -> ReplicaSet ctrl creates 3 Pod objects (just
records). Scheduler assigns pods to nodes (decision, nothing running). kubelet on each
node sees its pod -> containerd pulls+runs. kubelet reports -> apiserver -> etcd.
Actual = desired. KEY: everyone watches apiserver; only apiserver touches etcd;
nothing runs until kubelet acts.

## Reconciliation proved live
- Deleted pods -> ReplicaSet ctrl recreated them (desired 3 != actual). Can't kill by
  deleting pods (bailing water). Scale to 0 = change desired state (turn off tap).
- Pets vs cattle: pods are cattle — replace, don't nurse. New pod = same ReplicaSet hash.

## Ties to prior learning
- kind = K8s IN Docker (node is a container; 6443 port-mapped = Day 10).
- Control plane runs ITSELF as pods (kubectl get pods -n kube-system).
- CoreDNS = K8s cluster DNS (like Docker's 127.0.0.11 embedded DNS, at scale).
