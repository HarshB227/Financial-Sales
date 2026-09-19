"""
Financial & Sales Analytics - Sample Data Generator
Generates 50,000+ realistic retail sales transactions for analytics dashboard
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

# Set seed for reproducibility
np.random.seed(42)
random.seed(42)

# Configuration
NUM_TRANSACTIONS = 55000  # 50,000+ transactions
START_DATE = datetime(2022, 1, 1)
END_DATE = datetime(2024, 8, 31)

print("Generating Financial & Sales Analytics Dataset...")
print(f"Target: {NUM_TRANSACTIONS:,} transactions")

# 1. GENERATE DIMENSION DATA
# ===========================

# Product Categories and Products
categories = {
    'Electronics': ['Laptop', 'Smartphone', 'Tablet', 'Headphones', 'Smart Watch', 'Camera'],
    'Clothing': ['T-Shirt', 'Jeans', 'Jacket', 'Dress', 'Shoes', 'Accessories'],
    'Home & Garden': ['Furniture', 'Kitchenware', 'Bedding', 'Decor', 'Garden Tools'],
    'Sports': ['Running Shoes', 'Yoga Mat', 'Dumbbells', 'Bicycle', 'Sports Apparel'],
    'Books': ['Fiction', 'Non-Fiction', 'Educational', 'Comics', 'Magazines']
}

# Product master list with pricing
products_list = []
product_id = 1

for category, items in categories.items():
    for item in items:
        if category == 'Electronics':
            base_price = random.uniform(150, 1500)
            cost_price = base_price * random.uniform(0.55, 0.65)
        elif category == 'Clothing':
            base_price = random.uniform(20, 200)
            cost_price = base_price * random.uniform(0.40, 0.50)
        elif category == 'Home & Garden':
            base_price = random.uniform(30, 500)
            cost_price = base_price * random.uniform(0.50, 0.60)
        elif category == 'Sports':
            base_price = random.uniform(25, 400)
            cost_price = base_price * random.uniform(0.45, 0.55)
        else:  # Books
            base_price = random.uniform(10, 50)
            cost_price = base_price * random.uniform(0.50, 0.60)

        products_list.append({
            'product_id': product_id,
            'product_name': item,
            'category': category,
            'base_price': round(base_price, 2),
            'cost_price': round(cost_price, 2)
        })
        product_id += 1

# Customer data (2000 unique customers)
NUM_CUSTOMERS = 2000
customers_list = []

for i in range(1, NUM_CUSTOMERS + 1):
    # Customer segments with different behaviors
    segment = random.choices(
        ['Premium', 'Regular', 'Occasional', 'New'],
        weights=[10, 35, 40, 15]
    )[0]

    customers_list.append({
        'customer_id': i,
        'customer_segment': segment,
        'registration_date': START_DATE + timedelta(days=random.randint(0, 730))
    })

# Store locations
stores_list = [
    {'store_id': 1, 'store_name': 'New York Flagship', 'city': 'New York', 'state': 'NY', 'region': 'Northeast'},
    {'store_id': 2, 'store_name': 'Los Angeles Central', 'city': 'Los Angeles', 'state': 'CA', 'region': 'West'},
    {'store_id': 3, 'store_name': 'Chicago Downtown', 'city': 'Chicago', 'state': 'IL', 'region': 'Midwest'},
    {'store_id': 4, 'store_name': 'Houston Mall', 'city': 'Houston', 'state': 'TX', 'region': 'South'},
    {'store_id': 5, 'store_name': 'Miami Beach', 'city': 'Miami', 'state': 'FL', 'region': 'South'},
    {'store_id': 6, 'store_name': 'Seattle Tech Hub', 'city': 'Seattle', 'state': 'WA', 'region': 'West'},
    {'store_id': 7, 'store_name': 'Boston Historic', 'city': 'Boston', 'state': 'MA', 'region': 'Northeast'},
    {'store_id': 8, 'store_name': 'Dallas Metroplex', 'city': 'Dallas', 'state': 'TX', 'region': 'South'},
]

print(f"[OK] Created {len(products_list)} products across {len(categories)} categories")
print(f"[OK] Created {len(customers_list):,} customers")
print(f"[OK] Created {len(stores_list)} stores")

# 2. GENERATE FACT TABLE (TRANSACTIONS)
# ======================================

transactions = []
transaction_id = 1

# Generate dates with realistic distribution
total_days = (END_DATE - START_DATE).days
dates = pd.date_range(start=START_DATE, end=END_DATE, freq='D')

for date in dates:
    # Seasonal patterns
    month = date.month
    day_of_week = date.weekday()  # 0=Monday, 6=Sunday

    # More sales in Nov-Dec (holiday season) and back-to-school (Aug-Sep)
    if month in [11, 12]:
        daily_transaction_count = random.randint(70, 120)
    elif month in [8, 9]:
        daily_transaction_count = random.randint(55, 85)
    else:
        daily_transaction_count = random.randint(40, 70)

    # Weekend boost
    if day_of_week in [5, 6]:  # Saturday, Sunday
        daily_transaction_count = int(daily_transaction_count * 1.3)

    for _ in range(daily_transaction_count):
        # Select customer with realistic repeat behavior
        # Premium customers shop more frequently
        customer = random.choice(customers_list)
        if customer['customer_segment'] == 'Premium':
            # Premium customers more likely to be selected
            if random.random() < 0.7:
                customer = random.choice([c for c in customers_list if c['customer_segment'] == 'Premium'])

        # Select product
        product = random.choice(products_list)

        # Quantity (most orders are 1-2 items)
        quantity = random.choices([1, 2, 3, 4, 5], weights=[60, 25, 10, 3, 2])[0]

        # Price with occasional discounts
        discount_pct = random.choices([0, 0.05, 0.10, 0.15, 0.20, 0.25],
                                     weights=[50, 20, 15, 10, 4, 1])[0]

        unit_price = product['base_price'] * (1 - discount_pct)
        revenue = unit_price * quantity
        cost = product['cost_price'] * quantity
        profit = revenue - cost

        # Store selection
        store = random.choice(stores_list)

        # Payment method
        payment_method = random.choices(
            ['Credit Card', 'Debit Card', 'Cash', 'Digital Wallet'],
            weights=[45, 30, 15, 10]
        )[0]

        transactions.append({
            'transaction_id': transaction_id,
            'transaction_date': date.strftime('%Y-%m-%d'),
            'customer_id': customer['customer_id'],
            'product_id': product['product_id'],
            'store_id': store['store_id'],
            'quantity': quantity,
            'unit_price': round(unit_price, 2),
            'discount_percent': round(discount_pct * 100, 2),
            'revenue': round(revenue, 2),
            'cost': round(cost, 2),
            'profit': round(profit, 2),
            'payment_method': payment_method
        })

        transaction_id += 1

        if transaction_id > NUM_TRANSACTIONS:
            break

    if transaction_id > NUM_TRANSACTIONS:
        break

print(f"[OK] Generated {len(transactions):,} transactions")

# 3. CREATE DATAFRAMES AND SAVE TO CSV
# =====================================

# Fact table
df_transactions = pd.DataFrame(transactions)

# Dimension tables
df_products = pd.DataFrame(products_list)
df_customers = pd.DataFrame(customers_list)
df_customers['registration_date'] = df_customers['registration_date'].dt.strftime('%Y-%m-%d')
df_stores = pd.DataFrame(stores_list)

# Date dimension (for time intelligence)
df_dates = pd.DataFrame({'date': pd.date_range(start=START_DATE, end=END_DATE, freq='D')})
df_dates['year'] = df_dates['date'].dt.year
df_dates['quarter'] = df_dates['date'].dt.quarter
df_dates['month'] = df_dates['date'].dt.month
df_dates['month_name'] = df_dates['date'].dt.strftime('%B')
df_dates['day'] = df_dates['date'].dt.day
df_dates['day_of_week'] = df_dates['date'].dt.dayofweek + 1  # 1=Monday, 7=Sunday
df_dates['day_name'] = df_dates['date'].dt.strftime('%A')
df_dates['week_of_year'] = df_dates['date'].dt.isocalendar().week
df_dates['is_weekend'] = df_dates['day_of_week'].isin([6, 7]).astype(int)
df_dates['date'] = df_dates['date'].dt.strftime('%Y-%m-%d')

# Save all files
print("\nSaving CSV files...")

df_transactions.to_csv('sales_transactions.csv', index=False)
df_products.to_csv('dim_products.csv', index=False)
df_customers.to_csv('dim_customers.csv', index=False)
df_stores.to_csv('dim_stores.csv', index=False)
df_dates.to_csv('dim_dates.csv', index=False)

# 4. GENERATE SUMMARY STATISTICS
# ===============================

print("\n" + "="*60)
print("DATASET SUMMARY STATISTICS")
print("="*60)

print(f"\nFiles Generated:")
print(f"   • sales_transactions.csv ({len(df_transactions):,} rows)")
print(f"   • dim_products.csv ({len(df_products)} rows)")
print(f"   • dim_customers.csv ({len(df_customers):,} rows)")
print(f"   • dim_stores.csv ({len(df_stores)} rows)")
print(f"   • dim_dates.csv ({len(df_dates):,} rows)")

print(f"\nFinancial Summary:")
print(f"   • Total Revenue: ${df_transactions['revenue'].sum():,.2f}")
print(f"   • Total Profit: ${df_transactions['profit'].sum():,.2f}")
print(f"   • Average Order Value: ${df_transactions['revenue'].mean():.2f}")
print(f"   • Profit Margin: {(df_transactions['profit'].sum() / df_transactions['revenue'].sum() * 100):.2f}%")

print(f"\nTime Period:")
print(f"   • Start Date: {df_transactions['transaction_date'].min()}")
print(f"   • End Date: {df_transactions['transaction_date'].max()}")
print(f"   • Total Days: {len(df_dates):,}")

print(f"\nTop 5 Categories by Revenue:")
revenue_by_category = df_transactions.merge(df_products, on='product_id').groupby('category')['revenue'].sum().sort_values(ascending=False)
for idx, (category, revenue) in enumerate(revenue_by_category.head(5).items(), 1):
    print(f"   {idx}. {category}: ${revenue:,.2f}")

print(f"\nCustomer Insights:")
print(f"   • Total Customers: {df_customers['customer_id'].nunique():,}")
print(f"   • Active Customers (made purchase): {df_transactions['customer_id'].nunique():,}")
print(f"   • Avg Transactions per Customer: {len(df_transactions) / df_transactions['customer_id'].nunique():.1f}")

print("\n" + "="*60)
print("[SUCCESS] Data generation complete! Ready for MySQL import.")
print("="*60)
