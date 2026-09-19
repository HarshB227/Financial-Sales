# Data Model Diagram - Star Schema

## 📊 Financial & Sales Analytics - Data Model

This document describes the star schema data model used for the Financial & Sales Analytics Dashboard.

---

## 🌟 Star Schema Overview

```
                         ┌─────────────────┐
                         │   dim_date      │
                         ├─────────────────┤
                         │ date (PK)       │
                         │ year            │
                         │ quarter         │
                         │ month           │
                         │ month_name      │
                         │ day             │
                         │ day_of_week     │
                         │ day_name        │
                         │ week_of_year    │
                         │ is_weekend      │
                         └────────┬────────┘
                                  │
                                  │ 1
                                  │
                                  │ *
        ┌─────────────────────────────────────────────┐
        │            fact_sales (FACT TABLE)          │
        ├─────────────────────────────────────────────┤
        │ transaction_id (PK)                         │
        │ transaction_date (FK) ──────────────────────┘
        │ customer_id (FK) ────────┐
        │ product_id (FK) ──────┐  │
        │ store_id (FK) ────┐   │  │
        │ quantity          │   │  │
        │ unit_price        │   │  │
        │ discount_percent  │   │  │
        │ revenue           │   │  │
        │ cost              │   │  │
        │ profit            │   │  │
        │ payment_method    │   │  │
        └───────────────────┼───┼──┼──┘
                            │   │  │
                         *  │   │  │  *
                         ┌──┘   │  └────────────────┐
                         │      │                   │
                      1  │      │  1             1  │
              ┌──────────┴──┐   │     ┌─────────────┴────────┐
              │  dim_store  │   │     │    dim_customer      │
              ├─────────────┤   │     ├──────────────────────┤
              │ store_id(PK)│   │     │ customer_id (PK)     │
              │ store_name  │   │     │ customer_segment     │
              │ city        │   │     │ registration_date    │
              │ state       │   │     └──────────────────────┘
              │ region      │   │
              └─────────────┘   │
                                │  *
                                │
                             1  │
                    ┌───────────┴────────┐
                    │   dim_product      │
                    ├────────────────────┤
                    │ product_id (PK)    │
                    │ product_name       │
                    │ category           │
                    │ base_price         │
                    │ cost_price         │
                    └────────────────────┘
```

---

## 📋 Table Descriptions

### 🎯 Fact Table

#### **fact_sales**
Central fact table containing all sales transactions.

| Column | Type | Description |
|--------|------|-------------|
| transaction_id | INT (PK) | Unique transaction identifier |
| transaction_date | DATE (FK) | Date of transaction → dim_date |
| customer_id | INT (FK) | Customer identifier → dim_customer |
| product_id | INT (FK) | Product identifier → dim_product |
| store_id | INT (FK) | Store identifier → dim_store |
| quantity | INT | Number of units sold |
| unit_price | DECIMAL(10,2) | Price per unit (after discount) |
| discount_percent | DECIMAL(5,2) | Discount percentage applied |
| revenue | DECIMAL(12,2) | Total revenue (unit_price × quantity) |
| cost | DECIMAL(12,2) | Total cost (cost_price × quantity) |
| profit | DECIMAL(12,2) | Total profit (revenue - cost) |
| payment_method | VARCHAR(50) | Payment method used |

**Row Count:** 55,000+ transactions  
**Date Range:** 2022-01-01 to 2024-08-31  
**Grain:** One row per transaction (transaction line item)

---

### 📅 Dimension Tables

#### **dim_date**
Date dimension for time intelligence analysis.

| Column | Type | Description |
|--------|------|-------------|
| date_id | INT (PK, Auto) | Auto-incrementing ID |
| date | DATE (UNIQUE) | Actual date value |
| year | INT | Year (2022, 2023, 2024) |
| quarter | INT | Quarter (1-4) |
| month | INT | Month (1-12) |
| month_name | VARCHAR(20) | Month name (January, etc.) |
| day | INT | Day of month (1-31) |
| day_of_week | INT | Day of week (1=Monday, 7=Sunday) |
| day_name | VARCHAR(20) | Day name (Monday, etc.) |
| week_of_year | INT | Week number (1-53) |
| is_weekend | BOOLEAN | Weekend indicator (Saturday/Sunday) |

**Row Count:** ~970 days  
**Purpose:** Enables YoY, MoM, QTD, YTD calculations

---

#### **dim_product**
Product dimension with category and pricing information.

| Column | Type | Description |
|--------|------|-------------|
| product_id | INT (PK) | Unique product identifier |
| product_name | VARCHAR(100) | Product name |
| category | VARCHAR(50) | Product category |
| base_price | DECIMAL(10,2) | Standard retail price |
| cost_price | DECIMAL(10,2) | Cost to company |

**Row Count:** 28 products  
**Categories:** Electronics, Clothing, Home & Garden, Sports, Books

---

#### **dim_customer**
Customer dimension with segmentation.

| Column | Type | Description |
|--------|------|-------------|
| customer_id | INT (PK) | Unique customer identifier |
| customer_segment | VARCHAR(50) | Customer segment (Premium, Regular, etc.) |
| registration_date | DATE | First registration date |

**Row Count:** 2,000 customers  
**Segments:** Premium, Regular, Occasional, New

---

#### **dim_store**
Store/location dimension.

| Column | Type | Description |
|--------|------|-------------|
| store_id | INT (PK) | Unique store identifier |
| store_name | VARCHAR(100) | Store name |
| city | VARCHAR(50) | City location |
| state | VARCHAR(2) | State code (NY, CA, etc.) |
| region | VARCHAR(50) | Region (Northeast, West, etc.) |

