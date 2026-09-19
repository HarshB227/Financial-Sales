# 🚀 Setup Instructions

## Quick Start Guide for Financial & Sales Analytics Dashboard

Follow these steps to get your complete analytics dashboard up and running.

---

## ✅ Prerequisites Checklist

- [ ] Python 3.8+ installed
- [ ] MySQL 8.0+ installed and running
- [ ] Power BI Desktop installed (latest version)
- [ ] Text editor or IDE

---

## 📦 Step 1: Generate Sample Data (Already Complete!)

The sample dataset has been generated with:
- ✅ 55,000 transactions
- ✅ 2,000 customers
- ✅ 27 products across 5 categories
- ✅ 8 stores in 4 regions
- ✅ Data spanning Jan 2022 - Mar 2024

**Generated Files:**
```
data/
  ├── sales_transactions.csv    (55,000 rows - FACT TABLE)
  ├── dim_products.csv          (27 rows)
  ├── dim_customers.csv         (2,000 rows)
  ├── dim_stores.csv            (8 rows)
  └── dim_dates.csv             (974 rows)
```

**Skip to Step 2** if data is already generated.

To regenerate data:
```bash
cd data
pip install -r requirements.txt
python generate_sales_data.py
```

---

## 🗄️ Step 2: Set Up MySQL Database

### A. Create Database
```bash
mysql -u root -p < sql/01_database_setup.sql
```

### B. Create Star Schema Tables
```bash
mysql -u root -p retail_analytics < sql/02_star_schema.sql
```

### C. Load Data into MySQL

**Option 1: MySQL Command Line (if LOCAL INFILE enabled)**

First, enable local infile:
```sql
SET GLOBAL local_infile = 1;
```

Then update file paths in `sql/03_data_load.sql` to match your system:
```sql
-- Change this line in 03_data_load.sql:
LOAD DATA LOCAL INFILE 'D:/task/Financial-Sales-Dashboard/data/dim_dates.csv'
-- To your actual path
```

Run:
```bash
mysql -u root -p --local-infile=1 retail_analytics < sql/03_data_load.sql
```

**Option 2: MySQL Workbench (Easier)**

1. Open MySQL Workbench
2. Connect to your database
3. Select `retail_analytics` database
4. For each table:
   - Right-click table → "Table Data Import Wizard"
   - Select corresponding CSV file
   - Match columns
   - Import

**Import Order (IMPORTANT):**
1. dim_dates.csv → dim_date
2. dim_products.csv → dim_product
3. dim_customers.csv → dim_customer
4. dim_stores.csv → dim_store
5. sales_transactions.csv → fact_sales

**Option 3: Python Script (Alternative)**

Create `load_data.py`:
```python
import pandas as pd
import mysql.connector

# Database connection
conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='your_password',
    database='retail_analytics'
)

# Load each CSV
tables = {
    'dim_date': 'dim_dates.csv',
    'dim_product': 'dim_products.csv',
    'dim_customer': 'dim_customers.csv',
    'dim_store': 'dim_stores.csv',
    'fact_sales': 'sales_transactions.csv'
}

for table, file in tables.items():
    df = pd.read_csv(f'data/{file}')
    df.to_sql(table, conn, if_exists='append', index=False)
    print(f"Loaded {table}")

conn.close()
```

### D. Verify Data Load
```sql
USE retail_analytics;

SELECT 'dim_date' AS table_name, COUNT(*) AS rows FROM dim_date
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales;
```

Expected results:
- dim_date: ~974 rows
- dim_product: 27 rows
- dim_customer: 2,000 rows
- dim_store: 8 rows
- fact_sales: 55,000 rows

---

## 🔍 Step 3: Test SQL Queries (Optional but Recommended)

Run sample queries to verify everything works:

```bash
mysql -u root -p retail_analytics < sql/04_analytical_queries.sql
```

Or test individual queries:
```sql
-- Test: Total Revenue by Category
SELECT
    p.category,
    ROUND(SUM(f.revenue), 2) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;
```

---

## 📊 Step 4: Build Power BI Dashboard

### A. Connect Power BI to MySQL

1. **Open Power BI Desktop**

2. **Get Data:**
   - Click "Get Data" → "Database" → "MySQL database"
   - Server: `localhost` (or your MySQL server)
   - Database: `retail_analytics`
   - Click "OK"

3. **Install MySQL Connector (if prompted):**
   - Download from: https://dev.mysql.com/downloads/connector/net/
   - Install and restart Power BI

4. **Select Tables:**
   - Check all 5 tables:
     - dim_date
     - dim_product
     - dim_customer
     - dim_store
     - fact_sales
   - Click "Load"

### B. Create Relationships

1. Click "Model" view (left sidebar)

2. Create these relationships (drag & drop):
   - `fact_sales[transaction_date]` → `dim_date[date]`
   - `fact_sales[customer_id]` → `dim_customer[customer_id]`
   - `fact_sales[product_id]` → `dim_product[product_id]`
   - `fact_sales[store_id]` → `dim_store[store_id]`

3. Set all relationships to:
   - Cardinality: Many-to-One (fact → dimension)
   - Cross filter: Single direction
   - Active: Yes

4. Mark date table:
   - Right-click `dim_date`
   - "Mark as date table"
   - Select `date` column

### C. Add DAX Measures

1. Create measures table:
   - Click "Data" view
   - Modeling → New Table
   - Name: `_Measures`
   - Formula: `_Measures = {1}`

2. Copy measures from `powerbi/dax_measures.txt`
   - Start with essential measures:
     - Total Revenue
     - Total Profit
     - Profit Margin %
     - YoY Revenue Growth %
     - Unique Customers
     - Customer Lifetime Value

3. Test each measure in a card visual

### D. Build Dashboard Pages

