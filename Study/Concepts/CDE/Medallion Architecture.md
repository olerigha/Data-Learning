---
course: CDE
week: 5
source: "[[Cloud-Data-Engineering/Week5/README|Week 5 README]], [[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# Medallion Architecture
**In one line:** Refine data in three layers: Bronze (raw), Silver (clean), Gold (ready for business use).

**In plain words:** Don't clean data in place. First save exactly what arrived (bronze), so you can always replay it. Then make a cleaned, validated copy with correct types and duplicates removed, and set bad rows aside instead of silently dropping them (silver). Finally build summary tables that dashboards read directly (gold). Each layer can be rebuilt from the one before it.

**Terms**
| Term | Means |
|---|---|
| Bronze | raw ingested data, unchanged |
| Silver | validated, typed, deduplicated; bad rows quarantined |
| Gold | aggregated, business-ready tables (often Parquet) |
| Quality gate | checks a row must pass to move to the next layer |
| Quarantine | holding area for rejected rows, kept for review |
| Parquet | columnar file format: compresses well, fast for analytics |

**Key points**
- Earthquake lab (`layered_pipeline.py`):
  - **Quality gate:** required columns present; missing time/lat/long/type rejected.
  - **Silver:** latitude in [−90, 90], longitude in [−180, 180], numbers typed.
  - **Gold:** group by date + event type → event count, maximum magnitude.
- Log row counts and duration at each layer, and record them in the catalog and lineage docs.
- Mirrors Inmon's staged approach, built with ELT.

**Memorize vs. look up:** Memorize what each layer holds and why bronze stays raw.

Related: [[Data Lakehouse]], [[Idempotent Pipelines]], [[Data Observability]], [[Inmon vs Kimball]], [[Object Storage]]
