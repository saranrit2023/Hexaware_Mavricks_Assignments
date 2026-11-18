----CREATE DATABASE RetailSalesDB;
----GO
----USE RetailSalesDB;
----GO

----CREATE TABLE dbo.customers (
----    customer_id INT IDENTITY(1,1) PRIMARY KEY,
----    first_name NVARCHAR(50) NOT NULL,
----    last_name NVARCHAR(50) NOT NULL,
----    city NVARCHAR(50) NULL, -- Allows NULL to demonstrate NULL behavior in Task 3
----    signup_date DATE NOT NULL
----);

----CREATE TABLE dbo.products (
----    product_id INT IDENTITY(1,1) PRIMARY KEY,
----    product_name NVARCHAR(100) NOT NULL,
----    category NVARCHAR(50) NOT NULL,
----    unit_price DECIMAL(10,2) NOT NULL
----);

----CREATE TABLE dbo.orders (
----    order_id INT IDENTITY(1,1) PRIMARY KEY,
----    customer_id INT NOT NULL REFERENCES dbo.customers(customer_id),
----    order_date DATE NOT NULL,
----    payment_status VARCHAR(20) NULL -- NULL indicates unpaid/missing payment record
----);

----CREATE TABLE dbo.order_items (
----    item_id INT IDENTITY(1,1) PRIMARY KEY,
----    order_id INT NOT NULL REFERENCES dbo.orders(order_id),
----    product_id INT NOT NULL REFERENCES dbo.products(product_id),
----    quantity INT NOT NULL,
----    unit_price DECIMAL(10,2) NOT NULL
----);

------ Seed Sample Data
----INSERT INTO dbo.customers (first_name, last_name, city, signup_date) VALUES
----(N'Aarav', N'Sharma', N'Chennai', '2026-01-10'),
----(N'Priya', N'Nair', N'Mumbai', '2026-02-15'),
----(N'Rohan', N'Verma', N'Bengaluru', '2026-03-01'),
----(N'Sneha', N'Iyer', NULL, '2026-04-12'),       -- NULL city for Task 3
----(N'Vikram', N'Rao', N'Chennai', '2026-05-20');   -- Customer with NO orders

----INSERT INTO dbo.products (product_name, category, unit_price) VALUES
----(N'Laptop Pro 15', N'Electronics', 1000.00),
----(N'Noise-Cancel Headphones', N'Electronics', 200.00),
----(N'Ergonomic Chair', N'Furniture', 350.00),
----(N'Standing Desk', N'Furniture', 500.00),
----(N'Mechanical Keyboard', N'Accessories', 120.00),
----(N'USB-C Dock', N'Accessories', 80.00);

----INSERT INTO dbo.orders (customer_id, order_date, payment_status) VALUES
----(1, '2026-09-10', 'Paid'),
----(1, '2026-09-22', 'Paid'),
----(1, '2026-10-05', 'Paid'),
----(1, '2026-10-18', 'Paid'), -- Customer 1 has 4 orders (> 3)
----(2, '2026-09-10', 'Paid'),
----(2, '2026-10-12', NULL),   -- Unpaid order
----(3, '2026-10-15', 'Paid'),
----(4, '2026-11-02', NULL);   -- Unpaid order

----INSERT INTO dbo.order_items (order_id, product_id, quantity, unit_price) VALUES
----(1, 1, 1, 1000.00), (1, 5, 1, 120.00),
----(2, 2, 2, 200.00),
----(3, 3, 1, 350.00),
----(4, 4, 1, 500.00),  (4, 6, 2, 80.00),
----(5, 1, 2, 1000.00), -- High sales day: 2026-09-10 (Order 1: 1120 + Order 5: 2000 = 3120)
----(6, 2, 1, 200.00),
----(7, 5, 3, 120.00),
----(8, 6, 2, 80.00);


