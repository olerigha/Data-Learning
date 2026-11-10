---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# OLTP vs OLAP
**In one line:** OLTP databases run the business day to day; OLAP systems analyze its history.

**In plain words:** The store's checkout system records each sale as it happens: many tiny, fast writes. That's OLTP. Managers asking "sales by region by month for 3 years" need huge read-only scans over history. That's OLAP. One database can't be tuned well for both, so data is copied from OLTP systems into a separate analytical warehouse.

**Terms**
| Term | Means |
|---|---|
| OLTP | Online Transaction Processing: operational, current data, many small updates |
| OLAP | Online Analytical Processing: reporting / BI, large historical reads |
| Normalized | split into many tables (good for writes) |
| Denormalized | fewer, wider tables (good for reads) |
| Subject-oriented | organized around business topics (sales), not apps |

**Key points**
| | OLTP | OLAP |
|---|---|---|
| Purpose | run operations | analysis, BI |
| Data | current | current + historical |
| Size | < 100 GB typical | > 100 GB |
| Model | ER, normalized | dimensional, denormalized |
| Organized by | application | subject |
- The warehouse becomes the "single source of truth": subject-oriented, non-volatile, historical.

**Memorize vs. look up:** Memorize the table above.

Related: [[Normalization]], [[Inmon vs Kimball]], [[Fact and Dimension Tables]], [[Database Management System]]
