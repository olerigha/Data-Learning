---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# Fact and Dimension Tables
**In one line:** Facts are the numbers you measure (sales $); dimensions are the who/what/when/where that describe them.

**In plain words:** A dimensional model has a central fact table with one row per business event (one line on a receipt). It holds the measures and keys pointing to the dimension tables (date, product, store, customer). To answer "sales by store by month", you sum the fact's measures and group by dimension columns. First decide the **grain**: exactly what one fact row means.

**Terms**
| Term | Means |
|---|---|
| Fact | measurable event: a sale, click or payment |
| Measure | numeric column in the fact table (sales $, units) |
| Dimension | descriptive context table (Date, Product, Store, Customer) |
| Grain | what one fact row represents |
| Additive / semi-additive / non-additive | can sum across everything / only some dimensions (balances) / never (ratios) |
| Date dimension | prebuilt calendar table: fiscal periods, holidays, weekend flags |
| Conformed dimension | shared by several fact tables (one Customer dimension everywhere) |

**Key points**
- Four-step design: **(1)** pick the business process → **(2)** declare the grain → **(3)** choose dimensions → **(4)** choose facts.
- Use the most atomic grain (e.g. one POS line item) so any later question can drill down.
- For ratios (gross margin), store the numerator and denominator, then compute the ratio of the sums, not the sum of the ratios.
- Other patterns: role-playing date (order / ship date), factless fact (attendance), aggregate tables.

**Example:** Retail POS: grain = one line item; dimensions = Date, Product, Store, Promotion; facts = quantity, sales $, cost $, gross profit.

**Memorize vs. look up:** Memorize fact vs dimension, grain, and the four steps.

Related: [[Star vs Snowflake Schema]], [[Slowly Changing Dimensions]], [[OLTP vs OLAP]], [[KPIs and the Semantic Layer]]
