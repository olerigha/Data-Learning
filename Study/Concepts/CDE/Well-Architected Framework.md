---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Well-Architected Framework
**In one line:** AWS's five-pillar checklist for a good cloud system: operational excellence, security, reliability, performance efficiency and cost optimization.

**In plain words:** When you design a cloud system, check it against five questions. Can we run and change it safely? Is the data protected? Does it recover from failures by itself? Is it fast enough and using the right services? Are we spending wisely? Each pillar comes with a few design principles.

**Terms**
| Pillar | Key principles from the slides |
|---|---|
| Operational excellence | operations as code; small, frequent, reversible changes; anticipate failure; learn from it |
| Security | strong identity, traceability, security at every layer, protect data in transit and at rest, keep people away from data |
| Reliability | auto-recover, test recovery, scale horizontally, stop guessing capacity, automate change |
| Performance efficiency | use managed and serverless services, go global in minutes, experiment often |
| Cost optimization | cloud financial management, pay for what you use, measure efficiency, attribute spend |

**Key points**
- General design principles: stop guessing capacity, test at production scale, automate experiments, evolve the architecture, decide from data, run "game days" (practice failures).
- Reference architectures: 3-tier web app, recommendation system, analytics pipeline, ML pipeline.
- Bottom line: choose the right service for the workload, with security, reliability and cost in mind.

**Memorize vs. look up:** Memorize the five pillars and one principle each.

Related: [[Cloud Cost Management]], [[Functional vs Non-Functional Requirements]], [[VPC and IAM Least Privilege]], [[Regions and Availability Zones]], [[Data Observability]]
