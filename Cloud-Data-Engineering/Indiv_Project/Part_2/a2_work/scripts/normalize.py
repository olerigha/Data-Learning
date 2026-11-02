"""
normalize.py — Assignment 2, Part 2: decompose the flat table 1NF -> 2NF -> 3NF.

  python -I normalize.py <FLAT_CSV> <OUT_3NF_DIR> <OUT_XLSX>

Outputs:
  * 3NF tables as load-ready CSVs (one per table) in OUT_3NF_DIR
  * Workbook with exactly three tabs: '1NF', '2NF', '3NF'
Includes a lossless-join check: the 3NF tables re-joined must reproduce every flat row.
"""
import sys
import numpy as np
import pandas as pd
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.utils import get_column_letter

FLAT, OUT_DIR, OUT_XLSX = sys.argv[1], sys.argv[2], sys.argv[3]
flat = pd.read_csv(FLAT)

# ---------------- 1NF ----------------
# Atomic values: split non-atomic meter_code "building|utility" into its two parts (both already
# present as columns, so meter_code is dropped). No repeating groups remain.
# Key: (building_name, utility_type, reading_date). reading_id is a row surrogate that is
# dropped so the key is natural.
nf1 = flat.drop(columns=["meter_code", "reading_id"]).copy()
assert not nf1.duplicated(["building_name", "utility_type", "reading_date"]).any()
nf1["reading_month"] = nf1.reading_date.str[:7] + "-01"   # atomic derived month, used for tariff FDs

# ---------------- 2NF ----------------
# Remove partial dependencies on the composite key {building_name, utility_type, reading_date}.
b_cols = ["building_name", "building_kaggle_id", "site_name", "timezone", "lat", "lng",
          "primary_space_usage", "sub_space_usage", "gross_sqm", "gross_sqft"]
nf2_building = nf1[b_cols].drop_duplicates().reset_index(drop=True)                 # {building_name}
nf2_utility = nf1[["utility_type", "unit"]].drop_duplicates().reset_index(drop=True)  # {utility_type}
nf2_day_weather = nf1[["reading_date", "site_name", "avg_air_temp_c", "max_air_temp_c",
                       "avg_dew_temp_c", "total_precip_mm", "weather_hours"]].drop_duplicates().reset_index(drop=True)
nf2_utility_day_rate = nf1[["utility_type", "reading_date", "reading_month", "tx_comm_price_cents_kwh",
                            "eia_data_status", "unit_rate_usd", "rate_source"]].drop_duplicates().reset_index(drop=True)
nf2_reading = nf1[["building_name", "utility_type", "reading_date", "daily_consumption_kwh",
                   "peak_hour_kwh", "peak_hour", "hours_reported", "est_daily_cost_usd"]].copy()
for name, df, key in [("building", nf2_building, ["building_name"]), ("utility", nf2_utility, ["utility_type"]),
                      ("day_weather", nf2_day_weather, ["reading_date"]),
                      ("utility_day_rate", nf2_utility_day_rate, ["utility_type", "reading_date"]),
                      ("reading", nf2_reading, ["building_name", "utility_type", "reading_date"])]:
    assert not df.duplicated(key).any(), f"2NF key violated in {name}"

# ---------------- 3NF ----------------
# Remove transitive dependencies; give each entity a surrogate key.
# Data-cleansing decision (D-007): sub-usage casing standardised to Title Case ('office'->'Office', 'garage'->'Garage').
site = (nf2_building[["site_name", "timezone", "lat", "lng"]].drop_duplicates()
        .rename(columns={"lat": "latitude", "lng": "longitude"}).reset_index(drop=True))
site.insert(0, "site_id", range(1, len(site) + 1))

prim = sorted(nf2_building.primary_space_usage.unique())
space_usage = pd.DataFrame({"usage_name": prim, "parent_usage_id": pd.array([pd.NA] * len(prim), dtype="Int64")})
space_usage.insert(0, "space_usage_id", range(1, len(prim) + 1))
pid = dict(zip(space_usage.usage_name, space_usage.space_usage_id))
bclean = nf2_building.copy()
bclean["sub_clean"] = bclean.sub_space_usage.str.strip().str.title()
subs = bclean[["primary_space_usage", "sub_clean"]].drop_duplicates().sort_values(["primary_space_usage", "sub_clean"])
sub_df = pd.DataFrame({"usage_name": subs.sub_clean.values,
                       "parent_usage_id": pd.array(subs.primary_space_usage.map(pid).values, dtype="Int64")})
