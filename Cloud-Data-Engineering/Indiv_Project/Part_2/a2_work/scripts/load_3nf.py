"""
load_3nf.py — load the 9 normalized CSVs into MySQL in FK-safe order, then print row counts.

  python -I load_3nf.py --host <HOST> --port 3306 --user <USER> --csv-dir <DIR> [--ssl-ca <PEM>]

Password: read from the MYSQL_PWD environment variable if set, otherwise prompted (hidden).
It is never written to disk or printed. Assumes schema.sql has already been run.
Idempotent: each table is emptied before loading (children first).
"""
import argparse, csv, getpass, os, sys, time
import pymysql

ORDER = ["site", "space_usage", "building", "utility_type", "meter",
         "weather_daily", "eia_price_monthly", "tariff_rate", "daily_reading"]

ap = argparse.ArgumentParser()
ap.add_argument("--host", required=True); ap.add_argument("--port", type=int, default=3306)
ap.add_argument("--user", required=True); ap.add_argument("--db", default="campus_energy")
ap.add_argument("--csv-dir", required=True); ap.add_argument("--ssl-ca", default=None)
ap.add_argument("--batch", type=int, default=2000)
a = ap.parse_args()

pwd = os.environ.get("MYSQL_PWD")
if pwd is None:
    pwd = getpass.getpass("MySQL password: ")
ssl = {"ca": a.ssl_ca} if a.ssl_ca else None
conn = pymysql.connect(host=a.host, port=a.port, user=a.user, password=pwd, database=a.db,
                       ssl=ssl, autocommit=False, charset="utf8mb4")
del pwd
cur = conn.cursor()

cur.execute("SET FOREIGN_KEY_CHECKS = 0")
for t in reversed(ORDER):
    cur.execute(f"DELETE FROM `{t}`")
cur.execute("SET FOREIGN_KEY_CHECKS = 1")
conn.commit()

t0 = time.time()
for t in ORDER:
    with open(os.path.join(a.csv_dir, f"{t}.csv"), newline="", encoding="utf-8") as fh:
        rdr = csv.reader(fh)
        cols = next(rdr)
        rows = [[None if v == "" else v for v in r] for r in rdr]
    # space_usage is self-referencing: load roots (parent NULL) before children
    if t == "space_usage":
        pi = cols.index("parent_usage_id")
        rows.sort(key=lambda r: (r[pi] is not None, int(r[0])))
    sql = f"INSERT INTO `{t}` ({', '.join('`'+c+'`' for c in cols)}) VALUES ({', '.join(['%s']*len(cols))})"
    for i in range(0, len(rows), a.batch):
        cur.executemany(sql, rows[i:i + a.batch])
    conn.commit()
    print(f"loaded {t:18s} {len(rows):>7,} rows")
print(f"load time {time.time() - t0:.1f}s")

cur.execute(" UNION ALL ".join(f"SELECT '{t}' AS table_name, COUNT(*) AS row_count FROM `{t}`" for t in ORDER))
total = 0
print("\nVERIFY (SELECT COUNT(*) per table):")
for name, n in cur.fetchall():
    total += n; print(f"  {name:18s} {n:>7,}")
print(f"  {'TOTAL':18s} {total:>7,}")
conn.close()