--SELECT TOP 5
--    p.product_id,
--    UPPER(p.product_name) AS product_name,
--    p.category,
--    SUM(oi.quantity) AS units_sold,
--    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue,
--    FORMAT(SUM(oi.quantity * oi.unit_price), 'C', 'en-US') AS formatted_revenue
--FROM dbo.products p
--JOIN dbo.order_items oi ON p.product_id = oi.product_id
--GROUP BY p.product_id, p.product_name, p.category
--ORDER BY total_revenue DESC;

--SELECT 
--    FORMAT(o.order_date, 'yyyy-MM') AS sales_month,
--    COUNT(DISTINCT o.order_id) AS total_orders,
--    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS monthly_sales
--FROM dbo.orders o
--JOIN dbo.order_items oi ON o.order_id = oi.order_id
--GROUP BY FORMAT(o.order_date, 'yyyy-MM')
--ORDER BY sales_month;

--SELECT 
--    c.customer_id,
--    UPPER(CONCAT(c.first_name, ' ', c.last_name)) AS customer_full_name,
--    DATEDIFF(DAY, c.signup_date, '2026-11-17') AS account_age_days,
--    COUNT(o.order_id) AS total_orders
--FROM dbo.customers c
--JOIN dbo.orders o ON c.customer_id = o.customer_id
--GROUP BY c.customer_id, c.first_name, c.last_name, c.signup_date
--HAVING COUNT(o.order_id) > 3;


--WITH OrderTotals AS (
--    SELECT 
--        o.order_id,
--        c.city,
--        SUM(oi.quantity * oi.unit_price) AS basket_value
--    FROM dbo.orders o
--    JOIN dbo.customers c ON o.customer_id = c.customer_id
--    JOIN dbo.order_items oi ON o.order_id = oi.order_id
--    GROUP BY o.order_id, c.city
--)
--SELECT 
--    ISNULL(city, N'Unknown City') AS city,
--    COUNT(order_id) AS order_count,
--    ROUND(AVG(basket_value), 2) AS avg_basket_value
--FROM OrderTotals
--GROUP BY city
--ORDER BY avg_basket_value DESC;

--SELECT 
--    o.order_id,
--    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
--    FORMAT(o.order_date, 'dd-MMM-yyyy') AS formatted_order_date,
--    DATEDIFF(DAY, o.order_date, '2026-11-17') AS days_pending,
--    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS amount_due
--FROM dbo.orders o
--LEFT JOIN dbo.customers c ON o.customer_id = c.customer_id
--LEFT JOIN dbo.order_items oi ON o.order_id = oi.order_id
--WHERE o.payment_status IS NULL
--GROUP BY o.order_id, c.first_name, c.last_name, o.order_date;

--SELECT 
--    c.customer_id,
--    CONCAT(c.first_name, ' ', c.last_name) AS inactive_customer,
--    c.city,
--    DATEDIFF(DAY, c.signup_date, '2026-11-17') AS days_since_signup
--FROM dbo.customers c
--LEFT JOIN dbo.orders o ON c.customer_id = o.customer_id
--WHERE o.order_id IS NULL;

--SELECT 
--    p.category,
--    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue,
--    CONCAT(
--        ROUND(
--            (SUM(oi.quantity * oi.unit_price) * 100.0) / 
--            SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 
--        2), 
--    '%') AS revenue_share_pct
--FROM dbo.products p
--JOIN dbo.order_items oi ON p.product_id = oi.product_id
--GROUP BY p.category
--ORDER BY category_revenue DESC;

--SELECT TOP 1
--    FORMAT(o.order_date, 'yyyy-MM-dd (dddd)') AS peak_sales_day,
--    COUNT(DISTINCT o.order_id) AS orders_placed,
--    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_day_sales
--FROM dbo.orders o
--JOIN dbo.order_items oi ON o.order_id = oi.order_id
--GROUP BY o.order_date
--ORDER BY total_day_sales DESC;
