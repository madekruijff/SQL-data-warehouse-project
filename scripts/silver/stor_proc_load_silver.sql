/*
===========================================================================================
Stored Procedure: Populating Silver Layer Tables
===========================================================================================
Scipt Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to populate
  	the 'silver' schema tables using the raw data of the 'bronze' schema.
Actions performed:
  	Truncates Silver Tables
  	Inserts cleaned and transformed data from 'bronze' to 'silver' tables'

Usage example: Exec silver.load_silver;
===========================================================================================
*/

--Creating Stored Procedure to populate silver layer tables with clean data.
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		PRINT '=======================================================';
		PRINT 'Populating Silver Layer with Cleaned Data';
		PRINT '=======================================================';

		PRINT '-------------------------------------------------------';
		PRINT 'Loading Silver Layer CRM Tables';
		PRINT '-------------------------------------------------------';
		SET @batch_start_time = GETDATE();
		SET @start_time = GETDATE();
	--Populationg silver.crm_cust_info with cleaned data
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> silver.crm_cust_info truncated. Inserting data';
	INSERT INTO silver.crm_cust_info (
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

	SELECT cst_id, 
	cst_key, 
	TRIM(cst_firstname) AS cst_firstname, 
	TRIM(cst_lastname) AS cst_lastname, 
	CASE WHEN cst_marital_status = UPPER(TRIM('S')) THEN 'Single'
		WHEN cst_marital_status = UPPER(TRIM('M')) THEN 'Married'
		ELSE 'n/a'		--Writing out marital status and specifying unknowns as not applicable
	END AS cst_marital_status,
	CASE WHEN cst_gndr = UPPER(TRIM('F')) THEN 'Female'
		WHEN cst_gndr = UPPER(TRIM('M')) THEN 'Male'
		ELSE 'n/a'		--Writing out genders and specifying unknowns as not applicable
	END AS cst_gndr,
	cst_create_date
	FROM (
	--Creating a table without duplicates (removing older entries via creation date)
		SELECT *, ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL)t
	WHERE flag_last = 1
	;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'



	--Inserting the cleaned data into silver.crm_prd_info
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.crm_prd_info;
	PRINT '>> silver.crm_prd_info truncated. Inserting data';
	INSERT INTO silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	--Cleaning bronze.crm_prd_info
	SELECT
	prd_id,
	REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,	--Standardizing identifiers
	SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,			--Standardizing identifiers
	prd_nm,
	ISNULL(prd_cost, 0) AS prd_cost,						--Specifying the full product line name instead of abbreviations
	CASE UPPER(TRIM(prd_line))
		 WHEN 'M' THEN 'Mountain'
		 WHEN 'R' THEN 'Road'
		 WHEN 'S' THEN 'Other Sales'
		 WHEN 'T' THEN 'Touring'
		 ELSE 'n/a'
	END AS prd_line,
	CAST (prd_start_dt AS DATE) AS start_dt,				--Standardizing dates
	CAST(
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE)
		AS prd_end_dt --Calculation of end date as one day before the next start date
	FROM bronze.crm_prd_info
	;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'

	--Inserting cleaned data into the silver.crm_sales_details table
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.crm_sales_details;
	PRINT '>> silver.crm_sales_details truncated. Inserting data';
	INSERT INTO silver.crm_sales_details(
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)

	--Cleaning data of the bronze.crm_sales_details table
	SELECT
	sls_ord_num,
	sls_prd_key,
	sls_cust_id,
	CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
		ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)	--In MSS conversion from integer to date requires VARCHAR conversion prior
	END AS sls_order_dt,
	CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL	--shipping date was fine, the setup applied is a preventive measure for future entries
		ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)	--In MSS conversion from integer to date requires VARCHAR conversion prior
	END AS sls_ship_dt,
	CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL	--due date was fine, the setup applied is a preventive measure for future entries
		ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)	--In MSS conversion from integer to date requires VARCHAR conversion prior
	END AS sls_due_dt,
	CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)	--sales recalculated from quantity and price if negative, 0 NULL or wrong values exist
		ELSE sls_sales
	END AS sls_sales,
	sls_quantity,
	CASE WHEN sls_price IS NULL OR sls_price <= 0 
		THEN sls_sales / NULLIF(sls_quantity, 0)	--price recalculated from quantity and sales if negative, 0 or NULL values exist
		ELSE sls_price
	END AS sls_price
	FROM bronze.crm_sales_details;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'


	--Inserting cleaned data into the silver.erp_cust_az12 table
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_cust_az12;
	PRINT '>> silver.erp_cust_az12 truncated. Inserting data';
	INSERT INTO silver.erp_cust_az12(
	cid,
	bdate,
	gen
	)
	--Transforming bronze.erp_cust_az12
	SELECT
	CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))	--Removing 'NAS' prefix where present
		ELSE cid
	END AS cid,
	CASE WHEN bdate > GETDATE() THEN NULL						--Setting future birthdates to NULL
		ELSE bdate
	END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
		WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
		ELSE 'n/a'
	END AS gen		--Normalizing gender
	FROM bronze.erp_cust_az12;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'

	--Insert data into silver.erp_cust_loc_a101
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_loc_a101;
	PRINT '>> silver.erp_loc_a101 truncated. Inserting data';
	INSERT INTO silver.erp_loc_a101(
	cid,
	cntry
	)

	--Transforming bronze.erp_loc_a101
	SELECT
	REPLACE(cid, '-', '') AS cid,										--Standardizing identifiers
	CASE WHEN TRIM(cntry) IN('US', 'USA') THEN 'United States'			--Standardizing country names
		 WHEN TRIM(cntry) IN('DE') THEN 'Germany'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE cntry
	END AS cntry
	FROM bronze.erp_loc_a101;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'


	--Insert data into silver.erp_px_cat_g1v2
	SET @start_time = GETDATE();
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	PRINT '>> silver.erp_px_cat_g1v2 truncated. Inserting data';
	INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance
	)
	SELECT * FROM bronze.erp_px_cat_g1v2;
	SET @end_time = GETDATE();
	PRINT '>> Load Duration: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
	PRINT '----------------'
	SET @batch_end_time = GETDATE();
	PRINT '=======================================================';
	PRINT 'Loading Silver Layer is Completed';
	PRINT 'Total Data Insertion Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	PRINT '=======================================================';
	END TRY
		BEGIN CATCH
		PRINT '=====================================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'ERROR Message' + ERROR_MESSAGE();
		PRINT 'ERROR Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=====================================================';
	END CATCH
END
