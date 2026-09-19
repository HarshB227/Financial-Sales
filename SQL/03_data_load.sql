-- ============================================================================
-- Financial & Sales Analytics Dashboard - Data Loading Script
-- ============================================================================
-- Purpose: Load CSV data into star schema tables
-- Note: Adjust file paths based on your system
-- ============================================================================

USE retail_analytics;

-- ============================================================================
-- LOAD DIMENSION TABLES FIRST (to satisfy foreign key constraints)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Load Date Dimension
-- ----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/dim_dates.csv'
INTO TABLE dim_date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(date, year, quarter, month, month_name, day, day_of_week, day_name, week_of_year, is_weekend);

SELECT CONCAT('Loaded ', COUNT(*), ' records into dim_date') AS Status FROM dim_date;

-- ----------------------------------------------------------------------------
-- Load Product Dimension
-- ----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/dim_products.csv'
INTO TABLE dim_product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category, base_price, cost_price);

SELECT CONCAT('Loaded ', COUNT(*), ' records into dim_product') AS Status FROM dim_product;

-- ----------------------------------------------------------------------------
-- Load Customer Dimension
-- ----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/dim_customers.csv'
INTO TABLE dim_customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_segment, registration_date);

SELECT CONCAT('Loaded ', COUNT(*), ' records into dim_customer') AS Status FROM dim_customer;

-- ----------------------------------------------------------------------------
-- Load Store Dimension
-- ----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/dim_stores.csv'
INTO TABLE dim_store
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(store_id, store_name, city, state, region);

SELECT CONCAT('Loaded ', COUNT(*), ' records into dim_store') AS Status FROM dim_store;

-- ============================================================================
-- LOAD FACT TABLE (after dimensions are loaded)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Load Sales Transactions Fact
-- ----------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/sales_transactions.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, transaction_date, customer_id, product_id, store_id,
 quantity, unit_price, discount_percent, revenue, cost, profit, payment_method);

SELECT CONCAT('Loaded ', COUNT(*), ' records into fact_sales') AS Status FROM fact_sales;

-- ============================================================================
-- DATA VALIDATION & VERIFICATION
-- ============================================================================

-- Verify record counts
SELECT 'Data Load Summary:' AS '';

SELECT
    'dim_date' AS table_name,
    COUNT(*) AS record_count,
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM dim_date

UNION ALL

SELECT
    'dim_product' AS table_name,
    COUNT(*) AS record_count,
    COUNT(DISTINCT category) AS unique_categories,
    NULL AS max_date
FROM dim_product

UNION ALL

SELECT
    'dim_customer' AS table_name,
    COUNT(*) AS record_count,
    COUNT(DISTINCT customer_segment) AS unique_segments,
    NULL AS max_date
FROM dim_customer

UNION ALL

SELECT
    'dim_store' AS table_name,
    COUNT(*) AS record_count,
    COUNT(DISTINCT region) AS unique_regions,
    NULL AS max_date
FROM dim_store

UNION ALL

SELECT
    'fact_sales' AS table_name,
    COUNT(*) AS record_count,
    ROUND(SUM(revenue), 2) AS total_revenue,
    NULL AS max_date
FROM fact_sales;

-- Check for referential integrity
SELECT 'Referential Integrity Check:' AS '';

SELECT 'Orphaned transactions (invalid customer_id)' AS check_type, COUNT(*) AS count
FROM fact_sales f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'Orphaned transactions (invalid product_id)', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_product p ON f.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT 'Orphaned transactions (invalid store_id)', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_store s ON f.store_id = s.store_id
WHERE s.store_id IS NULL

UNION ALL

SELECT 'Orphaned transactions (invalid date)', COUNT(*)
FROM fact_sales f
LEFT JOIN dim_date d ON f.transaction_date = d.date
WHERE d.date IS NULL;

SELECT 'Data load complete! All tables populated successfully.' AS Status;
