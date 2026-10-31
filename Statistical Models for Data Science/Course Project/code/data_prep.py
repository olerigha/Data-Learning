"""
Data wrangling for the UCI Gas Turbine CO and NOx Emission data set.

Concatenates gt_2011.csv ... gt_2015.csv, adds a `year` column and a within-year
row index, checks data quality, removes exact duplicate rows, and writes:
    Dataset/gt_combined.csv               cleaned, concatenated data
    Part_1/variable_summary.csv           variable characteristics table
    Part_1/data_quality.txt               missing / duplicate / boundary checks
"""
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
DATA_DIR = ROOT / "Dataset"
FIG_DIR = ROOT / "figures"
PART1_DIR = ROOT / "Part_1"
PART2_DIR = ROOT / "Part_2"
YEARS = range(2011, 2016)

# Column metadata (descriptions and units from the UCI documentation)
VARIABLES = {
    "AT":   ("Ambient temperature", "°C", "Ambient"),
    "AP":   ("Ambient pressure", "mbar", "Ambient"),
    "AH":   ("Ambient relative humidity", "%", "Ambient"),
    "AFDP": ("Air filter differential pressure", "mbar", "Process"),
    "GTEP": ("Gas turbine exhaust pressure", "mbar", "Process"),
    "TIT":  ("Turbine inlet temperature", "°C", "Process"),
    "TAT":  ("Turbine after temperature", "°C", "Process"),
    "CDP":  ("Compressor discharge pressure", "mbar", "Process"),
    "TEY":  ("Turbine energy yield", "MWh", "Output"),
    "CO":   ("Carbon monoxide", "mg/m³", "Emission"),
    "NOX":  ("Nitrogen oxides (NOx)", "mg/m³", "Emission"),
}


def load_raw() -> pd.DataFrame:
    """Read and concatenate the five yearly files, keeping file order."""
    frames = []
    for year in YEARS:
        d = pd.read_csv(DATA_DIR / f"gt_{year}.csv")
        d["year"] = year
        d["row_in_year"] = np.arange(len(d))
        frames.append(d)
    return pd.concat(frames, ignore_index=True)


STUCK_RUN_HOURS = 12  # identical consecutive NOx readings treated as a flat-lined analyzer


def stuck_nox_mask(df: pd.DataFrame) -> pd.Series:
    run_id = (df.NOX != df.NOX.shift()).cumsum()
    run_len = df.groupby(run_id).NOX.transform("size")
    return run_len >= STUCK_RUN_HOURS


def clean(raw: pd.DataFrame) -> pd.DataFrame:
    """Remove exact duplicate sensor records and flat-lined NOx analyzer runs."""
    dup = raw.duplicated(subset=list(VARIABLES), keep="first")
    df = raw.loc[~dup].reset_index(drop=True)
    return df.loc[~stuck_nox_mask(df)].reset_index(drop=True)


def load_clean() -> pd.DataFrame:
    path = DATA_DIR / "gt_combined.csv"
    if not path.exists():
        main()
    return pd.read_csv(path)


def variable_summary(df: pd.DataFrame) -> pd.DataFrame:
    rows = []
    for col, (desc, unit, group) in VARIABLES.items():
        s = df[col]
        rows.append({
            "Column": col,
            "Description": desc,
            "Unit": unit,
            "Group": group,
            "Data Type": "decimal",
            "Example": s.iloc[0],
            "Missing": int(s.isna().sum()),
            "Unique": int(s.nunique()),
            "Min": s.min(), "P1": s.quantile(0.01), "Median": s.median(),
            "Mean": s.mean(), "P99": s.quantile(0.99), "Max": s.max(),
            "Std": s.std(), "Skew": s.skew(),
        })
    return pd.DataFrame(rows)


def quality_report(raw: pd.DataFrame, df: pd.DataFrame) -> str:
    lines = [
        f"Rows per year (raw): {raw.groupby('year').size().to_dict()}",
        f"Raw shape: {raw.shape}",
        f"Missing values (total): {int(raw[list(VARIABLES)].isna().sum().sum())}",
        f"Exact duplicate rows removed: {int(raw.duplicated(subset=list(VARIABLES)).sum())}",
        f"Flat-lined NOx rows removed (>= {STUCK_RUN_HOURS} identical consecutive hours): "
        f"{int(stuck_nox_mask(raw.drop_duplicates(subset=list(VARIABLES)).reset_index(drop=True)).sum())}",
        "  " + raw[stuck_nox_mask(raw)].groupby(["year", "NOX"]).row_in_year.agg(["min", "max", "size"])
        .to_string().replace("\n", "\n  "),
        f"Clean shape: {df.shape}",
        f"Clean rows per year: {df.groupby('year').size().to_dict()}",
        "",
        "Boundary / saturation checks (clean data):",
        f"  TAT >= 549 °C: {(df.TAT >= 549).mean():.1%} of rows",
        f"  TIT >= 1099 °C: {(df.TIT >= 1099).mean():.1%} of rows",
        f"  AH >= 100 %: {(df.AH >= 100).sum()} rows",
        f"  CO == 0: {(df.CO == 0).sum()} rows; CO > 10: {(df.CO > 10).sum()}; CO > 20: {(df.CO > 20).sum()}",
        f"  NOX > 100: {(df.NOX > 100).sum()} rows; NOX < 40: {(df.NOX < 40).sum()}",
        f"  TEY < 110 MWh (low load): {(df.TEY < 110).sum()} rows",
        "",
        "Annual means:",
        df.groupby("year")[list(VARIABLES)].mean().round(2).T.to_string(),
        "",
        "NOx mean by within-year 1,000-row block:",
    ]
    for y, d in df.groupby("year"):
        blocks = [round(d.NOX.iloc[i:i + 1000].mean(), 1) for i in range(0, len(d), 1000)]
        lines.append(f"  {y}: {blocks}")
    dup_rows = raw[raw.duplicated(subset=list(VARIABLES), keep=False)]
    lines += ["", "Duplicate record locations (year, row_in_year):",
              dup_rows[["year", "row_in_year"]].to_string(index=False)]
    return "\n".join(lines)


def main():
    for d in (FIG_DIR, PART1_DIR, PART2_DIR):
        d.mkdir(exist_ok=True)
    raw = load_raw()
    df = clean(raw)
    df.to_csv(DATA_DIR / "gt_combined.csv", index=False)
    summary = variable_summary(df)
    summary.round(3).to_csv(PART1_DIR / "variable_summary.csv", index=False)
    report = quality_report(raw, df)
    (PART1_DIR / "data_quality.txt").write_text(report, encoding="utf-8")
    pd.set_option("display.width", 220)
    print(report)
    print(summary.round(3).to_string(index=False))


if __name__ == "__main__":
    main()
