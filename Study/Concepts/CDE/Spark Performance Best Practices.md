---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]]"
status: new
tags: [generated]
---
# Spark Performance Best Practices
**In one line:** Spark speed comes from data layout and avoiding shuffles: columnar files, right-sized files, filtering early, broadcast joins, adaptive execution, and fixing skew, diagnosed in the Spark UI first.

**In plain words:** Most slow Spark jobs read too much data, move too much data, or have one straggler task. So store data as Parquet/Delta in reasonably large files, partition by date-like columns, read only the columns and rows you need, and broadcast small tables instead of shuffling big ones. Turn on adaptive query execution. Check the Spark UI before guessing. Memory matters too: when data spills to disk, everything gets 10–100× slower.

**Terms**
| Term | Means |
|---|---|
| Parquet / Delta | columnar file formats; read only the needed columns |
| Pruning | skipping partitions and columns a query doesn't need |
| Broadcast join | send a small table to every executor; no shuffle |
| AQE | Adaptive Query Execution: re-plans at runtime (merges partitions, splits skewed joins) |
| Spill | data overflowing memory onto disk |
| GC | garbage collection pauses in the Java runtime |
| Spot / preemptible workers | cheap, interruptible machines |

**Key points**
| Area | Best practice |
|---|---|
| File format | Parquet or Delta, not CSV or JSON |
| File size | 128 MB – 1 GB per file; compact after big loads |
| Partitioning | by date or low-cardinality columns (< 100 values); never by user ID |
| Early pruning | filter early, select only needed columns |
| Joins | broadcast small tables (< 10 MB default) |
| UDFs | built-in functions or Pandas UDFs; plain Python UDFs are slow |
| Diagnose | Spark UI: SQL tab, stage max vs median task time, executor GC and spill |
| AQE | `spark.sql.adaptive.enabled = true` (Spark 3+) |
| Skew | salt hot keys or pre-bucket at write time |
| Memory | size executor memory; cache DataFrames you reuse |
| Right engine | pandas/DuckDB < 10 GB; Polars 10–100 GB; Spark > 100 GB |
| Benchmarking | fixed data, one warm-up run, median of 3 |
| Cost | spot workers (60–90% cheaper), auto-terminate, off-peak runs |

- Memory: Spark memory ≈ 0.75 × (heap − 300 MB), split into storage (cache, broadcasts) and execution (shuffles), which can borrow from each other.

**Memorize vs. look up:** Memorize "layout and shuffles", broadcast small tables, and the right-engine sizes. Look up the exact settings.

Related: [[Partitions and Shuffles]], [[Spark DataFrames and SQL]], [[Cloud Cost Management]], [[Structured vs Semi-structured vs Unstructured Data]]
