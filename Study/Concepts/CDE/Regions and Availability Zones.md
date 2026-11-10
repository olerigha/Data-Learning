---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Regions and Availability Zones
**In one line:** Cloud infrastructure is nested (region → availability zone → data center → rack), and each level is a separate failure domain.

**In plain words:** A region is a geographic area like `us-east-1`. Inside it are several availability zones (AZs): isolated data centers with their own power and cooling. If one AZ fails, the others keep going, so spreading your app across AZs protects it. A fault at a lower level (a single rack) takes down everything on that rack. That "blast radius" is what your redundancy plan has to survive.

**Terms**
| Term | Means |
|---|---|
| Region | geographic area with 3+ AZs (e.g. `us-east-1`) |
| Availability zone (AZ) | isolated data center(s) in a region (e.g. `us-east-1a`) |
| Failure domain | a unit that can fail together |
| Blast radius | how much breaks when one component fails |
| Data residency | legal requirement to keep data in a certain country or region |

**Key points**
- Region → AZ → data center → rack → hosts. Each layer has a different failure domain and SLA.
- Deploy across multiple AZs for high availability.
- Choose regions for latency (near users) and data residency (laws).

**Memorize vs. look up:** Memorize region vs AZ and why you use several AZs.

Related: [[Cloud Economics and Elasticity]], [[Well-Architected Framework]], [[Load Balancing]], [[Data Governance and Lineage]]
