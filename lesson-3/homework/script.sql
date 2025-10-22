/* =========================================================
   CLEAN START: drop if exists (safe re-runs)
   ========================================================= */
IF OBJECT_ID('dbo.Products', 'U')   IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
GO

/* =========================================================
   EASY-LEVEL TASKS
   ========================================================= */

-- 3) Create table Products with PK on ProductID
CREATE TABLE dbo.Products
(
    ProductID   INT          NOT NULL PRIMARY KEY,
    ProductName VARCHAR(50)  NOT NULL,
    Price       DECIMAL(10,2) NULL  -- may be NULL initially; we’ll show ISNULL later
);
GO

-- 4) Insert three rows
INSERT INTO dbo.Products (ProductID, ProductName, Price) VALUES
(1, 'Keyboard', 39.99),
(2, 'Mouse',    19.50),
(3, 'Monitor',  199.00);
GO

-- 6) Add UNIQUE constraint to ProductName
ALTER TABLE dbo.Products
ADD CONSTRAINT UQ_Products_ProductName UNIQUE (ProductName);
GO

-- 7) Example comment:
-- This ALTER adds a nullable CategoryID we'll later hook up to Categories via FK.
-- 8) Add CategoryID column
ALTER TABLE dbo.Products
ADD CategoryID INT NULL;
GO

-- 9) Create Categories with PK and UNIQUE CategoryName
CREATE TABLE dbo.Categories
(
    CategoryID   INT          NOT NULL PRIMARY KEY,
    CategoryName VARCHAR(50)  NOT NULL UNIQUE
);
GO

-- 10) (Theory) IDENTITY explanation provided above; if you want one in practice:
-- (Optional demo) Add a surrogate identity PK example table:
IF OBJECT_ID('dbo.DemoIdentity', 'U') IS NOT NULL DROP TABLE dbo.DemoIdentity;
CREATE TABLE dbo.DemoIdentity
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Note VARCHAR(50)
);
INSERT INTO dbo.DemoIdentity (Note) VALUES ('row A'), ('row B'); -- Id auto-increments
GO


/* =========================================================
   MEDIUM-LEVEL TASKS
   ========================================================= */

-- 1) BULK INSERT demo into Products
-- NOTE: BULK INSERT reads from a file accessible to the SQL Server instance.
-- Prepare a CSV like:
--   ProductID,ProductName,Price,CategoryID
--   4,Webcam,75.25,20
--   5,Headset,49.90,10
--   6,USB Hub,15.00,20
--
-- Save it e.g. to: C:\Data\products_load.csv
-- Ensure SQL Server service account has read permission to that path.

-- (Optional) Pre-seed categories that match CSV CategoryIDs so FK won’t fail later
INSERT INTO dbo.Categories (CategoryID, CategoryName) VALUES
(10, 'Peripherals'),
(20, 'Accessories');
GO

-- If your CSV has a header row, set FIRSTROW = 2. Adjust FIELDTERMINATOR/ROWTERMINATOR as needed.
-- If your file only has (ProductID, ProductName, Price, CategoryID) in that order:
BEGIN TRY
    BULK INSERT dbo.Products
    FROM 'C:\Data\products_load.csv'
    WITH
    (
        FORMAT = 'CSV',           -- SQL 2022+ supports FORMAT=CSV. For older versions, comment this and use FIELDTERMINATOR/ROWTERMINATOR.
        FIRSTROW = 2              -- skip header
        -- FIELDTERMINATOR = ',', -- use these on older versions without FORMAT=CSV
        -- ROWTERMINATOR   = '\n'
    );
END TRY
BEGIN CATCH
    -- If FORMAT=CSV isn’t supported on your version, retry legacy style:
    PRINT 'FORMAT=CSV not supported here. Retrying legacy BULK INSERT...';
    BULK INSERT dbo.Products
    FROM 'C:\Data\products_load.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        TABLOCK
    );
END CATCH;
GO

-- 2) Create FOREIGN KEY Products.CategoryID -> Categories.CategoryID
-- First make sure existing CategoryIDs are valid or NULL; then add FK:
ALTER TABLE dbo.Products
WITH CHECK ADD CONSTRAINT FK_Products_Categories
FOREIGN KEY (CategoryID) REFERENCES dbo.Categories(CategoryID);
GO

-- 3) Explain PRIMARY KEY vs UNIQUE KEY (theory in text above).

-- 4) Add CHECK constraint ensuring Price > 0 (allow NULLs but if not NULL must be > 0)
ALTER TABLE dbo.Products
ADD CONSTRAINT CK_Products_Price_Positive CHECK (Price IS NULL OR Price > 0);
GO

-- 5) Add Stock INT NOT NULL safely for existing rows (use default + WITH VALUES)
ALTER TABLE dbo.Products
ADD Stock INT NOT NULL CONSTRAINT DF_Products_Stock DEFAULT (0) WITH VALUES;
GO

-- 6) Use ISNULL to replace NULL Price with 0 (persistently via UPDATE)
UPDATE dbo.Products
SET Price = ISNULL(Price, 0.00);
GO

-- 7) Describe purpose/usage of FOREIGN KEY (theory above).
--    (Practical hint: try deleting a parent category to see FK behavior; default is NO ACTION.)

/* =========================================================
   QUICK CHECKS (optional)
   ========================================================= */
-- See what we’ve got:
SELECT TOP (100) * FROM dbo.Categories ORDER BY CategoryID;
SELECT TOP (100) * FROM dbo.Products ORDER BY ProductID;
GO

