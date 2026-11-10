---
course: CDE
week: 4
source: "[[SQL-4.3-Views.sql]]"
status: new
tags: [generated]
---
# Views and Materialized Views
**In one line:** A view is a saved query you can use like a table; a materialized view also saves the results.

**In plain words:** If you keep writing the same join, save it as a view and query it by name. A normal view stores only the query, so it re-runs every time and is always fresh. A materialized view stores the answer too: much faster to read, but it has to be refreshed when the data changes. Views also hide columns people shouldn't see.

**Terms**
| Term | Means |
|---|---|
| View | a named, stored SELECT; a "virtual table" |
| Materialized view | a view whose results are stored on disk |
| Refresh | recompute a materialized view's stored results |

**Key points**
```sql
CREATE VIEW basketValue AS
SELECT orderNumber, SUM(quantityOrdered * priceEach) AS total
FROM orderdetails GROUP BY orderNumber;
```
In words: save "total value per order" so others can just `SELECT * FROM basketValue`.
- Views can build on other views (e.g. `highestBasketValue` from `basketValue`).
- Uses: reuse logic, simplify the schema for users, restrict which columns they see.
- MySQL has no built-in materialized views; warehouses (BigQuery, Snowflake) do.

**Memorize vs. look up:** Memorize view vs materialized view (fresh vs fast).

Related: [[Subqueries and CTEs]], [[Stored Procedures]], [[KPIs and the Semantic Layer]]
