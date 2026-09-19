@echo off
echo ============================================================
echo  Git Setup for Financial Sales Dashboard
echo ============================================================
echo.

cd /d "D:\task\Financial-Sales-Dashboard"

echo [1/5] Checking Git status...
git status
echo.

echo [2/5] Adding all files...
git add .
echo.

echo [3/5] Creating initial commit...
git commit -m "Initial commit: Financial & Sales Analytics Dashboard

- 55,000+ transaction dataset with star schema
- 23 advanced SQL queries (CTEs, window functions, joins)
- 70+ Power BI DAX measures (YoY growth, RFM segmentation)
- Interactive HTML dashboards with animations
- Complete documentation and setup guides
- Portfolio-ready business intelligence solution

Co-Authored-By: Claude Code <noreply@anthropic.com>"
echo.

echo [4/5] Setting up remote...
git branch -M main
git remote add origin https://github.com/HarshB227/Financial-Sales-Dashboard.git
echo.

echo [5/5] Ready to push!
echo.
echo ============================================================
echo  SETUP COMPLETE!
echo ============================================================
echo.
echo  Next steps:
echo  1. Make sure you created the repo on GitHub
echo  2. Run: git push -u origin main
echo.
echo  Or just run:
echo  git push -u origin main
echo.
pause
