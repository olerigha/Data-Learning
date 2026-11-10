---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]]"
status: new
tags: [generated]
---
# Serverless Computing
**In one line:** Upload just a function; the cloud runs it when an event calls it and charges only for that run.

**In plain words:** With a VM (EC2) you manage the operating system and pay while it's on, used or not. With serverless functions (FaaS) there's no server for you to manage: your code wakes up on an event (a file upload, an API call), runs, and you pay per call. It suits short, event-driven jobs. It doesn't suit long ones: functions have time limits and a small "cold start" delay after sitting idle.

**Terms**
| Term | Means |
|---|---|
| FaaS | Functions as a Service: AWS Lambda, GCP Cloud Functions, Azure Functions |
| Event-driven | runs in response to a trigger |
| Cold start | startup delay on the first call after idle |
| Execution limit | max run time: 15 min on AWS, 9 min on GCP |
| API Gateway | gives a function a public HTTP endpoint |
| SAM template | `template.yaml` describing a Lambda deployment |
| Spot / preemptible VMs | 60–90% cheaper VMs that can be interrupted; good for batch |

**Key points**
- Ideal for event-driven ingestion, light transformations and API backends.
- VMs vs serverless: VMs give control (custom workloads); serverless gives zero idle cost.
- VM tips: pick the right machine family, auto-scaling groups, right-size (over-provisioning wastes money).
- Course lab: a Lambda function with a SAM template and a Streamlit front end; `boto3` for AWS from Python.

**Memorize vs. look up:** Memorize when serverless fits, cold starts, and the time limits.

Related: [[Cloud Service Models]], [[Pub-Sub Messaging]], [[Three-Tier Data Apps]], [[Cloud Cost Management]]
