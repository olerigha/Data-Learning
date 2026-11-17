"""
pipeline.py - Medallion pipeline (Bronze -> Silver -> Gold) and star-schema load for campus_dw.

Steps
  1. DDL for Bronze/Silver/Gold staging tables (sql/01_medallion_ddl.sql).
  2. Bronze: land every EIA API record exactly as returned (JSON) plus the Assignment 2
     daily meter readings (all columns as text), each row stamped with ingested_at and source_name.
  3. Data-quality checks on Bronze before any transformation: null, duplicate, range and format
     checks per source. Pass/fail counts are logged to dq_check_log; failing rows are quarantined.
  4. Silver: type-cast, convert ERCOT periods from UTC to US/Central, standardize casing, and mask
     the site GPS coordinates (1-decimal generalization + salted SHA-256 token) before writing.
  5. Gold (sql/02_gold_build.sql) and the star schema with SCD2 (sql/03_star_schema_etl.sql).

Usage
  python pipeline.py --host <host> --user <user> --raw-dir <bronze_raw> --campus-csv <flat csv>
                     --sql-dir <sql dir> [--port 3306] [--ssl-ca <pem>]
The MySQL password comes from MYSQL_PWD or an interactive prompt. The masking salt comes from
PII_SALT; in production it would live in AWS Secrets Manager rather than in the environment.
"""
import argparse
import csv
import getpass
import hashlib
import json
import logging
import os
import re
import sys
import uuid
from datetime import datetime, timezone
from pathlib import Path

import pandas as pd
import pymysql

log = logging.getLogger("pipeline")
RUN_ID = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "-" + uuid.uuid4().hex[:6]
NOW = datetime.now(timezone.utc).replace(tzinfo=None, microsecond=0)
SALT = os.environ.get("PII_SALT", "campus-energy-dev-salt")


# ---------------------------------------------------------------- helpers
def run_sql_file(cur, path: Path):
    text = "\n".join(line for line in path.read_text(encoding="utf-8").splitlines()
                     if not line.strip().startswith("--"))
    for stmt in re.split(r";\s*\n", text):
        if stmt.strip():
            cur.execute(stmt)
            if cur.description:
                cur.fetchall()
    log.info("ran %s", path.name)


def insert_many(cur, table, cols, rows, batch=1000):
    sql = f"INSERT INTO {table} ({', '.join(cols)}) VALUES ({', '.join(['%s'] * len(cols))})"
    for i in range(0, len(rows), batch):
        cur.executemany(sql, rows[i:i + batch])


def log_check(cur, source, name, ctype, passed_mask: pd.Series):
    n, ok = len(passed_mask), int(passed_mask.sum())
    cur.execute("INSERT INTO dq_check_log (run_id, source_name, check_name, check_type, rows_checked, rows_passed, "
                "rows_failed, checked_at) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
                (RUN_ID, source, name, ctype, n, ok, n - ok, NOW))
    log.info("DQ %-34s %-38s checked=%6d passed=%6d failed=%5d", source, name, n, ok, n - ok)


def mask_coords(lat: float, lng: float) -> tuple:
    token = hashlib.sha256(f"{SALT}|{lat:.6f},{lng:.6f}".encode()).hexdigest()
    return round(lat, 1), round(lng, 1), token


# ---------------------------------------------------------------- bronze
def load_bronze(cur, raw_dir: Path, campus_csv: Path):
    for src_dir in sorted(p for p in raw_dir.iterdir() if p.is_dir()):
        manifest = json.loads((src_dir / "manifest.json").read_text(encoding="utf-8"))
        ingested = datetime.fromisoformat(manifest["ingested_at"]).replace(tzinfo=None)
        rows = []
        for page in manifest["pages"]:
            body = json.loads((src_dir / page["file"]).read_text(encoding="utf-8"))
            for rec in body.get("response", {}).get("data", []):
                rows.append((manifest["source_name"], page["file"], page["page"], json.dumps(rec), ingested))
        insert_many(cur, "bronze_eia_raw", ["source_name", "source_file", "page_no", "record_json", "ingested_at"], rows)
        log.info("bronze_eia_raw <- %s: %d records", manifest["source_name"], len(rows))
    with campus_csv.open(newline="", encoding="utf-8") as fh:
        rdr = csv.reader(fh)
        header = next(rdr)
        rows = [r + ["a2_campus_energy_flat", NOW] for r in rdr]
    insert_many(cur, "bronze_campus_reading", header + ["source_name", "ingested_at"], rows)
    log.info("bronze_campus_reading <- %s: %d rows", campus_csv.name, len(rows))


