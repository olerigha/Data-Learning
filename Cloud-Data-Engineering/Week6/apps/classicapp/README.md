# Classic Models Customer Data Application

A full-stack data application demonstrating modern decoupled architecture:
- **FastAPI Backend** (`ClassicFastAPI.py`): Connects to the Classic Models relational database in **MySQL** via SQLAlchemy ORM, performs Pydantic request/response schema validation, and exposes RESTful API endpoints for reading and updating customer data with auto-generated OpenAPI documentation.
- **Streamlit Frontend** (`ClassicApp.py`): Interactive analytics user interface with logo branding that communicates with the database **strictly through the FastAPI REST API backend**, supporting customer lookups, listing, and live editing with an update button.
- **Configuration** (`config.yaml`): Centralized YAML configuration for database connection parameters and API settings, with environment variable interpolation `${VAR:-default}`.

```
┌─────────────────────────────────┐
│ Streamlit Frontend              │
│ (ClassicApp.py, port 8501)      │
│ - Branding & Logo               │
│ - Table / Card Display          │
│ - Customer Search & Edit Form   │
└───────────────┬─────────────────┘
                │  HTTP GET /customers
                │  HTTP GET /customers/{id}
                │  HTTP PUT /customers/{id}  <-- Updates customer
                ▼
┌─────────────────────────────────┐
│ FastAPI REST API Backend        │
│ (ClassicFastAPI.py, port 8000)  │
│ - Pydantic Request Validation   │
│ - Auto OpenAPI Docs (/docs)     │
└───────────────┬─────────────────┘
                │  SQLAlchemy ORM (CRUD)
                ▼
┌─────────────────────────────────┐
│ MySQL Database                  │
│ (classicmodels schema)          │
└─────────────────────────────────┘
```

## Prerequisites

- Python 3.10+ (tested on Python 3.12)
- MySQL Server (version 8.0+) with the `classicmodels` database installed
  - Schema & data script available at: `code/classicmodels/mysqlsampledatabase.sql`
- Required Python dependencies:
  ```bash
  pip install -r requirements.txt
  ```

## Configuration (`config.yaml`)

Connection parameters are defined in `config.yaml`:

```yaml
database:
  dialect: "mysql"
  driver: "mysqlconnector"
  host: "${DB_HOST:-localhost}"
  port: 3306
  user: "${DB_USER:-root}"
  password: "${DB_PASSWORD:-rootroot}"
  database: "${DB_NAME:-classicmodels}"
  charset: "utf8"
  pool_recycle: 3600

api:
  host: "${API_HOST:-127.0.0.1}"
  port: 8000
  base_url: "${API_BASE_URL:-http://127.0.0.1:8000}"
  title: "Classic Models API"
  version: "1.0.0"
```

You can either modify `config.yaml` directly or override settings using environment variables (e.g. `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, or a complete `DATABASE_URL` connection string):

```bash
export DB_HOST="localhost"
export DB_USER="root"
export DB_PASSWORD="mysecretpassword"
# Or a complete connection URL:
# export DATABASE_URL="mysql+mysqlconnector://user:pass@host:3306/classicmodels"
```

## Running the Application

### Step 1: Ensure MySQL is Running

Make sure your MySQL server is running and the `classicmodels` database is loaded:

```bash
# Load sample database into MySQL (if not already done)
mysql -u root -p < ../../../classicmodels/mysqlsampledatabase.sql
```

### Step 2: Start the FastAPI Server

The FastAPI backend connects to MySQL and must be started first:

```bash
# From inside the classicapp directory:
cd code/week6/apps/classicapp
uvicorn ClassicFastAPI:app --reload

# Or from the repository root:
uvicorn ClassicFastAPI:app --app-dir code/week6/apps/classicapp --reload
```

- API Base URL: [http://127.0.0.1:8000](http://127.0.0.1:8000)
- Interactive Swagger UI: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- Alternative ReDoc UI: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

#### API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | API status and overview |
| `GET` | `/health` | Health check verifying MySQL connection and customer count |
| `GET` | `/customers` | Retrieve all customer records from MySQL |
| `GET` | `/customers/{customer_id}` | Retrieve specific customer by `customerNumber` (returns 404 if not found) |
| `PUT` | `/customers/{customer_id}` | Update customer fields (name, contact, city, state, country) in MySQL |

### Step 3: Start the Streamlit Frontend

In a separate terminal, launch the Streamlit frontend:

```bash
# From inside the classicapp directory:
cd code/week6/apps/classicapp
streamlit run ClassicApp.py

# Or from the repository root:
streamlit run code/week6/apps/classicapp/ClassicApp.py
```

The Streamlit UI will open at [http://localhost:8501](http://localhost:8501).

Use the sidebar navigation to:
- **Get All Customers**: View all records in a responsive table or expandable detail cards.
- **Get Customer by ID**: Query a specific customer by ID (e.g., `103`, `112`, `114`), with an expandable quick-edit form.
- **Edit Customer**: Dedicated edit interface to look up any customer, modify their attributes, and persist updates with the **Update Customer** button.
- **API Health Status**: Inspect live connectivity and row counts reported by FastAPI.

## Running Tests

Run the test suite verifying API contract serialization, MySQL read/update queries, and 404 handling:

```bash
python -m unittest TestClassicFastAPI.py -v
```

From the repository `code/` directory:

```bash
PYTHONPATH=week6/apps/classicapp python -m unittest week6/apps/classicapp/TestClassicFastAPI.py -v
```
