---
course: CDE
week: 8
source: "[[Dataproc_JupyterLab_Setup_Guide_Reusable]]"
status: new
tags: [generated]
---
# Google Cloud Dataproc
**In one line:** GCP's managed Spark/Hadoop service: spin up a cluster with JupyterLab in minutes, run PySpark, then delete it.

**In plain words:** Instead of installing Spark on your own machines, Dataproc creates a ready-made cluster: a master plus worker VMs (or a single node for practice). With the Jupyter component and the Component Gateway turned on, you open JupyterLab in your browser and run PySpark against the cluster. Clusters bill for every VM while they exist, so always delete them when you're done. Idle auto-deletion is only a safety net.

**Terms**
| Term | Means |
|---|---|
| Dataproc | managed Spark / Hadoop clusters on GCP |
| Master / worker | coordinator node / nodes that run executors |
| Single-node cluster | master only; for learning and testing |
| `--optional-components=JUPYTER` | install JupyterLab on the cluster |
| Component Gateway | secure browser access to cluster web UIs |
| `--max-idle=1h` | delete after an hour idle (not a hard limit or spending cap) |
| Cloud Shell | browser terminal where the `gcloud` commands run |

**Key points**
- Steps: set variables (project, region, zone, cluster name, machine type) → enable APIs → check worker permissions → `gcloud dataproc clusters create … --single-node --optional-components=JUPYTER --enable-component-gateway --max-idle=1h` → open JupyterLab → test PySpark → **delete the cluster**.
- Distributed demo layout: 1 master `e2-standard-4` + 2 workers `e2-standard-2`, 100 GB disks.
- Deleting the cluster stops VM charges; buckets and other resources keep billing.
- Common error: missing permissions on the staging/temp bucket.
- Course exercises: config test, PySpark data exploration, Yelp EDA.

**Memorize vs. look up:** Memorize "always delete the cluster" and what JUPYTER + Component Gateway give you. Look up the commands.

Related: [[Spark Architecture]], [[Cloud Cost Management]], [[Managed Databases]], [[VPC and IAM Least Privilege]]
