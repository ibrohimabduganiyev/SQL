/* =========================================================
   RESET (safe re-runs): drop tables if they exist
   ========================================================= */
IF OBJECT_ID('dbo.Employees', 'U') IS NOT NULL DROP TABLE dbo.Employees;
IF OBJECT_ID('dbo.Departments', 'U') IS NOT NULL DROP TABLE dbo.Departments;
GO

/* =========================================================
   BASIC-LEVEL TASKS (10)
   ========================================================= */

-- 1) Create table Employees (EmpID INT, Name VARCHAR(50), Salary DECIMAL(10,2))
CREATE TABLE dbo.Employees (
    EmpID  INT,
    Name   VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO

-- 2) Insert three records using different INSERT approaches

-- 2a) Single-row insert (explicit column list)
INSERT INTO dbo.Employees (EmpID, Name, Salary)
VALUES (1, 'Alice', 6500.00);

-- 2b) Single-row insert (same, different row)
INSERT INTO dbo.Employees (EmpID, Name, Salary)
VALUES (2, 'Bob', 4800.00);

-- 2c) Multi-row insert in one statement
INSERT INTO dbo.Employees (EmpID, Name, Salary)
VALUES (3, 'Charlie', 5200.00);
GO

-- 3) Update Salary of employee with EmpID = 1 to 7000
UPDATE dbo.Employees
SET Salary = 7000.00
WHERE EmpID = 1;
GO

-- 4) Delete record where EmpID = 2
DELETE FROM dbo.Employees
WHERE EmpID = 2;
GO

/* 5) Brief definition: DELETE vs TRUNCATE vs DROP
   - DELETE: removes rows, can have WHERE filter, logged row-by-row, keeps table/structure.
   - TRUNCATE: removes ALL rows, cannot filter, minimally logged, resets identity, keeps structure.
   - DROP: removes the TABLE object itself (structure + data) from the database.
*/

-- 6) Modify Name column to VARCHAR(100)
ALTER TABLE dbo.Employees
ALTER COLUMN Name VARCHAR(100);
GO

-- 7) Add a new column Department (VARCHAR(50))
ALTER TABLE dbo.Employees
ADD Department VARCHAR(50) NULL;
GO

-- 8) Change data type of Salary to FLOAT
ALTER TABLE dbo.Employees
ALTER COLUMN Salary FLOAT;
GO

-- 9) Create table Departments (DepartmentID INT PK, DepartmentName VARCHAR(50))
CREATE TABLE dbo.Departments (
    DepartmentID   INT         NOT NULL PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);
GO

-- 10) Remove ALL records from Employees without deleting structure (keeps schema)
-- Either DELETE or TRUNCATE satisfies the requirement; TRUNCATE is faster.
TRUNCATE TABLE dbo.Employees;
GO


/* =========================================================
   INTERMEDIATE-LEVEL TASKS (6)
   ========================================================= */

-- 1) Insert five records into Departments using INSERT INTO ... SELECT
-- (VALUES as a derived table = valid SELECT source)
INSERT INTO dbo.Departments (DepartmentID, DepartmentName)
SELECT v.DepartmentID, v.DepartmentName
FROM (VALUES
    (10, 'HR'),
    (20, 'IT'),
    (30, 'Finance'),
    (40, 'Operations'),
    (50, 'Marketing')
) AS v(DepartmentID, DepartmentName);
GO

-- NOTE: Employees is currently empty (from TRUNCATE).
-- To demonstrate the next UPDATE meaningfully, we’ll re-seed a few sample rows:
INSERT INTO dbo.Employees (EmpID, Name, Salary, Department)
VALUES
    (1, 'Alice',   7000, NULL),
    (3, 'Charlie', 5200, NULL),
    (4, 'Dina',    4500, NULL);
GO

-- 2) Update Department of all employees where Salary > 5000 to 'Management'
UPDATE dbo.Employees
SET Department = 'Management'
WHERE Salary > 5000;
GO

-- 3) Remove all employees but keep table structure intact
-- (Again, TRUNCATE fits perfectly and is efficient.)
TRUNCATE TABLE dbo.Employees;
GO

-- 4) Drop the Department column from Employees
ALTER TABLE dbo.Employees
DROP COLUMN Department;
GO

-- 5) Rename Employees table to StaffMembers
EXEC sys.sp_rename 'dbo.Employees', 'StaffMembers';
GO

-- 6) Completely remove the Departments table from the database
DROP TABLE dbo.Departments;
GO

/* =========================================================
   DONE. You now have:
     - dbo.StaffMembers (empty, columns: EmpID INT, Name VARCHAR(100), Salary FLOAT)
     - Departments table dropped
   ========================================================= */

