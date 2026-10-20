/***********************************************
** Name:        SQL Window Functions
** Description: Perform calculations across a set of rows related to the current row without collapsing the result set; used for ranking, running totals, and moving averages
** Author:      Ashish Pujari
************************************************/

######################################## Window Functions ########################################
# Perform calculations across a set of rows related to the current row within a 
# query result, without actually grouping the rows together with GROUP BY clause
#
# The PARTITION BY is used with window functions to divide the result set into 
# partitions to which the window function is applied separately.
#
# OVER() clause defines the window over which the function operates. 
# It specifies the partitioning and ordering of the rows within the window. 
# You can partition the data into groups and order the rows within each group.
##################################################################################################  

# Calculate the average order amount for each customer.
SELECT 
    customerNumber, 
    AVG(total_amount) AS avg_order_amount
FROM (
    SELECT 
        o.customerNumber, 
        SUM(od.quantityOrdered * od.priceEach) AS total_amount
    FROM 
        orders o
    JOIN 
        orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY 
        o.orderNumber, o.customerNumber
) AS order_totals
GROUP BY 
    customerNumber;

# Calculate the average order amount for each customer using Window Function
SELECT 
    o.customerNumber, 
    o.orderDate, 
    SUM(od.quantityOrdered * od.priceEach) AS total_amount,
    AVG(SUM(od.quantityOrdered * od.priceEach)) 
OVER (PARTITION BY o.customerNumber) AS avg_order_amount
FROM 
    orders o
JOIN 
    orderdetails od ON o.orderNumber = od.orderNumber
GROUP BY 
    o.customerNumber, o.orderDate;

# Rank customers by their total order value:
SELECT
    c.customerNumber,
    SUM(od.quantityOrdered * od.priceEach) AS totalCustomerOrderValue,
    RANK() OVER (ORDER BY SUM(od.quantityOrdered * od.priceEach) DESC) AS customerRank
FROM
    orderdetails od
JOIN
    orders o ON od.orderNumber = o.orderNumber
JOIN
    customers c ON o.customerNumber = c.customerNumber
GROUP BY
    c.customerNumber;

# Show all products along with the max, avg and min buy prices within their 
# respective product lines
SELECT  productName,
		buyPrice,
		productline,
        MAX(buyPrice) OVER
         (PARTITION BY productline) AS maxBuyPriceInLine,
        AVG(buyPrice) OVER
         (PARTITION BY productline) AS avgBuyPriceInLine,
        MIN(buyPrice) OVER
         (PARTITION BY productline) AS minBuyPriceInLine
FROM products;

# Find the top products by quantity ordered in each product line:
SELECT
    productLine,
    productName,
    quantityOrdered,
    RANK() OVER (PARTITION BY productLine ORDER BY quantityOrdered DESC) AS productRank
FROM
    products
    INNER JOIN orderdetails ON products.productCode = orderdetails.productCode;
   
# Calculate the percentage of total sales attributed to each product 
SELECT 
    od.productCode, 
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    SUM(od.quantityOrdered * od.priceEach) / SUM(SUM(od.quantityOrdered * od.priceEach)) OVER () * 100 AS percentage_of_total
FROM 
    orderdetails od
GROUP BY 
    od.productCode;
    
# Find the difference in days between consecutive orders for each customer
SELECT 
    customerNumber, 
    orderDate,
    DATEDIFF(orderDate, LAG(orderDate) 
    OVER (PARTITION BY customerNumber ORDER BY orderDate)) AS days_since_last_order
FROM 
    orders;

#Calculate year-over-year growth in the number of orders: 
SELECT 
	YEAR(orderDate) AS order_year, 
	COUNT(*) AS total_orders,
	LAG(COUNT(*)) OVER (ORDER BY YEAR(orderDate)) AS previous_year_orders,
	COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(orderDate)) AS growth
FROM 
    orders
GROUP BY 
    order_year
ORDER BY 
    order_year;