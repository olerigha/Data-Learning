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
