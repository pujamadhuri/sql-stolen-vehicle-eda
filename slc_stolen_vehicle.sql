/*
Project: Stolen Vehicle Data SLC 2012 & 2013 – MySQL Exploratory Data Analysis
Description:
This project performs end-to-end data cleaning, deduplication, transformation,
and exploratory data analysis (EDA) using MySQL.

Approach:
- Raw datasets are preserved using backup tables
- Staging tables are used for cleaning and validation
- Data types are standardized in the final analytics table
- EDA queries focus on time, location, and behavioral patterns

Tools: MySQL 8.0+
*/
CREATE TABLE SLC_stolenvehicles.slc_2013(
`CASE` TEXT, 
OFFENSE TEXT,
`OFFENSE DESCRIPTION` TEXT,
`REPORT DATE` TEXT,
`OCCUR DATE` TEXT,
`DAY OF WEEK` TEXT,
LOCATION TEXT,
LOCATION1 TEXT);


SELECT *
FROM SLC_stolenvehicles.slc_2013;

CREATE TABLE slc_2012_backup AS SELECT * 
FROM SLC_stolenvehicles.slc_2012;

CREATE TABLE slc_2013_backup AS SELECT * 
FROM SLC_stolenvehicles.slc_2013;


CREATE TABLE slc_2012_staging AS
SELECT * FROM slc_2012;

CREATE TABLE slc_2013_staging AS
SELECT * FROM slc_2013;

SELECT *
FROM SLC_stolenvehicles.slc_2013_staging;

SELECT `CASE`, `REPORT DATE`, COUNT(*) 
FROM slc_2012_staging
GROUP BY `CASE`, `REPORT DATE`
HAVING COUNT(*) > 1;

SELECT `CASE`, `REPORT DATE`, COUNT(*) 
FROM slc_2013_staging
GROUP BY `CASE`, `REPORT DATE`
HAVING COUNT(*) > 1;


-- A CTE was used with ROW_NUMBER() to identify duplicate records
-- However, CTEs are not updatable in MySQL
-- To safely remove duplicates, a second staging table "slc_2013_staging2" was created
-- The row numbers were stored in this table and duplicate rows were deleted

