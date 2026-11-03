# Week 6: Business Intelligence and Data Applications

## Overview

This week covers business intelligence, dashboard design, data visualization, communication, interactive data applications, and data governance. It focuses on serving curated data through production-grade REST APIs (FastAPI) and interactive analytical web applications (Streamlit, Dash).

## Outcome

Expose analytics datasets through robust REST API endpoints and interactive web dashboards, implementing request validation, error handling, health checks, data contracts, and governance policies.

## Labs & Applications

- **Classic Models Customer App** (`apps/classicapp/`) — full-stack decoupled data application:
  - `ClassicFastAPI.py`: Asynchronous REST API built with FastAPI, SQLAlchemy ORM connection to the MySQL database, Pydantic schema validation, and automated OpenAPI documentation (`/docs`).
  - `ClassicApp.py`: Streamlit frontend application with logo branding that reads and updates customer data strictly through the FastAPI REST API backend.
  - `config.yaml`: Externalized YAML configuration for MySQL connection details and API settings.
  - `TestClassicFastAPI.py`: API contract tests validating health check, collection, and detail endpoints.
  - `TestFastAPI.py`: Minimal introductory FastAPI service example.
- **Dashboards** (`apps/dashboard/`) — interactive data apps with Plotly Dash:
  - `DashApp1.py` & `DashApp2.py`: Web dashboards displaying data tables, KPIs, and interactive filters.
- **Serverless Data Applications** (`apps/serverless/`) — cloud-native serverless architecture:
  - `lambda/`: AWS Lambda functions querying S3 objects and RDS MySQL with parameter validation.
  - `ui/`: Interactive Streamlit application communicating with the serverless API.
  - `template.yaml`: AWS Serverless Application Model (SAM) declarative template.
- **AI Database Agents** (`apps/ai/`) — natural language data querying:
  - `AISQLAgent.ipynb`: AI-driven database agent using LangChain, SQLAlchemy, and Ollama to translate natural language into SQL queries.
- **Data Governance and Provenance** (`datagov/`) — metadata management and data contracts:
  - `Data-Governance-and-Provenance.ipynb`: Notebook tracking provenance metadata across ETL hops (`run_id`, content hashes, schema versions, rejection rates).
  - `governance-lab.md`: Guide for data sensitivity classification, access control boundaries, and data contracts.
  - `observability-lab.md`: Operational telemetry, failure injection, and structured logging.
- **Security & Encryption** (`encryption/`) — data protection fundamentals:
  - Notebooks covering symmetric encryption (`9.3a`), asymmetric encryption (`9.3b`), and cryptographic hashing (`9.3c`).
- **Reporting** (`reporting/`) — enterprise BI:
  - Tableau workbook (`ClassicModelsDashboard.twb`) and instructions guide ([`TableauInstructions.md`](reporting/TableauInstructions.md)) for ClassicModels analytics reporting.

## Framework Comparison

| Dimension | FastAPI | Plotly Dash | Streamlit |
|---|---|---|---|
| **Primary Use** | High-performance REST APIs | Complex analytical dashboards | Rapid prototyping & data apps |
| **Execution** | Async (ASGI, Uvicorn) | Reactive callbacks | Script rerun execution model |
| **Validation** | Pydantic type models | Component property types | Built-in Python checks |
| **Documentation** | Interactive Swagger & ReDoc | Custom layouts | In-app Markdown & widgets |

## Running Locally

### 1. Classic Models Customer Application (FastAPI + Streamlit)

```bash
# Terminal 1: Start FastAPI REST backend (connects to DB)
cd week6/apps/classicapp
uvicorn ClassicFastAPI:app --reload

# Terminal 2: Start Streamlit UI (communicates through FastAPI)
cd week6/apps/classicapp
streamlit run ClassicApp.py
```

- FastAPI Interactive Docs: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- Streamlit Web Application: [http://localhost:8501](http://localhost:8501)

### 2. Plotly Dash Dashboards

```bash
python week6/apps/dashboard/DashApp1.py
```

### 3. API Contract Tests

From the repository `code/` root:

```bash
PYTHONPATH=week6/apps/classicapp python -m unittest week6/apps/classicapp/TestClassicFastAPI.py -v
```

## Assessment Milestones

- **Assignment 2:** Relational Data Model Design, SQL Queries, and Cloud Database Implementation.
- **Project Milestone 3:** [Project Checkpoint 3](../docs/CHECKPOINT-3.md) — SQL & Analytics Queries, API Contract, and Preliminary Visualizations.
- **Quiz 5:** REST design principles, schema validation, dashboard KPI formulation, interactive filtering, health endpoints, data classification, and responsible AI governance.

## Submission

Include the API specification (endpoints, request/response payloads), dashboard screenshots with active filters, health check output, framework tradeoff memo, completed data catalog entry, versioned data contract, and governance review.

