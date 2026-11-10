---
course: CDE
week: 5
source: "[[Week5-DatawarehouseDataLakes.pdf]]"
status: new
tags: [generated]
---
# Data Lakehouse
**In one line:** A data lake (cheap files in object storage) plus warehouse features (ACID, SQL, schemas) in one system.

**In plain words:** A **data lake** dumps every kind of raw data into cheap object storage and only applies structure when you read it. It's flexible, but it can become a messy "data swamp". A **warehouse** is tidy and fast for SQL, but costlier and rigid. A **lakehouse** keeps the files in cheap storage but adds a table format (Delta Lake, Iceberg, Hudi) that brings transactions, updates, versioning and schema rules.

**Terms**
| Term | Means |
|---|---|
| Data lake | raw data of any type in object storage |
| Schema-on-read | structure applied when queried (lake) |
| Schema-on-write | structure required before loading (warehouse) |
| Open table format | Delta Lake, Apache Iceberg, Apache Hudi: metadata layers on Parquet |
| Compaction | merging many small files into fewer big ones for speed |
| Data catalog | searchable inventory of datasets, schemas and owners |

**Key points**
| | Warehouse | Lake |
|---|---|---|
| Data | structured | any type |
| Schema | on write | on read |
| Scale / cost | TB, pricier | PB, cheap |
| Users | BI / reporting | data scientists, engineers, ML |
- Lakehouse = lake storage + warehouse reliability. It usually uses bronze/silver/gold layers.
- Streaming in: Kafka → Spark Structured Streaming → Delta. Watermarks handle late events.
- Governance from day one: catalog (Unity, Glue, Dataplex), column masking, lineage, audit logs.

**Memorize vs. look up:** Memorize lake vs warehouse vs lakehouse, and schema-on-read vs schema-on-write.

Related: [[Medallion Architecture]], [[Object Storage]], [[Inmon vs Kimball]], [[Data Governance and Lineage]], [[Structured vs Semi-structured vs Unstructured Data]]
