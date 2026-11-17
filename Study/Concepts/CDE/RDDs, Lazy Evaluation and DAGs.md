---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]], [[Cloud-Data-Engineering/Week8/Week8/README|Week 8 README]]"
status: new
tags: [generated]
---
# RDDs, Lazy Evaluation and DAGs
**In one line:** Spark's data lives in RDDs (unchangeable, partitioned collections); transformations only build a plan (a DAG), and nothing runs until an action asks for a result.

**In plain words:** An RDD is Spark's basic dataset: split into partitions spread across machines, kept in memory, and never modified in place. Each step makes a new RDD. Transformations (`map`, `filter`, `join`) are lazy: Spark just records them in a plan, a directed acyclic graph (DAG). When you call an action (`count`, `sum`, `first`), Spark optimizes the whole plan and runs it. Because Spark remembers how each RDD was built (its lineage), it can rebuild a lost partition instead of saving copies to disk.

**Terms**
| Term | Means |
|---|---|
| RDD | Resilient Distributed Dataset: immutable, fault-tolerant, partitioned collection |
| Partition | one chunk of the data, processed by one task |
| Transformation | builds a new RDD from an old one (`map`, `filter`, `join`, `union`); lazy |
| Action | returns a value and triggers execution (`reduce`, `count`, `first`) |
| Lazy evaluation | nothing runs until an action |
| DAG | directed acyclic graph: steps flow one way, never loop back |
| Lineage | the recorded chain of transformations; used to recompute lost partitions |
| Job → stage → task | one action = one job; shuffles split it into stages; each stage runs one task per partition |

**Key points**
- RDD parts: partitions, dependencies on parent RDDs, a compute function, and partitioning metadata.
- RDDs are recomputed on every action unless you `cache()` / `persist()` them.
- **Stage boundaries are shuffles:** narrow steps chain together in one stage; a wide step starts a new stage.
- Spark runs one task per partition; aim for 2–4 partitions per CPU.
- `df.explain()` shows the plan before anything runs.

**Example:** `sc.textFile(...).map(to_int).filter(lt_10).sum()`. `map` and `filter` just add to the plan; `sum()` is the action that runs the job on every partition and adds the partial sums.

**Memorize vs. look up:** Memorize transformation vs action, lazy evaluation, and job → stage → task.

Related: [[Spark Architecture]], [[Partitions and Shuffles]], [[Spark DataFrames and SQL]], [[Data Governance and Lineage]]
