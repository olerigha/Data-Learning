# Google Cloud Dataproc + JupyterLab — Reusable Setup Guide

Create a small, single-node Dataproc cluster with browser-accessible JupyterLab. All project-specific values are variables, so this guide can be shared across projects.

**Where to run commands:** Google Cloud Shell (Bash), unless marked as Python notebook code. You need permission to create Dataproc clusters and, for optional IAM steps, to modify IAM policies. Billing and required APIs must be enabled for the project.

## 1. Set your variables (run once per Cloud Shell session)

Change `PROJECT_ID` to your own Google Cloud project ID. You can change the other values if needed.

```bash
export PROJECT_ID="YOUR_PROJECT_ID"
export REGION="us-central1"
export ZONE="us-central1-a"
export CLUSTER_NAME="pyspark-test-cluster"
export MACHINE_TYPE="e2-standard-4"
export IMAGE_VERSION="2.2-debian12"
export DISK_SIZE_GB="100"

gcloud config set project "$PROJECT_ID"
export PROJECT_NUMBER="$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')"
export SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

printf 'Project: %s\nProject number: %s\nVM service account: %s\n' \
  "$PROJECT_ID" "$PROJECT_NUMBER" "$SERVICE_ACCOUNT"
```

**Note:** The example uses the default Compute Engine service account. For production, use a dedicated service account with least-privilege access. Re-run this section in any new Cloud Shell session before using variables below.

## 2. Enable required APIs

```bash
gcloud services enable \
  compute.googleapis.com \
  dataproc.googleapis.com \
  storage.googleapis.com \
  --project="$PROJECT_ID"
```

## 3. Check Dataproc Worker permissions

```bash
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten='bindings[].members' \
  --filter="bindings.members:$SERVICE_ACCOUNT" \
  --format='table(bindings.role,bindings.condition.title)'
```

If `roles/dataproc.worker` is **missing**, and you have permission to modify project IAM, run:

```bash
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/dataproc.worker" \
  --condition=None
```

`--condition=None` makes this binding unconditional. If prompted to choose a condition, select **None**. Do not grant the broad Editor role just to make Dataproc work.

## 4. Create the small cluster with JupyterLab

The **JUPYTER optional component** and **Component Gateway** are both important for the browser-based JupyterLab experience.

```bash
gcloud dataproc clusters create "$CLUSTER_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --zone="$ZONE" \
  --single-node \
  --master-machine-type="$MACHINE_TYPE" \
  --master-boot-disk-size="$DISK_SIZE_GB" \
  --image-version="$IMAGE_VERSION" \
  --optional-components=JUPYTER \
  --enable-component-gateway \
  --max-idle=1h
```

This is a **single-node** learning/testing cluster, not a multi-worker deployment. `--max-idle=1h` requests deletion after an idle period; it is **not** a hard one-hour lifetime or a spending cap. Region/zone, machine, disk, and image availability can vary by project.

## 5. Verify and open JupyterLab

```bash
gcloud dataproc clusters list \
  --project="$PROJECT_ID" --region="$REGION"

gcloud dataproc clusters describe "$CLUSTER_NAME" \
  --project="$PROJECT_ID" --region="$REGION"
```

