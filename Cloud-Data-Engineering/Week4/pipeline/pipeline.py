"""Automated end-to-end data pipeline for 2020 IMDb movies.

Demonstrates production engineering practices:
1. Configuration Management: Externalized config.yaml with ${VAR:-default} env overrides.
2. Ingestion: Web scraping with BeautifulSoup and automatic local fixture fallback.
3. Structured Logging: Formatted log messages with execution durations and row counts.
4. Resilience: Retries with exponential backoff on transient database errors.
5. Idempotency: Atomic transactions with INSERT ... ON DUPLICATE KEY UPDATE.
6. Orchestration: Prefect flow and tasks.
"""

from __future__ import annotations

import csv
import logging
import os
from pathlib import Path

# Disable external Prefect telemetry pings when running in restricted/offline environments
os.environ.setdefault("PREFECT_SERVER_ANALYTICS_ENABLED", "false")
import re
import sys
import time
from typing import Any, Callable, Sequence

from bs4 import BeautifulSoup
import mysql.connector
from prefect import flow, task
import requests
import yaml

# ─────────────────────────────────────────────────────────────────────────────
# Configuration Management Layer
# ─────────────────────────────────────────────────────────────────────────────

DEFAULT_CONFIG_PATH = Path(__file__).resolve().parent / "config.yaml"


def load_config(config_path: str | Path | None = None) -> dict[str, Any]:
    """Load pipeline YAML configuration and resolve ${VAR:-default} placeholders."""
    path = Path(config_path) if config_path else DEFAULT_CONFIG_PATH
    if not path.exists():
        return {}

    with open(path, encoding="utf-8") as f:
        content = f.read()

    def _resolve(match: re.Match[str]) -> str:
        expr = match.group(1)
        if ":-" in expr:
            var_name, default = expr.split(":-", 1)
        else:
            var_name, default = expr, ""
        return os.environ.get(var_name, default)

    resolved = re.sub(r"\$\{([^}]+)\}", _resolve, content)
    return yaml.safe_load(resolved) or {}


CONFIG = load_config()

# Logger configuration (console + file)
LOG_LEVEL = CONFIG.get("settings", {}).get("log_level", "INFO")
LOG_FILE = CONFIG.get("settings", {}).get("log_file", "pipeline.log")

logger = logging.getLogger("movie_pipeline")
logger.setLevel(getattr(logging, str(LOG_LEVEL).upper(), logging.INFO))
logger.propagate = False
logger.handlers.clear()

log_formatter = logging.Formatter("%(asctime)s %(levelname)s %(name)s %(message)s")

_console_handler = logging.StreamHandler(sys.stdout)
_console_handler.setFormatter(log_formatter)
logger.addHandler(_console_handler)

if LOG_FILE:
    log_file_path = Path(__file__).resolve().parent / LOG_FILE
    _file_handler = logging.FileHandler(log_file_path, mode="a", encoding="utf-8")
    _file_handler.setFormatter(log_formatter)
    logger.addHandler(_file_handler)

# DB Configuration externalized from YAML / Environment
DB_CONFIG = {
    "host": CONFIG.get("database", {}).get("host", "localhost"),
    "port": int(CONFIG.get("database", {}).get("port", 3306)),
    "user": CONFIG.get("database", {}).get("user", "root"),
    "password": CONFIG.get("database", {}).get("password", ""),
    "database": CONFIG.get("database", {}).get("database", "imdb_data"),
}

INGESTION_CONFIG = CONFIG.get("ingestion", {})
SETTINGS_CONFIG = CONFIG.get("settings", {})

FIXTURE_REL_PATH = INGESTION_CONFIG.get("fallback_fixture_path", "data/movie_ratings.csv")
FIXTURE_PATH = Path(__file__).resolve().parent / FIXTURE_REL_PATH
SCHEMA_PATH = Path(__file__).resolve().parent / "Create-IMDB.sql"

# ─────────────────────────────────────────────────────────────────────────────
# Database Layer (Resilience, Retries, Idempotency)
# ─────────────────────────────────────────────────────────────────────────────

UPSERT_MOVIES_SQL = """
INSERT INTO movies (name, year, imdb_rating, votes)
VALUES (%s, %s, %s, %s)
ON DUPLICATE KEY UPDATE
    imdb_rating = VALUES(imdb_rating),
    votes = VALUES(votes)
"""

# MySQL Error numbers considered transient / retryable:
# 1205: ER_LOCK_WAIT_TIMEOUT, 1213: ER_LOCK_DEADLOCK, 2006: CR_SERVER_GONE_ERROR, 2013: CR_SERVER_LOST
TRANSIENT_ERRNO = {1205, 1213, 2006, 2013}
TRANSIENT_PHRASES = ("deadlock", "lock wait timeout", "lost connection", "server has gone away")


