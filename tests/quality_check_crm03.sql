/*===========================================================================================
========================================================================
*/

--03. Sales Details

--Script Purpose: This script is for the data quality check and data cleaning and transformation from the bronze and silver Sales Details tables data.

/*===========================================================================================
========================================================================
*/

--Step 1: Inspect Bronze Table

SELECT*
FROM bronze.crm_sales_details;

--Step 2: Check sls_ord_num column for unwanted spaces

SELECT
TRIM(sls_ord_num) AS sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num ! =TRIM(sls_ord_num);

--Step 3: Check sls_prd_key for integrity

SELECT 
sls_prd_key
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);

--Step 4: Check sls_cust_id for integrity

SELECT
sls_cust_id
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);

--or

SELECT
sls_cust_id
FROM bronze.crm_sales_details
EXCEPT
SELECT
cst_id
FROM silver.crm_cust_info;

--Step 5: Check dates columns before changing the data type as clearly seen is interger.
-- Since it ic integer,make sure that there exist no value less then or equal to zero
--checking the length or date given as integers making sure it has all the expected inputs.
--Checking outliers by validating the boundaries of the date range.
-- Order Date should be less than ship date and due date. 

SELECT
	NULLIF (sls_order_dt,0) AS sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 
	OR LEN(sls_order_dt) !=8 
	OR sls_order_dt > 20500101
	OR sls_order_dt <19000101;

SELECT
	NULLIF (sls_ship_dt,0) AS sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0 
	OR LEN(sls_ship_dt) !=8 
	OR sls_ship_dt > 20500101
	OR sls_ship_dt <19000101;

SELECT
	NULLIF (sls_due_dt,0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
	OR LEN(sls_due_dt) !=8 
	OR sls_due_dt > 20500101
	OR sls_due_dt <19000101;


SELECT
	sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


--Step 6: Check sls_sales, Quntity & price.
-- Business Rule: Sales = qunatity* price
-- no negatives, zeroes or nulls
-- if errors found then , Business Rules  after consulting the source system experts is advised.
-- Every data cannot be handled just by cleaning,it needs to be discussed with the expert team  first.
-- Business Rules: 
-- If sales is negative , zero or null, derive it using quantity and price.
-- If price is zero or null, calculate it using sales and quantity.
-- If price is negative, convert it to a positive value.
	

SELECT DISTINCT
	sls_sales    AS old_sls_sales,
	sls_price    AS old_sls_price,
	sls_quantity ,
	
	CASE WHEN  sls_price IS NULL OR sls_price < = 0			
			 THEN  ( sls_sales) / NULLIF(sls_quantity,0)
			 ELSE sls_price
			 END sls_price,

	CASE WHEN  sls_sales IS NULL OR sls_sales < = 0 OR sls_sales ! = sls_quantity* ABS(sls_price)
			 THEN  sls_quantity * ABS(sls_price)
			 ELSE sls_sales
			 END sls_sales    
	
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales    <= 0
	OR sls_quantity <= 0
	OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

--Step 7: Run the same queries for silver table after loading


SELECT*
FROM silver.crm_sales_details;

SELECT
	sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;




SELECT DISTINCT
	sls_sales,
	sls_price,
	sls_quantity 

FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price 
	OR sls_sales IS NULL 
	OR sls_quantity IS NULL 
	OR sls_price IS NULL
	OR sls_sales    <= 0
	OR sls_quantity <= 0
	OR sls_price    <= 0
ORDER BY sls_sales, sls_quantity, sls_price;
