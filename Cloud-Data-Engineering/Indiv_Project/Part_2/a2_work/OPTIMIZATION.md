# Part 6 — Optimization, With Proof (report draft)

**Evidence:** `evidence/phase6_experiment.txt`, captured on the live RDS instance (MySQL **8.4.11**, run at 2026-11-02 02:38:10 UTC) by `deliverables/phase6_experiment.sql`. Each plan was run 3 times and the **median** is reported. `evidence/phase6_before.txt` is **not used**: it was captured while the test index already existed (see PROJECT_LOG).

## 6a. The two most join-heavy queries
- **Q1** (cost per m², August 2017): 7 tables (daily_reading, meter, utility_type, tariff_rate, building, space_usage ×2).
- **Q5** (cost roll-up by usage hierarchy, WITH ROLLUP): 6 tables (daily_reading, meter, tariff_rate, building, space_usage ×2).

Full baseline EXPLAIN ANALYZE output for both is in Appendix A below (paste from `phase6_experiment.txt`, blocks `Q1 BASELINE run 2` and `Q5 BASELINE run 2`).

## 6b. Index hypothesis and results (Q1)
**Hypothesis (H1):** `CREATE INDEX idx_dr_meter_date_kwh ON daily_reading (meter_id, reading_date, consumption_kwh);` The baseline reads `daily_reading` once per meter, and this covering index holds every column Q1 needs from that table, so those lookups should get cheaper. Two alternatives were also tested so the conclusion doesn't rest on a single guess.

| Run set (RDS 8.4.11) | Access on daily_reading | Rows examined on dr | Rows kept | Q1 runtime ms (3 runs) | **Median** |
|---|---|---|---|---|---|
| Baseline (PK only) | `Index lookup on dr using PRIMARY (meter_id=m.meter_id)` | 92 × 308 loops = **28,336** | 31 × 308 = **9,548** | 44.3 / 41.5 / 53.6 | **44.3** |
| H1 `(meter_id, reading_date, consumption_kwh)` | *unchanged*: PRIMARY | 28,336 | 9,548 | 42.3 / 42.4 / 52.0 | **42.4** |
| H2 `(reading_date, meter_id, consumption_kwh)` | *unchanged*: PRIMARY | 28,336 | 9,548 | 43.5 / 41.7 / 41.4 | **41.7** |
| H3 on tariff_rate `(rate_month, utility_type_id, unit_rate_usd)` | *unchanged*: PRIMARY; join reordered (`Table scan on tr` rows=9 → `Single-row index lookup on tr using uq_tariff_utility_month`) | 28,336 | 9,548 | 41.8 / 42.0 / 42.9 | **42.0** |

None of the new indexes appears in any plan line: `using idx_dr_*` and `using idx_tr_month_utility` occur 0 times.

Where the Q1 time goes (baseline run 2): the 7-table nested-loop join finishes at **12.8 ms**, result streaming reaches **20.7 ms**, and the `Sort` of 9,548 rows plus the `Group aggregate` run from **30.2 to 41.3 ms**. The query finishes (`Limit`) at **41.5 ms**.

## 6c. Empirical analysis (3–4 sentences)
On RDS MySQL 8.4.11, Q1's baseline plan reads `daily_reading` through the clustered primary key (`Index lookup on dr using PRIMARY (meter_id=m.meter_id)`). That examines 92 rows × 308 loops = 28,336 rows, and a post-lookup date `Filter` keeps only 31 per loop (9,548 rows), for a median runtime of 44.3 ms. My hypothesised covering index `idx_dr_meter_date_kwh` **did not improve performance**. The optimizer kept the PRIMARY lookup with an identical 28,336 rows examined, and the median of 42.4 ms is inside the baseline's 41.5–53.6 ms run-to-run spread. The reason is that InnoDB's clustered key `(meter_id, reading_date)` already stores every column Q1 needs, so the secondary copy is costed the same (0.296 vs 0.297 per lookup). A `ref` lookup also uses only the equality prefix `meter_id`, so the August range is still applied as a filter. A date-leading index (H2, 41.7 ms) and a tariff_rate index (H3, 42.0 ms) were also not used for `daily_reading`; H3 only reordered the 9-row tariff scan into single-row lookups. The plans show the real cost is after the join: the join is done by 12.8 ms, while sorting and grouping 9,548 rows take about 11 ms (30.2 → 41.3 ms), work that no index on these tables removes.

## Q5 observation (second profiled query)
Q5 joins `tariff_rate` **before** `daily_reading`, through the non-sargable condition `tr.rate_month = DATE_FORMAT(dr.reading_date,'%Y-%m-01')`. Each meter's 92 readings are therefore read once per tariff month: `rows=92 loops=924` = **85,008 rows examined to produce 28,336** (3.0×). The median runtime is **124 ms**, with the join finishing at about 52.5 ms. H1 (123 ms) and H2 (132 ms) left the plan unchanged. This is a query and schema design issue, not an indexing one. Storing the reading's month (or joining on a date range) would let the month match on the key, and that should be tested before production.

## Decision
No index is kept for production. Each one adds write and storage cost on `daily_reading` (28k rows → about 300 rows/day in steady state) with no measured read benefit. For the required "after" screenshot, H1 is recreated, shown in `SHOW INDEX`, and shown **not** being used in `EXPLAIN ANALYZE`, which is consistent with the analysis above.

## Appendix A — full baseline plans
*(Insert verbatim from `evidence/phase6_experiment.txt`: "Q1 BASELINE run 2" and "Q5 BASELINE run 2".)*
## Appendix B — full after plans
*(Insert verbatim: "Q1 H1 run 2", plus H2/H3 run 2 for completeness.)*
