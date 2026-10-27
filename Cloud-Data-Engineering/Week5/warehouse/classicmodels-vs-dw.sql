/***********************************************
** Name:        Operational vs Analytical Queries
** Description: Contrasts OLTP-style queries against dimensional model queries to illustrate data warehouse design benefits
** Author:      Ashish Pujari
**
** Requires:    Both schemas loaded: `classicmodels` (OLTP) and `classicmodelsdw` (see classicmodelsdw.sql).
** Note:        Each pair below returns the same rows, so you can compare results and query shape.
**              The dimensional queries join the fact table to dimensions on surrogate keys.
************************************************/

-- -----------------------------------------------------
-- 1. Monthly quantity ordered per country and product line
-- -----------------------------------------------------

-- Dimensional ( analytical database ) approach: fact + 3 dimensions
USE classicmodelsdw;
SELECT
    dimc.country,
    dimp.productLine,
    dimt.year,
    dimt.month,
    SUM(fact.quantityOrdered) AS totalQuantity
FROM
    factOrderDetails AS fact
    INNER JOIN dimtime AS dimt ON dimt.dateId = fact.orderDateId
    INNER JOIN dimProducts AS dimp ON dimp.productKey = fact.productKey
    INNER JOIN dimCustomers AS dimc ON dimc.customerKey = fact.customerKey
GROUP BY dimc.country, dimp.productLine, dimt.year, MONTH(dimt.date), dimt.month
ORDER BY dimc.country, dimp.productLine, dimt.year, MONTH(dimt.date);

-- Operational ( relational ) approach: dates come from the order header, product line from products
USE classicmodels;
SELECT
    c.country,
    p.productLine,
    YEAR(o.orderDate) AS year,
    MONTHNAME(o.orderDate) AS month,
    SUM(od.quantityOrdered) AS totalQuantity
FROM
    orders AS o
    INNER JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
    INNER JOIN products AS p ON p.productCode = od.productCode
    INNER JOIN customers AS c ON c.customerNumber = o.customerNumber
GROUP BY c.country, p.productLine, YEAR(o.orderDate), MONTH(o.orderDate), MONTHNAME(o.orderDate)
ORDER BY c.country, p.productLine, YEAR(o.orderDate), MONTH(o.orderDate);


-- -----------------------------------------------------
-- 2. All products bought by each customer (distinct pairs)
-- -----------------------------------------------------

-- Dimensional ( analytical database ) approach: fact + 2 dimensions
USE classicmodelsdw;
SELECT DISTINCT
    dimc.customerNumber,
    dimp.productCode
FROM
    factOrderDetails AS fact
    INNER JOIN dimCustomers AS dimc ON dimc.customerKey = fact.customerKey
    INNER JOIN dimProducts AS dimp ON dimp.productKey = fact.productKey
ORDER BY dimc.customerNumber, dimp.productCode;

-- Operational ( relational ) approach: 3 table join through the order header
USE classicmodels;
SELECT DISTINCT
    c.customerNumber,
    od.productCode
FROM
    customers AS c
    INNER JOIN orders AS o ON o.customerNumber = c.customerNumber
    INNER JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
ORDER BY c.customerNumber, od.productCode;


-- -----------------------------------------------------
-- 3. Customers who bought at least 10 different products
-- -----------------------------------------------------

-- Dimensional ( analytical database ) approach
USE classicmodelsdw;
SELECT
    dimc.customerNumber,
    COUNT(DISTINCT fact.productKey) AS distinctProducts
FROM
    factOrderDetails AS fact
    INNER JOIN dimCustomers AS dimc ON dimc.customerKey = fact.customerKey
GROUP BY dimc.customerKey, dimc.customerNumber
HAVING COUNT(DISTINCT fact.productKey) >= 10
ORDER BY dimc.customerNumber;

-- Operational ( relational ) approach: 3 table join through the order header
USE classicmodels;
SELECT
    c.customerNumber,
    COUNT(DISTINCT od.productCode) AS distinctProducts
FROM
    customers AS c
    INNER JOIN orders AS o ON o.customerNumber = c.customerNumber
    INNER JOIN orderdetails AS od ON od.orderNumber = o.orderNumber
GROUP BY c.customerNumber
HAVING COUNT(DISTINCT od.productCode) >= 10
ORDER BY c.customerNumber;

-- End --