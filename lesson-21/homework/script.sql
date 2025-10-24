
/* Demo: ensure table exists & filled (skip if already done) */
IF OBJECT_ID('dbo.ProductSales') IS NULL
BEGIN
    CREATE TABLE dbo.ProductSales (
        SaleID INT PRIMARY KEY,
        ProductName VARCHAR(50) NOT NULL,
        SaleDate DATE NOT NULL,
        SaleAmount DECIMAL(10, 2) NOT NULL,
        Quantity INT NOT NULL,
        CustomerID INT NOT NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM dbo.ProductSales)
BEGIN
INSERT INTO dbo.ProductSales (SaleID, ProductName, SaleDate, SaleAmount, Quantity, CustomerID) VALUES 
(1, 'Product A', '2023-01-01', 148.00, 2, 101),
(2, 'Product B', '2023-01-02', 202.00, 3, 102),
(3, 'Product C', '2023-01-03', 248.00, 1, 103),
(4, 'Product A', '2023-01-04', 149.50, 4, 101),
(5, 'Product B', '2023-01-05', 203.00, 5, 104),
(6, 'Product C', '2023-01-06', 252.00, 2, 105),
(7, 'Product A', '2023-01-07', 151.00, 1, 101),
(8, 'Product B', '2023-01-08', 205.00, 8, 102),
(9, 'Product C', '2023-01-09', 253.00, 7, 106),
(10, 'Product A', '2023-01-10', 152.00, 2, 107),
(11, 'Product B', '2023-01-11', 207.00, 3, 108),
(12, 'Product C', '2023-01-12', 249.00, 1, 109),
(13, 'Product A', '2023-01-13', 153.00, 4, 110),
(14, 'Product B', '2023-01-14', 208.50, 5, 111),
(15, 'Product C', '2023-01-15', 251.00, 2, 112),
(16, 'Product A', '2023-01-16', 154.00, 1, 113),
(17, 'Product B', '2023-01-17', 210.00, 8, 114),
(18, 'Product C', '2023-01-18', 254.00, 7, 115),
(19, 'Product A', '2023-01-19', 155.00, 3, 116),
(20, 'Product B', '2023-01-20', 211.00, 4, 117),
(21, 'Product C', '2023-01-21', 256.00, 2, 118),
(22, 'Product A', '2023-01-22', 157.00, 5, 119),
(23, 'Product B', '2023-01-23', 213.00, 3, 120),
(24, 'Product C', '2023-01-24', 255.00, 1, 121),
(25, 'Product A', '2023-01-25', 158.00, 6, 122),
(26, 'Product B', '2023-01-26', 215.00, 7, 123),
(27, 'Product C', '2023-01-27', 257.00, 3, 124),
(28, 'Product A', '2023-01-28', 159.50, 4, 125),
(29, 'Product B', '2023-01-29', 218.00, 5, 126),
(30, 'Product C', '2023-01-30', 258.00, 2, 127);
END;


/* 1) Row number per sale by SaleDate */
SELECT
  SaleID, ProductName, SaleDate, SaleAmount,
  ROW_NUMBER() OVER (ORDER BY SaleDate, SaleID) AS RowNumByDate
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;


/* 2) Rank products by total quantity sold (ties share rank, no gaps) */
WITH q AS (
  SELECT ProductName, SUM(Quantity) AS TotalQty
  FROM dbo.ProductSales
  GROUP BY ProductName
)
SELECT
  ProductName, TotalQty,
  DENSE_RANK() OVER (ORDER BY TotalQty DESC) AS DenseRankByQty
FROM q
ORDER BY DenseRankByQty, ProductName;


/* 3) Identify the top sale for each customer (by SaleAmount; ties included) */
WITH r AS (
  SELECT *,
         RANK() OVER (PARTITION BY CustomerID ORDER BY SaleAmount DESC, SaleDate, SaleID) AS rnk
  FROM dbo.ProductSales
)
SELECT CustomerID, SaleID, ProductName, SaleAmount, SaleDate
FROM r
WHERE rnk = 1
ORDER BY CustomerID, SaleID;


/* 4) Each sale with next sale amount by SaleDate */
SELECT
  SaleID, SaleDate, SaleAmount,
  LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextSaleAmount
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;


