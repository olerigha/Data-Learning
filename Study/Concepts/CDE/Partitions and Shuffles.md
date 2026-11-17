---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]], [[Cloud-Data-Engineering/Week8/Week8/README|Week 8 README]]"
status: new
tags: [generated]
---
# Partitions and Shuffles
**In one line:** Narrow transformations work within each partition; wide ones must **shuffle** data across the network, which is the expensive part of Spark.

**In plain words:** If each output partition only needs one input partition (`map`, `filter`), every machine works alone: fast. If rows with the same key must be brought together from everywhere (`groupByKey`, `join`, `distinct`), data has to move between machines (a shuffle): slow. Controlling how many partitions you have, and keeping them balanced, is most of Spark tuning. One oversized partition (skew) makes everyone wait for one slow task.

**Terms**
| Term | Means |
|---|---|
| Narrow transformation | `map`, `filter`, `flatMap`, `mapPartitions`: no data movement |
| Wide transformation | `join`, `groupByKey`, `reduceByKey`, `distinct`, `repartition`: needs a shuffle |
| Shuffle | redistributing data across the network by key |
| `repartition(n)` | full shuffle to exactly $n$ partitions |
| `coalesce(n)` | reduce partitions *without* a full shuffle (good after filtering) |
| Skew / straggler | one partition much larger, so its task runs much longer |
| Salting | add a random suffix to hot keys to spread them out |
| Accumulator | shared counter: tasks only add, only the driver reads |
| Broadcast variable | read-only copy sent once to each executor (lookup tables, models) |

**Key points**
- Default parallelism ≈ 2 × CPU cores; tune for the workload.
- Use `coalesce` to shrink, `repartition` to grow or rebalance.
- Accumulators can double-count if used inside retried transformations; use them in actions like `foreach`.
- Broadcast variables must fit in memory; never modify them after sending.
- Lab: bar charts of rows per partition before and after `repartition` / `coalesce`.

**Memorize vs. look up:** Memorize narrow vs wide (with two examples each), repartition vs coalesce, and what skew is.

Related: [[RDDs, Lazy Evaluation and DAGs]], [[Spark Performance Best Practices]], [[Spark Architecture]]
