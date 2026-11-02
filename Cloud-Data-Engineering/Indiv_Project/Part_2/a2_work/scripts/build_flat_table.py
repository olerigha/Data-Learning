"""
build_flat_table.py — Assignment 2, Part 1 (Campus Energy Monitoring Platform)

Builds ONE flat, denormalised table from REAL public data only, without synthetic rows or people:
  * BDG2 (Building Data Genome Project 2), Bull site: building metadata,
    hourly cleaned meter readings (electricity, chilled water, steam), hourly weather.
  * EIA-861M "sales_revenue.xlsx": Texas commercial average retail electricity price, monthly.

Grain: one row = one meter x one calendar day, 2017-07-01 .. 2017-09-30 (92 days).
Expected rows: 308 meters x 92 days = 28,336.

Inputs are opened read-only. Run:
  python -I build_flat_table.py <BDG2_DIR> <EIA_861M_XLSX> <OUT_CSV>
"""
import sys
import pandas as pd

BDG2, EIA_XLSX, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
SITE = "Bull"
START, END = "2017-07-01", "2017-09-30"
UTILITIES = ["electricity", "chilledwater", "steam"]

# Assumed thermal rates in USD per kWh-equivalent (see ASSUMPTIONS.md A-004/A-005).
CHW_COP = 4.0                   # chilled water cost = TX commercial electricity price / chiller COP
STEAM_USD_PER_KWH = 0.034       # natural-gas boiler steam, about $10/MMBtu delivered = 0.034 $/kWh

# ---------- 1. Building metadata (real) ----------
meta = pd.read_csv(f"{BDG2}/data/metadata/metadata.csv")
meta = meta[meta.site_id == SITE][[
    "building_id", "site_id", "building_id_kaggle", "primaryspaceusage",
    "sub_primaryspaceusage", "sqm", "sqft", "lat", "lng", "timezone"]]

# ---------- 2. Meter readings: wide hourly -> long daily (real) ----------
frames = []
for util in UTILITIES:
    w = pd.read_csv(f"{BDG2}/data/meters/cleaned/{util}_cleaned.csv",
                    usecols=lambda c: c == "timestamp" or c.startswith(f"{SITE}_"),
                    parse_dates=["timestamp"])
    w = w[(w.timestamp >= START) & (w.timestamp < pd.Timestamp(END) + pd.Timedelta(days=1))]
    long = w.melt(id_vars="timestamp", var_name="building_id", value_name="kwh")
    long["reading_date"] = long.timestamp.dt.date
    long["hour"] = long.timestamp.dt.hour
    g = long.groupby(["building_id", "reading_date"])
    daily = g.agg(daily_consumption_kwh=("kwh", lambda s: s.sum(min_count=1)),
                  peak_hour_kwh=("kwh", "max"),
                  hours_reported=("kwh", "count")).reset_index()
    # Hour of the daily peak. Null when no readings exist for that day.
    idx = long.dropna(subset=["kwh"]).groupby(["building_id", "reading_date"])["kwh"].idxmax()
    peak = long.loc[idx, ["building_id", "reading_date", "hour"]].rename(columns={"hour": "peak_hour"})
    daily = daily.merge(peak, on=["building_id", "reading_date"], how="left")
    daily["utility_type"] = util
    frames.append(daily)
rd = pd.concat(frames, ignore_index=True)

# ---------- 3. Weather hourly -> daily (real) ----------
wx = pd.read_csv(f"{BDG2}/data/weather/weather.csv", parse_dates=["timestamp"])
wx = wx[(wx.site_id == SITE) & (wx.timestamp >= START) &
        (wx.timestamp < pd.Timestamp(END) + pd.Timedelta(days=1))]
wx["reading_date"] = wx.timestamp.dt.date
wxd = wx.groupby("reading_date").agg(
    avg_air_temp_c=("airTemperature", "mean"),
    max_air_temp_c=("airTemperature", "max"),
    avg_dew_temp_c=("dewTemperature", "mean"),
    total_precip_mm=("precipDepth1HR", lambda s: s.clip(lower=0).sum(min_count=1)),
    weather_hours=("airTemperature", "count")).reset_index()

# ---------- 4. EIA-861M Texas commercial price, monthly (real) ----------
eia = pd.read_excel(EIA_XLSX, sheet_name="Monthly-States", header=None, skiprows=3)
eia = eia.iloc[:, [0, 1, 2, 3, 11]]
eia.columns = ["year", "month", "state", "data_status", "price_cents_kwh"]
tx = eia[(eia.state == "TX") & (eia.year == 2017) & (eia.month.isin([7, 8, 9]))].copy()
tx["month"] = tx.month.astype(int)

# ---------- 5. Assemble flat table ----------
flat = rd.merge(meta, on="building_id", how="left").merge(wxd, on="reading_date", how="left")
flat["month"] = pd.to_datetime(flat.reading_date).dt.month
flat = flat.merge(tx[["month", "price_cents_kwh", "data_status"]], on="month", how="left")
flat["elec_price_usd_kwh"] = flat.price_cents_kwh / 100.0
flat["unit_rate_usd"] = flat.elec_price_usd_kwh
flat.loc[flat.utility_type == "chilledwater", "unit_rate_usd"] = flat.elec_price_usd_kwh / CHW_COP
flat.loc[flat.utility_type == "steam", "unit_rate_usd"] = STEAM_USD_PER_KWH
flat["rate_source"] = flat.utility_type.map({
    "electricity": "EIA-861M TX commercial avg price",
    "chilledwater": "ASSUMED: EIA TX price / COP 4.0",
    "steam": "ASSUMED: gas boiler $0.034/kWh"})
flat["est_daily_cost_usd"] = (flat.daily_consumption_kwh * flat.unit_rate_usd).round(2)
flat["meter_code"] = flat.building_id + "|" + flat.utility_type
flat["unit"] = "kWh"

flat = flat.sort_values(["reading_date", "building_id", "utility_type"]).reset_index(drop=True)
flat.insert(0, "reading_id", range(1, len(flat) + 1))
cols = ["reading_id", "reading_date", "meter_code", "utility_type", "unit",
        "building_id", "building_id_kaggle", "site_id", "timezone", "lat", "lng",
        "primaryspaceusage", "sub_primaryspaceusage", "sqm", "sqft",
        "daily_consumption_kwh", "peak_hour_kwh", "peak_hour", "hours_reported",
        "avg_air_temp_c", "max_air_temp_c", "avg_dew_temp_c", "total_precip_mm", "weather_hours",
        "price_cents_kwh", "data_status", "unit_rate_usd", "rate_source", "est_daily_cost_usd"]
flat = flat[cols].rename(columns={
    "building_id": "building_name", "building_id_kaggle": "building_kaggle_id",
    "site_id": "site_name", "primaryspaceusage": "primary_space_usage",
    "sub_primaryspaceusage": "sub_space_usage", "sqm": "gross_sqm", "sqft": "gross_sqft",
    "price_cents_kwh": "tx_comm_price_cents_kwh", "data_status": "eia_data_status"})
for c in ["lat", "lng", "daily_consumption_kwh", "peak_hour_kwh", "avg_air_temp_c", "max_air_temp_c",
          "avg_dew_temp_c", "total_precip_mm"]:
    flat[c] = flat[c].round(4)
flat["unit_rate_usd"] = flat["unit_rate_usd"].round(6)   # 6 dp so stored rate x kWh reproduces cost exactly
flat.to_csv(OUT, index=False)
print(f"wrote {OUT}: rows={len(flat)} cols={flat.shape[1]}")
