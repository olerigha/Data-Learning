---
course: CDE
week: 6
source: "[[Week6-BusinessIntelligence.pdf]], [[governance-lab]]"
status: new
tags: [generated]
---
# Data Governance and Lineage
**In one line:** The ongoing rules and roles for who owns data, where it came from, how sensitive it is, and who may use it.

**In plain words:** Without governance, nobody knows which table is right, who owns it, or whether it holds private data, and the data becomes a risk instead of an asset. Governance is a handoff chain. The producer registers the dataset and documents its source. A steward tags its sensitivity and sets rules (retention, masking). Consumers get least-privilege access, and their use is logged. Lineage tracks every step data took from source to dashboard.

**Terms**
| Term | Means |
|---|---|
| Provenance | origin and history of the data: source, time, transformations |
| Lineage | map of data flow: source → ingest → clean → join → aggregate → report |
| Metadata | data about data: technical, business, operational |
| Data catalog | searchable inventory of datasets and owners |
| Classification | Public / Internal / Confidential / Restricted |
| PII | personally identifiable information |
| Data steward | domain expert who defines and enforces quality for their data |
| GDPR / CCPA / HIPAA / FERPA | privacy laws: EU / California / US health / US student records |

**Key points**
- Lineage answers: where did this come from, what touched it, who uses it? That enables impact analysis, debugging and compliance.
- Classify at the column level; re-check when data is joined or derived.
- Engineers implement the laws: data residency, retention, deletion on request, access logs.
- Responsible use: minimize what you collect; anonymization ≠ pseudonymization; check for bias.
- Lab: catalog entry, field classification, data contract, lineage, an observability rule, an AI-use record.

**Memorize vs. look up:** Memorize provenance vs lineage, the four classification levels, and the steward role. Look up regulation details.

Related: [[Data Contracts]], [[Data Observability]], [[Data Lakehouse]], [[VPC and IAM Least Privilege]], [[Data Engineering Lifecycle]]
