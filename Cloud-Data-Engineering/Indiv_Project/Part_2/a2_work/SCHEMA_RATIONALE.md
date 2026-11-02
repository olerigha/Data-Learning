# Part 3 — Conceptual & Logical Data Model (report draft)

Artifacts: `design/erd_conceptual.png` (M:N shown unresolved), `design/erd_conceptual_resolved.png`, `design/erd_logical.png`; Mermaid sources `design/*.mmd`; DDL `deliverables/schema.sql`.

## 3a. Conceptual model
Seven business entities, shown with relationships only:
- SITE contains 1..N BUILDINGs.
- SITE records 0..N daily WEATHER_OBSERVATIONs.
- SPACE_USAGE classifies 0..N BUILDINGs.
- SPACE_USAGE is the parent of 0..N SPACE_USAGEs (recursive).
- BUILDING **is metered for** UTILITY_TYPE, which is **M:N**: one building is metered for 1–3 utilities, and one utility is metered in 90–123 buildings.
- UTILITY_TYPE is billed at 0..N TARIFF_RATEs.
- MARKET_PRICE (EIA) is the basis for 0..N TARIFF_RATEs. This is optional: steam has no market basis.

The resolved view replaces the M:N with the associative entity **METER**. Each meter produces 0..N DAILY_READINGs.

## 3b. Logical model (9 tables)
See `design/erd_logical.png`. Mermaid can't put parentheses in type names, so DECIMAL_10_1 means DECIMAL(10,1), and so on. Every table has a primary key. All 9 FKs are declared, and 12 CHECK constraints are enforced (MySQL ≥ 8.0.16).

| Relationship | Cardinality | Implemented by |
|---|---|---|
| site → building | 1 : 1..N | building.site_id NOT NULL |
| site → weather_daily | 1 : 0..N | weather_daily PK (site_id, weather_date) |
| space_usage → space_usage | 0..1 : 0..N | parent_usage_id NULL self-FK |
| space_usage → building | 1 : 0..N | building.space_usage_id NOT NULL (leaf level) |
| building → meter | 1 : 1..N | meter.building_id NOT NULL |
| utility_type → meter | 1 : 0..N | meter.utility_type_id NOT NULL; UNIQUE (building_id, utility_type_id) |
| meter → daily_reading | 1 : 0..N | daily_reading PK (meter_id, reading_date) |
| utility_type → tariff_rate | 1 : 0..N | UNIQUE (utility_type_id, rate_month) |
| eia_price_monthly → tariff_rate | 0..1 : 0..N | tariff_rate.eia_price_id NULL |

## 3c. Structural requirements
| Requirement | Met by | Evidence |
|---|---|---|
| ≥ 6 entities | 9 tables | `SHOW TABLES` returned 9 (local test 2026-11-01) |
| M:N via junction | building ↔ utility_type through **meter** | 308 meters; buildings by utility count: 88 have 3, 8 have 2, 28 have 1; utility → buildings: elec 123, CHW 95, steam 90 |
| Recursive hierarchy | **space_usage.parent_usage_id → space_usage** | `WITH RECURSIVE` walk returns e.g. "Services > Garage", "Office > Office" |

## Design choices (with the alternative rejected)
- **The meter is the junction, not a bare link table.** In BDG2 the physical meter is the thing that exists, with its own identifier and its own readings. That makes it a real associative entity rather than a two-column bridge. Rejected alternative: a `building_utility` bridge table, with readings keyed on (building_id, utility_type_id). It would carry the same information but lose the meter as an addressable asset.
- **Hierarchy via a self-FK (adjacency list) rather than separate primary/sub tables.** The data has only two levels, but a self-reference lets facilities add a third level (e.g., Education > Laboratory > Wet Lab) without a schema change. Rejected alternative: a `primary_usage` table plus a `sub_usage` table, which fixes the depth at two.
- **Composite natural PK on daily_reading** (D-008). It enforces one reading per meter per day without an extra 4-byte surrogate on 28k rows. InnoDB clusters the table by (meter_id, reading_date), which suits per-meter time-series scans. Date-range scans across all meters are not served by this order; that gap is the Part 6 indexing target.
- **ON DELETE RESTRICT** everywhere, except tariff_rate → eia_price_monthly (`SET NULL`). The tariff stays valid if its market reference is withdrawn. Restricting deletes also removes the Part 2 deletion anomaly: a usage category can't vanish while buildings use it (test T6).
- **Derived values are not stored.** Cost = kWh × unit_rate_usd and sqft = sqm × 10.7639 are computed in SQL. Exact SQL total for the quarter: **$14,832,619.22**. The flat CSV's per-row rounded column sums to $14,832,619.04 because of floating-point half-even rounding in pandas; the database figure is authoritative.
- **Types:** DECIMAL, not FLOAT, for energy and money, so sums are exact (confirmed above). The smallest integer type that fits each key. utf8mb4.

## Pre-deployment validation (local, not RDS)
Run against an isolated MySQL 26.10 test instance (localhost:3307, throwaway, no credentials reused):
- `schema.sql` executed twice without error, so it is re-runnable.
- `load_3nf.py` loaded 9 tables / 28,897 rows in 0.3 s. The COUNT(*) totals match the CSVs.
- Negative tests all rejected: orphan FK (1452), duplicate building+utility meter (1062), consumption with 0 hours, hours = 25, tariff month not on the 1st (3819), deleting an in-use usage category (1451).

**Caveat:** RDS will run MySQL 8.0.x, not 26.10. All syntax used (CHECK, WITH RECURSIVE, window functions) exists in 8.0.16+, but the RDS run is the evidence that counts.
