---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# Inmon vs Kimball
**In one line:** Two ways to build a data warehouse: one big integrated warehouse first (Inmon), or department-sized marts first (Kimball).

**In plain words:** An enterprise data warehouse (EDW) pulls data from all operational systems into one place for analysis. Inmon says build that central, normalized warehouse first, then carve out marts for each department. Kimball says start with dimensional marts that answer real questions now, and connect them later through shared dimensions. Modern ELT pipelines (bronze/silver/gold) borrow from both.

**Terms**
| Term | Means |
|---|---|
| EDW | Enterprise Data Warehouse |
| Data mart | smaller warehouse for one department (Finance, Marketing) |
| Data cube | multi-dimensional summary for slicing (product × region × month) |
| Top-down / bottom-up | Inmon / Kimball |
| ETL / ELT | transform before loading / load raw first, transform inside the warehouse |
| Metadata repository | catalog of what's in the warehouse and how it's structured |

**Key points**
- EDW traits: subject-oriented, integrated, time-variant (snapshots over time), non-volatile (not edited once loaded).
- **Inmon:** consistent across the company; slower to deliver.
- **Kimball:** faster value for specific questions; risk of "mart sprawl".
- Pipeline: operational DBs → ETL → EDW → marts / cubes → BI users.

**Memorize vs. look up:** Memorize top-down vs bottom-up and one pro/con each.

Related: [[OLTP vs OLAP]], [[Fact and Dimension Tables]], [[Medallion Architecture]], [[Data Lakehouse]]
