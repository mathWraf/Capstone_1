-- Colorado sales territory.
USE sample_sales;

-- Find total revenue
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

-- Revenue breakdown by year and month
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

-- 
SELECT * FROM Management WHERE Region = "West";