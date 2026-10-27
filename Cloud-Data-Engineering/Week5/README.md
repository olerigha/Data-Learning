# Week 5: Lakehouse and Data Warehouse

## Overview

This week covers data lakehouse architecture, dimensional modeling (star schemas), slowly changing dimensions (SCDs), bronze/silver/gold layered architectures, data quality gates, testing, columnar file formats (Parquet), data cataloging, lineage tracking, and BI dashboard integration.

## Outcome

Build a multi-hop lakehouse pipeline using bronze/silver/gold layers, apply dimensional modeling and warehouse queries, record catalog and lineage entries, and visualize business KPIs through a connected BI dashboard.

## Labs

- **Lakehouse Architecture** (`lakehouse/`) — multi-hop storage layers:
  - Implements `layered_pipeline.py` converting raw source inputs into bronze (raw preservation), silver (validated, typed records with rejected record quarantine), and gold (aggregated analytics tables stored as columnar Parquet).
  - Verified with automated unit tests in `lakehouse/tests/`.
- **Data Warehouse** (`warehouse/`) — dimensional modeling and analytics:
  - Star schema design featuring fact tables and dimension tables.
  - Slowly changing dimensions (SCD Type 1 vs. Type 2).
  - Connecting Metabase via Docker to answer key business questions.

## Key Concepts

- **Idempotency:** Executing a pipeline run multiple times produces identical state without duplicate records.
- **Medallion Layers:**
  - *Bronze:* Raw ingestion without transformations.
  - *Silver:* Cleaned, validated, typed, and deduplicated records with quarantine paths for malformed records.
  - *Gold:* Enriched, aggregated, query-optimized analytical models stored in columnar Parquet format.
- **Data Governance:** Completing entries for the [Data Catalog](../docs/DATA-CATALOG.md) and [Data Lineage](../docs/DATA-LINEAGE.md).

## Running the Pipeline

```bash
# Run the layered lakehouse pipeline
python week5/lakehouse/layered_pipeline.py \
  week5/warehouse/all_week.csv \
  /tmp/cloud-data-engineering-layers

# Run lakehouse tests
PYTHONPATH=week5/lakehouse python -m unittest discover -s week5/lakehouse/tests -v
```

## Assessment Milestones

- **Quiz 4:** Warehouse grain, fact vs. dimension modeling, SCD tradeoffs, medallion layer responsibilities, quality metrics, columnar storage benefits, data catalog attributes, and lineage tracking.

## Submission

Include the pipeline architecture diagram, rerun/idempotency verification evidence, rejected-record report, bronze/silver/gold row counts and schemas, completed data catalog and lineage records, and a screenshot of the Metabase dashboard.