sub_df.insert(0, "space_usage_id", range(len(prim) + 1, len(prim) + 1 + len(sub_df)))
space_usage = pd.concat([space_usage, sub_df], ignore_index=True)
sid = {(r.parent_usage_id, r.usage_name): r.space_usage_id for r in sub_df.itertuples()}

building = bclean.sort_values("building_name").reset_index(drop=True)
building["space_usage_id"] = [sid[(pid[p], s)] for p, s in zip(building.primary_space_usage, building.sub_clean)]
building["site_id"] = building.site_name.map(dict(zip(site.site_name, site.site_id)))
building.insert(0, "building_id", range(1, len(building) + 1))
building = building[["building_id", "building_name", "building_kaggle_id", "site_id", "space_usage_id", "gross_sqm"]]
building["building_kaggle_id"] = building.building_kaggle_id.astype(int)
# gross_sqft dropped: derived (sqft = sqm x 10.7639), a transitive dependency via sqm.

utility_type = nf2_utility.rename(columns={"utility_type": "utility_code"}).sort_values("utility_code").reset_index(drop=True)
utility_type.insert(0, "utility_type_id", range(1, len(utility_type) + 1))

uid = dict(zip(utility_type.utility_code, utility_type.utility_type_id))
bid = dict(zip(building.building_name, building.building_id))
meter = nf2_reading[["building_name", "utility_type"]].drop_duplicates().sort_values(["building_name", "utility_type"]).reset_index(drop=True)
meter.insert(0, "meter_id", range(1, len(meter) + 1))
meter["building_id"] = meter.building_name.map(bid)
meter["utility_type_id"] = meter.utility_type.map(uid)
meter["meter_code"] = meter.building_name + "|" + meter.utility_type
mid = {(r.building_name, r.utility_type): r.meter_id for r in meter.itertuples()}
meter = meter[["meter_id", "building_id", "utility_type_id", "meter_code"]]

daily_reading = nf2_reading.copy()
daily_reading["meter_id"] = [mid[k] for k in zip(daily_reading.building_name, daily_reading.utility_type)]
daily_reading = daily_reading[["meter_id", "reading_date", "daily_consumption_kwh", "peak_hour_kwh",
                               "peak_hour", "hours_reported"]].rename(columns={"daily_consumption_kwh": "consumption_kwh"})
daily_reading["peak_hour"] = daily_reading.peak_hour.astype("Int64")
daily_reading = daily_reading.sort_values(["meter_id", "reading_date"]).reset_index(drop=True)
# est_daily_cost_usd dropped: derived (consumption_kwh x unit_rate_usd), computed in queries.

weather_daily = nf2_day_weather.copy()
weather_daily["site_id"] = weather_daily.site_name.map(dict(zip(site.site_name, site.site_id)))
weather_daily = weather_daily.rename(columns={"reading_date": "weather_date", "weather_hours": "hours_observed"})
weather_daily = weather_daily[["site_id", "weather_date", "avg_air_temp_c", "max_air_temp_c",
                               "avg_dew_temp_c", "total_precip_mm", "hours_observed"]].sort_values("weather_date").reset_index(drop=True)

eia = nf2_utility_day_rate[["reading_month", "tx_comm_price_cents_kwh", "eia_data_status"]].drop_duplicates().sort_values("reading_month").reset_index(drop=True)
eia_price_monthly = pd.DataFrame({"eia_price_id": range(1, len(eia) + 1), "state_code": "TX", "sector": "COMMERCIAL",
                                  "price_month": eia.reading_month, "price_cents_kwh": eia.tx_comm_price_cents_kwh,
                                  "data_status": eia.eia_data_status})
