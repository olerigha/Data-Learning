---
course: CDE
week: 3
source: "[[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Normalization
**In one line:** Split tables so each fact is stored in exactly one place, which removes duplicate data and update mistakes.

**In plain words:** If an office's phone number is copied onto every employee row, changing it means updating many rows, and missing one makes the data disagree. Normalization fixes this step by step. Make every cell hold one value (1NF). Make every column depend on the *whole* key (2NF). Make non-key columns depend only on the key, not on each other (3NF). The cost is more tables and more joins.

**Terms**
| Term | Means |
|---|---|
| UNF | unnormalized: repeating groups, multi-value cells, no key |
| Anomaly | insert / update / delete problem caused by duplicated data |
| Atomic | one single value per cell |
| Functional dependency | A determines B (knowing A tells you B) |
| Partial dependency | a column depends on only *part* of a composite key |
| Transitive dependency | key → non-key A → non-key B |

**Key points**
- **1NF:** unique rows, atomic values, no repeating groups.
- **2NF:** 1NF + no partial dependencies.
  In words: every non-key column needs the whole key, not just part of it.
- **3NF:** 2NF + no transitive dependencies.
  In words: non-key columns depend on the key, and nothing but the key.
- Fix at each step: move the offending columns to a new table with a copy of the column they depend on.
- Trade-off: great for OLTP (writes); warehouses often *denormalize* for fast reads.

**Example:** Employees(empNo, name, officeCode, officeCity) → officeCity depends on officeCode (transitive), so move it to Offices(officeCode, city).

**Memorize vs. look up:** Memorize what 1NF, 2NF and 3NF each remove.

Related: [[Database Keys]], [[Entities, Relationships and Cardinality]], [[OLTP vs OLAP]], [[Star vs Snowflake Schema]]
