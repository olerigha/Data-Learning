/***********************************************
** Name:        ClassicModels Sales Star Schema (SCD Type 2)
** Description: Star schema where dim_customer, dim_product and dim_salesperson
**              keep history. A changed attribute expires the current row and
**              inserts a new version. The fact joins to the dimension version
**              that was valid on the order date (as-of join).
**              Grain of the fact: one row per order line.
** Requires:    MySQL 8.0+ (recursive CTE), source schema `classicmodels`
** Schema:      classicmodelsdw_t2 (does not touch classicmodels or classicmodelsdw)
** Counterpart: classicmodelsdw.sql is the Type 1 (current values only) version
**              of this model. Both use surrogate keys and keep the source key
**              as a unique/business-key column.
** Re-runnable: yes. Run it again after the source changes to capture history.
** Author:      Ashish Pujari
**
** Type 2 conventions
**   effective_from : first version = 1900-01-01 (so every historical fact
**                    finds a row); later versions = date the change was loaded
**   effective_to   : 9999-12-31 for the current version, otherwise the day
**                    before the next version starts
**   is_current     : 1 for the open version of each business key
**   row_hash       : MD5 of all tracked attributes, used to detect changes
** dim_date and dim_order_status stay Type 1 (calendar and codes do not change).
** Note: two changes to the same key on the same load date are collapsed
**       into one version, because history granularity is one day.
************************************************/

SET @OLD_SQL_MODE=@@SQL_MODE;
SET SQL_MODE=CONCAT(@@SQL_MODE, ',NO_AUTO_VALUE_ON_ZERO');
SET @OLD_SQL_SAFE_UPDATES=@@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES=0;
SET SESSION cte_max_recursion_depth = 20000;

CREATE SCHEMA IF NOT EXISTS `classicmodelsdw_t2` DEFAULT CHARACTER SET utf8mb4;
USE `classicmodelsdw_t2`;

