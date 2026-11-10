---
course: CDE
week: 6
source: "[[Week6-BusinessIntelligence.pdf]]"
status: new
tags: [generated]
---
# KPIs and the Semantic Layer
**In one line:** KPIs are the few metrics that track key goals; the semantic layer defines each metric once so every tool shows the same number.

**In plain words:** A metric is any business measure. A KPI is a metric tied directly to an objective, with a target. When two teams compute "revenue" differently, meetings turn into arguments about whose number is right. The semantic (metrics) layer sits between the warehouse and the BI tools and holds one official definition of each metric, plus access rules. Every dashboard, notebook and spreadsheet then pulls from it.

**Terms**
| Term | Means |
|---|---|
| Metric | quantifiable measure of a business process |
| KPI | Key Performance Indicator: a metric tied to a key objective |
| SMART | Specific, Measurable, Attainable, Relevant, Time-bound |
| Semantic / metrics layer | shared business definitions on top of raw tables (dbt Semantic Layer, Looker, Cube) |
| Row-level security | users see only the rows they're allowed to |
| Glossary | shared definitions of business terms |

**Key points**
- Every KPI should map to a business outcome and pass the SMART check.
- Metric examples: marketing (incremental sales), sales (avg purchase value), finance (current ratio), HR (attrition rate).
- Put row-level security in the semantic layer, not in each app.
- Decision-makers need 3–5 KPIs, not 50 charts.

**Memorize vs. look up:** Memorize metric vs KPI, SMART, and why a semantic layer exists.

Related: [[BI vs Standard Reporting]], [[Dashboard Design Principles]], [[Views and Materialized Views]], [[Data Contracts]]
