/*===========================================================================================
========================================================================
*/

--04. Customer Date Of Birth Details

--Script Purpose: This script is for the data quality check and data cleaning and transformation from the bronze and silver erp_cust_az12 tables data.

/*===========================================================================================
========================================================================
*/

--Step 1: Inspect Bronze Table

SELECT*
FROM bronze.erp_cust_az12;

--Step 2: Clean the cid as it has extra characters as compared to the customer id from customer info table
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
	 ELSE cid
	 END  cid,
          bdate,
          gen
FROM bronze.erp_cust_az12
	WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
	 ELSE cid
	 END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info);

	 --OR

SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
	 ELSE cid
	 END  cid	
FROM bronze.erp_cust_az12
EXCEPT
	SELECT DISTINCT cst_key 
	FROM silver.crm_cust_info;


--Step 3: Check bdate column 
-- range for very old customers or future bdate, bad data quality
-- Older then 100 years should be discussed but more the the current date is impossible, there null it

SELECT
	cid,
	CASE WHEN bdate > GETDATE() THEN NULL
	ELSE bdate
	END  bdate,
	gen
FROM bronze.erp_cust_az12
;

-- Step 4 : Check column gender for low cardinality , distinctness and handle null

SELECT DISTINCT
gen,
	CASE WHEN UPPER (TRIM(gen)) IN ('F', 'Female') THEN 'Female'
		 WHEN UPPER (TRIM(gen)) IN ('M', 'Male')   THEN 'Male'
		 ELSE 'n/a'
		 END gen
FROM 
bronze.erp_cust_az12;


-- Step 5 : Check all the above queries for silver layer after loading into silver.erp_cust_az12

SELECT*
FROM silver.erp_cust_az12;

SELECT
cid	
FROM silver.erp_cust_az12
EXCEPT
	SELECT DISTINCT cst_key 
	FROM silver.crm_cust_info;


SELECT
	bdate
FROM silver.erp_cust_az12
	WHERE bdate > GETDATE();


SELECT DISTINCT
gen
FROM 
silver.erp_cust_az12;