-- -----------------------------------------------------
-- dim_date (Type 1; key 0 = Unknown / not yet happened)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_date (
    date_key      INT          NOT NULL,
    full_date     DATE         NULL,
    day_of_month  TINYINT      NULL,
    day_name      VARCHAR(10)  NOT NULL,
    day_of_week   TINYINT      NULL COMMENT '1=Monday ... 7=Sunday',
    iso_week      TINYINT      NULL,
    iso_year      SMALLINT     NULL,
    month_num     TINYINT      NULL,
    month_name    VARCHAR(10)  NOT NULL,
    quarter_num   TINYINT      NULL,
    year_num      SMALLINT     NULL,
    is_weekend    TINYINT(1)   NOT NULL DEFAULT 0,
    PRIMARY KEY (date_key),
    UNIQUE KEY uq_dim_date_full_date (full_date),
    KEY ix_dim_date_year_month (year_num, month_num)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- dim_customer (Type 2)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key              INT          NOT NULL AUTO_INCREMENT,
    customer_number           INT          NOT NULL COMMENT 'source business key (repeats across versions)',
    customer_name             VARCHAR(50)  NOT NULL,
    contact_last_name         VARCHAR(50)  NOT NULL,
    contact_first_name        VARCHAR(50)  NOT NULL,
    phone                     VARCHAR(50)  NOT NULL,
    address_line1             VARCHAR(50)  NOT NULL,
    address_line2             VARCHAR(50)  NULL,
    city                      VARCHAR(50)  NOT NULL,
    state                     VARCHAR(50)  NULL,
    postal_code               VARCHAR(15)  NULL,
    country                   VARCHAR(50)  NOT NULL,
    credit_limit              DECIMAL(10,2) NULL,
    sales_rep_employee_number INT          NULL,
    row_hash                  CHAR(32)     NOT NULL,
    effective_from            DATE         NOT NULL,
    effective_to              DATE         NOT NULL DEFAULT '9999-12-31',
    is_current                TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (customer_key),
    KEY ix_dim_customer_bk (customer_number, effective_from, effective_to),
    KEY ix_dim_customer_current (customer_number, is_current)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- dim_product (Type 2)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_product (
    product_key              INT           NOT NULL AUTO_INCREMENT,
    product_code             VARCHAR(15)   NOT NULL COMMENT 'source business key (repeats across versions)',
    product_name             VARCHAR(70)   NOT NULL,
    product_line             VARCHAR(50)   NOT NULL,
    product_line_description VARCHAR(4000) NULL,
    product_scale            VARCHAR(10)   NOT NULL,
    product_vendor           VARCHAR(50)   NOT NULL,
    product_description      TEXT          NOT NULL,
    buy_price                DECIMAL(10,2) NOT NULL,
    msrp                     DECIMAL(10,2) NOT NULL,
    row_hash                 CHAR(32)      NOT NULL,
    effective_from           DATE          NOT NULL,
    effective_to             DATE          NOT NULL DEFAULT '9999-12-31',
    is_current               TINYINT(1)    NOT NULL DEFAULT 1,
    PRIMARY KEY (product_key),
    KEY ix_dim_product_bk (product_code, effective_from, effective_to),
    KEY ix_dim_product_current (product_code, is_current),
    KEY ix_dim_product_line (product_line)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- dim_salesperson (Type 2; key 0 = Unassigned)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_salesperson (
    salesperson_key INT          NOT NULL AUTO_INCREMENT,
    employee_number INT          NOT NULL COMMENT 'source business key; -1 = Unassigned',
    last_name       VARCHAR(50)  NOT NULL,
    first_name      VARCHAR(50)  NOT NULL,
    full_name       VARCHAR(101) NOT NULL,
    job_title       VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NULL,
    office_city     VARCHAR(50)  NULL,
    office_state    VARCHAR(50)  NULL,
    office_country  VARCHAR(50)  NULL,
    territory       VARCHAR(10)  NULL,
    manager_name    VARCHAR(101) NULL,
    row_hash        CHAR(32)     NOT NULL,
    effective_from  DATE         NOT NULL,
    effective_to    DATE         NOT NULL DEFAULT '9999-12-31',
    is_current      TINYINT(1)   NOT NULL DEFAULT 1,
    PRIMARY KEY (salesperson_key),
    KEY ix_dim_salesperson_bk (employee_number, effective_from, effective_to),
    KEY ix_dim_salesperson_current (employee_number, is_current)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- dim_order_status (Type 1)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS dim_order_status (
    status_key  INT         NOT NULL AUTO_INCREMENT,
    status_name VARCHAR(15) NOT NULL,
    PRIMARY KEY (status_key),
    UNIQUE KEY uq_dim_order_status (status_name)
) ENGINE=InnoDB;

-- -----------------------------------------------------
-- fact_sales_order_line
-- Grain: one row per (order_number, order_line_number)
-- Dimension keys point at the dimension VERSION valid on the order date.
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS fact_sales_order_line (
    sales_line_key     BIGINT        NOT NULL AUTO_INCREMENT,
    order_date_key     INT           NOT NULL,
    required_date_key  INT           NOT NULL,
    shipped_date_key   INT           NOT NULL DEFAULT 0 COMMENT '0 = not shipped yet',
    customer_key       INT           NOT NULL,
    product_key        INT           NOT NULL,
    salesperson_key    INT           NOT NULL DEFAULT 0 COMMENT '0 = Unassigned',
    status_key         INT           NOT NULL,
    order_number       INT           NOT NULL COMMENT 'degenerate dimension',
    order_line_number  SMALLINT      NOT NULL COMMENT 'degenerate dimension',
    quantity_ordered   INT           NOT NULL,
    unit_price         DECIMAL(10,2) NOT NULL COMMENT 'non-additive',
    line_sales_amount  DECIMAL(12,2) NOT NULL COMMENT 'quantity * unit_price',
    unit_cost          DECIMAL(10,2) NOT NULL COMMENT 'buy price of the product version valid on the order date',
    line_cost          DECIMAL(12,2) NOT NULL,
    line_margin        DECIMAL(12,2) NOT NULL,
    PRIMARY KEY (sales_line_key),
    UNIQUE KEY uq_fact_order_line (order_number, order_line_number),
    CONSTRAINT fk_fact_order_date    FOREIGN KEY (order_date_key)    REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_required_date FOREIGN KEY (required_date_key) REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_shipped_date  FOREIGN KEY (shipped_date_key)  REFERENCES dim_date (date_key),
    CONSTRAINT fk_fact_customer      FOREIGN KEY (customer_key)      REFERENCES dim_customer (customer_key),
    CONSTRAINT fk_fact_product       FOREIGN KEY (product_key)       REFERENCES dim_product (product_key),
    CONSTRAINT fk_fact_salesperson   FOREIGN KEY (salesperson_key)   REFERENCES dim_salesperson (salesperson_key),
    CONSTRAINT fk_fact_status        FOREIGN KEY (status_key)        REFERENCES dim_order_status (status_key)
) ENGINE=InnoDB;

-- =====================================================
-- STAGING VIEWS: source projection + change-detection hash
-- =====================================================
CREATE OR REPLACE VIEW stg_customer AS
SELECT customerNumber AS customer_number, customerName AS customer_name,
       contactLastName AS contact_last_name, contactFirstName AS contact_first_name,
       phone, addressLine1 AS address_line1, addressLine2 AS address_line2,
       city, state, postalCode AS postal_code, country,
       creditLimit AS credit_limit, salesRepEmployeeNumber AS sales_rep_employee_number,
       MD5(CONCAT_WS('|',
           COALESCE(customerName, ''), COALESCE(contactLastName, ''), COALESCE(contactFirstName, ''),
           COALESCE(phone, ''), COALESCE(addressLine1, ''), COALESCE(addressLine2, ''),
           COALESCE(city, ''), COALESCE(state, ''), COALESCE(postalCode, ''), COALESCE(country, ''),
           COALESCE(creditLimit, ''), COALESCE(salesRepEmployeeNumber, ''))) AS row_hash
FROM classicmodels.customers;

CREATE OR REPLACE VIEW stg_product AS
SELECT p.productCode AS product_code, p.productName AS product_name,
       p.productLine AS product_line, pl.textDescription AS product_line_description,
       p.productScale AS product_scale, p.productVendor AS product_vendor,
       p.productDescription AS product_description, p.buyPrice AS buy_price, p.MSRP AS msrp,
       MD5(CONCAT_WS('|',
           COALESCE(p.productName, ''), COALESCE(p.productLine, ''), COALESCE(pl.textDescription, ''),
           COALESCE(p.productScale, ''), COALESCE(p.productVendor, ''), COALESCE(p.productDescription, ''),
           COALESCE(p.buyPrice, ''), COALESCE(p.MSRP, ''))) AS row_hash
FROM classicmodels.products p
JOIN classicmodels.productlines pl ON pl.productLine = p.productLine;

CREATE OR REPLACE VIEW stg_salesperson AS
SELECT e.employeeNumber AS employee_number, e.lastName AS last_name, e.firstName AS first_name,
       CONCAT(e.firstName, ' ', e.lastName) AS full_name, e.jobTitle AS job_title, e.email,
       o.city AS office_city, o.state AS office_state, o.country AS office_country,
       o.territory, CONCAT(m.firstName, ' ', m.lastName) AS manager_name,
       MD5(CONCAT_WS('|',
           COALESCE(e.lastName, ''), COALESCE(e.firstName, ''), COALESCE(e.jobTitle, ''),
           COALESCE(e.email, ''), COALESCE(o.city, ''), COALESCE(o.state, ''),
           COALESCE(o.country, ''), COALESCE(o.territory, ''),
           COALESCE(CONCAT(m.firstName, ' ', m.lastName), ''))) AS row_hash
FROM classicmodels.employees e
LEFT JOIN classicmodels.offices   o ON o.officeCode = e.officeCode
LEFT JOIN classicmodels.employees m ON m.employeeNumber = e.reportsTo;

-- =====================================================
-- LOAD: Unknown members
-- =====================================================
INSERT INTO dim_date (date_key, full_date, day_name, month_name, is_weekend)
VALUES (0, NULL, 'Unknown', 'Unknown', 0)
ON DUPLICATE KEY UPDATE day_name = VALUES(day_name);

INSERT INTO dim_salesperson
    (salesperson_key, employee_number, last_name, first_name, full_name, job_title,
     row_hash, effective_from, effective_to, is_current)
VALUES (0, -1, 'Unassigned', 'Unassigned', 'Unassigned', 'Unassigned',
        'unknown', '1900-01-01', '9999-12-31', 1)
ON DUPLICATE KEY UPDATE full_name = VALUES(full_name);

-- =====================================================
-- LOAD: dim_date (Type 1) from the years present in the source orders
-- =====================================================
SET @min_year = (SELECT MIN(YEAR(LEAST(orderDate, requiredDate, COALESCE(shippedDate, orderDate))))
                 FROM classicmodels.orders);
SET @max_year = (SELECT MAX(YEAR(GREATEST(orderDate, requiredDate, COALESCE(shippedDate, orderDate))))
                 FROM classicmodels.orders);

INSERT INTO dim_date
    (date_key, full_date, day_of_month, day_name, day_of_week, iso_week, iso_year,
     month_num, month_name, quarter_num, year_num, is_weekend)
WITH RECURSIVE d (dt) AS (
    SELECT MAKEDATE(@min_year, 1)
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY)
    FROM d
    WHERE dt < DATE_SUB(MAKEDATE(@max_year + 1, 1), INTERVAL 1 DAY)
)
SELECT CAST(DATE_FORMAT(dt, '%Y%m%d') AS UNSIGNED),
       dt, DAYOFMONTH(dt), DAYNAME(dt), WEEKDAY(dt) + 1, WEEK(dt, 3),
       YEARWEEK(dt, 3) DIV 100, MONTH(dt), MONTHNAME(dt), QUARTER(dt), YEAR(dt),
       WEEKDAY(dt) >= 5
FROM d
ON DUPLICATE KEY UPDATE date_key = date_key;

INSERT INTO dim_order_status (status_name)
SELECT DISTINCT status FROM classicmodels.orders
ON DUPLICATE KEY UPDATE status_name = VALUES(status_name);

-- =====================================================
-- LOAD: Type 2 dimensions. Step A expires changed rows, step B inserts
-- new versions (brand-new keys and changed keys).
-- =====================================================

-- ---- dim_customer ----
UPDATE dim_customer d
JOIN stg_customer s ON s.customer_number = d.customer_number
SET d.effective_to = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY),
    d.is_current   = 0
WHERE d.is_current = 1
  AND d.row_hash <> s.row_hash;

INSERT INTO dim_customer
    (customer_number, customer_name, contact_last_name, contact_first_name, phone,
     address_line1, address_line2, city, state, postal_code, country,
     credit_limit, sales_rep_employee_number, row_hash,
     effective_from, effective_to, is_current)
SELECT s.customer_number, s.customer_name, s.contact_last_name, s.contact_first_name, s.phone,
       s.address_line1, s.address_line2, s.city, s.state, s.postal_code, s.country,
       s.credit_limit, s.sales_rep_employee_number, s.row_hash,
       CASE WHEN prev.customer_number IS NULL THEN DATE '1900-01-01' ELSE CURRENT_DATE END,
       DATE '9999-12-31', 1
FROM stg_customer s
LEFT JOIN dim_customer cur
       ON cur.customer_number = s.customer_number AND cur.is_current = 1
LEFT JOIN (SELECT DISTINCT customer_number FROM dim_customer) prev
       ON prev.customer_number = s.customer_number
WHERE cur.customer_key IS NULL;

-- ---- dim_product ----
UPDATE dim_product d
JOIN stg_product s ON s.product_code = d.product_code
SET d.effective_to = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY),
    d.is_current   = 0