SELECT *,
ROW_NUMBER()OVER(
PARTITION BY `CASE`, `REPORT DATE`
ORDER BY `REPORT DATE`) AS row_num
FROM SLC_stolenvehicles.slc_2013_staging;

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY `CASE`, `REPORT DATE`
ORDER BY `REPORT DATE`) AS row_num
FROM SLC_stolenvehicles.slc_2013_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY `CASE`, `REPORT DATE`
ORDER BY `REPORT DATE`) AS row_num
FROM SLC_stolenvehicles.slc_2013_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `slc_2013_staging2` (
  `CASE` text,
  `OFFENSE` text,
  `OFFENSE DESCRIPTION` text,
  `REPORT DATE` text,
  `OCCUR DATE` text,
  `DAY OF WEEK` text,
  `LOCATION` text,
  `Location 1` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM SLC_stolenvehicles.slc_2013_staging2;

INSERT INTO SLC_stolenvehicles.slc_2013_staging2
(`CASE`,
  `OFFENSE`,
  `OFFENSE DESCRIPTION`,
  `REPORT DATE`,
  `OCCUR DATE`,
  `DAY OF WEEK`,
  `LOCATION`,
  `Location 1`,
  `row_num`)
SELECT *,
ROW_NUMBER() OVER(PARTITION BY `CASE`, `REPORT DATE`
ORDER BY `REPORT DATE`) as row_num
FROM SLC_stolenvehicles.slc_2013_staging;


SELECT *
FROM SLC_stolenvehicles.slc_2013_staging2
WHERE OFFENSE = 2404-0;


-- Remove duplicate records where row_num > = 2
-- The earliest occurrence (row_num = 1) is retained
SELECT *
 FROM SLC_stolenvehicles.slc_2013_staging2
WHERE row_num >=2;
DELETE FROM SLC_stolenvehicles.slc_2013_staging2
WHERE row_num >=2;


-- Convert date fields from TEXT to DATE/DATETIME format
UPDATE SLC_stolenvehicles.slc_2013_staging2
SET `REPORT DATE` = STR_TO_DATE(`REPORT DATE`, '%Y %b %d %r');

UPDATE SLC_stolenvehicles.slc_2012_staging
SET `REPORT DATE` = STR_TO_DATE(`REPORT DATE`, '%m/%d/%Y');

SELECT *
FROM SLC_stolenvehicles.slc_2013_staging2;
UPDATE SLC_stolenvehicles.slc_2013_staging2
SET `OCCUR DATE` = STR_TO_DATE(`OCCUR DATE`, '%Y %b %d %r');
UPDATE SLC_stolenvehicles.slc_2012_staging
SET `OCC DATE` = STR_TO_DATE(`OCC DATE`, '%Y %b %d %r');


ALTER TABLE SLC_stolenvehicles.slc_2013_staging2
DROP COLUMN row_num;

-- Check all distinct years in 2012 staging
SELECT DISTINCT YEAR(`REPORT DATE`) AS year, COUNT(*) 
FROM SLC_stolenvehicles.slc_2012_staging
GROUP BY year
ORDER BY year;

-- Check all distinct years in 2013 staging
SELECT DISTINCT YEAR(`REPORT DATE`) AS year, COUNT(*) 
FROM SLC_stolenvehicles.slc_2013_staging2
GROUP BY year
ORDER BY year;

UPDATE SLC_stolenvehicles.slc_2013_staging2
SET `REPORT DATE` = STR_TO_DATE(`REPORT DATE`, '%m/%d/%Y')
WHERE YEAR(`REPORT DATE`) = 2014;

SELECT *
FROM SLC_stolenvehicles.slc_2013_staging2
WHERE YEAR(`REPORT DATE`) NOT IN (2013);


-- Remove records outside the expected year range
-- to ensure dataset consistency
DELETE FROM SLC_stolenvehicles.slc_2013_staging2
WHERE YEAR(`REPORT DATE`) != 2013;

SELECT *
FROM SLC_stolenvehicles.slc_2012_staging;

SELECT *
FROM SLC_stolenvehicles.slc_2013_staging2; 

ALTER TABLE SLC_stolenvehicles.slc_2012_staging
RENAME COLUMN `OFFENSE CODE` TO `OFFENSE`;



-- Create final consolidated analytics table
-- This table contains cleaned, validated data
-- and is used for all EDA queries
CREATE TABLE SLC_stolenvehicles.slc_stolen_final AS
SELECT `CASE`, `OFFENSE`, `OFFENSE DESCRIPTION`, `REPORT DATE`, `OCC DATE`, `DAY OF WEEK`, `LOCATION`, `Location 1`
FROM SLC_stolenvehicles.slc_2012_staging
UNION ALL
SELECT `CASE`, `OFFENSE`, `OFFENSE DESCRIPTION`, `REPORT DATE`, `OCCUR DATE`, `DAY OF WEEK`, `LOCATION`, `Location 1`
FROM SLC_stolenvehicles.slc_2013_staging2;


-- Analyze total vehicle thefts by year
SELECT 
    YEAR(`REPORT DATE`) AS year,
    COUNT(*) AS total_thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY year
ORDER BY year;


-- Identify monthly trends and seasonality
SELECT 
    YEAR(`REPORT DATE`) AS year,
    MONTHNAME(`REPORT DATE`) AS month,
    MONTH(`REPORT DATE`) AS month_num,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY year, month, month_num
ORDER BY year, month_num;


-- Determine locations with highest theft activity
SELECT 
    LOCATION,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY LOCATION
ORDER BY thefts DESC
LIMIT 10;


-- Compare theft frequency across days of the week
SELECT 
    `DAY OF WEEK`,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY `DAY OF WEEK`
ORDER BY thefts DESC;


-- Compare weekday vs weekend theft patterns
SELECT
    CASE
        WHEN `DAY OF WEEK` IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY day_type;


-- Calculate average monthly thefts per year
SELECT
    YEAR(`REPORT DATE`) AS year,
    ROUND(COUNT(*) / 12, 2) AS avg_monthly_thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY year;


-- Identify peak hours for vehicle thefts
SELECT 
    HOUR(`REPORT DATE`) AS hour,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY hour
ORDER BY thefts DESC;


-- Analyze seasonal distribution of thefts
SELECT
    CASE
        WHEN MONTH(`REPORT DATE`) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(`REPORT DATE`) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(`REPORT DATE`) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END AS season,
    COUNT(*) AS thefts
FROM SLC_stolenvehicles.slc_stolen_final
GROUP BY season
ORDER BY thefts DESC;


ALTER TABLE SLC_stolenvehicles.slc_stolen_final
MODIFY `CASE` VARCHAR(50),
MODIFY OFFENSE VARCHAR(20),
MODIFY `OFFENSE DESCRIPTION` VARCHAR(255),
MODIFY `REPORT DATE` DATETIME,
MODIFY `OCC DATE` DATETIME,
MODIFY `DAY OF WEEK` VARCHAR(10),
MODIFY LOCATION VARCHAR(255),
MODIFY `Location 1` VARCHAR(255);

SELECT *
FROM SLC_stolenvehicles.slc_stolen_final;






















