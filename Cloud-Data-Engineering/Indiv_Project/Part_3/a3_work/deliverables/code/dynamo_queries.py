"""
dynamo_queries.py - DynamoDB queries for table CampusEnergy (boto3).

Part 3 (access patterns)
  AP1  Daily readings for one meter over a date range          -> base table Query, PK + SK BETWEEN
  AP2  Every utility reading for one building on one day        -> GSI1 Query, PK + begins_with(SK)
  AP3  Incomplete-data meter-days across campus in a date range -> sparse GSI2 Query, PK + SK BETWEEN

Part 4b (DynamoDB strengths)
  N1   Meter profile plus its latest 7 readings in ONE request   -> item collection, descending, Limit
  N2   A building's peak chilled-water week across all utilities, projected to a few attributes -> GSI1 + ProjectionExpression
  N3   Single meter-day lookup for a dashboard tile               -> GetItem by full primary key

Every call reports ConsumedCapacity so read cost can be compared in the report.
Usage: python dynamo_queries.py [--table CampusEnergy] [--region us-east-2] [--only AP1,N1,...]
"""
import argparse
from boto3.dynamodb.conditions import Key
import boto3

METER = "Bull_education_Dottie|electricity"
BUILDING = "Bull_education_Dottie"


def show(title, question, resp, cols):
    items = resp.get("Items") or ([resp["Item"]] if "Item" in resp else [])
    cc = resp.get("ConsumedCapacity", {})
    print("=" * 110)
    print(title)
    print("Business question:", question)
    print(f"items returned: {len(items)} | scanned: {resp.get('ScannedCount', len(items))} | "
          f"consumed read capacity units: {cc.get('CapacityUnits')}")
    print("-" * 110)
    print(" | ".join(f"{c:<22}" for c in cols))
    for it in items:
        print(" | ".join(f"{str(it.get(c, '')):<22}" for c in cols))
    print()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--table", default="CampusEnergy"); ap.add_argument("--region", default="us-east-2")
    ap.add_argument("--only", default="")
    a = ap.parse_args()
    only = {x.strip().upper() for x in a.only.split(",") if x.strip()}
    t = boto3.resource("dynamodb", region_name=a.region).Table(a.table)
    rc = {"ReturnConsumedCapacity": "TOTAL"}

    def want(code):
        return not only or code in only

    if want("AP1"):
        show("AP1  Query base table: one meter, date range",
             f"What did meter {METER} use each day of 8-14 August 2017?",
             t.query(KeyConditionExpression=Key("PK").eq(f"METER#{METER}")
                     & Key("SK").between("DATE#2017-08-08", "DATE#2017-08-14"), **rc),
             ["SK", "kwh", "peak_kwh", "peak_hour", "hours_reported", "cost_current_usd"])
    if want("AP2"):
        show("AP2  Query GSI1: one building, one day, all utilities",
             f"What did {BUILDING} use across every utility on 2017-08-08 (the summer's chilled-water peak day)?",
             t.query(IndexName="GSI1", KeyConditionExpression=Key("GSI1PK").eq(f"BLDG#{BUILDING}")
                     & Key("GSI1SK").begins_with("DATE#2017-08-08#"), **rc),
             ["GSI1SK", "meter_code", "kwh", "peak_hour", "cost_current_usd"])
    if want("AP3"):
        show("AP3  Query sparse GSI2: incomplete-data days campus-wide",
             "Which meters reported fewer than 24 hours of data during 1-7 September 2017?",
             t.query(IndexName="GSI2", KeyConditionExpression=Key("GSI2PK").eq("DQ#PARTIAL")
                     & Key("GSI2SK").between("DATE#2017-09-01", "DATE#2017-09-07~"), **rc),
             ["GSI2SK", "hours_reported", "kwh", "building"])
    if want("N1"):
        show("N1  Query item collection, newest first, Limit 8 (profile + latest 7 days)",
             f"For the meter dashboard, show {METER}'s profile and its seven most recent daily readings.",
             t.query(KeyConditionExpression=Key("PK").eq(f"METER#{METER}"), ScanIndexForward=False, Limit=8, **rc),
             ["SK", "building", "gross_sqm", "kwh", "peak_hour", "on_grid_peak_hour"])
    if want("N2"):
        show("N2  Query GSI1 with ProjectionExpression: building week across utilities",
             f"How did {BUILDING} use each utility during 7-13 August 2017, the week its chilled-water demand peaked?",
             t.query(IndexName="GSI1", KeyConditionExpression=Key("GSI1PK").eq(f"BLDG#{BUILDING}")
                     & Key("GSI1SK").between("DATE#2017-08-07", "DATE#2017-08-13~"),
                     ProjectionExpression="GSI1SK, kwh, max_temp_c, cost_current_usd", **rc),
             ["GSI1SK", "kwh", "max_temp_c", "cost_current_usd"])
    if want("N3"):
        show("N3  GetItem by full primary key",
             f"What were {METER}'s kWh and cost on 2017-09-06 (the day of its 221 MWh single-hour spike)?",
             t.get_item(Key={"PK": f"METER#{METER}", "SK": "DATE#2017-09-06"}, **rc),
             ["PK", "SK", "kwh", "peak_kwh", "peak_hour", "cost_current_usd"])


if __name__ == "__main__":
    main()
