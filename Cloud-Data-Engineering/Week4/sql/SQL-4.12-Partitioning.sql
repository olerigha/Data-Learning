/***********************************************
** Name:        SQL Table Partitioning
** Description: Divides large tables into smaller physical pieces; improves query performance and simplifies data lifecycle management
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### Partitions ###################
# Partitioning (a database design technique) improves performance, manageability and reduces the cost of storing large datasets

################### RANGE Partitioning ###################
# specify various ranges for which data is assigned. Ranges should be contiguous but not overlapping, and are defined using the VALUES LESS THAN operator
CREATE TABLE customer_rangepartition (
  `customerNumber` int(11) NOT NULL,
  `customerName` varchar(50) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `addressLine1` varchar(50) NOT NULL,
  `addressLine2` varchar(50) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `salesRepEmployeeNumber` int(11) DEFAULT NULL,
  `creditLimit` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`customerNumber`)
) PARTITION BY RANGE (customerNumber) 
(PARTITION p0 VALUES LESS THAN (200) , 
PARTITION p1 VALUES LESS THAN (300) , 
PARTITION p2 VALUES LESS THAN (400) , 
PARTITION p3 VALUES LESS THAN (500));

# Check to see if all partitions are created
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_rangepartition'; 

# Insert data into the partitioned table from the original customers table 
INSERT INTO customer_rangepartition (
SELECT * FROM customers);

# Check to see if all partitions have data
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_rangepartition'; 

# validate if the partitioning is working ( P0 partition has 32 customers )
Select count(*) from customers where customerNumber < 200;

# truncate data from partition 0
ALTER TABLE customer_rangepartition TRUNCATE PARTITION p0;

# Check to see if data from partition 0 is truncated
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_rangepartition'; 

# Drop Partition 0
ALTER TABLE customer_rangepartition DROP PARTITION p0;

# Check to see if partition 0 is dropped
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_rangepartition'; 

# Alter table to data refresh by adding Partitions
ALTER TABLE customer_rangepartition ADD PARTITION (PARTITION p4 VALUES LESS THAN (600));

# Add Partition on the fly
SELECT 
    PARTITION_NAME, TABLE_ROWS
FROM
    INFORMATION_SCHEMA.PARTITIONS
WHERE
    TABLE_NAME = 'customer_rangepartition'; 
    
SELECT 
    *
FROM
    customer_rangepartition 
WHERE
    contactLastName LIKE 'S%';
    
SELECT 
    *
FROM
    customer_rangepartition PARTITION (p0 , p2)
WHERE
    contactLastName LIKE 'S%';


# Drop customer_partitioned table
drop table customer_rangepartition;

################### List Partitioning ###################
# each partition is defined and selected based on the membership of a column value in one of a set of value lists, rather than in one of a set of contiguous ranges of values
CREATE TABLE customers_listpartition (
  `customerNumber` int(11) NOT NULL,
  `customerName` varchar(50) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `addressLine1` varchar(50) NOT NULL,
  `addressLine2` varchar(50) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `salesRepEmployeeNumber` int(11) DEFAULT NULL,
  `creditLimit` decimal(10,2) DEFAULT NULL
)  PARTITION BY LIST COLUMNS (country) 
(PARTITION pcountry_a VALUES IN ('Australia' , 'Austria' , 'Belgium', 'Canada', 'Denmark' ) , 
 PARTITION pcountry_b VALUES IN ('Finland' , 'France', 'Germany', 'Hong Kong', 'Ireland','Israel', 'Italy' ) , 
 PARTITION pcountry_c VALUES IN ('Japan' , 'Netherlands', 'New Zealand', 'Norway', 'Philippines', 'Poland'),
 PARTITION pcountry_d VALUES IN ('Portugal' , 'Russia', 'Singapore', 'South Africa', 'Spain', 'Sweden', 'Switzerland','UK','USA')); 
 
# Check to see if partitions were created
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customers_listpartition'; 

# insert data from customers table 
INSERT INTO customers_listpartition (
SELECT * FROM customers);

# check to see the data into partitions
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customers_listpartition'; 

# validate results
SELECT 
    COUNT(*)
FROM
    customers
WHERE
    country IN ('Australia' , 'Austria',
        'Belgium',
        'Canada',
        'Denmark');



# Drop customer_partitioned table
DROP TABLE customers_listpartition;


################### Hash Partitioning ###################
# Distribute data among a predefined number of partitions on a column value or expression based on a column value.
CREATE TABLE customer_hashpartition (
  `customerNumber` int(11) NOT NULL,
  `customerName` varchar(50) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `addressLine1` varchar(50) NOT NULL,
  `addressLine2` varchar(50) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `salesRepEmployeeNumber` int(11) DEFAULT NULL,
  `creditLimit` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`customerNumber`)
) PARTITION BY HASH (customerNumber) PARTITIONS 8; 

# Check to see if partitions were created
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_hashpartition'; 

# insert data from customers table 
INSERT INTO customer_hashpartition (
SELECT * FROM customers);

# check to see the data into partitions
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_hashpartition';
SELECT 
    *
FROM
    customer_hashpartition PARTITION (p0);

# Drop customer_partitioned table
DROP TABLE customer_hashpartition;


################### Key Partitioning ###################
# special form of HASH partition, where the hashing function for key partitioning is supplied by the MySQL server
CREATE TABLE customer_keypartition (
  `customerNumber` int(11) NOT NULL,
  `customerName` varchar(50) NOT NULL,
  `contactLastName` varchar(50) NOT NULL,
  `contactFirstName` varchar(50) NOT NULL,
  `phone` varchar(50) NOT NULL,
  `addressLine1` varchar(50) NOT NULL,
  `addressLine2` varchar(50) DEFAULT NULL,
  `city` varchar(50) NOT NULL,
  `state` varchar(50) DEFAULT NULL,
  `postalCode` varchar(15) DEFAULT NULL,
  `country` varchar(50) NOT NULL,
  `salesRepEmployeeNumber` int(11) DEFAULT NULL,
  `creditLimit` decimal(10,2) DEFAULT NULL,
  PRIMARY KEY (`customerNumber`)
) PARTITION BY KEY(customerNumber) 
PARTITIONS 8;

# Check to see if partitions were created
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_keypartition'; 

# insert data from customers table 
INSERT INTO customer_keypartition (
SELECT * FROM customers);

# check to see the data into partitions
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='customer_keypartition';
SELECT 
    *
FROM
    CUSTOMER_KEYPARTITION PARTITION (p0);

# Drop customer_partitioned table
DROP TABLE customer_keypartition;

################### Sub-Partitioning ###################
# method to divide each partition further in a partitioned table
CREATE TABLE orders_subpartition (
  `orderNumber` int(11) NOT NULL,
  `orderDate` date NOT NULL,
  `requiredDate` date NOT NULL,
  `shippedDate` date DEFAULT NULL,
  `status` varchar(15) NOT NULL,
  `comments` text,
  `customerNumber` int(11) NOT NULL
) PARTITION BY RANGE (YEAR(orderDate)) 
SUBPARTITION BY HASH (TO_DAYS(orderDate)) 
SUBPARTITIONS 3 (
	PARTITION p0 VALUES LESS THAN (2015) , 
    PARTITION p1 VALUES LESS THAN (2016),
	PARTITION p2 VALUES LESS THAN MAXVALUE); 
    
# Check to see if partitions were created
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='orders_subpartition'; 

# insert data from customers table 
INSERT INTO orders_subpartition (
SELECT * FROM orders);

# check to see the data into partitions
SELECT PARTITION_NAME, SUBPARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='orders_subpartition'; 
SELECT PARTITION_NAME, TABLE_ROWS FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='orders_subpartition'; 

SELECT PARTITION_NAME FROM INFORMATION_SCHEMA.PARTITIONS WHERE TABLE_NAME='orders_subpartition' GROUP BY PARTITION_NAME;

# Drop customer_partitioned table
DROP TABLE orders_subpartition;

---- END ----

# References
# http://www.w3resource.com/mysql/mysql-partition.php
# http://www.mysqltutorial.org/

# Use case for partitioning
# data is collected on a daily basis from a set of 124 grocery stores. Each days data was completely distinct from every other days. We partitioned the data on the date. This allowed us to have faster searches because oracle can use partitioned indexes and quickly eliminate all of the non-relevant days. This also allows for much easier backup operations because you can work in just the new partitions. Also after 5 years of data we needed to get rid of an entire days data. You can "drop" or eliminate an entire partition at a time instead of deleting rows. So getting rid of old data was a snap.



