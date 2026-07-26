# Day 18 — Kubernetes Debugging I: Workloads & Pods

## The Debugging Method (recite in interviews)
1. kubectl get pods            -> STATUS = the symptom
2. kubectl describe pod <x>    -> Events (bottom) + Last State = the CAUSE
3. kubectl logs <x> --previous -> app's side (--previous = the CRASHED instance's logs)
4. kubectl get events          -> cluster context
5. kubectl exec -it <x> -- sh  -> poke inside (if running)
KEY: status is the SYMPTOM not the diagnosis. Exit code + Events reveal the real cause.

## Failure modes (5/5 diagnosed)
- ImagePullBackOff/ErrImagePull: can't pull image (describe Events). Causes: wrong tag,
  image missing, no pull creds (private registry), registry unreachable.
- CrashLoopBackOff exit 1: starts then app crashes (logs --previous). App error/missing config.
- CrashLoopBackOff exit 137: OOMKilled (describe Last State). Mem limit too low / leak.
- Running but 0/1 READY: up but not serving (describe Events). Readiness probe failing.
- Init:0/1: init container failing (logs -c <init>). Dependency not ready.
- Pending: can't schedule (describe Events). Insufficient resources / untolerated taint.

## Key insights
- CrashLoopBackOff = SYMPTOM not cause. Exit code: 1=app error, 137=OOMKilled(128+9).
- Running != Ready. READY column = ready containers/total. 0/1 = readiness fail -> no traffic.
- logs --previous = the crashed instance's logs. Multi-container: logs -c <name>.
- Init containers all complete before main starts; often dependency gates.

## Keep prod up while fixing (the Infosys question)
- Never edit live pod. Update DEPLOYMENT -> rolling update = zero downtime (readiness-gated).
- kubectl rollout undo = instant revert. OOMKill: raise limit if real demand, first rule out leak.
