# Power BI Dashboard Setup Guide

## 📊 Financial & Sales Analytics Dashboard

This guide will walk you through setting up the complete Power BI dashboard from scratch.

---

## 🎯 Prerequisites

- ✅ Power BI Desktop (latest version) installed
- ✅ MySQL database with data loaded OR CSV files generated
- ✅ Basic understanding of Power BI interface

---

## 📁 PART 1: Data Connection & Import

### Option A: Connect to MySQL Database (Recommended)

1. **Open Power BI Desktop**
   - Click "Get Data" → "Database" → "MySQL database"

2. **Enter Connection Details**
   - Server: `localhost` (or your MySQL server)
   - Database: `retail_analytics`
   - Click "OK"

3. **Select Tables**
   - Select all tables:
     - `dim_date`
     - `dim_product`
     - `dim_customer`
     - `dim_store`
     - `fact_sales`
   - Click "Load"

### Option B: Import from CSV Files

1. **Click "Get Data" → "Text/CSV"**

2. **Import each file in order:**
   - `dim_dates.csv`
   - `dim_products.csv`
   - `dim_customers.csv`
   - `dim_stores.csv`
   - `sales_transactions.csv`

3. **For each file:**
   - Navigate to the file location
   - Click "Transform Data" (not "Load")
   - Check data types are correct
   - Click "Close & Apply"

---

## 🔗 PART 2: Create Data Model Relationships

1. **Click "Model" view** (left sidebar icon)

2. **Create Relationships** (Drag and drop between tables):

   **From fact_sales to dimensions:**
   - `fact_sales[transaction_date]` → `dim_date[date]` (Many-to-One)
   - `fact_sales[customer_id]` → `dim_customer[customer_id]` (Many-to-One)
   - `fact_sales[product_id]` → `dim_product[product_id]` (Many-to-One)
   - `fact_sales[store_id]` → `dim_store[store_id]` (Many-to-One)

3. **Configure Relationships:**
   - All relationships should be **One-to-Many** (from dimension to fact)
   - Cardinality: **One-to-Many**
   - Cross filter direction: **Single** (dimension → fact)
   - Make relationships **Active**

4. **Mark Date Table:**
   - Right-click `dim_date` table
   - Select "Mark as date table"
   - Choose `date` column as the date column

---

## 📐 PART 3: Create DAX Measures

### 3.1 Create Measure Table (Organization)

1. Click "Data" view → "Modeling" tab
2. Click "New Table"
3. Enter: `_Measures = {1}`
4. This creates a blank table to organize measures

### 3.2 Add Key Measures

**Copy from `dax_measures.txt` file - here are the essential ones to start:**

1. **Revenue Metrics:**
```DAX
Total Revenue = SUM(fact_sales[revenue])

Total Profit = SUM(fact_sales[profit])

Profit Margin % = DIVIDE([Total Profit], [Total Revenue], 0) * 100

Average Order Value = AVERAGE(fact_sales[revenue])
```

2. **Time Intelligence:**
```DAX
Previous Year Revenue = 
CALCULATE(
    [Total Revenue],
    DATEADD(dim_date[date], -1, YEAR)
)

YoY Revenue Growth % = 
DIVIDE(
    [Total Revenue] - [Previous Year Revenue],
    [Previous Year Revenue],
    0
) * 100

YTD Revenue = TOTALYTD([Total Revenue], dim_date[date])
```

3. **Customer Metrics:**
```DAX
Unique Customers = DISTINCTCOUNT(fact_sales[customer_id])

Repeat Customer Rate % = 
DIVIDE(
    CALCULATE(
        DISTINCTCOUNT(fact_sales[customer_id]),
        FILTER(
            VALUES(fact_sales[customer_id]),
            CALCULATE(COUNTROWS(fact_sales)) > 1
        )
    ),
    [Unique Customers],
    0
) * 100

Customer Lifetime Value = 
CALCULATE(
    SUM(fact_sales[revenue]),
    ALLEXCEPT(fact_sales, fact_sales[customer_id])
)
```

