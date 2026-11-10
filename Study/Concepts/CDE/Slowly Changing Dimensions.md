---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# Slowly Changing Dimensions
**In one line:** Rules for what to do when a dimension value changes, like a customer moving cities: overwrite it, add a new row, or keep a "previous" column.

**In plain words:** Dimension details change occasionally. If a customer moves from Boston to Chicago, do old sales count toward Boston or Chicago? **Type 1** overwrites, so history is lost (fine for fixing typos). **Type 2** adds a new row with a new surrogate key and date range, so old sales stay with Boston and new ones go to Chicago. **Type 3** keeps "previous" and "current" columns, giving one step of history.

**Terms**
| Term | Means |
|---|---|
| SCD | Slowly Changing Dimension |
| Type 1 | overwrite; no history |
| Type 2 | new row per change; full history |
| Type 3 | previous + current columns; limited history |
| Surrogate key | system-made ID, so one customer can have several dimension rows |
| Effective dates / current flag | columns showing when a row was valid and whether it's current |

**Key points**
- Type 1: simplest; use for error corrections.
- Type 2: most common when history matters. Needs `valid_from`, `valid_to`, `is_current`.
- Type 3: only when a fixed, small number of changes is expected.
- Warehouse lab compares Type 1 vs Type 2.

**Memorize vs. look up:** Memorize all three types and when to use each.

Related: [[Fact and Dimension Tables]], [[Database Keys]], [[Star vs Snowflake Schema]]
