/*===========================================================================================
========================================================================
*/

--01. Customer Information

--Script Purpose: This script is for the data quality check from the bronze and silver customer information tables data.

/*===========================================================================================
========================================================================
*/


--Step 1: Inspect Bronze Table

SELECT*
FROM bronze.crm_cust_info;


--Step2: Check for Nulls or duplicates in Primary Key
--       Rank them if found and get rid of old data if latest updated data of the duplicates exists.
--       Expectation: No Result

SELECT 
	cst_id,
	count(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING count(*)>1 OR cst_id IS NULL
;


--Step 3: Check for Unwanted  spaces in string values.
--        Expectation: No Result

SELECT
CST_FIRSTNAME
FROM BRONZE.crm_cust_info
WHERE CST_FIRSTNAME != TRIM (CST_FIRSTNAME);


SELECT
CST_LASTNAME
FROM BRONZE.crm_cust_info
WHERE CST_LASTNAME != TRIM (CST_LASTNAME);


SELECT
CST_GNDR
FROM BRONZE.crm_cust_info
WHERE CST_GNDR != TRIM (CST_GNDR);


SELECT
CST_MARITAL_STATUS
FROM BRONZE.crm_cust_info
WHERE CST_MARITAL_STATUS != TRIM (CST_MARITAL_STATUS);


--Step 4: Data Standardization and Consistency
--		  In the columns marital status and gender it was M, S ,M & F respectively 
--		  Check the distinct names and also map the values while cleanup as M comes in gender as well as marital status.
--		  Therefore map it as complete names.

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;


/* NOTE:
		1. After completing the quality check for bronze table, fixing and cleaning up data is required according to the
		errors found. 

		2. Cleanup and transformation such as inspecting the table initially, checking for primary key and it's nulls and
		duplicates, investing those duplicates and ranking them, Normalizing, standardizing the data to make it consistent throughout,
		trimming the unwanted spaces from string values and them finally inserting them into silver table was done.

		3. Transformed data when loaded into the specific silver table needs to be validated again in order to double-check
		if any inaccuracies persist. (Repeat the exact same queries BUT for silver table)*/


