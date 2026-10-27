"""Build bronze, silver, and gold CSV layers from an event-style CSV file."""

from __future__ import annotations

import csv
import logging
import os
import sys
import time
from collections import defaultdict
from collections.abc import Iterable, Mapping
from pathlib import Path
from typing import Any

log_handlers: list[logging.Handler] = [logging.StreamHandler(sys.stdout)]
log_file_env = os.getenv("LOG_FILE")
if log_file_env:
    log_handlers.append(logging.FileHandler(log_file_env, mode="a", encoding="utf-8"))

logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
    handlers=log_handlers,
    force=True,
)
logger = logging.getLogger("layered_pipeline")

REQUIRED_COLUMNS = ("time", "latitude", "longitude", "mag", "type")


def require_columns(rows: Iterable[Mapping[str, Any]], columns: Iterable[str]) -> None:
    required = set(columns)
    for index, row in enumerate(rows):
        missing = required.difference(row)
        if missing:
            names = ", ".join(sorted(missing))
            raise ValueError(f"row {index} is missing required columns: {names}")


def reject_nulls(rows: Iterable[Mapping[str, Any]], columns: Iterable[str]) -> None:
    required = tuple(columns)
    for index, row in enumerate(rows):
        missing = [column for column in required if row.get(column) in (None, "")]
        if missing:
            names = ", ".join(missing)
            raise ValueError(f"row {index} has null values in: {names}")


def check_numeric_range(
    rows: Iterable[Mapping[str, Any]],
    column: str,
    minimum: float,
    maximum: float,
) -> None:
    for index, row in enumerate(rows):
        value = row.get(column)
        if not isinstance(value, (int, float)) or not minimum <= value <= maximum:
            raise ValueError(
                f"row {index} has invalid {column}: {value!r}; "
                f"expected {minimum} <= value <= {maximum}"
            )


def read_rows(input_path: Path) -> list[dict[str, str]]:
    with input_path.open(newline="", encoding="utf-8") as source:
        return list(csv.DictReader(source))


def build_layers(rows: list[dict[str, str]]) -> tuple[list[dict], list[dict], list[dict]]:
    require_columns(rows, REQUIRED_COLUMNS)
    reject_nulls(rows, ("time", "latitude", "longitude", "type"))

    bronze = rows
    silver = []
    for row in bronze:
        cleaned = {key: value.strip() for key, value in row.items()}
        cleaned["latitude"] = float(cleaned["latitude"])
        cleaned["longitude"] = float(cleaned["longitude"])
        cleaned["mag"] = float(cleaned["mag"] or 0.0)
        silver.append(cleaned)

    check_numeric_range(silver, "latitude", -90.0, 90.0)
    check_numeric_range(silver, "longitude", -180.0, 180.0)

    grouped: dict[tuple[str, str], list[float]] = defaultdict(list)
    for row in silver:
        grouped[(row["time"][:10], row["type"])].append(row["mag"])

    gold = [
        {
            "event_date": event_date,
            "event_type": event_type,
            "event_count": len(magnitudes),
            "maximum_magnitude": max(magnitudes),
        }
        for (event_date, event_type), magnitudes in sorted(grouped.items())
    ]
    return bronze, silver, gold


def write_layer(rows: list[dict], output_path: Path) -> None:
    if not rows:
        return
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w", newline="", encoding="utf-8") as destination:
        writer = csv.DictWriter(destination, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def run_pipeline(input_path: Path, output_dir: Path) -> None:
    start_time = time.time()
    rows = read_rows(input_path)
    bronze, silver, gold = build_layers(rows)

    write_layer(bronze, output_dir / "bronze" / "events.csv")
    write_layer(silver, output_dir / "silver" / "events.csv")
    write_layer(gold, output_dir / "gold" / "events_summary.csv")

    duration = time.time() - start_time
    logger.info(
        "pipeline complete input_rows=%d bronze=%d silver=%d gold=%d duration=%.3fs",
        len(rows),
        len(bronze),
        len(silver),
        len(gold),
        duration,
    )


if __name__ == "__main__":
    if len(sys.argv) < 3:
        raise SystemExit("usage: layered_pipeline.py <input.csv> <output-dir>")
    run_pipeline(Path(sys.argv[1]), Path(sys.argv[2]))