4. **RFM Segmentation:**
```DAX
Recency Days = 
VAR MaxDateInData = MAX(dim_date[date])
VAR LastPurchaseDate = 
    CALCULATE(
        MAX(fact_sales[transaction_date]),
        ALLEXCEPT(fact_sales, fact_sales[customer_id])
    )
RETURN DATEDIFF(LastPurchaseDate, MaxDateInData, DAY)

Frequency = 
CALCULATE(
    COUNTROWS(fact_sales),
    ALLEXCEPT(fact_sales, fact_sales[customer_id])
)

Monetary = 
CALCULATE(
    SUM(fact_sales[revenue]),
    ALLEXCEPT(fact_sales, fact_sales[customer_id])
)
```

> 📝 **Tip:** Copy all measures from `dax_measures.txt` into your `_Measures` table for the complete set.

---

## 🎨 PART 4: Build Dashboard Pages

### Page 1: Executive Summary

**Create the following visuals:**

1. **KPI Cards (Top Row)**
   - Total Revenue (large number, with YoY %)
   - Total Profit (with profit margin %)
   - Unique Customers (with growth %)
   - Average Order Value

2. **Revenue Trend Line Chart**
   - X-axis: `dim_date[month_name]` + `dim_date[year]`
   - Y-axis: `Total Revenue`, `Previous Year Revenue`
   - Legend: Show both current and previous year

3. **Category Performance Bar Chart**
   - X-axis: `dim_product[category]`
   - Y-axis: `Total Revenue`
   - Data labels: On
   - Sort: Descending by revenue

4. **Regional Map**
   - Location: `dim_store[state]` or `dim_store[city]`
   - Size: `Total Revenue`
   - Color: `Profit Margin %`

5. **Monthly Revenue & Profit Combo Chart**
   - X-axis: `dim_date[year]` and `dim_date[month]`
   - Column: `Total Revenue`
   - Line: `Total Profit`

### Page 2: Sales Deep Dive

1. **Revenue by Store (Table/Matrix)**
   - Rows: `dim_store[store_name]`, `dim_store[region]`
   - Values: `Total Revenue`, `Total Profit`, `Profit Margin %`, `Total Transactions`

2. **Product Performance Matrix**
   - Rows: `dim_product[category]`, `dim_product[product_name]`
   - Values: `Total Revenue`, `Profit Margin %`
   - Conditional formatting on profit margin

3. **Day of Week Analysis (Column Chart)**
   - X-axis: `dim_date[day_name]`
   - Y-axis: `Total Revenue`

4. **Payment Method Distribution (Donut Chart)**
   - Legend: `fact_sales[payment_method]`
   - Values: `Total Transactions`

### Page 3: Customer Analytics

1. **Customer Segment Analysis (Clustered Bar)**
   - Y-axis: `dim_customer[customer_segment]`
   - X-axis: `Total Revenue`, `Unique Customers`

2. **RFM Segmentation Matrix**
   - Create calculated table for RFM segments
   - Show count and revenue by RFM segment

3. **Customer Lifetime Value Distribution (Histogram)**
   - X-axis: Customer bins by CLV
   - Y-axis: Count of customers

4. **Repeat Purchase Rate Card**
   - Show `Repeat Customer Rate %`
   - With trend sparkline

5. **Cohort Retention Heatmap**
   - Rows: Cohort Month
   - Columns: Months since first purchase
   - Values: Retention %
   - Conditional formatting: Color gradient

### Page 4: Time Intelligence & Trends

1. **YoY Comparison Cards**
   - `YoY Revenue Growth %`
   - `YoY Profit Growth %`
   - With trend indicators

2. **YTD vs Previous YTD (Area Chart)**
   - X-axis: Month
   - Y-axis: `YTD Revenue`, `Previous Year YTD Revenue`

3. **Quarterly Performance (Column Chart)**
   - X-axis: Quarter
   - Y-axis: Revenue, Profit
   - Group by year

4. **Seasonal Analysis (Line Chart)**
   - Show seasonal patterns across years

---

## 🎨 PART 5: Dashboard Design & Formatting

### Visual Theme

1. **Apply Theme:**
   - View → Themes → Choose a professional theme
   - Recommended: "Executive" or "Innovate"

