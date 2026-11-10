---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Load Balancing
**In one line:** Spread incoming requests across several servers so no single one is overloaded, and route around the ones that fail.

**In plain words:** A load balancer is the front door. Users hit one address, and it passes each request to a healthy server behind it. It's the only part exposed to the internet; the app servers sit safely in a private subnet. Add servers when traffic grows (scale out) and the load balancer spreads the work. It also checks server health and stops sending traffic to broken ones.

**Terms**
| Term | Means |
|---|---|
| Load balancer | distributes tasks across resources |
| Application LB | routes HTTP(S) requests, can route by path |
| Network LB | very fast, works at the connection level (TCP/UDP) |
| Gateway LB | routes traffic through security appliances |
| Health check | regular probe (e.g. a `/health` endpoint) to find failed servers |
| API Gateway | managed service to publish, secure and monitor APIs |

**Key points**
- Internet → load balancer (public subnet, port 443) → app instances (private subnet, port 8080 from the LB only).
- Pairs with auto-scaling groups to scale out.
- Week 6 data apps expose `/health` for load-balancer probes.

**Memorize vs. look up:** Memorize what it does and where it sits. Look up the three types.

Related: [[VPC and IAM Least Privilege]], [[Regions and Availability Zones]], [[Three-Tier Data Apps]], [[Cloud Economics and Elasticity]]

*The ALB / NLB descriptions and the health-check detail are general background; the slide only lists the three types.*
