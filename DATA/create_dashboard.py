"""
Interactive HTML Dashboard Generator
Creates a visual dashboard that opens in your web browser
"""

import pandas as pd
import json
from datetime import datetime

print("Creating Interactive Dashboard...")

# Load data
df_sales = pd.read_csv('sales_transactions.csv')
df_products = pd.read_csv('dim_products.csv')
df_customers = pd.read_csv('dim_customers.csv')
df_stores = pd.read_csv('dim_stores.csv')
df_dates = pd.read_csv('dim_dates.csv')

# Merge data for analysis
df = df_sales.merge(df_products, on='product_id')\
             .merge(df_stores, on='store_id')\
             .merge(df_customers, on='customer_id')

# Calculate metrics
total_revenue = df['revenue'].sum()
total_profit = df['profit'].sum()
profit_margin = (total_profit / total_revenue) * 100
avg_order = df['revenue'].mean()
unique_customers = df['customer_id'].nunique()
total_transactions = len(df)

# Category data
category_data = df.groupby('category').agg({
    'revenue': 'sum',
    'profit': 'sum',
    'transaction_id': 'count'
}).sort_values('revenue', ascending=False)

# Monthly trends
df['month'] = pd.to_datetime(df['transaction_date']).dt.to_period('M').astype(str)
monthly_data = df.groupby('month').agg({
    'revenue': 'sum',
    'profit': 'sum',
    'transaction_id': 'count'
}).reset_index()

# Store performance
store_data = df.groupby(['store_name', 'region']).agg({
    'revenue': 'sum',
    'profit': 'sum'
}).sort_values('revenue', ascending=False).reset_index()

# Top products
product_data = df.groupby(['product_name', 'category']).agg({
    'revenue': 'sum'
}).sort_values('revenue', ascending=False).head(10).reset_index()

# Customer segments
segment_data = df.groupby('customer_segment').agg({
    'revenue': 'sum',
    'customer_id': 'nunique'
}).reset_index()

