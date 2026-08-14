/*
======================================================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
======================================================================================================================
Script Purpose: 
  This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'Silver' schema tables from
  the 'Bronze' schema.

Actions Performed:
  -Truncates Silver Tables.
  -Inserts transformed and cleaned data from Bronze to Silver Tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or returns any values.

Usage Example:
  EXEC Silver.load_silver;
======================================================================================================================
*/
  
CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
	DECLARE @StartTime DATETIME, @EndTime DATETIME, @BatchStartTime DATETIME, @BatchEndTime DATETIME;
	BEGIN TRY
		PRINT '***********************************************************************************************************';
		PRINT '								          Loading Silver Layer                                                ';
		PRINT '***********************************************************************************************************';

		PRINT '///////////////////////////////////////////////////////////////////////////////////////////////////////////';
		PRINT '									      Loading CRM Tables                                                  ';
		PRINT '///////////////////////////////////////////////////////////////////////////////////////////////////////////';

		PRINT'.........................';
		PRINT'CUSTOMER INFORMATION TABLE';
		PRINT'.........................';

		SET @BatchStartTime = GETDATE();
		SET @StartTime = GETDATE();
		PRINT '>> Truncating Table: Silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Inserting Data Into: Silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)

		SELECT
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				 WHEN UPPER(TRIM(cst_marital_status)) = 'S'THEN 'Single'
				 ELSE 'n/a'
				 END cst_marital_status,

			CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				 WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				 ELSE 'n/a'
				 END cst_gndr,
			cst_create_date
		FROM 
			(
			SELECT*,
				ROW_NUMBER () OVER (PARTITION BY cst_id  ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
			)t
		WHERE flag_last = 1 ;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';

		PRINT'.........................';
		PRINT'PRODUCT INFORMATION TABLE';
		PRINT'.........................';

		SET @StartTime =GETDATE();
		PRINT'>> Truncating Table: Silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT'>> Inserting Data Into: Silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS Prd_key,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN  'M' THEN 'Mountain'
				 WHEN  'S' THEN 'Other Sales'
				 WHEN  'R' THEN 'Road'
				 WHEN  'T' THEN 'Touring'
				 ELSE 'n/a'
				 END AS prd_line,
			CAST((prd_start_dt) AS DATE) AS prd_start_dt,
			CAST(LEAD (prd_start_dt) OVER(PARTITION BY prd_key  ORDER BY prd_start_dt ASC)-1 AS DATE) AS prd_end_dt
		FROM Bronze.crm_prd_info;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';

		PRINT'...................';
		PRINT'SALES DETAILS TABLE';
		PRINT'...................';

		SET @StartTime = GETDATE();
		PRINT'>>Truncating Table: Silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT'>> Inserting Data Into Table: Silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_price,
			sls_quantity,
			sls_sales
		)
		SELECT 
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt)!= 8 THEN NULL  
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
				 END  sls_order_dt,

			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
				 END  sls_ship_dt ,

			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt  AS VARCHAR)  AS DATE)  
				 END  sls_due_dt,			


			CASE WHEN  sls_price IS NULL OR sls_price < = 0 
				 THEN  ( sls_sales) / NULLIF(sls_quantity,0)
				 ELSE sls_price
				 END sls_price,
			sls_quantity,
			CASE WHEN  sls_sales IS NULL OR sls_sales < = 0 OR sls_sales ! = sls_quantity* ABS(sls_price)
				 THEN  sls_quantity * ABS(sls_price)
				 ELSE sls_sales
				 END sls_sales					
		FROM bronze.crm_sales_details;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';


		PRINT '///////////////////////////////////////////////////////////////////////////////////////////////////////////';
		PRINT '								         Loading ERP Tables                                                   ';
		PRINT '///////////////////////////////////////////////////////////////////////////////////////////////////////////';

		PRINT'........................';
		PRINT'CUSTOMER BIRTHDATE TABLE';
		PRINT'........................';

		SET @StartTime = GETDATE();
		PRINT'>> Truncating Table: silver.erp_cust_az12 ';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT'>> Inserting Data Into Table: silver.erp_cust_az12';

		INSERT INTO silver.erp_cust_az12(
			cid,
			bdate,
			gen
		)
		SELECT
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4, LEN(cid))
			 ELSE cid
			 END  cid,

		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
			 END  bdate,

		CASE WHEN UPPER (TRIM(gen)) IN ('F', 'Female') THEN 'Female'
			 WHEN UPPER (TRIM(gen)) IN ('M', 'Male')   THEN 'Male'
			 ELSE 'n/a'
			 END gen

		FROM bronze.erp_cust_az12;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';

		PRINT'.......................';
		PRINT'CUSTOMER LOCATION TABLE';
		PRINT'.......................';

		SET @StartTime = GETDATE();
		PRINT'>> Truncating Table: Silver.erp_loc_a101';
		TRUNCATE TABLE Silver.erp_loc_a101;
		PRINT'>> Inserting Data Into Table: Silver.erp_loc_a101';
		INSERT INTO Silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT
			REPLACE (cid, '-', '') cid,
		CASE WHEN TRIM(cntry) IN ('USA', 'United States', 'US') THEN 'United States'
			 WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
			 ELSE cntry
			 END AS cntry
		FROM bronze.erp_loc_a101;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';

		PRINT'..................................';
		PRINT'PRODUCT CATEGORY-SUBCATEGORY TABLE';
		PRINT'..................................';

		SET @StartTime = GETDATE();
		PRINT'>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT'>> Inserting Data Into Table: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @EndTime = GETDATE();
		PRINT '--> Load Duration:' + ' '+ CAST(DATEDIFF(second, @StartTime, @EndTime) AS NVARCHAR) + ' '+ 'seconds';

		SET @BatchEndTime = GETDATE();
		PRINT '--> Batch Load Duration:' + ' '+ CAST(DATEDIFF(second, @BatchStartTime, @BatchEndTime) AS NVARCHAR) + ' '+ 'seconds';

		PRINT '***********************************************************************************************************';
		PRINT '								          Loading Complete                                                    ';
		PRINT '***********************************************************************************************************';

	END TRY

	BEGIN CATCH
		PRINT'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';

		PRINT'Error Message :' + ' ' + ERROR_MESSAGE();
		PRINT'Error Number  :' + ' ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT'Error State   :' + ' ' + CAST(ERROR_STATE() AS NVARCHAR);

		PRINT'!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!';

	END CATCH
		
END;

======================================================================================================================
                                                   ! Stored Procedure Complete!


