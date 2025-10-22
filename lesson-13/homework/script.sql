/* 1) Output "emp_id-first_name last_name" e.g., "100-Steven King" (Employees) */
SELECT CONCAT(e.emp_id, '-', e.first_name, ' ', e.last_name) AS EmpLine
FROM dbo.Employees AS e;

/* 2) Replace substring '124' -> '999' inside phone_number (Employees) */
UPDATE dbo.Employees
SET phone_number = REPLACE(phone_number, '124', '999');
/* 3) First name + its length for names starting with A/J/M; order by first name */
SELECT 
  e.first_name AS FirstName,
  LEN(e.first_name) AS FirstNameLength
FROM dbo.Employees AS e
WHERE e.first_name LIKE '[AJM]%'
ORDER BY e.first_name ASC;
/* 4) Total salary for each manager_id (Employees) */
SELECT 
  e.manager_id,
  SUM(e.salary) AS TotalSalary
FROM dbo.Employees AS e
GROUP BY e.manager_id;
/* 5) For each row: year + highest of (Max1, Max2, Max3) (TestMax)
   Works on all supported SQL Server versions via CROSS APPLY */
SELECT t.[Year],
       MAX(v.mx) AS HighestValue
FROM dbo.TestMax AS t
CROSS APPLY (VALUES (t.Max1), (t.Max2), (t.Max3)) AS v(mx)
GROUP BY t.[Year];
/* (On SQL Server 2022+, you could also: SELECT [Year], GREATEST(Max1,Max2,Max3) AS HighestValue FROM dbo.TestMax; ) */
/* 6) Odd-numbered movies AND description is not 'boring' (Cinema) */
SELECT *
FROM dbo.Cinema AS c
WHERE c.id % 2 = 1
  AND c.[description] <> 'boring';
/* 7) Sort by Id ascending, but Id = 0 must always be last (SingleOrder)
   Single ORDER BY expression solution */
SELECT *
FROM dbo.SingleOrder
ORDER BY IIF(Id = 0, 2147483647, Id);  -- pushes zeros to the end while preserving numeric order
/* 8) Select first non-NULL value among several columns, else NULL (Person)
   Example with columns: phone_home, phone_work, phone_mobile */
SELECT 
  p.person_id,
  COALESCE(p.phone_home, p.phone_work, p.phone_mobile) AS FirstNonNullPhone
FROM dbo.Person AS p;
/* Replace column list with your actual columns; COALESCE returns the first non-NULL. */