eid = dict(zip(eia_price_monthly.price_month, eia_price_monthly.eia_price_id))
tr = nf2_utility_day_rate[["utility_type", "reading_month", "unit_rate_usd", "rate_source"]].drop_duplicates()
assert not tr.duplicated(["utility_type", "reading_month"]).any(), "rate not constant within month"
tr = tr.sort_values(["reading_month", "utility_type"]).reset_index(drop=True)
tariff_rate = pd.DataFrame({
    "tariff_rate_id": range(1, len(tr) + 1),
    "utility_type_id": tr.utility_type.map(uid).values,
    "rate_month": tr.reading_month.values,
    "eia_price_id": pd.array([eid[m] if u != "steam" else pd.NA for u, m in zip(tr.utility_type, tr.reading_month)], dtype="Int64"),
    "unit_rate_usd": tr.unit_rate_usd.values,
    "rate_basis": tr.rate_source.values})

tables3 = {"site": site, "space_usage": space_usage, "building": building, "utility_type": utility_type,
           "meter": meter, "daily_reading": daily_reading, "weather_daily": weather_daily,
           "eia_price_monthly": eia_price_monthly, "tariff_rate": tariff_rate}

# ---------------- Lossless-join check ----------------
su = space_usage.set_index("space_usage_id")
r = (daily_reading.merge(meter, on="meter_id").merge(building, on="building_id").merge(site, on="site_id")
     .merge(utility_type, on="utility_type_id"))
r["sub_space_usage"] = r.space_usage_id.map(su.usage_name)
r["primary_space_usage"] = r.space_usage_id.map(su.parent_usage_id).map(su.usage_name)
r["rate_month"] = r.reading_date.str[:7] + "-01"
r = r.merge(tariff_rate, on=["utility_type_id", "rate_month"]).merge(
    weather_daily, left_on=["site_id", "reading_date"], right_on=["site_id", "weather_date"])
chk = flat.assign(sub_space_usage=flat.sub_space_usage.str.title()).merge(
    r[["building_name", "utility_code", "reading_date", "consumption_kwh", "sub_space_usage", "primary_space_usage",
       "gross_sqm", "unit_rate_usd", "avg_air_temp_c"]],
    left_on=["building_name", "utility_type", "reading_date"], right_on=["building_name", "utility_code", "reading_date"],
    suffixes=("", "_3nf"))
assert len(chk) == len(flat) == len(r), (len(chk), len(flat), len(r))
for a, b in [("daily_consumption_kwh", "consumption_kwh"), ("sub_space_usage", "sub_space_usage_3nf"),
             ("primary_space_usage", "primary_space_usage_3nf"), ("gross_sqm", "gross_sqm_3nf"),
             ("unit_rate_usd", "unit_rate_usd_3nf"), ("avg_air_temp_c", "avg_air_temp_c_3nf")]:
    x, y = chk[a], chk[b]
    assert ((x == y) | (x.isna() & y.isna())).all(), f"mismatch {a}"
print(f"LOSSLESS JOIN OK: {len(r)} rows reconstructed from 3NF == {len(flat)} flat rows")

import os
os.makedirs(OUT_DIR, exist_ok=True)
for n, df in tables3.items():
    df.to_csv(f"{OUT_DIR}/{n}.csv", index=False, na_rep="")
    print(f"3NF {n}: {len(df)} rows")
print("3NF total rows:", sum(len(d) for d in tables3.values()))

# ---------------- Workbook ----------------
F = "Arial"
H1 = Font(name=F, bold=True, size=14); H2 = Font(name=F, bold=True, size=11, color="FFFFFF")
B = Font(name=F, bold=True, size=10); N = Font(name=F, size=10); I = Font(name=F, italic=True, size=9, color="555555")
FILL_H2 = PatternFill("solid", fgColor="1F4E78"); FILL_COL = PatternFill("solid", fgColor="D9E1F2")
FILL_KEY = PatternFill("solid", fgColor="FFF2CC")
thin = Side(style="thin", color="BFBFBF"); BOX = Border(left=thin, right=thin, top=thin, bottom=thin)
WRAP = Alignment(wrap_text=True, vertical="top")


def cell(ws, r, c, v, font=N, fill=None, border=False, wrap=False):
    if isinstance(v, float) and np.isnan(v):
        v = "NULL"
    elif v is pd.NA:
        v = "NULL"
    elif isinstance(v, (np.integer,)):
        v = int(v)
    elif isinstance(v, (np.floating,)):
        v = float(v)
    x = ws.cell(row=r, column=c, value=v); x.font = font
    if fill: x.fill = fill
    if border: x.border = BOX
    if wrap: x.alignment = WRAP
    return x


