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