def is_transient_db_error(exc: BaseException) -> bool:
    """Determine whether an exception is a transient database condition suitable for retry."""
    errno = getattr(exc, "errno", None)
    if errno in TRANSIENT_ERRNO:
        return True
    message = str(exc).lower()
    return any(phrase in message for phrase in TRANSIENT_PHRASES)


def write_movies(
    connect: Callable[..., Any],
    configuration: dict[str, Any],
    movies_data: Sequence[tuple[Any, ...]],
    max_retries: int | None = None,
    base_delay: float | None = None,
) -> int:
    """Upsert movie rows with retry on transient errors and atomic transaction safety.

    Args:
        connect: Factory callable returning a DB-API 2.0 connection.
        configuration: Connection kwargs passed to `connect`.
        movies_data: Sequence of (name, year, imdb_rating, votes) tuples.
        max_retries: Maximum attempts on transient database errors (defaults to config).
        base_delay: Initial backoff delay in seconds (defaults to config).

    Returns:
        Number of affected rows reported by the database cursor.
    """
    if not movies_data:
        return 0

    retries_limit = max_retries if max_retries is not None else int(SETTINGS_CONFIG.get("max_retries", 3))
    delay = base_delay if base_delay is not None else float(SETTINGS_CONFIG.get("retry_delay_seconds", 0.05))

    for attempt in range(1, retries_limit + 1):
        connection = None
        cursor = None
        start_time = time.perf_counter()
        try:
            connection = connect(**configuration)
            cursor = connection.cursor()
            cursor.executemany(UPSERT_MOVIES_SQL, movies_data)
            connection.commit()
            duration_ms = (time.perf_counter() - start_time) * 1000
            rowcount = cursor.rowcount
            logger.info(
                "query=upsert_movies status=success rows_affected=%d duration_ms=%.2f attempt=%d",
                rowcount,
                duration_ms,
                attempt,
            )
            return rowcount
        except Exception as exc:
            duration_ms = (time.perf_counter() - start_time) * 1000
            if connection is not None:
                try:
                    connection.rollback()
                except Exception:
                    pass

            errno = getattr(exc, "errno", None)
            if errno == 1049 and attempt < retries_limit:
                target_db = configuration.get("database", "imdb_data")
                logger.warning(
                    "database %s not found (errno 1049); auto-initializing from %s",
                    target_db,
                    SCHEMA_PATH.name,
                )
                try:
                    admin_cfg = {k: v for k, v in configuration.items() if k != "database"}
                    admin_conn = connect(**admin_cfg)
                    admin_cur = admin_conn.cursor()
                    if SCHEMA_PATH.exists():
                        with open(SCHEMA_PATH, encoding="utf-8") as sf:
                            for raw_stmt in sf.read().split(";"):
                                stmt = raw_stmt.strip()
                                if stmt:
                                    admin_cur.execute(stmt)
                    else:
                        admin_cur.execute(f"CREATE DATABASE IF NOT EXISTS `{target_db}`")
                    admin_conn.commit()
                    admin_cur.close()
                    admin_conn.close()
                    logger.info("database %s schema successfully initialized", target_db)
                    continue
                except Exception as init_exc:
                    logger.warning("could not auto-initialize schema: %s", init_exc)

            is_transient = is_transient_db_error(exc)
            if is_transient and attempt < retries_limit:
                logger.warning(
                    "query=upsert_movies status=transient_retry attempt=%d max_retries=%d sleep_s=%.2f error=%s",
                    attempt,
                    retries_limit,
                    delay,
                    exc,
                )
                time.sleep(delay)
                delay *= 2
                continue

            logger.error(
                "query=upsert_movies status=failed duration_ms=%.2f attempt=%d error=%s",
                duration_ms,
                attempt,
                exc,
            )
            raise
        finally:
            if cursor is not None:
                try:
                    cursor.close()
                except Exception:
                    pass
            if connection is not None:
                try:
                    connection.close()
                except Exception:
                    pass


# ─────────────────────────────────────────────────────────────────────────────
# Extraction & Transformation Layer
# ─────────────────────────────────────────────────────────────────────────────

