-- Generated from deliverables/queries.sql (identical query text). Each EXPLAIN ANALYZE runs 3x; report the median.
USE campus_energy;
SELECT VERSION() AS server_version, NOW() AS run_at;
SHOW INDEX FROM daily_reading;
SELECT '=== Q1 BEFORE run 1 ===' AS marker;
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
SELECT '=== Q1 BEFORE run 2 ===' AS marker;
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
SELECT '=== Q1 BEFORE run 3 ===' AS marker;
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
SELECT '=== Q5 BEFORE run 1 ===' AS marker;
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
SELECT '=== Q5 BEFORE run 2 ===' AS marker;
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
SELECT '=== Q5 BEFORE run 3 ===' AS marker;
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
