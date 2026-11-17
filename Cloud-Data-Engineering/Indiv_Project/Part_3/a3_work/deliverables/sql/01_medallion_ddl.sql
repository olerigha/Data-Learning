-- =====================================================================
-- 01  Medallion staging DDL (Bronze / Silver / Gold) - database campus_dw
-- =====================================================================
CREATE DATABASE IF NOT EXISTS campus_dw DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE campus_dw;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS fact_daily_energy, mv_month_usage_utility, dim_date, dim_building, dim_utility, dim_weather,
                     gold_building_month_cost, gold_peak_hour_alignment,
                     silver_campus_reading, silver_ercot_hourly, silver_tx_price_monthly, silver_quarantine,
                     bronze_eia_raw, bronze_campus_reading, dq_check_log;
SET FOREIGN_KEY_CHECKS = 1;

-- ---------------- BRONZE: raw, untransformed, with audit columns ----------------
-- One row per API record, stored as the exact JSON object returned by EIA.
CREATE TABLE bronze_eia_raw (
  raw_id        INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  source_name   VARCHAR(60)  NOT NULL,
  source_file   VARCHAR(120) NOT NULL,
  page_no       SMALLINT UNSIGNED NOT NULL,
  record_json   JSON         NOT NULL,
  ingested_at   DATETIME     NOT NULL,
  KEY ix_bronze_eia_source (source_name)
) ENGINE=InnoDB;

-- Assignment 2 domain records (flat daily meter readings), every column kept as text.
CREATE TABLE bronze_campus_reading (
  raw_id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  reading_id VARCHAR(20), reading_date VARCHAR(20), meter_code VARCHAR(120), utility_type VARCHAR(30), unit VARCHAR(10),
  building_name VARCHAR(100), building_kaggle_id VARCHAR(20), site_name VARCHAR(40), timezone VARCHAR(40),
  lat VARCHAR(20), lng VARCHAR(20), primary_space_usage VARCHAR(60), sub_space_usage VARCHAR(60),
  gross_sqm VARCHAR(20), gross_sqft VARCHAR(20), daily_consumption_kwh VARCHAR(30), peak_hour_kwh VARCHAR(30),
  peak_hour VARCHAR(10), hours_reported VARCHAR(10), avg_air_temp_c VARCHAR(20), max_air_temp_c VARCHAR(20),
  avg_dew_temp_c VARCHAR(20), total_precip_mm VARCHAR(20), weather_hours VARCHAR(10),
  tx_comm_price_cents_kwh VARCHAR(20), eia_data_status VARCHAR(20), unit_rate_usd VARCHAR(20),
  rate_source VARCHAR(80), est_daily_cost_usd VARCHAR(30),
  source_name   VARCHAR(60) NOT NULL,
  ingested_at   DATETIME    NOT NULL
) ENGINE=InnoDB;

-- Row-level data-quality results for every check run (pass/fail counts per check).
CREATE TABLE dq_check_log (
  check_id      INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  run_id        VARCHAR(40)  NOT NULL,
  source_name   VARCHAR(60)  NOT NULL,
  check_name    VARCHAR(80)  NOT NULL,
  check_type    VARCHAR(20)  NOT NULL,      -- null / duplicate / range / format
  rows_checked  INT UNSIGNED NOT NULL,
  rows_passed   INT UNSIGNED NOT NULL,
  rows_failed   INT UNSIGNED NOT NULL,
  checked_at    DATETIME     NOT NULL
) ENGINE=InnoDB;

-- ---------------- SILVER: typed, cleaned, conformed, PII-masked ----------------
CREATE TABLE silver_quarantine (
  q_id           INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  source_name    VARCHAR(60)  NOT NULL,
  raw_id         INT UNSIGNED NOT NULL,
  failed_checks  VARCHAR(200) NOT NULL,
  record_json    JSON         NOT NULL,
  quarantined_at DATETIME     NOT NULL
) ENGINE=InnoDB;

