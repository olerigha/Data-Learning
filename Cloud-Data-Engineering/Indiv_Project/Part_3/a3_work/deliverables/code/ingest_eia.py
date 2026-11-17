"""
ingest_eia.py - live pull from the EIA Open Data API v2 (Bronze landing).

Two datasets enrich the campus energy domain:
  * ERCOT hourly demand (electricity/rto/region-data, respondent ERCO, type D),
    summer 2025 (same calendar window as the 2017 campus readings).
  * Texas commercial retail electricity price and sales, monthly 2017 -> latest
    (electricity/retail-sales, stateid TX, sectorid COM).

Every API page is written to disk exactly as returned (no transformation) together
with a manifest that records the request parameters (key removed), HTTP status,
row counts and ingestion time. pipeline.py loads these files into Bronze tables.

The API key is read from the EIA_API_KEY environment variable or, if that is not
set, from ~/.eia_api_key. It is never logged or written to disk.

Usage:
  python ingest_eia.py --out <bronze_raw_dir> [--page-size 500]
"""
import argparse
import json
import logging
import os
import random
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

import requests

BASE = "https://api.eia.gov/v2"
RETRY_STATUS = {429, 500, 502, 503, 504}
MAX_RETRIES = 6
PAUSE_BETWEEN_PAGES = 0.4   # seconds; EIA allows roughly 9,000 requests/hour, so this stays far below it
TIMEOUT = (10, 60)          # connect, read

DATASETS = {
    "eia_ercot_hourly_demand": {
        "route": "electricity/rto/region-data/data/",
        "params": {
            "frequency": "hourly",
            "data[0]": "value",
            "facets[respondent][]": "ERCO",
            "facets[type][]": "D",
            "start": "2025-07-01T05",   # 2025-07-01 00:00 US/Central, expressed in UTC
            "end": "2025-10-01T04",     # 2025-09-30 23:00 US/Central
            "sort[0][column]": "period",
            "sort[0][direction]": "asc",
        },
    },
    "eia_tx_commercial_retail_monthly": {
        "route": "electricity/retail-sales/data/",
        "params": {
            "frequency": "monthly",
            "data[0]": "price",
            "data[1]": "sales",
            "facets[stateid][]": "TX",
            "facets[sectorid][]": "COM",
            "start": "2017-01",
            "sort[0][column]": "period",
            "sort[0][direction]": "asc",
        },
    },
}

log = logging.getLogger("ingest_eia")


def load_api_key() -> str:
    key = os.environ.get("EIA_API_KEY")
    if not key:
        key_file = Path.home() / ".eia_api_key"
        if key_file.exists():
            key = key_file.read_text(encoding="utf-8").strip()
    if not key:
        sys.exit("No EIA API key found (set EIA_API_KEY or create ~/.eia_api_key).")
    return key


def get_with_retries(session: requests.Session, url: str, params: dict) -> requests.Response | None:
    """GET with exponential backoff. Honors Retry-After on 429/5xx. Returns None if every attempt fails."""
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            resp = session.get(url, params=params, timeout=TIMEOUT)
        except (requests.Timeout, requests.ConnectionError) as exc:
            wait = min(2 ** attempt, 60) + random.uniform(0, 1)
            log.warning("network error (%s) attempt %d/%d; retrying in %.1fs", type(exc).__name__, attempt, MAX_RETRIES, wait)
            time.sleep(wait)
            continue
        if resp.status_code == 200:
            return resp
        if resp.status_code in RETRY_STATUS:
            retry_after = resp.headers.get("Retry-After")
            wait = float(retry_after) if retry_after and retry_after.isdigit() else min(2 ** attempt, 60) + random.uniform(0, 1)
            log.warning("HTTP %d attempt %d/%d; retrying in %.1fs", resp.status_code, attempt, MAX_RETRIES, wait)
            time.sleep(wait)
            continue
        # 4xx other than 429 will not succeed on retry (bad parameter, bad key)
        log.error("HTTP %d, not retryable: %s", resp.status_code, resp.text[:200].replace("\n", " "))
        return None
    log.error("giving up after %d attempts", MAX_RETRIES)
    return None


def pull_dataset(session, api_key, name, spec, out_dir: Path, page_size: int) -> dict:
    url = f"{BASE}/{spec['route']}"
    run_dir = out_dir / name
    run_dir.mkdir(parents=True, exist_ok=True)
    offset, page_no, rows_total, total_reported = 0, 0, 0, None
    pages = []
    while True:
        params = {**spec["params"], "offset": offset, "length": page_size, "api_key": api_key}
        resp = get_with_retries(session, url, params)
        if resp is None:
            break
        try:
            body = resp.json()
        except ValueError:
            log.error("%s page %d: response is not JSON; stopping", name, page_no)
            break
        response = body.get("response") if isinstance(body, dict) else None
        if not isinstance(response, dict) or "data" not in response:
            log.error("%s page %d: missing 'response.data' (keys: %s); stopping",
                      name, page_no, list(body)[:5] if isinstance(body, dict) else type(body).__name__)
            break
        data = response.get("data") or []
        if total_reported is None:
            try:
                total_reported = int(response.get("total", 0))
            except (TypeError, ValueError):
                total_reported = None
        page_file = run_dir / f"page_{page_no:04d}.json"
        page_file.write_text(resp.text, encoding="utf-8")          # raw, byte-for-byte API payload
        pages.append({"page": page_no, "offset": offset, "rows": len(data), "http_status": resp.status_code,
                      "file": page_file.name})
        log.info("%s page %d offset %d -> %d rows (total reported %s)", name, page_no, offset, len(data), total_reported)
        rows_total += len(data)
        if not data:
            log.info("%s: empty page, done", name)
            break
        offset += len(data)
        page_no += 1
        if total_reported is not None and offset >= total_reported:
            break
        time.sleep(PAUSE_BETWEEN_PAGES)
    params_logged = {k: v for k, v in spec["params"].items()}
    manifest = {"source_name": name, "endpoint": f"{BASE}/{spec['route']}", "params": params_logged,
                "page_size": page_size, "pages": pages, "rows_total": rows_total,
                "total_reported": total_reported,
                "ingested_at": datetime.now(timezone.utc).isoformat(timespec="seconds")}
    (run_dir / "manifest.json").write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    return manifest


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="directory for raw Bronze files")
    ap.add_argument("--page-size", type=int, default=500)
    args = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", stream=sys.stdout)
    api_key = load_api_key()
    out = Path(args.out)
    with requests.Session() as session:
        session.headers["User-Agent"] = "campus-energy-pipeline/1.0"
        summary = [pull_dataset(session, api_key, n, s, out, args.page_size) for n, s in DATASETS.items()]
    for m in summary:
        log.info("SUMMARY %s: %d rows in %d pages (API total %s)", m["source_name"], m["rows_total"],
                 len(m["pages"]), m["total_reported"])
    grand = sum(m["rows_total"] for m in summary)
    log.info("SUMMARY all sources: %d records", grand)
    if grand < 500:
        sys.exit("fewer than 500 records retrieved")


if __name__ == "__main__":
    main()
