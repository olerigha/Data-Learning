/***********************************************
** Name:        SQL DDL (Data Definition Language)
** Description: Commands for creating, altering, and dropping databases, tables, and constraints
** Author:      Ashish Pujari
************************************************/

#Show the list of databases
SHOW DATABASES;

#Drop the classicModels_temp database if it already exists	
DROP DATABASE IF EXISTS classicmodels_temp;

#Create classicmodels_temp database
CREATE DATABASE IF NOT EXISTS classicmodels_temp;

#Select the classicmodels_temp database where the tables needs to be created
USE classicmodels_temp;

#Shows the list of all tables in the database
SHOW TABLES;

#Create office table
DROP TABLE IF EXISTS `offices`;

CREATE TABLE `offices` (
  `officeCode` VARCHAR(10) NOT NULL,
  `city` VARCHAR(50) NOT NULL,
  `phone` VARCHAR(50) NOT NULL,
  `addressLine1` VARCHAR(50) NOT NULL,
  `addressLine2` VARCHAR(50) DEFAULT NULL,
  `state` VARCHAR(50) DEFAULT NULL,
  `country` VARCHAR(50) NOT NULL,
  `postalCode` VARCHAR(15) NOT NULL,
  `territory` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`officeCode`)
) ENGINE=INNODB DEFAULT CHARSET=LATIN1;

#Provides information on table structure 
DESCRIBE offices;

#Check the offices table - columns 
SELECT * FROM offices;

#Insert data into the offices table
INSERT INTO `offices`
	(`officeCode`,`city`,`phone`,`addressLine1`,`addressLine2`,`state`,`country`,`postalCode`,`territory`) 
VALUES 
('1','San Francisco','+1 650 219 4782','100 Market Street','Suite 300','CA','USA','94080','NA'),
('2','Boston','+1 215 837 0825','1550 Court Place','Suite 102','MA','USA','02107','NA'),
('3','NYC','+1 212 555 3000','523 East 53rd Street','apt. 5A','NY','USA','10022','NA'),
('4','Paris','+33 14 723 4404','43 Rue Jouffroy D\'abbans',NULL,NULL,'France','75017','EMEA'),
('5','Tokyo','+81 33 224 5000','4-1 Kioicho',NULL,'Chiyoda-Ku','Japan','102-8578','Japan'),
('6','Sydney','+61 2 9264 2451','5-11 Wentworth Avenue','Floor #2',NULL,'Australia','NSW 2010','APAC'),
('7','London','+44 20 7877 2041','25 Old Broad Street','Level 7',NULL,'UK','EC2N 1HN','EMEA');

#get the count of records (rows ) loaded
SELECT COUNT(*) FROM offices;

#check the data load
SELECT * FROM offices;

#expand city name FROM NYC TO New York City
UPDATE offices 
SET 
    city = 'New York City'
WHERE
    city = 'NYC';
    
#ERROR - User can't update or delete records without specifying a key (ex. primary key) in the where clause
SET SQL_SAFE_UPDATES = 0;

#expand city name from NYC TO New York City
UPDATE offices 
SET 
    city = 'New York City'
WHERE
    city = 'NYC';
	
#check to see if the data was correctly updated   
SELECT * FROM offices WHERE officeCode=3;

#check info on tables
SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA='classicmodels_temp' 
        AND table_name='offices';
	
#update table comments to provide more information on the table
ALTER TABLE `offices` COMMENT 'All Office Locations';

#check to see if the table comments are updated
SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA='classicmodels_temp' 
        AND table_name='offices';
	
#create employees table
DROP TABLE IF EXISTS `employes`;

CREATE TABLE `employes` (
  `employeeNumber` INT(11) NOT NULL,
  `lastName` VARCHAR(50) NOT NULL,
  `firstName` VARCHAR(50) NOT NULL,
  `extension` VARCHAR(10) NOT NULL,
  `email` VARCHAR(100) NOT NULL,
  `officeCode` VARCHAR(10) NOT NULL,
  `reportsTo` INT(11) DEFAULT NULL,
  `jobTitle` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`employeeNumber`),
  KEY `reportsTo` (`reportsTo`),
  KEY `officeCode` (`officeCode`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`reportsTo`) REFERENCES `employes` (`employeeNumber`),
  CONSTRAINT `employees_ibfk_2` FOREIGN KEY (`officeCode`) REFERENCES `offices` (`officeCode`)
) ENGINE=INNODB DEFAULT CHARSET=LATIN1;


#update the table name from "employes" to "employees"
RENAME TABLE employes TO employees;  
 
#provides information on table structure 
DESCRIBE employees;

#shows the list of all tables in the database
SHOW TABLES;

#check employees table - columns
SELECT * FROM employees;

#use import csv functionality in mysql to upload data

#enable file load 
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

#show folder where the file can be loaded from
SHOW VARIABLES LIKE "secure_file_priv";

#load file from the server itself (if running this command on server)
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Employees.csv' INTO TABLE employees FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

#load file from a client to a server (if client and server are different)
#LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Employees.csv' INTO TABLE employees FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n';

#verify data was loaded 
SELECT COUNT(*) FROM employees;

#add a new field for each employee (SSN)
#if the field is marked NOT NULL we will need to drop and recreate the data
ALTER TABLE employees 
ADD COLUMN ssn VARCHAR(10) NULL 
AFTER jobTitle;

#verify the newly created column 
DESCRIBE employees;

#delete the data from the employees table. does it succeed ? 
#President cannot be deleted because other employees report to this person
DELETE FROM employees 
WHERE employeeNumber = 1002;

#remove FK references to this employee and then delete this employee
UPDATE employees 
SET reportsTo = NULL 
WHERE reportsTo = 1002;

#Sales rep can be deleted because no other employee reports to this person
#no FK references to this employee 
DELETE FROM employees 
WHERE employeeNumber = 1702;

#Delete all the data in the offices table. does it succeed ? 
TRUNCATE TABLE offices;

#Need to drop employees table first
DROP TABLE employees;

#Delete the data in the offices table 
TRUNCATE TABLE offices;

#Check data from offices
SELECT * FROM offices;

#Drop table offices
DROP TABLE offices;

#Drop database
DROP DATABASE classicmodels_temp;

#Show the list of databases
SHOW DATABASES;