# Layered Data Pipeline

Run the pipeline against the course earthquake dataset:

```bash
python code/week5/lakehouse/layered_pipeline.py \
  code/week5/warehouse/all_week.csv \
  /tmp/cloud-data-engineering-layers
```

The pipeline validates its required columns and numeric ranges, creates bronze (raw), silver (cleaned), and gold (analytics-ready) layers, and aggregates the gold output by date and event type. Extend the exercise with a schema contract, a reject/quarantine path, idempotent output handling, and Parquet output.

Record lineage and governance using [DATA-CATALOG.md](../../docs/DATA-CATALOG.md) and [DATA-LINEAGE.md](../../docs/DATA-LINEAGE.md). Save the pipeline log with row counts and duration as evidence.
