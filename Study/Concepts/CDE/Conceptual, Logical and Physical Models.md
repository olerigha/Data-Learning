---
course: CDE
week: 3
source: "[[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Conceptual, Logical and Physical Models
**In one line:** Design a database in three passes: big picture → tables and keys → real implementation details.

**In plain words:** First sketch what things exist and how they relate ("customers place orders"), without worrying about software. Then turn that into tables, columns, keys and normalization. Finally pick the actual data types, indexes and storage for a specific product like MySQL. Each pass adds detail. Getting the design right early saves years of painful migrations.

**Terms**
| Term | Means |
|---|---|
| Conceptual model | entities and relationships only (an ER diagram) |
| Logical model | tables, columns, primary/foreign keys, normalized |
| Physical model | data types, indexes, partitions, storage engine |
| ER diagram (ERD) | entity-relationship diagram |
| Schema | the actual implementation of the model in a DBMS |
| Forward / reverse engineer | generate tables from a diagram / a diagram from existing tables |

**Key points**
- Design process: requirements → conceptual → logical → physical → iterate with stakeholders.
- Conceptual ignores hardware and software; logical is software-specific but ignores hardware; physical depends on both.
- Logical design steps: entities → tables, relationships → foreign keys, attributes → columns.
- Labs: build ClassicModels from a SQL script; reverse- and forward-engineer the ERD in MySQL Workbench.

**Memorize vs. look up:** Memorize what each level contains.

Related: [[Entities, Relationships and Cardinality]], [[Database Keys]], [[Normalization]], [[Indexing, Partitioning and EXPLAIN]]
