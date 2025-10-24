/* =======================
   Puzzle 1: Month with 0
   ======================= */
IF OBJECT_ID('dbo.Dates') IS NOT NULL DROP TABLE dbo.Dates;
CREATE TABLE dbo.Dates ( Id INT, Dt DATETIME );
INSERT INTO dbo.Dates VALUES
(1,'2018-04-06 11:06:43.020'),
(2,'2017-12-06 11:06:43.020'),
(3,'2016-01-06 11:06:43.020'),
(4,'2015-11-06 11:06:43.020'),
(5,'2014-10-06 11:06:43.020');

SELECT
  Id,
  Dt,
  RIGHT('0' + CONVERT(VARCHAR(2), MONTH(Dt)), 2) AS MonthPrefixedWithZero
FROM dbo.Dates
ORDER BY Id;


/* ===========================================
   Puzzle 2: Distinct Ids & SUM of max Vals
   =========================================== */
IF OBJECT_ID('dbo.MyTabel') IS NOT NULL DROP TABLE dbo.MyTabel;
CREATE TABLE dbo.MyTabel ( Id INT, rID INT, Vals INT );
INSERT INTO dbo.MyTabel VALUES
(121, 9, 1), (121, 9, 8),
(122, 9, 14), (122, 9, 0), (122, 9, 1),
(123, 9, 1), (123, 9, 2), (123, 9, 10);

-- Har bir (rID, Id) bo‘yicha MAX(Vals), so‘ng rID bo‘yicha yig‘amiz:
WITH MaxPerId AS (
  SELECT rID, Id, MAX(Vals) AS MaxVals
  FROM dbo.MyTabel
  GROUP BY rID, Id
)
SELECT
  COUNT(*) AS Distinct_Ids,      -- subquerydagi qatorlar soni = distinct Idlar soni
  rID,
  SUM(MaxVals) AS TotalOfMaxVals
FROM MaxPerId
GROUP BY rID;


 /* ===============================================
    Puzzle 3: Length between 6 and 10 (inclusive)
    =============================================== */
IF OBJECT_ID('dbo.TestFixLengths') IS NOT NULL DROP TABLE dbo.TestFixLengths;
CREATE TABLE dbo.TestFixLengths ( Id INT, Vals VARCHAR(100) );
INSERT INTO dbo.TestFixLengths VALUES
(1,'11111111'), (2,'123456'), (2,'1234567'),
(2,'1234567890'), (5,''), (6,NULL),
(7,'123456789012345');

SELECT Id, Vals
FROM dbo.TestFixLengths
WHERE Vals IS NOT NULL
  AND Vals <> ''
  AND LEN(Vals) BETWEEN 6 AND 10
ORDER BY Id, Vals;

