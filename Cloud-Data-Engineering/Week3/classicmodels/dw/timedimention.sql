use classicmodelsdw;

SET SQL_SAFE_UPDATES = 0;

###### small-numbers table
#DROP TABLE IF EXISTS numbers_small;
#CREATE TABLE numbers_small (number INT);
INSERT INTO numbers_small VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

###### main numbers table
#DROP TABLE IF EXISTS numbers;
#CREATE TABLE numbers (number BIGINT);
INSERT INTO numbers
SELECT thousands.number * 1000 + hundreds.number * 100 + tens.number * 10 + ones.number
  FROM numbers_small thousands, numbers_small hundreds, numbers_small tens, numbers_small ones
LIMIT 1000000;

###### date table
DROP TABLE IF EXISTS dimTime;
CREATE TABLE dimTime (
  dateId          BIGINT PRIMARY KEY, 
  date             DATE NOT NULL,
  timestamp        BIGINT , 
  weekend          CHAR(10) NOT NULL DEFAULT "Weekday",
  day_of_week      CHAR(10) ,
  month            CHAR(10) ,
  month_day        INT , 
  year             INT ,
  week_starting_monday CHAR(2) ,
  UNIQUE KEY `date` (`date`),
  KEY `year_week` (`year`,`week_starting_monday`)
);

###### populate it with days
INSERT INTO dimTime (dateId, date)
SELECT number, DATE_ADD( '2014-01-01', INTERVAL number DAY )
  FROM numbers
  WHERE DATE_ADD( '2014-01-01', INTERVAL number DAY ) BETWEEN '2014-01-01' AND '2017-01-01'
  ORDER BY number;

###### fill in other rows
UPDATE dimTime SET
  timestamp =   UNIX_TIMESTAMP(date),
  day_of_week = DATE_FORMAT( date, "%W" ),
  weekend =     IF( DATE_FORMAT( date, "%W" ) IN ('Saturday','Sunday'), 'Weekend', 'Weekday'),
  month =       DATE_FORMAT( date, "%M"),
  year =        DATE_FORMAT( date, "%Y" ),
  month_day =   DATE_FORMAT( date, "%d" );

UPDATE dimTime SET week_starting_monday = DATE_FORMAT(date,'%v');