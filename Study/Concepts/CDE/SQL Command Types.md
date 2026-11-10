---
course: CDE
week: 3
source: "[[SQL-Reference.pdf]]"
status: new
tags: [generated]
---
# SQL Command Types
**In one line:** SQL commands come in four families: define structure (DDL), work with rows (DML), control access (DCL), and control transactions (TCL).

**In plain words:** Some commands build or change the *shape* of the database (create a table, add a column). Others read and change the *rows* inside it. A third group decides *who* may do what, and the last group decides when changes become permanent. The important gotcha: structure changes (DDL) usually save immediately and can't be rolled back, but row changes (DML) can be wrapped in a transaction.

**Terms**
| Family | Commands | Does |
|---|---|---|
| DDL (Data Definition) | CREATE, ALTER, DROP, TRUNCATE, RENAME, COMMENT | defines or changes tables, columns, constraints, indexes |
| DML (Data Manipulation) | SELECT, INSERT, UPDATE, DELETE, MERGE (+ DESCRIBE, EXPLAIN) | reads and writes rows |
| DCL (Data Control) | GRANT, REVOKE | gives or removes privileges |
| TCL (Transaction Control) | COMMIT, ROLLBACK, SAVEPOINT, SET TRANSACTION | makes changes permanent or undoes them |
| CRUD | Create, Read, Update, Delete | = INSERT, SELECT, UPDATE, DELETE |

**Key points**
- DDL auto-commits in most engines, so it's hard or impossible to undo. DML participates in transactions.
- `DELETE` with no `WHERE` removes **all** rows. `TRUNCATE` empties the table but keeps its structure.
- `GRANT SELECT ON customers TO report_user;`
  In words: let the reporting user read the table, and nothing more (least privilege).
- **Data types (MySQL):**
  - Strings: `CHAR(n)` fixed length (e.g. `CHAR(2)` for "IL"), `VARCHAR(n)` variable length, `BLOB` binary.
  - Integers: `TINYINT` (1 byte) … `INT` (4) … `BIGINT` (8).
  - Decimals: `DECIMAL(M,D)` is **exact** (use for money; `DECIMAL(5,2)` = −999.99 to 999.99); `FLOAT` and `DOUBLE` are approximate.
  - Dates: `DATE`, `TIME`, `DATETIME`, `TIMESTAMP`, `YEAR`.

**Memorize vs. look up:** Memorize the four families, "DDL auto-commits", and DECIMAL for money. Look up type sizes.

Related: [[ACID Transactions]], [[Stored Procedures]], [[Database Keys]], [[SQL Joins]], [[VPC and IAM Least Privilege]]
