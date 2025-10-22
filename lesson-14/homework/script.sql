SELECT
  LTRIM(RTRIM(CASE WHEN CHARINDEX(',', Name) > 0
                   THEN LEFT(Name, CHARINDEX(',', Name) - 1)
                   ELSE Name END))     AS [Name],
  LTRIM(RTRIM(CASE WHEN CHARINDEX(',', Name) > 0
                   THEN SUBSTRING(Name, CHARINDEX(',', Name) + 1, LEN(Name))
                   ELSE NULL END))     AS [Surname]
FROM dbo.TestMultipleColumns;

-- Easiest in SQL Server: bracket-escape
SELECT *
FROM dbo.TestPercent
WHERE TheString LIKE '%[%]%';
/* If you prefer ESCAPE:
WHERE TheString LIKE '%!%%' ESCAPE '!'; */
-- SQL Server 2022+ (ordinal aware)
SELECT s.Id, sp.ordinal, sp.value AS Part
FROM dbo.Splitter AS s
CROSS APPLY STRING_SPLIT(s.TheString, '.', 1) AS sp;  -- 1 = enable_ordinal

-- Older versions:
-- CROSS APPLY STRING_SPLIT(s.TheString, '.') AS sp;   -- (no ordinal column)
SELECT *
FROM dbo.testDots
WHERE (LEN(Vals) - LEN(REPLACE(Vals, '.', ''))) > 2;
SELECT
  cs.Id,
  cs.TheString,
  (LEN(cs.TheString) - LEN(REPLACE(cs.TheString, ' ', ''))) AS SpaceCount
FROM dbo.CountSpaces AS cs;
SELECT e.EmployeeID,
       e.FirstName,
       e.LastName,
       e.Salary,
       m.EmployeeID AS ManagerID,
       m.FirstName  AS ManagerFirstName,
       m.LastName   AS ManagerLastName,
       m.Salary     AS ManagerSalary
FROM dbo.Employee AS e
JOIN dbo.Employee AS m
  ON m.EmployeeID = e.ManagerID
WHERE e.Salary > m.Salary;