WHERE d.is_current = 1
  AND d.row_hash <> s.row_hash;

INSERT INTO dim_product
    (product_code, product_name, product_line, product_line_description,
     product_scale, product_vendor, product_description, buy_price, msrp,
     row_hash, effective_from, effective_to, is_current)
SELECT s.product_code, s.product_name, s.product_line, s.product_line_description,
       s.product_scale, s.product_vendor, s.product_description, s.buy_price, s.msrp,
       s.row_hash,
       CASE WHEN prev.product_code IS NULL THEN DATE '1900-01-01' ELSE CURRENT_DATE END,
       DATE '9999-12-31', 1
FROM stg_product s
LEFT JOIN dim_product cur
       ON cur.product_code = s.product_code AND cur.is_current = 1
LEFT JOIN (SELECT DISTINCT product_code FROM dim_product) prev
       ON prev.product_code = s.product_code
WHERE cur.product_key IS NULL;

-- ---- dim_salesperson ----
UPDATE dim_salesperson d
JOIN stg_salesperson s ON s.employee_number = d.employee_number
SET d.effective_to = DATE_SUB(CURRENT_DATE, INTERVAL 1 DAY),
    d.is_current   = 0
WHERE d.is_current = 1
  AND d.row_hash <> s.row_hash;

INSERT INTO dim_salesperson
    (employee_number, last_name, first_name, full_name, job_title, email,
     office_city, office_state, office_country, territory, manager_name,
     row_hash, effective_from, effective_to, is_current)
