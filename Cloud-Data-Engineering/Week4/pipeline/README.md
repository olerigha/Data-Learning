# Data Engineering Pipeline Suite — Week 4

An end-to-end data pipeline demonstrating production practices (configuration, structured logging, retries, idempotency) using the **2020 IMDb Movies** dataset.

## Directory Structure

```
week4/pipeline/
├── Create-IMDB.sql                      # Schema initialization script (creates imdb_data and movies table)
├── config.yaml                          # Pipeline configuration (URLs, DB credentials, retries)
├── data/
│   └── movie_ratings.csv                # 2020 movie fixture (offline fallback)
├── ingestion/
│   └── DataIngestion-Scraping.ipynb     # Web scraping walkthrough with BeautifulSoup
├── Pipeline-Engineering-Practices.ipynb  # Core practices: config, logging, retries, idempotency
├── pipeline.py                          # Automated end-to-end pipeline (Prefect orchestration)
├── requirements.txt                     # Pipeline Python dependencies
└── tests/
    └── test_pipeline.py                 # Automated unit tests for database transactions & retry logic
```

## Setup & Prerequisites

### 1. Install Dependencies

Install the required Python packages:

```bash
pip install -r requirements.txt
```

*(Or install directly: `pip install prefect beautifulsoup4 requests mysql-connector-python pyyaml pandas`)*

### 2. Initialize the Database

Ensure MySQL is running and initialize the database schema and table:

```bash
mysql -u root -p < Create-IMDB.sql
```

Connection settings can be updated in `config.yaml` or overridden via environment variables:

```bash
export DB_HOST=localhost
export DB_USER=root
export MYSQL_PASSWORD=your_password
export DB_NAME=imdb_data
```

## How to Run

### 1. Run the Automated Pipeline

Execute the end-to-end pipeline. Prefect orchestrates each task (extract, parse, retry, upsert):

```bash
python pipeline.py
```

> **Offline Fallback:** If internet access to IMDb is restricted, the pipeline automatically falls back to loading records from `data/movie_ratings.csv`.
> **Auto-Schema Recovery:** If the target database does not exist yet (`errno 1049`), the pipeline automatically bootstraps itself by running `Create-IMDB.sql` and retrying.

### 2. View the Prefect Dashboard & Console

By default, `python pipeline.py` spins up a temporary server during execution. To explore the persistent interactive web console:

1. **Start the Prefect server** (in a separate terminal window):
   ```bash
   prefect server start
   ```
2. **Point your client to the local server** (run once):
   ```bash
   prefect config set PREFECT_API_URL=http://127.0.0.1:4200/api
   ```
3. **Execute the pipeline**:
   ```bash
   python pipeline.py
   ```
4. **Open the Dashboard**: Navigate to **[http://localhost:4200](http://localhost:4200)** in your browser to inspect:
   - **Flow Runs:** Full run history and parameters.
   - **Task Dependency Graph:** Visual DAG showing `fetch_url` → `scrape_movies` / `load_fallback_fixture` → `insert_movies`.
   - **Observability:** Task states (`Completed`, `Failed`), duration metrics, and structured logs.

### 3. Interactive Notebooks

Work through the guided notebooks in Jupyter:

- **Ingestion & Scraping:** [`ingestion/DataIngestion-Scraping.ipynb`](ingestion/DataIngestion-Scraping.ipynb) — HTML parsing, rate-limiting, and text extraction.
- **Production Practices:** [`Pipeline-Engineering-Practices.ipynb`](Pipeline-Engineering-Practices.ipynb) — Config loading, structured logging, exponential backoff, and idempotent upserts.

### 4. Run Unit Tests

Execute the automated test suite verifying database transactions, idempotency, retries, and config parsing:

```bash
# From week4/pipeline directory:
PYTHONPATH=. python3 -m unittest discover -s tests -v

# Or from repository root:
PYTHONPATH=code/week4/pipeline python3 -m unittest discover -s code/week4/pipeline/tests -v
```
