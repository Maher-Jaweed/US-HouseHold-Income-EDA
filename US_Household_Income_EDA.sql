#DATA CLEANING:

SELECT * 
FROM us_household_income_statistics
;

SELECT * 
FROM us_household_income
;

#Rename Column 
ALTER TABLE us_household_income_statistics
	RENAME COLUMN `ï»¿id` TO `id`
;

#Check for Duplicates 
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id 
HAVING Count(id) > 1
;

#Duplicates have been found. Identify duplicates
SELECT *
FROM(
SELECT row_id,
id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM us_household_income
) duplicates
WHERE row_num > 1
;

#Delete Identified Duplicates 
DELETE FROM us_household_income
Where row_id IN (
	SELECT row_id
	FROM(
		SELECT row_id, id,
		ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
		FROM us_household_income
		) duplicates
	WHERE row_num > 1)
;

#Check for Duplicates  
SELECT id, COUNT(id)
FROM us_household_income_statistics
GROUP BY id 
HAVING Count(id) > 1
;

#Observed "Alabama", spelled as "alabama". The following query does not identify this issue, but highlights other data quality issues
SELECT State_Name, Count(State_Name)
FROM us_household_income
GROUP BY State_Name
;

UPDATE us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia'
;

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alamaba'
;

SELECT * 
FROM us_household_income
;

#Checking for nulls/blanks in "Place" as one cell was observed empty 
SELECT *
FROM us_household_income
WHERE Place =''
ORDER BY 1
;

SELECT *
FROM us_household_income
WHERE Place ='Autauga County'
ORDER BY 1
;

#Populate missing cell by using two contraints, "County" and "City", since a county ,'Autauga County', does not mean the place will be the same. 
UPDATE us_household_income
SET Place = 'Autauga County'
Where County = 'Autauga County'
and City = 'Vinemont'
;

#Check for Data Quality
SELECT Type, Count(Type)
FROM us_household_income
Group by Type
ORDER BY 1
;

#"Boroughs" to "Boroughs", and need further invesitgation to understand if "CPD" is a typo for "CDP" 
UPDATE us_household_income
SET Type = 'Borough' 
Where Type = 'Boroughs' 
;

SELECT ALand, AWater 
FROM us_household_income
Where (AWater = 0 OR AWater = '' OR Awater IS NULL)
AND (ALand = 0 OR ALand = '' OR ALand IS NULL)
;

#Some places are enirley made up of water 
SELECT ALand, AWater 
FROM us_household_income
Where (ALand = 0 OR ALand = '' OR ALand IS NULL)
;


#EDA:
SELECT State_Name, County, City, ALand, AWater
FROM us_household_income
;

#Top Ten Largest States by Land 
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
Order by 2 DESC
LIMIT 10
;

#Top Ten Largest States by Water 
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_household_income
GROUP BY State_Name
Order by 3 DESC
LIMIT 10
;


SELECT * 
FROM us_household_income u 
INNER JOIN us_household_income_statistics us 
	ON u.id = us.id
WHERE MEAN <> 0
;

#Top 5 States with the Highest Houshold Income by Mean
SELECT u.State_Name, ROUND(AVG(Mean),0) Mean, ROUND(AVG(Median),0) Median
FROM us_household_income u 
INNER JOIN us_household_income_statistics us 
	ON u.id = us.id
    WHERE MEAN <> 0
GROUP BY u.State_Name
Order by 2 DESC 
LIMIT 5
;

#Top 5 States with the Lowest Houshold Income by Mean
SELECT u.State_Name, ROUND(AVG(Mean),0) Mean, ROUND(AVG(Median),0) Median
FROM us_household_income u 
INNER JOIN us_household_income_statistics us 
	ON u.id = us.id
    WHERE MEAN <> 0
GROUP BY u.State_Name
Order by 2 
LIMIT 5
;

SELECT Type, COUNT(TYPE), ROUND(AVG(Mean),0) Mean, ROUND(AVG(Median),0) Median
FROM us_household_income u 
INNER JOIN us_household_income_statistics us 
	ON u.id = us.id
    WHERE MEAN <> 0
GROUP BY Type
ORDER BY 4 DESC
;

#Why is the Mean of Community so low? All the communities are from Puerto Rico. 
Select * 
FROM us_household_income
WHERE Type = 'Community'
;

#Filter out smaller data rows that include CPD, County, Municipality, and Community since their count is so low
SELECT Type, COUNT(TYPE), ROUND(AVG(Mean),0) Mean, ROUND(AVG(Median),0) Median
FROM us_household_income u 
INNER JOIN us_household_income_statistics us 
	ON u.id = us.id
    WHERE MEAN <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 4 DESC
;












 



