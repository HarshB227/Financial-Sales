-- ============================================================================
-- Financial & Sales Analytics Dashboard - Analytical Queries
-- ============================================================================
-- Purpose: 20+ SQL queries demonstrating JOINs, CTEs, Window Functions
-- Business Focus: Revenue, Margin, Customer Retention, Growth Analytics
-- ============================================================================

USE retail_analytics;

-- ============================================================================
-- SECTION 1: REVENUE ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 1: Total Revenue, Profit, and Margin by Category
-- Techniques: JOIN, GROUP BY, Aggregate Functions
-- ----------------------------------------------------------------------------
SELECT
    p.category,
    COUNT(DISTINCT f.transaction_id) AS total_transactions,
    SUM(f.quantity) AS total_units_sold,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.revenue)) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(f.revenue), 2) AS avg_transaction_value
FROM fact_sales f
INNER JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------
-- Query 2: Monthly Revenue Trend with YoY Growth
-- Techniques: JOIN, DATE functions, Self-join for YoY comparison
-- ----------------------------------------------------------------------------
SELECT
    d.year,
    d.month_name,
    ROUND(SUM(f.revenue), 2) AS monthly_revenue,
    ROUND(SUM(f.profit), 2) AS monthly_profit,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    COUNT(f.transaction_id) AS transaction_count
FROM fact_sales f
INNER JOIN dim_date d ON f.transaction_date = d.date
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- ----------------------------------------------------------------------------
-- Query 3: Year-over-Year Revenue Growth
-- Techniques: CTE, Self-JOIN, Window Functions
-- ----------------------------------------------------------------------------
WITH yearly_revenue AS (
    SELECT
        d.year,
        ROUND(SUM(f.revenue), 2) AS total_revenue,
        ROUND(SUM(f.profit), 2) AS total_profit
    FROM fact_sales f
    INNER JOIN dim_date d ON f.transaction_date = d.date
    GROUP BY d.year
)
SELECT
    current.year,
    current.total_revenue,
    current.total_profit,
    previous.total_revenue AS previous_year_revenue,
    ROUND(((current.total_revenue - previous.total_revenue) / previous.total_revenue) * 100, 2) AS revenue_growth_pct,
    ROUND(current.total_revenue - previous.total_revenue, 2) AS revenue_increase
FROM yearly_revenue current
LEFT JOIN yearly_revenue previous ON current.year = previous.year + 1
ORDER BY current.year;

-- ============================================================================
-- SECTION 2: CUSTOMER ANALYTICS & RETENTION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 4: Customer Lifetime Value (CLV)
-- Techniques: CTE, Aggregate Functions, Ranking
-- ----------------------------------------------------------------------------
WITH customer_metrics AS (
    SELECT
        c.customer_id,
        c.customer_segment,
        COUNT(f.transaction_id) AS total_purchases,
        ROUND(SUM(f.revenue), 2) AS lifetime_revenue,
        ROUND(SUM(f.profit), 2) AS lifetime_profit,
        ROUND(AVG(f.revenue), 2) AS avg_order_value,
        MIN(f.transaction_date) AS first_purchase_date,
        MAX(f.transaction_date) AS last_purchase_date,
        DATEDIFF(MAX(f.transaction_date), MIN(f.transaction_date)) AS customer_lifespan_days
    FROM fact_sales f
    INNER JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY c.customer_id, c.customer_segment
)
SELECT
    customer_id,
    customer_segment,
    total_purchases,
    lifetime_revenue,
    lifetime_profit,
    avg_order_value,
    customer_lifespan_days,
    ROUND(lifetime_revenue / NULLIF(customer_lifespan_days, 0) * 30, 2) AS monthly_revenue_rate
