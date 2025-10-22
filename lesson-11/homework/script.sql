/* Helper for names (safe on both schemas with/without First/Last) */
-- CustomerName expr we'll reuse:
-- COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName) AS CustomerName


/* 1) Orders after 2022 with customer names
   Return: OrderID, CustomerName, OrderDate */
SELECT 
    o.OrderID,
    COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName) AS CustomerName,
    o.OrderDate
FROM dbo.Orders    AS o
JOIN dbo.Customers AS c
  ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2023-01-01';


/* 2) Employees in Sales or Marketing
   Return: EmployeeName, DepartmentName */
SELECT 
    e.EmployeeName,
    d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d
  ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName IN ('Sales','Marketing');


/* 3) Max salary per department
   Return: DepartmentName, MaxSalary */
SELECT 
    d.DepartmentName,
    MAX(e.Salary) AS MaxSalary
FROM dbo.Departments AS d
JOIN dbo.Employees   AS e
  ON e.DepartmentID = d.DepartmentID
GROUP BY d.DepartmentName;


/* 4) USA customers with orders in 2023
   Return: CustomerName, OrderID, OrderDate */
SELECT 
    COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName) AS CustomerName,
    o.OrderID,
    o.OrderDate
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o
  ON o.CustomerID = c.CustomerID
WHERE c.Country = 'USA'
  AND o.OrderDate >= '2023-01-01'
  AND o.OrderDate <  '2024-01-01';


/* 5) How many orders each customer placed
   Return: CustomerName, TotalOrders */
SELECT 
    COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName) AS CustomerName,
    COUNT(o.OrderID) AS TotalOrders
FROM dbo.Customers AS c
LEFT JOIN dbo.Orders AS o
  ON o.CustomerID = c.CustomerID
GROUP BY COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName);


/* 6) Products supplied by either Gadget Supplies or Clothing Mart
   Return: ProductName, SupplierName */
SELECT 
    p.ProductName,
    s.SupplierName
FROM dbo.Products  AS p
JOIN dbo.Suppliers AS s
  ON s.SupplierID = p.SupplierID
WHERE s.SupplierName IN ('Gadget Supplies','Clothing Mart');


/* 7) Most recent order per customer (include customers with no orders)
   Return: CustomerName, MostRecentOrderDate */
SELECT
    COALESCE(NULLIF(LTRIM(RTRIM(c.FirstName + ' ' + c.LastName)), ' '), c.CustomerName) AS CustomerName,
    oa.MostRecentOrderDate
FROM dbo.Customers AS c
OUTER APPLY (
    SELECT TOP (1) o.OrderDate AS MostRecentOrderDate
    FROM dbo.Orders AS o
    WHERE o.CustomerID = c.CustomerID
    ORDER BY o.OrderDate DESC
) AS oa;

