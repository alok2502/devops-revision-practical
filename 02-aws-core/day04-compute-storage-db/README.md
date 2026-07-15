# Day 4 — Compute, Storage & Databases

## EC2 pricing (match commitment to predictability)
On-Demand (flexible, priciest) | Reserved/Savings (steady baseline, ~72% off) |
Spot (~90% off, 2-min reclaim, fault-tolerant only) | Dedicated Hosts (licensing niche)

## Storage
- EBS = block, one instance, AZ-bound (gp3/io2/st1). "Server's disk."
- EFS = shared NFS, many instances, spans AZs. "Shared drive."
- S3 = object, ~infinite, 11 nines. Classes Standard->IA->Glacier->Deep Archive + lifecycle.

## RDS
- Managed: patching/backups/replication/failover handled.
- Multi-AZ = HA/failover (standby, not read from). Read Replica = scale reads. (Don't confuse!)
- RDS (relational, SQL, joins) vs DynamoDB (NoSQL, serverless, no joins).
- In-VPC: DB subnet group spans >=2 AZs; private subnets + SG(5432 from VPC) + not public = defense in depth.

## Gotchas
- S3 versioning keeps all versions (delete = delete marker).
- EBS AZ-bound; Nitro remaps device names (sdf -> nvme1n1); ALWAYS lsblk before mkfs.

## Revisit as code (Terraform days)
RDS migration, read replicas, Route53, CloudWatch, Well-Architected pillars.
