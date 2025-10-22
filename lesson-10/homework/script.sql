/* ===============================
   EASY-LEVEL TASKS
   =============================== */

-- 1) Сотрудники с зарплатой > 50000 + их департаменты
-- Expected: EmployeeName, Salary, DepartmentName
SELECT e.EmployeeName,
       e.Salary,
       d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d
  ON d.DepartmentID = e.DepartmentID
WHERE e.Salary > 50000;

-- 2) Клиенты и даты заказов, оформленных в 2023 году
-- Expected: FirstName, LastName, OrderDate
SELECT c.FirstName,
       c.LastName,
       o.OrderDate
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o
  ON o.CustomerID = c.CustomerID
WHERE o.OrderDate >= '2023-01-01'
  AND o.OrderDate <  '2024-01-01';

-- 3) Все сотрудники + название департамента (включая тех, у кого департамента нет)
-- Expected: EmployeeName, DepartmentName
SELECT e.EmployeeName,
       d.DepartmentName
FROM dbo.Employees   AS e
LEFT JOIN dbo.Departments AS d
  ON d.DepartmentID = e.DepartmentID;

-- 4) Все поставщики и продукты, которые они поставляют
-- (показываем поставщиков даже если у них нет продуктов)
-- Expected: SupplierName, ProductName
SELECT s.SupplierName,
       p.ProductName
FROM dbo.Suppliers AS s
LEFT JOIN dbo.Products  AS p
  ON p.SupplierID = s.SupplierID;

-- 5) Все заказы и соответствующие платежи
-- (включая заказы без платежей и платежи без заказа)
-- Expected: OrderID, OrderDate, PaymentDate, Amount
SELECT o.OrderID,
       o.OrderDate,
       p.PaymentDate,
       p.Amount
FROM dbo.Orders   AS o
FULL OUTER JOIN dbo.Payments AS p
  ON p.OrderID = o.OrderID;

-- 6) Имя сотрудника + имя его менеджера (self-join)
-- Expected: EmployeeName, ManagerName
SELECT e.EmployeeName,
       m.EmployeeName AS ManagerName
FROM dbo.Employees AS e
LEFT JOIN dbo.Employees AS m
  ON m.EmployeeID = e.ManagerID;

-- 7) Студенты, записанные на курс 'Math 101'
-- Expected: StudentName, CourseName
SELECT s.StudentName,
       c.CourseName
FROM dbo.Students    AS s
JOIN dbo.Enrollments AS en
  ON en.StudentID = s.StudentID
JOIN dbo.Courses     AS c
  ON c.CourseID = en.CourseID
WHERE c.CourseName = 'Math 101';

-- 8) Клиенты, оформившие заказ с количеством > 3
-- (предполагаем, что в Orders есть колонка Quantity)
-- Expected: FirstName, LastName, Quantity
SELECT DISTINCT
       c.FirstName,
       c.LastName,
       o.Quantity
FROM dbo.Customers AS c
JOIN dbo.Orders    AS o
  ON o.CustomerID = c.CustomerID
WHERE o.Quantity > 3;

-- 9) Сотрудники из отдела 'Human Resources'
-- Expected: EmployeeName, DepartmentName
SELECT e.EmployeeName,
       d.DepartmentName
FROM dbo.Employees   AS e
JOIN dbo.Departments AS d
  ON d.DepartmentID = e.DepartmentID
WHERE d.DepartmentName = 'Human Resources';

