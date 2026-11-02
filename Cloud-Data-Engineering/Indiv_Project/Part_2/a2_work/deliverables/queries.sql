-- =====================================================================
-- Assignment 2 — Part 5: Business queries (campus_energy, MySQL 8.4 on RDS)
-- Data: BDG2 Bull site (UT Austin), 308 meters, daily, 2017-07-01..2017-09-30
-- Cost = consumption_kwh x tariff_rate.unit_rate_usd for the reading's month.
-- =====================================================================
USE campus_energy;

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
