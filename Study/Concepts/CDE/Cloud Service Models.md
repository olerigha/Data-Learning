---
course: CDE
week: 2
source: "[[Week1-Introduction.pdf]], [[Cloud-Data-Engineering/Week2/Lecture2/README|Week 2 README]]"
status: new
tags: [generated]
---
# Cloud Service Models
**In one line:** How much of the stack the cloud provider runs for you: just the hardware, the platform, the whole app, or a single function.

**In plain words:** Think of it like food. IaaS is renting a kitchen: you get the equipment but cook everything yourself. PaaS is a meal kit: the platform is ready, you bring the recipe (your code). SaaS is eating at a restaurant: you just use the finished product. FaaS (serverless) is ordering one dish only when you're hungry, and you pay per dish.

**Terms**
| Term | Means | Example |
|---|---|---|
| IaaS | Infrastructure as a Service: rented VMs, storage, networks | AWS EC2 |
| PaaS | Platform as a Service: managed runtime or database | AWS RDS, Cloud SQL |
| SaaS | Software as a Service: a finished app | Gmail, Tableau Cloud |
| FaaS / serverless | run one function on demand, pay per call | AWS Lambda |

**Key points**
- Moving IaaS → PaaS → SaaS: less control, less maintenance.
- Course design question: "When is full OS control needed (EC2) versus a managed runtime?"
- Architecture patterns this week: decoupled compute and storage, microservices, event-driven data flows.

**Memorize vs. look up:** Memorize the four models with one AWS example each.

Related: [[Object Storage]], [[Managed Databases]], [[Serverless Computing]], [[Cloud Economics and Elasticity]]
