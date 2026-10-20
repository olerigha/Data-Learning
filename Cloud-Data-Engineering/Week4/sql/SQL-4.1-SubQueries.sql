/***********************************************
** Name:        SQL Subqueries
** Description: Nested SELECT statements embedded inside another query; used to filter or compute values from a separate result set
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

######################### Use case ###################
# List customers who pay more than average amount

# what is the average payment amount
SELECT AVG(amount) FROM payments;

# plug in this value in the next query - cumbersome
SELECT 
    customerNumber, 
    checkNumber, 
    amount
FROM
    payments
WHERE
    amount > 32431.64; 

##################### Subquery ######################
# Query that is nested inside another query such as 
# SELECT, INSERT, UPDATE or DELETE. Sub queries can 
# be placed inside SELECT, WHERE, FROM, etc.
#####################################################

# all payments greater than average payment
# the outer query filters payments that are greater than the average payment returned by the subquery
SELECT 
    customerNumber, 
    checkNumber, 
    amount
FROM
    payments
WHERE
    amount > (SELECT 
            AVG(amount)
        FROM
            payments);            

# customers who have ordered at least 1 product (IN operator) 
SELECT 
    customerName,
	contactFirstName,
    contactLastName,
    phone
FROM
    customers
WHERE
    customerNumber IN (SELECT 
            customerNumber
        FROM
            orders);
            
# customers who have not ordered any products (NOT IN operator)
SELECT 
    customerName,	
	contactFirstName,
    contactLastName,
    phone
FROM
    customers
WHERE
    customerNumber NOT IN (SELECT
            customernumber
        FROM
            orders);
       
##################### Subquery with EXIST #####################
# EXISTS or NOT EXISTS operator - returns a Boolean value of TRUE or FALSE. 
# EXISTS will be faster than IN because it finds a hit, 
# it will quit looking as the condition has proved true.
###############################################################

# Customers who have ordered atleast 1 product (EXISTS). 
SELECT 
    customerName,
	contactFirstName,
    contactLastName,
    phone
FROM
    customers c
WHERE
    EXISTS( SELECT 
            *
        FROM
            orders o
        WHERE
            c.customerNumber = o.customerNumber);
        
# customers who have not ordered any products (NOT EXISTS)
SELECT 
    customerName,
	contactFirstName,
    contactLastName,
    phone
FROM
    customers
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            orders
        WHERE
            customers.customerNumber = orders.customerNumber);

# customers who have placed at least one order greater than 10K
SELECT 
    customerName, 
    contactFirstName, 
    contactLastName, 
    phone
FROM
    customers
WHERE
    EXISTS( SELECT 
            *
        FROM
            orderdetails
                INNER JOIN
            orders
        WHERE
            customers.customerNumber = orders.customerNumber
                AND orderdetails.orderNumber = orders.orderNumber
                AND priceEach * quantityOrdered > 10000);

################# Subquery in the FROM clause #################

# maximum, minimum and average number of items in sale orders
# run the inner query first for bettter understanding
SELECT 
    MAX(items) AS maxItems, 
    MIN(items) AS minItems, 
    AVG(items) AS avgItems
FROM
    (SELECT 
        orderNumber, COUNT(orderNumber) AS items
    FROM
        orderdetails
    GROUP BY orderNumber) AS lineitems;

# list all products whose buy price is greater than all the Harley products - ALL
SELECT 
    productCode, 
    productName, 
    buyPrice
FROM
    products
WHERE
    buyPrice > ALL (SELECT 
            buyPrice
        FROM
            products
        WHERE
            productName LIKE '%Harley%'); 
   
# average buy price of all products whose buy price is greater than all the Harley products - ALL
SELECT 
    AVG(buyPrice) AS avgBuyPrice
FROM
    products
WHERE
    buyPrice > ALL (SELECT 
            buyPrice
        FROM
            products
        WHERE
            productName LIKE '%Harley%'); 
            
# list all products whose buy price is greater than any of the Harley products - ANY 
SELECT 
    productCode, 
    productName, 
    buyPrice
FROM
    products
WHERE
    buyPrice > ANY (SELECT 
            buyPrice
        FROM
            products
        WHERE
            productName LIKE '%Harley%');   

# products whose buy prices are greater than the average buy price of products within their product line
SELECT 
    productName, productLine, buyPrice
FROM
    products AS p
WHERE
    buyPrice > (SELECT 
            AVG(buyPrice)
        FROM
            products
        WHERE
            productline = p.productline);
            
################## Subquery in SELECT clause #################
#Used when you wish to compute an aggregate value, but you do not want the 
# aggregate function to apply to the main query.

#show all employee details along with the total number of employees in the table
SELECT 
    *, 
    (SELECT COUNT(employeeNumber) FROM employees) AS numberOfEmployees
FROM
    employees;

# Show all products along with the max, avg and min buy prices within their 
# respective product lines
SELECT 
    productName,
    buyPrice,
    productline,
    (SELECT 
            MAX(buyPrice)
        FROM
            products
        WHERE
            productline = p.productline) maxBuyPriceInLine,
     (SELECT 
            AVG(buyPrice)
        FROM
            products
        WHERE
            productline = p.productline) avgBuyPriceInLine,
     (SELECT 
            MIN(buyPrice)
        FROM
            products
        WHERE
            productline = p.productline) minBuyPriceInLine                       
FROM
    products p;