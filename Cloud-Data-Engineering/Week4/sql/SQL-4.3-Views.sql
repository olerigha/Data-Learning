/***********************************************
** Name:        SQL Views
** Description: Stored SELECT queries that act as virtual tables; used to simplify repeated queries, enforce security, and abstract schema details
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### VIEWS ###################

# view containing only customer name and country
CREATE VIEW customerCountry AS
    SELECT 
        customerName, country
    FROM
        customers;

# describe the structure of view
DESCRIBE customerCountry;

# lists all the tables and views
SHOW FULL TABLES; 
        
# select data from the view
SELECT 
    *
FROM
    customerCountry;

# view for basket values using orderdetails table
CREATE VIEW basketValue AS
    SELECT 
        orderNumber, SUM(quantityOrdered * priceEach) AS total
    FROM
        orderDetails
    GROUP BY orderNumber
    ORDER BY total DESC;

# select data from the view
SELECT 
    orderNumber, total
FROM
    basketValue;

### create view highestBasketValue from another view basketValue
# Show top 50 orders by basketValue 
CREATE VIEW highestBasketValue AS
    SELECT 
        orderNumber, ROUND(total, 2) AS total
    FROM
        basketValue
	ORDER BY total DESC
    LIMIT 50;

# select data from the view
SELECT 
    orderNumber, total
FROM	
    highestBasketValue;
    
# create views with joins - order number, customer name, and total sales per order
CREATE VIEW customerOrders AS
    SELECT 
        d.orderNumber,
        c.customerName,
        c.phone,
        SUM(quantityOrdered * priceEach) total
    FROM
        orderDetails d
            INNER JOIN
        orders o ON o.orderNumber = d.orderNumber
            INNER JOIN
        customers c ON c.customerNumber = o.customerNumber
    GROUP BY d.orderNumber
    ORDER BY total DESC;

# select data from the view
SELECT 
    orderNumber, customerName, phone, total
FROM
    customerOrders;
    
# views with subqueries - products whose buy prices are higher than the average price of all products
CREATE VIEW productsAboveAvgPrice AS
    SELECT 
        productCode, productName, buyPrice
    FROM
        products
    WHERE
        buyPrice > (SELECT 
                AVG(buyPrice)
            FROM
                products)
    ORDER BY buyPrice DESC;

# select data from the view
SELECT 
    productCode, productName, buyPrice
FROM
    productsAboveAvgPrice;
    
################### UPDATE VIEWS ###################

# create a officeInfo view
CREATE VIEW officeInfo AS
    SELECT 
        officeCode, phone, city
    FROM
        offices;
        
# select data from the view
SELECT 
    officeCode, phone, city
FROM
    officeInfo;

# find views that can be updated
SELECT 
    table_name, is_updatable
FROM
    information_schema.views
WHERE
    table_schema = 'classicmodels';

#set the update mode
SET SQL_SAFE_UPDATES = 0;

# update phone for the paris office from '+33 14 723 4404' to '+33 14 723 5555'
UPDATE officeInfo 
SET 
    phone = '+33 14 723 5555'
WHERE
    officeCode = 4;

# select data from the view
SELECT 
    officeCode, phone, city
FROM
    officeInfo
WHERE
    officeCode = 4;
    
# select data from underlying table
SELECT 
    officeCode, phone, city
FROM
    offices
WHERE
    officeCode = 4;
    
# Update view with CHECK OPTION 
# ensuring data consistency so that only valid data will be written to the database

# employees whose job title is VP or higher
CREATE OR REPLACE VIEW vps AS
    SELECT 
		*
    FROM
        employees
    WHERE
        jobTitle LIKE '%VP%';
        
# select data from the view
SELECT 
    *
FROM
    vps;

# new employee was recruited for IT Manager position. INSERT data using the vps view
INSERT INTO vps(employeeNumber,firstname,lastname,jobtitle,extension,email,officeCode,reportsTo)
values(1703,'Lily','Bush','IT Manager','x9111','lilybush@classicmodelcars.com',1,1002);

# select data from employees table - employee 1703 added
SELECT 
    *
FROM
    employees
WHERE
    employeeNumber = 1703;

# select data from the view - employee 1703 data not seen
SELECT 
	*
FROM
    vps;

# this time use CHECK OPTION
CREATE OR REPLACE VIEW vps AS
    SELECT 
        *
    FROM
        employees
    WHERE
        jobTitle LIKE '%VP%' WITH CHECK OPTION;

# delete the recently added employee
DELETE FROM employees 
where employeeNumber = 1703;

# re-insert the employee - this throws an error
INSERT INTO vps(employeeNumber,firstname,lastname,jobtitle,extension,email,officeCode,reportsTo)
values(1703,'Lily','Bush','IT Manager','x9111','lilybush@classicmodelcars.com',1,1002);

# insert new employee as VP - this works
INSERT INTO vps(employeeNumber,firstname,lastname,jobtitle,extension,email,officeCode,reportsTo)
VALUES(1704,'John','Smith','VP Finance','x9112','johnsmith@classicmodelcars.com',1,1076);

# select data from the view - employee 1704 data seen
SELECT 
	*
FROM
    vps;
    
# check on 1704 employee number
SELECT 
	*
FROM
    employees
where employeeNumber = 1704;


# Managing Views
# Reporting structure
CREATE OR REPLACE VIEW organization AS
    SELECT 
        CONCAT(e.lastname, ' ', e.firstname) AS employee,
        CONCAT(m.lastname, ' ', m.firstname) AS manager
    FROM
        employees AS e
            INNER JOIN
        employees AS m ON m.employeeNumber = e.reportsTo
    ORDER BY Manager;

# select data from the view
SELECT 
    *
FROM
    organization;

# adding emails to the organization view
ALTER VIEW organization AS
    SELECT 
        CONCAT(E.lastname, ' ', E.firstname) AS employee,
        CONCAT(M.lastname, ' ', M.firstname) AS manager,
        e.email as employeeEmail,
        m.email as managerEmail
    FROM
        employees AS e
            INNER JOIN
        employees AS m ON m.employeeNumber = e.reportsTo
    ORDER BY manager;

# check to see if email is added for each employee 
SELECT 
    *
FROM
    organization;

# clean up rows added in this module
DELETE FROM employees 
WHERE
    employeeNumber = 1703 or employeeNumber = 1704;

# Drop views if it already exists
DROP VIEW IF EXISTS customerCountry;
DROP VIEW IF EXISTS basketValue;
DROP VIEW IF EXISTS highestBasketValue;
DROP VIEW IF EXISTS customerOrders;
DROP VIEW IF EXISTS productsAboveAvgPrice;
DROP VIEW IF EXISTS officeInfo;
DROP VIEW IF EXISTS vps;
DROP VIEW IF EXISTS organization;