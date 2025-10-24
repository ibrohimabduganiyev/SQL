/* =========================================================
   Demo setup from your prompt (temp table #Sales)
========================================================= */
IF OBJECT_ID('tempdb..#Sales') IS NOT NULL DROP TABLE #Sales;
CREATE TABLE #Sales (
    SaleID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100),
    Product VARCHAR(100),
    Quantity INT,
    Price DECIMAL(10,2),
    SaleDate DATE
);
INSERT INTO #Sales (CustomerName, Product, Quantity, Price, SaleDate) VALUES
('Alice', 'Laptop', 1, 1200.00, '2024-01-15'),
('Bob', 'Smartphone', 2, 800.00, '2024-02-10'),
('Charlie', 'Tablet', 1, 500.00, '2024-02-20'),
('David', 'Laptop', 1, 1300.00, '2024-03-05'),
('Eve', 'Smartphone', 3, 750.00, '2024-03-12'),
('Frank', 'Headphones', 2, 100.00, '2024-04-08'),
('Grace', 'Smartwatch', 1, 300.00, '2024-04-25'),
('Hannah', 'Tablet', 2, 480.00, '2024-05-05'),
('Isaac', 'Laptop', 1, 1250.00, '2024-05-15'),
('Jack', 'Smartphone', 1, 820.00, '2024-06-01');


/* =========================================================
   1) Customers who purchased at least one item in March 2024 (EXISTS)
========================================================= */
SELECT DISTINCT s1.CustomerName
FROM #Sales AS s1
WHERE EXISTS (
    SELECT 1
    FROM #Sales AS s2
    WHERE s2.CustomerName = s1.CustomerName
      AND s2.SaleDate >= '2024-03-01'
      AND s2.SaleDate <  '2024-04-01'
)
ORDER BY s1.CustomerName;


/* =========================================================
   2) Product with the highest total sales revenue (subquery)
   Revenue = SUM(Quantity * Price). If ties exist, returns all.
========================================================= */
WITH ProdRevenue AS (
    SELECT
        Product,
        SUM(CAST(Quantity AS DECIMAL(18,2)) * Price) AS TotalRevenue
    FROM #Sales
    GROUP BY Product
)
SELECT Product, TotalRevenue
FROM ProdRevenue
WHERE TotalRevenue = (
    SELECT MAX(TotalRevenue) FROM ProdRevenue
);


/* =========================================================
   3) Second highest sale amount (subquery)
   Sale amount is per row: Quantity * Price; distinct second max.
========================================================= */
SELECT MAX(Amount) AS SecondHighestAmount
FROM (
    SELECT DISTINCT CAST(Quantity AS DECIMAL(18,2)) * Price AS Amount
    FROM #Sales
) d
WHERE Amount < (SELECT MAX(CAST(Quantity AS DECIMAL(18,2)) * Price) FROM #Sales);


/* =========================================================
   4) Total quantity of products sold per month (subquery)
   Returns MonthStart + TotalQty
========================================================= */
SELECT
    DATEFROMPARTS(YEAR(s.SaleDate), MONTH(s.SaleDate), 1) AS MonthStart,
    (SELECT SUM(s2.Quantity)
     FROM #Sales s2
     WHERE YEAR(s2.SaleDate) = YEAR(s.SaleDate)
       AND MONTH(s2.SaleDate) = MONTH(s.SaleDate)
    ) AS TotalQuantity
FROM #Sales s
GROUP BY DATEFROMPARTS(YEAR(s.SaleDate), MONTH(s.SaleDate), 1)
ORDER BY MonthStart;


/* =========================================================
   5) Customers who bought same products as another customer (EXISTS)
   Returns customers for whom there exists a different customer with same product.
========================================================= */
SELECT DISTINCT s1.CustomerName
FROM #Sales s1
WHERE EXISTS (
    SELECT 1
    FROM #Sales s2
    WHERE s2.Product = s1.Product
      AND s2.CustomerName <> s1.CustomerName
)
ORDER BY s1.CustomerName;


/* =========================================================
   6) "How many fruits does each person have in individual fruit level"
   Assumption: we have a basket with (Person, Fruit, Qty).
   a) Total fruits per person (sum of quantities)
   b) Individual fruit level (expand each quantity to individual rows)
========================================================= */

-- Demo basket
IF OBJECT_ID('tempdb..#Basket') IS NOT NULL DROP TABLE #Basket;
CREATE TABLE #Basket (Person VARCHAR(50), Fruit VARCHAR(50), Qty INT);
INSERT INTO #Basket(Person, Fruit, Qty) VALUES
('Alice','Apple', 2), ('Alice','Banana',1),
('Bob','Orange',3),
('Charlie','Grapes',2), ('Charlie','Apple',1);

-- (a) How many fruits each person has (total count)
SELECT Person, SUM(Qty) AS TotalFruits
FROM #Basket
GROUP BY Person
ORDER BY Person;

-- (b) Individual fruit level expansion using a Tally (recursive CTE)
;WITH Tally AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM Tally WHERE n < 1000 -- upper bound for max Qty
),
Expanded AS (
    SELECT b.Person, b.Fruit, t.n
    FROM #Basket b
    JOIN Tally t
      ON t.n <= b.Qty
)
SELECT Person, COUNT(*) AS FruitsAtIndividualLevel
FROM Expanded
GROUP BY Person
ORDER BY Person
OPTION (MAXRECURSION 0);

-- If you want the actual individual rows (one row per fruit unit), run:
-- SELECT Person, Fruit FROM Expanded ORDER BY Person, Fruit, n;