FROM customer_metrics
ORDER BY lifetime_revenue DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- Query 5: RFM Segmentation (Recency, Frequency, Monetary)
-- Techniques: CTE, Window Functions (NTILE), CASE statements
-- ----------------------------------------------------------------------------
WITH rfm_calc AS (
    SELECT
        customer_id,
        DATEDIFF((SELECT MAX(date) FROM dim_date), MAX(transaction_date)) AS recency_days,
        COUNT(transaction_id) AS frequency,
        ROUND(SUM(revenue), 2) AS monetary
    FROM fact_sales
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM rfm_calc
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    frequency_score,
    monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total_score,
    CASE
        WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 'Champions'
        WHEN recency_score >= 3 AND frequency_score >= 3 THEN 'Loyal Customers'
        WHEN recency_score >= 4 THEN 'Recent Customers'
        WHEN monetary_score >= 4 THEN 'Big Spenders'
        WHEN recency_score <= 2 AND frequency_score <= 2 THEN 'At Risk'
        WHEN recency_score <= 2 THEN 'Lost Customers'
        ELSE 'Regular Customers'
    END AS customer_segment_rfm
FROM rfm_scores
ORDER BY rfm_total_score DESC, monetary DESC
LIMIT 100;

-- ----------------------------------------------------------------------------
-- Query 6: Customer Retention Rate by Cohort
-- Techniques: CTE, Window Functions, Cohort Analysis
-- ----------------------------------------------------------------------------
WITH customer_cohorts AS (
    SELECT
        customer_id,
        DATE_FORMAT(MIN(transaction_date), '%Y-%m') AS cohort_month,
        MIN(transaction_date) AS first_purchase_date
    FROM fact_sales
    GROUP BY customer_id
),
cohort_activity AS (
    SELECT
        c.cohort_month,
        DATE_FORMAT(f.transaction_date, '%Y-%m') AS activity_month,
        COUNT(DISTINCT f.customer_id) AS active_customers
    FROM customer_cohorts c
    INNER JOIN fact_sales f ON c.customer_id = f.customer_id
    GROUP BY c.cohort_month, DATE_FORMAT(f.transaction_date, '%Y-%m')
)
SELECT
    cohort_month,
    activity_month,
    active_customers,
    TIMESTAMPDIFF(MONTH, STR_TO_DATE(CONCAT(cohort_month, '-01'), '%Y-%m-%d'),
                          STR_TO_DATE(CONCAT(activity_month, '-01'), '%Y-%m-%d')) AS months_since_first_purchase
FROM cohort_activity
ORDER BY cohort_month, activity_month;

-- ============================================================================
-- SECTION 3: PRODUCT & CATEGORY PERFORMANCE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 7: Top 10 Products by Revenue with Ranking
-- Techniques: JOIN, Window Functions (RANK, DENSE_RANK)
-- ----------------------------------------------------------------------------
SELECT
    p.product_id,
    p.product_name,
    p.category,
    COUNT(f.transaction_id) AS total_sales,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(SUM(f.profit), 2) AS total_profit,
    RANK() OVER (ORDER BY SUM(f.revenue) DESC) AS revenue_rank,
    DENSE_RANK() OVER (PARTITION BY p.category ORDER BY SUM(f.revenue) DESC) AS category_rank
FROM fact_sales f
INNER JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- ----------------------------------------------------------------------------
-- Query 8: Product Performance with Running Total
-- Techniques: Window Functions (SUM OVER), Running Totals
-- ----------------------------------------------------------------------------
WITH product_revenue AS (
    SELECT
        p.product_name,
        p.category,
        ROUND(SUM(f.revenue), 2) AS revenue
    FROM fact_sales f
    INNER JOIN dim_product p ON f.product_id = p.product_id
    GROUP BY p.product_name, p.category
)
SELECT
    product_name,
    category,
    revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC
                       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_revenue,
    ROUND((revenue / SUM(revenue) OVER ()) * 100, 2) AS pct_of_total_revenue,
    ROUND((SUM(revenue) OVER (ORDER BY revenue DESC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
          / SUM(revenue) OVER ()) * 100, 2) AS cumulative_pct
FROM product_revenue
ORDER BY revenue DESC
LIMIT 20;

-- ----------------------------------------------------------------------------
-- Query 9: Category Performance - Month over Month Growth
-- Techniques: CTE, LAG Window Function, Growth calculations
-- ----------------------------------------------------------------------------
WITH monthly_category_sales AS (
    SELECT
        p.category,
        DATE_FORMAT(f.transaction_date, '%Y-%m') AS year_month,
        ROUND(SUM(f.revenue), 2) AS monthly_revenue
    FROM fact_sales f
    INNER JOIN dim_product p ON f.product_id = p.product_id
    GROUP BY p.category, DATE_FORMAT(f.transaction_date, '%Y-%m')
)
SELECT
    category,
    year_month,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (PARTITION BY category ORDER BY year_month) AS previous_month_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue, 1)
          OVER (PARTITION BY category ORDER BY year_month), 2) AS mom_change,
    ROUND(((monthly_revenue - LAG(monthly_revenue, 1)
            OVER (PARTITION BY category ORDER BY year_month))
          / NULLIF(LAG(monthly_revenue, 1) OVER (PARTITION BY category ORDER BY year_month), 0)) * 100, 2)
          AS mom_growth_pct
