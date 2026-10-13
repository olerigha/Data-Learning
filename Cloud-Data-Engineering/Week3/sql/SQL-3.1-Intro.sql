/***********************************************
** Name:        Introduction to SQL
** Description: Covers basic SQL commands for listing databases, exploring table structures, and running simple SELECT queries
** Author:      Ashish Pujari
************************************************/

# Show the list of all databases
SHOW DATABASES;

# Select database
USE classicmodels;

# List of all tables in the database
SHOW TABLES;

# Provides information on the offices table 
DESCRIBE offices;

#List all offices
SELECT * FROM offices;

# Provides information on customers table 
DESCRIBE customers;

# List all customers and all available information
SELECT 
    *
FROM
    customers;

# List all customers and information from a few (columns)
SELECT 
    customerNumber, customername, phone, country
FROM
    customers;
    
# Using aliases we can dynamically rename columns for display 
# allows SQL queries and the result set to be more readable
SELECT 
    customerNumber, customername as businessName, phone, country
FROM
    customers;
    
# Both column alias and table alias
SELECT
	customerNumber,
    customerName AS businessName,
    contactFirstName,
    contactLastName,
    postalCode AS postCode
FROM
    customers AS cust;

# Select customers who are located in USA or France 
# The WHERE clause is used to filter records
SELECT 
    customerNumber, customername, phone, country
FROM
    customers
WHERE
	country = 'USA' OR country = 'France';
	#add another country
    
# Select customers who are located in USA or France
# IN Operator allows you to easily test if an expression matches any value in a list of values.  
SELECT 
    customerNumber, customername, phone, country
FROM
    customers
WHERE
	country IN ('USA' , 'France');
    
# select customers who are located in USA or France and have a credit limit > $100,000
# whats wrong with this query ?
SELECT 
    customerNumber, customername, country, creditLimit
FROM
    customers
WHERE
    country = 'USA' OR country = 'France'
        AND creditlimit > 100000;
    
/* Due to operator precedence the query returns the customers located 
 * in USA OR customers France with the credit limit > 100000 rather than 
 * those who are from USA or France AND have a credit limit > 100000
 */
SELECT 
    customerNumber, customername, country, creditLimit
FROM
    customers
WHERE
    (country = 'USA' OR country = 'France')
        AND creditlimit > 100000;
    
# Exercise - List all the orders that are 'In Process' or 'shipped' 
SELECT 
    orderNumber, orderDate, requiredDate, customerNumber, status
FROM
    orders
WHERE
    (status = 'In Process'
        OR status = 'shipped');
        
# Find all the orders have been placed but not shipped or cancelled.
# Note the 2 seperate operator aliases which indicate the same thing - Not Equal To
# The != operator is converted to be <> by the compiler/interpreter during execution 

SELECT 
    orderNumber, orderDate, requiredDate, customerNumber, status
FROM
    orders
WHERE
    status <> 'shipped'
        AND status != 'cancelled';
        
#List all customers that are not assigned to a sales rep - is Null
SELECT 
    *
FROM
    customers
WHERE
    salesRepEmployeeNumber IS NULL;
                       
# List all products with buyPrice between 50$ and 100$ 
SELECT 
	productCode,
	productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice
FROM
    products
WHERE
    buyPrice BETWEEN 50 AND 100;
    
# List all products with buyPrice between 50$ and 100$ 
SELECT 
    productCode,
    productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice
FROM
    products
WHERE
    buyPrice >= 50 AND buyPrice <= 100;

# List all customers along with their resident state and country 
# return N/A if the state is NULL using if statement 
SELECT 
    customerNumber,
    customerName,
    IF(state IS NULL, 'N/A', state) AS State,
    country
FROM
    customers;
    
# using case statement 
SELECT
	customerNumber,
    customerName,
    (CASE WHEN state IS NULL 
		THEN 'N/A' ELSE state END) 
	AS state,
    country
FROM
    customers;

# List all customers from Japan
# searching on Japa<single character wildcard>
SELECT 
	*
FROM
    customers
WHERE
    country LIKE 'Japa_';

# list all customers from cities starting with San
# searching on San<wildcard> 
SELECT 
	*
FROM
    customers
WHERE
    city LIKE 'San%';
#   city LIKE 'San F%';

# Exercise: List all products from Harley - partial match
SELECT 
    productCode, 
    productName, 
    productLine, 
    productDescription, 
    quantityInStock, 
    buyPrice, 
    MSRP
FROM
    products
WHERE
    productName LIKE '%Harley%';
    
# Details of products that are not from Harley Davidson
SELECT
	productCode,
	productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice,
    MSRP
FROM
    products
WHERE
    productName NOT LIKE '%Harley%';
     
# What is the cost of inventory for Harley Davidson's products
# Use of column alias
SELECT
	productCode,
	productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice,
    (quantityInStock * buyPrice) AS totalAmount
FROM
    products
WHERE
    productName LIKE '%Harley%';
    
# Exercise: What is the profit per product for Harley Davidson's products
# Hint: (MSRP - buyPrice)
SELECT
	productCode,
	productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice,
    (MSRP - buyPrice) AS productProfit
FROM
    products
WHERE
    productName LIKE '%Harley%';

# if we want to wholesale Harley Davidson products in packs of 50, 
# how many units can we sell to another retailer and how many would be left over 

SELECT 
	productCode,
	productName,
    productLine,
    productDescription,
    quantityInStock,
    buyPrice,
    MSRP,
    FLOOR(quantityInStock / 50) AS numberOfPacks,
    (quantityInStock % 50) AS remainderQuantityInStock
FROM
    products
WHERE
    productName LIKE '%Harley%';

######################## DISTINCT  ########################

# DISTINCT - returns only distinct (unique) values
# what are the states where our customers are located ?
# only one NULL value will be returned 

SELECT DISTINCT
    state
FROM
    customers;
    
# what are the cities and states where our customers are located ?
# using DISTINCT gives unique combination of city and state.
SELECT DISTINCT
    city, state 
FROM
    customers
WHERE
    state IS NOT NULL;
    
# Adding customerName to DISTINCT is same as SELECT all  
SELECT DISTINCT
   customerName, state, city
FROM
    customers
WHERE
    state IS NOT NULL;

######################## LIMIT  ########################
# LIMIT - constrain the number of rows in a result set
# Useful when sampling large result sets or to report on top or bottom results

# first 10 customers in the customers table
SELECT 
    contactLastname,
    contactFirstname,
    customerNumber,
    state,
    city,
	creditLimit
FROM
    customers
LIMIT 10;
