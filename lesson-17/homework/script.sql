--------------------------------------------------------
-- 1) REPORT: ALL DISTRIBUTORS & REGIONS (MISSING = 0)
--------------------------------------------------------
DROP TABLE IF EXISTS #RegionSales;
CREATE TABLE #RegionSales (
  Region      VARCHAR(100),
  Distributor VARCHAR(100),
  Sales       INTEGER NOT NULL,
  PRIMARY KEY (Region, Distributor)
);
INSERT INTO #RegionSales (Region, Distributor, Sales) VALUES
('North','ACE',10), ('South','ACE',67), ('East','ACE',54),
('North','ACME',65), ('South','ACME',9), ('East','ACME',1), ('West','ACME',7),
('North','Direct Parts',8), ('South','Direct Parts',7), ('West','Direct Parts',12);

WITH Regions AS (
  SELECT DISTINCT Region FROM #RegionSales
),
Distributors AS (
  SELECT DISTINCT Distributor FROM #RegionSales
),
AllCombos AS (
  SELECT r.Region, d.Distributor
  FROM Regions r
  CROSS JOIN Distributors d
)
SELECT
  a.Region,
  a.Distributor,
  COALESCE(rs.Sales, 0) AS Sales
FROM AllCombos a
LEFT JOIN #RegionSales rs
  ON rs.Region = a.Region
 AND rs.Distributor = a.Distributor
ORDER BY a.Distributor,
  CASE a.Region WHEN 'North' THEN 1 WHEN 'South' THEN 2 WHEN 'East' THEN 3 WHEN 'West' THEN 4 ELSE 5 END;


--------------------------------------------------------
-- 2) MANAGERS WITH ≥ 5 DIRECT REPORTS
--------------------------------------------------------
CREATE TABLE Employee (id INT, name VARCHAR(255), department VARCHAR(255), managerId INT);
TRUNCATE TABLE Employee;
INSERT INTO Employee VALUES
(101, 'John', 'A', NULL), (102, 'Dan', 'A', 101), (103, 'James', 'A', 101),
(104, 'Amy', 'A', 101), (105, 'Anne', 'A', 101), (106, 'Ron', 'B', 101);

SELECT m.name
FROM Employee AS m
JOIN (
  SELECT managerId
  FROM Employee
  WHERE managerId IS NOT NULL
  GROUP BY managerId
  HAVING COUNT(*) >= 5
) x
  ON x.managerId = m.id;


--------------------------------------------------------
-- 3) CUSTOMER -> VENDOR WITH HIGHEST ORDER COUNT
--------------------------------------------------------
DROP TABLE IF EXISTS Orders;
CREATE TABLE Orders (
  OrderID    INTEGER PRIMARY KEY,
  CustomerID INTEGER NOT NULL,
  [Count]    MONEY NOT NULL,
  Vendor     VARCHAR(100) NOT NULL
);
INSERT INTO Orders VALUES
(1,1001,12,'Direct Parts'), (2,1001,54,'Direct Parts'), (3,1001,32,'ACME'),
(4,2002,7,'ACME'), (5,2002,16,'ACME'), (6,2002,5,'Direct Parts');

WITH S AS (
  SELECT CustomerID, Vendor, SUM([Count]) AS TotalCnt
  FROM Orders
  GROUP BY CustomerID, Vendor
),
R AS (
  SELECT
    CustomerID,
    Vendor,
    TotalCnt,
    ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TotalCnt DESC) AS rn
  FROM S
)
SELECT CustomerID, Vendor
FROM R
WHERE rn = 1
ORDER BY CustomerID;


--------------------------------------------------------
-- 4) CHECK PRIME NUMBER USING WHILE
--------------------------------------------------------
DECLARE @Check_Prime INT = 91;
DECLARE @i INT = 2;
DECLARE @isPrime BIT = 1;

IF @Check_Prime <= 1
  SET @isPrime = 0;
ELSE
BEGIN
  WHILE (@i * @i) <= @Check_Prime
  BEGIN
    IF (@Check_Prime % @i = 0)
    BEGIN
      SET @isPrime = 0;
      BREAK;
    END
    SET @i = @i + CASE WHEN @i = 2 THEN 1 ELSE 2 END;
  END
END

SELECT CASE WHEN @isPrime = 1
            THEN 'This number is prime'
            ELSE 'This number is not prime'
       END AS Result;


--------------------------------------------------------
-- 5) DEVICE STATS: LOCATIONS COUNT, MAX LOCATION, TOTAL SIGNALS
--------------------------------------------------------
CREATE TABLE Device(
  Device_id INT,
  Locations VARCHAR(25)
);
INSERT INTO Device VALUES
(12,'Bangalore'), (12,'Bangalore'), (12,'Bangalore'), (12,'Bangalore'),
(12,'Hosur'), (12,'Hosur'),
(13,'Hyderabad'), (13,'Hyderabad'), (13,'Secunderabad'),
(13,'Secunderabad'), (13,'Secunderabad');

WITH loc_counts AS (
  SELECT Device_id, Locations, COUNT(*) AS cnt
  FROM Device
  GROUP BY Device_id, Locations
),
ranked AS (
  SELECT Device_id, Locations, cnt,
         ROW_NUMBER() OVER (PARTITION BY Device_id ORDER BY cnt DESC) AS rn
  FROM loc_counts
),
totals AS (
  SELECT Device_id,
         COUNT(DISTINCT Locations) AS no_of_location,
         COUNT(*) AS no_of_signals
  FROM Device
  GROUP BY Device_id
)
SELECT
  t.Device_id,
  t.no_of_location,
  r.Locations AS max_signal_location,
  t.no_of_signals
FROM totals t
JOIN ranked r ON r.Device_id = t.Device_id AND r.rn = 1
ORDER BY t.Device_id;
