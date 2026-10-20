/***********************************************
** Name:        SQL Built-in Functions
** Description: String, numeric, and date functions provided by MySQL; used to transform and format values in query output
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### String functions ###################
# TRIM - remove leading and trailing white spaces
SELECT TRIM('     MySQL TRIM function    ') AS trimText;

# LTRIM - remove leading spaces on left
SELECT LTRIM('     MySQL TRIM function    ') AS ltrimText;

# RTRIM - remove trailing spaces on right
SELECT RTRIM('     MySQL TRIM function    ') AS rtrimText;

# CONCAT - combine 1 or many columns
# CONCAT_WS - concatenate with separator
# Space - add space between  the first name and the last name
SELECT
	customerNumber,
    CONCAT (contactFirstName, space(1), contactLastName ) AS 'contactFullName',
    CONCAT_WS(', ', addressLine1, addressLine2, state, city) AS 'contactAddress'
FROM
customers;

# CONCAT - with TRIM
SELECT
	customerNumber,
    CONCAT (TRIM(contactFirstName), space(1), TRIM(contactLastName) ) AS 'contactFullName',
    CONCAT_WS(', ', addressLine1, addressLine2, state, city) AS 'contactAddress'
FROM
customers;
    
# UPPER - converts to uppercase / LOWER - converts to lowercase
SELECT 
    customerNumber,
    country,
    UPPER(country) AS countryUpper,
    city,
    LOWER(city) AS cityLower
FROM
    customers;

# INSTR - search the set of characters ( case sensitive ) and indicate the position
SELECT 
    customerNumber,
    addressLine1,
    INSTR(addressLine1, 'St.') AS positionOfMatch
FROM
    customers
WHERE
    INSTR(addressLine1, 'St.') > 0; 
    
# LAPD - pads leading spaces / RAPD - pads trailing spaces
SELECT
	customerNumber,
    addressLine1, RPAD(addressLine1, 20, '*') AS rapdAddressLine1,
    addressLine2, LPAD(addressLine2, 20, '*') AS lapdAddressLine2
FROM
    customers;

# REPLACE 
# translate "St." to "Street" in the addressLine1 column
SELECT 
    customerNumber,
    addressLine1,
    REPLACE(addressLine1, 'St.', 'Street') AS newAddressLine1		
FROM
    customers
WHERE
    country = 'USA';

######### SUBSTRING - extracts part of the string ##########
SELECT 
    customerNumber,
    addressLine1,
    # extract the street number 
    substring(addressLine1,1,4) AS streetNumber,
	# extract all characters from position 5 till end of string
	substring(addressLine1,5) AS streetName1,
	substring(addressLine1 FROM 5) AS streetName2,
	# extract all characters from position -10 for length 6
    substring(addressLine1, -10, 6) AS streetName3,
    substring(addressLine1 FROM -10 for 6) AS streetName4
FROM
    customers
WHERE
    country = 'USA';
    
# CHAR_LENGTH - length of string (number of characters including spaces )
# street adress - removing last 3 characters
SELECT 
    customerNumber,
    addressLine1,
    SUBSTRING(addressLine1,
        1,
        CHAR_LENGTH(addressLine1) - 3) AS streetName
FROM
    customers
WHERE
    country = 'USA';

# COALESCE - returns the first non-NULL value of a list

# returns the first non-NULL value from the list ( City, state ) or NULL
SELECT 
    customerNumber,
    state,
    country,
    COALESCE(state, country) AS stateOrCountry
FROM
    customers;

# RegEx - special string that describes a search pattern

# find out products whose name starts with character A, B or C.
SELECT 
    productname
FROM
    products
WHERE
    productname REGEXP '^(A|B|C)'
ORDER BY productname;

# find the product whose name ends with f
SELECT 
    productname
FROM
    products
WHERE
    productname REGEXP 'f$';
    
# find products whose name contains exactly 10 characters
SELECT 
    productname
FROM
    products
WHERE
    productname REGEXP '^.{10}$';    

################### Numeric functions ###################

# apply FLOOR, CEIL, ROUND, TRUNCATE to buyPrice column
SELECT
    productName,
    buyPrice,
    FLOOR(buyPrice) AS floorBuyPrice,
    CEIL(buyPrice)  AS ceilBuyPrice,
    ROUND(buyPrice) AS roundBuyPrice,
    ROUND(buyPrice,3) AS roundBuyPrice,
    TRUNCATE(buyPrice,1) AS truncateBuyPrice
FROM 
	products
WHERE
	ProductName LIKE '%Harley%';
   
# apply POWER, SQRT to MSRP column
SELECT
    productName,
    buyPrice,
    MSRP,
    POWER(MSRP,2) AS power2MSRP,
    POWER(MSRP,-2) AS powerNeg2MSRP,
    POWER(MSRP,1/2) AS powerReciprocal2MSRP,
    SQRT(MSRP) AS squareRootMSRP
FROM 
	products
WHERE
	ProductName LIKE '%Harley%';
    
# apply ABS and SIGN to the difference between MSRP and buyPrice
SELECT
    productName,
    buyPrice,
    MSRP,
	(buyPrice - MSRP) AS buyPriceMSRPDiff,
	ABS(buyPrice - MSRP) AS absBuyPriceMSRPDiff,
	SIGN(buyPrice - MSRP) AS signBuyPriceMSRPDiff,
    SIGN(MSRP - buyPrice ) AS signMSRPBuyPriceDiff
FROM 
	products
WHERE
	ProductName LIKE '%Harley%';

################### Date functions ###################

# current system time
SELECT NOW() AS currentTime;

# date part of the DATETIME and CURDATE
SELECT DATE(NOW()), CURDATE();

# format the current date using DATE_FORMAT function
SELECT 
    CURDATE() AS 'default',
    DATE_FORMAT(CURDATE(), '%m-%d-%y') AS '%m-%d-%y',
    DATE_FORMAT(CURDATE(), '%d/%m/%Y') AS '%d/%m/%Y',
    DATE_FORMAT(CURDATE(), '%M-%d-%Y') AS '%M-%d-%Y',
    DATE_FORMAT(CURDATE(), '%D-%M-%y') AS '%D-%M-%y';

SELECT 
	ordernumber,
    orderDate,
    shippedDate,
    DATEDIFF(shippedDate, orderDate) AS numberOfDays
FROM
    orders
ORDER BY numberOfDays DESC
LIMIT 5;

# Add a value from a date value using DATE_ADD function
SELECT
	orderDate,
    requiredDate,
    DATE_ADD(orderDate, INTERVAL 1 DAY) AS dayAfterOrderDate,
	DATE_ADD(orderDate, INTERVAL 1 WEEK) AS weekAfterOrderDate,
    DATE_ADD(orderDate, INTERVAL 1 MONTH) AS monthAfterOrderDate,
    DATE_ADD(orderDate, INTERVAL 1 YEAR) AS yearAfterOrderDate
FROM
    orders;

# subtract a value from a date value using DATE_SUB function
SELECT
	orderDate,
    shippedDate,
    DATE_SUB(shippedDate, INTERVAL 1 DAY) AS dayBeforeShippedDate,
    DATE_SUB(shippedDate, INTERVAL 1 WEEK) AS weekBeforeShippedDate,
    DATE_SUB(shippedDate, INTERVAL 1 MONTH) AS monthBeforeShippedDate,
    DATE_SUB(shippedDate, INTERVAL 1 YEAR) AS yearBeforeShippedDate
FROM
	orders;

################### Conversions functions ###################
# Conversion functions are used to convert a data type into another data type

# MySQL converts a string into an integer implicitly before calculation:
SELECT (1 + '1')/2;

# Explicit cast
SELECT (1 + CAST('1' AS UNSIGNED))/2 ;

# phone is varchar(50) and when cast to unsigned integer we have erroneous results 
DESCRIBE offices;

SELECT 
    phone,
    CAST(phone AS UNSIGNED) AS phoneAsInteger,
    CAST(phone AS CHAR) AS phoneAsChar
FROM
    offices;

# orders whose required dates are in January 2015. 
# The data type of the requireDate column is DATE, therefore, MySQL has to convert the literal strings: '2015-01-01' and '2015-01-31' into TIMESTAMP values before evaluating the WHERE condition.
SELECT 
    orderNumber, requiredDate
FROM
    orders
WHERE
    requiredDate BETWEEN '2015-01-01' AND '2015-01-31';

# To be safe, you can use CAST() function to explicitly convert a string into a TIMESTAMP value as follows: 
SELECT 
    orderNumber, requiredDate
FROM
    orders
WHERE
    requiredDate BETWEEN CAST('2015-01-01' AS DATETIME) AND CAST('2015-01-31' AS DATETIME);

# converts DOUBLE values into CHAR values and uses the results as the arguments to CONCAT function
SELECT 
    productName,
    CONCAT('BuyPrice, MSRP : (',
            CAST(buyprice AS CHAR),
            ',',
            CAST(msrp AS CHAR),
            ')') AS prices
FROM
    products;
