/* ============================================
   EASY-LEVEL TASKS
   ============================================ */

-- 1) Total number of products in each category
SELECT
  p.Category,
  COUNT(*) AS ProductCount
FROM dbo.Products AS p
GROUP BY p.Category;

-- 2) Average price in 'Electronics' category
SELECT AVG(CAST(p.Price AS DECIMAL(18,2))) AS AvgPrice_Electronics
FROM dbo.Products AS p
WHERE p.Category = 'Electronics';

-- 3) Customers from cities starting with 'L'
SELECT *
FROM dbo.Customers AS c
WHERE c.City LIKE 'L%';

-- 4) Product names ending with 'er'
SELECT p.ProductName
FROM dbo.Products AS p
WHERE p.ProductName LIKE '%er';

-- 5) Customers from countries ending in 'A'
SELECT *
FROM dbo.Customers AS c
WHERE c.Country LIKE '%A';

-- 6) Highest price among all products
SELECT MAX(p.Price) AS MaxProductPrice
FROM dbo.Products AS p;

-- 7) Label stock status ('Low Stock' if quantity < 30, else 'Sufficient')
SELECT
  p.ProductID,
  p.ProductName,
  p.StockQuantity,
  CASE WHEN p.StockQuantity < 30 THEN 'Low Stock' ELSE 'Sufficient' END AS StockStatus
FROM dbo.Products AS p;

-- 8) Total number of customers in each country
SELECT
  c.Country,
  COUNT(*) AS CustomerCount
FROM dbo.Customers AS c
GROUP BY c.Country;

-- 9) Min and Max quantity ordered (Orders)
SELECT
  MIN(o.Quantity) AS MinQty,
  MAX(o.Quantity) AS MaxQty
FROM dbo.Orders AS o;


/* ============================================
   MEDIUM-LEVEL TASKS
   ============================================ */

-- 1) Customer IDs who placed orders in Jan 2023 but had NO invoices in Jan 2023
-- (Assumes Orders.OrderDate, Invoices.InvoiceDate, and CustomerID in both)
SELECT DISTINCT o.CustomerID
FROM dbo.Orders AS o
WHERE o.OrderDate >= '2023-01-01' AND o.OrderDate < '2023-02-01'
EXCEPT
SELECT DISTINCT i.CustomerID
FROM dbo.Invoices AS i
WHERE i.InvoiceDate >= '2023-01-01' AND i.InvoiceDate < '2023-02-01';

-- 2) Combine all product names from Products and Products_Discounted (keep duplicates)
SELECT p.ProductName
FROM dbo.Products AS p
UNION ALL
SELECT d.ProductName
FROM dbo.Products_Discounted AS d;

-- 3) Combine all product names from Products and Products_Discounted (no duplicates)
SELECT p.ProductName
FROM dbo.Products AS p
UNION
SELECT d.ProductName
FROM dbo.Products_Discounted AS d;

-- 4) Average order amount by year
-- (Assumes Orders has OrderAmount; if not, replace with Quantity*UnitPrice)
SELECT
  YEAR(o.OrderDate) AS OrderYear,
  AVG(CAST(o.OrderAmount AS DECIMAL(18,2))) AS AvgOrderAmount
FROM dbo.Orders AS o
GROUP BY YEAR(o.OrderDate)
ORDER BY OrderYear;

-- 5) Price grouping: 'Low' (<100), 'Mid' (100–500), 'High' (>500)
SELECT
  p.ProductName,
  CASE
    WHEN p.Price < 100 THEN 'Low'
    WHEN p.Price BETWEEN 100 AND 500 THEN 'Mid'
    ELSE 'High'
  END AS PriceGroup
FROM dbo.Products AS p;

-- 6) PIVOT year values into columns [2012], [2013]; save to Population_Each_Year
-- (Assumes City_Population has columns: City, [Year], Population)
IF OBJECT_ID('dbo.Population_Each_Year','U') IS NOT NULL DROP TABLE dbo.Population_Each_Year;
SELECT *
INTO dbo.Population_Each_Year
FROM (
    SELECT City, [Year], Population
    FROM dbo.City_Population
) AS src
PIVOT (
    SUM(Population) FOR [Year] IN ([2012],[2013])
) AS pvt;

-- 7) Total sales per ProductID (Sales)
-- (Use TotalAmount if present; else Quantity*UnitPrice; handle NULLs)
SELECT
  s.ProductID,
  SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales
FROM dbo.Sales AS s
GROUP BY s.ProductID;

-- 8) Products containing 'oo' in the name
SELECT p.ProductName
FROM dbo.Products AS p
WHERE p.ProductName LIKE '%oo%';

-- 9) PIVOT city values into columns (Bektemir, Chilonzor, Yakkasaroy); save to Population_Each_City
-- Result rows by Year (or another key); adjust as needed.
IF OBJECT_ID('dbo.Population_Each_City','U') IS NOT NULL DROP TABLE dbo.Population_Each_City;
SELECT *
INTO dbo.Population_Each_City
FROM (
    SELECT [Year], City, Population
    FROM dbo.City_Population
) AS src
PIVOT (
    SUM(Population) FOR City IN ([Bektemir],[Chilonzor],[Yakkasaroy])
) AS pvt;

