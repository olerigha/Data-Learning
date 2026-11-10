---
course: CDE
week: 3
source: "[[Week3-RelationalDatabases.pdf]]"
status: new
tags: [generated]
---
# Entities, Relationships and Cardinality
**In one line:** Entities are the "things" you store, relationships say how they connect, and cardinality says how many of one go with how many of the other.

**In plain words:** Read the business description and pick out the important nouns: Customer, Order, Product. Those become entities (tables). Then ask how they connect and in what numbers. One customer has many orders (1:N). One order has many products and one product is in many orders (M:N). An M:N link can't be stored directly, so you add a middle "junction" table.

**Terms**
| Term | Means |
|---|---|
| Entity | a real-world thing or event you store (becomes a table) |
| Attribute | a property of an entity (becomes a column) |
| Strong / weak / associative entity | stands alone / depends on another / links others |
| Cardinality | how many: 1:1, 1:N, M:N |
| Optionality | must vs may (e.g. a customer *may* have zero orders) |
| Junction (join) table | splits an M:N into two 1:N links |
| Composite / multi-valued attribute | made of parts (address) / can have several values (phones) |

**Key points**
- 1:1: user ↔ profile. 1:N: customer → orders. M:N: orders ↔ products through `orderdetails`.
- Relationship steps: first entity → related entity → optionality → relationship → cardinality.
- ClassicModels entities: Customers, Products, ProductLines, Orders, OrderDetails, Payments, Employees, Offices.

**Example:** "Many orders contain many products" ⇒ `orders` 1:N `orderdetails` N:1 `products`.

**Memorize vs. look up:** Memorize the three cardinalities and the junction-table fix for M:N.

Related: [[Conceptual, Logical and Physical Models]], [[Database Keys]], [[SQL Joins]], [[Normalization]]
