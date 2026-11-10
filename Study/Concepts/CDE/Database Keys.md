---
course: CDE
week: 3
source: "[[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Database Keys
**In one line:** Columns that uniquely identify a row (primary key) or point to a row in another table (foreign key).

**In plain words:** Every row needs an ID that's never blank and never repeated: that's the primary key. To link tables, copy one table's primary key into another as a foreign key. A payment row carries the customer's number. The database then refuses any foreign key that doesn't match a real row, so there are no "orphan" payments.

**Terms**
| Term | Means |
|---|---|
| PK | primary key: unique, never NULL |
| FK | foreign key: must match an existing PK in another table |
| Composite key | a key made of several columns |
| Candidate key | any minimal set of columns that could be the PK |
| Natural key | a real-world ID (email, product code): meaningful but can change |
| Surrogate key | system-made ID (auto-increment, UUID): stable, no meaning |
| Lookup table | small reference table (status codes, cities) |

**Key points**
- Three integrity rules:
  - **Entity integrity:** PK is unique and not NULL.
  - **Referential integrity:** every FK matches a real PK.
  - **Domain integrity:** data types, NOT NULL, CHECK, DEFAULT (e.g. $100 < creditLimit < $1,000,000).
- Choosing natural vs surrogate: is it stable? minimal? do users search by it? fast enough?
- Warehouses (Wk 5) use surrogate keys so dimension history can be tracked.

**Memorize vs. look up:** Memorize PK vs FK, natural vs surrogate, and the three integrity rules.

Related: [[Entities, Relationships and Cardinality]], [[Normalization]], [[SQL Joins]], [[Slowly Changing Dimensions]]
