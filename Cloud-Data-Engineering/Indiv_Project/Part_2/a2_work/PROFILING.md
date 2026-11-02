# Part 1 — Dataset Acquisition & Profiling

## 1. Acquisition option
**Option B, public real-world data.** No synthetic rows, people, or values are generated. One reproducible script (`scripts/build_flat_table.py`) reshapes and joins two public sources into a single flat, denormalised table.

| Source | Provider | URL | License | Downloaded |
|---|---|---|---|---|
| Building Data Genome Project 2 (BDG2), commit 9b97ccbe | BUDS Lab, NUS (Miller et al., 2020) | https://github.com/buds-lab/building-data-genome-project-2 | CC BY-SA 4.0 | 2026-10-31 |
| EIA-861M Monthly Electric Sales & Revenue (`sales_revenue.xlsx`, sheet Monthly-States) | U.S. Energy Information Administration | https://www.eia.gov/electricity/data/eia861m/xls/sales_revenue.xlsx | U.S. Government public domain | 2026-11-01 17:31 CST (sha256 c7963ad7…4044e) |

Citation: Miller, C. et al. *The Building Data Genome Project 2, energy meter data from the ASHRAE Great Energy Predictor III competition.* Sci Data 7, 368 (2020). doi:10.1038/s41597-020-00712-x.

The BDG2 paper (Tables 4–5) states that all energy meters were converted to **kWh**, with chilled water converted from tons × 3.51685. Its site table lists Austin, TX ("Univ. of Texas – Austin") as one of the sites. Bull's US/Central timezone and 30.2672, -97.7431 centroid match Austin, consistent with the A1 deck.

## 2. Construction (what the script does)
1. Filter BDG2 metadata to site `Bull` (124 buildings).
2. Read cleaned hourly meters for electricity (123), chilled water (95), and steam (90), giving **308 meters**. Restrict to 2017-07-01 00:00 through 2017-09-30 23:00, unpivot wide to long, and aggregate per meter per day: sum, max hour, hour of max, count of non-null hours.
3. Aggregate Bull hourly weather to daily values.
4. Join the Texas commercial average retail price for Jul/Aug/Sep 2017 from EIA-861M (status "Final").
5. Apply unit rates. Electricity uses the EIA price. Chilled water and steam use the assumptions in ASSUMPTIONS.md (A-004, A-005). Compute estimated daily cost.

Reproduce:
```
python -I scripts/build_flat_table.py ../../Dataset/BDG2 sources/eia_861m/sales_revenue.xlsx data/flat_campus_energy_daily.csv
```

## 3. Volume
**28,336 rows × 29 columns** = 308 meters × 92 days. No duplicate (meter, date) pairs. CSV is 8.3 MB.
Rows by utility: electricity 11,316; chilled water 8,740; steam 8,280.

## 4. Data dictionary (observed types)
| # | Column | Type | Nulls | Distinct | Business concept |
|---|---|---|---|---|---|
| 1 | reading_id | int | 0 | 28,336 | Reading (surrogate) |
| 2 | reading_date | date | 0 | 92 | Reading |
| 3 | meter_code | text "building\|utility" | 0 | 308 | Meter (**non-atomic composite**) |
| 4 | utility_type | text | 0 | 3 | Utility |
| 5 | unit | text | 0 | 1 | Utility |
| 6 | building_name | text | 0 | 124 | Building |
| 7 | building_kaggle_id | int | 0 | 124 | Building |
| 8 | site_name | text | 0 | 1 | Site |
| 9 | timezone | text | 0 | 1 | Site |
| 10–11 | lat, lng | decimal | 0 | 1 | Site |
| 12 | primary_space_usage | text | 0 | 6 | Space-usage category (parent) |
| 13 | sub_space_usage | text | 0 | 16 | Space-usage category (child) |
| 14–15 | gross_sqm, gross_sqft | decimal | 0 | 123 | Building |
| 16 | daily_consumption_kwh | decimal | 237 | 20,724 | Reading |
| 17 | peak_hour_kwh | decimal | 237 | 9,284 | Reading |
| 18 | peak_hour | int 0–23 | 237 | 24 | Reading |
| 19 | hours_reported | int 0–24 | 0 | 21 | Reading (data quality) |
| 20–23 | avg_air_temp_c, max_air_temp_c, avg_dew_temp_c, total_precip_mm | decimal | 0 | ≤92 | Weather (site-day) |
| 24 | weather_hours | int | 0 | 3 | Weather (data quality) |
| 25 | tx_comm_price_cents_kwh | decimal | 0 | 3 | Tariff (month) |
| 26 | eia_data_status | text | 0 | 1 | Tariff |
| 27 | unit_rate_usd | decimal | 0 | 6 | Tariff (utility × month) |
| 28 | rate_source | text | 0 | 3 | Tariff |
| 29 | est_daily_cost_usd | decimal | 237 | 18,148 | Reading (derived) |

## 5. Five-row preview (selected columns; full rows are in the CSV)
```
reading_id reading_date meter_code                         building_name         primary_space_usage            sub_space_usage   gross_sqm daily_consumption_kwh peak_hour_kwh peak_hour hours_reported avg_air_temp_c unit_rate_usd est_daily_cost_usd
1          2017-07-01   Bull_assembly_Amalia|chilledwater  Bull_assembly_Amalia  Entertainment/public assembly  Sports Stadium    52377.0   98524.7334            4450.8325     15        24             30.4417        0.0206        2029.61
2          2017-07-01   Bull_assembly_Amalia|electricity   Bull_assembly_Amalia  Entertainment/public assembly  Sports Stadium    52377.0   9366.0                415.0         22        24             30.4417        0.0824        771.76
3          2017-07-01   Bull_assembly_Amalia|steam         Bull_assembly_Amalia  Entertainment/public assembly  Sports Stadium    52377.0   1916.3151             100.467       7         24             30.4417        0.0340        65.15
4          2017-07-01   Bull_assembly_Beau|chilledwater    Bull_assembly_Beau    Entertainment/public assembly  Conference Center 46789.1   72685.2662            3421.1773     1         24             30.4417        0.0206        1497.32
5          2017-07-01   Bull_assembly_Beau|electricity     Bull_assembly_Beau    Entertainment/public assembly  Conference Center 46789.1   9774.0                523.0         0         24             30.4417        0.0824        805.38
```

## 6. Real anomalies present (input for Part 2)
- **Repeated entity data (duplicate groups):** every building's name, usage, and area repeat on each of its meter-day rows. For example, `Bull_lodging_Caren` appears on 276 rows (3 utilities × 92 days). Site, timezone, and lat/lng repeat on all 28,336 rows. Weather repeats 308× per day. The EIA price repeats on about 9,400 rows per month.
- **Inconsistent casing:** sub_space_usage `Office` (16 buildings) vs `office` (1), and `garage` (5) in lower case while every other value is Title Case.
- **Nulls:** 237 meter-days with no readings. `Bull_office_Mai|electricity` is null for all 92 days, so the meter exists but has no consumption. Another 698 meter-days are partial (1–23 hours).
- **Non-atomic value:** meter_code packs building and utility into one string.
- **Shared values that are not duplicates:** `Bull_lodging_Charlotte` and `Bull_lodging_Xavier` both have 750.6 m².
- **Zero-consumption days:** 647 (mostly steam and chilled water shut-off in summer).