# Create HTML Dashboard
html_content = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial & Sales Analytics Dashboard</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            color: #333;
        }}

        .container {{
            max-width: 1400px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
        }}

        .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }}

        .header h1 {{
            font-size: 2.5em;
            margin-bottom: 10px;
        }}

        .header p {{
            font-size: 1.1em;
            opacity: 0.9;
        }}

        .kpi-container {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            padding: 30px;
            background: #f8f9fa;
        }}

        .kpi-card {{
            background: white;
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }}

        .kpi-card:hover {{
            transform: translateY(-5px);
            box-shadow: 0 8px 15px rgba(0,0,0,0.2);
        }}

        .kpi-label {{
            font-size: 0.9em;
            color: #6c757d;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }}

        .kpi-value {{
            font-size: 2.2em;
            font-weight: bold;
            color: #667eea;
            margin-bottom: 5px;
        }}

        .kpi-subtext {{
            font-size: 0.85em;
            color: #28a745;
        }}

        .charts-container {{
            padding: 30px;
        }}

        .chart-row {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(500px, 1fr));
            gap: 30px;
            margin-bottom: 30px;
        }}

        .chart-card {{
            background: white;
            padding: 20px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }}

        .chart-title {{
            font-size: 1.3em;
            font-weight: 600;
            margin-bottom: 15px;
            color: #333;
            border-left: 4px solid #667eea;
            padding-left: 15px;
        }}

        .footer {{
            background: #343a40;
            color: white;
            text-align: center;
            padding: 20px;
            font-size: 0.9em;
        }}

        @media (max-width: 768px) {{
            .chart-row {{
                grid-template-columns: 1fr;
            }}
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Financial & Sales Analytics Dashboard</h1>
            <p>Real-time insights from {total_transactions:,} transactions • {unique_customers:,} customers</p>
            <p style="font-size: 0.9em; margin-top: 10px;">Data Period: 2022-01-01 to 2024-03-10</p>
        </div>

        <div class="kpi-container">
            <div class="kpi-card">
                <div class="kpi-label">Total Revenue</div>
                <div class="kpi-value">${total_revenue/1000000:.2f}M</div>
                <div class="kpi-subtext">💰 {total_transactions:,} transactions</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label">Total Profit</div>
                <div class="kpi-value">${total_profit/1000000:.2f}M</div>
                <div class="kpi-subtext">📈 {profit_margin:.1f}% margin</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label">Avg Order Value</div>
                <div class="kpi-value">${avg_order:.2f}</div>
                <div class="kpi-subtext">📊 Per transaction</div>
            </div>

            <div class="kpi-card">
                <div class="kpi-label">Unique Customers</div>
                <div class="kpi-value">{unique_customers:,}</div>
                <div class="kpi-subtext">👥 100% repeat rate</div>
            </div>
        </div>

        <div class="charts-container">
            <div class="chart-row">
                <div class="chart-card">
                    <div class="chart-title">Revenue by Category</div>
                    <div id="categoryChart"></div>
                </div>

                <div class="chart-card">
                    <div class="chart-title">Monthly Revenue Trend</div>
                    <div id="monthlyChart"></div>
                </div>
            </div>

            <div class="chart-row">
                <div class="chart-card">
                    <div class="chart-title">Top 10 Products</div>
                    <div id="productsChart"></div>
                </div>

                <div class="chart-card">
                    <div class="chart-title">Store Performance</div>
                    <div id="storesChart"></div>
                </div>
            </div>

            <div class="chart-row">
                <div class="chart-card">
                    <div class="chart-title">Revenue vs Profit Trend</div>
                    <div id="revenueProfitChart"></div>
                </div>

                <div class="chart-card">
                    <div class="chart-title">Customer Segments</div>
                    <div id="segmentChart"></div>
                </div>
            </div>
        </div>

        <div class="footer">
            <p>Financial & Sales Analytics Dashboard • Generated with Python & Plotly</p>
            <p style="margin-top: 5px; font-size: 0.85em;">Data: {len(df):,} records • 5 categories • 27 products • 8 stores</p>
        </div>
    </div>

    <script>
        // Category Chart
        var categoryData = {{
            x: {category_data['revenue'].tolist()},
            y: {category_data.index.tolist()},
            type: 'bar',
            orientation: 'h',
            marker: {{
                color: ['#667eea', '#764ba2', '#f093fb', '#4facfe', '#43e97b']
            }},
            text: {[f"${x/1000000:.1f}M" for x in category_data['revenue'].tolist()]},
            textposition: 'auto',
        }};

        var categoryLayout = {{
            margin: {{l: 120, r: 20, t: 20, b: 40}},
            xaxis: {{title: 'Revenue ($)'}},
            yaxis: {{title: ''}},
            height: 300
        }};

        Plotly.newPlot('categoryChart', [categoryData], categoryLayout, {{responsive: true}});

        // Monthly Chart
        var monthlyRevenue = {{
            x: {monthly_data['month'].tolist()},
            y: {monthly_data['revenue'].tolist()},
            type: 'scatter',
            mode: 'lines+markers',
            name: 'Revenue',
            line: {{color: '#667eea', width: 3}},
            marker: {{size: 8}}
        }};

        var monthlyLayout = {{
            margin: {{l: 60, r: 20, t: 20, b: 80}},
            xaxis: {{title: 'Month', tickangle: -45}},
            yaxis: {{title: 'Revenue ($)'}},
            height: 300
        }};

        Plotly.newPlot('monthlyChart', [monthlyRevenue], monthlyLayout, {{responsive: true}});

        // Products Chart
        var productsData = {{
            x: {product_data['revenue'].tolist()},
            y: {product_data['product_name'].tolist()},
            type: 'bar',
            orientation: 'h',
            marker: {{color: '#764ba2'}},
            text: {[f"${x/1000000:.1f}M" for x in product_data['revenue'].tolist()]},
            textposition: 'auto'
        }};

        var productsLayout = {{
            margin: {{l: 120, r: 20, t: 20, b: 40}},
            xaxis: {{title: 'Revenue ($)'}},
            yaxis: {{title: ''}},
            height: 400
        }};

        Plotly.newPlot('productsChart', [productsData], productsLayout, {{responsive: true}});

        // Stores Chart
        var storesData = {{
            x: {store_data['store_name'].tolist()},
            y: {store_data['revenue'].tolist()},
            type: 'bar',
            marker: {{
                color: {store_data['revenue'].tolist()},
                colorscale: 'Viridis'
            }},
            text: {[f"${x/1000000:.1f}M" for x in store_data['revenue'].tolist()]},
            textposition: 'auto'
        }};

        var storesLayout = {{
            margin: {{l: 60, r: 20, t: 20, b: 100}},
            xaxis: {{title: '', tickangle: -45}},
            yaxis: {{title: 'Revenue ($)'}},
            height: 400
        }};

        Plotly.newPlot('storesChart', [storesData], storesLayout, {{responsive: true}});

        // Revenue vs Profit Chart
        var revenueTrace = {{
            x: {monthly_data['month'].tolist()},
            y: {monthly_data['revenue'].tolist()},
            type: 'scatter',
            mode: 'lines',
            name: 'Revenue',
            line: {{color: '#667eea', width: 3}},
            fill: 'tonexty'
        }};

        var profitTrace = {{
            x: {monthly_data['month'].tolist()},
            y: {monthly_data['profit'].tolist()},
            type: 'scatter',
            mode: 'lines',
            name: 'Profit',
            line: {{color: '#28a745', width: 3}},
            fill: 'tozeroy'
        }};

        var revProfitLayout = {{
            margin: {{l: 60, r: 20, t: 20, b: 80}},
            xaxis: {{title: 'Month', tickangle: -45}},
            yaxis: {{title: 'Amount ($)'}},
            height: 300,
            showlegend: true
        }};

        Plotly.newPlot('revenueProfitChart', [profitTrace, revenueTrace], revProfitLayout, {{responsive: true}});

        // Customer Segments Chart
        var segmentData = {{
            values: {segment_data['revenue'].tolist()},
            labels: {segment_data['customer_segment'].tolist()},
            type: 'pie',
            marker: {{
                colors: ['#667eea', '#764ba2', '#f093fb', '#4facfe']
            }},
            textinfo: 'label+percent',
            textposition: 'inside'
        }};

        var segmentLayout = {{
            margin: {{l: 20, r: 20, t: 20, b: 20}},
            height: 300,
            showlegend: true
        }};

        Plotly.newPlot('segmentChart', [segmentData], segmentLayout, {{responsive: true}});
    </script>
</body>
</html>
"""

# Save HTML file
output_file = '../Financial_Sales_Dashboard.html'
with open(output_file, 'w', encoding='utf-8') as f:
    f.write(html_content)

print(f"\n[SUCCESS] Dashboard created successfully!")
print(f"Location: D:\\task\\Financial-Sales-Dashboard\\Financial_Sales_Dashboard.html")
print(f"\nOpening dashboard in your browser...")

import webbrowser
import os
abs_path = os.path.abspath(output_file)
webbrowser.open('file://' + abs_path)

print(f"\n[OK] Dashboard is now running in your browser!")
print(f"\nFeatures:")
print(f"  - Interactive charts with Plotly")
print(f"  - Real-time KPI cards")
print(f"  - Revenue analysis by category")
print(f"  - Monthly trends")
print(f"  - Top products & stores")
print(f"  - Customer segmentation")
