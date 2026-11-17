"""
dynamo_create_table.py - create the CampusEnergy single-table design (on-demand) with two GSIs.

  Base table : PK (S) / SK (S)        meter item collection: PROFILE + DATE#yyyy-mm-dd readings
  GSI1       : GSI1PK (S) / GSI1SK (S) building -> day -> utility view (BLDG#..., DATE#...#utility)
  GSI2       : GSI2PK (S) / GSI2SK (S) sparse data-quality index (DQ#PARTIAL, DATE#...#meter)

Same definition as the AWS CLI command used for the deployed table:
  aws dynamodb create-table --table-name CampusEnergy --billing-mode PAY_PER_REQUEST ... (see report Part 3)

Usage: python dynamo_create_table.py [--table CampusEnergy] [--region us-east-2]
"""
import argparse
import boto3


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--table", default="CampusEnergy"); ap.add_argument("--region", default="us-east-2")
    a = ap.parse_args()
    client = boto3.client("dynamodb", region_name=a.region)
    attrs = ["PK", "SK", "GSI1PK", "GSI1SK", "GSI2PK", "GSI2SK"]
    client.create_table(
        TableName=a.table,
        BillingMode="PAY_PER_REQUEST",
        AttributeDefinitions=[{"AttributeName": n, "AttributeType": "S"} for n in attrs],
        KeySchema=[{"AttributeName": "PK", "KeyType": "HASH"}, {"AttributeName": "SK", "KeyType": "RANGE"}],
        GlobalSecondaryIndexes=[
            {"IndexName": "GSI1", "Projection": {"ProjectionType": "ALL"},
             "KeySchema": [{"AttributeName": "GSI1PK", "KeyType": "HASH"}, {"AttributeName": "GSI1SK", "KeyType": "RANGE"}]},
            {"IndexName": "GSI2", "Projection": {"ProjectionType": "ALL"},
             "KeySchema": [{"AttributeName": "GSI2PK", "KeyType": "HASH"}, {"AttributeName": "GSI2SK", "KeyType": "RANGE"}]},
        ],
        Tags=[{"Key": "project", "Value": "assignment3"}],
    )
    client.get_waiter("table_exists").wait(TableName=a.table)
    desc = client.describe_table(TableName=a.table)["Table"]
    print(desc["TableName"], desc["TableStatus"], [g["IndexName"] for g in desc["GlobalSecondaryIndexes"]])


if __name__ == "__main__":
    main()
