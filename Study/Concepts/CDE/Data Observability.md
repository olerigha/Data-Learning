---
course: CDE
week: 6
source: "[[observability-lab]], [[Week6-BusinessIntelligence.pdf]]"
status: new
tags: [generated]
---
# Data Observability
**In one line:** Record enough signals from pipelines and apps (counts, timings, errors, freshness) to know when something breaks and why.

**In plain words:** A pipeline that "ran fine" might have loaded zero rows. Observability means each run leaves evidence: how many rows came in, were accepted, rejected and written; how long each stage took; how many retries happened; and a clear error if it failed, without leaking passwords. With that, you can alert on problems and prove the data is fresh and complete.

**Terms**
| Term | Means |
|---|---|
| Run ID | unique label for one pipeline run |
| Row counts | input / accepted / rejected / output |
| Latency (p50 / p95) | typical / slow-case response time |
| Freshness SLA | promise about how recent the data is |
| Failure injection | deliberately breaking things to test recovery |

**Key points**
- Signals to capture: run ID, paths, row counts, per-stage duration, retry count and backoff, error class with context.
- Week 4 IMDb pipeline: HTTP status, fallbacks, query latency (ms), rows affected, commit status, retries.
- Lakehouse lab: set `LOG_FILE` and inject failures (bad rows, missing columns) to check the quality gate.
- Data product metrics: adoption (users, views), quality (% checks passing, null rates), performance (p95 latency), trust (% certified datasets).

**Memorize vs. look up:** Memorize the signal list.

Related: [[Pipeline Orchestration with Prefect]], [[Medallion Architecture]], [[Data Contracts]], [[Idempotent Pipelines]], [[Well-Architected Framework]]
