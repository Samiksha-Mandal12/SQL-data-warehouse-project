/*
=======================================================================================================================
Quality Checks
=======================================================================================================================
Script Purpose:
	This script performs quality checks to validate the integrity, consistency, and accuracy of the bronze layer.
	These checks ensure:
	- Completeness and validity of data across the CRM and ERP source tables.
	- Consistency and correctness of the key columns, data types, dates, numeric values, and categorical attributes.
	- Identification of null, duplicate, invalid, inconsistent, or unexpected values in the raw data.

Usage Notes:
	- Run these checks after data loading the cource data into the Bronze layer.
	- Investigate and resolve any discrepancies identified during the checks before proceeding to the silver layer.
=======================================================================================================================
*/

--=====================================================================================================================
--Checking 'bronze.crm_cust_info'
--=====================================================================================================================
--Check for uniqueness of customer id in bronze.crm_cust_info.
--Check for unwanted spaces in string values.
--Check for Data Standardization and Consistency for marital status and gender.
--Expectation: No results
SELECT 
	cst_id,
	count(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING count(*)>1 OR cst_id IS NULL;
---

SELECT
cst_firstname
FROM BRONZE.crm_cust_info
WHERE cst_firstname != TRIM (cst_firstname);
---

SELECT
cst_lastname
FROM BRONZE.crm_cust_info
WHERE cst_lastname != TRIM (cst_lastname);
---


SELECT
cst_gndr
FROM BRONZE.crm_cust_info
WHERE cst_gndr != TRIM (cst_gndr);
---

SELECT
cst_marital_status
FROM BRONZE.crm_cust_info
WHERE cst_marital_status != TRIM (cst_marital_status);
---

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
---

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;
---

--=====================================================================================================================
--Checking 'bronze.crm_prd_info'
--=====================================================================================================================
--Check for uniqueness of prd_id in bronze.crm_prd_info.
--Replacing string characters.
--Checking for date validation
--Check for unwanted spaces,nulls in string values.
--Expectation : No result
SELECT 
	prd_id,
	count(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING count(*)>1 OR prd_id IS NULL;
---

SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS Cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key)) AS Prd_key
	FROM bronze.crm_prd_info;
---

SELECT
 TRIM(prd_nm) AS prd_nm
 FROM bronze.crm_prd_info
 WHERE prd_nm != TRIM(prd_nm);
---

 SELECT
	prd_cost
 FROM bronze.crm_prd_info 
 WHERE prd_cost < 0 OR prd_cost IS NULL;
---

SELECT DISTINCT
	prd_line 
FROM 
bronze.crm_prd_info;
---

SELECT
*
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
---


--=====================================================================================================================
--Checking 'bronze.crm_sales_details'
--=====================================================================================================================
--Check for unwanted in sls_ord_num.
--Check keys for integrity
--Checking for dates data type, date order and character length validation
--Validating business rules for sales, quantity and price
--Expectation : No result


SELECT
TRIM(sls_ord_num) AS sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num ! =TRIM(sls_ord_num);
---

SELECT 
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
---

SELECT 
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
---

SELECT
	 sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
	OR LEN(sls_order_dt) !=8 
	OR sls_order_dt > 20500101
	OR sls_order_dt <19000101;
---

SELECT
	 sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
	OR LEN(sls_ship_dt) !=8 
	OR sls_ship_dt > 20500101
	OR sls_ship_dt <19000101;
---

SELECT
	 sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
	OR LEN(sls_due_dt) !=8 
	OR sls_due_dt > 20500101
	OR sls_due_dt <19000101;
---

SELECT
	sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;
---

SELECT DISTINCT
	sls_sales,
	sls_price,
	sls_quantity
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales    <= 0
	OR sls_quantity <= 0
	OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
---

--=====================================================================================================================
--Checking 'bronze.erp_cust_az12'
--=====================================================================================================================
--Checking for extra characters in cid and validating the values.
--Checking for birthdate range to find out very old birthdates or birthdates from future dates.
--Checking distinct genders.
--Expectation : No result
SELECT
 cid 	
FROM bronze.erp_cust_az12
	WHERE cid LIKE 'NAS%';
---

SELECT
	bdate
FROM bronze.erp_cust_az12
WHERE bdate < = '1900-01-01' OR  bdate > = GETDATE();
---

SELECT DISTINCT
	gen
FROM 
bronze.erp_cust_az12;
---

--=====================================================================================================================
--Checking 'bronze.erp_loc_a101'
--=====================================================================================================================
--Checking for unwanted characters or spaces in cid .
--Checking for countries for distinctness.
--Expectation : No result
SELECT
	cid
FROM bronze.erp_loc_a101;
---

SELECT DISTINCT 
	cntry 
FROM BRONZE.ERP_LOC_A101;
---

--=====================================================================================================================
--Checking 'bronze.erp_px_cat_g1v2'
--=====================================================================================================================
--Checking for unwanted spaces and distinctness.
--Expectation : No result
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat);
---

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;
---

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE subcat != TRIM(subcat);
---

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;
---
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE maintenance != TRIM(maintenance);
---

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;
---
--=====================================================================================================================
	 
