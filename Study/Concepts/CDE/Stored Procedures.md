---
course: CDE
week: 4
source: "[[SQL-4.9-Procedures.sql]], [[SQL-4.8-Variables.sql]]"
status: new
tags: [generated]
---
# Stored Procedures
**In one line:** Named blocks of SQL logic saved inside the database and run with `CALL`, optionally with inputs.

**In plain words:** Instead of every app re-sending the same multi-step SQL, you save it in the database once as a procedure, like a function. Apps call it by name and can pass parameters (e.g. a customer number). Procedures can use variables and IF logic. Triggers are procedures that run automatically when rows are inserted, updated or deleted.

**Terms**
| Term | Means |
|---|---|
| Stored procedure | saved SQL routine, run with `CALL name(args)` |
| Parameter (IN / OUT) | value passed in / returned |
| Variable | `SET @x = ...` holds a value during a session or procedure |
| Trigger | code that fires automatically on INSERT / UPDATE / DELETE |
| DELIMITER | MySQL trick to change `;` so a procedure body can contain `;` |

**Key points**
```sql
CALL get_order_by_cust(141, @shipped, @canceled, @resolved, @disputed);
```
In words: run the saved routine for customer 141; it fills four OUT variables with that customer's order counts by status.
- `CALL GetAllProducts();` is the no-parameter version: it returns all 110 products.
- Keeps business logic in one place, and lets you grant "can run this" without "can read the tables".
- Downside: logic hidden in the database is harder to version and test than app code.

**Memorize vs. look up:** Memorize what procedures and triggers are for. Look up the CREATE syntax.

Related: [[Views and Materialized Views]], [[ACID Transactions]], [[SQL from Python]]