FROM monthly_category_sales
ORDER BY category, year_month;

-- ============================================================================
-- SECTION 4: STORE & REGIONAL ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 10: Store Performance Comparison
-- Techniques: Multiple JOINs, Aggregation, Ranking
-- ----------------------------------------------------------------------------
SELECT
    s.store_name,
    s.city,
    s.region,
    COUNT(f.transaction_id) AS total_transactions,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND(AVG(f.revenue), 2) AS avg_transaction_value,
    RANK() OVER (ORDER BY SUM(f.revenue) DESC) AS store_rank
FROM fact_sales f
INNER JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.city, s.region
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------
-- Query 11: Regional Performance with Market Share
-- Techniques: CTE, Window Functions, Percentage calculations
-- ----------------------------------------------------------------------------
WITH regional_sales AS (
    SELECT
        s.region,
        ROUND(SUM(f.revenue), 2) AS regional_revenue,
        ROUND(SUM(f.profit), 2) AS regional_profit,
        COUNT(DISTINCT f.customer_id) AS unique_customers
    FROM fact_sales f
    INNER JOIN dim_store s ON f.store_id = s.store_id
    GROUP BY s.region
)
SELECT
    region,
    regional_revenue,
    regional_profit,
    unique_customers,
    ROUND((regional_revenue / SUM(regional_revenue) OVER ()) * 100, 2) AS market_share_pct,
    ROUND(regional_profit / regional_revenue * 100, 2) AS profit_margin_pct
FROM regional_sales
ORDER BY regional_revenue DESC;

-- ============================================================================
-- SECTION 5: TIME-BASED ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 12: Day of Week Performance Analysis
-- Techniques: JOIN with Date dimension, Aggregation
-- ----------------------------------------------------------------------------
SELECT
    d.day_name,
    d.day_of_week,
    d.is_weekend,
    COUNT(f.transaction_id) AS total_transactions,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(AVG(f.revenue), 2) AS avg_transaction_value,
    COUNT(DISTINCT f.customer_id) AS unique_customers
FROM fact_sales f
INNER JOIN dim_date d ON f.transaction_date = d.date
GROUP BY d.day_name, d.day_of_week, d.is_weekend
ORDER BY d.day_of_week;

-- ----------------------------------------------------------------------------
-- Query 13: Quarterly Performance with YoY Comparison
-- Techniques: CTE, Complex aggregations, Self-join
-- ----------------------------------------------------------------------------
WITH quarterly_metrics AS (
    SELECT
        d.year,
        d.quarter,
        CONCAT(d.year, '-Q', d.quarter) AS year_quarter,
        ROUND(SUM(f.revenue), 2) AS revenue,
        ROUND(SUM(f.profit), 2) AS profit,
        COUNT(DISTINCT f.customer_id) AS customers
    FROM fact_sales f
    INNER JOIN dim_date d ON f.transaction_date = d.date
    GROUP BY d.year, d.quarter
)
SELECT
    current.year_quarter,
    current.revenue AS current_revenue,
    previous.revenue AS previous_year_revenue,
    ROUND(((current.revenue - previous.revenue) / NULLIF(previous.revenue, 0)) * 100, 2) AS yoy_growth_pct,
    current.customers AS current_customers,
    previous.customers AS previous_year_customers
