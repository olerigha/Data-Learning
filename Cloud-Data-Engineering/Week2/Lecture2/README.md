# Week 2: Cloud Services and System Design

## Overview

Week 2 covers cloud service models and architecture, core cloud services (compute, storage, networking), managed databases, serverless computing, the Well-Architected Framework, reference architectures, and cloud data system design.

## Core Topics

1. **Cloud Service Models & Architecture**
   - Service models: Infrastructure as a Service (IaaS), Platform as a Service (PaaS), Software as a Service (SaaS), and Function as a Service / Serverless (FaaS).
   - Architectural patterns: Decoupled compute and storage, microservices, and event-driven data flows.

2. **Core Cloud Services & Infrastructure**
   - Virtual compute: Virtual machines (EC2) vs. serverless runtimes.
   - Object storage: Scalable, immutable blob storage (AWS S3, Google Cloud Storage) with lifecycle rules and tiering.
   - Cloud networking & IAM: Virtual Private Clouds (VPCs), subnets, gateways, and least-privilege IAM policies.

3. **Managed Databases & Serverless Computing**
   - Managed relational databases (RDS) vs. self-managed database servers.
   - Serverless compute with AWS Lambda and API Gateway for on-demand data services.

4. **Well-Architected Framework & System Design**
   - AWS Well-Architected Pillars: Reliability, security, cost optimization, performance efficiency, and operational excellence.
   - Cloud data system design: Architecture diagrams, throughput sizing, SLA definition, and cloud pricing estimation.

## Labs

- **AWS Cloud Services** (`aws/`) — Interacting with AWS services via CLI and Python (`boto3`):
  - [2.1-AWS-IAM.ipynb](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week2/aws/2.1-AWS-IAM.ipynb): Defining least-privilege IAM policies, users, service roles, and temporary credentials via STS.
  - [2.2-AWS-Cloud-APIs.ipynb](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week2/aws/2.2-AWS-Cloud-APIs.ipynb): Credential management, S3 object/bucket operations, and EC2 compute management.
- **Google Cloud Platform** (`gcp/`) — GCP data infrastructure and storage APIs:
  - [GoogleCloud.md](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week2/gcp/GoogleCloud.md): Comprehensive guide to GCP components, Service Account setup, Cloud SQL provisioning, MySQL Workbench migration, and Dataflow pipelines.
  - [2.3-GCP-Cloud-APIs.ipynb](file:///Users/apujari/Documents/courses/CloudDataEngineering/code/week2/gcp/2.3-GCP-Cloud-APIs.ipynb): Authenticating via Service Account JSON keys and interacting with Google Cloud Storage (GCS) APIs to ingest live USGS earthquake feeds.

## Service Model Comparison

| Service Model | Course Implementation | Key System Design Question |
|---|---|---|
| **Object Storage** | AWS S3 / Google Cloud Storage | How should raw, immutable data snapshots be stored? |
| **Virtual Compute** | AWS EC2 (Ubuntu) | When is full OS control required versus a managed runtime? |
| **Managed Database** | Relational Database Service (RDS) | How do managed services handle backups, failover, and scaling? |
| **Serverless Compute** | AWS Lambda & API Gateway | How can APIs scale elastically with zero idle cost? |

## Assessment Milestones

- **Quiz 1:** Cloud service models, IAM scope, object storage mechanics, serverless execution, network security, and cost governance.
- **Project Milestone 1:** [Project Checkpoint 1](../docs/CHECKPOINT-1.md) — Team Roster, Business Use Case, and Candidate Data Sources.

## Submission

Include the cloud system architecture diagram, deployment configuration parameters (no secrets), API specification, local test results, cloud cost estimate, and evidence that all temporary cloud resources have been terminated.
