/* ============================================
   Lesson 9 — INNER + CROSS joins (Easy Level)
   ============================================ */

-- 1) Products × Suppliers — all combinations (Cartesian product)
SELECT p.ProductName, s.SupplierName
FROM dbo.Products AS p
CROSS JOIN dbo.Suppliers AS s;

-- 2) Departments × Employees — all combinations
SELECT d.DepartmentName, e.EmployeeName
FROM dbo.Departments AS d
CROSS JOIN dbo.Employees   AS e;

-- 3) Only where supplier actually supplies the product
--    (classic inner join on SupplierID)
SELECT s.SupplierName, p.ProductName
FROM dbo.Suppliers AS s
JOIN dbo.Products  AS p
  ON p.SupplierID = s.SupplierID;

-- 4) Customer names and their Order IDs
SELECT c.CustomerName, o.OrderID
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o
  ON o.CustomerID = c.CustomerID;

-- 5) Students × Courses — all combinations
SELECT st.StudentName, c.CourseName
FROM dbo.Students AS st
CROSS JOIN dbo.Courses AS c;

-- 6) Products and Orders where ProductIDs match
SELECT p.ProductName, o.OrderID, o.Quantity
FROM dbo.Products AS p
JOIN dbo.Orders   AS o
  ON o.ProductID = p.ProductID;

-- 7) Employees whose DepartmentID matches the department
SELECT d.DepartmentID, d.DepartmentName, e.EmpID, e.EmployeeName
FROM dbo.Departments AS d
JOIN dbo.Employees   AS e
  ON e.DepartmentID = d.DepartmentID;

-- 8) Student names and their enrolled CourseIDs
SELECT st.StudentName, en.CourseID
FROM dbo.Students    AS st
JOIN dbo.Enrollments AS en
  ON en.StudentID = st.StudentID;

-- 9) Orders that have matching payments
SELECT o.OrderID, pmt.PaymentID, pmt.Amount
FROM dbo.Orders   AS o
JOIN dbo.Payments AS pmt
  ON pmt.OrderID = o.OrderID;

-- 10) Orders where the product price is more than 100
--     (filter in ON to showcase non-equality operator usage)
SELECT o.OrderID, p.ProductName, p.Price
FROM dbo.Orders   AS o
JOIN dbo.Products AS p
  ON p.ProductID = o.ProductID
 AND p.Price > 100;  -- using '>' in ON

-- Using <>  (not equal): join customers to orders except a specific city
SELECT c.CustomerID, o.OrderID
FROM dbo.Customers c
JOIN dbo.Orders    o
  ON o.CustomerID = c.CustomerID
 AND c.City <> 'Nowhere';

-- Using >= or <= : orders joined to products with price band condition
SELECT o.OrderID, p.ProductName, p.Price
FROM dbo.Orders o
JOIN dbo.Products p
  ON p.ProductID = o.ProductID
 AND p.Price >= 50
 AND p.Price <= 500;


