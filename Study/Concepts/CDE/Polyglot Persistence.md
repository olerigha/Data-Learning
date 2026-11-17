---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]]"
status: new
tags: [generated]
---
# Polyglot Persistence
**In one line:** Use a different database for each workload (relational, document, key-value, graph), chosen by its access pattern.

**In plain words:** No database is best at everything. Orders that need transactions and joins belong in a relational database. A product catalog whose fields keep changing fits a document store. Session caches and lookups by ID fit a key-value store. "Who knows whom" questions fit a graph. Most real systems need more than one, so they use several side by side. NoSQL design starts from the queries you'll run, not from the entities.

**Terms**
| Term | Means |
|---|---|
| Polyglot persistence | several database types in one system |
| Access pattern | the shape and frequency of the queries you'll run |
| Sharding | splitting data across machines by key |

**Key points**
- **Decision guide:**
  - Strong consistency + multi-table joins (transactions matter) → **relational** (PostgreSQL, MySQL, RDS).
  - Flexible nested schema, high writes, schema changes often → **document** (MongoDB, Firestore).
  - Many-to-many, deep traversals (relationships are the data) → **graph** (Neo4j, Neptune).
  - Lookups by key at huge scale → **key-value** (DynamoDB, Redis).
- **Comparison:**

| | Relational | DynamoDB | MongoDB | Neo4j |
|---|---|---|---|---|
| Consistency | strong (ACID) | eventual by default | tunable | ACID |
| Modeling | normalized, joins | denormalized by access pattern | embed or reference | nodes and relationships |
| Queries | SQL joins | key lookups | `find()`, aggregation | Cypher patterns |
| Scaling | mostly vertical | serverless, automatic | sharding | less horizontal |

**Memorize vs. look up:** Memorize the decision guide.

Related: [[NoSQL and the CAP Theorem]], [[DynamoDB Key Design]], [[Document Databases]], [[Graph Databases and Cypher]], [[OLTP vs OLAP]]
