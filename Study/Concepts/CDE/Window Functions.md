---
course: CDE
week: 4
source: "[[SQL-4.7-Windows.sql]]"
status: new
tags: [generated]
---
# Window Functions
**In one line:** Calculate across related rows (ranks, running totals, group averages) while keeping every row.

**In plain words:** GROUP BY squashes each group into one row. A window function does the group calculation but writes the answer next to *every* row. So you can show each order alongside its customer's average, or rank customers by total spend, without losing detail. `OVER(...)` defines the window: `PARTITION BY` splits into groups, `ORDER BY` sets the order inside each group.

**Terms**
| Term | Means |
|---|---|
| OVER() | marks a window function and defines its window |
| PARTITION BY | split rows into groups (like GROUP BY, without collapsing) |
| ORDER BY (inside OVER) | order within each group, needed for ranks and running totals |
| ROW_NUMBER() | 1, 2, 3… no ties |
| RANK() | ties share a rank, then skip (1, 1, 3) |
| DENSE_RANK() | ties share a rank, no skip (1, 1, 2) |
| LAG() / LEAD() | value from the previous / next row |

**Key points**
```sql
SELECT productName, productLine, buyPrice,
       AVG(buyPrice) OVER (PARTITION BY productLine) AS line_avg
FROM products;
```
In words: show every product with the average price of its product line beside it.
- Running total: `SUM(amount) OVER (ORDER BY paymentDate)`.
- Month-over-month change: `amount - LAG(amount) OVER (ORDER BY month)`.

**Memorize vs. look up:** Memorize PARTITION BY vs GROUP BY and RANK vs DENSE_RANK.

Related: [[GROUP BY and HAVING]], [[Subqueries and CTEs]], [[Fact and Dimension Tables]]
