# Week 2: Introduction to Google Cloud Platform (GCP) for Data Engineering

This guide walks you through setting up your Google Cloud environment, understanding core GCP data storage and processing services, and completing hands-on labs with **Cloud Storage (GCS)**, **Cloud SQL**, and Python APIs.

---

## 1. Account Setup & Prerequisites

### A. Create Your Google Cloud Account
- Sign up at [cloud.google.com/free](https://cloud.google.com/free) to claim your **$300 in free trial credits** (valid for 90 days).
- Create a new GCP project (e.g., `cloud-data-eng-lab`) or select your course project.
- Ensure billing is enabled for your project.

### B. Install Python Client Libraries
In your local environment or virtual environment, install the official Google Cloud Python client libraries:

```bash
pip install --upgrade google-cloud-storage google-cloud-bigquery google-cloud-pubsub
```

---

## 2. Core GCP Data Engineering Components

| Service | Category | Best Used For |
|---|---|---|
| **Cloud Storage (GCS)** | Object Storage (Data Lake) | Raw data files, Parquet/CSV, backups, pipeline staging |
| **Cloud SQL** | Managed Relational DB | Operational transactional databases (MySQL, PostgreSQL, SQL Server) |
| **Cloud Datastore / Firestore** | NoSQL Document DB | Hierarchical, transactional JSON-like documents, app state |
| **Cloud Pub/Sub** | Real-time Messaging | High-throughput distributed event streaming and message queuing |
| **Cloud BigQuery** | Serverless Data Warehouse | SQL analytics over massive datasets (TB/PB scale) |
| **Cloud Dataflow** | Unified Streaming/Batch ETL | Serverless Apache Beam data pipelines (e.g. Cloud SQL → BigQuery) |

---

## 3. Hands-on Lab: Cloud Storage & Python APIs

> Companion notebook: [GCP-GoogleCloudStorageAPIs.ipynb](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week2/gcp/GCP-GoogleCloudStorageAPIs.ipynb)

### Step 1: Create a Service Account (SA) for Python Access
1. Open the [GCP Console > IAM & Admin > Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts).
2. Click **Create Service Account**:
   - **Name**: `storage-python-client`
   - **Role**: `Storage Admin` (or `Storage Object Admin` for least privilege)
3. Click into the newly created service account > navigate to the **Keys** tab.
4. Click **Add Key > Create new key > JSON**.
5. Save the downloaded JSON key file securely on your computer (e.g. `~/credentials/gcp-key.json`).

### Step 2: Configure Environment Authentication
Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to your downloaded JSON key:

- **macOS / Linux (Terminal or `~/.zshrc`)**:
  ```bash
  export GOOGLE_APPLICATION_CREDENTIALS="/path/to/your/gcp-key.json"
  ```
- **In Python / Jupyter Notebook**:
  ```python
  import os
  os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = '/path/to/your/gcp-key.json'
  ```

### Step 3: Run the Cloud Storage Workflow via Python

```python
from google.cloud import storage
import urllib.request

# 1. Initialize client
client = storage.Client()

# 2. List existing buckets
print("Existing buckets:")
for bucket in client.list_buckets():
    print(f" - {bucket.name}")

# 3. Create a globally unique bucket (replace 'student-unique-id' with your name/id)
bucket_name = "data-eng-earthquake-student-unique-id"
bucket = client.create_bucket(bucket_name, location="US")
print(f"✓ Created bucket: {bucket.name}")

# 4. Ingest real-world dataset: USGS Earthquakes Live Feed
url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.csv"
urllib.request.urlretrieve(url, "all_week.csv")
print("✓ Downloaded latest earthquake feed.")

# 5. Upload the file to GCS
blob = bucket.blob("raw/earthquakes/all_week.csv")
blob.upload_from_filename("all_week.csv")
print(f"✓ Uploaded all_week.csv to gs://{bucket_name}/raw/earthquakes/all_week.csv")
```

---

## 4. Hands-on Lab: Cloud SQL & Database Migration

### Step 1: Provision a Cloud SQL (MySQL) Instance
1. Go to **Cloud SQL** in the GCP Console and click **Create Instance**.
2. Select **MySQL** (version 8.0).
3. Set an Instance ID (e.g., `classicmodels-db`) and define a strong root password.
4. Choose **Enterprise / Single Zone** (for cost-efficiency in student labs).

### Step 2: Connect via MySQL Workbench
To connect your local MySQL Workbench to Cloud SQL:
1. In Cloud SQL > **Connections** tab > **Authorized Networks**:
   - Add your local IP address (find via `curl ifconfig.me`).
2. Alternatively, use the **Cloud SQL Auth Proxy** (recommended for production):
   ```bash
   ./cloud-sql-proxy --port 3306 <INSTANCE_CONNECTION_NAME>
   ```
3. Open MySQL Workbench and configure a new connection using the Cloud SQL Public IP address and your root/user credentials.

### Step 3: Migrate ClassicModels Data to Cloud SQL
1. In MySQL Workbench, create the database:
   ```sql
   CREATE DATABASE classicmodels;
   USE classicmodels;
   ```
2. Execute the `classicmodels.sql` schema and data insert script into your Cloud SQL instance.
3. Validate row counts across `customers`, `orders`, and `products`.

---

## 5. Next Steps: Data Pipelines with Cloud Dataflow

Once your data is housed in Cloud SQL and GCS, explore Cloud Dataflow templates to move and transform data:
- **Cloud SQL → BigQuery**: Load relational tables into BigQuery analytical datasets for SQL analytics and reporting.
- **Cloud SQL / GCS → Pub/Sub**: Stream database change logs or events into Pub/Sub topics for downstream real-time streaming architectures.
