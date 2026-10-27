/***********************************************
** Name:        ClassicModels Data Warehouse Schema
** Description: Dimensional (star/snowflake) schema for ClassicModels; used to support analytical and reporting workloads
** Author:      Ashish Pujari
**
** Requires:    MySQL 8.0+ (recursive CTE) and the source schema `classicmodels`
** Grain:       factOrderDetails = one row per order line (orderNumber, orderLineNumber)
** Keys:        Every dimension has a surrogate primary key (customerKey,
**              employeeKey, productKey); the source key is kept as a UNIQUE
**              column. The fact table references the surrogate keys.
** History:     Type 1 (current values only). See classicmodelsdw_star_type2.sql
**              for the Type 2 (history-keeping) version.
**
** WARNING:     This script DROPs and rebuilds the `classicmodelsdw` schema on
**              every run. Anything stored in that schema is lost. It never
**              modifies `classicmodels`.
************************************************/

-- Session settings (original values are restored at the end of the script)
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
-- NO_AUTO_VALUE_ON_ZERO lets us insert the reserved Unknown row with key 0
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=CONCAT(@@SQL_MODE, ',NO_AUTO_VALUE_ON_ZERO');

-- -----------------------------------------------------
-- Schema classicmodelsdw
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `classicmodelsdw`;

CREATE SCHEMA `classicmodelsdw` DEFAULT CHARACTER SET utf8mb4;
USE `classicmodelsdw`;

