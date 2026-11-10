---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Structured vs Semi-structured vs Unstructured Data
**In one line:** How much shape the data has (fixed tables, patterned text, or no structure), plus the file formats used to store it.

**In plain words:** Structured data has fixed, well-defined fields (numbers, dates, addresses). Semi-structured data is text with a pattern or labels (JSON, XML, logs), so fields can vary. Unstructured data has no built-in structure (audio, video, PDFs, images). The file format you choose changes storage cost, query speed and how easily other tools can read it. Always keep the raw copy untouched.

**Terms**
| Term | Means |
|---|---|
| Delimited text | CSV / TSV / pipe: fields split by a character |
| JSON | name/value pairs and ordered lists; lightweight and platform-independent |
| XML | self-describing, extensible tagged text |
| Row formats | CSV, JSON: human-readable, slow for analytics |
| Columnar formats | Parquet, ORC: compressed, fast analytics |
| Binary formats | Avro, Protocol Buffers: compact, schema-enforced, good for streaming |
| Open table formats | Delta, Iceberg, Hudi: add ACID and versioning |
| Encoding | maps characters to bytes (ASCII, UTF-8, UTF-16) |
| Mojibake | garbled text from reading with the wrong encoding |

**Key points**
- **Raw → Cleaned → Curated:** raw is exactly as retrieved (immutable, timestamped); cleaned is validated and deduplicated; curated is documented, access-controlled and ready to use.
- Never overwrite raw; if a bug shows up downstream, reprocess from raw.
- Always specify the encoding (usually UTF-8) when reading text files.

**Memorize vs. look up:** Memorize the three data types, row vs columnar, and raw → cleaned → curated.

Related: [[The 4 Vs of Data]], [[Object Storage]], [[Medallion Architecture]], [[Data Lakehouse]]
