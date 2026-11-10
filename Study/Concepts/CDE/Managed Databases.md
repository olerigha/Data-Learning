---
course: CDE
week: 2
source: "[[Week2-CloudServicesDesign.pdf]], [[Week3-RelationalDatabases.pdf]], [[AWS-MySQL.pdf]]"
status: new
tags: [generated]
---
# Managed Databases
**In one line:** The cloud provider runs the database server for you: backups, patches, failover and scaling included.

**In plain words:** You could install MySQL on an EC2 machine yourself, but then you handle backups, upgrades and crashes. With a managed database (AWS RDS, Google Cloud SQL) you choose the engine and size, and the provider does the upkeep. You still design the tables and write the SQL.

**Terms**
| Term | Means |
|---|---|
| RDS | AWS Relational Database Service |
| Cloud SQL | Google's managed MySQL/PostgreSQL/SQL Server |
| Self-managed | you install and run the database on your own VM |
| Failover | switching to a standby copy when the main one dies |
| Read replica | a read-only copy that spreads out read traffic |
| PITR | point-in-time recovery: restore to any moment |

**Key points**
- Course design question: "How do managed services handle backups, failover, and scaling?"
- Week 3 lab: create an RDS MySQL instance, connect from MySQL Workbench and Python.
- Managed backups with PITR are standard in RDS and Cloud SQL.

**Memorize vs. look up:** Memorize what the provider handles vs what you still do.

Related: [[Cloud Service Models]], [[Database Management System]], [[VPC and IAM Least Privilege]], [[Serverless Computing]]
