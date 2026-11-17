"""
dynamo_load.py - load the campus meter telemetry into DynamoDB table CampusEnergy (single-table design).

Item types
  Meter profile   PK = METER#<meter_code>   SK = PROFILE
  Daily reading   PK = METER#<meter_code>   SK = DATE#<yyyy-mm-dd>
                  GSI1PK = BLDG#<building>  GSI1SK = DATE#<yyyy-mm-dd>#<utility>      (building/day view)
                  GSI2PK = DQ#PARTIAL       GSI2SK = DATE#<yyyy-mm-dd>#<meter_code>   (sparse: only days with <24 hours reported)

Source: the warehouse star schema built by pipeline.py (fact_daily_energy + dimensions), so DynamoDB holds
the same cleaned, PII-masked values as the warehouse.

Usage: python dynamo_load.py --host <mysql host> --user <user> [--port 3306] [--ssl-ca <pem>] [--table CampusEnergy]
AWS credentials come from the standard boto3 chain (profile/env); region us-east-2.
"""
import argparse
import getpass
import os
import time
from decimal import Decimal

import boto3
import pymysql

READINGS_SQL = """
SELECT f.meter_code, d.full_date, b.building_bk, b.primary_usage, b.sub_usage, u.utility_code, u.unit,
       f.consumption_kwh, f.peak_hour_kwh, f.peak_hour, f.hours_reported, f.cost_current_usd, f.on_grid_peak_hour,
       w.max_air_temp_c
FROM fact_daily_energy f
JOIN dim_date d     ON d.date_key = f.date_key
JOIN dim_building b ON b.building_key = f.building_key
JOIN dim_utility u  ON u.utility_key = f.utility_key
JOIN dim_weather w  ON w.weather_key = f.weather_key
"""
PROFILE_SQL = """
SELECT DISTINCT f.meter_code, b.building_bk, b.primary_usage, b.sub_usage, b.gross_sqm, b.site_name,
       b.site_lat_1dp, b.site_lng_1dp, u.utility_code, u.unit, u.rate_basis
FROM fact_daily_energy f
JOIN dim_building b ON b.building_bk = (SELECT building_bk FROM dim_building WHERE building_key = f.building_key)
                   AND b.is_current = 1
JOIN dim_utility u  ON u.utility_key = f.utility_key
"""


def dec(x):
    return None if x is None else Decimal(str(x))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--host", required=True); ap.add_argument("--port", type=int, default=3306)
    ap.add_argument("--user", required=True); ap.add_argument("--ssl-ca")
    ap.add_argument("--table", default="CampusEnergy"); ap.add_argument("--region", default="us-east-2")
    a = ap.parse_args()
    pwd = os.environ.get("MYSQL_PWD")
    if pwd is None:
        pwd = getpass.getpass("MySQL password: ")
    conn = pymysql.connect(host=a.host, port=a.port, user=a.user, password=pwd, database="campus_dw",
                           ssl={"ca": a.ssl_ca} if a.ssl_ca else None)
    del pwd
    with conn.cursor(pymysql.cursors.DictCursor) as cur:
        cur.execute(PROFILE_SQL); profiles = cur.fetchall()
        cur.execute(READINGS_SQL); readings = cur.fetchall()
    conn.close()

    table = boto3.resource("dynamodb", region_name=a.region).Table(a.table)
    t0 = time.time()
    with table.batch_writer(overwrite_by_pkeys=["PK", "SK"]) as bw:
        for p in profiles:
            bw.put_item(Item={
                "PK": f"METER#{p['meter_code']}", "SK": "PROFILE", "entity": "meter_profile",
                "meter_code": p["meter_code"], "building": p["building_bk"], "primary_usage": p["primary_usage"],
                "sub_usage": p["sub_usage"], "gross_sqm": dec(p["gross_sqm"]), "site": p["site_name"],
                "site_lat_1dp": dec(p["site_lat_1dp"]), "site_lng_1dp": dec(p["site_lng_1dp"]),
                "utility": p["utility_code"], "unit": p["unit"], "rate_basis": p["rate_basis"]})
        for r in readings:
            day = r["full_date"].isoformat()
            item = {
                "PK": f"METER#{r['meter_code']}", "SK": f"DATE#{day}", "entity": "daily_reading",
                "meter_code": r["meter_code"], "reading_date": day, "building": r["building_bk"],
                "primary_usage": r["primary_usage"], "utility": r["utility_code"],
                "kwh": dec(r["consumption_kwh"]), "peak_kwh": dec(r["peak_hour_kwh"]), "peak_hour": int(r["peak_hour"]),
                "hours_reported": int(r["hours_reported"]), "cost_current_usd": dec(r["cost_current_usd"]),
                "on_grid_peak_hour": bool(r["on_grid_peak_hour"]), "max_temp_c": dec(r["max_air_temp_c"]),
                "GSI1PK": f"BLDG#{r['building_bk']}", "GSI1SK": f"DATE#{day}#{r['utility_code']}"}
            if int(r["hours_reported"]) < 24:      # sparse index: only incomplete days are projected into GSI2
                item["GSI2PK"] = "DQ#PARTIAL"
                item["GSI2SK"] = f"DATE#{day}#{r['meter_code']}"
            bw.put_item(Item=item)
    print(f"loaded {len(profiles)} meter profiles + {len(readings)} daily readings "
          f"= {len(profiles) + len(readings)} items in {time.time() - t0:.0f}s")
    desc = boto3.client("dynamodb", region_name=a.region).describe_table(TableName=a.table)["Table"]
    print(f"table {a.table}: status {desc['TableStatus']}, billing {desc['BillingModeSummary']['BillingMode']}, "
          f"approx item count {desc['ItemCount']} (DynamoDB refreshes this about every 6 hours)")


if __name__ == "__main__":
    main()