-- -----------------------------------------------------
-- Table `dimCustomers`
-- -----------------------------------------------------
CREATE TABLE `dimCustomers` (
    `customerKey` INT NOT NULL AUTO_INCREMENT,
    `customerNumber` INT NOT NULL COMMENT 'source business key',
    `customerName` VARCHAR(50) NOT NULL,
    `contactLastName` VARCHAR(50) NOT NULL,
    `contactFirstName` VARCHAR(50) NOT NULL,
    `phone` VARCHAR(50) NOT NULL,
    `addressLine1` VARCHAR(50) NOT NULL,
    `addressLine2` VARCHAR(50) NULL DEFAULT NULL,
    `city` VARCHAR(50) NOT NULL,
    `state` VARCHAR(50) NULL DEFAULT NULL,
    `postalCode` VARCHAR(15) NULL DEFAULT NULL,
    `country` VARCHAR(50) NOT NULL,
    `salesRepEmployeeNumber` INT NULL DEFAULT NULL,
    `creditLimit` DECIMAL(10,2) NULL DEFAULT NULL,
    PRIMARY KEY (`customerKey`),
    UNIQUE INDEX `uq_dimCustomers_customerNumber` (`customerNumber`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `dimEmployees`
-- managerName is flattened in so BI tools do not need a self-join.
-- employeeKey 0 is the reserved "Unassigned" member (customers with no rep).
-- -----------------------------------------------------
CREATE TABLE `dimEmployees` (
    `employeeKey` INT NOT NULL AUTO_INCREMENT,
    `employeeNumber` INT NOT NULL COMMENT 'source business key; -1 = Unassigned',
    `lastName` VARCHAR(50) NOT NULL,
    `firstName` VARCHAR(50) NOT NULL,
    `extension` VARCHAR(10) NOT NULL,
    `email` VARCHAR(100) NOT NULL,
    `officeCode` VARCHAR(10) NOT NULL,
    `reportsTo` INT DEFAULT NULL,
    `managerName` VARCHAR(101) DEFAULT NULL,
    `jobTitle` VARCHAR(50) NOT NULL,
    `city` VARCHAR(50) DEFAULT NULL,
    `state` VARCHAR(50) DEFAULT NULL,
    `country` VARCHAR(50) DEFAULT NULL,
    `postalCode` VARCHAR(15) DEFAULT NULL,
    `territory` VARCHAR(10) DEFAULT NULL,
    PRIMARY KEY (`employeeKey`),
    UNIQUE INDEX `uq_dimEmployees_employeeNumber` (`employeeNumber`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `dimProducts`
-- quantityInStock is a current-inventory snapshot. It is kept here and also
-- on factOrderDetails (stock level at load time) for the Tableau workbook.
-- -----------------------------------------------------
CREATE TABLE `dimProducts` (
    `productKey` INT NOT NULL AUTO_INCREMENT,
    `productCode` VARCHAR(15) NOT NULL COMMENT 'source business key',
    `productName` VARCHAR(70) NOT NULL,
    `productLine` VARCHAR(50) NOT NULL,
    `productScale` VARCHAR(10) NOT NULL,
    `productVendor` VARCHAR(50) NOT NULL,
    `productDescription` TEXT NOT NULL,
    `quantityInStock` SMALLINT NOT NULL,
    `buyPrice` DECIMAL(10,2) NOT NULL,
    `MSRP` DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (`productKey`),
    UNIQUE INDEX `uq_dimProducts_productCode` (`productCode`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `dimtime`
-- dateId is the dimension's own key (days since the first calendar date),
-- not a source key, so it is already a surrogate.
-- -----------------------------------------------------
CREATE TABLE `dimtime` (
    `dateId` BIGINT NOT NULL,
    `date` DATE NOT NULL,
    `timestamp` BIGINT NULL DEFAULT NULL,
    `weekend` CHAR(10) NOT NULL DEFAULT 'Weekday',
    `day_of_week` CHAR(10) NULL DEFAULT NULL,
    `month` CHAR(10) NULL DEFAULT NULL,
    `month_day` INT NULL DEFAULT NULL,
    `year` INT NULL DEFAULT NULL,
    `week_starting_monday` CHAR(2) NULL DEFAULT NULL,
    PRIMARY KEY (`dateId`),
    UNIQUE INDEX `date` (`date`),
    INDEX `year_week` (`year`, `week_starting_monday`)
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Table `factOrderDetails`
-- Foreign keys use the surrogate keys. customerNumber, productCode and
-- employeeNumber are kept as plain (non-FK) columns so the existing Tableau
-- workbook, which joins on them, keeps working. New queries should join on
-- the surrogate keys. Drop those three columns if you do not need them.
-- -----------------------------------------------------
CREATE TABLE `factOrderDetails` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `orderNumber` INT NOT NULL,
    `orderLineNumber` SMALLINT NOT NULL,
    `productKey` INT NOT NULL,
    `customerKey` INT NOT NULL,
    `employeeKey` INT NOT NULL DEFAULT 0 COMMENT '0 = Unassigned',
    `productCode` VARCHAR(15) NOT NULL COMMENT 'source key, kept for Tableau',
    `customerNumber` INT NOT NULL COMMENT 'source key, kept for Tableau',
    `employeeNumber` INT NULL DEFAULT NULL COMMENT 'source key, kept for Tableau',
    `orderDateId` BIGINT NOT NULL,
    `requiredDateId` BIGINT DEFAULT NULL,
    `shippedDateId` BIGINT DEFAULT NULL,
    `quantityOrdered` INT NULL,
    `quantityInStock` SMALLINT NULL COMMENT 'product stock level at load time (snapshot, non-additive)',
    `priceEach` DECIMAL(10,2) NOT NULL,
    `lineTotal` DECIMAL(12,2) NOT NULL COMMENT 'quantityOrdered * priceEach',
    `status` VARCHAR(15) NULL,
    PRIMARY KEY (`id`),
    UNIQUE INDEX `uq_factOrderDetails_orderLine` (`orderNumber`, `orderLineNumber`),
    INDEX `fk_factOrderDetails_dimProducts_idx` (`productKey`),
    INDEX `fk_factOrderDetails_dimCustomers_idx` (`customerKey`),
    INDEX `fk_factOrderDetails_dimEmployees_idx` (`employeeKey`),
    INDEX `fk_factOrderDetails_dimTime_idx1` (`orderDateId`),
    INDEX `fk_factOrderDetails_dimTime_idx2` (`requiredDateId`),
    INDEX `fk_factOrderDetails_dimTime_idx3` (`shippedDateId`),
    CONSTRAINT `fk_factOrderDetails_dimProducts` FOREIGN KEY (`productKey`)
        REFERENCES `dimProducts` (`productKey`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_factOrderDetails_dimCustomers` FOREIGN KEY (`customerKey`)
        REFERENCES `dimCustomers` (`customerKey`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_factOrderDetails_dimEmployees` FOREIGN KEY (`employeeKey`)
        REFERENCES `dimEmployees` (`employeeKey`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_factOrderDetails_dimTime1` FOREIGN KEY (`orderDateId`)
        REFERENCES `dimtime` (`dateId`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_factOrderDetails_dimTime2` FOREIGN KEY (`requiredDateId`)
        REFERENCES `dimtime` (`dateId`)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT `fk_factOrderDetails_dimTime3` FOREIGN KEY (`shippedDateId`)
        REFERENCES `dimtime` (`dateId`)
        ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARACTER SET=utf8mb4;

-- -----------------------------------------------------
-- Populate Time dimension
-- Range: Jan 1 of the earliest year to Dec 31 of the latest year found in the
-- source order/required/shipped dates. dateId = days since the start date.
-- -----------------------------------------------------
SET SESSION cte_max_recursion_depth = 20000;

SET @min_year = (SELECT MIN(YEAR(LEAST(orderDate, requiredDate, COALESCE(shippedDate, orderDate))))
                 FROM classicmodels.orders);
SET @max_year = (SELECT MAX(YEAR(GREATEST(orderDate, requiredDate, COALESCE(shippedDate, orderDate))))
                 FROM classicmodels.orders);
SET @start_date = MAKEDATE(@min_year, 1);
SET @end_date = DATE_SUB(MAKEDATE(@max_year + 1, 1), INTERVAL 1 DAY);

INSERT INTO dimtime (dateId, date)
WITH RECURSIVE d (dt) AS (
    SELECT @start_date
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM d WHERE dt < @end_date
)
SELECT DATEDIFF(dt, @start_date), dt FROM d;

-- Populate calendar attributes in a single pass (WHERE on the key keeps this
-- safe even when SQL_SAFE_UPDATES is enabled)
UPDATE dimtime
SET
    timestamp = UNIX_TIMESTAMP(date),
    day_of_week = DATE_FORMAT(date, '%W'),
    weekend = IF(DATE_FORMAT(date, '%W') IN ('Saturday', 'Sunday'), 'Weekend', 'Weekday'),
    month = DATE_FORMAT(date, '%M'),
    year = DATE_FORMAT(date, '%Y'),
    month_day = DATE_FORMAT(date, '%d'),
    week_starting_monday = DATE_FORMAT(date, '%v')
WHERE dateId >= 0;

-- -----------------------------------------------------
-- Copy Data from ClassicModels
-- Surrogate keys are generated by AUTO_INCREMENT; they are not inserted.
-- -----------------------------------------------------

-- dimCustomers
INSERT INTO dimCustomers (
    customerNumber, customerName, contactLastName, contactFirstName,
    phone, addressLine1, addressLine2, city, state, postalCode,
    country, salesRepEmployeeNumber, creditLimit
)
SELECT
    customerNumber, customerName, contactLastName, contactFirstName,
    phone, addressLine1, addressLine2, city, state, postalCode,
    country, salesRepEmployeeNumber, creditLimit
FROM classicmodels.customers;

-- dimProducts
INSERT INTO dimProducts (
    productCode, productName, productLine,
    productScale, productVendor, productDescription,
    quantityInStock, buyPrice, MSRP
)
SELECT
    productCode, productName, productLine,
    productScale, productVendor, productDescription,
    quantityInStock, buyPrice, MSRP
FROM classicmodels.products;

-- dimEmployees: reserved Unassigned member first (key 0), then real employees
INSERT INTO dimEmployees (
    employeeKey, employeeNumber, lastName, firstName,
    extension, email, officeCode, jobTitle
)
VALUES (0, -1, 'Unassigned', 'Unassigned', '', '', '', 'Unassigned');

-- employees joined with offices and with their manager
INSERT INTO dimEmployees (
    employeeNumber, lastName, firstName,
    extension, email, officeCode, reportsTo, managerName, jobTitle,
    city, state, country, postalCode, territory
)
SELECT
    e.employeeNumber, e.lastName, e.firstName,
    e.extension, e.email, e.officeCode, e.reportsTo,
    CONCAT(m.firstName, ' ', m.lastName), e.jobTitle,
    o.city, o.state, o.country, o.postalCode, o.territory
FROM classicmodels.employees AS e
LEFT JOIN classicmodels.offices AS o
    ON e.officeCode = o.officeCode
LEFT JOIN classicmodels.employees AS m
    ON e.reportsTo = m.employeeNumber;

-- factOrderDetails: look up surrogate keys through the source keys.
-- Customers without a sales rep map to the Unassigned member (key 0).
INSERT INTO factOrderDetails (
    orderNumber, orderLineNumber,
    productKey, customerKey, employeeKey,
    productCode, customerNumber, employeeNumber,
    orderDateId, requiredDateId, shippedDateId,
    quantityOrdered, quantityInStock, priceEach, lineTotal, status
)
SELECT
    o.orderNumber,
    od.orderLineNumber,
    dp.productKey,
    dc.customerKey,
    COALESCE(de.employeeKey, 0),
    od.productCode,
    o.customerNumber,
    c.salesRepEmployeeNumber,
    dimOrder.dateId,
    dimReq.dateId,
    dimShip.dateId,
    od.quantityOrdered,
    p.quantityInStock,
    od.priceEach,
    od.quantityOrdered * od.priceEach,
    o.status
FROM classicmodels.orders AS o
INNER JOIN classicmodels.orderdetails AS od
    ON o.orderNumber = od.orderNumber
INNER JOIN classicmodels.customers AS c
    ON o.customerNumber = c.customerNumber
INNER JOIN classicmodels.products AS p
    ON od.productCode = p.productCode
INNER JOIN dimCustomers AS dc
    ON dc.customerNumber = o.customerNumber
INNER JOIN dimProducts AS dp
    ON dp.productCode = od.productCode
LEFT JOIN dimEmployees AS de
    ON de.employeeNumber = c.salesRepEmployeeNumber
INNER JOIN dimtime AS dimOrder
    ON dimOrder.date = o.orderDate
LEFT JOIN dimtime AS dimReq
    ON dimReq.date = o.requiredDate
LEFT JOIN dimtime AS dimShip
    ON dimShip.date = o.shippedDate;

-- -----------------------------------------------------
-- Validation: row counts for each table, plus fact-vs-source checks
-- (dimEmployees includes the extra Unassigned row)
-- -----------------------------------------------------
SELECT 'dimCustomers' AS table_name, COUNT(*) AS total_rows FROM dimCustomers
UNION ALL SELECT 'dimEmployees',      COUNT(*) FROM dimEmployees
UNION ALL SELECT 'dimProducts',       COUNT(*) FROM dimProducts
UNION ALL SELECT 'dimtime',           COUNT(*) FROM dimtime
UNION ALL SELECT 'factOrderDetails',  COUNT(*) FROM factOrderDetails;

SELECT 'order lines: fact vs source' AS check_name,
       (SELECT COUNT(*) FROM factOrderDetails)           AS dw_value,
       (SELECT COUNT(*) FROM classicmodels.orderdetails) AS source_value;

SELECT 'total order value: fact vs source' AS check_name,
       (SELECT SUM(lineTotal) FROM factOrderDetails) AS dw_value,
       (SELECT SUM(quantityOrdered * priceEach) FROM classicmodels.orderdetails) AS source_value;

-- -----------------------------------------------------
-- Restore Session Variables
-- -----------------------------------------------------
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
