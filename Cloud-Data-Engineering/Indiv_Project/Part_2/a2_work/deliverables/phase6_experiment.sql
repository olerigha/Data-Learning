-- Phase 6 experiment (self-contained, order-safe). Generated from deliverables/queries.sql.
USE campus_energy;
SELECT VERSION() AS server_version, NOW() AS run_at_utc;
SET @n := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_energy' AND TABLE_NAME='daily_reading' AND INDEX_NAME='idx_dr_meter_date_kwh');
SET @s := IF(@n > 0, 'DROP INDEX idx_dr_meter_date_kwh ON daily_reading', 'DO 0');
PREPARE p FROM @s; EXECUTE p; DEALLOCATE PREPARE p;

SET @n := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_energy' AND TABLE_NAME='daily_reading' AND INDEX_NAME='idx_dr_date_meter_kwh');
SET @s := IF(@n > 0, 'DROP INDEX idx_dr_date_meter_kwh ON daily_reading', 'DO 0');
PREPARE p FROM @s; EXECUTE p; DEALLOCATE PREPARE p;

SET @n := (SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA='campus_energy' AND TABLE_NAME='tariff_rate' AND INDEX_NAME='idx_tr_month_utility');
SET @s := IF(@n > 0, 'DROP INDEX idx_tr_month_utility ON tariff_rate', 'DO 0');
PREPARE p FROM @s; EXECUTE p; DEALLOCATE PREPARE p;

SELECT '=== BASELINE: indexes on daily_reading and tariff_rate ===' AS marker;
SHOW INDEX FROM daily_reading;
SHOW INDEX FROM tariff_rate;
SELECT '=== Q1 BASELINE run 1 ===' AS marker;
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
SELECT '=== Q1 BASELINE run 2 ===' AS marker;
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
SELECT '=== Q1 BASELINE run 3 ===' AS marker;
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

SELECT '=== Q5 BASELINE run 1 ===' AS marker;
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
SELECT '=== Q5 BASELINE run 2 ===' AS marker;
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
SELECT '=== Q5 BASELINE run 3 ===' AS marker;
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

-- H1: covering index on the per-meter lookup path
SELECT '=== H1: CREATE INDEX idx_dr_meter_date_kwh ON daily_reading (meter_id, reading_date, consumption_kwh) ===' AS marker;
CREATE INDEX idx_dr_meter_date_kwh ON daily_reading (meter_id, reading_date, consumption_kwh);
ANALYZE TABLE daily_reading;
SELECT '=== Q1 H1 run 1 ===' AS marker;
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
SELECT '=== Q1 H1 run 2 ===' AS marker;
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
SELECT '=== Q1 H1 run 3 ===' AS marker;
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

SELECT '=== Q5 H1 run 1 ===' AS marker;
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

DROP INDEX idx_dr_meter_date_kwh ON daily_reading;
-- H2: date-leading covering index so the Aug range can drive the join
SELECT '=== H2: CREATE INDEX idx_dr_date_meter_kwh ON daily_reading (reading_date, meter_id, consumption_kwh) ===' AS marker;
CREATE INDEX idx_dr_date_meter_kwh ON daily_reading (reading_date, meter_id, consumption_kwh);
ANALYZE TABLE daily_reading;
SELECT '=== Q1 H2 run 1 ===' AS marker;
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
SELECT '=== Q1 H2 run 2 ===' AS marker;
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
SELECT '=== Q1 H2 run 3 ===' AS marker;
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

SELECT '=== Q5 H2 run 1 ===' AS marker;
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

DROP INDEX idx_dr_date_meter_kwh ON daily_reading;
-- H3: covering index for the constant month filter on tariff_rate
SELECT '=== H3: CREATE INDEX idx_tr_month_utility ON tariff_rate (rate_month, utility_type_id, unit_rate_usd) ===' AS marker;
CREATE INDEX idx_tr_month_utility ON tariff_rate (rate_month, utility_type_id, unit_rate_usd);
ANALYZE TABLE tariff_rate;
SELECT '=== Q1 H3 run 1 ===' AS marker;
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
SELECT '=== Q1 H3 run 2 ===' AS marker;
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
SELECT '=== Q1 H3 run 3 ===' AS marker;
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


DROP INDEX idx_tr_month_utility ON tariff_rate;
SELECT '=== END: indexes restored to baseline ===' AS marker;
SHOW INDEX FROM daily_reading;
SHOW INDEX FROM tariff_rate;