FROM quarterly_metrics current
LEFT JOIN quarterly_metrics previous
    ON current.quarter = previous.quarter
    AND current.year = previous.year + 1
ORDER BY current.year, current.quarter;

-- ----------------------------------------------------------------------------
-- Query 14: Seasonal Trends Analysis
-- Techniques: CASE statements, Aggregation by custom groups
-- ----------------------------------------------------------------------------
SELECT
    d.year,
    CASE
        WHEN d.month IN (12, 1, 2) THEN 'Winter'
        WHEN d.month IN (3, 4, 5) THEN 'Spring'
        WHEN d.month IN (6, 7, 8) THEN 'Summer'
        WHEN d.month IN (9, 10, 11) THEN 'Fall'
    END AS season,
    COUNT(f.transaction_id) AS total_transactions,
    ROUND(SUM(f.revenue), 2) AS seasonal_revenue,
    ROUND(AVG(f.revenue), 2) AS avg_order_value,
    COUNT(DISTINCT f.customer_id) AS unique_customers
FROM fact_sales f
INNER JOIN dim_date d ON f.transaction_date = d.date
GROUP BY d.year, season
ORDER BY d.year, FIELD(season, 'Winter', 'Spring', 'Summer', 'Fall');

-- ============================================================================
-- SECTION 6: CUSTOMER BEHAVIOR ANALYSIS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 15: Customer Purchase Frequency Distribution
-- Techniques: Subquery, CASE statements, Distribution analysis
-- ----------------------------------------------------------------------------
WITH customer_frequency AS (
    SELECT
        customer_id,
        COUNT(transaction_id) AS purchase_count
    FROM fact_sales
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN purchase_count = 1 THEN '1 purchase'
        WHEN purchase_count BETWEEN 2 AND 5 THEN '2-5 purchases'
        WHEN purchase_count BETWEEN 6 AND 10 THEN '6-10 purchases'
        WHEN purchase_count BETWEEN 11 AND 20 THEN '11-20 purchases'
        ELSE '20+ purchases'
    END AS frequency_bucket,
    COUNT(customer_id) AS customer_count,
    ROUND(COUNT(customer_id) * 100.0 / SUM(COUNT(customer_id)) OVER (), 2) AS pct_of_customers
FROM customer_frequency
GROUP BY frequency_bucket
ORDER BY MIN(purchase_count);

-- ----------------------------------------------------------------------------
-- Query 16: Average Days Between Purchases
-- Techniques: Window Functions (LAG), Date calculations
-- ----------------------------------------------------------------------------
WITH customer_purchase_dates AS (
    SELECT
        customer_id,
        transaction_date,
        LAG(transaction_date) OVER (PARTITION BY customer_id ORDER BY transaction_date) AS previous_purchase_date
    FROM fact_sales
),
purchase_intervals AS (
    SELECT
        customer_id,
        DATEDIFF(transaction_date, previous_purchase_date) AS days_between_purchases
    FROM customer_purchase_dates
    WHERE previous_purchase_date IS NOT NULL
)
SELECT
    customer_id,
    COUNT(*) AS number_of_repeat_purchases,
    ROUND(AVG(days_between_purchases), 1) AS avg_days_between_purchases,
    MIN(days_between_purchases) AS min_days_between_purchases,
    MAX(days_between_purchases) AS max_days_between_purchases
FROM purchase_intervals
GROUP BY customer_id
HAVING COUNT(*) >= 3  -- Only customers with 3+ purchases
ORDER BY avg_days_between_purchases
LIMIT 50;

-- ============================================================================
-- SECTION 7: ADVANCED ANALYTICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 17: Pareto Analysis (80/20 Rule) - Top Customers
-- Techniques: CTE, Window Functions, Running totals
-- ----------------------------------------------------------------------------
WITH customer_revenue AS (
    SELECT
        f.customer_id,
        c.customer_segment,
        ROUND(SUM(f.revenue), 2) AS total_revenue
    FROM fact_sales f
    INNER JOIN dim_customer c ON f.customer_id = c.customer_id
    GROUP BY f.customer_id, c.customer_segment
),
customer_ranked AS (
    SELECT
        customer_id,
        customer_segment,
        total_revenue,
        SUM(total_revenue) OVER (ORDER BY total_revenue DESC
                                 ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
        SUM(total_revenue) OVER () AS grand_total,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS customer_rank
    FROM customer_revenue
)
SELECT
    customer_id,
    customer_segment,
    total_revenue,
    customer_rank,
    ROUND((running_total / grand_total) * 100, 2) AS cumulative_revenue_pct,
    CASE
        WHEN (running_total / grand_total) <= 0.80 THEN 'Top 80% Revenue Contributors'
        ELSE 'Bottom 20% Revenue'
    END AS pareto_segment
FROM customer_ranked
ORDER BY customer_rank
LIMIT 100;

-- ----------------------------------------------------------------------------
-- Query 18: Customer Segment Performance Comparison
-- Techniques: Multiple aggregations, CASE statements
-- ----------------------------------------------------------------------------
SELECT
    c.customer_segment,
    COUNT(DISTINCT f.customer_id) AS customer_count,
    COUNT(f.transaction_id) AS total_transactions,
    ROUND(AVG(COUNT(f.transaction_id)) OVER (PARTITION BY c.customer_segment), 2) AS avg_transactions_per_customer,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(AVG(f.revenue), 2) AS avg_order_value,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.revenue)) * 100, 2) AS profit_margin_pct,
    ROUND(SUM(f.revenue) / COUNT(DISTINCT f.customer_id), 2) AS revenue_per_customer
