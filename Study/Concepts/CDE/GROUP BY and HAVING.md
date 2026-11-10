---
course: CDE
week: 3
source: "[[SQL-3.3-GroupBy.sql]]"
status: new
tags: [generated]
---
# GROUP BY and HAVING
**In one line:** Collapse rows into groups and compute totals per group; HAVING filters the groups afterwards.

**In plain words:** `GROUP BY country` puts all rows for each country into one bucket. Then aggregate functions (COUNT, SUM, AVG, MIN, MAX) give one number per bucket. `WHERE` filters individual rows *before* grouping; `HAVING` filters the finished groups *after*. `ORDER BY` sorts and `LIMIT` caps the output.

**Terms**
| Term | Means |
|---|---|
| Aggregate | COUNT, SUM, AVG, MIN, MAX: many rows → one value |
| GROUP BY | one output row per distinct value (or combination) |
| WHERE | row filter, before grouping |
| HAVING | group filter, after grouping |
| ORDER BY … ASC/DESC | sort the result |
| LIMIT n | return only the first n rows |

**Key points**
```sql
SELECT country, COUNT(*) AS n
FROM customers
WHERE creditLimit > 0
GROUP BY country
HAVING COUNT(*) >= 5
ORDER BY n DESC;
```
In words: count customers with credit per country, keep countries with at least 5, biggest first.
- Order SQL *runs* in: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT.
- Every selected column must be grouped or aggregated.

**Memorize vs. look up:** Memorize WHERE vs HAVING and the run order.

Related: [[SQL Joins]], [[Window Functions]], [[Subqueries and CTEs]]