**Row Count:** 8 stores  
**Regions:** Northeast, West, South, Midwest

---

## 🔗 Relationships

### Relationship Details

| From (Fact) | To (Dimension) | Type | Cardinality |
|-------------|----------------|------|-------------|
| fact_sales.transaction_date | dim_date.date | FK → PK | Many-to-One |
| fact_sales.customer_id | dim_customer.customer_id | FK → PK | Many-to-One |
| fact_sales.product_id | dim_product.product_id | FK → PK | Many-to-One |
| fact_sales.store_id | dim_store.store_id | FK → PK | Many-to-One |

**Filter Direction:** Single (Dimension → Fact)  
**Relationship Type:** All relationships are ACTIVE  
**Referential Integrity:** Enforced via MySQL foreign keys

---

## 📊 Data Model Characteristics

### ✅ Star Schema Benefits

1. **Simple & Intuitive**
   - Easy to understand for business users
   - Clear separation of facts and dimensions
   - Straightforward join paths

2. **Query Performance**
   - Optimized for OLAP queries
   - Minimal joins required
   - Indexed foreign keys for fast lookups

3. **Easy Aggregation**
   - Natural grouping by dimensions
   - Efficient SUM, COUNT, AVG operations
   - Fast drill-down and roll-up

4. **Scalability**
   - Can easily add new dimensions
   - Supports growing fact table
   - Compatible with BI tools (Power BI, Tableau)

---

## 🎯 Query Patterns

### Common Query Pattern
```sql
SELECT
    d.year,
    d.month_name,
    p.category,
    s.region,
    SUM(f.revenue) AS total_revenue,
    SUM(f.profit) AS total_profit
FROM fact_sales f
INNER JOIN dim_date d ON f.transaction_date = d.date
INNER JOIN dim_product p ON f.product_id = p.product_id
INNER JOIN dim_store s ON f.store_id = s.store_id
GROUP BY d.year, d.month_name, p.category, s.region;
```

### Performance Indexes

**Fact Table (fact_sales):**
- Primary Key: `transaction_id`
- Foreign Key Indexes: `transaction_date`, `customer_id`, `product_id`, `store_id`
- Composite Indexes: `(transaction_date, customer_id)`, `(transaction_date, product_id)`

**Dimension Tables:**
- Primary Keys on all dimension keys
- Category/grouping columns indexed (e.g., `category`, `region`, `customer_segment`)

---

## 📈 Business Metrics Supported

This star schema enables analysis of:

### Revenue & Profitability
- Total revenue, cost, profit by any dimension
- Profit margins by product, category, store
- Average order value trends

### Time-Based Analysis
- Year-over-Year (YoY) growth
- Month-over-Month (MoM) trends
- Quarterly and seasonal patterns
- YTD, QTD, MTD comparisons

### Customer Analytics
- Customer Lifetime Value (CLV)
- RFM Segmentation (Recency, Frequency, Monetary)
- Customer retention and churn
- Cohort analysis
- Repeat purchase rates

### Product Performance
- Top/bottom products by revenue
- Category mix and contribution
- Product profitability analysis
- Discount impact on sales

### Geographic Analysis
- Store performance comparison
- Regional revenue distribution
- City/state-level analysis

---

## 🔄 Data Refresh Strategy

### Current Setup (Static Dataset)
- One-time load from CSV files
- Date range: 2022-2024

### Production Recommendations
1. **Incremental Load**
   - Load only new transactions daily
   - Update fact table with yesterday's transactions

2. **Dimension Updates**
   - Slowly Changing Dimensions (SCD Type 2) for historical tracking
   - New products/stores added as needed

3. **Date Dimension**
   - Pre-populate 10 years into future
   - Auto-generate via script

---

## 📊 Model Statistics

| Metric | Value |
|--------|-------|
| Total Tables | 5 (1 fact, 4 dimensions) |
| Total Rows | ~58,000 |
| Fact Table Rows | 55,000+ |
| Relationships | 4 (many-to-one) |
| Date Range | Jan 2022 - Aug 2024 (~32 months) |
| Grain | Transaction level |
| Database Size | ~15-20 MB |

---

## 🛠️ Technical Implementation

### MySQL Engine
- Engine: **InnoDB**
- Character Set: **utf8mb4**
- Collation: **utf8mb4_unicode_ci**

### Constraints
- Primary Keys on all tables
- Foreign Key constraints enforced
- NOT NULL constraints on key fields
- DECIMAL precision for financial data

---

## 📝 Notes

1. **Grain of Fact Table:** Each row represents one transaction (one product purchase)
2. **Additivity:** Revenue, cost, profit, quantity are fully additive across all dimensions
3. **Date Handling:** All dates are stored as DATE type (no time component)
4. **Currency:** All monetary values in USD (adjust as needed)
5. **Indexes:** Optimized for analytical queries, not OLTP

---

## 🎓 Best Practices Applied

✅ **Star schema design** (not snowflake)  
✅ **Surrogate keys** where beneficial  
✅ **Date dimension** for time intelligence  
✅ **Denormalized dimensions** for query performance  
✅ **Consistent naming conventions**  
✅ **Foreign key constraints** for data integrity  
✅ **Indexed join columns** for performance  
✅ **Separated facts from dimensions**  

---

**Last Updated:** 2024  
**Model Version:** 1.0  
**Compatible With:** Power BI, Tableau, MySQL 8.0+
