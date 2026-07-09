# VPC CIDR Plan — Production-style 2-AZ layout

## VPC
- CIDR: 10.0.0.0/16   (65,536 addresses)

## Subnets (4 total: public + private across 2 AZs)

| Subnet          | AZ          | CIDR          | Addresses | Purpose                     |
|-----------------|-------------|---------------|-----------|-----------------------------|
| public-az-a     | us-east-1a  | 10.0.1.0/24   | 256       | ALB, NAT GW, bastion        |
| public-az-b     | us-east-1b  | 10.0.2.0/24   | 256       | ALB, NAT GW (HA)            |
| private-az-a    | us-east-1a  | 10.0.11.0/24  | 256       | app servers                 |
| private-az-b    | us-east-1b  | 10.0.12.0/24  | 256       | app servers, RDS            |

## Design notes
- /24 per subnet = 256 addresses (~251 usable after AWS reserves 5).
- Public subnets in 10.0.1-2.x, private in 10.0.11-12.x — the gap leaves
  room to grow each tier without renumbering.
- Two AZs = survives a single-AZ failure (HA requirement).
- Only 4 of 256 possible /24s used — tons of headroom in the /16.
