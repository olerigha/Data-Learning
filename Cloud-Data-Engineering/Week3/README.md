# Week 3: Relational Databases and Core SQL

## Overview

Week 3 covers relational data modeling, entity-relationship diagrams (ERDs), keys and integrity constraints, schema normalization (1NF, 2NF, 3NF), and core SQL queries (filtering, multi-table joins, aggregations, and grouping).

## Core Topics

1. **Relational Data Modeling & Normalization**
   - Entities, attributes, relationships (1:1, 1:N, N:M), and cardinality.
   - Primary keys, foreign keys, candidate keys, surrogate keys, and composite keys.
   - Normalization forms (1NF, 2NF, 3NF) to eliminate insertion, update, and deletion anomalies.
   - Entity-Relationship Diagrams (ERDs) and schema constraints.

2. **Core SQL Queries**
   - Filtering with `WHERE`, comparison operators, pattern matching (`LIKE`), and boolean logic.
   - Multi-table joins: `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and self-joins.
   - Aggregations (`COUNT`, `SUM`, `AVG`, `MIN`, `MAX`) combined with `GROUP BY` and `HAVING`.

## Labs

- **AWS RDS & Managed Databases**:
  - [AWS-RDS.ipynb](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week3/AWS-RDS.ipynb): Provisioning, connecting, and querying an Amazon RDS MySQL database from Python.
  - [AWS-MySQL.pdf](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week3/AWS-MySQL.pdf): Walkthrough guide for AWS RDS MySQL setup and Workbench connectivity.
- **Data Modeling** (`modeling/`) — entity identification, relationship mapping, primary and foreign key definitions, and ERD construction.
- **Foundational SQL** (`sql/`) — query design and execution:
  - Filtering, boolean logic, and string manipulations.
  - Multi-table relational joins with foreign key relationships.
  - Summary metrics and grouped aggregations.
- **Reference Solutions** (`solutions/`) — verified reference SQL scripts for query exercises.

## Assessment Milestones

- **Quiz 2:** Keys, normalization rules, ERD interpretation, join semantics, and aggregate calculations.

## Submission

Include conceptual, logical, and physical ERD diagrams, DDL schema scripts with integrity constraints, seed data scripts, and query execution outputs with row counts.
