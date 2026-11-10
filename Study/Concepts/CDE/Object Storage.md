---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]], [[GoogleCloud]]"
status: new
tags: [generated]
---
# Object Storage
**In one line:** Cheap, nearly unlimited cloud storage for whole files, kept in "buckets" (AWS S3, Google Cloud Storage, Azure Blob).

**In plain words:** Object storage isn't a database. It's a giant, extremely reliable flat folder in the cloud. You upload whole files under a path-like key and download them whole. It's the usual landing zone for raw data and the foundation of data lakes and lakehouses. Older, rarely used files can move to cheaper "cold" storage classes.

**Terms**
| Term | Means |
|---|---|
| Bucket | top-level container; name must be globally unique |
| Object / key | one stored file / its path-like name, e.g. `raw/earthquakes/all_week.csv` |
| Flat namespace | no real folders; slashes in keys just look like folders |
| Durability "11 nines" | 99.999999999%: losing a file is almost impossible |
| Storage classes | Standard (hot) → Nearline → Coldline / Glacier (archive) |
| Lifecycle rules | auto-move or delete files by age |

**Key points**
- Use object storage as the foundation of the data lake and lakehouse.
- GCP lab: create a bucket, download the USGS earthquake feed, upload it to `raw/earthquakes/`.
  In words: land raw data as-is in a "raw" area first; clean it later.
- Python: `boto3` for S3, `google-cloud-storage` for GCS.
- Lab cleanup: empty and delete the buckets you created.

**Memorize vs. look up:** Memorize bucket / object / key, the storage classes, and why raw data lands here first.

Related: [[Cloud Service Models]], [[Data Lakehouse]], [[Medallion Architecture]], [[Cloud Cost Management]]
