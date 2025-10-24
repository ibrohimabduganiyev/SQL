/* =========================================================
   PART 1 — Stored Procedure Tasks (Employees / DepartmentBonus)
========================================================= */
IF OBJECT_ID('dbo.Employees') IS NULL
BEGIN
    CREATE TABLE dbo.Employees (
        EmployeeID INT PRIMARY KEY,
        FirstName  NVARCHAR(50),
        LastName   NVARCHAR(50),
        Department NVARCHAR(50),
        Salary     DECIMAL(10,2)
    );
END;

IF OBJECT_ID('dbo.DepartmentBonus') IS NULL
BEGIN
    CREATE TABLE dbo.DepartmentBonus (
        Department      NVARCHAR(50) PRIMARY KEY,
        BonusPercentage DECIMAL(5,2)
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Employees)
BEGIN
    INSERT INTO dbo.Employees VALUES
    (1, 'John', 'Doe', 'Sales', 5000),
    (2, 'Jane', 'Smith', 'Sales', 5200),
    (3, 'Mike', 'Brown', 'IT',    6000),
    (4, 'Anna', 'Taylor','HR',    4500);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DepartmentBonus)
BEGIN
    INSERT INTO dbo.DepartmentBonus VALUES
    ('Sales', 10),
    ('IT',    15),
    ('HR',     8);
END;
GO

/* 📄 Task 1: sp_BuildEmployeeBonus
   - Создаёт #EmployeeBonus (EmployeeID, FullName, Department, Salary, BonusAmount)
   - Заполняет с учётом процента бонуса
   - Возвращает содержимое #EmployeeBonus
*/
IF OBJECT_ID('dbo.sp_BuildEmployeeBonus','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_BuildEmployeeBonus;
GO
CREATE PROCEDURE dbo.sp_BuildEmployeeBonus
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#EmployeeBonus') IS NOT NULL
        DROP TABLE #EmployeeBonus;

    CREATE TABLE #EmployeeBonus (
        EmployeeID  INT        NOT NULL,
        FullName    NVARCHAR(200) NOT NULL,
        Department  NVARCHAR(50)  NOT NULL,
        Salary      DECIMAL(10,2) NOT NULL,
        BonusAmount DECIMAL(18,2) NOT NULL
    );

    INSERT INTO #EmployeeBonus (EmployeeID, FullName, Department, Salary, BonusAmount)
    SELECT
        e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
        e.Department,
        e.Salary,
        CAST(e.Salary * (COALESCE(db.BonusPercentage,0) / 100.0) AS DECIMAL(18,2)) AS BonusAmount
    FROM dbo.Employees e
    LEFT JOIN dbo.DepartmentBonus db
           ON db.Department = e.Department;

    SELECT * FROM #EmployeeBonus ORDER BY EmployeeID;
END;
GO
-- EXEC dbo.sp_BuildEmployeeBonus;

 /* 📄 Task 2: sp_UpdateDepartmentSalary
    - Параметры: @Department, @IncreasePercent
    - Обновляет Salary = Salary * (1 + @IncreasePercent/100)
    - Возвращает обновлённых сотрудников этого департамента
 */
IF OBJECT_ID('dbo.sp_UpdateDepartmentSalary','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_UpdateDepartmentSalary;
GO
CREATE PROCEDURE dbo.sp_UpdateDepartmentSalary
    @Department      NVARCHAR(50),
    @IncreasePercent DECIMAL(9,4)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Employees
       SET Salary = CAST(Salary * (1.0 + (@IncreasePercent / 100.0)) AS DECIMAL(10,2))
     WHERE Department = @Department;

    SELECT EmployeeID,
           CONCAT(FirstName, ' ', LastName) AS FullName,
           Department,
           Salary
    FROM dbo.Employees
    WHERE Department = @Department
    ORDER BY EmployeeID;
END;
GO
-- EXEC dbo.sp_UpdateDepartmentSalary @Department = N'Sales', @IncreasePercent = 5;


/* =========================================================
   PART 2 — MERGE Tasks (Products_Current / Products_New)
========================================================= */
IF OBJECT_ID('dbo.Products_Current') IS NULL
BEGIN
    CREATE TABLE dbo.Products_Current (
        ProductID   INT PRIMARY KEY,
        ProductName NVARCHAR(100),
        Price       DECIMAL(10,2)
    );
END;

IF OBJECT_ID('dbo.Products_New') IS NULL
BEGIN
    CREATE TABLE dbo.Products_New (
        ProductID   INT PRIMARY KEY,
        ProductName NVARCHAR(100),
        Price       DECIMAL(10,2)
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.Products_Current)
BEGIN
    INSERT INTO dbo.Products_Current VALUES
    (1, 'Laptop',     1200),
    (2, 'Tablet',      600),
    (3, 'Smartphone',  800);
END;

-- Переинициализируем "новую" витрину
TRUNCATE TABLE dbo.Products_New;
INSERT INTO dbo.Products_New VALUES
(2, 'Tablet Pro',     700),
(3, 'Smartphone',     850),
(4, 'Smartwatch',     300);

-- 📄 Task 3: MERGE (update, insert, delete) + финальное состояние
MERGE dbo.Products_Current AS tgt
USING dbo.Products_New     AS src
   ON tgt.ProductID = src.ProductID
WHEN MATCHED THEN
    UPDATE SET
        tgt.ProductName = src.ProductName,
        tgt.Price       = src.Price
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, Price)
    VALUES (src.ProductID, src.ProductName, src.Price)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT $action AS MergeAction, inserted.ProductID, inserted.ProductName, inserted.Price;

-- Итог после MERGE:
SELECT * FROM dbo.Products_Current ORDER BY ProductID;


