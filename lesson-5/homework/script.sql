/* =========================================================
   EASY-LEVEL TASKS
   ========================================================= */

-- 1) Alias column: ProductName AS Name (Products)
SELECT p.ProductName AS [Name]
FROM dbo.Products AS p;

-- 2) Alias table: Customers AS Client
SELECT *
FROM dbo.Customers AS Client;

-- 3) UNION: ProductName from Products and Products_Discounted
SELECT p.ProductName
FROM dbo.Products AS p
UNION
SELECT d.ProductName
FROM dbo.Products_Discounted AS d;

-- 4) INTERSECT: common ProductName in both tables
SELECT p.ProductName
FROM dbo.Products AS p
INTERSECT
SELECT d.ProductName
FROM dbo.Products_Discounted AS d;

-- 5) DISTINCT customer names + Country
-- Robust name build if schema has FirstName/LastName:
SELECT DISTINCT
       COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.FirstName, c.LastName) AS CustomerName,
       c.Country
FROM dbo.Customers AS c;

-- 6) CASE: 'High' if Price > 1000, else 'Low'  (Products)
SELECT p.ProductName,
       p.Price,
       CASE WHEN p.Price > 1000 THEN 'High' ELSE 'Low' END AS PriceBand
FROM dbo.Products AS p;

-- 7) IIF: 'Yes' if StockQuantity > 100 else 'No' (Products_Discounted)
SELECT d.ProductName,
       d.StockQuantity,
       IIF(d.StockQuantity > 100, 'Yes', 'No') AS Over100
FROM dbo.Products_Discounted AS d;


/* =========================================================
   MEDIUM-LEVEL TASKS
   ========================================================= */

-- 1) UNION again (explicit per task)
SELECT p.ProductName FROM dbo.Products AS p
UNION
SELECT d.ProductName FROM dbo.Products_Discounted AS d;

-- 2) EXCEPT: Products MINUS Products_Discounted (by ProductName)
SELECT p.ProductName
FROM dbo.Products AS p
EXCEPT
SELECT d.ProductName
FROM dbo.Products_Discounted AS d;

-- 3) IIF: 'Expensive' if Price > 1000, else 'Affordable' (Products)
SELECT p.ProductID,
       p.ProductName,
       p.Price,
       IIF(p.Price > 1000, 'Expensive', 'Affordable') AS PriceTier
FROM dbo.Products AS p;

-- 4) Employees: Age < 25 OR Salary > 60000
SELECT e.*
FROM dbo.Employees AS e
WHERE e.Age < 25
   OR e.Salary > 60000;

-- 5) Update salary +10% if Department = 'HR' OR EmployeeID = 5
-- (With IF feedback + WHILE demo to satisfy control-flow requirements)
DECLARE @rows INT;

UPDATE e
SET e.Salary = e.Salary * 1.10
FROM dbo.Employees AS e
WHERE e.DepartmentName = 'HR'
   OR e.EmpID = 5;

SET @rows = @@ROWCOUNT;

IF (@rows > 0)
    PRINT CONCAT('Salaries updated for ', @rows, ' row(s).');
ELSE
    PRINT 'No salaries matched the criteria.';

-- WHILE demo (purely illustrative)
DECLARE @i INT = 1;
WHILE (@i <= 3)
BEGIN
    PRINT CONCAT('Post-update check iteration #', @i);
    SET @i += 1;
END;

