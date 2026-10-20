/***********************************************
** Name:        Database Administration
** Description: Managing user accounts, roles, and privileges; used to control access and secure the database
** Author:      Ashish Pujari
************************************************/

################### DB ADMINISTRATION ###################
# DBA - managing user accounts, roles, privileges, and profiles 

# A consultant is hired and he/she needs access to the Orders table to solve a business problem. Access can be given based on the requirements and once the work is complete the access rights to the table can be revoked.
CREATE USER 'manager'@'localhost' IDENTIFIED BY 'manager';
CREATE USER 'salesrep'@'localhost' IDENTIFIED BY 'sales';

# grant user salesrep all privileges to the orders tables */
GRANT ALL ON orders TO 'salesrep'@'localhost';

# grant execute the SELECT, INSERT and UPDATE statements against the classicmodels database
GRANT SELECT, INSERT, UPDATE, DELETE ON  classicmodels.* TO 'manager'@'localhost';

# update password for user salesrep
SET PASSWORD FOR 'salesrep'@'localhost' = PASSWORD('salesrep');

# now login as 'salesrep'@'localhost' and manager'@'localhost
# run the below insert statement and make sure it succeeds for manager and not for salesrep user.
INSERT INTO 
OFFICES 
(officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory ) 
VALUES 
('11', 'Paris', '+33 14 723 5555', '43 Rue Jouffroy D\'abbans', NULL, NULL, 'France', '75017', 'EMEA' );


# revoke all privileges from the orders table for user manager & salesrep 
REVOKE ALL ON orders FROM 'manager'@'localhost';
REVOKE SELECT, UPDATE, DELETE ON classicmodels.* FROM 'salesrep'@'localhost';

DROP USER 'manager'@'localhost';
DROP USER 'salesrep'@'localhost';

# LOCK / UNLOCK
# client session to acquire a table lock explicitly for preventing other sessions from accessing the table offices during a specific period.
LOCK TABLE offices READ;

# try inserting data into the offices table
INSERT INTO 
OFFICES 
(officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory ) 
VALUES 
('11', 'Paris', '+33 14 723 5555', '43 Rue Jouffroy D\'abbans', NULL, NULL, 'France', '75017', 'EMEA' );

# will get an error. unlock all tables.
UNLOCK TABLES;

# try insert a record after the unlock.
INSERT INTO 
OFFICES 
(officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory ) 
VALUES 
('11', 'Paris', '+33 14 723 5555', '43 Rue Jouffroy D\'abbans', NULL, NULL, 'France', '75017', 'EMEA' );

# check to see if the data is inserted in the office table
select * from offices;

# delete the data inserted.
SET SQL_SAFE_UPDATES=0;
DELETE FROM offices 
WHERE
    officecode=11;

#ref : http://www.mysqltutorial.org/
	

################### SINGLE TABLE/DATA BACKUPS ######################
CREATE TABLE classicmodels.offices_bkup LIKE classicmodels.offices;
INSERT INTO classicmodels.offices_bkup (SELECT * FROM classicmodels.offices);

# alternatively
CREATE TABLE IF NOT EXISTS offices_bkup 
SELECT 
	* 
FROM
	offices;

select * from offices_bkup;

# compare 2 tables to make sure the backup and the original tables are the same
SELECT 
    *
FROM
    (SELECT 
        *
    FROM
        offices UNION ALL SELECT 
        *
    FROM
        offices_bkup) tbl
GROUP BY officeCode, city
HAVING COUNT(*) = 1
ORDER BY officeCode;

# Insert additional data into the original table
INSERT INTO 
OFFICES 
(officeCode, city, phone, addressLine1, addressLine2, state, country, postalCode, territory ) 
VALUES 
('11', 'Paris', '+33 14 723 5555', '43 Rue Jouffroy D\'abbans', NULL, NULL, 'France', '75017', 'EMEA' );

# compare 2 tables to make sure the new record is reflected.
SELECT 
    *
FROM
    (SELECT 
        *
    FROM
        offices UNION ALL SELECT 
        *
    FROM
        offices_bkup) tbl
GROUP BY officeCode, city
HAVING COUNT(*) = 1
ORDER BY officeCode;

# delete the data inserted.
SET SQL_SAFE_UPDATES=0;
DELETE FROM offices 
WHERE
    officecode=11;

# drop the backup table    
DROP table offices_bkup;

################### Temp tables ###################
# Temporary table is a special type of table that allows you to store a temporary result set, which you can reuse several times in a single session.

# Top 10 customers by revenue
CREATE TEMPORARY TABLE top10customers
SELECT p.customerNumber, 
       c.customerName, 
       FORMAT(SUM(p.amount),2) total
FROM payments p
INNER JOIN customers c ON c.customerNumber = p.customerNumber
GROUP BY p.customerNumber
ORDER BY total DESC
LIMIT 10;

# retrieve data from the temp table top10customers
SELECT * FROM top10customers;

# Drop the temporary table
DROP TEMPORARY TABLE top10customers;