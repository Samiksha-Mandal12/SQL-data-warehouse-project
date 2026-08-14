/*===========================================================================================
========================================================================
*/

--05 . Customer Location Details

/*Script Purpose: This script is for the data quality check and data cleaning and transformation from the bronze and silver erp_loc_a101 tables data
 and loading the final cleaned columns into the silver layer.

 Handling invalid values and empty string. Data Normalization and missing values from country.*/

/*===========================================================================================
========================================================================
*/

--Step 1: Inspect Bronze Table
SELECT*
FROM bronze.erp_loc_a101;

--Step 2: Check column cid

SELECT
REPLACE (cid, '-', '') cid
FROM bronze.erp_loc_a101
	EXCEPT
	SELECT cst_key
	FROM silver.crm_cust_info;

--Step 3: Check country column
--check cardinality
SELECT DISTINCT 
	cntry AS old_cntry,
	CASE WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
	 WHEN TRIM(cntry) = 'Germany' THEN 'Germany'
	 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
	 ELSE cntry
	 END AS cntry
FROM BRONZE.ERP_LOC_A101;
