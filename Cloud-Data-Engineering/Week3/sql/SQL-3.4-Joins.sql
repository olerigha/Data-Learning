/***********************************************
** Name:        SQL Joins
** Description: Combine rows from two or more tables on related columns; used to query data across normalized schemas
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

############################ JOINS  ########################
# A join combines two or more tables to retrieve data from multiple tables
# INNER JOIN: Returns all rows when there is at least one match in BOTH tables
# OUTER JOIN : 
# 	LEFT JOIN: Return all rows from the left table, and the matched rows from the right table
# 	RIGHT JOIN: Return all rows from the right table, and the matched rows from the left table
# 	FULL JOIN: Return all rows when there is a match in ONE of the tables
# CROSS JOIN: Cartesian Product of two tables that returns all possible combinations
############################################################

######################## INNER JOIN ########################
# Returns all rows when there is at least one match in BOTH tables ( intersection )
# by joining two tables with a common column 
############################################################

# List customers and the orders that they have placed.
SELECT 
    *
FROM
    customers c
        INNER JOIN
    orders o ON c.customerNumber = o.customerNumber;

# List customers and the orders that they have placed.
# Select specific columns and use table alias
SELECT 
    c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.orderNumber,
    o.orderDate,
    o.status
FROM
    customers c
        INNER JOIN
    orders o ON c.customerNumber = o.customerNumber;
 
# Inner join with multiple tables
# List customers, the orders that they have placed, and order details.
SELECT
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.orderNumber,
    o.orderDate,
    o.status,
    d.productCode
FROM
    customers c
        INNER JOIN
    orders o ON c.customerNumber = o.customerNumber
        INNER JOIN
    orderDetails d ON o.orderNumber = d.orderNumber;

######################## NATURAL JOIN ########################
# Same as inner join but eliminates duplicate columns in the joining columns
# No need to specify the join column as long both tables have a common column
##############################################################

SELECT 
    *
FROM
    customers
        NATURAL JOIN
    orders;
    
######################## LEFT JOIN  ########################
# Select rows from the both left and right tables that are matched, 
# plus all rows from the left table ( T1 ) even there is no match 
# found for them in the right table ( T2 ).
# LEFT JOIN AND LEFT OUTER JOIN are the same join.
# In contrast to the INNER JOIN, the order of the tables plays an 
# important role in the LEFT JOIN, and the results may be completely 
# different if the order changes in your SQL query.
#############################################################

# List *all* customers and the orders that they have placed.
# Some of these customers may not have placed any orders (null)
SELECT 
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.orderNumber,
    o.orderDate,
    o.STATUS
FROM
    customers c
        LEFT JOIN
    orders o ON c.customerNumber = o.customerNumber;

#add this clause to check customers that havent placed orders
#WHERE o.orderNumber IS NULL

# Left join with multiple tables
# could return thousands of rows
SELECT 
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.customerNumber,
    o.orderNumber,
    o.orderDate,
    o.STATUS,
    d.productCode
FROM
    customers c
        LEFT OUTER JOIN
    orders o ON c.customerNumber = o.customerNumber
        LEFT OUTER JOIN
    orderDetails d ON o.orderNumber = d.orderNumber;

#add this clause to check customers that havent placed orders
#WHERE o.orderNumber IS NULL

######################## RIGHT JOIN ########################
# The RIGHT JOIN keyword returns all the rows from the right table 
# even if there are no matches in the left table.
#############################################################

# Select all records from Orders table and Customers that match those orders.
# There are no orders without a customer number. So a RIGHT JOIN from Customers 
# to Orders will return same results as an INNER JOIN
SELECT  
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    orderNumber,
    o.orderDate,
    o.STATUS
FROM
    customers c
        RIGHT JOIN
    orders o ON c.customerNumber = o.customerNumber;

# Right join with multiple tables
SELECT 
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.customerNumber,
    o.orderNumber,
    o.orderDate,
    productCode,
    o.STATUS
FROM
    customers c
        RIGHT OUTER JOIN
    orders o ON c.customerNumber = o.customerNumber
        RIGHT OUTER JOIN
    orderDetails d ON o.orderNumber = d.orderNumber;

# rows in the left table that do not match with the rows in the right table
# WHERE
#    c.customerNumber = 125 / * OR 168 */

#Exercise:
#1) Perform a inner, left and right join between employees and offices
# Are you able to explain the results.

######################## SELF JOIN ########################
# A self join is a join in which a table is joined with itself 
# (which is also called Unary relationships), especially when the table 
# has a FOREIGN KEY which references its own PRIMARY KEY.
###########################################################

# List of employees along with their managers and designation 
# This is a listing of the organization structure
SELECT
    e1.firstName  AS managerFirstName,
    e1.lastName   AS managerLastName,
    e1.jobTitle	  AS managerJobTitle,
    e2.firstName  AS empFirstName,
    e2.lastName   AS empLastName,
    e2.jobTitle   AS empJobTitle
FROM
    employees AS e1
LEFT JOIN
	employees AS e2
ON
    e1.employeeNumber = e2.reportsTo;    

#Exercise: What happens if you use the LEFT JOIN  above

######################## CROSS JOIN ########################
# A Cross join is the the Cartesian Product of two tables
# It creates a combination of every row from the two tables.
# Returns a large number of records and not commonly used. 
###########################################################

# Cross join between customers and orders creates a lot of records 39772
# syntax 1 
SELECT
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.orderNumber, 
    o.orderDate,
    o.status
FROM
    customers c, orders o;

# syntax 2 
SELECT 
	c.customerNumber,
    c.customerName,
    c.contactFirstName,
    c.contactLastName,
    c.postalCode,
    o.orderNumber, 
    o.orderDate,
    o.status
FROM
    customers c
        CROSS JOIN
    orders o;

################ JOINS applied to other queries ##################    

# Exercise: What is the total revenue for each year for the products that were shipped

# Exercise: Find all orders that were shipped and have total sales greater than $1500
    
######################## UNION ########################
# The UNION operator is used to combine the result-set of two or more SELECT statements.
# Every SELECT statement within UNION must have the same number of columns
# The columns must also have similar data types
# The columns in every SELECT statement must also be in the same order
###########################################################

# union on customers and offices based on location  
(SELECT 
    city,state,country
FROM
    customers) UNION (SELECT 
    city,state,country
FROM
    offices) 
ORDER BY 2 , 1;

# Remove states with NULL value
(SELECT 
    city,state,country
FROM
    customers
WHERE state is NOT NULL ) UNION (SELECT 
    city,state,country
FROM
    offices
WHERE state is NOT NULL) 
ORDER BY 2 , 1; 

# UNION ALL operator does not remove duplicates - check city San Francisco
(SELECT 
    city,state,country
FROM
    customers
WHERE state is NOT NULL ) UNION ALL (SELECT 
    city,state,country
FROM
    offices
WHERE state is NOT NULL) 
ORDER BY 2 , 1; 