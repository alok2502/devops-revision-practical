# Day 3 — IAM & VPC (build + real debugging)

## What I built (production-shaped VPC, via CLI)
- VPC 10.0.0.0/16, 2 AZs; public subnets 10.0.1-2.0/24, private 10.0.11-12.0/24
- IGW (attached), NAT (in public subnet + EIP)
- Route tables: public-rt (0.0.0.0/0 -> IGW), private-rt (0.0.0.0/0 -> NAT)
- Bastion (public IP) + private-app (NO public IP)
- SGs: bastion-sg (SSH from my IP), private-sg (SSH from bastion-sg only)

## IAM
- users / groups / roles / policies. Least privilege.
- Instance role = right way to give EC2 AWS access: temp auto-rotating creds via
  IMDS (169.254.169.254), NO keys on disk.

## Key distinctions (interview)
- Public vs private subnet = the ROUTE TABLE (IGW=public, NAT=private), not a checkbox.
- SG (instance, stateful, allow-only) vs NACL (subnet, stateless, allow+deny).
- IGW (two-way) vs NAT (outbound-only, no inbound initiation; keeps a state table = same idea as an SG).
- Bastion vs SSM Session Manager (shell via AWS API/443, no SSH/port22/public IP, audited — modern replacement).

## War stories
1. Root keys on the box -> deleted at source, MFA on root, switched to instance role.
2. Malformed NAT (Subnet:null, edge-associated route table) -> recreated cleanly via CLI.
3. SSH timeout -> diagnosed as wrong source IP in SG -> pivoted to Session Manager.

## Diagnostic ladder
timeout = packets dropped (network) | refused = arrived, nothing listening (service) | denied = auth
