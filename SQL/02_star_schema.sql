-- ============================================================================
-- Financial & Sales Analytics Dashboard - Star Schema Design
-- ============================================================================
-- Purpose: Create fact and dimension tables for retail analytics
-- Schema: Star Schema optimized for OLAP queries
-- ============================================================================

USE retail_analytics;

-- ============================================================================
-- DIMENSION TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Dimension: Date (Time Intelligence)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_date;

CREATE TABLE dim_date (
    date_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE NOT NULL UNIQUE,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    week_of_year INT NOT NULL,
    is_weekend BOOLEAN NOT NULL,
    INDEX idx_date (date),
    INDEX idx_year_month (year, month),
    INDEX idx_year_quarter (year, quarter)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Dimension: Products
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_product;

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2) NOT NULL,
    INDEX idx_category (category)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Dimension: Customers
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_customer;

CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    customer_segment VARCHAR(50) NOT NULL,
    registration_date DATE NOT NULL,
    INDEX idx_segment (customer_segment),
    INDEX idx_registration_date (registration_date)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Dimension: Stores
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS dim_store;

CREATE TABLE dim_store (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(2) NOT NULL,
    region VARCHAR(50) NOT NULL,
    INDEX idx_region (region),
    INDEX idx_state (state)
) ENGINE=InnoDB;

-- ============================================================================
-- FACT TABLE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Fact: Sales Transactions
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS fact_sales;

CREATE TABLE fact_sales (
    transaction_id INT PRIMARY KEY,
    transaction_date DATE NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    store_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_percent DECIMAL(5, 2) NOT NULL DEFAULT 0,
    revenue DECIMAL(12, 2) NOT NULL,
    cost DECIMAL(12, 2) NOT NULL,
    profit DECIMAL(12, 2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,

    -- Foreign Keys
    FOREIGN KEY (transaction_date) REFERENCES dim_date(date),
    FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),

    -- Indexes for query performance
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_customer_id (customer_id),
    INDEX idx_product_id (product_id),
    INDEX idx_store_id (store_id),
    INDEX idx_date_customer (transaction_date, customer_id),
    INDEX idx_date_product (transaction_date, product_id)
) ENGINE=InnoDB;

-- ============================================================================
-- VERIFY SCHEMA CREATION
-- ============================================================================

-- Show all tables
SELECT 'Star Schema Created Successfully!' AS Status;

SELECT
    TABLE_NAME,
    TABLE_TYPE,
    ENGINE,
    TABLE_ROWS,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS Size_MB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'retail_analytics'
ORDER BY TABLE_NAME;

-- Show table relationships
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'retail_analytics'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, ORDINAL_POSITION;
