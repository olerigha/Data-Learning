---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]]"
status: new
tags: [generated]
---
# NoSQL and the CAP Theorem
**In one line:** NoSQL ("Not Only SQL") databases give up some consistency to gain scale and flexible schemas; the CAP theorem says a distributed system can only guarantee two of consistency, availability and partition tolerance.

**In plain words:** Relational databases struggle with huge scale, changing schemas and semi-structured data. NoSQL databases (key-value, document, wide-column, graph) are built to scale out across many machines with flexible structure. The price: when machines can't talk to each other, you must choose between always answering (availability) and always giving the latest data (consistency). Many NoSQL systems choose to answer and catch up later, which is called "eventual consistency". NoSQL doesn't replace relational; each has its uses.

**Terms**
| Term | Means |
|---|---|
| NoSQL | "Not Only SQL": non-relational databases |
| Consistency (C) | every client sees the same, latest data |
| Availability (A) | every request gets a response |
| Partition tolerance (P) | the system keeps working when messages between machines are lost |
| CA / CP / AP | which two of the three a system guarantees |
| ACID | Atomicity, Consistency, Isolation, Durability: strict (relational) |
| BASE | Basically Available, Soft state, Eventual consistency (NoSQL) |
| Eventual consistency | given time, all copies converge to the same value |

**Key points**
- Design goals of NoSQL: horizontal scalability, flexible schema, high availability.
- Four families: **key-value**, **document**, **wide-column**, **graph**.
- In real networks partitions happen, so the practical choice is usually CP vs AP.
- Strong consistency is still possible in some NoSQL systems (Spanner; Cosmos DB at its strong level).
- Choose the consistency model from business needs, not the database's default.

**Memorize vs. look up:** Memorize the C, A and P definitions, "pick two", and ACID vs BASE.

Related: [[Key-Value and Wide-Column Stores]], [[Document Databases]], [[Graph Databases and Cypher]], [[Polyglot Persistence]], [[ACID Transactions]]
