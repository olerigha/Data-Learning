---
tags: [course-hub]
---
# CDE — Cloud-Data-Engineering

The arc so far: what data engineering is → cloud building blocks → relational databases and SQL → advanced SQL and pipelines → warehouses and lakehouses → governance, BI and data apps.

## Weeks

### Week 1 — Introduction to cloud data engineering
Source: [[Week1-Introduction.pdf]], [[Cloud-Data-Engineering/Week1/Lecture1/README|Week 1 README]], [[AWS-CLI]], [[EC2]]
- [[Data Roles]] · [[Data Engineering Lifecycle]]
- [[The 4 Vs of Data]] · [[Structured vs Semi-structured vs Unstructured Data]] · [[Batch vs Streaming]]
- [[Cloud Economics and Elasticity]] · [[Regions and Availability Zones]] · [[Infrastructure as Code]] · [[AWS CLI and EC2 Basics]]

### Week 2 — Cloud services and system design
Source: [[Week2-CloudServicesDesign.pdf]], [[Cloud-Data-Engineering/Week2/Lecture2/README|Week 2 README]], [[GoogleCloud]]
- **Networking and identity:** [[VPC and IAM Least Privilege]] · [[Load Balancing]]
- **Services:** [[Cloud Service Models]] · [[Serverless Computing]] · [[Object Storage]] · [[Pub-Sub Messaging]] · [[Managed Databases]]
- **Architecture:** [[Well-Architected Framework]] · [[Cloud Cost Management]] · [[Functional vs Non-Functional Requirements]]

### Week 3 — Relational databases and core SQL
Source: [[Week3-RelationalDatabases.pdf]], [[SQL-Reference.pdf]], [[AWS-MySQL.pdf]]
- [[Database Management System]] · [[Conceptual, Logical and Physical Models]] · [[Entities, Relationships and Cardinality]]
- [[Database Keys]] · [[Normalization]]
- [[SQL Command Types]] · [[SQL Joins]] · [[GROUP BY and HAVING]]

### Week 4 — Advanced SQL and data pipelines
Source: [[Cloud-Data-Engineering/Week4/README|Week 4 README]], [[Cloud-Data-Engineering/Week4/pipeline/README|pipeline README]], `Week4/sql/` labs
- [[Subqueries and CTEs]] · [[Window Functions]] · [[Views and Materialized Views]] · [[Stored Procedures]]
- [[ACID Transactions]] · [[Indexing, Partitioning and EXPLAIN]]
- [[SQL from Python]] · [[Pipeline Orchestration with Prefect]]

### Week 5 — Data warehouses and lakehouses
Source: [[Week5-DatawarehouseDataLakes.pdf]], [[Cloud-Data-Engineering/Week5/README|Week 5 README]]
- [[OLTP vs OLAP]] · [[Inmon vs Kimball]]
- [[Fact and Dimension Tables]] · [[Star vs Snowflake Schema]] · [[Slowly Changing Dimensions]]
- [[Data Lakehouse]] · [[Medallion Architecture]] · [[Idempotent Pipelines]]

### Week 6 — Governance, BI and data apps
Source: [[Week6-BusinessIntelligence.pdf]], [[governance-lab]], [[observability-lab]]
- [[Data Governance and Lineage]] · [[Data Contracts]] · [[Data Observability]]
- [[BI vs Standard Reporting]] · [[KPIs and the Semantic Layer]] · [[Dashboard Design Principles]]
- [[Three-Tier Data Apps]]

## Threads across weeks
- **Data path:** [[Object Storage]] → [[Medallion Architecture]] → [[Fact and Dimension Tables]] → [[Dashboard Design Principles]]
- **Writes vs reads:** [[Normalization]] (OLTP) ↔ [[Star vs Snowflake Schema]] (OLAP), see [[OLTP vs OLAP]]
- **Reliable pipelines:** [[ACID Transactions]] + [[Idempotent Pipelines]] + [[Pipeline Orchestration with Prefect]] + [[Data Observability]]
- **Communication (with LCDS):** [[Dashboard Design Principles]] ↔ [[Chart Selection]]
