# Data Engineering Pipeline Suite — Week 4

This directory contains a streamlined, end-to-end data pipeline suite standardized on a single dataset (**2020 IMDb Movie Releases**). Students follow one continuous data journey from extraction through data quality profiling to resilient, idempotent loading into MySQL.

## Directory Structure

```
week4/pipeline/
├── DataEngineering-Foundations.ipynb    # Structured, semi-structured, and unstructured data concepts
├── data/                                # Data fixtures
│   └── movies.xls                       # Reference multi-sheet dataset
├── ingestion/                           # Ingestion & Scraping
│   ├── DataIngestion-Scraping.ipynb     # Web scraping with BeautifulSoup (IMDb 2020 movies)
│   └── movie_ratings.csv                # Scraped 2020 movie reference fixture (offline fallback)
├── Pipeline-Engineering-Practices.ipynb  # Core practices: config, structured logging, retries, idempotency
├── Python-Pipeline.py                   # Automated end-to-end pipeline with Prefect orchestration
├── pipeline_db.py                       # Resilient DB module (upserts, retries, rollback, logging)
└── tests/
    └── test_pipeline_db.py              # Automated unit tests for database writer & retry logic
```

## Unified Learning Progression (2020 Movies Dataset)

```
[ IMDb 2020 Search ] ──► [ Ingestion ] ──► [ Pandas Profiling ] ──► [ Resilient Pipeline ] ──► [ MySQL Database ]
(Web Scraping / Cache)   (BeautifulSoup)   (Nulls, Types, Dedup)    (Retries, Logging, Upsert)   (imdb_data.movies)
```

### 1. Foundations (`DataEngineering-Foundations.ipynb`)
- Distinguish between structured (relational tables, CSV), semi-structured (JSON payloads, HTML DOM), and unstructured data.
- Track data provenance: recording source URI, ingest timestamp, and schema versions.

### 2. Ingestion & Scraping (`ingestion/DataIngestion-Scraping.ipynb`)
- Scrapes release data for movies released in 2020 from IMDb (`https://www.imdb.com/search/title/?release_date=2020-01-01,2020-12-31`).
- Demonstrates HTML parsing, rate-limiting, and extracting title, year, rating, and vote counts.
- Stores output as `movie_ratings.csv`, which doubles as a local offline fixture.

### 3. Transformation & Quality Profiling
- Cleans scraped text (stripping rank indicators like `"1. Industry"` to `"Industry"`).
- Handles missing ratings and vote counts, parses vote strings (`"1.2M"` -> `1200000`), and casts numeric data types with Pandas.
- Evaluates data quality gates (uniqueness of `(name, year)`, range checks on ratings `0.0 - 10.0`).

### 4. Production Pipeline Engineering (`Pipeline-Engineering-Practices.ipynb`)
- **Configuration:** Managing settings with environment variables (`DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`).
- **Structured Logging:** Emitting single-line log events with execution durations and row counts.
- **Resilience:** Automatic retry with exponential backoff for transient database errors (deadlocks, lock timeouts, dropped connections).
- **Idempotency:** Using MySQL `INSERT ... ON DUPLICATE KEY UPDATE` on `UNIQUE (name, year)` to ensure repeated pipeline executions update records without duplicating data.

### 5. Automated Orchestration (`Python-Pipeline.py`)
- Coordinates tasks (`fetch_url`, `scrape_movies`, `parse_vote_count`, `insert_movies`).
- Features automatic fallback to `ingestion/movie_ratings.csv` if network access is restricted or offline.
- Writes to MySQL database `imdb_data` (created via `code/week4/exercises/Create-IMDB.sql`).

## Testing

Run the automated test suite verifying database transactions, idempotency, and retry behavior:

```bash
PYTHONPATH=week4/pipeline python3 -m unittest discover -s week4/pipeline/tests -v
```