def text_block(ws, r, lines, ncols=10):
    for ln in lines:
        font = B if ln.startswith("§") else N
        cell(ws, r, 1, ln.lstrip("§"), font)
        r += 1
    return r


def table_block(ws, r, title, df, keys, total_rows, note, sample):
    cell(ws, r, 1, f"{title}   ({total_rows:,} rows)", H2, FILL_H2)
    for c in range(2, max(len(df.columns), 2) + 1):
        ws.cell(row=r, column=c).fill = FILL_H2
    r += 1
    cell(ws, r, 1, note, I); r += 1
    for j, col in enumerate(df.columns, 1):
        tag = " (PK)" if col in keys.get("pk", []) else ""
        tag += " (FK)" if col in keys.get("fk", []) else ""
        cell(ws, r, j, col + tag, B, FILL_KEY if tag else FILL_COL, border=True)
    r += 1
    for row in sample.itertuples(index=False):
        for j, v in enumerate(row, 1):
            cell(ws, r, j, v, N, border=True)
        r += 1
    return r + 1


wb = Workbook()
# ---- Tab 1NF ----
ws = wb.active; ws.title = "1NF"
cell(ws, 1, 1, "1NF — Atomic values, no repeating groups, primary key identified", H1)
r = text_block(ws, 3, [
    "§Source: flat_campus_energy_daily.csv (28,336 rows × 29 cols), BDG2 Bull site + EIA-861M, 2017-07-01..2017-09-30, one row per meter per day.",
    "§Violations fixed to reach 1NF",
    "1. meter_code = 'Bull_office_Mai|electricity' is NON-ATOMIC (packs building + utility). Split into building_name + utility_type (both atomic) and dropped meter_code.",
    "2. reading_id was a row-number surrogate with no business meaning; dropped so the natural key is visible. reading_month (YYYY-MM-01) added as an atomic attribute for tariff dependencies.",
    "3. No repeating groups: each row holds exactly one meter's reading for one day. Every column holds a single value of one domain.",
    "§Candidate keys",
    "PK = {building_name, utility_type, reading_date}. Also candidate: {building_kaggle_id, utility_type, reading_date}. Verified unique on all 28,336 rows.",
    "§Functional dependencies observed in the 1NF relation (verified against the data)",
    "FD1  {building_name, utility_type, reading_date} → daily_consumption_kwh, peak_hour_kwh, peak_hour, hours_reported, est_daily_cost_usd",
    "FD2  building_name → building_kaggle_id, site_name, primary_space_usage, sub_space_usage, gross_sqm, gross_sqft      (partial: depends on part of key)",
    "FD3  building_kaggle_id → building_name      (1:1 alternate identifier)",
    "FD4  utility_type → unit      (partial)",
    "FD5  site_name → timezone, lat, lng      (transitive via building_name → site_name)",
    "FD6  sub_space_usage → primary_space_usage      (transitive; each sub-usage belongs to exactly one primary usage)",
    "FD7  gross_sqm → gross_sqft      (derived: sqft = sqm × 10.7639)",
    "FD8  {site_name, reading_date} → avg_air_temp_c, max_air_temp_c, avg_dew_temp_c, total_precip_mm, weather_hours      (partial: reading_date + site via building)",
    "FD9  reading_date → reading_month;  reading_month → tx_comm_price_cents_kwh, eia_data_status      (partial + transitive)",
    "FD10 {utility_type, reading_month} → unit_rate_usd, rate_source      (partial: utility_type + reading_date)",
    "FD11 {daily_consumption_kwh, unit_rate_usd} → est_daily_cost_usd      (derived)",
    "§Anomalies in this relation (real rows; see report Part 2)",
    "INSERTION: Bull_office_Mai's electricity meter has no data for the entire window. Recording that the meter exists forces 92 rows with daily_consumption_kwh = NULL (e.g., 2017-07-01, hours_reported = 0). A new building, space-usage category, or an October-2017 EIA price cannot be recorded without a meter-day reading.",
    "DELETION: Bull_assembly_Maren is the ONLY 'Swimming Pool' building. Purging its 276 readings also deletes its floor area (11,345.5 m²) and the fact that 'Swimming Pool' is a sub-usage of 'Entertainment/public assembly'.",
    "UPDATE: Bull_office_Mai stores sub_space_usage = 'office' (lower case) on 276 rows, while 16 other buildings use 'Office'. Correcting it means updating all 276 rows; a partial update leaves the building with two different usages. The same applies to gross_sqm (276 rows per 3-meter building) and EIA price revisions (9,548 rows for August).",
])
r += 1
sample_names = ["Bull_office_Mai", "Bull_assembly_Maren", "Bull_lodging_Caren"]
s1 = nf1[nf1.building_name.isin(sample_names) & nf1.reading_date.isin(["2017-07-01", "2017-08-01"])]
s1 = s1.sort_values(["building_name", "reading_date", "utility_type"])
r = table_block(ws, r, "Relation R_1NF (28 attributes: 29 flat - meter_code - reading_id + reading_month)", nf1,
                {"pk": ["building_name", "utility_type", "reading_date"]}, len(nf1),
                "Sample: 18 real rows (3 buildings × 3 utilities × 2 dates) showing anomaly evidence. Full data: data/flat_campus_energy_daily.csv", s1)

