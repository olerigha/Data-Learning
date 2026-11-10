---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Cloud Cost Management
**In one line:** Almost everything in the cloud is billed, so tag every resource, set budget alerts, estimate costs up front, and clean up after labs.

**In plain words:** Pay-as-you-go also means pay-for-what-you-forget. Tag every resource with its project, so you can see where money goes. Set a budget that alerts you before spending gets out of hand. Use the pricing calculator before you build. And when a lab ends, delete everything you created, then confirm the forecast drops to $0.

**Terms**
| Term | Means |
|---|---|
| Cost Explorer | AWS view of past spending by service, account or tag |
| Budget alert | notification when spend passes a threshold (e.g. 80%) |
| Tag | label on a resource (project, environment, owner) |
| TTL / ExpiresOn tag | marks when a resource should be deleted |
| Pricing calculator | estimates monthly cost before you build |

**Key points**
- **Cleanup checklist:** (1) stop or terminate compute (EC2, test Lambdas) → (2) empty and delete S3 buckets → (3) delete RDS instances and manual snapshots → (4) delete lab IAM roles and policies → (5) delete security groups, NAT gateways, endpoints → (6) check Cost Explorer forecast is $0 for the lab tag.
- NAT gateways and idle databases are classic silent costs.
- Assignment submissions need a cost estimate and proof that resources were terminated.

**Memorize vs. look up:** Memorize "tag everything" and the cleanup order.

Related: [[Well-Architected Framework]], [[Cloud Economics and Elasticity]], [[AWS CLI and EC2 Basics]], [[Functional vs Non-Functional Requirements]]
