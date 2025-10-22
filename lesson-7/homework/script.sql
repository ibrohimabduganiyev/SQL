/* =========================================================
   🟢 EASY-LEVEL TASKS (10)
   ========================================================= */

-- 1) MIN price (Products)
SELECT MIN(p.Price) AS MinPrice
FROM dbo.Products AS p;

-- 2) MAX salary (Employees)
SELECT MAX(e.Salary) AS MaxSalary
FROM dbo.Employees AS e;

-- 3) Count rows in Customers
SELECT COUNT(*) AS CustomerCount
FROM dbo.Customers AS c;

-- 4) Count unique product categories (Products)
SELECT COUNT(DISTINCT p.Category) AS DistinctCategoryCount
FROM dbo.Products AS p;

-- 5) Total sales amount for product id = 7 (Sales)
-- Uses TotalAmount if present; else Quantity*UnitPrice; defaults to 0 if nulls.
SELECT
  SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSalesForProd7
FROM dbo.Sales AS s
WHERE s.ProductID = 7;

-- 6) Average age of employees
SELECT AVG(CAST(e.Age AS DECIMAL(10,2))) AS AvgEmployeeAge
FROM dbo.Employees AS e;

-- 7) Number of employees in each department (DeptID is safe/common)
SELECT
  e.DeptID,
  COUNT(*) AS EmployeeCount
FROM dbo.Employees AS e
GROUP BY e.DeptID;

-- 8) Min/Max Price by Category (Products)
SELECT
  p.Category,
  MIN(p.Price) AS MinPrice,
  MAX(p.Price) AS MaxPrice
FROM dbo.Products AS p
GROUP BY p.Category;

-- 9) Total sales per Customer (Sales)
SELECT
  s.CustomerID,
  SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales
FROM dbo.Sales AS s
GROUP BY s.CustomerID;

-- 10) Departments having more than 5 employees
SELECT
  e.DeptID,
  COUNT(*) AS EmployeeCount
FROM dbo.Employees AS e
GROUP BY e.DeptID
HAVING COUNT(*) > 5;


/* =========================================================
   🟠 MEDIUM-LEVEL TASKS (9)
   ========================================================= */

-- 1) Total and average sales for each product category (join Sales→Products)
SELECT
  p.Category,
  SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales,
  AVG(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0.0)) AS AvgSales
FROM dbo.Sales AS s
JOIN dbo.Products AS p
  ON p.ProductID = s.ProductID
GROUP BY p.Category;

-- 2) Count number of employees from Department 'HR'
-- (If you don’t have DepartmentName, replace with DeptID = <HR_ID>.)
SELECT COUNT(*) AS HREmployeeCount
FROM dbo.Employees AS e
WHERE UPPER(e.DepartmentName) = 'HR';

-- 3) Highest and lowest Salary by department
SELECT
  e.DeptID,
  MAX(e.Salary) AS MaxSalary,
  MIN(e.Salary) AS MinSalary
FROM dbo.Employees AS e
GROUP BY e.DeptID;

-- 4) Average salary per Department
SELECT
  e.DeptID,
  AVG(CAST(e.Salary AS DECIMAL(18,2))) AS AvgSalary
FROM dbo.Employees AS e
GROUP BY e.DeptID;

-- 5) AVG salary and COUNT(*) per Department
SELECT
  e.DeptID,
  AVG(CAST(e.Salary AS DECIMAL(18,2))) AS AvgSalary,
  COUNT(*) AS EmployeeCount
FROM dbo.Employees AS e
GROUP BY e.DeptID;

-- 6) Product categories with AVG price > 400
SELECT
  p.Category,
  AVG(CAST(p.Price AS DECIMAL(18,2))) AS AvgPrice
FROM dbo.Products AS p
GROUP BY p.Category
HAVING AVG(CAST(p.Price AS DECIMAL(18,2))) > 400;

-- 7) Total sales for each year (Sales)
-- Uses OrderDate if present, else SaleDate.
SELECT
  YEAR(COALESCE(s.OrderDate, s.SaleDate)) AS SalesYear,
  SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales
FROM dbo.Sales AS s
GROUP BY YEAR(COALESCE(s.OrderDate, s.SaleDate))
ORDER BY SalesYear;

-- 8) Customers who placed at least 3 orders (Sales)
SELECT
  s.CustomerID,
  COUNT(*) AS OrderCount
FROM dbo.Sales AS s
GROUP BY s.CustomerID
HAVING COUNT(*) >= 3;

-- 9) Departments with average salary > 60000
SELECT
  e.DeptID,
  AVG(CAST(e.Salary AS DECIMAL(18,2))) AS AvgSalary
FROM dbo.Employees AS e
GROUP BY e.DeptID
HAVING AVG(CAST(e.Salary AS DECIMAL(18,2))) > 60000;

