---
course: CDE
week: 6
source: "[[Week6-BusinessIntelligence.pdf]], [[Cloud-Data-Engineering/Week6/README|Week 6 README]]"
status: new
tags: [generated]
---
# Three-Tier Data Apps
**In one line:** Split a data app into a UI, an API and a database, so each layer can be changed or swapped on its own.

**In plain words:** The user clicks in a Streamlit page (UI). The page doesn't touch the database directly; it calls a FastAPI backend (API), which checks the input, applies the business rules and queries MySQL through SQLAlchemy (database). Because the layers only talk through defined interfaces, you could swap Streamlit for React, or MySQL for Postgres, without rewriting the rest.

**Terms**
| Term | Means |
|---|---|
| UI / presentation tier | what the user sees (Streamlit, Dash) |
| API tier | business logic and validation (FastAPI, Flask) |
| Data tier | system of record (MySQL on RDS) |
| Pydantic | validates request/response data in FastAPI |
| OpenAPI / Swagger | auto-generated API docs (`/docs`) |
| `st.cache_data` / `st.cache_resource` | Streamlit caching of results / of connections |
| Docker / Cloud Run | package the app / run it serverless, scaling to zero |

**Key points**
- Course app: Browser → Streamlit (:8501) → FastAPI (`/customers`) → SQLAlchemy → MySQL ClassicModels.
- Streamlit re-runs the whole script on every click, so cache expensive work.
- Security: validate first, parameterized queries only, OAuth/OIDC login, rate-limit heavy requests.
- Testing: unit (mock queries), integration (test database), a few end-to-end UI flows, all in CI.
- Ops: a `/health` endpoint; log each query's user, filters, size and latency.

**Memorize vs. look up:** Memorize the three tiers and what each one does.

Related: [[SQL from Python]], [[Serverless Computing]], [[Dashboard Design Principles]], [[Data Observability]]
