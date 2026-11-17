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
