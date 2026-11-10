---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Batch vs Streaming
**In one line:** Batch processes data in scheduled chunks (high throughput, minutes–hours delay); streaming processes each event as it arrives (sub-second delay).

**In plain words:** Batch is the nightly truck: a scheduler (cron, Airflow) runs every N hours and loads a big pile into the warehouse. Streaming is a conveyor belt: events (clicks, sensors, database changes) flow into a durable log like Kafka, and a stream processor handles them continuously. Batch is simpler and cheaper; streaming is for when minutes of delay are too slow. Separately, ETL vs ELT is about *when* you transform.

**Terms**
| Term | Means |
|---|---|
| Batch | scheduled bulk processing |
| Streaming | continuous, event-by-event processing |
| Latency | delay from event to usable data |
| Throughput | how much data per unit of time |
| Kafka topic | durable, partitioned, ordered event log |
| Flink / Spark Streaming | stream processors |
| ETL | Extract → Transform → Load: transform before loading (traditional) |
| ELT | Extract → Load → Transform: load raw to the lake/warehouse, transform there (cloud-native) |
| API / REST | rules for programs to request data over HTTP (GET, POST, DELETE) |

**Key points**
- Batch: source DB → scheduler → warehouse. High throughput, higher latency.
- Streaming: event source (clickstream, IoT, CDC) → Kafka → stream processor. Low latency.
- Any pipeline, ETL or ELT, must be **idempotent, retryable and observable**.
- APIs are a common source: a client sends a GET to a REST API and gets data back.

**Memorize vs. look up:** Memorize batch vs streaming trade-offs and ETL vs ELT.

Related: [[Data Engineering Lifecycle]], [[Pub-Sub Messaging]], [[Idempotent Pipelines]], [[The 4 Vs of Data]]
