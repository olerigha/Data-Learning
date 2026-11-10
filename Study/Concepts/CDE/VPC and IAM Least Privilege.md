---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]], [[AWS-CLI]]"
status: new
tags: [generated]
---
# VPC and IAM Least Privilege
**In one line:** A VPC is your private network in the cloud; IAM decides who can do what. Give every user and service only the access it needs.

**In plain words:** A VPC is your own fenced-off network inside AWS. Public subnets hold only what must face the internet (load balancers, NAT gateways). Private subnets hold the app servers. A data subnet holds the databases, which are never public. Security groups act as firewalls between these tiers. IAM is the keycard system: services should take on **roles** with short-lived credentials rather than long-lived user keys, and every role gets only the permissions it needs.

**Terms**
| Term | Means |
|---|---|
| VPC | Virtual Private Cloud: your logically isolated network |
| Subnet | a section of the VPC: public (internet-facing) or private (internal) |
| Security group | stateful firewall per instance; inbound denied by default |
| NAT gateway | lets private servers reach out to the internet (e.g. for updates) without being reachable |
| VPC endpoint | private path to S3 or DynamoDB (avoids NAT charges) |
| IAM user / group / role / policy | person identity / set of users / assumable identity with no long-lived keys / JSON allow-deny rules |
| STS AssumeRole | gives temporary credentials (15 min – 12 h) |
| MFA | multi-factor authentication |

**Key points**
- The app is reachable only through the load balancer, never directly from the internet.
- Reference security-group IDs (not IP ranges) to express trust between tiers.
- **IAM best practices:** never use the root account day-to-day; roles for services, not users; least privilege from day one (easier to add than remove); MFA for every human; rotate access keys.
- GCP equivalent: service accounts with JSON keys (e.g. `Storage Object Admin` instead of `Storage Admin`).

**Memorize vs. look up:** Memorize public/private/data subnets, user vs role, and the five IAM best practices.

Related: [[AWS CLI and EC2 Basics]], [[Load Balancing]], [[Managed Databases]], [[Well-Architected Framework]], [[Data Governance and Lineage]]