# ---- Tab 2NF ----
ws2 = wb.create_sheet("2NF")
cell(ws2, 1, 1, "2NF — Remove partial dependencies on the composite key {building_name, utility_type, reading_date}", H1)
r = text_block(ws2, 3, [
    "§Rule: every non-key attribute must depend on the WHOLE key. Attributes that depend on only part of the key move to their own relation.",
    "FD2 building_name → building attributes          ⇒ R_building (PK building_name)",
    "FD4 utility_type → unit                           ⇒ R_utility (PK utility_type)",
    "FD8 reading_date (+site) → weather                ⇒ R_day_weather (PK reading_date; single site in scope)",
    "FD9/FD10 {utility_type, reading_date} → price, rate ⇒ R_utility_day_rate (PK utility_type, reading_date)",
    "FD1 full key → measurements                       ⇒ R_reading (PK building_name, utility_type, reading_date)",
    "§Still violating 3NF (fixed in the next tab): R_building has site_name → timezone/lat/lng, sub_space_usage → primary_space_usage, gross_sqm → gross_sqft; "
    "R_utility_day_rate has reading_date → reading_month → price; R_reading still carries derived est_daily_cost_usd.",
    "§Anomalies resolved here: 'office' now lives on 1 row of R_building (not 276). Maren's area survives deletion of its readings. Mai's building row exists without readings.",
])
r += 1
pick = lambda d, col, vals: d[d[col].isin(vals)]
r = table_block(ws2, r, "R_building", nf2_building, {"pk": ["building_name"]}, len(nf2_building),
                "One row per building. 'office' casing anomaly now stored once.",
                pick(nf2_building, "building_name", sample_names + ["Bull_office_Lilla", "Bull_lodging_Charlotte"]))
r = table_block(ws2, r, "R_utility", nf2_utility, {"pk": ["utility_type"]}, len(nf2_utility), "", nf2_utility)
r = table_block(ws2, r, "R_day_weather", nf2_day_weather, {"pk": ["reading_date"]}, len(nf2_day_weather),
                "Bull site daily weather.", nf2_day_weather.head(5))
r = table_block(ws2, r, "R_utility_day_rate", nf2_utility_day_rate, {"pk": ["utility_type", "reading_date"]},
                len(nf2_utility_day_rate), "Rate repeats every day of the month, so the transitive dependency via reading_month remains.",
                nf2_utility_day_rate[nf2_utility_day_rate.reading_date.isin(["2017-07-01", "2017-07-02", "2017-08-01"])])
r = table_block(ws2, r, "R_reading", nf2_reading, {"pk": ["building_name", "utility_type", "reading_date"]},
                len(nf2_reading), "Measurements only; est_daily_cost_usd is still a derived value.",
                nf2_reading[nf2_reading.building_name.isin(sample_names) & (nf2_reading.reading_date == "2017-07-01")])

