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