@task
def fetch_url(url: str, headers: dict[str, str], timeout: int | None = None):
    """Fetch the URL and return the response content, or None on failure."""
    req_timeout = timeout if timeout is not None else int(INGESTION_CONFIG.get("request_timeout_seconds", 10))
    try:
        response = requests.get(url, headers=headers, timeout=req_timeout)
        if response.status_code == 200:
            logger.info("fetched url=%s", url)
            return response.content
        logger.warning("fetch_failed url=%s status=%d", url, response.status_code)
    except Exception as exc:
        logger.warning("fetch_error url=%s error=%s", url, exc)
    return None


@task
def parse_vote_count(vote_text: str | None) -> int | None:
    """Convert vote count text (e.g. '125K', '1.2M', '(450)') to an integer."""
    if not vote_text:
        return None
    cleaned = vote_text.replace("(", "").replace(")", "").replace("K", "000").strip()
    digits_and_symbols = "".join(ch for ch in cleaned if ch.isdigit() or ch in [".", "M"])

    try:
        if "M" in cleaned:
            return int(float(digits_and_symbols.replace("M", "")) * 1_000_000)
        return int(float(digits_and_symbols))
    except (ValueError, TypeError):
        return None


@task
def load_fallback_fixture(year: int):
    """Load local cached 2020 movies when external network or scraping is unavailable."""
    if not FIXTURE_PATH.exists():
        logger.warning("fixture not found at %s", FIXTURE_PATH)
        return []
    records = []
    with open(FIXTURE_PATH, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if str(row.get("year", "")).strip() == str(year):
                name = re.sub(r"^\d+\.\s*", "", row.get("movie", "")).strip()
                imdb = float(row["imdb"]) if row.get("imdb") else None
                votes = int(float(row["votes"])) if row.get("votes") else None
                records.append((name, str(year), imdb, votes))
    logger.info("loaded fallback records=%d from %s", len(records), FIXTURE_PATH.name)
    return records


@task
def scrape_movies(year: int):
    """Scrape movies for a specific year, with fallback to local cached fixture."""
    url_template = INGESTION_CONFIG.get(
        "search_url_template",
        "https://www.imdb.com/search/title/?release_date={year}-01-01,{year}-12-31",
    )
    url = url_template.format(year=year)
    user_agent = INGESTION_CONFIG.get(
        "user_agent",
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    )
    headers = {"User-Agent": user_agent}

    page_html = fetch_url(url, headers)
    if page_html is None:
        logger.info("falling back to local fixture for year=%d", year)
        return load_fallback_fixture(year)

    soup = BeautifulSoup(page_html, "html.parser")
    mv_containers = soup.find_all("li", class_="ipc-metadata-list-summary-item")

    if not mv_containers:
        logger.info("no containers parsed from html; using local fixture")
        return load_fallback_fixture(year)

    movies_data = []
    for container in mv_containers:
        name_tag = container.find("h3", class_="ipc-title__text")
        raw_name = name_tag.get_text(strip=True) if name_tag else ""
        name = re.sub(r"^\d+\.\s*", "", raw_name).strip() if raw_name else None

        year_tag = container.find("span", class_=lambda x: x and "metadata-item" in x)
        year_text = year_tag.get_text(strip=True).split("–")[0] if year_tag else str(year)

        imdb_tag = container.find("span", class_="ipc-rating-star--rating")
        try:
            imdb_rating = float(imdb_tag.get_text(strip=True)) if imdb_tag else None
        except ValueError:
            imdb_rating = None

        vote_tag = container.find("span", class_=lambda x: x and "voteCount" in x)
        votes = parse_vote_count(vote_tag.get_text(strip=True)) if vote_tag else None

        if name:
            movies_data.append((name, year_text, imdb_rating, votes))

    return movies_data


@task
def insert_movies(movies_data):
    """Idempotently insert movie records into the MySQL database with retries."""
    try:
        row_count = write_movies(mysql.connector.connect, DB_CONFIG, movies_data)
        logger.info("upserted rows=%d", row_count)
    except Exception as error:
        logger.error("db_error error=%s", error, exc_info=False)
        raise


@flow
def data_pipeline(start_year: int | None = None, end_year: int | None = None):
    """Main pipeline to extract, clean, and store 2020 IMDb movies."""
    default_year = int(CONFIG.get("pipeline", {}).get("target_year", 2020))
    from_year = start_year if start_year is not None else default_year
    to_year = end_year if end_year is not None else default_year

    all_movies = []
    for year in range(from_year, to_year + 1):
        logger.info("processing year=%d", year)
        movies_data = scrape_movies(year)
        all_movies.extend(movies_data)

    if all_movies:
        insert_movies(all_movies)
    return len(all_movies)


if __name__ == "__main__":
    # Standardized on 2020 IMDb movie release data
    data_pipeline()
