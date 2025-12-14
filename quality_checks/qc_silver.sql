
/*
===========================================================================================
Quality Checks of the Silver Layer
===========================================================================================
Scipt Purpose:
    This script performs various quality checks for data consistency, accuracy and 
    standardization for all 'silver' layer tables. Performed checks include:
        NULL or duplicate primary keys
        Unwanted spaces in string fields
        Data standardization and consistency
        Invalid date ranges, orders and formats
        Data consistency between related fields (to prepare Joins during analysis)

Usage notes:
    Run these checks after data loading into the 'silver' layer
    Investigate and resolve any discrepancies found during the checks
===========================================================================================
*/

-- ========================================================================================
-- Checking data consistency of 'silver.crm_cust_info'
-- ========================================================================================

--Checking for NULL or duplicates in the primary key
SELECT cst_id, COUNT(*) FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) >1 or cst_id IS NULL;

--Checking for unwanted Spaces (e.g. first_name, last_name or gndr)
SELECT cst_firstname FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

--Data Standardization and Consistency
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;


-- ========================================================================================
-- Checking data consistency of 'silver.crm_crm_prd_info'
-- ========================================================================================

--Verifying data integrity of silver.crm_prd_info, checking for duplicates
SELECT prd_id, COUNT(*) FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) >1 or prd_id IS NULL;

--Checking for unwanted Spaces in the prd_nm column
SELECT prd_nm FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

--Checking for NULLS or negative values in the prd_cost column
SELECT prd_cost FROM silver.crm_prd_info
WHERE prd_cost < 0 or prd_cost IS NULL;

--Data consistency of the product line information
SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

--Check for invalid date orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ========================================================================================
-- Checking data consistency of 'silver.crm_sales_details'
-- ========================================================================================

--Order date should be prior to shipping and due date
SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt
OR LEN(sls_due_dt) != 8;

--Checking if sales, quantity and price are real (non negative, NULL or zero) values
SELECT DISTINCT sls_sales, sls_quantity, sls_price FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 or sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ========================================================================================
-- Checking data consistency of 'silver.crm_cust_info'
-- ========================================================================================

--Check if birthdates are out of boundaries
SELECT DISTINCT bdate FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();    --Entries below boundaries persist as they were not modified

SELECT DISTINCT gen FROM silver.erp_cust_az12;


-- ========================================================================================
-- Checking data consistency of 'silver.erp_loc_a101'
-- ========================================================================================

--Checking country data integrity
SELECT DISTINCT cntry FROM silver.erp_loc_a101
ORDER BY cntry; 


-- ========================================================================================
-- Checking data consistency of 'silver.erp_px_cat_g1v2'
-- ========================================================================================

--Checking for unwanted Spaces of the category, subcategory and maintenance columns
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
OR subcat != TRIM(subcat) 
OR maintenance != TRIM(maintenance);

--Checking Data Consistency and Standardization
SELECT DISTINCT maintenance 
FROM silver.erp_px_cat_g1v2;
