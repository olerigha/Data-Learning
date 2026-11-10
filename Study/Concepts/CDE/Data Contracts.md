---
course: CDE
week: 6
source: "[[Week6-BusinessIntelligence.pdf]], [[governance-lab]]"
status: new
tags: [generated]
---
# Data Contracts
**In one line:** A written, versioned agreement between whoever produces a dataset and whoever uses it: columns, types, freshness and owner.

**In plain words:** Dashboards break when an upstream team renames a column without warning. A data contract writes the promise down ("this table has these columns of these types, refreshed by 6 am, owned by Sales Ops") in a file like `data-contract.yaml`. Automated checks enforce it, so a breaking change fails in testing instead of in production.

**Terms**
| Term | Means |
|---|---|
| Producer / consumer | team that publishes the data / team that uses it |
| Schema | column names and types |
| SLA / freshness | how up to date the data is promised to be |
| CI | continuous integration: automatic checks on every change |
| Versioning | contract v1 → v2 when something must change |

**Key points**
- A contract specifies: columns, types, semantics (what values mean), freshness, ownership.
- Enforced in CI, so breaking changes fail before release.
- Tools: dbt contracts, Great Expectations, Soda, Open Data Contract Standard.
- Lab evidence: `data-contract.yaml` plus a passing and a failing validation.

**Memorize vs. look up:** Memorize what a contract contains and why it's enforced in CI.

Related: [[Data Governance and Lineage]], [[Data Observability]], [[KPIs and the Semantic Layer]]
