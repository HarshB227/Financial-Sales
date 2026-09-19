@echo off
echo ============================================================
echo  Financial & Sales Analytics Dashboard - LAUNCHER
echo ============================================================
echo.
echo  Starting your interactive dashboard...
echo.

REM Open the HTML dashboard
start "" "D:\task\Financial-Sales-Dashboard\Financial_Sales_Dashboard.html"

echo  [OK] Dashboard opened in your browser!
echo.
echo  Opening reports...
echo.

REM Open the executive report
start notepad "D:\task\Financial-Sales-Dashboard\Executive_Summary_Report.txt"

echo  [OK] Executive report opened!
echo.
echo  Opening data folder...
echo.

REM Open the data folder
start explorer "D:\task\Financial-Sales-Dashboard\data"

echo  [OK] Data folder opened!
echo.
echo ============================================================
echo  ALL COMPONENTS LAUNCHED!
echo ============================================================
echo.
echo  What's now open:
echo  1. Interactive Dashboard (Browser)
echo  2. Executive Summary Report (Notepad)
echo  3. Data Files Folder (Explorer)
echo.
echo  Press any key to exit this window...
pause >nul
