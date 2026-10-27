# Week 5 Warehouse Lab

## Outcome
Load the classic models star schema into a local MySQL warehouse and explore it through Metabase.

## Step 1 — Load the warehouse schema and data

```bash
mysql -u root -p < week5/warehouse/classicmodelsdw.sql
```

`classicmodels-vs-dw.sql` contains notes on how the OLTP schema was restructured into a star schema. Review it before loading.

## Step 2 — Start Metabase

```bash
docker run -d -p 3000:3000 --name metabase metabase/metabase
```

Open http://localhost:3000 and complete the initial setup.

## Step 3 — Connect Metabase to MySQL

| Field    | Value                  |
|----------|------------------------|
| Host     | host.docker.internal   |
| Port     | 3306                   |
| Database | classicmodelsdw        |
| Username | root                   |
| Password | *(use env var or prompt — never commit)* |

## Step 4 — Build a dashboard

Reproduce the questions answered in `week6/ClassicModelData-Reporting.xlsx` as Metabase questions. Save them to a dashboard and export a screenshot for submission.

*(Note: The Tableau workbook `ClassicModelsDashboard.twb`, instructions, and Excel reporting files `ClassicModelData-Reporting.xlsx` / `ClassicModelData.xlsx` have been moved to `week6/` for analytics and dashboarding applications).*

## Cleanup

```bash
docker stop metabase && docker rm metabase
```

## Submission
Include the star schema diagram, the Metabase dashboard screenshot, row counts for each dimension and fact table, and the cleanup confirmation.
