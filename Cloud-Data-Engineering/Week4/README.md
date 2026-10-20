# Week 4: Advanced SQL and Data Pipelines

## Overview

Week 4 covers advanced SQL techniques, Common Table Expressions (CTEs), subqueries, database views, window functions, stored procedures, ACID transactions, table indexing, query execution plans, SQL in Python, and pipeline engineering design.

## Core Topics

1. **Advanced SQL & Analytical Querying**
   - Subqueries (scalar, column, row, correlated) and subqueries in `FROM`/`WHERE`.
   - Common Table Expressions (`WITH` clauses) for modular and readable query pipelines.
   - Analytical window functions (`ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LEAD()`, `LAG()`, running totals).
   - Database views and materialized views.
   - Stored procedures, variables, and procedural logic.

2. **Database Administration & Performance Tuning**
   - ACID transactions: `START TRANSACTION`, `COMMIT`, and `ROLLBACK` for multi-step write safety.
   - Table partitioning and B-tree indexing strategies.
   - Query observability with `EXPLAIN` and `EXPLAIN ANALYZE`.

3. **SQL in Python & Pipeline Design**
   - Connecting Python to relational databases using SQLAlchemy and parameterized execution.
   - Pipeline configuration management, structured logging, and failure handling.

## Labs

- **Advanced SQL** (`sql/`) — subqueries, CTEs, views, stored procedures, window functions, transactions, and partitioning.
- **Query Exercises** (`exercises/`) — structured problem sets testing advanced query formulation and analytical aggregation.
- **Python Database Integration** (`python/`):
  - `PythonMySQL.ipynb`: Connecting Python to relational databases with SQLAlchemy and connection pooling.
- **Pipeline Engineering Suite** (`pipeline/`) — production data pipelines and engineering practices:
  - `config.yaml`: Externalized configuration managing database credentials, scraping URLs, and retry settings.
  - `Pipeline-Engineering-Practices.ipynb`: Configuration management, structured logging, retries with exponential backoff, and idempotency.
  - `pipeline.py`: Automated end-to-end pipeline with Prefect orchestration, transient error retries, and idempotent MySQL storage.
- **Query Execution & Optimization** (`sql/SQL-4.5-Index.sql`) — analyzing execution plans with `EXPLAIN`, identifying full table scans vs. index lookups.

## Assessment Milestones

- **Assignment 1 Due:** Cloud System Design and Pricing.
- **Project Milestone 2:** [Project Checkpoint 2](../docs/CHECKPOINT-2.md) — Conceptual and Logical Data Models, Schema DDL, and Seed Scripts.
- **Quiz 3:** CTE structures, window function frame specifications, transaction isolation, index types, and execution plan interpretation.

## Submission

Include advanced SQL query scripts and execution results, `EXPLAIN` execution plans before and after indexing, Python database interaction outputs with rollback demonstration, and database engine version metadata.
