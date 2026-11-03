# Week 6: Analytics Applications

## Overview

This week covers business intelligence, dashboard design, data visualization, communication, interactive data applications, and data governance. It focuses on serving curated data through production-grade REST APIs and interactive analytical web applications.

## Outcome

Expose analytics datasets through robust REST API endpoints and interactive web dashboards, implementing request validation, error handling, health checks, data contracts, and governance policies.

## Labs

- **REST APIs & Applications** (`apps/classicapp/`) — building analytical service endpoints and frontend:
  - `ClassicFastAPI.py`: Asynchronous REST API using FastAPI with Pydantic schema validation, SQLAlchemy ORM database integration, and automated OpenAPI documentation (`/docs`).
  - `ClassicApp.py`: Streamlit frontend application communicating through the FastAPI backend.
  - `TestFastAPI.py`: Minimal introductory FastAPI service example.
  - Contract testing for APIs using `TestClassicFastAPI.py`.
- **Dashboards** (`apps/dashboard/`) — interactive data apps with Plotly Dash:
  - `DashApp1.py` & `DashApp2.py`: Web dashboard displaying data tables, KPIs, and interactive filters.
- **Streamlit** (`apps/streamlit/`) — reactive data applications:
  - `app.py`: Streamlit application providing live filtering, KPI metric cards, and responsive visualizations.
- **Serverless Data Applications** (`apps/serverless/`) — serverless data app architecture:
  - `lambda/`: AWS Lambda functions reading S3 objects and RDS MySQL with parameter validation and automated testing.
  - `ui/`: Interactive Streamlit web application communicating with the serverless API.
  - `template.yaml`: AWS Serverless Application Model (SAM) declarative infrastructure-as-code template.
- **AI Database Agents** (`apps/ai/`) — natural language data querying:
  - `AISQLAgent.ipynb`: AI-driven database agent using LangChain, SQLAlchemy, and Ollama to translate natural language into SQL queries.
- **Governance and Responsible AI** ([`governance-lab.md`](governance-lab.md), [`Data-Governance-and-Provenance.ipynb`](Data-Governance-and-Provenance.ipynb)) — metadata management and data ethics:
  - `Data-Governance-and-Provenance.ipynb`: Practical notebook tracking provenance metadata across ETL hops (`run_id`, content hashes, schema versions, rejection rates).
  - Classifying data sensitivity and defining access control boundaries.
  - Formulating a versioned data contract and data retention policy.
  - Updating the data catalog, lineage tracking, and establishing responsible AI review criteria.
- **Observability and Failure Injection** ([`observability-lab.md`](observability-lab.md)) — operational telemetry and failure handling:
  - Emitting structured execution telemetry, query latencies, and row count metrics.
  - Controlled failure injection (schema violations, range constraint checks, missing input paths).
  - Capturing pipeline logs (`pipeline.log`) and diagnosing failure classes without exposing credentials.

## Framework Comparison

| Dimension | FastAPI | Plotly Dash | Streamlit |
|---|---|---|---|
| **Primary Use** | High-performance REST APIs | Complex analytical dashboards | Rapid prototyping & data apps |
| **Execution** | Async (ASGI, Uvicorn) | Reactive callbacks | Script rerun execution model |
| **Validation** | Pydantic type models | Component property types | Built-in Python checks |
| **Documentation** | Interactive Swagger & ReDoc | Custom layouts | In-app Markdown & widgets |

## Running Locally

```bash
# FastAPI with auto-reloading docs at http://localhost:8000/docs
uvicorn week6.apps.api.ClassicFastAPI:app --reload

# Streamlit interactive application
streamlit run week6/apps/streamlit/app.py

# Dash interactive dashboard
python week6/apps/dashboard/DashApp1.py

# Run API contract test suite
PYTHONPATH=week6/apps/classicapp python -m unittest week6/apps/classicapp/TestClassicFastAPI.py -v
```

## Assessment Milestones

- **Assignment 2:** Relational Data Model Design, SQL Queries, and Cloud Database Implementation.
- **Project Milestone 3:** [Project Checkpoint 3](../docs/CHECKPOINT-3.md) — SQL & Analytics Queries, API Contract, and Preliminary Visualizations.
- **Quiz 5:** REST design principles, schema validation, dashboard KPI formulation, interactive filtering, health endpoints, data classification, and responsible AI governance.

## Submission

Include the API specification (endpoints, request/response payloads), dashboard screenshots with active filters, health check output, framework tradeoff memo, completed data catalog entry, versioned data contract, and governance review.