/* =========================================================
   📄 Task 4: Tree Node — тип каждой вершины (Root / Inner / Leaf)
   (LeetCode style; SQL Server)
========================================================= */
IF OBJECT_ID('dbo.Tree') IS NULL
BEGIN
    CREATE TABLE dbo.Tree (id INT PRIMARY KEY, p_id INT NULL);
END;
TRUNCATE TABLE dbo.Tree;
INSERT INTO dbo.Tree (id, p_id) VALUES
(1, NULL),
(2, 1),
(3, 1),
(4, 2),
(5, 2);

-- Решение:
SELECT
    t.id,
    CASE
        WHEN t.p_id IS NULL THEN 'Root'
        WHEN EXISTS (SELECT 1 FROM dbo.Tree c WHERE c.p_id = t.id) THEN 'Inner'
        ELSE 'Leaf'
    END AS type
FROM dbo.Tree t
ORDER BY t.id;


/* =========================================================
   📄 Task 5: Confirmation Rate (LeetCode style)
   SQL Server версия (без ENUM): action NVARCHAR(10)
========================================================= */
IF OBJECT_ID('dbo.Signups') IS NULL
BEGIN
    CREATE TABLE dbo.Signups (
        user_id    INT PRIMARY KEY,
        time_stamp DATETIME
    );
END;

IF OBJECT_ID('dbo.Confirmations') IS NULL
BEGIN
    CREATE TABLE dbo.Confirmations (
        user_id    INT,
        time_stamp DATETIME,
        action     NVARCHAR(10)  -- 'confirmed' / 'timeout'
    );
END;

TRUNCATE TABLE dbo.Signups;
INSERT INTO dbo.Signups (user_id, time_stamp) VALUES
(3, '2020-03-21 10:16:13'),
(7, '2020-01-04 13:57:59'),
(2, '2020-07-29 23:09:44'),
(6, '2020-12-09 10:39:37');

TRUNCATE TABLE dbo.Confirmations;
INSERT INTO dbo.Confirmations (user_id, time_stamp, action) VALUES
(3, '2021-01-06 03:30:46', 'timeout'),
(3, '2021-07-14 14:00:00', 'timeout'),
(7, '2021-06-12 11:57:29', 'confirmed'),
(7, '2021-06-13 12:58:28', 'confirmed'),
(7, '2021-06-14 13:59:27', 'confirmed'),
(2, '2021-01-22 00:00:00', 'confirmed'),
(2, '2021-02-28 23:59:59', 'timeout');

-- Решение: для каждого user_id из Signups — confirmed / total, 2 знака
WITH Agg AS (
    SELECT
        s.user_id,
        SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END) AS confirmed_cnt,
        COUNT(c.user_id) AS total_cnt
    FROM dbo.Signups s
    LEFT JOIN dbo.Confirmations c
           ON c.user_id = s.user_id
    GROUP BY s.user_id
)
SELECT
    user_id,
    CAST(ROUND(COALESCE(1.0 * confirmed_cnt / NULLIF(total_cnt,0), 0.0), 2) AS DECIMAL(10,2)) AS confirmation_rate
FROM Agg
ORDER BY confirmation_rate, user_id;  -- как в примере: 0.00, 0.00, 1.00, 0.50


/* =========================================================
   📄 Task 6: Employees with the lowest salary (subquery)
========================================================= */
IF OBJECT_ID('dbo.employees') IS NULL
BEGIN
    CREATE TABLE dbo.employees (
        id INT PRIMARY KEY,
        name   VARCHAR(100),
        salary DECIMAL(10,2)
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.employees)
BEGIN
    INSERT INTO dbo.employees (id, name, salary) VALUES
    (1, 'Alice',   50000),
    (2, 'Bob',     60000),
    (3, 'Charlie', 50000);
END;

SELECT id, name, salary
FROM dbo.employees
WHERE salary = (SELECT MIN(salary) FROM dbo.employees)
ORDER BY id;


/* =========================================================
   📄 Task 7: GetProductSalesSummary (stored procedure)
   - Вход: @ProductID
   - Выход: ProductName, TotalQuantity, TotalAmount, FirstSaleDate, LastSaleDate
     (если продаж нет — ProductName, а остальные NULL)
========================================================= */
IF OBJECT_ID('dbo.Products') IS NULL
BEGIN
    CREATE TABLE dbo.Products (
        ProductID   INT PRIMARY KEY,
        ProductName NVARCHAR(100),
        Category    NVARCHAR(50),
        Price       DECIMAL(10,2)
    );
END;

IF OBJECT_ID('dbo.Sales') IS NULL
BEGIN
    CREATE TABLE dbo.Sales (
        SaleID    INT PRIMARY KEY,
        ProductID INT FOREIGN KEY REFERENCES dbo.Products(ProductID),
        Quantity  INT,
        SaleDate  DATE
    );
END;

-- Примерные данные из задания могут быть вставлены отдельно при необходимости.

IF OBJECT_ID('dbo.GetProductSalesSummary','P') IS NOT NULL
    DROP PROCEDURE dbo.GetProductSalesSummary;
GO
CREATE PROCEDURE dbo.GetProductSalesSummary
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.ProductName,
        SUM(s.Quantity)                                      AS [Total Quantity Sold],
        SUM(CAST(s.Quantity AS DECIMAL(18,2)) * p.Price)     AS [Total Sales Amount],
        MIN(s.SaleDate)                                      AS [First Sale Date],
        MAX(s.SaleDate)                                      AS [Last Sale Date]
    FROM dbo.Products p
    LEFT JOIN dbo.Sales s
           ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID
    GROUP BY p.ProductName;
END;
GO
-- EXEC dbo.GetProductSalesSummary @ProductID = 1;

