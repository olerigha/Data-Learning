-- =====================================================================
-- Assignment 3 - Campus Energy Monitoring Platform - warehouse SQL (RDS MySQL 8.4, database campus_dw)
-- Order of execution: 01 Medallion DDL -> (pipeline.py loads Bronze/Silver) -> 02 Gold -> 03 star schema + SCD2
--   -> 04 Part 2 analytical queries + optimization -> 05 Part 4a showcase queries -> 06 evidence queries
-- No credentials or endpoints appear in this file.
-- =====================================================================

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


-- =====================================================================
-- 02  Gold build: aggregate Silver campus readings and enrich them with live EIA data
-- =====================================================================
USE campus_dw;

-- Gold 1: monthly cost per building and utility, priced at the 2017 Texas commercial rate
-- and re-priced at the most recent rate EIA reports for the same calendar month.
-- Chilled water is costed as electricity / chiller COP 4.0; steam at a flat $0.034/kWh (A2 assumptions).
TRUNCATE TABLE gold_building_month_cost;
INSERT INTO gold_building_month_cost
WITH monthly AS (
  SELECT building_name, primary_usage, utility_code,
         DATE_FORMAT(reading_date, '%Y-%m-01') AS usage_month,
         SUM(consumption_kwh) AS kwh
  FROM silver_campus_reading
  GROUP BY building_name, primary_usage, utility_code, DATE_FORMAT(reading_date, '%Y-%m-01')
), latest AS (
  SELECT MONTH(price_month) AS cal_month, MAX(price_month) AS latest_month
  FROM silver_tx_price_monthly GROUP BY MONTH(price_month)
), priced AS (
  SELECT m.*, p17.price_cents_kwh AS p2017, pc.price_cents_kwh AS pcur, l.latest_month
  FROM monthly m
  JOIN silver_tx_price_monthly p17 ON p17.price_month = m.usage_month
  JOIN latest l                    ON l.cal_month = MONTH(m.usage_month)
  JOIN silver_tx_price_monthly pc  ON pc.price_month = l.latest_month
)
SELECT building_name, primary_usage, utility_code, usage_month, ROUND(kwh, 2),
       p2017, pcur, latest_month,
       ROUND(kwh * CASE utility_code WHEN 'electricity' THEN p2017 / 100 WHEN 'chilledwater' THEN p2017 / 400 ELSE 0.034 END, 2),
       ROUND(kwh * CASE utility_code WHEN 'electricity' THEN pcur  / 100 WHEN 'chilledwater' THEN pcur  / 400 ELSE 0.034 END, 2),
       ROUND(100 * (CASE utility_code WHEN 'steam' THEN 0 ELSE (pcur - p2017) / p2017 END), 2)
FROM priced;

-- Gold 2: campus peak hours compared with Texas grid (ERCOT) peak hours.
-- Joined on local hour of day: campus electricity peaks (Jul-Sep 2017) vs ERCOT demand (Jul-Sep 2025).
TRUNCATE TABLE gold_peak_hour_alignment;
INSERT INTO gold_peak_hour_alignment
WITH campus AS (
  SELECT peak_hour AS local_hour, COUNT(*) AS n
  FROM silver_campus_reading WHERE utility_code = 'electricity'
  GROUP BY peak_hour
), grid AS (
  SELECT local_hour, AVG(demand_mwh) AS avg_mwh,
         RANK() OVER (ORDER BY AVG(demand_mwh) DESC) AS rnk
  FROM silver_ercot_hourly GROUP BY local_hour
)
SELECT g.local_hour,
       COALESCE(c.n, 0),
       ROUND(100 * COALESCE(c.n, 0) / (SELECT SUM(n) FROM campus), 2),
       ROUND(g.avg_mwh),
       g.rnk,
       g.rnk <= 3
FROM grid g LEFT JOIN campus c ON c.local_hour = g.local_hour;


