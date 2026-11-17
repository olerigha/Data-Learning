---
course: CDE
week: 8
source: "[[Week8-ParallelDistributed.pdf]], [[Cloud-Data-Engineering/Week8/Week8/README|Week 8 README]]"
status: new
tags: [generated]
---
# Spark DataFrames and SQL
**In one line:** Spark DataFrames are distributed, schema-aware tables. Write the logic in Python or in SQL and Spark builds the same optimized plan.

**In plain words:** A Spark DataFrame looks like a pandas table, but it's split across the cluster, lazy (nothing runs until an action), and immutable (each step returns a new DataFrame). Because Spark knows the columns and types, its optimizer can rearrange your steps for speed. Spark SQL lets you query the same data with plain SQL. DataFrames and Spark SQL are now the default way to use Spark; RDDs sit underneath.

**Terms**
| Term | Means |
|---|---|
| Spark DataFrame | distributed table with a schema |
| Eager vs lazy | pandas runs each line now / Spark waits for an action |
| Immutable | can't change in place; transformations return a new DataFrame |
| Spark SQL | run SQL (and HiveQL) on DataFrames and tables |
| Catalyst | Spark's query optimizer |
| Hive / SerDes / UDFs | older Hadoop warehouse, its serializers, user-defined functions (all supported) |

**Key points**
| | pandas | PySpark DataFrame |
|---|---|---|
| Runs on | one machine | many nodes in parallel |
| Evaluation | eager | lazy |
| Mutability | can modify in place | immutable |
| API size | larger, richer | smaller |

```python
df = spark.read.csv("food-inspections/food-inspections.csv", header=True, inferSchema=True)
df.createOrReplaceTempView("inspections")
spark.sql("SELECT Results, COUNT(*) FROM inspections GROUP BY Results").show()
```
In words: load the CSV as a distributed table, give it a SQL name, then count inspections per result. `show()` is the action that runs it.

**Memorize vs. look up:** Memorize the pandas vs PySpark table. Look up the API.

Related: [[RDDs, Lazy Evaluation and DAGs]], [[Spark Performance Best Practices]], [[GROUP BY and HAVING]], [[SQL from Python]]

*The code snippet is a general example on the lab's dataset, not copied from the notebook.*
