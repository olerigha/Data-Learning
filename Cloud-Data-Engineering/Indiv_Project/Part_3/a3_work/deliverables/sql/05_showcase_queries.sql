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
