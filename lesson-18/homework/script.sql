/* =========================================================
   DEMO SETUP (Products, Sales) — skip if already created
========================================================= */
IF OBJECT_ID('dbo.Products') IS NULL
BEGIN
    CREATE TABLE Products (
        ProductID INT PRIMARY KEY,
        ProductName VARCHAR(100),
        Category VARCHAR(50),
        Price DECIMAL(10,2)
    );
END;
IF OBJECT_ID('dbo.Sales') IS NULL
BEGIN
    CREATE TABLE Sales (
        SaleID INT PRIMARY KEY,
        ProductID INT,
        Quantity INT,
        SaleDate DATE,
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    );
END;

IF NOT EXISTS (SELECT 1 FROM Products)
BEGIN
    INSERT INTO Products (ProductID, ProductName, Category, Price) VALUES
    (1, 'Samsung Galaxy S23', 'Electronics', 899.99),
    (2, 'Apple iPhone 14', 'Electronics', 999.99),
    (3, 'Sony WH-1000XM5 Headphones', 'Electronics', 349.99),
    (4, 'Dell XPS 13 Laptop', 'Electronics', 1249.99),
    (5, 'Organic Eggs (12 pack)', 'Groceries', 3.49),
    (6, 'Whole Milk (1 gallon)', 'Groceries', 2.99),
    (7, 'Alpen Cereal (500g)', 'Groceries', 4.75),
    (8, 'Extra Virgin Olive Oil (1L)', 'Groceries', 8.99),
    (9, 'Mens Cotton T-Shirt', 'Clothing', 12.99),
    (10, 'Womens Jeans - Blue', 'Clothing', 39.99),
    (11, 'Unisex Hoodie - Grey', 'Clothing', 29.99),
    (12, 'Running Shoes - Black', 'Clothing', 59.95),
    (13, 'Ceramic Dinner Plate Set (6 pcs)', 'Home & Kitchen', 24.99),
    (14, 'Electric Kettle - 1.7L', 'Home & Kitchen', 34.90),
    (15, 'Non-stick Frying Pan - 28cm', 'Home & Kitchen', 18.50),
    (16, 'Atomic Habits - James Clear', 'Books', 15.20),
    (17, 'Deep Work - Cal Newport', 'Books', 14.35),
    (18, 'Rich Dad Poor Dad - Robert Kiyosaki', 'Books', 11.99),
    (19, 'LEGO City Police Set', 'Toys', 49.99),
    (20, 'Rubiks Cube 3x3', 'Toys', 7.99);
END;

IF NOT EXISTS (SELECT 1 FROM Sales)
BEGIN
    INSERT INTO Sales (SaleID, ProductID, Quantity, SaleDate) VALUES
    (1, 1, 2, '2025-04-01'),
    (2, 1, 1, '2025-04-05'),
    (3, 2, 1, '2025-04-10'),
    (4, 2, 2, '2025-04-15'),
    (5, 3, 3, '2025-04-18'),
    (6, 3, 1, '2025-04-20'),
    (7, 4, 2, '2025-04-21'),
    (8, 5, 10, '2025-04-22'),
    (9, 6, 5, '2025-04-01'),
    (10, 6, 3, '2025-04-11'),
    (11, 10, 2, '2025-04-08'),
    (12, 12, 1, '2025-04-12'),
    (13, 12, 3, '2025-04-14'),
    (14, 19, 2, '2025-04-05'),
    (15, 20, 4, '2025-04-19'),
    (16, 1, 1, '2025-03-15'),
    (17, 2, 1, '2025-03-10'),
    (18, 5, 5, '2025-02-20'),
    (19, 6, 6, '2025-01-18'),
    (20, 10, 1, '2024-12-25'),
    (21, 1, 1, '2024-04-20');
END;

/* =========================================================
   1) TEMP TABLE: MonthlySales (current month totals)
   Return: ProductID, TotalQuantity, TotalRevenue
========================================================= */
IF OBJECT_ID('tempdb..#MonthlySales') IS NOT NULL
    DROP TABLE #MonthlySales;

CREATE TABLE #MonthlySales (
    ProductID INT PRIMARY KEY,
    TotalQuantity INT NOT NULL,
    TotalRevenue DECIMAL(18,2) NOT NULL
);

DECLARE @StartOfMonth DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @EndOfMonth   DATE = EOMONTH(GETDATE());

INSERT INTO #MonthlySales (ProductID, TotalQuantity, TotalRevenue)
SELECT
    p.ProductID,
    COALESCE(SUM(s.Quantity), 0) AS TotalQuantity,
    COALESCE(SUM(CAST(s.Quantity AS DECIMAL(18,2)) * p.Price), 0.00) AS TotalRevenue
FROM Products p
LEFT JOIN Sales s
       ON s.ProductID = p.ProductID
      AND s.SaleDate >= @StartOfMonth
      AND s.SaleDate <= @EndOfMonth
GROUP BY p.ProductID;

-- View MonthlySales result
SELECT * FROM #MonthlySales ORDER BY ProductID;

/* =========================================================
   2) VIEW: vw_ProductSalesSummary
   Return: ProductID, ProductName, Category, TotalQuantitySold
========================================================= */
IF OBJECT_ID('dbo.vw_ProductSalesSummary', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ProductSalesSummary;
GO
CREATE VIEW dbo.vw_ProductSalesSummary
AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,
    COALESCE(SUM(s.Quantity), 0) AS TotalQuantitySold
FROM Products p
LEFT JOIN Sales s
       ON s.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category;
GO

-- View usage example
SELECT * FROM dbo.vw_ProductSalesSummary ORDER BY ProductID;

/* =========================================================
   3) SCALAR FUNCTION: fn_GetTotalRevenueForProduct(@ProductID)
   Return: DECIMAL(18,2) — total revenue for the product
========================================================= */
IF OBJECT_ID('dbo.fn_GetTotalRevenueForProduct', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetTotalRevenueForProduct;
GO
CREATE FUNCTION dbo.fn_GetTotalRevenueForProduct (@ProductID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Total DECIMAL(18,2);
    SELECT @Total = COALESCE(SUM(CAST(s.Quantity AS DECIMAL(18,2)) * p.Price), 0.00)
    FROM Products p
    LEFT JOIN Sales s ON s.ProductID = p.ProductID
    WHERE p.ProductID = @ProductID;

    RETURN COALESCE(@Total, 0.00);
END;
GO

-- Usage example:
-- SELECT dbo.fn_GetTotalRevenueForProduct(1) AS TotalRevenue_For_Product1;

/* =========================================================
   4) INLINE TVF: fn_GetSalesByCategory(@Category)
   Return: ProductName, TotalQuantity, TotalRevenue
========================================================= */
IF OBJECT_ID('dbo.fn_GetSalesByCategory', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_GetSalesByCategory;
GO
CREATE FUNCTION dbo.fn_GetSalesByCategory (@Category VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.ProductName,
        COALESCE(SUM(s.Quantity), 0) AS TotalQuantity,
        COALESCE(SUM(CAST(s.Quantity AS DECIMAL(18,2)) * p.Price), 0.00) AS TotalRevenue
    FROM Products p
    LEFT JOIN Sales s
           ON s.ProductID = p.ProductID
    WHERE p.Category = @Category
    GROUP BY p.ProductName, p.Price
);
GO

-- Usage example:
-- SELECT * FROM dbo.fn_GetSalesByCategory('Electronics') ORDER BY ProductName;

