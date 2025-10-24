/* =========================================================
   Demo setup (drop & recreate to be idempotent)
========================================================= */
IF OBJECT_ID('dbo.sales_data') IS NOT NULL DROP TABLE dbo.sales_data;
GO
CREATE TABLE dbo.sales_data (
    sale_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(100),
    product_category VARCHAR(50),
    product_name VARCHAR(100),
    quantity_sold INT,
    unit_price DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    order_date DATE,
    region VARCHAR(50)
);
INSERT INTO dbo.sales_data VALUES
(1, 101, 'Alice', 'Electronics', 'Laptop', 1, 1200.00, 1200.00, '2024-01-01', 'North'),
(2, 102, 'Bob', 'Electronics', 'Phone', 2, 600.00, 1200.00, '2024-01-02', 'South'),
(3, 103, 'Charlie', 'Clothing', 'T-Shirt', 5, 20.00, 100.00, '2024-01-03', 'East'),
(4, 104, 'David', 'Furniture', 'Table', 1, 250.00, 250.00, '2024-01-04', 'West'),
(5, 105, 'Eve', 'Electronics', 'Tablet', 1, 300.00, 300.00, '2024-01-05', 'North'),
(6, 106, 'Frank', 'Clothing', 'Jacket', 2, 80.00, 160.00, '2024-01-06', 'South'),
(7, 107, 'Grace', 'Electronics', 'Headphones', 3, 50.00, 150.00, '2024-01-07', 'East'),
(8, 108, 'Hank', 'Furniture', 'Chair', 4, 75.00, 300.00, '2024-01-08', 'West'),
(9, 109, 'Ivy', 'Clothing', 'Jeans', 1, 40.00, 40.00, '2024-01-09', 'North'),
(10, 110, 'Jack', 'Electronics', 'Laptop', 2, 1200.00, 2400.00, '2024-01-10', 'South'),
(11, 101, 'Alice', 'Electronics', 'Phone', 1, 600.00, 600.00, '2024-01-11', 'North'),
(12, 102, 'Bob', 'Furniture', 'Sofa', 1, 500.00, 500.00, '2024-01-12', 'South'),
(13, 103, 'Charlie', 'Electronics', 'Camera', 1, 400.00, 400.00, '2024-01-13', 'East'),
(14, 104, 'David', 'Clothing', 'Sweater', 2, 60.00, 120.00, '2024-01-14', 'West'),
(15, 105, 'Eve', 'Furniture', 'Bed', 1, 800.00, 800.00, '2024-01-15', 'North'),
(16, 106, 'Frank', 'Electronics', 'Monitor', 1, 200.00, 200.00, '2024-01-16', 'South'),
(17, 107, 'Grace', 'Clothing', 'Scarf', 3, 25.00, 75.00, '2024-01-17', 'East'),
(18, 108, 'Hank', 'Furniture', 'Desk', 1, 350.00, 350.00, '2024-01-18', 'West'),
(19, 109, 'Ivy', 'Electronics', 'Speaker', 2, 100.00, 200.00, '2024-01-19', 'North'),
(20, 110, 'Jack', 'Clothing', 'Shoes', 1, 90.00, 90.00, '2024-01-20', 'South'),
(21, 111, 'Kevin', 'Electronics', 'Mouse', 3, 25.00, 75.00, '2024-01-21', 'East'),
(22, 112, 'Laura', 'Furniture', 'Couch', 1, 700.00, 700.00, '2024-01-22', 'West'),
(23, 113, 'Mike', 'Clothing', 'Hat', 4, 15.00, 60.00, '2024-01-23', 'North'),
(24, 114, 'Nancy', 'Electronics', 'Smartwatch', 1, 250.00, 250.00, '2024-01-24', 'South'),
(25, 115, 'Oscar', 'Furniture', 'Wardrobe', 1, 1000.00, 1000.00, '2024-01-25', 'East');
GO


