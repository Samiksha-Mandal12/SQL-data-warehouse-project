/*===========================================================================================
========================================================================
*/

--02. Product Information

--Script Purpose: This script is for the data quality check and data cleaning and transformation from the bronze and silver product information tables data.

/*===========================================================================================
========================================================================
*/

--Step 1: Inspect Bronze Table

SELECT
	*
FROM Bronze.crm_prd_info;

--Step2: Check for Nulls or duplicates in Primary Key
--       Rank them if found and get rid of old data if latest updated data of the duplicates exists.
--       Expectation: No Result

SELECT 
	prd_id,
	count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING count(*)>1 OR prd_id IS NULL
;


--Step 3: substituting prd_key as it has category id along with the key mentioned in category erp PX_CAT_G1V2table.
 --Cross check the category id with another table in order to join and find errors,
-- There is a difference of hypen and underscore in cat id from two different tables , so make it even

SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS Prd_key
	FROM bronze.crm_prd_info



--Step 4: Checking for product name if any unwanted spaces;
 SELECT
 TRIM(prd_nm) AS prd_nm
 FROM bronze.crm_prd_info
 WHERE prd_nm != TRIM(prd_nm);


 --Step 5: Checking for product cost if any nulls or negative values;
 -- Replacing nulls with 0 using ISNULL function
 SELECT
 prd_cost
 FROM bronze.crm_prd_info 
 WHERE prd_cost < 0 OR prd_cost IS NULL;

--Step 6: Checking the column prd_line for Nulls & distinctness and mapping the complete words
-- R for Road, S for Other Sales, M for Mountain,T for Touring
-- Using standardization factors like uppercase and also trimming unwanted spaces while mapping usin CASE statements
SELECT DISTINCT
prd_line 
FROM 
bronze.crm_prd_info;


--Step 7 : Start Date and End Date checking if any end date is smaller than start date which should realistically not happen.
-- Previous row End Date = Next row Start Date -1, can be done use LEAD function
-- As the start date and end date does not have any time mentioned in it, so it is best to change the data type as DATE in silver DDL or cast it.
SELECT
*
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


SELECT
	prd_id,
	prd_key,
	prd_start_dt,
	prd_end_dt,
	LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC)-1 AS prd_start_dt_test
FROM bronze.crm_prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R','AC-HE-HL-U509');


-----------------------------------------------------------------------------------------------------------

/* NOTE:
		1. After completing the quality check for bronze table, fixing and cleaning up data is required according to the
		errors found. 

		2. Cleanup and transformation such as inspecting the table initially, checking for primary key and it's nulls and
		duplicates, investing those duplicates and ranking them, Normalizing, standardizing the data to make it consistent throughout,
		trimming the unwanted spaces from string values and them finally inserting them into silver table was done.

		3. Transformed data when loaded into the specific silver table needs to be validated again in order to double-check
		if any inaccuracies persist. (Repeat the exact same queries BUT for silver table)
As Shown
*/

		SELECT 
			prd_id,
			count(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING count(*)>1 OR prd_id IS NULL;


 SELECT
 prd_cost
 FROM silver.crm_prd_info 
 WHERE prd_cost < 0 OR prd_cost IS NULL;


 SELECT
*
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
