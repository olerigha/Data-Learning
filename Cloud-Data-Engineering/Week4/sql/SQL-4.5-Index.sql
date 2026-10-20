/***********************************************
** Name:        SQL Indexes
** Description: Data structures that speed up row lookups; used to optimize SELECT query performance on large tables
** Author:      Ashish Pujari
************************************************/

# show all indexes in the classicmodels schema
SELECT DISTINCT
    TABLE_NAME, INDEX_NAME
FROM
    INFORMATION_SCHEMA.STATISTICS
WHERE
    TABLE_SCHEMA = 'classicmodels';

# show all indexes on an existing table 
SHOW INDEX FROM customers;

# create a new index on the customers table based on city
CREATE INDEX cityIndex
  ON customers (city);
  
# show all indexes on an existing table 
SHOW INDEX FROM customers;

# The index is used when the below query (WHERE clause with city) is executed 
SELECT 
    customerNumber,
    contactFirstName,
    contactLastName,
    city,
    state
FROM
    CUSTOMERS
WHERE
    city = 'Auckland';

# create a new index on the customers table based on city,state
CREATE INDEX cityState_index
  ON customers (city, state);

# check to see indexes were created
SHOW INDEX FROM customers;

ALTER TABLE customers
  RENAME INDEX cityState_index TO cityStateIndex;

# drop the index created
ALTER TABLE customers DROP INDEX cityIndex;
ALTER TABLE customers DROP INDEX cityStateIndex;

# check to see if the index is dropped
SHOW INDEX FROM customers;