**Follow the detailed guide in:**
`powerbi/dashboard_setup_guide.md`

**Quick 4-page structure:**
1. **Executive Summary** - KPIs, trends, category performance
2. **Sales Deep Dive** - Store, product, payment analysis
3. **Customer Analytics** - RFM, CLV, retention, cohorts
4. **Time Intelligence** - YoY, MoM, seasonal trends

### E. Apply Formatting

1. Choose a theme (View → Themes)
2. Add slicers for:
   - Date range
   - Region
   - Category
   - Store
3. Format visuals consistently
4. Add page navigation

### F. Save & Publish

1. File → Save As → `Financial_Sales_Analytics_Dashboard.pbix`
2. (Optional) Publish to Power BI Service for sharing

---

## 🧪 Step 5: Validate Your Dashboard

### Data Validation Checks:

- [ ] Total Revenue: ~$27.8M
- [ ] Total Profit: ~$11.7M
- [ ] Profit Margin: ~42%
- [ ] Total Transactions: 55,000
- [ ] Date Range: Jan 2022 - Mar 2024
- [ ] Top Category: Electronics
- [ ] All slicers filter correctly
- [ ] YoY measures show data for 2022-2024

### Visual Quality Checks:

- [ ] All charts load without errors
- [ ] Filters work across pages
- [ ] DAX measures calculate correctly
- [ ] No blank visuals
- [ ] Professional formatting applied
- [ ] Tooltips work
- [ ] Drill-through pages function

---

## 📁 Project Structure Reference

```
Financial-Sales-Dashboard/
│
├── README.md                        ← Start here
├── SETUP_INSTRUCTIONS.md            ← This file
│
├── data/
│   ├── generate_sales_data.py       ← Data generator script
│   ├── requirements.txt             ← Python dependencies
│   ├── sales_transactions.csv       ← Generated fact table
│   ├── dim_products.csv             ← Product dimension
│   ├── dim_customers.csv            ← Customer dimension
│   ├── dim_stores.csv               ← Store dimension
│   └── dim_dates.csv                ← Date dimension
│
├── sql/
│   ├── 01_database_setup.sql        ← Create database
│   ├── 02_star_schema.sql           ← Create tables
│   ├── 03_data_load.sql             ← Load CSV data
│   └── 04_analytical_queries.sql    ← 23 analytical queries
│
├── powerbi/
│   ├── dax_measures.txt             ← 70+ DAX formulas
│   └── dashboard_setup_guide.md     ← Detailed Power BI guide
│
└── docs/
    ├── data_model_diagram.md        ← Star schema documentation
    └── kpi_definitions.md           ← Business metrics guide
```

---

## 🐛 Troubleshooting

### MySQL Connection Issues

**Error:** "Can't connect to MySQL server"
- **Fix:** Ensure MySQL service is running
- Windows: Services → MySQL80 → Start
- Mac/Linux: `sudo systemctl start mysql`

**Error:** "Access denied for user"
- **Fix:** Check username/password
- Reset: `ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';`

### Data Loading Issues

**Error:** "The used command is not allowed with this MySQL version"
- **Fix:** Enable local_infile:
  ```sql
  SET GLOBAL local_infile = 1;
  ```
- Use MySQL Workbench import wizard instead

**Error:** "Duplicate entry for primary key"
- **Fix:** Drop and recreate tables:
  ```sql
  DROP TABLE IF EXISTS fact_sales;
  -- Then re-run 02_star_schema.sql
  ```

### Power BI Issues

**Error:** MySQL connector not found
- **Fix:** Download and install MySQL .NET Connector
- URL: https://dev.mysql.com/downloads/connector/net/

**Error:** Relationships auto-detected incorrectly
- **Fix:** Delete auto-created relationships
- Manually create as specified in setup

**DAX Measure Errors:**
- Check table/column names match exactly
- Ensure relationships are active
- Verify date table is marked

---

## 💡 Tips for Success

1. **Follow the order:** Database → SQL → Power BI
2. **Verify each step:** Don't skip validation checks
3. **Start simple:** Build basic visuals first, add complexity later
4. **Save often:** Power BI files can be large, save incremental versions
5. **Test filters:** Verify slicers filter all visuals correctly
6. **Use bookmarks:** Create saved views for presentations

---

## 📚 Additional Resources

- **MySQL Documentation:** https://dev.mysql.com/doc/
- **Power BI Docs:** https://docs.microsoft.com/power-bi/
- **DAX Guide:** https://dax.guide/
- **SQL Tutorial:** https://www.w3schools.com/sql/

---

## ✅ Completion Checklist

- [ ] Python dependencies installed
- [ ] Sample data generated (5 CSV files)
- [ ] MySQL database created
- [ ] Star schema tables created
- [ ] Data loaded into MySQL
- [ ] Data validated (row counts correct)
- [ ] Power BI connected to MySQL
- [ ] Relationships created
- [ ] DAX measures added
- [ ] Dashboard pages built
- [ ] Formatting applied
- [ ] Final validation passed
- [ ] Dashboard saved

---

## 🎉 Next Steps

Once your dashboard is complete:

1. **Explore the data** - Use slicers to filter and discover insights
2. **Customize visuals** - Adjust colors, fonts to match your style
3. **Add more measures** - Copy additional DAX from dax_measures.txt
4. **Share your work** - Publish to Power BI Service or export to PDF
5. **Portfolio ready!** - Take screenshots for your resume/portfolio

---

## 📞 Support

For issues or questions:
1. Check `docs/` folder for detailed documentation
2. Review SQL query outputs for data validation
3. Consult Power BI error messages - they're usually helpful!

---

**Estimated Setup Time:** 2-3 hours (first time)

**Good luck building your dashboard!** 🚀
