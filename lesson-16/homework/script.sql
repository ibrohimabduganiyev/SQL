/* =========================================================
   1) Numbers 1..1000 via recursive CTE (materialize into a temp table if you want)
   ========================================================= */
WITH nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM nums WHERE n < 1000
)
SELECT n
INTO #Numbers -- drop this if you just want a resultset
FROM nums
OPTION (MAXRECURSION 0);

-- SELECT * FROM #Numbers;

/* =========================================================
   2) Total sales per employee (derived table)  (Sales, Employees)
   ========================================================= */
SELECT 
    e.EmployeeID,
    e.EmployeeName,
    dt.TotalSales
FROM dbo.Employees AS e
LEFT JOIN (
    SELECT s.EmployeeID,
           SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales
    FROM dbo.Sales AS s
    GROUP BY s.EmployeeID
) AS dt
  ON dt.EmployeeID = e.EmployeeID
ORDER BY e.EmployeeID;

/* =========================================================
   3) Average salary of employees (CTE)  (Employees)
   ========================================================= */
WITH avg_salary AS (
    SELECT AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSalary
    FROM dbo.Employees
)
SELECT AvgSalary FROM avg_salary;

/* =========================================================
   4) Highest single sale per product (derived table)  (Sales, Products)
   ========================================================= */
SELECT 
    p.ProductID,
    p.ProductName,
    dt.MaxSaleAmount
FROM dbo.Products AS p
JOIN (
    SELECT s.ProductID,
           MAX(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS MaxSaleAmount
    FROM dbo.Sales AS s
    GROUP BY s.ProductID
) AS dt
  ON dt.ProductID = p.ProductID
ORDER BY p.ProductID;

/* =========================================================
   5) Starting at 1, double each time; max value < 1,000,000  (powers of two)
   ========================================================= */
WITH Doubles AS (
    SELECT CAST(1 AS BIGINT) AS val
    UNION ALL
    SELECT val * 2 FROM Doubles WHERE val * 2 < 1000000
)
SELECT val
FROM Doubles
ORDER BY val
OPTION (MAXRECURSION 0);

/* =========================================================
   6) Employees who made > 5 sales (CTE)  (Sales, Employees)
   ========================================================= */
WITH sales_count AS (
    SELECT s.EmployeeID, COUNT(*) AS SaleCount
    FROM dbo.Sales AS s
    GROUP BY s.EmployeeID
)
SELECT e.EmployeeID, e.EmployeeName, sc.SaleCount
FROM sales_count AS sc
JOIN dbo.Employees AS e
  ON e.EmployeeID = sc.EmployeeID
WHERE sc.SaleCount > 5
ORDER BY sc.SaleCount DESC;

/* =========================================================
   7) Products with total sales > $500 (CTE)  (Sales, Products)
   ========================================================= */
WITH product_totals AS (
    SELECT s.ProductID,
           SUM(COALESCE(s.TotalAmount, s.Quantity * s.UnitPrice, 0)) AS TotalSales
    FROM dbo.Sales AS s
    GROUP BY s.ProductID
)
SELECT p.ProductID, p.ProductName, pt.TotalSales
FROM product_totals AS pt
JOIN dbo.Products AS p
  ON p.ProductID = pt.ProductID
WHERE pt.TotalSales > 500
ORDER BY pt.TotalSales DESC;

/* =========================================================
   8) Employees with salaries above the average (CTE)  (Employees)
   ========================================================= */
WITH avg_sal AS (
    SELECT AVG(CAST(Salary AS DECIMAL(18,2))) AS AvgSalary
    FROM dbo.Employees
)
SELECT e.EmployeeID, e.EmployeeName, e.Salary
FROM dbo.Employees AS e
CROSS JOIN avg_sal AS a
WHERE e.Salary > a.AvgSalary
ORDER BY e.Salary DESC;

