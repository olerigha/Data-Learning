---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]], [[Sakila-Snowflake-ERD.pdf]]"
status: new
tags: [generated]
---
# Star vs Snowflake Schema
**In one line:** Star = one flat table per dimension around the fact; snowflake = dimensions split further into sub-tables.

**In plain words:** In a star schema the fact table sits in the middle, and each dimension is one wide table, even if that repeats data (Product includes its category and brand). Queries need few joins, so they're fast and simple. A snowflake schema normalizes those dimensions (Product → Category → Department), which saves space but adds joins. Warehouses usually prefer star.

**Terms**
| Term | Means |
|---|---|
| Star schema | fact + denormalized dimension tables |
| Snowflake schema | fact + normalized, multi-level dimension tables |
| Dimension hierarchy | levels like Year → Quarter → Month → Day, or Region → Country → City |
| Junk dimension | one table holding several low-value flags |

**Key points**
- Star: fewer joins, faster BI queries, some repeated values (on purpose).
- Snowflake: less redundancy, more joins, more complex SQL.
- Course examples: ClassicModels star schema; Sakila star and Sakila snowflake ERDs.
- Exercise: ETL from the ClassicModels ER model into its dimensional model.

**Memorize vs. look up:** Memorize the difference and why warehouses favor star.

Related: [[Fact and Dimension Tables]], [[Normalization]], [[Slowly Changing Dimensions]]