SELECT s.employee_number, s.last_name, s.first_name, s.full_name, s.job_title, s.email,
       s.office_city, s.office_state, s.office_country, s.territory, s.manager_name,
       s.row_hash,
       CASE WHEN prev.employee_number IS NULL THEN DATE '1900-01-01' ELSE CURRENT_DATE END,
       DATE '9999-12-31', 1
FROM stg_salesperson s
LEFT JOIN dim_salesperson cur
       ON cur.employee_number = s.employee_number AND cur.is_current = 1
LEFT JOIN (SELECT DISTINCT employee_number FROM dim_salesperson) prev
       ON prev.employee_number = s.employee_number
WHERE cur.salesperson_key IS NULL;

-- =====================================================
-- LOAD: fact (as-of join to the dimension version valid on the order date;
-- upsert on the order-line natural key so reruns create no duplicates)
-- =====================================================
INSERT INTO fact_sales_order_line
    (order_date_key, required_date_key, shipped_date_key,
     customer_key, product_key, salesperson_key, status_key,
     order_number, order_line_number,
     quantity_ordered, unit_price, line_sales_amount, unit_cost, line_cost, line_margin)
SELECT CAST(DATE_FORMAT(o.orderDate,    '%Y%m%d') AS UNSIGNED),
       CAST(DATE_FORMAT(o.requiredDate, '%Y%m%d') AS UNSIGNED),
       COALESCE(CAST(DATE_FORMAT(o.shippedDate, '%Y%m%d') AS UNSIGNED), 0),
       dc.customer_key,
       dp.product_key,
       COALESCE(ds.salesperson_key, 0),
       st.status_key,
       od.orderNumber,
       od.orderLineNumber,
       od.quantityOrdered,
       od.priceEach,
       od.quantityOrdered * od.priceEach,
       dp.buy_price,
       od.quantityOrdered * dp.buy_price,
       od.quantityOrdered * (od.priceEach - dp.buy_price)