def read_bronze_eia(conn, source):
    df = pd.read_sql("SELECT raw_id, record_json FROM bronze_eia_raw WHERE source_name = %s", conn, params=(source,))
    recs = pd.json_normalize([json.loads(x) for x in df.record_json])
    recs.insert(0, "raw_id", df.raw_id.values)
    recs["record_json"] = df.record_json.values
    return recs


# ---------------------------------------------------------------- quality checks
def run_checks(cur, source, df, checks):
    """checks: list of (name, type, bool Series of rows that pass). Returns mask of rows passing all checks."""
    failed = pd.Series([[] for _ in range(len(df))], index=df.index)
    for name, ctype, ok in checks:
        ok = ok.fillna(False).astype(bool)
        log_check(cur, source, name, ctype, ok)
        for i in df.index[~ok]:
            failed[i].append(name)
    bad = failed.map(len) > 0
    q = [(source, int(df.at[i, "raw_id"]), "; ".join(failed[i]), df.at[i, "record_json"], NOW) for i in df.index[bad]]
    insert_many(cur, "silver_quarantine", ["source_name", "raw_id", "failed_checks", "record_json", "quarantined_at"], q)
    log.info("QUARANTINE %s: %d rows rejected, %d rows pass to Silver", source, int(bad.sum()), int((~bad).sum()))
    return ~bad


def num(s):
    return pd.to_numeric(s, errors="coerce")


def silver_ercot(conn, cur):
    src = "eia_ercot_hourly_demand"
    df = read_bronze_eia(conn, src)
    v = num(df["value"])
    ok = run_checks(cur, src, df, [
        ("null: period and value present", "null", df["period"].notna() & df["value"].notna() & (df["value"].astype(str) != "")),
        ("duplicate: (respondent, type, period)", "duplicate", ~df.duplicated(["respondent", "type", "period"], keep="first")),
        ("range: 20,000 <= demand_mwh <= 120,000", "range", v.between(20000, 120000)),
        ("format: period = YYYY-MM-DDTHH", "format", df["period"].astype(str).str.fullmatch(r"\d{4}-\d{2}-\d{2}T\d{2}")),
    ])
    d = df[ok].copy()
    utc = pd.to_datetime(d["period"], format="%Y-%m-%dT%H").dt.tz_localize("UTC")
    local = utc.dt.tz_convert("America/Chicago")
    rows = list(zip(utc.dt.tz_localize(None).dt.to_pydatetime(), local.dt.tz_localize(None).dt.to_pydatetime(),
                    local.dt.date, local.dt.hour.astype(int), num(d["value"]).astype(int)))
    insert_many(cur, "silver_ercot_hourly", ["period_utc", "period_local", "local_date", "local_hour", "demand_mwh"], rows)
    log.info("silver_ercot_hourly: %d rows", len(rows))


def silver_price(conn, cur):
    src = "eia_tx_commercial_retail_monthly"
    df = read_bronze_eia(conn, src)
    p, s = num(df["price"]), num(df["sales"])
    ok = run_checks(cur, src, df, [
        ("null: period, price, sales present", "null", df["period"].notna() & p.notna() & s.notna()),
        ("duplicate: (stateid, sectorid, period)", "duplicate", ~df.duplicated(["stateid", "sectorid", "period"], keep="first")),
        ("range: 1 <= price <= 50 cents, sales > 0", "range", p.between(1, 50) & (s > 0)),
        ("format: period = YYYY-MM", "format", df["period"].astype(str).str.fullmatch(r"\d{4}-\d{2}")),
    ])
    d = df[ok]
    rows = list(zip(pd.to_datetime(d["period"] + "-01").dt.date, num(d["price"]).round(2), num(d["sales"]).round(3)))
    insert_many(cur, "silver_tx_price_monthly", ["price_month", "price_cents_kwh", "sales_million_kwh"], rows)
    log.info("silver_tx_price_monthly: %d rows", len(rows))


