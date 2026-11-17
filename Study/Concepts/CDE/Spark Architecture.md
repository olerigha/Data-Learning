---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]], [[Cloud-Data-Engineering/Week8/Week8/README|Week 8 README]]"
status: new
tags: [generated]
---
# Spark Architecture
**In one line:** A Spark **driver** plans the work, a **cluster manager** hands out machines, and **executors** on those machines run the tasks in parallel.

**In plain words:** Your program runs in the driver, which turns your code into a plan and splits it into small tasks. The cluster manager gives the driver resources. Executors are worker processes on the cluster's machines: each runs tasks on its own chunk of data and can keep data in memory. On top of this core engine, Spark adds libraries for SQL, streaming, machine learning and graphs, and it reads from many data sources (files, data lakes, databases).

**Terms**
| Term | Means |
|---|---|
| Driver | runs your program; builds the plan; schedules tasks |
| Executor | worker process that runs tasks and caches data |
| Cluster manager | allocates machines (YARN, Kubernetes, Spark standalone, Dataproc) |
| SparkSession / SparkContext | your entry point to Spark from code |
| Spark Core | task dispatching, scheduling and basic I/O |
| Spark SQL / Streaming / MLlib / GraphX | libraries for SQL, streaming, ML and graphs |
| Spark UI / admin console | web page showing jobs, stages, tasks and executors |

**Key points**
- "A driver plans, executors run tasks"; the cluster manager allocates resources; data sources feed one Spark Core.
- Spark ships a copy of each variable used in a function to every task (use broadcast variables for big lookups).
- Lab `8.1-SparkBasics.ipynb`: start a SparkSession, read Chicago food inspections (~277K rows) into a DataFrame, look at schema and stats.
- Runs locally with Java 17+ and `pyspark`, or on a managed cluster such as Dataproc.

**Memorize vs. look up:** Memorize driver vs executor vs cluster manager.

Related: [[RDDs, Lazy Evaluation and DAGs]], [[Partitions and Shuffles]], [[Spark DataFrames and SQL]], [[Google Cloud Dataproc]]

*The YARN / Kubernetes examples and library names are general background; the slide shows the component diagram.*
