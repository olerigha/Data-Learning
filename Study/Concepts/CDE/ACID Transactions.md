---
course: CDE
week: 4
source: "[[SQL-4.10-Transactions.sql]]"
status: new
tags: [generated]
---
# ACID Transactions
**In one line:** Group several changes so they all happen or none do: `START TRANSACTION` … `COMMIT` or `ROLLBACK`.

**In plain words:** Moving money means subtracting from one account *and* adding to another. If the system crashes between the two, money vanishes. A transaction wraps both steps: either everything is saved (COMMIT) or everything is undone (ROLLBACK). ACID is the four promises a database makes about transactions.

**Terms**
| Term | Means |
|---|---|
| Atomicity | all or nothing |
| Consistency | rules (keys, constraints) still hold afterwards |
| Isolation | concurrent transactions don't see each other's half-done work |
| Durability | once committed, it survives crashes |
| COMMIT | make the changes permanent |
| ROLLBACK | undo everything since START TRANSACTION |
| Autocommit | MySQL default: each statement commits on its own |

**Key points**
```sql
START TRANSACTION;
INSERT INTO offices VALUES (...);
ROLLBACK;   -- new office disappears
```
In words: try a change, look at it, then undo it as if it never happened.
- Lab: insert offices, ROLLBACK (gone), insert again, COMMIT (kept).
- Pipelines use transactions so a failed load leaves no half-written data.
- Isolation levels (how strict "isolation" is) are on Quiz 3.

**Memorize vs. look up:** Memorize the four ACID letters and COMMIT vs ROLLBACK.

Related: [[Database Management System]], [[SQL from Python]], [[Idempotent Pipelines]], [[Data Lakehouse]]
