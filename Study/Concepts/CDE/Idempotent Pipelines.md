---
course: CDE
week: 5
source: "[[Cloud-Data-Engineering/Week5/README|Week 5 README]], [[Cloud-Data-Engineering/Week4/pipeline/README|Week 4 pipeline README]]"
status: new
tags: [generated]
---
# Idempotent Pipelines
**In one line:** Running a pipeline twice gives the same result as running it once, with no duplicate rows.

**In plain words:** Pipelines fail and get re-run. If every run blindly appends, a retry doubles your data. An idempotent pipeline is safe to repeat. It "upserts" (insert new, update existing) on a unique key, or replaces the whole output for that day instead of adding to it. That's what makes automatic retries safe.

**Terms**
| Term | Means |
|---|---|
| Idempotent | same end state no matter how many times you run it |
| Upsert | insert if new, update if the key already exists |
| Natural / unique key | what identifies "the same record" (e.g. movie title + year) |
| Overwrite partition | replace one day's output instead of appending |

**Key points**
- In MySQL: `INSERT … ON DUPLICATE KEY UPDATE`, backed by a UNIQUE key.
  In words: if this row already exists, update it instead of adding a copy.
- Idempotency + retries + transactions = a pipeline you can safely re-run after any failure.
- The Week 4 IMDb pipeline uses idempotent MySQL storage and tests for it.

**Memorize vs. look up:** Memorize the definition and the upsert pattern.

Related: [[Pipeline Orchestration with Prefect]], [[ACID Transactions]], [[Medallion Architecture]], [[Data Observability]]