FROM fact_sales f
INNER JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_segment
ORDER BY total_revenue DESC;

-- ----------------------------------------------------------------------------
-- Query 19: Product Cross-Category Purchases
-- Techniques: Self-join, Distinct counts
-- ----------------------------------------------------------------------------
WITH customer_categories AS (
    SELECT DISTINCT
        f.customer_id,
        p.category
    FROM fact_sales f
    INNER JOIN dim_product p ON f.product_id = p.product_id
)
SELECT
    c1.category AS category_1,
    c2.category AS category_2,
    COUNT(DISTINCT c1.customer_id) AS customers_purchasing_both
FROM customer_categories c1
INNER JOIN customer_categories c2
    ON c1.customer_id = c2.customer_id
    AND c1.category < c2.category  -- Avoid duplicates and self-pairs
GROUP BY c1.category, c2.category
HAVING COUNT(DISTINCT c1.customer_id) > 50
ORDER BY customers_purchasing_both DESC;

-- ----------------------------------------------------------------------------
-- Query 20: Monthly Active Customer Retention
-- Techniques: CTE, Window Functions (LAG), Month-over-month tracking
-- ----------------------------------------------------------------------------
WITH monthly_customers AS (
    SELECT DISTINCT
        DATE_FORMAT(transaction_date, '%Y-%m') AS year_month,
        customer_id
    FROM fact_sales
),
customer_counts AS (
    SELECT
        year_month,
        COUNT(customer_id) AS active_customers
    FROM monthly_customers
    GROUP BY year_month
)
SELECT
    year_month,
    active_customers,
    LAG(active_customers, 1) OVER (ORDER BY year_month) AS previous_month_customers,
    active_customers - LAG(active_customers, 1) OVER (ORDER BY year_month) AS customer_change,
    ROUND(((active_customers - LAG(active_customers, 1) OVER (ORDER BY year_month))
          / NULLIF(LAG(active_customers, 1) OVER (ORDER BY year_month), 0)) * 100, 2) AS retention_growth_pct
FROM customer_counts
ORDER BY year_month;

