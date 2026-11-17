"""Draw the star-schema ER diagram and the Medallion pipeline flow (PNG) with matplotlib."""
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

OUT = Path(sys.argv[1] if len(sys.argv) > 1 else ".")


def table_box(ax, x, y, w, title, rows, head="#1F4E78", fill="#F3F7FB"):
    line_h = 0.42
    h = line_h * (len(rows) + 1) + 0.15
    ax.add_patch(FancyBboxPatch((x, y - h), w, h, boxstyle="round,pad=0.02", fc=fill, ec=head, lw=1.6))
    ax.add_patch(FancyBboxPatch((x, y - line_h - 0.05), w, line_h + 0.05, boxstyle="round,pad=0.02", fc=head, ec=head))
    ax.text(x + w / 2, y - line_h / 2 - 0.03, title, ha="center", va="center", color="white", fontsize=11, weight="bold")
    for i, (key, col, typ) in enumerate(rows):
        yy = y - line_h * (i + 1.5) - 0.05
        ax.text(x + 0.12, yy, key, fontsize=7.5, color="#B22222" if key else "black", weight="bold", va="center")
        ax.text(x + 0.75, yy, col, fontsize=8.2, va="center")
        ax.text(x + w - 0.1, yy, typ, fontsize=7.2, va="center", ha="right", color="#555555")
    return (x, y - h, w, h)


def link(ax, a, b, label):
    ax.add_patch(FancyArrowPatch(a, b, arrowstyle="-", lw=1.4, color="#444444"))
    mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    ax.text(mx, my, label, fontsize=8, ha="center", va="center",
            bbox=dict(boxstyle="round,pad=0.2", fc="white", ec="#999999"))


def star():
    fig, ax = plt.subplots(figsize=(17, 11))
    ax.set_xlim(0, 34); ax.set_ylim(0, 22); ax.axis("off")
    fact = table_box(ax, 12.2, 15.6, 9.6, "fact_daily_energy", [
        ("PK", "fact_id", "INT"), ("FK", "date_key", "INT"), ("FK", "building_key", "INT"),
        ("FK", "utility_key", "TINYINT"), ("FK", "weather_key", "INT"),
        ("DD", "meter_code  (UK meter_code+date_key)", "VARCHAR(120)"),
        ("", "consumption_kwh", "DECIMAL(14,4)"), ("", "peak_hour_kwh", "DECIMAL(14,4)"),
        ("", "peak_hour", "TINYINT"), ("", "hours_reported", "TINYINT"),
        ("", "cost_2017_usd", "DECIMAL(12,2)"), ("", "cost_current_usd  (live EIA price)", "DECIMAL(12,2)"),
        ("", "on_grid_peak_hour  (ERCOT top-3 hour)", "TINYINT(1)")], head="#7B2C2C", fill="#FBF3F3")
    d_date = table_box(ax, 0.6, 21.2, 8.2, "dim_date", [
        ("PK", "date_key (yyyymmdd)", "INT"), ("UK", "full_date", "DATE"), ("", "day_name", "VARCHAR(9)"),
        ("", "is_weekend", "TINYINT(1)"), ("", "week_of_year", "TINYINT"), ("", "month_num / month_name", "TINYINT / VARCHAR"),
        ("", "quarter_num", "TINYINT"), ("", "year_num", "SMALLINT")])
    d_bld = table_box(ax, 25.0, 21.2, 8.4, "dim_building  (SCD Type 2)", [
        ("PK", "building_key (surrogate)", "INT"), ("BK", "building_bk (business key)", "VARCHAR(100)"),
        ("", "primary_usage / sub_usage", "VARCHAR(60)"), ("", "gross_sqm  (tracked)", "DECIMAL(10,1)"),
        ("", "site_name", "VARCHAR(40)"), ("", "site_lat_1dp / site_lng_1dp (masked)", "DECIMAL"),
        ("", "valid_from", "DATE"), ("", "valid_to", "DATE"), ("", "is_current", "TINYINT(1)"),
        ("", "change_reason", "VARCHAR(120)")])
    d_util = table_box(ax, 0.6, 8.0, 8.2, "dim_utility", [
        ("PK", "utility_key", "TINYINT"), ("UK", "utility_code", "VARCHAR(30)"), ("", "unit", "VARCHAR(10)"),
        ("", "rate_basis", "VARCHAR(80)")])
    d_wx = table_box(ax, 25.0, 8.0, 8.4, "dim_weather", [
        ("PK", "weather_key (yyyymmdd)", "INT"), ("UK", "weather_date", "DATE"), ("", "avg_air_temp_c", "DECIMAL(5,2)"),
        ("", "max_air_temp_c", "DECIMAL(5,2)"), ("", "temp_band", "VARCHAR(12)")])
    fx, fy, fw, fh = fact
    link(ax, (d_date[0] + d_date[2], d_date[1] + d_date[3] / 2), (fx, fy + fh - 1.2), "1 : N  date_key")
    link(ax, (d_bld[0], d_bld[1] + d_bld[3] / 2), (fx + fw, fy + fh - 1.6), "1 : N  building_key")
    link(ax, (d_util[0] + d_util[2], d_util[1] + d_util[3] / 2), (fx, fy + 1.6), "1 : N  utility_key")
    link(ax, (d_wx[0], d_wx[1] + d_wx[3] / 2), (fx + fw, fy + 1.6), "1 : N  weather_key")
    ax.text(17, 21.6, "campus_dw star schema - grain: one row per meter per calendar day (Jul-Sep 2017)",
            ha="center", fontsize=14, weight="bold")
    ax.text(17, 0.4, "PK primary key · FK foreign key · UK unique · BK business key · DD degenerate dimension",
            ha="center", fontsize=9, color="#555555")
    fig.savefig(OUT / "star_schema.png", dpi=160, bbox_inches="tight"); plt.close(fig)


