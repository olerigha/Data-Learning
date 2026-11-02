-- =====================================================================
-- Cloud Native Data Engineering — Assignment 2 — SQL SCRIPT (submission)
-- Campus Energy Monitoring Platform (evolves Assignment 1)
-- Author: Obaro Erigha
-- Target: Amazon RDS for MySQL 8.4.11 (us-east-2), schema campus_energy
-- Data: BDG2 Bull site (UT Austin) daily meter readings Jul–Sep 2017 + EIA-861M TX prices
-- Contents:
--   PART 3/4  Schema DDL (9 tables, PK/FK/UNIQUE/CHECK)
--   PART 4    Data load note + verification counts
--   PART 5    8 business queries (business question above each)
--   PART 6    EXPLAIN ANALYZE + index commands (hypotheses H1–H3) + cleanup
-- No credentials or endpoints appear in this file.
-- =====================================================================

-- =====================================================================
-- PART 3/4 — SCHEMA DDL (MySQL 8.0.16+; deployed on RDS MySQL 8.4.11)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS campus_energy
  DEFAULT CHARACTER SET utf8mb4 DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE campus_energy;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS daily_reading, tariff_rate, eia_price_monthly, weather_daily,
                     meter, building, utility_type, space_usage, site;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. SITE: a campus / BDG2 site. Owns buildings and weather observations.
CREATE TABLE site (
  site_id        SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  site_name      VARCHAR(50)       NOT NULL,
  timezone       VARCHAR(40)       NOT NULL,
  latitude       DECIMAL(8,5)      NULL,          -- BDG2 gives site centroid only; may be unknown
  longitude      DECIMAL(8,5)      NULL,
  CONSTRAINT pk_site PRIMARY KEY (site_id),
  CONSTRAINT uq_site_name UNIQUE (site_name),
  CONSTRAINT ck_site_lat CHECK (latitude  IS NULL OR latitude  BETWEEN -90  AND 90),
  CONSTRAINT ck_site_lng CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
) ENGINE=InnoDB;

