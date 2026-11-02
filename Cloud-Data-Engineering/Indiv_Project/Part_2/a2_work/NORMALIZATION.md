# Part 2 — Normalization (report draft)

Input: `data/flat_campus_energy_daily.csv`, 28,336 rows × 29 columns, one row per meter per day (Bull site, 2017-07-01 to 2017-09-30). Workbook: `deliverables/normalization_workbook.xlsx` (tabs **1NF**, **2NF**, **3NF**). Script: `scripts/normalize.py`.

## 2.1 Data anomalies (actual rows)

**Insertion anomaly.** The electricity meter on `Bull_office_Mai` has no readings in the entire window. In the flat table, the only way to record that this meter exists is with reading rows. So it occupies 92 rows whose measurements are all NULL:

| reading_id | reading_date | meter_code | building_name | sub_space_usage | gross_sqm | daily_consumption_kwh | hours_reported |
|---|---|---|---|---|---|---|---|
| 280 | 2017-07-01 | Bull_office_Mai\|electricity | Bull_office_Mai | office | 792.0 | NULL | 0 |

The same applies the other way. A newly commissioned building, a new space-usage category, or the EIA October-2017 Texas price cannot be inserted until some meter reports a reading for that building or month.

**Deletion anomaly.** `Bull_assembly_Maren` is the only building whose sub-usage is *Swimming Pool*:

| reading_id | reading_date | meter_code | primary_space_usage | sub_space_usage | gross_sqm | daily_consumption_kwh |
|---|---|---|---|---|---|---|
| 34 | 2017-07-01 | Bull_assembly_Maren\|chilledwater | Entertainment/public assembly | Swimming Pool | 11345.5 | 35450.5750 |
| 35 | 2017-07-01 | Bull_assembly_Maren\|electricity | Entertainment/public assembly | Swimming Pool | 11345.5 | 7721.0000 |
| 36 | 2017-07-01 | Bull_assembly_Maren\|steam | Entertainment/public assembly | Swimming Pool | 11345.5 | 302.3312 |

Suppose its 276 reading rows are purged, for example because the pool's meters are decommissioned or a retention policy removes old readings. That would also delete the building's floor area (11,345.5 m²), its Kaggle ID, and the fact that *Swimming Pool* is a category under *Entertainment/public assembly*.

**Update anomaly.** `Bull_office_Mai` is stored with `sub_space_usage = 'office'` (lower case), while 16 other buildings use `'Office'`:

| reading_id | reading_date | meter_code | primary_space_usage | sub_space_usage |
|---|---|---|---|---|
| 279 | 2017-07-01 | Bull_office_Mai\|chilledwater | Office | office |
| 280 | 2017-07-01 | Bull_office_Mai\|electricity | Office | office |
| 281 | 2017-07-01 | Bull_office_Mai\|steam | Office | office |
| 587 | 2017-07-02 | Bull_office_Mai\|chilledwater | Office | office |

Fixing this one value means updating **276 rows**. If any are missed, the building has two different usages, and a `GROUP BY sub_space_usage` splits office buildings into two groups. The same problem hits any correction of `gross_sqm` (276 rows for a three-meter building) and any EIA price revision (the August price is repeated on 9,548 rows).

## 2.2 Functional dependencies

Each FD below was checked against all 28,336 rows by `scripts/normalize.py`; FD1–FD10 hold, and FD11 reproduces est_daily_cost_usd exactly. 1NF key: **{building_name, utility_type, reading_date}**.

| FD | Dependency | Type |
|---|---|---|
| FD1 | {building_name, utility_type, reading_date} → daily_consumption_kwh, peak_hour_kwh, peak_hour, hours_reported | full |
| FD2 | building_name → building_kaggle_id, site_name, primary_space_usage, sub_space_usage, gross_sqm, gross_sqft | partial |
| FD3 | building_kaggle_id → building_name | alternate key |
| FD4 | utility_type → unit | partial |
| FD5 | site_name → timezone, lat, lng | transitive |
| FD6 | sub_space_usage → primary_space_usage | transitive |
| FD7 | gross_sqm → gross_sqft (×10.7639) | derived / transitive |
| FD8 | {site_name, reading_date} → avg/max air temp, dew temp, precip, weather_hours | partial |
| FD9 | reading_date → reading_month → tx_comm_price_cents_kwh, eia_data_status | partial + transitive |
| FD10 | {utility_type, reading_month} → unit_rate_usd, rate_source | partial |
| FD11 | {daily_consumption_kwh, unit_rate_usd} → est_daily_cost_usd | derived |

## 2.3 Decomposition summary

- **1NF:** split the non-atomic `meter_code` ("building|utility") and drop the `reading_id` row surrogate. Gives one relation of 28 attributes with PK {building_name, utility_type, reading_date}.
- **2NF:** remove the partial dependencies FD2, FD4, FD8, FD9 and FD10. Gives R_building (124), R_utility (3), R_day_weather (92), R_utility_day_rate (276) and R_reading (28,336).
- **3NF:** remove the transitive and derived dependencies FD5, FD6, FD7, FD9 and FD11, then add surrogate keys. The result is **9 tables**:

| Table | Rows | PK | FKs | Role |
|---|---|---|---|---|
| site | 1 | site_id | — | campus |
| space_usage | 21 | space_usage_id | parent_usage_id → space_usage | **recursive hierarchy** (6 primary + 15 sub) |
| building | 124 | building_id | site_id, space_usage_id | |
| utility_type | 3 | utility_type_id | — | |
| meter | 308 | meter_id | building_id, utility_type_id | **junction for M:N building ↔ utility_type** |
| daily_reading | 28,336 | (meter_id, reading_date) | meter_id | fact |
| weather_daily | 92 | (site_id, weather_date) | site_id | |
| eia_price_monthly | 3 | eia_price_id | — | real EIA price |
| tariff_rate | 9 | tariff_rate_id | utility_type_id, eia_price_id (NULL for steam) | |

Total: 28,897 rows. A lossless-join check confirms the 9 tables re-join to exactly 28,336 rows, with identical consumption, usage, area, rate and weather values.

## 2.4 Business assumptions applied
See ASSUMPTIONS.md A-008 to A-013.