CREATE TABLE silver_ercot_hourly (
  period_utc       DATETIME NOT NULL PRIMARY KEY,
  period_local     DATETIME NOT NULL,          -- US/Central wall-clock time
  local_date       DATE     NOT NULL,
  local_hour       TINYINT UNSIGNED NOT NULL,
  demand_mwh       INT UNSIGNED NOT NULL,
  KEY ix_ercot_local (local_date, local_hour)
) ENGINE=InnoDB;

CREATE TABLE silver_tx_price_monthly (
  price_month      DATE NOT NULL PRIMARY KEY,
  price_cents_kwh  DECIMAL(6,2)  NOT NULL,
  sales_million_kwh DECIMAL(12,3) NOT NULL
) ENGINE=InnoDB;

-- Site coordinates are generalized to 1 decimal place (about 11 km) and the exact value
-- is replaced by a salted SHA-256 token; the raw coordinates never reach Silver.
CREATE TABLE silver_campus_reading (
  reading_date      DATE          NOT NULL,
  meter_code        VARCHAR(120)  NOT NULL,
  building_name     VARCHAR(100)  NOT NULL,
  utility_code      VARCHAR(30)   NOT NULL,
  unit              VARCHAR(10)   NOT NULL,
  primary_usage     VARCHAR(60)   NOT NULL,
  sub_usage         VARCHAR(60)   NOT NULL,
  gross_sqm         DECIMAL(10,1) NOT NULL,
  site_name         VARCHAR(40)   NOT NULL,
  site_lat_1dp      DECIMAL(4,1)  NOT NULL,
  site_lng_1dp      DECIMAL(5,1)  NOT NULL,
  site_geo_token    CHAR(64)      NOT NULL,
  consumption_kwh   DECIMAL(14,4) NOT NULL,
  peak_hour_kwh     DECIMAL(14,4) NOT NULL,
  peak_hour         TINYINT UNSIGNED NOT NULL,
  hours_reported    TINYINT UNSIGNED NOT NULL,
  avg_air_temp_c    DECIMAL(7,4)  NULL,
  max_air_temp_c    DECIMAL(7,4)  NULL,
  PRIMARY KEY (meter_code, reading_date)
) ENGINE=InnoDB;

-- ---------------- GOLD: curated analytics (domain + API enrichment) ----------------
CREATE TABLE gold_building_month_cost (
  building_name        VARCHAR(100)  NOT NULL,
  primary_usage        VARCHAR(60)   NOT NULL,
  utility_code         VARCHAR(30)   NOT NULL,
  usage_month          DATE          NOT NULL,       -- 2017 month of the campus readings
  kwh                  DECIMAL(16,2) NOT NULL,
  price_2017_cents     DECIMAL(6,2)  NOT NULL,       -- EIA TX commercial, same month 2017
  price_current_cents  DECIMAL(6,2)  NOT NULL,       -- EIA TX commercial, latest year with that calendar month
  price_current_month  DATE          NOT NULL,
  cost_2017_usd        DECIMAL(14,2) NOT NULL,
  cost_current_usd     DECIMAL(14,2) NOT NULL,
  cost_change_pct      DECIMAL(7,2)  NOT NULL,
  PRIMARY KEY (building_name, utility_code, usage_month)
) ENGINE=InnoDB;

CREATE TABLE gold_peak_hour_alignment (
  local_hour                 TINYINT UNSIGNED NOT NULL PRIMARY KEY,
  campus_peak_meter_days     INT UNSIGNED NOT NULL,   -- electricity meter-days whose daily peak fell in this hour (Jul-Sep 2017)
  campus_peak_share_pct      DECIMAL(5,2) NOT NULL,
  ercot_avg_demand_mwh       INT UNSIGNED NOT NULL,   -- ERCOT mean hourly demand, Jul-Sep 2025 (live API)
  ercot_demand_rank          TINYINT UNSIGNED NOT NULL,
  is_ercot_top3_hour         TINYINT(1) NOT NULL
) ENGINE=InnoDB;
