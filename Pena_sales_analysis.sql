-- sales territory: Colorado.
USE sample_sales;

-- 4.1) Find total revenue

SELECT SUM(ss.Sale_Amount) AS store_revenue, MIN(ss.Transaction_Date) AS Start_Date, MAX(ss.Transaction_Date) AS End_Date
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado";


-- 4.2) Revenue breakdown by year and month

SELECT DATE_FORMAT(ss.Transaction_Date, "%m/%Y") AS StoreDate, SUM(ss.Sale_Amount) AS store_amount
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY StoreDate;


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


-- 4.4a) Find number of transactions per month

SELECT DATE_FORMAT(ss.Transaction_Date, "%m/%Y") AS StoreDate, COUNT(DATE_FORMAT(ss.Transaction_Date, "%m/%d/%Y")) AS store_transactions
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY StoreDate;


-- 4.4b) Average transaction amount by product category

WITH category_transaction AS (
SELECT ic.Category AS category, p.Product AS product, COUNT(s.Prod_Num) AS total_transaction
FROM Inventory_Categories ic
LEFT JOIN Products p
ON ic.CategoryId = p.CategoryId
LEFT JOIN Store_Sales s
ON p.ProdNum = s.Prod_Num
LEFT JOIN Store_Locations sl
ON s.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY p.Product, ic.Category
)

SELECT category, AVG(total_transaction) AS average_transaction 
FROM category_transaction
GROUP BY category;

-- 4.5) In-store sales performance
SELECT ss.Store_ID, sl.StoreLocation, SUM(ss.Sale_Amount) AS total_sales
FROM Store_Sales ss
LEFT JOIN Store_Locations sl
ON ss.Store_ID = sl.StoreId
WHERE sl.State = "Colorado"
GROUP BY ss.Store_ID
ORDER BY total_sales DESC;


-- 4.6) Recommendations

SELECT ic.Category AS category, COUNT(s.Prod_Num) AS store_total_transaction, SUM(s.Sale_Amount) AS store_total_sale
FROM Inventory_Categories ic
LEFT JOIN Products p
ON ic.CategoryId = p.CategoryId
LEFT JOIN Store_Sales s
ON p.ProdNum = s.Prod_Num
LEFT JOIN Store_Locations sl
ON s.Store_ID = sl.StoreId
WHERE sl.State = "Colorado" AND s.Transaction_Date LIKE "2025-%"
GROUP BY ic.Category
ORDER BY store_total_sale DESC;

SELECT DATE_FORMAT(s.Transaction_Date, "%m/%Y") AS StoreDate, SUM(s.Sale_Amount) AS store_amount
FROM Inventory_Categories ic
LEFT JOIN Products p
ON ic.CategoryId = p.CategoryId
LEFT JOIN Store_Sales s
ON p.ProdNum = s.Prod_Num
LEFT JOIN Store_Locations sl
ON s.Store_ID = sl.StoreId
WHERE sl.State = "Colorado" AND ic.Category = "Stationery and Supplies"
GROUP BY StoreDate;

/*
Findings:

- Best performing category is Technology & Accessories
- Least performing is Stationery & Supplies
- Textbooks and Books (General) outperformed Stationery & Supplies, despite less transactions
- Total sales for October jumped by 68.7% from September, across all product categories.​
- Total sales for December dropped by 37.6% from October, across all product categories

- Best performing store is Denver
- Least performing stores are Milliken, Berthoud, Wheat Ridge, and Parker
- Stores such as Lafayette, Sedalia, and Aurora experienced sales recovery from November to December
- Grand Junction is the only store that didn't suffer in sales loss.

Recommendation: 

In the next quarter, investigate the cause in total sales drop from October to December. 
Focus on top performing product categories and store locations. Improve promotions for 
Textbooks and Books (General) because they generate the most sales relative to their 
transaction amount. Find out what we did right from September to October that caused 
the 68.7% increase in sales and how we can replicate that for the next quarter.​ Reach out 
to the store location in Grand Junction and recovering locations, such as Lafayette and 
Sedalia, and learn what they are doing to revive their sales.​
*/