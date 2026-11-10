---
course: CDE
week: 3
source: "[[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Database Management System
**In one line:** The software that stores, protects and serves a shared collection of related data.

**In plain words:** A database is an organized collection of data about real things (students, courses, orders). The DBMS is the software around it. It answers queries quickly, lets many people use the data at once without clashing, recovers after crashes, and enforces rules so the data stays correct. A relational DBMS stores everything as tables linked by keys and is queried with SQL.

**Terms**
| Term | Means |
|---|---|
| DBMS / RDBMS | (Relational) Database Management System, e.g. MySQL, PostgreSQL |
| Table / relation | rows (tuples) and columns (attributes) |
| Schema-on-write | the table structure must exist before data is loaded |
| Query processor | turns your SQL into efficient steps |
| Transaction manager | keeps multi-step changes safe (ACID) |
| Codd | E.F. Codd invented the relational model (1970) |

**Key points**
- Benefits: program–data independence, fast retrieval, concurrent access and crash recovery, less duplication, integrity and security.
- Three parts inside: query processor, transaction manager, storage/memory manager.
- History: flat files → network model → relational (1970s) → warehouses → NoSQL → cloud databases.
- Classification: operational (OLTP) vs analytical (OLAP); relational vs document, key-value, column, graph.

**Memorize vs. look up:** Memorize what a DBMS does for you and what "relational" means.

Related: [[Conceptual, Logical and Physical Models]], [[Database Keys]], [[ACID Transactions]], [[OLTP vs OLAP]], [[Managed Databases]]