-- =====================================================================
-- 03  Star schema DDL + ELT from Silver/Gold, including the SCD Type 2 change
-- Grain of fact_daily_energy: one row per meter per calendar day (2017-07-01 .. 2017-09-30)
-- =====================================================================
USE campus_dw;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS fact_daily_energy, mv_month_usage_utility, dim_date, dim_building, dim_utility, dim_weather;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE dim_date (
  date_key     INT UNSIGNED NOT NULL PRIMARY KEY,     -- yyyymmdd
  full_date    DATE         NOT NULL UNIQUE,
  day_name     VARCHAR(9)   NOT NULL,
  is_weekend   TINYINT(1)   NOT NULL,
  week_of_year TINYINT UNSIGNED NOT NULL,
  month_num    TINYINT UNSIGNED NOT NULL,
  month_name   VARCHAR(9)   NOT NULL,
  quarter_num  TINYINT UNSIGNED NOT NULL,
  year_num     SMALLINT UNSIGNED NOT NULL
) ENGINE=InnoDB;

-- SCD Type 2: building_key is the surrogate, building_bk the business key.
CREATE TABLE dim_building (
  building_key   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  building_bk    VARCHAR(100) NOT NULL,
  primary_usage  VARCHAR(60)  NOT NULL,
  sub_usage      VARCHAR(60)  NOT NULL,
  gross_sqm      DECIMAL(10,1) NOT NULL,
  site_name      VARCHAR(40)  NOT NULL,
  site_lat_1dp   DECIMAL(4,1) NOT NULL,
  site_lng_1dp   DECIMAL(5,1) NOT NULL,
  valid_from     DATE         NOT NULL,
  valid_to       DATE         NOT NULL,
  is_current     TINYINT(1)   NOT NULL,
  change_reason  VARCHAR(120) NULL,
  UNIQUE KEY uq_building_version (building_bk, valid_from),
  KEY ix_building_current (building_bk, is_current)
) ENGINE=InnoDB;

