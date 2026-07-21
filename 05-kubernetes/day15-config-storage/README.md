# Day 15 — Kubernetes Config & Storage

## ConfigMaps (non-sensitive config)
- Externalize config (DB hosts, flags, log levels) so image stays generic across envs.
- Inject as env vars (envFrom/configMapRef) or mounted files. No config baked in image.

## Secrets (sensitive) — THE GOTCHA
- Same as ConfigMap but for passwords/keys. BUT: base64-ENCODED, not encrypted!
- `kubectl get secret x -o jsonpath='{.data.KEY}' | base64 -d` -> plaintext. Anyone with
  read access decodes it.
- To actually secure: (1) RBAC (limit who reads secrets), (2) etcd encryption at rest,
  (3) external secrets manager (AWS Secrets Manager/Vault).
- Prefer MOUNTING secrets as files over env vars (env leaks via /proc, crash dumps, children).

## PV / PVC / StorageClass (supply/demand/automation)
- PV = actual storage (supply). PVC = pod's request (demand). StorageClass = how to
  dynamically provision (automation). Pod -> PVC -> binds PV; StorageClass auto-creates PV.
- Decoupling: app writes a PVC ("give me 5Gi") not caring if it's EBS/NFS/local. Same
  manifest works on any cloud — swap the StorageClass.
- accessModes: ReadWriteOnce (RWO) = one node RW (like EBS, AZ-bound). Also RWX, ROX.

## Debugging: PVC stuck Pending (real scenario!)
- StorageClass VOLUMEBINDINGMODE: WaitForFirstConsumer = PV NOT provisioned until a POD
  consumes the PVC. Not a bug — waits so it provisions in the right node/AZ (EBS is
  AZ-bound). Fix: create the pod. (vs Immediate = binds right away.)
- Also check: reclaim policy Delete (data destroyed w/ PVC) vs Retain (kept — use for DBs).

## StatefulSet storage (the bridge)
- volumeClaimTemplates = a PVC template -> one SEPARATE PVC+PV per pod (data-db-0,
  data-db-1...). Own storage each = no sharing/corruption. Stable name -> pod reattaches
  to its own PV on recreate. Stable identity + stable storage = why DBs use StatefulSets.