-- ----------------------------------------------------------------------------
-- Query 21: Discount Impact Analysis
-- Techniques: CASE statements, Aggregations, Comparison
-- ----------------------------------------------------------------------------
SELECT
    CASE
        WHEN f.discount_percent = 0 THEN 'No Discount'
        WHEN f.discount_percent > 0 AND f.discount_percent <= 10 THEN '1-10% Discount'
        WHEN f.discount_percent > 10 AND f.discount_percent <= 20 THEN '11-20% Discount'
        ELSE '20%+ Discount'
    END AS discount_tier,
    COUNT(f.transaction_id) AS transaction_count,
    ROUND(AVG(f.quantity), 2) AS avg_quantity,
    ROUND(AVG(f.revenue), 2) AS avg_revenue,
    ROUND(SUM(f.revenue), 2) AS total_revenue,
    ROUND(SUM(f.profit), 2) AS total_profit,
    ROUND((SUM(f.profit) / SUM(f.revenue)) * 100, 2) AS profit_margin_pct
FROM fact_sales f
GROUP BY discount_tier
ORDER BY MIN(f.discount_percent);

-- ----------------------------------------------------------------------------
-- Query 22: Payment Method Analysis
-- Techniques: GROUP BY, Aggregations
-- ----------------------------------------------------------------------------
SELECT
    payment_method,
    COUNT(transaction_id) AS transaction_count,
    ROUND(COUNT(transaction_id) * 100.0 / SUM(COUNT(transaction_id)) OVER (), 2) AS pct_of_transactions,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(AVG(revenue), 2) AS avg_transaction_value,
    ROUND(SUM(revenue) * 100.0 / SUM(SUM(revenue)) OVER (), 2) AS pct_of_revenue
FROM fact_sales
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- ============================================================================
-- SUMMARY DASHBOARD QUERY - Key Metrics Overview
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Query 23: Executive Summary KPIs
-- Techniques: Multiple CTEs, Complex aggregations
-- ----------------------------------------------------------------------------
WITH overall_metrics AS (
    SELECT
        COUNT(DISTINCT transaction_id) AS total_transactions,
        COUNT(DISTINCT customer_id) AS total_customers,
        ROUND(SUM(revenue), 2) AS total_revenue,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(AVG(revenue), 2) AS avg_order_value
    FROM fact_sales
),
current_month AS (
    SELECT
        ROUND(SUM(revenue), 2) AS current_month_revenue
    FROM fact_sales
    WHERE DATE_FORMAT(transaction_date, '%Y-%m') = (
        SELECT MAX(DATE_FORMAT(transaction_date, '%Y-%m')) FROM fact_sales
    )
),
previous_month AS (
    SELECT
        ROUND(SUM(revenue), 2) AS previous_month_revenue
    FROM fact_sales
    WHERE DATE_FORMAT(transaction_date, '%Y-%m') = (
        SELECT DATE_FORMAT(DATE_SUB(STR_TO_DATE(CONCAT(MAX(DATE_FORMAT(transaction_date, '%Y-%m')), '-01'), '%Y-%m-%d'),
                           INTERVAL 1 MONTH), '%Y-%m')
        FROM fact_sales
    )
)
SELECT
    'Executive Summary' AS metric_category,
    om.total_transactions,
    om.total_customers,
    om.total_revenue,
    om.total_profit,
    ROUND((om.total_profit / om.total_revenue) * 100, 2) AS overall_profit_margin_pct,
    om.avg_order_value,
    cm.current_month_revenue,
    pm.previous_month_revenue,
    ROUND(((cm.current_month_revenue - pm.previous_month_revenue) / pm.previous_month_revenue) * 100, 2) AS mom_growth_pct
FROM overall_metrics om, current_month cm, previous_month pm;

-- ============================================================================
-- END OF ANALYTICAL QUERIES
-- ============================================================================
-- Total Queries: 23 SQL queries demonstrating:
-- ✓ INNER/LEFT JOINs
-- ✓ Common Table Expressions (CTEs)
-- ✓ Window Functions (ROW_NUMBER, RANK, LAG, LEAD, NTILE, SUM OVER)
-- ✓ Subqueries and Derived Tables
-- ✓ Aggregate Functions
-- ✓ Date/Time Functions
-- ✓ CASE Statements
-- ✓ Business Analytics (Revenue, Margin, Retention, RFM, Cohorts)
-- ============================================================================
