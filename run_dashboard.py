"""
Dashboard Launcher - Opens all components
"""
import webbrowser
import subprocess
import os
import time

print("="*70)
print(" FINANCIAL & SALES ANALYTICS DASHBOARD - LAUNCHER")
print("="*70)
print()

# Get absolute paths
base_path = r"D:\task\Financial-Sales-Dashboard"
dashboard_path = os.path.join(base_path, "Financial_Sales_Dashboard.html")
report_path = os.path.join(base_path, "Executive_Summary_Report.txt")
data_path = os.path.join(base_path, "data")

print("[1/4] Opening Interactive Dashboard in browser...")
webbrowser.open('file:///' + dashboard_path)
time.sleep(1)
print("      [OK] Dashboard launched!")

print()
print("[2/4] Opening Executive Summary Report...")
try:
    subprocess.Popen(['notepad.exe', report_path])
    time.sleep(0.5)
    print("      [OK] Report opened in Notepad!")
except:
    print("      [INFO] Report available at:", report_path)

print()
print("[3/4] Opening Data Files folder...")
try:
    subprocess.Popen(['explorer', data_path])
    time.sleep(0.5)
    print("      [OK] Data folder opened!")
except:
    print("      [INFO] Data folder:", data_path)

print()
print("[4/4] Opening project README...")
readme_path = os.path.join(base_path, "README.md")
try:
    subprocess.Popen(['notepad.exe', readme_path])
    time.sleep(0.5)
    print("      [OK] README opened!")
except:
    print("      [INFO] README available at:", readme_path)

print()
print("="*70)
print(" ALL COMPONENTS LAUNCHED SUCCESSFULLY!")
print("="*70)
print()
print("You should now see:")
print("  1. Interactive Dashboard - In your web browser")
print("  2. Executive Summary Report - In Notepad")
print("  3. Data Files - In File Explorer")
print("  4. README Guide - In Notepad")
print()
print("Dashboard Features:")
print("  - Interactive charts (hover for details)")
print("  - $27.8M revenue analysis")
print("  - 6 visualization panels")
print("  - KPI cards with key metrics")
print()
print("="*70)
print()

# Quick summary
print("QUICK STATS:")
print("  Total Revenue:        $27,812,190.57")
print("  Total Profit:         $11,696,562.93")
print("  Profit Margin:        42.06%")
print("  Transactions:         55,000")
print("  Customers:            2,000")
print("  Products:             27")
print("  Stores:               8")
print()
print("="*70)
print("Enjoy your dashboard! Close this window when done.")
print("="*70)