FROM classicmodels.orders o
JOIN classicmodels.orderdetails od ON od.orderNumber = o.orderNumber
JOIN classicmodels.customers    c  ON c.customerNumber = o.customerNumber
JOIN dim_customer dc
     ON dc.customer_number = o.customerNumber
    AND o.orderDate BETWEEN dc.effective_from AND dc.effective_to
JOIN dim_product dp
     ON dp.product_code = od.productCode
    AND o.orderDate BETWEEN dp.effective_from AND dp.effective_to
JOIN dim_order_status st ON st.status_name = o.status
LEFT JOIN dim_salesperson ds
     ON ds.employee_number = c.salesRepEmployeeNumber
    AND o.orderDate BETWEEN ds.effective_from AND ds.effective_to
ON DUPLICATE KEY UPDATE
    order_date_key    = VALUES(order_date_key),
    required_date_key = VALUES(required_date_key),
    shipped_date_key  = VALUES(shipped_date_key),
    customer_key      = VALUES(customer_key),
    product_key       = VALUES(product_key),
    salesperson_key   = VALUES(salesperson_key),
    status_key        = VALUES(status_key),
    quantity_ordered  = VALUES(quantity_ordered),
    unit_price        = VALUES(unit_price),
    line_sales_amount = VALUES(line_sales_amount),
    unit_cost         = VALUES(unit_cost),
    line_cost         = VALUES(line_cost),
    line_margin       = VALUES(line_margin);

-- =====================================================
-- VALIDATE
-- =====================================================
SELECT 'fact rows vs source order lines' AS check_name,
       (SELECT COUNT(*) FROM fact_sales_order_line)       AS dw_value,
       (SELECT COUNT(*) FROM classicmodels.orderdetails)  AS source_value;

SELECT 'total sales amount' AS check_name,
       (SELECT SUM(line_sales_amount) FROM fact_sales_order_line)                AS dw_value,
       (SELECT SUM(quantityOrdered * priceEach) FROM classicmodels.orderdetails) AS source_value;

SELECT 'exactly one current row per customer' AS check_name,
       (SELECT COUNT(*) FROM (SELECT customer_number FROM dim_customer
                              WHERE is_current = 1 GROUP BY customer_number
                              HAVING COUNT(*) <> 1) x) AS violations;

-- ---- Demo: see Type 2 in action (run manually, then rerun this script) ----
-- UPDATE classicmodels.customers SET city = 'Boston', state = 'MA' WHERE customerNumber = 103;
-- (rerun script)
-- SELECT customer_key, customer_number, city, effective_from, effective_to, is_current
-- FROM classicmodelsdw_t2.dim_customer WHERE customer_number = 103 ORDER BY effective_from;
-- Orders placed before today still point at the old city; the dimension keeps both versions.

SET SQL_SAFE_UPDATES=@OLD_SQL_SAFE_UPDATES;
SET SQL_MODE=@OLD_SQL_MODE;
