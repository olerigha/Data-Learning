---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]]"
status: new
tags: [generated]
---
# MapReduce, Spark, Dask and Ray
**In one line:** Four frameworks for distributed computing: MapReduce (the disk-based original), Spark (in-memory, the standard), Dask (scales Python data science code), and Ray (distributed ML and AI apps).

**In plain words:** MapReduce splits a job into a "map" step that processes pieces in parallel and a "reduce" step that combines the results. It writes to disk between steps, so it's slow and hard to program. Spark (2012) does the same kind of work but keeps data in memory, offers high-level APIs, runs interactively, and handles both batch and streaming, so it replaced MapReduce for most work. Dask scales familiar pandas-style Python to data bigger than memory. Ray parallelizes arbitrary Python functions and is built for distributed ML and AI.

**Terms**
| Term | Means |
|---|---|
| Map | apply a function to each piece of data in parallel |
| Reduce | combine the mapped results into an answer |
| Hadoop | the ecosystem built around MapReduce and its distributed file system |
| Batch / streaming | process data in chunks / continuously |
| Stateless task / stateful actor (Ray) | a function call with no memory / a long-lived worker that keeps state |

**Key points**
- **MapReduce:** hard to program, disk-oriented (doesn't use cluster RAM), batch only, interactive only via Pig/Hive.
- **Spark:** easier high-level APIs, caches partial results in memory for low latency, interactive, batch and streaming.
- **Dask (2014):** best for scaling pandas / NumPy-style code past memory.
- **Ray (2016):** best for distributed ML, deep learning and AI applications.

**Memorize vs. look up:** Memorize why Spark beat MapReduce (memory, APIs, interactive, streaming) and Dask vs Ray.

Related: [[Distributed Computing and Amdahl's Law]], [[Spark Architecture]], [[Batch vs Streaming]]
