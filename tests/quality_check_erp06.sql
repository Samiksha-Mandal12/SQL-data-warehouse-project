/*===========================================================================================
========================================================================
*/

--06 . Product Category-Subcategory Details

/*Script Purpose: This script is for the data quality check and data cleaning and transformation from the bronze and silver erp_px_cat_g1v2 tables data
 and loading the final cleaned columns into the silver layer.

 Result; The data quality of the table in bronze layer was excellent and thus no cleaning or tranforming was needed.
 Data was loaded into the silver layer.

*/

/*===========================================================================================
========================================================================
*/

--Step 1: Inspect Bronze Table

SELECT*
FROM Bronze.erp_px_cat_g1v2;

--Step 2: Check column id
--already checked in table crm_prd_info

--Step 3: Check column category
--unwanted spaces
-- cardinality
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat);


SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

--Step 3: Check column Subcategory
-- check unwanted spaces
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

--Step 4: Check column maintenance
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance);

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;