In the [Google Cloud Dataproc console](https://console.cloud.google.com/dataproc/clusters), select **your project**, open **your cluster**, choose **Web Interfaces**, and click **JupyterLab** under Component Gateway. Create a notebook using an available Python/PySpark kernel configured for Spark.

## 6. Test PySpark (run in a JupyterLab notebook)

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import avg, count

spark = SparkSession.builder.appName("DataprocTest").getOrCreate()
print("Spark version:", spark.version)
print("Spark master:", spark.sparkContext.master)

data = [
    (1, "Alice", "Engineering", 95000),
    (2, "Bob", "Marketing", 75000),
    (3, "Charlie", "Engineering", 105000),
    (4, "David", "Finance", 85000),
    (5, "Emma", "Marketing", 80000),
    (6, "Frank", "Finance", 90000),
]

df = spark.createDataFrame(data, ["id", "name", "department", "salary"])
df.show()
df.groupBy("department").agg(
    count("*").alias("employee_count"),
    avg("salary").alias("average_salary")
).show()
print("Total employees:", df.count())  # Expected: 6
print("Spark application ID:", spark.sparkContext.applicationId)

df.createOrReplaceTempView("employees")
spark.sql("""
    SELECT department, COUNT(*) AS employees, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
    ORDER BY avg_salary DESC
""").show()
```

## 7. Optional: Submit a PySpark job from Cloud Shell

```bash
cat > test_spark.py <<'PY'
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("DataprocBatchTest").getOrCreate()
df = spark.createDataFrame(
    [("Alice", 95000), ("Bob", 75000), ("Charlie", 105000)],
    ["name", "salary"]
)
df.show()
print("Total employees:", df.count())
spark.stop()
PY

gcloud dataproc jobs submit pyspark test_spark.py \
  --project="$PROJECT_ID" \
  --cluster="$CLUSTER_NAME" \
  --region="$REGION"
```

## 8. Troubleshooting: missing staging/temp bucket permissions

If cluster creation reports missing permissions such as `storage.objects.get` or `storage.objects.update`, **copy the exact bucket names from the error**. They are generated per environment; do not assume a bucket name based on the project number.

List existing buckets:

```bash
gcloud storage buckets list --project="$PROJECT_ID"
```

Set the two bucket names **without `gs://`**, using the actual names in your error:

```bash
export STAGING_BUCKET="PASTE_ACTUAL_STAGING_BUCKET_NAME"
export TEMP_BUCKET="PASTE_ACTUAL_TEMP_BUCKET_NAME"
```

If you administer those buckets and have confirmed they are the relevant ones, grant the VM service account object access **on those buckets only**:

```bash
for BUCKET in "$STAGING_BUCKET" "$TEMP_BUCKET"; do
  gcloud storage buckets add-iam-policy-binding "gs://$BUCKET" \
    --member="serviceAccount:$SERVICE_ACCOUNT" \
    --role="roles/storage.objectAdmin"
done
```

Verify:

```bash
gcloud storage buckets get-iam-policy "gs://$STAGING_BUCKET"
gcloud storage buckets get-iam-policy "gs://$TEMP_BUCKET"
```

These are **conditional troubleshooting commands**, not required for every deployment. `roles/storage.objectAdmin` is broad within each named bucket; review or narrow it for long-term use. If the account already has the required permissions but creation still fails, investigate IAM conditions, IAM Deny policies, bucket policies, and organization restrictions instead of adding more broad roles. Allow time for IAM propagation before retrying cluster creation.

### Other common issues

- **No Web Interfaces/JupyterLab:** The cluster may have been created without `--optional-components=JUPYTER` and/or `--enable-component-gateway`. For a disposable test cluster, delete and recreate with both flags.
- **`JAVA_HOME is not set` in Vertex AI Workbench:** That is a separate notebook environment. A Dataproc-hosted Spark kernel is generally easier than manually configuring local Spark in Workbench.
- **IAM condition prompt:** Use `--condition=None` if you intend an unconditional binding.
- **Optional organization policy diagnostic:** The following checks only one policy, not all possible restrictions:

```bash
gcloud org-policies describe constraints/gcp.restrictEndpointUsage \
  --project="$PROJECT_ID" --effective
```

## 9. Delete the cluster when finished

```bash
gcloud dataproc clusters delete "$CLUSTER_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION"
```

Deleting the cluster stops its VM charges; storage buckets and other resources may persist and incur separate charges.

## References

- [Dataproc service accounts](https://cloud.google.com/dataproc/docs/concepts/configuring-clusters/service-accounts)
- [Jupyter optional component](https://cloud.google.com/dataproc/docs/concepts/components/jupyter)
- [Component Gateway](https://cloud.google.com/dataproc/docs/concepts/accessing/gateways)

# Appendix: Demonstrating Distributed Spark with a Small Dataproc Cluster

**Purpose:** Create a small, three-node Google Cloud Dataproc cluster (one master and two workers), run a distributed PySpark job in JupyterLab, and inspect how Spark divides work into partitions and tasks.

> 
## A. Cluster layout

| Component | Setting |
|---|---|
| Master | 1 × `e2-standard-4` |
| Workers | 2 × `e2-standard-2` |
| Boot disks | 100 GB per VM |
| Image | `2.2-debian12` |
| JupyterLab | Enabled via optional component |
| Component Gateway | Enabled |
| Idle deletion | 1 hour |

**Cost note:** Three VMs and their disks incur charges while the cluster exists. Delete the cluster after the exercise. Idle deletion is a safeguard, not a substitute for cleanup.

## B. Create the cluster from Cloud Shell

Open **Google Cloud Console → Cloud Shell**, then paste the following. Change `PROJECT_ID` and `CLUSTER_NAME` as needed. The project must have billing enabled, the Dataproc API enabled, and appropriate IAM permissions and quotas.

```bash
# Configuration
export PROJECT_ID="YOUR_PROJECT_ID"
export REGION="us-central1"
export ZONE="us-central1-a"
export CLUSTER_NAME="pyspark-test-cluster"
export MASTER_MACHINE_TYPE="e2-standard-4"
export WORKER_MACHINE_TYPE="e2-standard-2"
export IMAGE_VERSION="2.2-debian12"
export DISK_SIZE_GB="100"

# Create one master and two workers
# No pip initialization action or third-party Spark JARs required.
gcloud dataproc clusters create "$CLUSTER_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --zone="$ZONE" \
  --num-workers=2 \
  --master-machine-type="$MASTER_MACHINE_TYPE" \
  --worker-machine-type="$WORKER_MACHINE_TYPE" \
  --master-boot-disk-size="${DISK_SIZE_GB}GB" \
  --worker-boot-disk-size="${DISK_SIZE_GB}GB" \
  --image-version="$IMAGE_VERSION" \
  --optional-components=JUPYTER \
  --enable-component-gateway \
  --max-idle=1h
```

If a cluster with the same name already exists, use a different name or delete the existing cluster before recreating it. If cluster creation fails because of service-account permissions, contact your administrator; the VM service account must have the required Dataproc and storage access.

## C. Open JupyterLab

1. In Google Cloud Console, navigate to **Dataproc → Clusters**.
2. Select `pyspark-test-cluster`.
3. Open **Web Interfaces → JupyterLab** (through Component Gateway).
4. Create a notebook with a PySpark-capable kernel. On a Dataproc cluster, the Spark session should use cluster resources, not a separate local Workbench installation.

## D. Run a simple distributed Spark job

In the notebook, run:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import col

spark = SparkSession.builder.appName("DistributedSparkDemo").getOrCreate()

# Eight partitions provide multiple tasks for the cluster to schedule.
df = spark.range(0, 1_000_000, 1, 8)

print("Partitions:", df.rdd.getNumPartitions())

result = df.groupBy((col("id") % 10).alias("group")).count()
result.orderBy("group").show()
```

**Expected:** 8 initial partitions and 10 groups, each with 100,000 rows. Spark may run tasks across both workers, depending on available resources and scheduling.

Optional: Check which Spark master the notebook is using:

```python
print("Spark master:", spark.sparkContext.master)
print("Spark application ID:", spark.sparkContext.applicationId)
```

For a cluster-backed session, the master should not be `local[*]`. If it is, the notebook is using local Spark rather than the Dataproc cluster's distributed resources.

## E. Show students where distributed work happens

1. In the cluster's **Web Interfaces**, open the **Spark History Server** to inspect completed applications, jobs, stages, and task counts. Depending on the notebook and session configuration, a running application may be easier to inspect in the Spark UI while it is active.
2. Open **YARN ResourceManager** to view applications and the cluster's worker resources.
3. Explain that **partitions** determine the number of tasks in a stage, while **workers** supply CPU and memory to execute tasks concurrently. Eight partitions do **not** mean eight workers.

For a longer-running demo, increase the range size if needed, but avoid unnecessarily large data volumes.

## F. Delete the cluster when finished

Run in Cloud Shell:

```bash
gcloud dataproc clusters delete "$CLUSTER_NAME" \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --quiet
```

**Instructor takeaway:** This exercise demonstrates real distributed Spark across two worker VMs. It complements the single-node and serverless exercises by making the cluster's physical worker layout visible.