CREATE TABLE dim_utility (
  utility_key   TINYINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  utility_code  VARCHAR(30) NOT NULL UNIQUE,
  unit          VARCHAR(10) NOT NULL,
  rate_basis    VARCHAR(80) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE dim_weather (
  weather_key     INT UNSIGNED NOT NULL PRIMARY KEY,   -- yyyymmdd of the observation day (site Bull)
  weather_date    DATE         NOT NULL UNIQUE,
  avg_air_temp_c  DECIMAL(5,2) NULL,
  max_air_temp_c  DECIMAL(5,2) NULL,
  temp_band       VARCHAR(12)  NOT NULL               -- '>= 38 C' / '35-37.9 C' / '< 35 C'
) ENGINE=InnoDB;

CREATE TABLE fact_daily_energy (
  fact_id            INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  date_key           INT UNSIGNED NOT NULL,
  building_key       INT UNSIGNED NOT NULL,
  utility_key        TINYINT UNSIGNED NOT NULL,
  weather_key        INT UNSIGNED NOT NULL,
  meter_code         VARCHAR(120) NOT NULL,           -- degenerate dimension
  consumption_kwh    DECIMAL(14,4) NOT NULL,
  peak_hour_kwh      DECIMAL(14,4) NOT NULL,
  peak_hour          TINYINT UNSIGNED NOT NULL,
  hours_reported     TINYINT UNSIGNED NOT NULL,
  cost_2017_usd      DECIMAL(12,2) NOT NULL,
  cost_current_usd   DECIMAL(12,2) NOT NULL,
  on_grid_peak_hour  TINYINT(1)    NOT NULL,          -- daily peak fell in one of ERCOT's top-3 demand hours
  UNIQUE KEY uq_fact_grain (meter_code, date_key),
  CONSTRAINT fk_fact_date     FOREIGN KEY (date_key)     REFERENCES dim_date (date_key),
  CONSTRAINT fk_fact_building FOREIGN KEY (building_key) REFERENCES dim_building (building_key),
  CONSTRAINT fk_fact_utility  FOREIGN KEY (utility_key)  REFERENCES dim_utility (utility_key),
  CONSTRAINT fk_fact_weather  FOREIGN KEY (weather_key)  REFERENCES dim_weather (weather_key)
) ENGINE=InnoDB;

-- ---------------- Dimension loads ----------------
INSERT INTO dim_date
SELECT DISTINCT CAST(DATE_FORMAT(reading_date, '%Y%m%d') AS UNSIGNED), reading_date, DAYNAME(reading_date),
       DAYOFWEEK(reading_date) IN (1, 7), WEEK(reading_date, 3), MONTH(reading_date), MONTHNAME(reading_date),
       QUARTER(reading_date), YEAR(reading_date)
FROM silver_campus_reading;

INSERT INTO dim_utility (utility_code, unit, rate_basis) VALUES
  ('chilledwater', 'kWh', 'EIA TX commercial price / chiller COP 4.0'),
  ('electricity',  'kWh', 'EIA TX commercial price'),
  ('steam',        'kWh', 'Flat $0.034/kWh (gas boiler estimate)');

INSERT INTO dim_weather
SELECT CAST(DATE_FORMAT(reading_date, '%Y%m%d') AS UNSIGNED), reading_date,
       ROUND(MAX(avg_air_temp_c), 2), ROUND(MAX(max_air_temp_c), 2),
       CASE WHEN MAX(max_air_temp_c) >= 38 THEN '>= 38 C' WHEN MAX(max_air_temp_c) >= 35 THEN '35-37.9 C' ELSE '< 35 C' END
FROM silver_campus_reading GROUP BY reading_date;

-- Initial building versions: valid from the start of the data window, open-ended.
INSERT INTO dim_building (building_bk, primary_usage, sub_usage, gross_sqm, site_name, site_lat_1dp, site_lng_1dp,
                          valid_from, valid_to, is_current, change_reason)
SELECT building_name, MAX(primary_usage), MAX(sub_usage), MAX(gross_sqm), MAX(site_name),
       MAX(site_lat_1dp), MAX(site_lng_1dp), '2017-07-01', '9999-12-31', 1, 'initial load'
FROM silver_campus_reading GROUP BY building_name;

-- ---------------- SCD Type 2 change ----------------
-- Facilities records that Bull_education_Dottie's new laboratory wing opened on 2017-08-15,
-- increasing gross floor area from 39,822.6 to 42,500.0 m2. Expire the old version, insert the new one.
UPDATE dim_building
   SET valid_to = '2017-08-14', is_current = 0
 WHERE building_bk = 'Bull_education_Dottie' AND is_current = 1;

INSERT INTO dim_building (building_bk, primary_usage, sub_usage, gross_sqm, site_name, site_lat_1dp, site_lng_1dp,
                          valid_from, valid_to, is_current, change_reason)
SELECT building_bk, primary_usage, sub_usage, 42500.0, site_name, site_lat_1dp, site_lng_1dp,
       '2017-08-15', '9999-12-31', 1, 'lab wing expansion: gross_sqm 39822.6 -> 42500.0'
FROM dim_building
WHERE building_bk = 'Bull_education_Dottie' AND valid_to = '2017-08-14';

-- ---------------- Fact load (point-in-time join to the building version valid on the reading date) ----------------
INSERT INTO fact_daily_energy (date_key, building_key, utility_key, weather_key, meter_code, consumption_kwh,
                               peak_hour_kwh, peak_hour, hours_reported, cost_2017_usd, cost_current_usd, on_grid_peak_hour)
SELECT CAST(DATE_FORMAT(s.reading_date, '%Y%m%d') AS UNSIGNED),
       b.building_key, u.utility_key, CAST(DATE_FORMAT(s.reading_date, '%Y%m%d') AS UNSIGNED),
       s.meter_code, s.consumption_kwh, s.peak_hour_kwh, s.peak_hour, s.hours_reported,
       ROUND(s.consumption_kwh * CASE s.utility_code WHEN 'electricity' THEN g.price_2017_cents / 100
                                                     WHEN 'chilledwater' THEN g.price_2017_cents / 400 ELSE 0.034 END, 2),
       ROUND(s.consumption_kwh * CASE s.utility_code WHEN 'electricity' THEN g.price_current_cents / 100
                                                     WHEN 'chilledwater' THEN g.price_current_cents / 400 ELSE 0.034 END, 2),
       COALESCE(p.is_ercot_top3_hour, 0)
FROM silver_campus_reading s
JOIN dim_building b ON b.building_bk = s.building_name AND s.reading_date BETWEEN b.valid_from AND b.valid_to
JOIN dim_utility  u ON u.utility_code = s.utility_code
JOIN gold_building_month_cost g ON g.building_name = s.building_name AND g.utility_code = s.utility_code
                               AND g.usage_month = DATE_FORMAT(s.reading_date, '%Y-%m-01')
LEFT JOIN gold_peak_hour_alignment p ON p.local_hour = s.peak_hour;

ANALYZE TABLE dim_date, dim_building, dim_utility, dim_weather, fact_daily_energy;


-- =====================================================================
-- 04  Part 2b analytical queries on the star schema + optimization
-- =====================================================================
USE campus_dw;

-- ---------------------------------------------------------------------
-- A1. [multi-dimensional aggregation: WITH ROLLUP]
-- Business question: What did each month of summer 2017 cost by primary space usage and utility,
-- at 2017 prices and at today's Texas commercial prices, with subtotals per month and a quarter total?
-- ---------------------------------------------------------------------
SELECT  d.month_name,
        b.primary_usage,
        u.utility_code,
        COUNT(*)                           AS meter_days,
        ROUND(SUM(f.consumption_kwh), 0)   AS kwh,
        ROUND(SUM(f.cost_2017_usd), 2)     AS cost_2017_usd,
        ROUND(SUM(f.cost_current_usd), 2)  AS cost_current_usd
FROM    fact_daily_energy f
JOIN    dim_date     d ON d.date_key     = f.date_key
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_utility  u ON u.utility_key  = f.utility_key
GROUP BY d.month_num, d.month_name, b.primary_usage, u.utility_code WITH ROLLUP;

-- ---------------------------------------------------------------------
-- A2. [SCD2-aware join]
-- Business question: Which 10 buildings had the highest average daily energy cost per square metre
-- in August 2017, using the floor area that was valid on each reading date?
-- (Bull_education_Dottie appears once per version: before and after its 2017-08-15 expansion.)
-- ---------------------------------------------------------------------
SELECT  b.building_bk,
        b.gross_sqm,
        b.valid_from,
        b.valid_to,
        COUNT(DISTINCT f.date_key)                                                   AS days,
        ROUND(SUM(f.cost_2017_usd) / COUNT(DISTINCT f.date_key) / b.gross_sqm, 4)    AS cost_per_sqm_per_day
FROM    fact_daily_energy f
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_date     d ON d.date_key     = f.date_key
WHERE   d.year_num = 2017 AND d.month_num = 8
GROUP BY b.building_key, b.building_bk, b.gross_sqm, b.valid_from, b.valid_to
ORDER BY cost_per_sqm_per_day DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- A3. [weekday vs weekend]
-- Business question: How much lower is average daily electricity use per square metre on weekends
-- than on weekdays, by primary space usage?
-- ---------------------------------------------------------------------
SELECT  b.primary_usage,
        ROUND(AVG(CASE WHEN d.is_weekend = 0 THEN f.consumption_kwh / b.gross_sqm END), 4) AS weekday_kwh_per_sqm,
        ROUND(AVG(CASE WHEN d.is_weekend = 1 THEN f.consumption_kwh / b.gross_sqm END), 4) AS weekend_kwh_per_sqm,
        ROUND(100 * (1 - AVG(CASE WHEN d.is_weekend = 1 THEN f.consumption_kwh / b.gross_sqm END)
                       / AVG(CASE WHEN d.is_weekend = 0 THEN f.consumption_kwh / b.gross_sqm END)), 1) AS weekend_drop_pct
FROM    fact_daily_energy f
JOIN    dim_date     d ON d.date_key     = f.date_key
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_utility  u ON u.utility_key  = f.utility_key
WHERE   u.utility_code = 'electricity'
GROUP BY b.primary_usage
ORDER BY weekend_drop_pct DESC;

-- ---------------------------------------------------------------------
-- A4. [weather dimension]
-- Business question: How does chilled-water use per square metre change across hot, very hot and
-- extreme days for each primary space usage?
-- ---------------------------------------------------------------------
SELECT  b.primary_usage,
        w.temp_band,
        COUNT(DISTINCT w.weather_key)                 AS days,
        ROUND(AVG(f.consumption_kwh / b.gross_sqm), 3) AS chw_kwh_per_sqm_day
FROM    fact_daily_energy f
JOIN    dim_weather  w ON w.weather_key  = f.weather_key
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_utility  u ON u.utility_key  = f.utility_key
WHERE   u.utility_code = 'chilledwater'
GROUP BY b.primary_usage, w.temp_band
HAVING  days >= 3
ORDER BY b.primary_usage, w.temp_band;

-- ---------------------------------------------------------------------
-- A5. [API enrichment: grid peak coincidence]
-- Business question: Which space-usage categories most often hit their daily electricity peak during
-- ERCOT's three highest-demand hours (16:00-18:00), and what share of their current-price cost falls on those days?
-- ---------------------------------------------------------------------
SELECT  b.primary_usage,
        COUNT(*)                                                         AS meter_days,
        SUM(f.on_grid_peak_hour)                                         AS grid_peak_days,
        ROUND(100 * SUM(f.on_grid_peak_hour) / COUNT(*), 1)              AS grid_peak_day_pct,
        ROUND(100 * SUM(CASE WHEN f.on_grid_peak_hour = 1 THEN f.cost_current_usd ELSE 0 END)
                  / SUM(f.cost_current_usd), 1)                          AS cost_share_on_grid_peak_days_pct
FROM    fact_daily_energy f
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_utility  u ON u.utility_key  = f.utility_key
WHERE   u.utility_code = 'electricity'
GROUP BY b.primary_usage
ORDER BY grid_peak_day_pct DESC;

-- =====================================================================
-- Optimization of the most expensive query (A1)
-- Baseline: EXPLAIN ANALYZE on A1 as written (scans all fact rows, three joins, rollup).
-- =====================================================================
EXPLAIN ANALYZE
SELECT  d.month_name, b.primary_usage, u.utility_code, COUNT(*) AS meter_days,
        ROUND(SUM(f.consumption_kwh), 0) AS kwh, ROUND(SUM(f.cost_2017_usd), 2) AS cost_2017_usd,
        ROUND(SUM(f.cost_current_usd), 2) AS cost_current_usd
FROM    fact_daily_energy f
JOIN    dim_date     d ON d.date_key     = f.date_key
JOIN    dim_building b ON b.building_key = f.building_key
JOIN    dim_utility  u ON u.utility_key  = f.utility_key
GROUP BY d.month_num, d.month_name, b.primary_usage, u.utility_code WITH ROLLUP;

-- Optimization: MySQL has no native materialized views, so the ETL maintains a pre-aggregated
-- summary table at month x usage x utility grain (refreshed after each fact load).
DROP TABLE IF EXISTS mv_month_usage_utility;
CREATE TABLE mv_month_usage_utility (
  month_num        TINYINT UNSIGNED NOT NULL,
  month_name       VARCHAR(9)   NOT NULL,
  primary_usage    VARCHAR(60)  NOT NULL,
  utility_code     VARCHAR(30)  NOT NULL,
  meter_days       INT UNSIGNED NOT NULL,
  kwh              DECIMAL(18,4) NOT NULL,
  cost_2017_usd    DECIMAL(16,2) NOT NULL,
  cost_current_usd DECIMAL(16,2) NOT NULL,
  refreshed_at     DATETIME     NOT NULL,
  PRIMARY KEY (month_num, primary_usage, utility_code)
) ENGINE=InnoDB;

INSERT INTO mv_month_usage_utility
SELECT d.month_num, d.month_name, b.primary_usage, u.utility_code, COUNT(*),
       SUM(f.consumption_kwh), SUM(f.cost_2017_usd), SUM(f.cost_current_usd), NOW()
FROM   fact_daily_energy f
JOIN   dim_date     d ON d.date_key     = f.date_key
JOIN   dim_building b ON b.building_key = f.building_key
JOIN   dim_utility  u ON u.utility_key  = f.utility_key
GROUP BY d.month_num, d.month_name, b.primary_usage, u.utility_code;
ANALYZE TABLE mv_month_usage_utility;

-- After: the same report answered from the summary table (identical result set).
EXPLAIN ANALYZE
SELECT  month_name, primary_usage, utility_code, SUM(meter_days) AS meter_days,
        ROUND(SUM(kwh), 0) AS kwh, ROUND(SUM(cost_2017_usd), 2) AS cost_2017_usd,
        ROUND(SUM(cost_current_usd), 2) AS cost_current_usd
FROM    mv_month_usage_utility
GROUP BY month_num, month_name, primary_usage, utility_code WITH ROLLUP;

SELECT  month_name, primary_usage, utility_code, SUM(meter_days) AS meter_days,
        ROUND(SUM(kwh), 0) AS kwh, ROUND(SUM(cost_2017_usd), 2) AS cost_2017_usd,
        ROUND(SUM(cost_current_usd), 2) AS cost_current_usd
FROM    mv_month_usage_utility
GROUP BY month_num, month_name, primary_usage, utility_code WITH ROLLUP;


-- =====================================================================
-- 05  Part 4a: relational warehouse showcase queries
-- =====================================================================
USE campus_dw;

-- ---------------------------------------------------------------------
-- S1. [SCD2 point-in-time vs current-state comparison]
-- Business question: For buildings whose attributes changed during the quarter, how different is
-- daily cost per square metre when each reading is measured against the floor area valid on that date
-- versus today's (current) floor area?
-- ---------------------------------------------------------------------
SELECT  hist.building_bk,
        hist.gross_sqm                                                        AS sqm_on_reading_date,
        cur.gross_sqm                                                         AS sqm_current,
        MIN(d.full_date)                                                      AS from_date,
        MAX(d.full_date)                                                      AS to_date,
        ROUND(SUM(f.cost_2017_usd) / COUNT(DISTINCT f.date_key) / hist.gross_sqm, 4) AS cost_per_sqm_day_historical,
        ROUND(SUM(f.cost_2017_usd) / COUNT(DISTINCT f.date_key) / cur.gross_sqm, 4)  AS cost_per_sqm_day_current_area
FROM    fact_daily_energy f
JOIN    dim_building hist ON hist.building_key = f.building_key
JOIN    dim_building cur  ON cur.building_bk   = hist.building_bk AND cur.is_current = 1
JOIN    dim_date     d    ON d.date_key        = f.date_key
WHERE   hist.building_bk IN (SELECT building_bk FROM dim_building GROUP BY building_bk HAVING COUNT(*) > 1)
GROUP BY hist.building_key, hist.building_bk, hist.gross_sqm, cur.gross_sqm
ORDER BY from_date;

-- ---------------------------------------------------------------------
-- S2. [time-series trend with window functions across three dimensions]
-- Business question: How did campus electricity demand trend through the summer, as a 7-day moving
-- average next to the daily maximum temperature, and which days ran more than 5% above their trend?
-- ---------------------------------------------------------------------
WITH daily AS (
  SELECT  d.full_date, d.day_name, w.max_air_temp_c, SUM(f.consumption_kwh) AS kwh
  FROM    fact_daily_energy f
  JOIN    dim_date    d ON d.date_key    = f.date_key
  JOIN    dim_weather w ON w.weather_key = f.weather_key
  JOIN    dim_utility u ON u.utility_key = f.utility_key
  WHERE   u.utility_code = 'electricity'
  GROUP BY d.full_date, d.day_name, w.max_air_temp_c
)
SELECT  full_date, day_name, max_air_temp_c,
        ROUND(kwh, 0)                                                                  AS campus_kwh,
        ROUND(AVG(kwh) OVER (ORDER BY full_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) AS kwh_7day_avg,
        ROUND(100 * (kwh / AVG(kwh) OVER (ORDER BY full_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) - 1), 1) AS pct_vs_trend
FROM    daily
ORDER BY full_date;

-- ---------------------------------------------------------------------
-- S3. [multi-dimensional rollup with GROUPING() labels]
-- Business question: How is the quarter's current-price energy bill split across weather bands and
-- weekday/weekend, with subtotals per band and a grand total, so Finance can budget for heat waves?
-- ---------------------------------------------------------------------
SELECT  IF(GROUPING(w.temp_band) = 1, 'ALL BANDS', w.temp_band)                             AS temp_band,
        IF(GROUPING(d.is_weekend) = 1, 'ALL DAYS', IF(d.is_weekend = 1, 'weekend', 'weekday')) AS day_type,
        COUNT(DISTINCT d.date_key)                                                           AS days,
        ROUND(SUM(f.cost_current_usd), 2)                                                    AS cost_current_usd,
        ROUND(SUM(f.cost_current_usd) / COUNT(DISTINCT d.date_key), 2)                       AS cost_per_day_usd
FROM    fact_daily_energy f
JOIN    dim_weather w ON w.weather_key = f.weather_key
JOIN    dim_date    d ON d.date_key    = f.date_key
GROUP BY w.temp_band, d.is_weekend WITH ROLLUP;


-- =====================================================================
-- 06  Evidence queries: data quality, quarantine, PII masking, Gold, SCD2
-- =====================================================================
USE campus_dw;

-- E1. Data-quality results (row-level pass/fail counts per check, latest run)
SELECT source_name, check_type, check_name, rows_checked, rows_passed, rows_failed
FROM dq_check_log
WHERE run_id = (SELECT run_id FROM dq_check_log ORDER BY check_id DESC LIMIT 1)
ORDER BY check_id;

-- E2. Quarantine: rejected rows by source and reason
SELECT source_name, failed_checks, COUNT(*) AS rows_quarantined
FROM silver_quarantine GROUP BY source_name, failed_checks;

-- E3. Layer row counts (Bronze -> Silver -> Gold -> star)
SELECT 'bronze_eia_raw' AS table_name, COUNT(*) AS row_count FROM bronze_eia_raw
UNION ALL SELECT 'bronze_campus_reading', COUNT(*) FROM bronze_campus_reading
UNION ALL SELECT 'silver_quarantine', COUNT(*) FROM silver_quarantine
UNION ALL SELECT 'silver_ercot_hourly', COUNT(*) FROM silver_ercot_hourly
UNION ALL SELECT 'silver_tx_price_monthly', COUNT(*) FROM silver_tx_price_monthly
UNION ALL SELECT 'silver_campus_reading', COUNT(*) FROM silver_campus_reading
UNION ALL SELECT 'gold_building_month_cost', COUNT(*) FROM gold_building_month_cost
UNION ALL SELECT 'gold_peak_hour_alignment', COUNT(*) FROM gold_peak_hour_alignment
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_building', COUNT(*) FROM dim_building
UNION ALL SELECT 'dim_utility', COUNT(*) FROM dim_utility
UNION ALL SELECT 'dim_weather', COUNT(*) FROM dim_weather
UNION ALL SELECT 'fact_daily_energy', COUNT(*) FROM fact_daily_energy;

-- E4. PII masking: raw coordinates in Bronze vs generalized value + token in Silver
SELECT 'bronze (raw)' AS layer, lat AS latitude, lng AS longitude, NULL AS geo_token FROM bronze_campus_reading LIMIT 1;
SELECT 'silver (masked)' AS layer, site_lat_1dp, site_lng_1dp, site_geo_token FROM silver_campus_reading LIMIT 1;

-- E5. Gold 1: quarter cost at 2017 vs current Texas commercial prices, by utility and month
SELECT utility_code, usage_month, MAX(price_2017_cents) AS price_2017_c, MAX(price_current_cents) AS price_now_c,
       MAX(price_current_month) AS price_now_month, ROUND(SUM(kwh), 0) AS kwh,
       SUM(cost_2017_usd) AS cost_2017_usd, SUM(cost_current_usd) AS cost_current_usd
FROM gold_building_month_cost GROUP BY utility_code, usage_month ORDER BY usage_month, utility_code;

-- E6. Gold 2: campus peak hour vs ERCOT system demand by hour of day
SELECT * FROM gold_peak_hour_alignment ORDER BY local_hour;

-- E7. SCD2 proof: expired and current versions of the changed building
SELECT building_key, building_bk, primary_usage, gross_sqm, valid_from, valid_to, is_current, change_reason
FROM dim_building WHERE building_bk = 'Bull_education_Dottie' ORDER BY valid_from;


