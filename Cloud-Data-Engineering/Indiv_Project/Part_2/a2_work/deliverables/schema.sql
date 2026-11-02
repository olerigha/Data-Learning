-- =====================================================================
-- Assignment 2 — Campus Energy Monitoring Platform (evolves A1)
-- Part 3: MySQL 8.0 DDL for the 3NF schema (9 tables)
-- Source data: BDG2 Bull site (UT Austin) + EIA-861M TX commercial prices
-- Engine: InnoDB, utf8mb4. CHECK constraints require MySQL >= 8.0.16.
-- Re-runnable: drops and recreates the schema objects in FK-safe order.
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

-- Verification: row counts per table (run after load)
-- SELECT 'site' t, COUNT(*) n FROM site UNION ALL SELECT 'space_usage', COUNT(*) FROM space_usage
-- UNION ALL SELECT 'building', COUNT(*) FROM building UNION ALL SELECT 'utility_type', COUNT(*) FROM utility_type
-- UNION ALL SELECT 'meter', COUNT(*) FROM meter UNION ALL SELECT 'daily_reading', COUNT(*) FROM daily_reading
-- UNION ALL SELECT 'weather_daily', COUNT(*) FROM weather_daily UNION ALL SELECT 'eia_price_monthly', COUNT(*) FROM eia_price_monthly
-- UNION ALL SELECT 'tariff_rate', COUNT(*) FROM tariff_rate;
