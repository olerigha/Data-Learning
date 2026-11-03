# Observability and Failure-Injection Lab

This lab introduces the operational loop: emit useful signals, inject a controlled failure, diagnose it from evidence, and recover without corrupting output.

## Signals to Capture

- Run identifier and input/output paths.
- Input, accepted, rejected, and output row counts.
- Duration for each major stage.
- Retry count, backoff delays, and request latency for database and external calls.
- Error class and actionable context, without exposing credentials or sensitive data.

---

## 1. Automated Pipeline Logging (Week 4 IMDb Pipeline)

The Week 4 pipeline (`pipeline.py`) automatically streams structured telemetry to stdout and writes them out directly to a log file (`pipeline.log`, configured in `config.yaml` or via `export LOG_FILE=pipeline.log`):

```bash
cd week4/pipeline
python pipeline.py
```

Inspect the generated log file as evidence:

```bash
cat pipeline.log
# Or monitor in real time:
tail -f pipeline.log
```

Key telemetry captured in `pipeline.log`:
- **HTTP Ingestion:** Web requests, status codes, and fallback triggers (`fetch_url`, `load_fallback_fixture`).
- **Database Telemetry:** Query latency in milliseconds, row counts affected, and transaction commit status:
  ```text
  query=upsert_movies status=success rows_affected=25 duration_ms=18.42 attempt=1
  ```
- **Resilience & Auto-Recovery:** Automatic schema bootstrap on missing database (`errno 1049`), deadlock retries with exponential backoff delays.

---

## 2. Lakehouse Layered Pipeline Logging & Failure Injection

Run the event pipeline and write logs out to a file:

```bash
# Set LOG_FILE environment variable to write directly to file
export LOG_FILE=/tmp/course-pipeline.log

python week5/lakehouse/layered_pipeline.py \
  week5/warehouse/all_week.csv /tmp/course-layers \
  2>&1 | tee /tmp/course-pipeline.log
```

### Failure Scenarios

1. Change one latitude to `999` and confirm the range check fails before gold output is published.
2. Remove the `type` header and confirm the schema error names the missing column.
3. Use a nonexistent input path and classify the failure as an operator/configuration error.
4. Run twice and compare row counts and output contents.

For each scenario, submit the log excerpt from `pipeline.log` or `/tmp/course-pipeline.log`, failure classification, expected recovery, and whether partial output must be deleted or quarantined.