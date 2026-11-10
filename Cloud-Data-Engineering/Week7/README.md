# Week 7: NoSQL and Graph Models

## Overview

This week covers non-relational data modeling paradigms: key-value/wide-column stores, document stores, and property graph databases. It explores schema flexibility, denormalization, partition keys, secondary indexes, consistency models, and traversal query languages.

## Outcome

Model representative access patterns across DynamoDB, MongoDB, and Neo4j, analyze operational and query tradeoffs, and evaluate when non-relational stores are preferable to traditional relational systems.

## Labs

- **Amazon DynamoDB** (`dynamodb/`) — single-table design and key-value/wide-column access patterns:
  - `AWS-DynamoDB-Orders.ipynb`: Designing composite partition and sort keys for fast point lookups and range queries.
  - `AWS-DynamoDB-Customers.ipynb`: Secondary indexing with Global Secondary Indexes (GSIs).
  - `AWS-DynamoDB-MLInferences.ipynb`: High-throughput time-series ingestion and TTL (Time-to-Live) management.
- **MongoDB** (`mongodb/`) — document store modeling:
  - Document modeling: embedding related records vs. referencing (`$lookup`).
  - Schema validation with JSON Schema.
  - Indexing compound fields, multi-key indexes, and geospatial proximity and polygon queries with Folium mapping (`MongoDB-Python-Restaurants.ipynb`).
  - Google Cloud Datastore comparison (`DataStore-Python-Restaurants.ipynb`).
- **Neo4j** (`neo4j/`) — property graph modeling:
  - Modeling entities as nodes, properties as attributes, and relationships as directed, labeled edges.
  - Writing graph traversal queries using Cypher (`MATCH`, `WHERE`, `RETURN`).
  - Path-finding, graph algorithms, and network visualization with NetworkX (`Neo4j-Friends.ipynb`, `Neo4j-Py2Neo.ipynb`).

## Database Model Comparison

| Paradigm | Database | Primary Access Pattern | Data Modeling Strategy | Consistency Model |
|---|---|---|---|---|
| **Key-Value / Wide-Column** | Amazon DynamoDB | High-throughput, predictable O(1) lookups by key | Single-table design, denormalization, partition + sort keys | Tunable (Eventual vs. Strong) |
| **Document Store** | MongoDB | Flexible hierarchical records, polymorphic schemas | JSON/BSON documents, embedding vs. referencing | Tunable read/write concerns |
| **Property Graph** | Neo4j | Deep multi-hop relationship traversals, pattern matching | Nodes, typed relationships, graph properties | ACID transactional |

## Assessment Milestones

- **Quiz 6:** DynamoDB partition keys, GSI costs, document embedding vs. referencing, JSON Schema validation, Cypher traversal syntax, and CAP theorem tradeoffs.

## Submission

Include database initialization and seed scripts, index definitions, representative query code and execution outputs, performance measurements, and a comparative tradeoff analysis.
