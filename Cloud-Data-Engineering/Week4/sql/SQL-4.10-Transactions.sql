/***********************************************
** Name:        SQL Transactions
** Description: Group multiple SQL statements into an atomic unit; used to ensure data consistency and manage concurrent access
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### TRANSACTIONS ###################
# START TRANSACTION, COMMIT,and ROLLBACK

# start a new transaction
START TRANSACTION;

# force MySQL not to commit changes automatically
SET AUTOCOMMIT = 0;

# list all offices
SELECT * FROM offices;

# insert data relating to new offices into offices table
INSERT INTO `offices`(`officeCode`,`city`,`phone`,`addressLine1`,`addressLine2`,`state`,`country`,`postalcode`, `territory`) values 
('8', 'Chicago', '+1 312 219 4782', '100 clinton Street', 'Suite 300', 'IL', 'USA', '60661', 'NA'),
('9', 'Austin', '+1 512 974 9315', '500 Rutherford Lane', 'Suite 100', 'TX', 'USA', '78754', 'NA');

# list the offices and make sure the additional entries are reflected
SELECT * FROM offices;

# rollback the updates
ROLLBACK;

# notice that on ROLLBACK additional offices are not reflected in the offices table
SELECT * FROM offices;

# insert data again relating to new offices into offices table
INSERT INTO `offices`(`officeCode`,`city`,`phone`,`addressLine1`,`addressLine2`,`state`,`country`,`postalcode`, `territory`) values 
('8', 'Chicago', '+1 312 219 4782', '100 clinton Street', 'Suite 300', 'IL', 'USA', '60661', 'NA'),
('9', 'Austin', '+1 512 974 9315', '500 Rutherford Lane', 'Suite 100', 'TX', 'USA', '78754', 'NA');

# commit the above transaction
COMMIT;

# notice that once committed the transaction takes place and we have additional offices reflected
SELECT * FROM offices;

# delete the records that were added
SET SQL_SAFE_UPDATES=0;
DELETE FROM offices 
WHERE
    officecode IN (8 , 9);
    
# enable the default autocommit
SET autocommit = 1;