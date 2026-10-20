/***********************************************
** Name:        SQL Stored Procedures and Triggers
** Description: Reusable SQL code blocks stored in the database; used to encapsulate business logic and automate actions on data events
** Author:      Ashish Pujari
************************************************/

# select database
USE classicmodels;

################### Stored procedures ###################
# Segment of declarative SQL statements stored inside the database catalog. A stored procedure can be invoked by triggers, other stored procedures, and applications such as Java, Python, PHP, etc.

# create a stored procedure that will pull all products from the products table
DELIMITER //
 CREATE PROCEDURE GetAllProducts() 
   BEGIN
   SELECT *  FROM products;
   END //
DELIMITER ;

# check to see if the stored procedure was created
SHOW PROCEDURE STATUS WHERE db = 'classicmodels';
SHOW CREATE PROCEDURE GetAllProducts;

# execute ( call ) the stored procedure and make sure we it aligns with the 110 records from the products table.
CALL GetAllProducts();

# validate
SELECT 
    *
FROM
    products;


# Use of parameters within stored procedures
# Create a stored procedure that will take customer number as input and will provide details based on status 
DELIMITER //
CREATE PROCEDURE get_order_by_cust(
 IN cust_no INT,
 OUT shipped INT,
 OUT canceled INT,
 OUT resolved INT,
 OUT disputed INT)
BEGIN
	 -- shipped
	SELECT
		COUNT(*)
	INTO shipped FROM
		orders
	WHERE
		customerNumber = cust_no
			AND status = 'Shipped';

	 -- canceled
	SELECT 
		COUNT(*)
	INTO canceled FROM
		orders
	WHERE
		customerNumber = cust_no
			AND status = 'Canceled';
	 
	 -- resolved
	SELECT 
		COUNT(*)
	INTO resolved FROM
		orders
	WHERE
		customerNumber = cust_no
			AND status = 'Resolved';
	 
	 -- disputed
	SELECT 
		COUNT(*)
	INTO disputed FROM
		orders
	WHERE
		customerNumber = cust_no
			AND status = 'Disputed';
 
END //
DELIMITER ;

# find the status of all orders for customer 141
CALL get_order_by_cust(141,@shipped,@canceled,@resolved,@disputed);
SELECT @shipped,@canceled,@resolved,@disputed;
SELECT 
    *
FROM
    customers
WHERE
    customerNumber = 141;
    

# Drop stored procedure
DROP PROCEDURE GetAllProducts;
DROP PROCEDURE get_order_by_cust;

################### Triggers ###################
# stored program executed automatically to respond to a specific event e.g.,  insert, update or delete occurred in a table. The main difference between a trigger and a stored procedure is that a trigger is called automatically when a data modification event is made against a table whereas a stored procedure must be called explicitly

# Log old price in a separate table named price_logs when there is a change in the price of a product (column MSRP )
# create a new price_logs table
CREATE TABLE price_logs (
    id INT(11) NOT NULL AUTO_INCREMENT,
    product_code VARCHAR(15) NOT NULL,
    price DOUBLE NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY product_code (product_code),
    CONSTRAINT price_logs_ibfk_1 FOREIGN KEY (product_code)
        REFERENCES products (productCode)
        ON DELETE CASCADE ON UPDATE CASCADE
);

# check the price logs table to make sure there are no records
SELECT * FROM price_logs;

# create a trigger that activates when the BEFORE UPDATE event of the products table occurs
DELIMITER $$ 
CREATE TRIGGER before_products_update 
   BEFORE UPDATE ON products 
   FOR EACH ROW 
BEGIN
     INSERT INTO price_logs(product_code,price)
     VALUES(old.productCode,old.msrp);
END $$
 
DELIMITER ;

# Check to make sure the trigger is created
SHOW TRIGGERS FROM classicmodels
WHERE `table` = 'products';

# change the price of a product and query the price_logs table using the following UPDATE statement:
UPDATE products 
SET 
    msrp = 95.1
WHERE
    productCode = 'S10_1678';

# check the price logs table to make sure the old value is saved
SELECT 
    *
FROM
    price_logs;

# We want to see not only the old price and when it was changed but also who changed it. 
# Add additional columns to the price_logs table. However, for the purpose of multiple triggers demonstration, we will create a new table user_change_logs to store the data of users who made the changes.
# create a user_change_logs table
CREATE TABLE user_change_logs (
    id INT(11) NOT NULL AUTO_INCREMENT,
    product_code VARCHAR(15) DEFAULT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by VARCHAR(30) NOT NULL,
    PRIMARY KEY (id),
    KEY product_code (product_code),
    CONSTRAINT user_change_logs_ibfk_1 FOREIGN KEY (product_code)
        REFERENCES products (productCode)
        ON DELETE CASCADE ON UPDATE CASCADE
);


# Now, we create a second trigger that activates on the BEFORE UPDATE event of the products table. This trigger will update the user_change_logs table with the data of the user who made the changes. It is activated after the before_products_update trigger.
DELIMITER $$
CREATE TRIGGER before_products_update_2 
   BEFORE UPDATE ON products 
   FOR EACH ROW FOLLOWS before_products_update
BEGIN
   INSERT INTO user_change_logs(product_code,updated_by)
   VALUES(old.productCode,user());
END$$
 
DELIMITER ;

# First, we update the prices of the product using the UPDATE statement as follows:
UPDATE products 
SET 
    msrp = 95.3
WHERE
    productCode = 'S10_1678';

# Second, we query the data from both price_logs and user_change_logs tables:
SELECT * FROM price_logs;
SELECT * FROM user_change_logs;

# Information On Triggers Order. The first one does not show order while the second query shows ordering
SHOW TRIGGERS FROM classicmodels;

SELECT 
# trigger_name, action_order
* 
FROM
    information_schema.triggers
WHERE
    trigger_schema = 'classicmodels'
ORDER BY event_object_table , 
         action_timing , 
         event_manipulation;


# Drop all databse objects ( triggers & tables ) 
DROP TABLE IF EXISTS `price_logs`;
DROP TABLE IF EXISTS `user_change_logs`;

# Note: Triggers don't exist at the table level. They are database level objects that are just associated with tables. There is no means to delete them by related table.
DROP TRIGGER IF EXISTS `before_products_update`;
DROP TRIGGER IF EXISTS `before_products_update_2`;

---- END ----

#ref : http://www.mysqltutorial.org/