def silver_campus(conn, cur):
    src = "a2_campus_energy_flat"
    df = pd.read_sql("SELECT * FROM bronze_campus_reading", conn)
    df["record_json"] = df.drop(columns=["ingested_at"]).to_json(orient="records", lines=True).splitlines()
    kwh, hrs, ph = num(df["daily_consumption_kwh"]), num(df["hours_reported"]), num(df["peak_hour"])
    ok = run_checks(cur, src, df, [
        ("null: consumption_kwh present", "null", kwh.notna()),
        ("duplicate: (meter_code, reading_date)", "duplicate", ~df.duplicated(["meter_code", "reading_date"], keep="first")),
        ("range: kWh>=0, 1<=hours<=24, 0<=peak_hour<=23", "range", (kwh >= 0) & hrs.between(1, 24) & ph.between(0, 23)),
        ("format: reading_date = YYYY-MM-DD", "format", df["reading_date"].astype(str).str.fullmatch(r"\d{4}-\d{2}-\d{2}")),
    ])
    d = df[ok].copy()
    masked = [mask_coords(float(a), float(b)) for a, b in zip(d["lat"], d["lng"])]
    d["sub_usage"] = d["sub_space_usage"].str.strip().str.title()   # 'office' -> 'Office', 'garage' -> 'Garage'
    rows = [(r.reading_date, r.meter_code, r.building_name, r.utility_type, r.unit, r.primary_space_usage, r.sub_usage,
             float(r.gross_sqm), r.site_name, m[0], m[1], m[2], float(r.daily_consumption_kwh), float(r.peak_hour_kwh),
             int(float(r.peak_hour)), int(r.hours_reported),
             float(r.avg_air_temp_c) if r.avg_air_temp_c else None, float(r.max_air_temp_c) if r.max_air_temp_c else None)
            for r, m in zip(d.itertuples(index=False), masked)]
    insert_many(cur, "silver_campus_reading",
                ["reading_date", "meter_code", "building_name", "utility_code", "unit", "primary_usage", "sub_usage",
                 "gross_sqm", "site_name", "site_lat_1dp", "site_lng_1dp", "site_geo_token", "consumption_kwh",
                 "peak_hour_kwh", "peak_hour", "hours_reported", "avg_air_temp_c", "max_air_temp_c"], rows)
    log.info("silver_campus_reading: %d rows (GPS masked)", len(rows))


# ---------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", required=True); ap.add_argument("--port", type=int, default=3306)
    ap.add_argument("--user", required=True); ap.add_argument("--ssl-ca")
    ap.add_argument("--raw-dir", required=True); ap.add_argument("--campus-csv", required=True)
    ap.add_argument("--sql-dir", required=True)
    a = ap.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", stream=sys.stdout)
    pwd = os.environ.get("MYSQL_PWD")
    if pwd is None:
        pwd = getpass.getpass("MySQL password: ")
    conn = pymysql.connect(host=a.host, port=a.port, user=a.user, password=pwd, charset="utf8mb4",
                           ssl={"ca": a.ssl_ca} if a.ssl_ca else None, autocommit=False, local_infile=False)
    del pwd
    sql_dir = Path(a.sql_dir)
    log.info("run_id %s", RUN_ID)
    with conn.cursor() as cur:
        run_sql_file(cur, sql_dir / "01_medallion_ddl.sql"); conn.commit()
        load_bronze(cur, Path(a.raw_dir), Path(a.campus_csv)); conn.commit()
        silver_ercot(conn, cur); silver_price(conn, cur); silver_campus(conn, cur); conn.commit()
        run_sql_file(cur, sql_dir / "02_gold_build.sql"); conn.commit()
        run_sql_file(cur, sql_dir / "03_star_schema_etl.sql"); conn.commit()
        cur.execute("""SELECT 'bronze_eia_raw', COUNT(*) FROM bronze_eia_raw UNION ALL
                       SELECT 'bronze_campus_reading', COUNT(*) FROM bronze_campus_reading UNION ALL
                       SELECT 'silver_quarantine', COUNT(*) FROM silver_quarantine UNION ALL
                       SELECT 'silver_ercot_hourly', COUNT(*) FROM silver_ercot_hourly UNION ALL
                       SELECT 'silver_tx_price_monthly', COUNT(*) FROM silver_tx_price_monthly UNION ALL
                       SELECT 'silver_campus_reading', COUNT(*) FROM silver_campus_reading UNION ALL
                       SELECT 'gold_building_month_cost', COUNT(*) FROM gold_building_month_cost UNION ALL
                       SELECT 'gold_peak_hour_alignment', COUNT(*) FROM gold_peak_hour_alignment UNION ALL
                       SELECT 'dim_date', COUNT(*) FROM dim_date UNION ALL
                       SELECT 'dim_building', COUNT(*) FROM dim_building UNION ALL
                       SELECT 'dim_utility', COUNT(*) FROM dim_utility UNION ALL
                       SELECT 'dim_weather', COUNT(*) FROM dim_weather UNION ALL
                       SELECT 'fact_daily_energy', COUNT(*) FROM fact_daily_energy""")
        for name, n in cur.fetchall():
            log.info("COUNT %-26s %7d", name, n)
    conn.close()


if __name__ == "__main__":
    main()