-- 2. SPACE_USAGE: RECURSIVE HIERARCHY. Top-level primary usage (parent NULL)
--    -> sub-usage (parent = primary). E.g. Education -> College Classroom.
CREATE TABLE space_usage (
  space_usage_id   SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  usage_name       VARCHAR(60)       NOT NULL,
  parent_usage_id  SMALLINT UNSIGNED NULL,        -- NULL = root category
  CONSTRAINT pk_space_usage PRIMARY KEY (space_usage_id),
  CONSTRAINT uq_space_usage_name_parent UNIQUE (parent_usage_id, usage_name),
  CONSTRAINT fk_space_usage_parent FOREIGN KEY (parent_usage_id)
    REFERENCES space_usage (space_usage_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3. BUILDING: one physical building, classified at the sub-usage (leaf) level.
CREATE TABLE building (
  building_id         SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  building_name       VARCHAR(80)       NOT NULL,
  building_kaggle_id  INT UNSIGNED      NULL,     -- ASHRAE GEPIII id; not every BDG2 building has one
  site_id             SMALLINT UNSIGNED NOT NULL,
  space_usage_id      SMALLINT UNSIGNED NOT NULL,
  gross_sqm           DECIMAL(10,1)     NOT NULL,
  CONSTRAINT pk_building PRIMARY KEY (building_id),
  CONSTRAINT uq_building_name UNIQUE (building_name),
  CONSTRAINT uq_building_kaggle UNIQUE (building_kaggle_id),
  CONSTRAINT ck_building_sqm CHECK (gross_sqm > 0),
  CONSTRAINT fk_building_site FOREIGN KEY (site_id)
    REFERENCES site (site_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_building_usage FOREIGN KEY (space_usage_id)
    REFERENCES space_usage (space_usage_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 4. UTILITY_TYPE: electricity, chilled water, steam (all reported in kWh per BDG2).
CREATE TABLE utility_type (
  utility_type_id  TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  utility_code     VARCHAR(20)      NOT NULL,
  unit             VARCHAR(10)      NOT NULL,
  CONSTRAINT pk_utility_type PRIMARY KEY (utility_type_id),
  CONSTRAINT uq_utility_code UNIQUE (utility_code)
) ENGINE=InnoDB;

-- 5. METER: ASSOCIATIVE (JUNCTION) ENTITY resolving BUILDING M:N UTILITY_TYPE.
--    A building is metered for 1..3 utilities; a utility is metered in many buildings.
CREATE TABLE meter (
  meter_id         SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  building_id      SMALLINT UNSIGNED NOT NULL,
  utility_type_id  TINYINT UNSIGNED  NOT NULL,
  meter_code       VARCHAR(100)      NOT NULL,     -- source identifier "building|utility"
  CONSTRAINT pk_meter PRIMARY KEY (meter_id),
  CONSTRAINT uq_meter_building_utility UNIQUE (building_id, utility_type_id),
  CONSTRAINT uq_meter_code UNIQUE (meter_code),
  CONSTRAINT fk_meter_building FOREIGN KEY (building_id)
    REFERENCES building (building_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_meter_utility FOREIGN KEY (utility_type_id)
    REFERENCES utility_type (utility_type_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 6. DAILY_READING: fact table, one row per meter per day (hourly data aggregated).
--    Consumption is NULL exactly when no hourly values were reported that day.
CREATE TABLE daily_reading (
  meter_id         SMALLINT UNSIGNED NOT NULL,
  reading_date     DATE              NOT NULL,
  consumption_kwh  DECIMAL(14,4)     NULL,
  peak_hour_kwh    DECIMAL(14,4)     NULL,
  peak_hour        TINYINT UNSIGNED  NULL,       -- local hour 0..23 of the daily maximum
  hours_reported   TINYINT UNSIGNED  NOT NULL,   -- data completeness, 0..24
  CONSTRAINT pk_daily_reading PRIMARY KEY (meter_id, reading_date),
  CONSTRAINT ck_dr_hours  CHECK (hours_reported BETWEEN 0 AND 24),
  CONSTRAINT ck_dr_peakhr CHECK (peak_hour IS NULL OR peak_hour BETWEEN 0 AND 23),
  CONSTRAINT ck_dr_nonneg CHECK (consumption_kwh IS NULL OR consumption_kwh >= 0),
  CONSTRAINT ck_dr_null_iff_no_hours CHECK (
       (hours_reported = 0 AND consumption_kwh IS NULL)
    OR (hours_reported > 0 AND consumption_kwh IS NOT NULL)),
  CONSTRAINT fk_dr_meter FOREIGN KEY (meter_id)
    REFERENCES meter (meter_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 7. WEATHER_DAILY: site-level daily weather (BDG2 weather is keyed by site).
CREATE TABLE weather_daily (
  site_id         SMALLINT UNSIGNED NOT NULL,
  weather_date    DATE              NOT NULL,
  avg_air_temp_c  DECIMAL(7,4)      NULL,
  max_air_temp_c  DECIMAL(7,4)      NULL,
  avg_dew_temp_c  DECIMAL(7,4)      NULL,
  total_precip_mm DECIMAL(8,2)      NULL,
  hours_observed  TINYINT UNSIGNED  NOT NULL,
  CONSTRAINT pk_weather_daily PRIMARY KEY (site_id, weather_date),
  CONSTRAINT ck_wx_hours CHECK (hours_observed BETWEEN 0 AND 24),
  CONSTRAINT fk_wx_site FOREIGN KEY (site_id)
    REFERENCES site (site_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 8. EIA_PRICE_MONTHLY: published average retail price (EIA-861M), per state/sector/month.
CREATE TABLE eia_price_monthly (
  eia_price_id     SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  state_code       CHAR(2)           NOT NULL,
  sector           VARCHAR(20)       NOT NULL,
  price_month      DATE              NOT NULL,     -- first day of month
  price_cents_kwh  DECIMAL(6,2)      NOT NULL,
  data_status      VARCHAR(15)       NOT NULL,     -- 'Final' / 'Preliminary'
  CONSTRAINT pk_eia_price_monthly PRIMARY KEY (eia_price_id),
  CONSTRAINT uq_eia_state_sector_month UNIQUE (state_code, sector, price_month),
  CONSTRAINT ck_eia_month_first CHECK (DAYOFMONTH(price_month) = 1),
  CONSTRAINT ck_eia_price_pos CHECK (price_cents_kwh > 0)
) ENGINE=InnoDB;

-- 9. TARIFF_RATE: billed unit rate per utility per month. eia_price_id records the
--    market basis (NULL for steam, whose rate is an assumption, not an EIA price).
CREATE TABLE tariff_rate (
  tariff_rate_id   SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  utility_type_id  TINYINT UNSIGNED  NOT NULL,
  rate_month       DATE              NOT NULL,     -- first day of month
  eia_price_id     SMALLINT UNSIGNED NULL,
  unit_rate_usd    DECIMAL(10,6)     NOT NULL,     -- USD per kWh (thermal kWh for CHW/steam)
  rate_basis       VARCHAR(100)      NOT NULL,
  CONSTRAINT pk_tariff_rate PRIMARY KEY (tariff_rate_id),
  CONSTRAINT uq_tariff_utility_month UNIQUE (utility_type_id, rate_month),
  CONSTRAINT ck_tariff_month_first CHECK (DAYOFMONTH(rate_month) = 1),
  CONSTRAINT ck_tariff_rate_pos CHECK (unit_rate_usd > 0),
  CONSTRAINT fk_tariff_utility FOREIGN KEY (utility_type_id)
    REFERENCES utility_type (utility_type_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_tariff_eia FOREIGN KEY (eia_price_id)
    REFERENCES eia_price_monthly (eia_price_id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

-- =====================================================================
-- PART 4 — DATA LOAD + VERIFICATION
-- The 9 normalized CSVs (data/3nf/*.csv) were loaded in FK-safe order with
-- scripts/load_3nf.py (pymysql, TLS with the RDS CA bundle, password prompted).
-- Business question: Did every normalized table load completely on RDS (>= 5,000 rows)?
-- Result on RDS: site 1, space_usage 21, building 124, utility_type 3, meter 308,
--   daily_reading 28,336, weather_daily 92, eia_price_monthly 3, tariff_rate 9 = 28,897.
-- =====================================================================
SELECT 'site' AS table_name, COUNT(*) AS row_count FROM site
UNION ALL SELECT 'space_usage', COUNT(*) FROM space_usage
UNION ALL SELECT 'building', COUNT(*) FROM building
UNION ALL SELECT 'utility_type', COUNT(*) FROM utility_type
UNION ALL SELECT 'meter', COUNT(*) FROM meter
UNION ALL SELECT 'daily_reading', COUNT(*) FROM daily_reading
UNION ALL SELECT 'weather_daily', COUNT(*) FROM weather_daily
UNION ALL SELECT 'eia_price_monthly', COUNT(*) FROM eia_price_monthly
UNION ALL SELECT 'tariff_rate', COUNT(*) FROM tariff_rate;

-- =====================================================================
-- PART 5 — BUSINESS QUERIES
-- =====================================================================
-- ---------------------------------------------------------------------
-- Q1. [INNER JOIN x6, GROUP BY, HAVING]
-- Business question: In August 2017 (Austin's peak cooling month), which 10 buildings
-- had the highest total energy cost per square metre across all utilities, so that
-- facilities can prioritise energy audits?
-- ---------------------------------------------------------------------
SELECT  b.building_name,
        parent.usage_name                             AS primary_usage,
        su.usage_name                                 AS sub_usage,
        b.gross_sqm,
        COUNT(DISTINCT m.meter_id)                    AS meters,
        ROUND(SUM(dr.consumption_kwh), 0)             AS total_kwh,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd), 2)                AS total_cost_usd,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd) / b.gross_sqm, 2)  AS cost_per_sqm_usd
FROM    daily_reading dr
JOIN    meter        m      ON m.meter_id         = dr.meter_id
JOIN    utility_type ut     ON ut.utility_type_id = m.utility_type_id
JOIN    tariff_rate  tr     ON tr.utility_type_id = m.utility_type_id
                           AND tr.rate_month      = '2017-08-01'
JOIN    building     b      ON b.building_id      = m.building_id
JOIN    space_usage  su     ON su.space_usage_id  = b.space_usage_id
JOIN    space_usage  parent ON parent.space_usage_id = su.parent_usage_id
WHERE   dr.reading_date >= '2017-08-01' AND dr.reading_date < '2017-09-01'
GROUP BY b.building_id, b.building_name, parent.usage_name, su.usage_name, b.gross_sqm
HAVING  SUM(dr.consumption_kwh) > 0
ORDER BY cost_per_sqm_usd DESC
LIMIT 10;

-- ---------------------------------------------------------------------
-- Q2. [LEFT OUTER JOIN, GROUP BY, HAVING]
-- Business question: Which meters miss the A1 target of 95% data completeness
-- (hours reported / hours expected) for the quarter, so the metering team can fix them?
-- LEFT JOIN keeps a meter even if it has no reading rows at all.
-- ---------------------------------------------------------------------
SELECT  m.meter_code,
        b.building_name,
        ut.utility_code,
        COUNT(dr.reading_date)                                    AS days_present,
        COALESCE(SUM(dr.hours_reported), 0)                       AS hours_reported,
        92 * 24                                                   AS hours_expected,
        ROUND(100 * COALESCE(SUM(dr.hours_reported), 0) / (92 * 24), 1) AS completeness_pct,
        SUM(CASE WHEN dr.hours_reported = 0 THEN 1 ELSE 0 END)    AS fully_missing_days
FROM    meter m
JOIN    building b      ON b.building_id = m.building_id
JOIN    utility_type ut ON ut.utility_type_id = m.utility_type_id
LEFT JOIN daily_reading dr ON dr.meter_id = m.meter_id
GROUP BY m.meter_id, m.meter_code, b.building_name, ut.utility_code
HAVING  completeness_pct < 95
ORDER BY completeness_pct ASC;

-- ---------------------------------------------------------------------
-- Q3. [CTE + window function LAG]
-- Business question: How did electricity consumption change month over month for each
-- primary space-usage category (e.g., did dormitories drop in August as students left)?
-- ---------------------------------------------------------------------
WITH monthly AS (
    SELECT  parent.usage_name                              AS primary_usage,
            DATE_FORMAT(dr.reading_date, '%Y-%m')          AS month,
            SUM(dr.consumption_kwh)                        AS kwh
    FROM    daily_reading dr
    JOIN    meter m           ON m.meter_id = dr.meter_id
    JOIN    utility_type ut   ON ut.utility_type_id = m.utility_type_id
    JOIN    building b        ON b.building_id = m.building_id
    JOIN    space_usage su    ON su.space_usage_id = b.space_usage_id
    JOIN    space_usage parent ON parent.space_usage_id = su.parent_usage_id
    WHERE   ut.utility_code = 'electricity'
    GROUP BY parent.usage_name, DATE_FORMAT(dr.reading_date, '%Y-%m')
)
SELECT  primary_usage,
        month,
        ROUND(kwh, 0)                                                    AS kwh,
        ROUND(LAG(kwh) OVER (PARTITION BY primary_usage ORDER BY month), 0) AS prev_month_kwh,
        ROUND(100 * (kwh - LAG(kwh) OVER (PARTITION BY primary_usage ORDER BY month))
                  / LAG(kwh) OVER (PARTITION BY primary_usage ORDER BY month), 1) AS mom_change_pct
FROM    monthly
ORDER BY primary_usage, month;

-- ---------------------------------------------------------------------
-- Q4. [CTE + window function ROW_NUMBER, multi-table INNER JOIN]
-- Business question: For each utility, which 3 buildings set the highest single-hour
-- peak demand this quarter, and on what date and hour? (Peak demand drives demand charges.)
-- ---------------------------------------------------------------------
WITH peaks AS (
    SELECT  ut.utility_code,
            b.building_name,
            dr.reading_date,
            dr.peak_hour,
            dr.peak_hour_kwh,
            ROW_NUMBER() OVER (PARTITION BY ut.utility_code, b.building_id
                               ORDER BY dr.peak_hour_kwh DESC, dr.reading_date) AS rn_in_building
    FROM    daily_reading dr
    JOIN    meter m         ON m.meter_id = dr.meter_id
    JOIN    utility_type ut ON ut.utility_type_id = m.utility_type_id
    JOIN    building b      ON b.building_id = m.building_id
    WHERE   dr.peak_hour_kwh IS NOT NULL
), building_peak AS (
    SELECT  utility_code, building_name, reading_date, peak_hour, peak_hour_kwh,
            DENSE_RANK() OVER (PARTITION BY utility_code ORDER BY peak_hour_kwh DESC) AS peak_rank
    FROM    peaks
    WHERE   rn_in_building = 1
)
SELECT  utility_code, peak_rank, building_name, reading_date, peak_hour,
        ROUND(peak_hour_kwh, 1) AS peak_hour_kwh
FROM    building_peak
WHERE   peak_rank <= 3
ORDER BY utility_code, peak_rank;

-- ---------------------------------------------------------------------
-- Q5. [Recursive hierarchy (self-join on space_usage), GROUP BY WITH ROLLUP]
-- Business question: What is the quarter's total energy cost by space-usage category,
-- rolled up from sub-usage to primary usage to campus total, so Finance can allocate
-- 100% of cost (A1 success criterion)?
-- ---------------------------------------------------------------------
SELECT  COALESCE(parent.usage_name, '== CAMPUS TOTAL ==')         AS primary_usage,
        COALESCE(su.usage_name, IF(parent.usage_name IS NULL, '', '-- subtotal --')) AS sub_usage,
        COUNT(DISTINCT b.building_id)                                 AS buildings,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd), 2)          AS cost_usd
FROM    daily_reading dr
JOIN    meter m            ON m.meter_id = dr.meter_id
JOIN    tariff_rate tr     ON tr.utility_type_id = m.utility_type_id
                          AND tr.rate_month = DATE_FORMAT(dr.reading_date, '%Y-%m-01')
JOIN    building b         ON b.building_id = m.building_id
JOIN    space_usage su     ON su.space_usage_id = b.space_usage_id
JOIN    space_usage parent ON parent.space_usage_id = su.parent_usage_id
GROUP BY parent.usage_name, su.usage_name WITH ROLLUP;

-- ---------------------------------------------------------------------
-- Q6. [INNER JOIN incl. weather, CASE banding, GROUP BY, HAVING]
-- Business question: How much more chilled water does the average building use per day
-- on very hot days (max >= 38 C) than on milder days, to size cooling-plant capacity?
-- ---------------------------------------------------------------------
SELECT  CASE WHEN w.max_air_temp_c >= 38 THEN '1: >= 38 C'
             WHEN w.max_air_temp_c >= 35 THEN '2: 35-37.9 C'
             ELSE                              '3: < 35 C' END   AS temp_band,
        COUNT(DISTINCT w.weather_date)                           AS days,
        ROUND(AVG(w.max_air_temp_c), 1)                          AS avg_max_temp_c,
        ROUND(AVG(dr.consumption_kwh), 0)                        AS avg_chw_kwh_per_meter_day,
        ROUND(SUM(dr.consumption_kwh) / COUNT(DISTINCT w.weather_date), 0) AS campus_chw_kwh_per_day
FROM    daily_reading dr
JOIN    meter m         ON m.meter_id = dr.meter_id
JOIN    utility_type ut ON ut.utility_type_id = m.utility_type_id
JOIN    building b      ON b.building_id = m.building_id
JOIN    weather_daily w ON w.site_id = b.site_id AND w.weather_date = dr.reading_date
WHERE   ut.utility_code = 'chilledwater'
  AND   dr.hours_reported = 24
GROUP BY temp_band
HAVING  COUNT(DISTINCT w.weather_date) >= 3
ORDER BY temp_band;

-- ---------------------------------------------------------------------
-- Q7. [CTE + window functions AVG/STDDEV OVER (PARTITION BY)]
-- Business question: Which meter-days were abnormal (consumption more than 3 standard
-- deviations from that meter's own quarterly mean), so operators can investigate within
-- 24 hours (A1 success criterion)?
-- ---------------------------------------------------------------------
WITH stats AS (
    SELECT  dr.meter_id,
            dr.reading_date,
            dr.consumption_kwh,
            AVG(dr.consumption_kwh)        OVER (PARTITION BY dr.meter_id) AS mean_kwh,
            STDDEV_SAMP(dr.consumption_kwh) OVER (PARTITION BY dr.meter_id) AS sd_kwh
    FROM    daily_reading dr
    WHERE   dr.consumption_kwh IS NOT NULL
      AND   dr.hours_reported = 24
)
SELECT  m.meter_code,
        s.reading_date,
        ROUND(s.consumption_kwh, 0)                       AS kwh,
        ROUND(s.mean_kwh, 0)                              AS meter_mean_kwh,
        ROUND((s.consumption_kwh - s.mean_kwh) / s.sd_kwh, 2) AS z_score,
        CASE WHEN s.consumption_kwh > s.mean_kwh THEN 'SPIKE' ELSE 'DROP' END AS anomaly_type
FROM    stats s
JOIN    meter m ON m.meter_id = s.meter_id
WHERE   s.sd_kwh > 0
  AND   ABS(s.consumption_kwh - s.mean_kwh) > 3 * s.sd_kwh
ORDER BY ABS((s.consumption_kwh - s.mean_kwh) / s.sd_kwh) DESC
LIMIT 15;

-- ---------------------------------------------------------------------
-- Q8. [RIGHT OUTER JOIN + LEFT OUTER JOIN, GROUP BY]
-- Business question: For every tariff (utility x month) on file, what was the metered
-- consumption and cost, and what market price was it based on? Tariffs with no
-- readings must still appear (RIGHT JOIN), and steam has no EIA basis (LEFT JOIN -> NULL).
-- ---------------------------------------------------------------------
SELECT  ut.utility_code,
        tr.rate_month,
        tr.unit_rate_usd,
        e.price_cents_kwh                                 AS eia_tx_commercial_cents,
        tr.rate_basis,
        COUNT(dr.reading_date)                            AS meter_days,
        ROUND(COALESCE(SUM(dr.consumption_kwh), 0), 0)    AS kwh,
        ROUND(COALESCE(SUM(dr.consumption_kwh), 0) * tr.unit_rate_usd, 2) AS cost_usd
FROM    daily_reading dr
JOIN    meter m ON m.meter_id = dr.meter_id
RIGHT JOIN tariff_rate tr
        ON  tr.utility_type_id = m.utility_type_id
        AND tr.rate_month      = DATE_FORMAT(dr.reading_date, '%Y-%m-01')
JOIN    utility_type ut        ON ut.utility_type_id = tr.utility_type_id
LEFT JOIN eia_price_monthly e  ON e.eia_price_id     = tr.eia_price_id
GROUP BY ut.utility_code, tr.tariff_rate_id, tr.rate_month, tr.unit_rate_usd,
         e.price_cents_kwh, tr.rate_basis
ORDER BY tr.rate_month, ut.utility_code;

-- =====================================================================
-- PART 6 — OPTIMIZATION WITH PROOF
-- Two most join-heavy queries: Q1 (7 tables) and Q5 (6 tables).
-- Full RDS output: evidence/phase6_experiment.txt (each plan run 3x; medians below).
-- =====================================================================

-- 6a. Baseline execution plans (only the PRIMARY key on daily_reading)
-- Q1 baseline on RDS: dr "Index lookup using PRIMARY (meter_id)" rows=92 x loops=308
--   = 28,336 rows examined, 9,548 kept; median 44.3 ms (44.3 / 41.5 / 53.6).
EXPLAIN ANALYZE
SELECT  b.building_name,
        parent.usage_name                             AS primary_usage,
        su.usage_name                                 AS sub_usage,
        b.gross_sqm,
        COUNT(DISTINCT m.meter_id)                    AS meters,
        ROUND(SUM(dr.consumption_kwh), 0)             AS total_kwh,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd), 2)                AS total_cost_usd,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd) / b.gross_sqm, 2)  AS cost_per_sqm_usd
FROM    daily_reading dr
JOIN    meter        m      ON m.meter_id         = dr.meter_id
JOIN    utility_type ut     ON ut.utility_type_id = m.utility_type_id
JOIN    tariff_rate  tr     ON tr.utility_type_id = m.utility_type_id
                           AND tr.rate_month      = '2017-08-01'
JOIN    building     b      ON b.building_id      = m.building_id
JOIN    space_usage  su     ON su.space_usage_id  = b.space_usage_id
JOIN    space_usage  parent ON parent.space_usage_id = su.parent_usage_id
WHERE   dr.reading_date >= '2017-08-01' AND dr.reading_date < '2017-09-01'
GROUP BY b.building_id, b.building_name, parent.usage_name, su.usage_name, b.gross_sqm
HAVING  SUM(dr.consumption_kwh) > 0
ORDER BY cost_per_sqm_usd DESC
LIMIT 10;

-- ---------------------------------------------------------------------

-- Q5 baseline on RDS: dr rows=92 x loops=924 = 85,008 examined -> 28,336 rows;
--   median 124 ms (124 / 124 / 122). Cause: non-sargable DATE_FORMAT tariff join.
EXPLAIN ANALYZE
SELECT  COALESCE(parent.usage_name, '== CAMPUS TOTAL ==')         AS primary_usage,
        COALESCE(su.usage_name, IF(parent.usage_name IS NULL, '', '-- subtotal --')) AS sub_usage,
        COUNT(DISTINCT b.building_id)                                 AS buildings,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd), 2)          AS cost_usd
FROM    daily_reading dr
JOIN    meter m            ON m.meter_id = dr.meter_id
JOIN    tariff_rate tr     ON tr.utility_type_id = m.utility_type_id
                          AND tr.rate_month = DATE_FORMAT(dr.reading_date, '%Y-%m-01')
JOIN    building b         ON b.building_id = m.building_id
JOIN    space_usage su     ON su.space_usage_id = b.space_usage_id
JOIN    space_usage parent ON parent.space_usage_id = su.parent_usage_id
GROUP BY parent.usage_name, su.usage_name WITH ROLLUP;

-- ---------------------------------------------------------------------

-- 6b. Index hypothesis H1: covering index on Q1's per-meter lookup path
CREATE INDEX idx_dr_meter_date_kwh ON daily_reading (meter_id, reading_date, consumption_kwh);
ANALYZE TABLE daily_reading;
SHOW INDEX FROM daily_reading;

-- Re-run after the index. RDS result: optimizer still chose PRIMARY (index unused);
--   rows examined unchanged (28,336); median 42.4 ms (within baseline spread).
EXPLAIN ANALYZE
SELECT  b.building_name,
        parent.usage_name                             AS primary_usage,
        su.usage_name                                 AS sub_usage,
        b.gross_sqm,
        COUNT(DISTINCT m.meter_id)                    AS meters,
        ROUND(SUM(dr.consumption_kwh), 0)             AS total_kwh,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd), 2)                AS total_cost_usd,
        ROUND(SUM(dr.consumption_kwh * tr.unit_rate_usd) / b.gross_sqm, 2)  AS cost_per_sqm_usd
FROM    daily_reading dr
JOIN    meter        m      ON m.meter_id         = dr.meter_id
JOIN    utility_type ut     ON ut.utility_type_id = m.utility_type_id
JOIN    tariff_rate  tr     ON tr.utility_type_id = m.utility_type_id
                           AND tr.rate_month      = '2017-08-01'
JOIN    building     b      ON b.building_id      = m.building_id
JOIN    space_usage  su     ON su.space_usage_id  = b.space_usage_id
JOIN    space_usage  parent ON parent.space_usage_id = su.parent_usage_id
WHERE   dr.reading_date >= '2017-08-01' AND dr.reading_date < '2017-09-01'
GROUP BY b.building_id, b.building_name, parent.usage_name, su.usage_name, b.gross_sqm
HAVING  SUM(dr.consumption_kwh) > 0
ORDER BY cost_per_sqm_usd DESC
LIMIT 10;

-- ---------------------------------------------------------------------

DROP INDEX idx_dr_meter_date_kwh ON daily_reading;

-- Alternative hypotheses tested the same way (results on RDS, Q1 median):
--   H2: CREATE INDEX idx_dr_date_meter_kwh ON daily_reading (reading_date, meter_id, consumption_kwh);
--       -> unused, 41.7 ms.   DROP INDEX idx_dr_date_meter_kwh ON daily_reading;
--   H3: CREATE INDEX idx_tr_month_utility ON tariff_rate (rate_month, utility_type_id, unit_rate_usd);
--       -> join reordered (tr table scan -> single-row lookup), dr unchanged, 42.0 ms.
--          DROP INDEX idx_tr_month_utility ON tariff_rate;
-- Decision (D-016): no index retained; no measured read benefit, added write cost.
-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
