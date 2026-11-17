---
course: CDE
week: 7
source: "[[Week7-NoSQL.pdf]], [[Cloud-Data-Engineering/Week7/README|Week 7 README]]"
status: new
tags: [generated]
---
# Document Databases
**In one line:** Store each record as a self-describing JSON-like document, so different documents can have different fields and related data can sit inside the same document.

**In plain words:** Instead of spreading a blog post over separate posts, tags and comments tables, a document database (MongoDB) keeps the whole post, its tags and its comments in one document. Reading it needs no joins. Documents in the same collection don't have to share a schema. The key design choice is whether to **embed** related data (fast reads, data owned by one parent) or **reference** it by ID (shared data, used by many).

**Terms**
| Term | Means |
|---|---|
| Document | self-describing JSON/BSON object |
| Collection | group of documents (like a table, but no fixed schema) |
| BSON | binary JSON: how MongoDB stores and sends data |
| `_id` / ObjectId | each document's unique primary key |
| Embedding | nest related data inside the document |
| Referencing | store another document's `_id`; combine with `$lookup` |
| JSON Schema validation | optional rules to enforce structure |
| JSON types | number, string, Boolean, array `[ ]`, object `{ }`, null |

**Key points**
- Platforms: MongoDB Atlas, GCP Firestore, AWS DocumentDB, CouchDB.
- MongoDB: open-source, scale-out, drivers for many languages; indexes can be single, compound, text or geospatial.
- Example: blog relational design needs 3+ tables; the document design is one `posts` collection with tags and comments inside.
- Labs: CRUD, geospatial queries on Chicago restaurants mapped with Folium, a countries quiz.

**Memorize vs. look up:** Memorize embed vs reference and when to use each.

Related: [[NoSQL and the CAP Theorem]], [[Structured vs Semi-structured vs Unstructured Data]], [[Polyglot Persistence]], [[Normalization]]
