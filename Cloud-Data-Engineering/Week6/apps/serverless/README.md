# Week 2 – API Gateway + Lambda → RDS (classicmodels)

This lab now covers both pieces of the Week 2 outcome: a read-only serverless API over RDS and a read-only object-storage preview endpoint for raw data in S3.

## Architecture

```
Browser / Streamlit UI
        │  HTTPS GET
        ▼
 API Gateway (HTTP API)
        │  proxy
        ▼
 AWS Lambda (Python 3.11)
        │  pymysql  (inside VPC)
        ▼
 Amazon RDS MySQL 8 – classicmodels database
```

## Prerequisites

| Tool | Version |
|------|---------|
| AWS CLI | ≥ 2.x (configured with `aws configure`) |
| AWS SAM CLI | ≥ 1.100 (`brew install aws-sam-cli`) |
| Python | 3.11 |
| An existing VPC + private subnets with a NAT Gateway or VPC endpoint for Lambda |

## Step 1 – Provision RDS (skip if you already have one)

```bash
aws rds create-db-instance \
  --db-instance-identifier classicmodels-db \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0 \
  --master-username admin \
  --master-user-password <YOUR_PASSWORD> \
  --db-name classicmodels \
  --allocated-storage 20 \
  --no-publicly-accessible \
  --vpc-security-group-ids <sg-xxxx> \
  --db-subnet-group-name <your-subnet-group>
```

Then load the schema:

```bash
mysql -h <rds-endpoint> -u admin -p classicmodels < ../../data/classicmodels.sql
```

Make sure the RDS security group **inbound rule** allows MySQL (port 3306) from the Lambda security group.

## Step 2 – Build & Deploy with SAM

```bash
cd Week2/lambda-rds-api

sam build

sam deploy --guided
# Answer the prompts, or pass overrides directly:
sam deploy \
  --stack-name classicmodels-api \
  --parameter-overrides \
      DBHost=<rds-endpoint> \
      DBUser=admin \
      DBPassword=<YOUR_PASSWORD> \
      RawBucketName=<raw-data-bucket> \
      SubnetIds="<subnet-1>,<subnet-2>" \
      LambdaSecurityGroupId=<sg-lambda> \
  --capabilities CAPABILITY_IAM \
  --resolve-s3
```

After a successful deploy, note the **ApiEndpoint** in the Outputs section.

## Step 3 – Run the Streamlit UI

```bash
cd ui
cp .env.example .env
# Edit .env and paste the ApiEndpoint value

pip install -r requirements.txt
streamlit run app.py
```

Open http://localhost:8501 in your browser.

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/summary` | Record counts for all tables |
| GET | `/customers` | All customers (`?limit=N`) |
| GET | `/customers/{id}` | Single customer by number |
| GET | `/products` | All products (`?limit=N`) |
| GET | `/products/{id}` | Single product by code |
| GET | `/orders` | All orders (`?limit=N`) |
| GET | `/orders/{id}` | Order + line items |
| GET | `/employees` | All employees |
| GET | `/employees/{id}` | Single employee |
| GET | `/objects/{key}` | Preview the first lines of a raw S3 object (`?limit=N`) |

All responses follow:

```json
{
  "data": [ ... ]   // or a single object for /{id} routes
}
```

## Local smoke tests

```bash
PYTHONPATH=week2/serverless/lambda python -m unittest week2/serverless/lambda/TestLambdaFunction.py -v
```

The object-storage test patches the S3 reader so it runs without AWS credentials. In a deployed stack, upload a small raw file to `RawBucketName` and call `/objects/<key>?limit=5` to verify the Lambda can read only the configured bucket.

## Project Structure

```
lambda-rds-api/
├── lambda/
│   ├── lambda_function.py   # Handler with built-in router
│   └── requirements.txt     # pymysql
├── ui/
│   ├── app.py               # Streamlit dashboard
│   ├── requirements.txt
│   └── .env.example
├── template.yaml            # AWS SAM (API Gateway + Lambda)
└── README.md
```

## Security notes

* Database credentials are passed as **CloudFormation parameters** (`NoEcho: true`) and stored as Lambda environment variables. For production, replace them with AWS Secrets Manager references.
* The Lambda runs inside the **same VPC** as RDS — it is never publicly accessible.
* CORS is restricted to `GET` and `OPTIONS` only.
