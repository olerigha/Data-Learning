---
course: CDE
week: 4
source: "[[Cloud-Data-Engineering/Week4/pipeline/README|Week 4 pipeline README]]"
status: new
tags: [generated]
---
# Pipeline Orchestration with Prefect
**In one line:** An orchestrator runs pipeline steps in order, retries the ones that fail, and logs what happened.

**In plain words:** A real pipeline has steps: fetch a web page, parse it, save to MySQL. Any step can fail for a temporary reason (network blip, database busy). Prefect wraps each step as a **task** and the whole run as a **flow**. It retries failed tasks with growing waits, falls back to a local file if the website is down, and shows every run in a dashboard. Settings live in a config file, not in the code.

**Terms**
| Term | Means |
|---|---|
| Flow | the whole pipeline run |
| Task | one step in the flow |
| DAG | directed acyclic graph: the map of which task feeds which |
| Retry with exponential backoff | try again after 1s, 2s, 4s… |
| Fallback | backup path when a source fails (`movie_ratings.csv`) |
| Structured logging | logs as key–value fields (counts, durations), easy to search |
| `config.yaml` | external settings: URLs, DB settings, retry counts |

**Key points**
- IMDb pipeline DAG: `fetch_url` → `scrape_movies` or `load_fallback_fixture` → `insert_movies`.
- Four production practices: **config**, **structured logging**, **retries**, **idempotency**.
- Auto-recovery: a missing database (`errno 1049`) triggers the schema script, then a retry.
- Dashboard at `localhost:4200` shows run history, the task graph and task states.
- Unit tests check transactions, idempotency, retries and config parsing.

**Memorize vs. look up:** Memorize the four practices and flow vs task. Look up Prefect commands.

Related: [[Idempotent Pipelines]], [[SQL from Python]], [[Data Observability]], [[Data Engineering Lifecycle]]