2. **Consistent Colors:**
   - Revenue: Blue (#1F77B4)
   - Profit: Green (#2CA02C)
   - Costs: Red (#D62728)
   - YoY Growth: Orange (#FF7F0E)

### Formatting Best Practices

1. **KPI Cards:**
   - Large font for numbers (48pt+)
   - Category label above number
   - Background: Subtle card background
   - Add sparklines for trends

2. **Charts:**
   - Remove gridlines for cleaner look
   - Add data labels on key metrics
   - Use tooltips for detailed info
   - Title font: 14-16pt bold

3. **Slicers (Filters):**
   - Add to left sidebar or top:
     - Date Range (slider)
     - Region (dropdown)
     - Category (dropdown)
     - Store (dropdown)
   - Style: Vertical list or tile

4. **Headers:**
   - Add page title at top
   - Use text boxes for section headers
   - Company logo placeholder

---

## 🔧 PART 6: Advanced Features

### 6.1 Drill-Through Pages

1. **Create Product Detail Page:**
   - Right-click page → "Drill through"
   - Add `product_id` to drill-through filters
   - Show detailed product metrics

2. **Create Customer Detail Page:**
   - Drill-through by `customer_id`
   - Show customer purchase history
   - RFM scores and segment

### 6.2 Bookmarks & Navigation

1. **Create Bookmarks:**
   - View → Bookmarks pane
   - Create bookmarks for different views:
     - "Revenue View"
     - "Profit View"
     - "Customer View"

2. **Add Buttons:**
   - Insert → Buttons → Navigation buttons
   - Link to pages or bookmarks

### 6.3 Tooltips

1. **Create Tooltip Page:**
   - New page → Set as tooltip page
   - Add detailed metrics
   - Apply to charts for rich hover experience

---

## 📊 PART 7: Performance Optimization

1. **Reduce Visual Count:**
   - Max 8-10 visuals per page
   - Use drill-through for details

2. **Optimize DAX:**
   - Use variables in measures
   - Avoid calculated columns where possible

3. **Data Refresh:**
   - Set up scheduled refresh if using MySQL
   - Configure incremental refresh for large datasets

---

## 📤 PART 8: Publishing & Sharing

### Save Locally

1. File → Save As
2. Name: `Financial_Sales_Analytics_Dashboard.pbix`

### Publish to Power BI Service (Optional)

1. Click "Publish" button
2. Sign in to Power BI account
3. Select workspace
4. Share with stakeholders

---

## 🎯 Key Dashboard Elements Checklist

- [ ] All data tables imported and related
- [ ] Date table marked as date table
- [ ] Key measures created (Revenue, Profit, YoY, etc.)
- [ ] RFM segmentation measures added
- [ ] Executive Summary page complete
- [ ] Sales Deep Dive page complete
- [ ] Customer Analytics page complete
- [ ] Time Intelligence page complete
- [ ] Slicers/filters added
- [ ] Professional theme applied
- [ ] Visual consistency across pages
- [ ] Drill-through pages configured
- [ ] Tooltips added
- [ ] Saved and ready to publish

---

## 📝 Sample Visualizations Reference

### Recommended Visual Types:

| Metric | Best Visual Type |
|--------|-----------------|
| Total Revenue, Profit | KPI Card |
| Revenue Trend | Line Chart |
| Category Performance | Bar Chart |
| Regional Performance | Map or Bar Chart |
| Product Mix | Donut/Pie Chart |
| YoY Comparison | Clustered Column Chart |
| Customer Distribution | Histogram |
| RFM Segments | Matrix with Heatmap |
| Cohort Retention | Matrix with Conditional Formatting |
| Time Series | Area Chart or Line Chart |

---

## 🚀 Quick Start Summary

1. ✅ Import data (MySQL or CSV)
2. ✅ Create relationships (star schema)
3. ✅ Add DAX measures (copy from dax_measures.txt)
4. ✅ Build 4 main pages (Executive, Sales, Customer, Time)
5. ✅ Apply formatting and theme
6. ✅ Add slicers and interactivity
7. ✅ Test and publish

---

## 💡 Tips for Success

- Start with Executive Summary page - it's your MVP
- Test each measure before building visuals
- Use consistent formatting across all pages
- Add tooltips for context
- Enable drill-through for deep dives
- Keep it simple - don't overcrowd pages
- Test performance with all filters applied

---

## 📚 Additional Resources

- [Power BI Documentation](https://docs.microsoft.com/power-bi/)
- [DAX Guide](https://dax.guide/)
- [Power BI Community](https://community.powerbi.com/)

---

**🎉 You're ready to build your Financial & Sales Analytics Dashboard!**

For questions or issues, refer to the main README.md or consult the SQL query files for data validation.
