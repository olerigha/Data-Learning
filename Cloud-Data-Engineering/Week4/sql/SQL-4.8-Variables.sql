/***********************************************
** Name:        SQL User-Defined Variables
** Description: Session-scoped variables for storing and reusing values within a single SQL session
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### USER DEFINED VARIABLES ###################
# pass a value from an SQL statement to another SQL statement
# within a particular session

# set variable 
SET @buyPrice:= 90;

# show all variables

# validate
Select @buyPrice AS buyPrice;

SELECT 
    productName,
    ProductVendor,
    buyPrice,
    MSRP
FROM
    products
WHERE
    buyPrice > @buyPrice;

# Use MAX function 
SELECT 
    @msrp:=MAX(msrp) AS maxMSRP
FROM
    products;

# user defined variable used in where clause
SELECT 
    productCode, productName, productLine, msrp
FROM
    products
WHERE
    msrp = @msrp;

# List all user variables
SELECT 
    *
FROM
    performance_schema.user_variables_by_thread;



################### EXPORT file (CSV) ###################
# Check the value set for the secure_file_priv variable
SHOW VARIABLES LIKE 'secure_file_priv';

# export result set to a CSV file
SELECT 
    orderNumber, status, orderDate, requiredDate, comments
FROM
    orders
WHERE
    status = 'Cancelled' 
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8/Uploads/cancelled_orders.csv' 
FIELDS ENCLOSED BY '"' 
TERMINATED BY ';' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n';

# exporting the data with column headings
(SELECT 'Order Number','Order Date','Status')
UNION 
(SELECT orderNumber,orderDate, status
FROM orders
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8/Uploads/cancelled_orders_with_headers.csv'
FIELDS ENCLOSED BY '"' TERMINATED BY ';' ESCAPED BY '"'
LINES TERMINATED BY '\r\n');