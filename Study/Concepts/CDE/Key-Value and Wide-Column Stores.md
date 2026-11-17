---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]]"
status: new
tags: [generated]
---
# Key-Value and Wide-Column Stores
**In one line:** Key-value stores map one unique key to one value for instant lookups; wide-column stores give each row a key and a flexible, sparse set of columns for massive write volumes.

**In plain words:** A key-value store is like a giant dictionary: give it a key, get the value back in constant time. There's no query language and no searching by other fields. It's simple and blazing fast. A wide-column store is a step up: each row has a key, but rows can have different columns, and it's built to absorb enormous numbers of writes, which suits sensor readings and activity logs.

**Terms**
| Term | Means |
|---|---|
| Key-value store | unique key → value (string, binary or structured) |
| O(1) | constant time: same speed however big the table |
| Redis | in-memory key-value store; sub-millisecond; lists, sets, hashes, sorted sets |
| DynamoDB | AWS serverless key-value / document store; auto-scaling; single-digit ms |
| Wide-column store | row key + dynamic columns that can differ per row |
| Bigtable | GCP wide-column store; petabyte scale; powers Search and Maps |
| Cassandra | open-source wide-column; tunable consistency; AP by default |

**Key points**
- **Key-value uses:** session caching, rate limiting, leaderboards, feature flags, pub/sub.
- **Wide-column uses:** time series (IoT), activity logs, recommendation signals.
- No secondary indexes by default; querying by anything but the key means scanning.

**Memorize vs. look up:** Memorize what each is for and one product each.

Related: [[DynamoDB Key Design]], [[NoSQL and the CAP Theorem]], [[Polyglot Persistence]]