def flow():
    fig, ax = plt.subplots(figsize=(17, 6.5))
    ax.set_xlim(0, 34); ax.set_ylim(0, 13); ax.axis("off")
    boxes = {
        "api": (0.3, 8.3, 5.6, 3.6, "#555555", "EIA Open Data API v2\nERCOT hourly demand (2,208)\nTX commercial price (116)\ningest_eia.py: offset paging,\nRetry-After/backoff, timeouts"),
        "a2": (0.3, 1.4, 5.6, 3.0, "#555555", "Assignment 2 domain data\ndaily meter readings\n(28,336 rows)"),
        "bronze": (7.4, 4.3, 6.0, 5.2, "#8C6A2B", "BRONZE (raw)\nbronze_eia_raw (JSON, 2,324)\nbronze_campus_reading (28,336)\n+ ingested_at, source_name\n12 DQ checks -> dq_check_log"),
        "quar": (7.4, 0.4, 6.0, 2.6, "#B22222", "silver_quarantine\n237 rows (null kWh,\n0 hours reported)"),
        "silver": (14.9, 4.3, 6.2, 5.2, "#5A6E7F", "SILVER (cleaned, masked)\nsilver_ercot_hourly (2,208)\nsilver_tx_price_monthly (116)\nsilver_campus_reading (28,099)\nUTC->US/Central, casing,\nGPS 1-dp + SHA-256 token"),
        "gold": (22.6, 7.6, 5.4, 4.0, "#B8860B", "GOLD (curated)\ngold_building_month_cost (918)\ngold_peak_hour_alignment (24)"),
        "star": (22.6, 1.6, 5.4, 4.6, "#1F4E78", "STAR (RDS MySQL 8.4)\nfact_daily_energy (28,099)\n+ 4 dims, SCD2 building\n+ summary table (48)"),
        "ddb": (29.4, 1.6, 4.4, 4.6, "#2E7D32", "DynamoDB\nCampusEnergy\n28,406 items\nPK/SK + GSI1 + GSI2"),
    }
    for k, (x, y, w, h, c, txt) in boxes.items():
        ax.add_patch(FancyBboxPatch((x, y), w, h, boxstyle="round,pad=0.1", fc="white", ec=c, lw=2))
        ax.text(x + w / 2, y + h / 2, txt, ha="center", va="center", fontsize=9)
    def arrow(a, b):
        ax.add_patch(FancyArrowPatch(a, b, arrowstyle="-|>", mutation_scale=16, lw=1.6, color="#333333"))
    arrow((5.9, 10.1), (7.4, 8.4)); arrow((5.9, 2.9), (7.4, 5.0)); arrow((10.4, 4.3), (10.4, 3.0))
    arrow((13.4, 6.9), (14.9, 6.9)); arrow((21.1, 8.0), (22.6, 9.4)); arrow((21.1, 5.6), (22.6, 4.2))
    arrow((25.3, 7.6), (25.3, 6.2)); arrow((28.0, 3.9), (29.4, 3.9))
    ax.text(17, 12.6, "Medallion pipeline: live EIA API + Assignment 2 domain data -> warehouse + DynamoDB",
            ha="center", fontsize=13, weight="bold")
    fig.savefig(OUT / "medallion_flow.png", dpi=160, bbox_inches="tight"); plt.close(fig)


if __name__ == "__main__":
    star(); flow(); print("diagrams written")