/* =========================
   1) Running total per customer
========================= */
SELECT
  customer_id, customer_name, sale_id, order_date, total_amount,
  SUM(total_amount) OVER (
    PARTITION BY customer_id
    ORDER BY order_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS running_total_customer
FROM dbo.sales_data
ORDER BY customer_id, order_date, sale_id;


/* ============================================
   2) Number of orders per product category
============================================ */
SELECT
  product_category,
  COUNT(*) AS order_count
FROM dbo.sales_data
GROUP BY product_category
ORDER BY product_category;


/* ============================================
   3) Max total_amount per product category
============================================ */
SELECT
  product_category,
  MAX(total_amount) AS max_total_amount
FROM dbo.sales_data
GROUP BY product_category
ORDER BY product_category;


/* ============================================
   4) Min unit_price per product category
============================================ */
SELECT
  product_category,
  MIN(unit_price) AS min_unit_price
FROM dbo.sales_data
GROUP BY product_category
ORDER BY product_category;


/* ==========================================================
   5) 3-kunlik (prev, curr, next) moving average by calendar day
      (avval kunlik sotuvni jamlaymiz, keyin oynani qo‘llaymiz)
========================================================== */
WITH daily AS (
  SELECT
    order_date,
    SUM(total_amount) AS day_sales
  FROM dbo.sales_data
  GROUP BY order_date
)
SELECT
  order_date,
  day_sales,
  AVG(day_sales) OVER (
    ORDER BY order_date
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
  ) AS moving_avg_3day
FROM daily
ORDER BY order_date;


/* =========================
   6) Total sales per region
========================= */
SELECT
  region,
  SUM(total_amount) AS total_sales
FROM dbo.sales_data
GROUP BY region
ORDER BY region;


/* =======================================================
   7) Rank customers by total purchase (ties => same rank)
======================================================= */
WITH totals AS (
  SELECT customer_id, customer_name, SUM(total_amount) AS total_purchase
  FROM dbo.sales_data
  GROUP BY customer_id, customer_name
)
SELECT
  customer_id,
  customer_name,
  total_purchase,
  DENSE_RANK() OVER (ORDER BY total_purchase DESC) AS purchase_rank
FROM totals
ORDER BY purchase_rank, customer_id;


/* ==========================================================
   8) Diff between current and previous sale amount per customer
========================================================== */
SELECT
  customer_id, customer_name, sale_id, order_date, total_amount,
  total_amount
  - LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, sale_id
    ) AS diff_from_prev_amount
FROM dbo.sales_data
ORDER BY customer_id, order_date, sale_id;


/* ==========================================================
   9) Top-3 most expensive products in each category (by unit_price)
      (avval product_name bo‘yicha eng katta unit_price ni olamiz)
========================================================== */
WITH prod_prices AS (
  SELECT
    product_category,
    product_name,
    MAX(unit_price) AS max_unit_price
  FROM dbo.sales_data
  GROUP BY product_category, product_name
),
ranked AS (
  SELECT
    product_category,
    product_name,
    max_unit_price,
    DENSE_RANK() OVER (
      PARTITION BY product_category
      ORDER BY max_unit_price DESC, product_name
    ) AS dr
  FROM prod_prices
)
SELECT product_category, product_name, max_unit_price
FROM ranked
WHERE dr <= 3
ORDER BY product_category, dr, product_name;


/* ===========================================================================
   10) Cumulative sum of sales per region by order_date (regional running total)
       (avval region+date bo‘yicha kunlik jam, so‘ng oyna bilan to‘playmiz)
=========================================================================== */
WITH region_daily AS (
  SELECT region, order_date, SUM(total_amount) AS day_sales
  FROM dbo.sales_data
  GROUP BY region, order_date
)
SELECT
  region,
  order_date,
  day_sales,
  SUM(day_sales) OVER (
    PARTITION BY region
    ORDER BY order_date
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS cumulative_sales_region
FROM region_daily
ORDER BY region, order_date;

