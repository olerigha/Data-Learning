# Week 8: Distributed Processing with Spark

## Overview

Introduction to Apache Spark / PySpark: DataFrames, RDDs, partitions, transformations vs. actions, and lazy evaluation.

## Files

- `8.1-SparkBasics.ipynb` — PySpark notebook covering:
  - SparkSession and SparkContext
  - Reading CSV into a DataFrame, schema and summary statistics
  - The RDD behind a DataFrame
  - Partitions: `repartition`, `coalesce`, and bar charts of rows per partition
  - Narrow vs. wide transformations, lazy evaluation, and `explain()` query plans
- `food-inspections.csv` — Chicago food inspections dataset (about 277,000 rows) used by the notebook.

## Running

Requires Java 17+ and `pyspark`. Open the notebook from this folder so the relative path to `food-inspections.csv` resolves, then run all cells.

## Assessment Milestones

- **Assignment 3:** Data Warehouse and Polyglot Persistence (NoSQL).
- **Project Milestone 4:** [Project Checkpoint 4](../docs/CHECKPOINT-4.md) — Pipeline Implementation, Data Warehouse Integration, and Distributed Processing Analysis.
- **Quiz 7:** Spark execution lifecycle, lazy evaluation, narrow vs. wide transformations, shuffle partitions, Catalyst optimization, and cost tradeoffs.
