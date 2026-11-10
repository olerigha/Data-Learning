---
course: CDE
week: 4
source: "[[SQL-4.1-SubQueries.sql]], [[SQL-4.2-CTEs.sql]]"
status: new
tags: [generated]
---
# Subqueries and CTEs
**In one line:** Use the result of one query inside another, either nested inline (subquery) or named up front (CTE).

**In plain words:** "Which payments are above average?" needs two steps: find the average, then filter. A subquery puts step 1 inside step 2's parentheses. A CTE (`WITH name AS (...)`) gives step 1 a name at the top so the main query reads like a recipe. Same result; CTEs are easier to read when there are several steps.

**Terms**
| Term | Means |
|---|---|
| Subquery | a SELECT nested inside another statement |
| Scalar subquery | returns one value (e.g. the average) |
| Correlated subquery | re-runs for each outer row, using that row's values |
| IN / NOT IN | is the value in the subquery's list? |
| EXISTS / NOT EXISTS | does the subquery return any row? (true/false) |
| CTE | Common Table Expression: a named temporary result inside one statement |

**Key points**
```sql
SELECT * FROM payments
WHERE amount > (SELECT AVG(amount) FROM payments);
```
In words: keep payments bigger than the overall average payment.
```sql
WITH avg_pay AS (SELECT AVG(amount) AS a FROM payments)
SELECT p.* FROM payments p, avg_pay WHERE p.amount > avg_pay.a;
```
In words: same thing, but the average gets a name first.
- Customers with no orders: `WHERE customerNumber NOT IN (SELECT customerNumber FROM orders)`.
- Subqueries can sit in SELECT, FROM or WHERE.

**Memorize vs. look up:** Memorize the scalar-subquery pattern and the `WITH` shape.

Related: [[SQL Joins]], [[GROUP BY and HAVING]], [[Window Functions]], [[Views and Materialized Views]]
