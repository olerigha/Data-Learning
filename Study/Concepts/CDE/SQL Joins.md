---
course: CDE
week: 3
source: "[[SQL-3.4-Joins.sql]]"
status: new
tags: [generated]
---
# SQL Joins
**In one line:** Combine rows from two tables by matching a shared column, usually a foreign key to a primary key.

**In plain words:** Normalized data is spread across tables, so to answer "which customer placed which order" you glue the tables back together on the matching key. The join type decides what happens to rows with no match: drop them (inner), or keep them from one side with blanks for the other (left/right).

**Terms**
| Term | Means |
|---|---|
| INNER JOIN | only rows that match in **both** tables |
| LEFT JOIN | all rows from the left table + matches from the right (else NULL) |
| RIGHT JOIN | all rows from the right table + matches from the left |
| FULL JOIN | all rows from both (MySQL lacks it; use UNION of left and right) |
| CROSS JOIN | every combination (Cartesian product) |
| Self-join | a table joined to itself (employee → manager) |
| Alias | short name for a table: `customers c` |

**Key points**
```sql
SELECT c.customerName, o.orderNumber
FROM customers c
INNER JOIN orders o ON c.customerNumber = o.customerNumber;
```
In words: for each customer, list their orders, matching on customer number. Customers with no orders are dropped.
- Swap to `LEFT JOIN` to keep customers with no orders (their `orderNumber` is NULL).
- Finding "customers with no orders" = LEFT JOIN, then `WHERE o.orderNumber IS NULL`.

**Memorize vs. look up:** Memorize inner vs left and the "find missing" pattern.

Related: [[Database Keys]], [[GROUP BY and HAVING]], [[Subqueries and CTEs]], [[Entities, Relationships and Cardinality]]
