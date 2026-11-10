---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# The 4 Vs of Data
**In one line:** Four ways data can be "big": how much (Volume), how fast (Velocity), how many kinds (Variety), and how trustworthy (Veracity), plus a fifth, Value.

**In plain words:** These four questions shape the architecture. Terabytes need different storage than gigabytes. Data arriving every millisecond needs streaming, not a nightly job. Mixed formats need flexible storage like a lake. Messy or unreliable sources need quality checks. And the fifth V is a reminder: only store data that actually helps decisions.

**Terms**
| V | Means | Example |
|---|---|---|
| Volume | amount of data | terabytes to petabytes |
| Velocity | speed of arrival / processing | batch (hourly/daily) → near-real-time → streaming (ms) |
| Variety | kinds of data | tables, JSON/XML, images, audio, video, logs |
| Veracity | quality and reliability | missing values, schema drift, unreliable sources |
| Value | usefulness | data that drives decisions |

**Key points**
- Scale (volume) drives architecture choices.
- Velocity decides batch vs streaming.
- Veracity is why pipelines have quality gates.
- Schema drift = the structure of incoming data changes without warning.

**Memorize vs. look up:** Memorize the four Vs (+ Value).

Related: [[Structured vs Semi-structured vs Unstructured Data]], [[Batch vs Streaming]], [[Medallion Architecture]], [[Data Lakehouse]]
