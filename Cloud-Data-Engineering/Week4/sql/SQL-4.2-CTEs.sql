/***********************************************
** Name:        SQL Common Table Expressions (CTEs)
** Description: Named temporary result sets defined at the top of a query; used to simplify complex joins and improve readability
** Author:      Ashish Pujari
************************************************/

########################Common Table Expressions (CTE)#########################################
# Common Table Expressions (CTEs) are temporary result sets that can be referenced within a SQL statement, 
# especially within complex queries. They are defined within the scope of a single SQL statement, usually 
# a SELECT, INSERT, UPDATE, or DELETE statement.
#############################################################################################

WITH 
 cte1 AS (SELECT customerNumber, customerName FROM customers),
 cte2 AS (SELECT customerNumber, orderNumber, status FROM orders)
 
SELECT cte1.customerNumber, cte1.customerName, cte2.orderNumber 
FROM cte1 JOIN cte2
WHERE cte1.customerNumber = cte2.customerNumber;

-- Calculate average payment amount
WITH AvgPayment AS (
    SELECT AVG(amount) AS avg_amount 
    FROM payments
)
-- List customers who pay more than average amount
SELECT 
    customerNumber, 
    checkNumber, 
    amount
FROM
    payments
CROSS JOIN 
    AvgPayment
WHERE
    amount > (SELECT avg_amount FROM AvgPayment);

-- Customers who have ordered at least 1 product
WITH OrderedCustomers AS (
    SELECT customerNumber
    FROM orders
)
SELECT 
    customerName,
    contactFirstName,
    contactLastName,
    phone
FROM
    customers
WHERE
    customerNumber IN (SELECT customerNumber FROM OrderedCustomers);

-- Customers who have not ordered any products
WITH NotOrderedCustomers AS (
    SELECT customerNumber
    FROM customers
    WHERE customerNumber NOT IN (SELECT customerNumber FROM orders)
)
SELECT 
    customerName,
    contactFirstName,
    contactLastName,
    phone
FROM
    customers
WHERE
    customerNumber IN (SELECT customerNumber FROM NotOrderedCustomers);

-- Customers who have placed at least one order greater than 10K
WITH HighValueOrders AS (
    SELECT o.customerNumber
    FROM orders o
    INNER JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE (od.priceEach * od.quantityOrdered) > 10000
)
SELECT 
    customerName, 
    contactFirstName, 
    contactLastName, 
    phone
FROM
    customers
WHERE
    customerNumber IN (SELECT customerNumber FROM HighValueOrders);

-- Maximum, minimum, and average number of items in sale orders
WITH LineItems AS (
    SELECT 
        orderNumber, COUNT(orderNumber) AS items
    FROM
        orderdetails
    GROUP BY orderNumber
)
SELECT 
    MAX(items) AS maxItems, 
    MIN(items) AS minItems, 
    AVG(items) AS avgItems
FROM
    LineItems;

# Exercise: List all products whose buy price is greater than all the Harley products
# Exercise: Show all employee details along with the total number of employees in the table
