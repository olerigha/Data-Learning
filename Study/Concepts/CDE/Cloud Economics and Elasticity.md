---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Cloud Economics and Elasticity
**In one line:** Rent computing on demand (operating expense) instead of buying it up front (capital expense), and scale it up or out as load changes.

**In plain words:** Buying servers means guessing tomorrow's needs today and getting stuck with too much or too little. The cloud flips that: pay as you go, change capacity in minutes, delete what you don't need. You can scale **up** (a bigger machine) or **out** (more machines). Chips stopped getting dramatically faster (Moore's Law is hitting physical limits), so scale-out and custom cloud chips matter more.

**Terms**
| Term | Means |
|---|---|
| Cloud computing (NIST) | on-demand, shared computing resources reached from anywhere with minimal management |
| CapEx | capital expense: buy hardware up front |
| OpEx | operating expense: pay-as-you-go |
| Elasticity | automatically add or remove resources with load |
| Vertical scaling (scale up) | a bigger machine |
| Horizontal scaling (scale out) | more machines |
| Multi-tenant | many customers share the same physical hardware safely |
| Moore's Law | transistor count doubles about every 2 years; now near atomic and heat limits |
| TPU / Graviton | custom cloud chips (Google ML chip / AWS ARM CPU) |

**Key points**
- Cloud traits: on-demand self-service, accessible, utility-priced, scalable, elastic, multi-tenant.
- Why cloud-native: elasticity, pay-per-use, managed services, global reach. Redesign for distributed systems; don't just "lift and shift".
- Multi-cloud: flexibility, proximity, failover, cost. The challenge is complexity.
- Success stories: Gilead (50 PB on AWS, data mesh), Toyota Connected (serverless + streaming, 70–80% savings), Epic Games (Fortnite on AWS).

**Memorize vs. look up:** Memorize CapEx vs OpEx and scale up vs scale out.

Related: [[Cloud Service Models]], [[Regions and Availability Zones]], [[Infrastructure as Code]], [[Cloud Cost Management]]
