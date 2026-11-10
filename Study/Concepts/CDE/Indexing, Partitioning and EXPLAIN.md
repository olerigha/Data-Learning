---
course: CDE
week: 4
source: "[[SQL-4.5-Index.sql]], [[SQL-4.12-Partitioning.sql]], [[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Indexing, Partitioning and EXPLAIN
**In one line:** Make queries fast with an index (a lookup shortcut) or partitions (split a big table into pieces), and check with EXPLAIN.

**In plain words:** Without an index, finding customers in Boston means reading every row (a full table scan). An index is like a book's index: jump straight to the right rows. It speeds up reads but slows down writes a little, because the index must be updated too. Partitioning splits a huge table into chunks (e.g. by date), so a query only reads the chunks it needs, and old chunks can be dropped in one step. `EXPLAIN` shows the database's plan, so you can see whether it scans or uses an index.

**Terms**
| Term | Means |
|---|---|
| Full table scan | reading every row |
| Index (B-tree) | sorted lookup structure on chosen column(s) |
| Clustered index | the table itself is stored in index order (one per table) |
| Non-clustered index | separate structure pointing to rows |
| Range partitioning | split by value ranges (e.g. by year) using `VALUES LESS THAN` |
| Hash partitioning | spread rows evenly by a hash of a key |
| EXPLAIN / EXPLAIN ANALYZE | show the query plan / run it and show real timings |

**Key points**
```sql
CREATE INDEX idx_city ON customers(city);
EXPLAIN SELECT * FROM customers WHERE city = 'Boston';
```
In words: build a shortcut on city, then confirm the query uses it instead of scanning.
- Index the columns used in WHERE, JOIN and ORDER BY.
- Partition time-series tables; you can truncate or drop an old partition instantly.
- Submission asks for EXPLAIN plans before and after indexing.

**Memorize vs. look up:** Memorize when to index and the read-vs-write trade-off.

Related: [[Conceptual, Logical and Physical Models]], [[OLTP vs OLAP]], [[SQL Joins]]
