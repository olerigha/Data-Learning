---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]], [[Cloud-Data-Engineering/Week7/README|Week 7 README]]"
status: new
tags: [generated]
---
# DynamoDB Key Design
**In one line:** In DynamoDB you design the table around the queries you'll run: a partition key picks where data lives, a sort key orders it, and anything else needs an index or a costly scan.

**In plain words:** DynamoDB is AWS's serverless key-value store: no servers, no capacity planning, fast reads at any scale. But there are no joins and no ad-hoc SQL. So instead of normalizing, you "pre-join" when writing. For example, store each order line together with its order header, so one query returns everything. The partition key is hashed to decide which storage partition an item lives on. The sort key orders items inside that partition, so you can ask for ranges. Pick keys from your access patterns first.

**Terms**
| Term | Means |
|---|---|
| Item | one record (like a row); can hold nested lists and maps |
| Partition key (pk) | hashed to choose the storage partition |
| Sort key (sk) | orders items within a partition; enables range queries |
| Primary key | pk alone, or pk + sk; must be unique |
| Hot partition | one key gets too much traffic; avoid with high-cardinality pk |
| `get_item` / `query` / `scan` | one item by full key / items sharing a pk / read the whole table |
| GSI | Global Secondary Index: a different pk + sk; add any time; eventually consistent; own cost |
| LSI | Local Secondary Index: same pk, different sk; only at table creation |
| TTL | time-to-live: items auto-delete after a timestamp |
| DynamoDB Streams | ordered log of item changes (feeds Lambda / Kinesis for CDC) |

**Key points**
- Cost of reads: `get_item` (cheapest) < `query` (one partition) ≪ `scan` (entire table). Avoid scans.
- `query(pk = 103)` is like `WHERE customerNumber = 103`, but with no join.
- **Single-table design:** all entity types in one table, told apart by pk/sk prefixes.
- Flexible schema: add an attribute to one item, with no ALTER TABLE.
- Relate items with key lookups and join in application code.
- Labs: Orders (composite keys), Customers (GSIs), MLInferences (time series + TTL).

**Memorize vs. look up:** Memorize pk vs sk, get vs query vs scan, and GSI vs LSI.

Related: [[Key-Value and Wide-Column Stores]], [[Normalization]], [[Database Keys]], [[Polyglot Persistence]], [[Serverless Computing]]
