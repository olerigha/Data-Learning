---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Data Engineering Lifecycle
**In one line:** The path data travels: Source → Ingest → Store → Transform → Serve → Consume, with observability watching every step.

**In plain words:** A data engineer builds the plumbing. Data starts in source systems (app databases, APIs, files, streams). It's ingested, stored (usually a lakehouse), cleaned and reshaped, then served to the tools people use (warehouses, APIs) and consumed as dashboards, reports or ML. Observability (logging, monitoring, quality checks) loops around the whole thing. Storage is the layer every other decision is built on.

**Terms**
| Term | Means |
|---|---|
| Source systems | OLTP databases, APIs, files, event streams |
| Ingest | pull data in (Kafka, Airbyte, Fivetran, CDC) |
| Store | lakehouse layers: bronze → gold (Delta Lake, Iceberg, S3) |
| Transform | clean, join, aggregate (dbt, Spark, SQL) |
| Serve / Consume | expose to warehouses and APIs / used in BI, ML, reports |
| Observability | logs, metrics and checks across all stages |
| CDC | change data capture: stream every row change from a database |
| Modern data stack | Ingestion → Storage → Transformation → Orchestration (Airflow, Prefect) → BI |

**Key points**
- Six layers: **Source → Ingest → Store → Transform → Serve → Consume**, plus an **observability loop**.
- The lakehouse (storage) is the focal layer.
- Each stage maps to later weeks: storage (Wk 2–3), transforms and pipelines (Wk 4–5), serving and governance (Wk 6).

**Memorize vs. look up:** Memorize the six layers in order and that observability wraps them.

Related: [[Data Roles]], [[Batch vs Streaming]], [[Medallion Architecture]], [[Data Observability]], [[Pipeline Orchestration with Prefect]]