# ---- Tab 3NF ----
ws3 = wb.create_sheet("3NF")
cell(ws3, 1, 1, "3NF — Remove transitive dependencies; final relational schema (9 tables)", H1)
total3 = sum(len(d) for d in tables3.values())
r = text_block(ws3, 3, [
    "§Transitive dependencies removed",
    "building_name → site_name → timezone, lat, lng           ⇒ site (PK site_id); building.site_id FK",
    "building_name → sub_space_usage → primary_space_usage    ⇒ space_usage (PK space_usage_id, parent_usage_id self-FK = RECURSIVE HIERARCHY); building.space_usage_id FK",
    "gross_sqm → gross_sqft (derived)                          ⇒ gross_sqft dropped (computed as sqm × 10.7639 when needed)",
    "reading_date → reading_month → price, status             ⇒ eia_price_monthly (PK eia_price_id; UNIQUE state, sector, month)",
    "{utility_type, reading_month} → unit_rate, basis         ⇒ tariff_rate (PK tariff_rate_id; UNIQUE utility_type_id, rate_month; eia_price_id FK NULL for steam)",
    "consumption × rate → est_daily_cost_usd (derived)         ⇒ dropped from storage; computed in SQL",
    "{building, utility} pair                                  ⇒ meter (PK meter_id; UNIQUE building_id, utility_type_id) = JUNCTION resolving M:N building ↔ utility_type",
    "§Data-cleansing decision (D-007): sub-usage casing standardised on load ('office' → 'Office', 'garage' → 'Garage'), so space_usage has one row per real category.",
    f"§Lossless-join verified by normalize.py: re-joining the 9 tables reproduces all {len(flat):,} flat rows with identical consumption, usage, area, rate and weather values.",
    f"§Total rows across 3NF tables: {total3:,} (daily_reading alone = {len(daily_reading):,} ≥ 5,000 requirement).",
])
r += 1
specs = [
    ("site", {"pk": ["site_id"]}, site, "Campus/site. 1 row in scope (Bull = Austin, TX)."),
    ("space_usage", {"pk": ["space_usage_id"], "fk": ["parent_usage_id"]}, space_usage,
     "Self-referencing hierarchy: parent_usage_id NULL = top-level primary usage."),
    ("building", {"pk": ["building_id"], "fk": ["site_id", "space_usage_id"]},
     building[building.building_name.isin(sample_names + ["Bull_office_Lilla"])], "FK space_usage_id points at the sub-usage (leaf) level."),
    ("utility_type", {"pk": ["utility_type_id"]}, utility_type, ""),
    ("meter", {"pk": ["meter_id"], "fk": ["building_id", "utility_type_id"]},
     meter[meter.meter_code.str.split("|").str[0].isin(["Bull_office_Mai", "Bull_assembly_Maren"])],
     "Associative (junction) entity: building M:N utility_type."),
    ("daily_reading", {"pk": ["meter_id", "reading_date"], "fk": ["meter_id"]},
     daily_reading[daily_reading.meter_id.isin(meter[meter.meter_code.str.startswith("Bull_office_Mai")].meter_id) & (daily_reading.reading_date <= "2017-07-02")],
     "Fact table. Note Mai electricity: consumption NULL, hours_reported 0."),
    ("weather_daily", {"pk": ["site_id", "weather_date"], "fk": ["site_id"]}, weather_daily.head(5), ""),
    ("eia_price_monthly", {"pk": ["eia_price_id"]}, eia_price_monthly, "Source: EIA-861M, TX commercial, Final."),
    ("tariff_rate", {"pk": ["tariff_rate_id"], "fk": ["utility_type_id", "eia_price_id"]}, tariff_rate,
     "CHW = EIA price / COP 4.0 (assumed); steam $0.034 (assumed)."),
]
for name, keys, sample, note in specs:
    r = table_block(ws3, r, name, tables3[name], keys, len(tables3[name]), note, sample)

for w in (ws, ws2, ws3):
    for c in range(1, 31):
        w.column_dimensions[get_column_letter(c)].width = 22
    w.column_dimensions["A"].width = 26
    w.freeze_panes = "A3"
wb.save(OUT_XLSX)
print("wrote", OUT_XLSX)
