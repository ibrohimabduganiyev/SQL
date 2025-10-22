/* =========================================================
   EASY-LEVEL TASKS (10)
   ========================================================= */

-- 1) Top 5 employees (stable order by EmpID; adjust if you prefer Salary, etc.)
SELECT TOP (5) *
FROM dbo.Employees
ORDER BY EmpID ASC;

-- 2) Unique Category values from Products
SELECT DISTINCT Category
FROM dbo.Products;

-- 3) Products with Price > 100
SELECT *
FROM dbo.Products
WHERE Price > 100;

-- 4) Customers whose FirstName starts with 'A'
SELECT *
FROM dbo.Customers
WHERE FirstName LIKE 'A%';

-- 5) Order Products by Price ascending
SELECT *
FROM dbo.Products
ORDER BY Price ASC;

-- 6) Employees with Salary >= 60000 and DepartmentName = 'HR'
SELECT *
FROM dbo.Employees
WHERE Salary >= 60000
  AND DepartmentName = 'HR';

-- 7) Replace NULL Email with default text (Employees)
SELECT
    EmpID,
    FirstName,
    LastName,
    ISNULL(Email, 'noemail@example.com') AS Email
FROM dbo.Employees;

-- 8) Products with Price BETWEEN 50 AND 100 (inclusive)
SELECT *
FROM dbo.Products
WHERE Price BETWEEN 50 AND 100;

-- 9) DISTINCT on two columns (Category, ProductName)
SELECT DISTINCT Category, ProductName
FROM dbo.Products;

-- 10) DISTINCT on (Category, ProductName) + order by ProductName DESC
SELECT DISTINCT Category, ProductName
FROM dbo.Products
ORDER BY ProductName DESC;


/* =========================================================
   MEDIUM-LEVEL TASKS (9 given)
   ========================================================= */

-- 1) Top 10 products ordered by Price DESC
SELECT TOP (10) *
FROM dbo.Products
ORDER BY Price DESC;

-- 2) COALESCE: first non-NULL of FirstName or LastName (Employees)
SELECT
    EmpID,
    COALESCE(FirstName, LastName) AS PreferredName
FROM dbo.Employees;

-- 3) DISTINCT Category and Price (Products)
SELECT DISTINCT Category, Price
FROM dbo.Products;

-- 4) Employees with Age between 30 and 40 OR DepartmentName = 'Marketing'
SELECT *
FROM dbo.Employees
WHERE (Age BETWEEN 30 AND 40)
   OR DepartmentName = 'Marketing';

-- 5) OFFSET-FETCH: rows 11..20 by Salary DESC (requires ORDER BY)
SELECT *
FROM dbo.Employees
ORDER BY Salary DESC
OFFSET 10 ROWS FETCH NEXT 10 ROWS ONLY;

-- 6) Products with Price <= 1000 and StockQuantity > 50, sort by StockQuantity ASC
SELECT *
FROM dbo.Products
WHERE Price <= 1000
  AND StockQuantity > 50
ORDER BY StockQuantity ASC;

-- 7) Products whose ProductName contains the letter 'e'
SELECT *
FROM dbo.Products
WHERE ProductName LIKE '%e%';

-- 8) Employees working in HR, IT, or Finance
SELECT *
FROM dbo.Employees
WHERE DepartmentName IN ('HR', 'IT', 'Finance');

-- 9) Customers ordered by City ASC, PostalCode DESC
SELECT *
FROM dbo.Customers
ORDER BY City ASC, PostalCode DESC;


/* =========================================================
   BONUS: ANY / ALL examples (optional, for the rubric)
   ========================================================= */

-- Products priced greater than ANY competitor prices (i.e., > min competitor price)
-- (Assumes dbo.CompetitorPrices(ProductName, Price)); adjust to your schema.
-- SELECT *
-- FROM dbo.Products p
-- WHERE p.Price > ANY (SELECT c.Price FROM dbo.CompetitorPrices c);

-- Products priced greater than ALL competitor prices (i.e., > max competitor price)
-- SELECT *
-- FROM dbo.Products p
-- WHERE p.Price > ALL (SELECT c.Price FROM dbo.CompetitorPrices c);

