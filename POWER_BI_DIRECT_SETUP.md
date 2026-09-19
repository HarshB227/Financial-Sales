# Power BI Setup (Direct from CSV - No MySQL Required)

## ⚡ Quick Setup - 15 Minutes

Since you don't have MySQL installed, you can build the dashboard directly from CSV files!

### Step 1: Open Power BI Desktop
1. Launch Power BI Desktop
2. Click "Get Data" → "Text/CSV"

### Step 2: Import CSV Files (in this order)

Navigate to: `D:\task\Financial-Sales-Dashboard\data\`

**Import these 5 files:**
1. ✅ `dim_dates.csv`
2. ✅ `dim_products.csv`
3. ✅ `dim_customers.csv`
4. ✅ `dim_stores.csv`
5. ✅ `sales_transactions.csv`

For each file:
- Click "Transform Data"
- Check column types are correct
- Click "Close & Apply"

### Step 3: Create Relationships

Click "Model" view (left sidebar), then drag to create:

1. `sales_transactions[transaction_date]` → `dim_dates[date]` (Many-to-One)
2. `sales_transactions[customer_id]` → `dim_customers[customer_id]` (Many-to-One)
3. `sales_transactions[product_id]` → `dim_products[product_id]` (Many-to-One)
4. `sales_transactions[store_id]` → `dim_stores[store_id]` (Many-to-One)

**Mark date table:**
- Right-click `dim_dates` → "Mark as date table"
- Select `date` column

### Step 4: Add Key DAX Measures

Click "Data" view → New Measure, paste these:

```DAX
Total Revenue = SUM(sales_transactions[revenue])

Total Profit = SUM(sales_transactions[profit])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0) * 100

Unique Customers = DISTINCTCOUNT(sales_transactions[customer_id])

Average Order Value = AVERAGE(sales_transactions[revenue])
```

### Step 5: Build Your First Visual

1. Click "Report" view
2. Add a Card visual
3. Drag `Total Revenue` measure
4. You should see: **$27.8M** ✅

### Step 6: Build Dashboard

Follow: `powerbi/dashboard_setup_guide.md` for complete dashboard

---

## ✅ That's it! No MySQL needed!

Your dashboard will work perfectly with CSV files.
All 70+ DAX measures from `powerbi/dax_measures.txt` will work.
