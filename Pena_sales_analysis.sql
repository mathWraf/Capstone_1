-- Colorado sales territory.
USE sample_sales;

-- 4.1) Find total revenue
WITH S_Totals AS (
SELECT SUM(ss.Sale_Amount) AS store_revenue, MIN(ss.Transaction_Date) AS S_Start_Date, MAX(ss.Transaction_Date) AS S_End_Date
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"),

O_Totals AS (
SELECT SUM(SalesTotal) online_revenue, MIN(Date) AS O_Start_Date, MAX(Date) AS O_End_Date
FROM Online_Sales
WHERE ShiptoState = "Colorado"
)

SELECT st.S_Start_Date, st.S_End_Date, ot.O_Start_Date, ot.O_End_Date, st.store_revenue + ot.online_revenue AS total_revenue
FROM S_Totals AS st
JOIN O_Totals AS ot;

SELECT Date, SalesTotal FROM Online_Sales WHERE ShiptoState = "Colorado";

-- 4.2) Revenue breakdown by year and month
WITH Store_Totals AS (
SELECT DATE_FORMAT(ss.Transaction_Date, "%m/%Y") AS StoreDate, SUM(ss.Sale_Amount) AS store_amount
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY StoreDate),

Online_Totals AS (
SELECT DATE_FORMAT(os.Date, "%m/%Y") AS OnlineDate, SUM(os.SalesTotal) AS online_amount
FROM Online_Sales os
WHERE os.ShiptoState = "Colorado"
GROUP BY OnlineDate)

SELECT st.StoreDate, st.store_amount + COALESCE(ot.online_amount, 0) AS Monthly_Totals
FROM Store_Totals st
LEFT JOIN Online_Totals ot
ON st.StoreDate = ot.OnlineDate;

-- 4.3) Comparison of total revenue
WITH S_Amount AS (
SELECT SUM(ss.Sale_Amount) AS store_revenue
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"),

O_Amount AS (
SELECT SUM(SalesTotal) online_revenue
FROM Online_Sales
WHERE ShiptoState = "Colorado"
)

SELECT CONCAT(CAST(ROUND(SUM(sa.store_revenue)/(SUM(sa.store_revenue) + SUM(oa.online_revenue)) * 100, 2) AS CHAR), "%") AS store_contribution, 
CONCAT(CAST(ROUND(SUM(oa.online_revenue)/(SUM(sa.store_revenue) + SUM(oa.online_revenue)) * 100, 2) AS CHAR), "%") AS online_contribution
FROM S_Amount sa
JOIN O_Amount oa;

SELECT * FROM Management /*WHERE Region = "West"*/;


-- 4.4a) Find number of transactions per month
WITH S_Total_Transactions AS (
SELECT DATE_FORMAT(ss.Transaction_Date, "%m/%Y") AS StoreDate, COUNT(DATE_FORMAT(ss.Transaction_Date, "%m/%d/%Y")) AS store_transactions
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY StoreDate),

O_Total_Transactions AS (
SELECT DATE_FORMAT(Date, "%m/%Y") AS OnlineDate, COUNT(DATE_FORMAT(Date, "%m/%d/%Y")) AS online_transactions
FROM Online_Sales
WHERE ShiptoState = "Colorado"
GROUP BY OnlineDate)

SELECT s.StoreDate, s.store_transactions + COALESCE(o.online_transactions, 0) AS monthly_transactions 
FROM S_Total_Transactions s
LEFT JOIN O_Total_Transactions o
ON s.StoreDate = o.OnlineDate;

-- 4.4b) Average transaction amount by product category

WITH category_transaction AS (
SELECT ic.Category, COUNT(s.Prod_Num) + COUNT(o.ProdNum) AS total_transaction
FROM Inventory_Categories ic
LEFT JOIN Products p
ON ic.CategoryId = p.CategoryId
LEFT JOIN Store_Sales s
ON p.ProdNum = s.Prod_Num
LEFT JOIN Online_Sales o
ON p.ProdNum = o.ProdNum
LEFT JOIN Store_Locations sl
ON s.Store_ID = sl.StoreId
WHERE sl.State = "Colorado" AND o.ShiptoState = "Colorado"
GROUP BY ic.Category)

SELECT AVG(total_transaction) AS average_transaction FROM category_transaction;

-- 4.5) In-store sales performance
SELECT ss.Store_ID, sl.StoreLocation, SUM(ss.Sale_Amount) AS total_sales
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY ss.Store_ID
ORDER BY total_sales DESC;

-- 4.6) 