/* 5) Each sale with previous sale amount by SaleDate */
SELECT
  SaleID, SaleDate, SaleAmount,
  LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevSaleAmount
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;


/* 6) Sales where amount > previous sale's amount (by SaleDate) */
WITH w AS (
  SELECT *,
         LAG(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS PrevAmount
  FROM dbo.ProductSales
)
SELECT SaleID, SaleDate, SaleAmount, PrevAmount
FROM w
WHERE PrevAmount IS NOT NULL AND SaleAmount > PrevAmount
ORDER BY SaleDate, SaleID;


/* 7) Difference from previous sale amount for every product */
SELECT
  ProductName, SaleID, SaleDate, SaleAmount,
  SaleAmount - LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID) AS DiffFromPrevWithinProduct
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;


/* 8) % change vs next sale amount (current -> next) */
SELECT
  SaleID, SaleDate, SaleAmount,
  LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) AS NextSaleAmount,
  CAST(
    100.0 * (LEAD(SaleAmount) OVER (ORDER BY SaleDate, SaleID) - SaleAmount)
    / NULLIF(SaleAmount, 0)
    AS DECIMAL(10,2)
  ) AS PctChange_ToNext
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;


/* 9) Ratio of current sale amount to previous sale amount within same product */
SELECT
  ProductName, SaleID, SaleDate, SaleAmount,
  CAST(
    SaleAmount / NULLIF(LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID), 0)
    AS DECIMAL(18,4)
  ) AS RatioToPrevWithinProduct
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;


/* 10) Difference from the very first sale of that product */
SELECT
  ProductName, SaleID, SaleDate, SaleAmount,
  SaleAmount - FIRST_VALUE(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID
       ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS DiffFromFirstSale
FROM dbo.ProductSales
ORDER BY ProductName, SaleDate, SaleID;


/* 11) Products with continuously increasing sales (strictly increasing by SaleAmount) */
WITH w AS (
  SELECT
    ProductName, SaleID, SaleDate, SaleAmount,
    CASE
      WHEN LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID) IS NULL THEN 0
      WHEN SaleAmount > LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID) THEN 0
      ELSE 1
    END AS Violation
  FROM dbo.ProductSales
),
agg AS (
  SELECT ProductName, SUM(Violation) AS Violations
  FROM w
  GROUP BY ProductName
)
SELECT ProductName
FROM agg
WHERE Violations = 0
ORDER BY ProductName;

-- If you instead want the increasing rows only (not necessarily all rows increasing), use:
-- SELECT ProductName, SaleID, SaleDate, SaleAmount
-- FROM (
--   SELECT *, LAG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID) AS PrevAmt
--   FROM dbo.ProductSales
-- ) x
-- WHERE PrevAmt IS NOT NULL AND SaleAmount > PrevAmt
-- ORDER BY ProductName, SaleDate, SaleID;


/* 12) Closing balance (running total) of sales amounts (overall timeline) */
SELECT
  SaleID, SaleDate, SaleAmount,
  SUM(SaleAmount) OVER (ORDER BY SaleDate, SaleID
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;

-- Per product running total variant:
-- SELECT ProductName, SaleID, SaleDate, SaleAmount,
--        SUM(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID
--            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotalPerProduct
-- FROM dbo.ProductSales
-- ORDER BY ProductName, SaleDate, SaleID;


/* 13) Moving average over the last 3 sales (overall sequence by date) */
SELECT
  SaleID, SaleDate, SaleAmount,
  AVG(SaleAmount) OVER (ORDER BY SaleDate, SaleID
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg_Last3
FROM dbo.ProductSales
ORDER BY SaleDate, SaleID;

-- Per product 3-sale moving average variant:
-- SELECT ProductName, SaleID, SaleDate, SaleAmount,
--        AVG(SaleAmount) OVER (PARTITION BY ProductName ORDER BY SaleDate, SaleID
--            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MovingAvg_Last3_PerProduct
-- FROM dbo.ProductSales
-- ORDER BY ProductName, SaleDate, SaleID;


/* 14) Difference between each sale amount and the average sale amount (overall mean) */
SELECT
  SaleID, SaleDate, SaleAmount,
  SaleAmount - AVG(SaleAmount) OVER () AS DiffFromGlobalAvg
FROM dbo.ProductSales
