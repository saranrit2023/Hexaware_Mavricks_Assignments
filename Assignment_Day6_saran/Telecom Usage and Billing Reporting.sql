------CREATE DATABASE TelecomBillingDB;

------USE TelecomBillingDB;

------CREATE TABLE dbo.plans (
------    plan_id INT IDENTITY(1,1) PRIMARY KEY,
------    plan_name NVARCHAR(50) NOT NULL UNIQUE,
------    monthly_fee DECIMAL(10,2) NOT NULL,
------    data_limit_gb DECIMAL(6,2) NOT NULL
------);

------CREATE TABLE dbo.subscribers (
------    subscriber_id INT IDENTITY(1,1) PRIMARY KEY,
------    full_name NVARCHAR(100) NOT NULL,
------    phone_number VARCHAR(15) NOT NULL UNIQUE,
------    circle NVARCHAR(50) NOT NULL,
------    plan_id INT NOT NULL REFERENCES dbo.plans(plan_id)
------);

------CREATE TABLE dbo.call_records (
------    record_id INT IDENTITY(1,1) PRIMARY KEY,
------    subscriber_id INT NOT NULL REFERENCES dbo.subscribers(subscriber_id),
------    call_date DATE NOT NULL,
------    duration_mins INT NOT NULL,
------    data_used_gb DECIMAL(6,2) NOT NULL
------);

------CREATE TABLE dbo.invoices (
------    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
------    subscriber_id INT NOT NULL REFERENCES dbo.subscribers(subscriber_id),
------    billing_month DATE NOT NULL, -- Stored as first day of billing month
------    due_date DATE NOT NULL,
------    amount DECIMAL(10,2) NOT NULL,
------    paid_date DATE NULL
------);

------INSERT INTO dbo.plans (plan_name, monthly_fee, data_limit_gb) VALUES
------(N'Basic 299',      299.00,  15.00),
------(N'Super 599',      599.00,  50.00),
------(N'Unlimited 999',  999.00, 150.00);

------INSERT INTO dbo.subscribers (full_name, phone_number, circle, plan_id) VALUES
------(N'Arjun Nair',     '9840100001', N'Tamil Nadu',  2),
------(N'Priya Sharma',   '9840100002', N'Maharashtra', 3),
------(N'Karthik Rao',    '9840100003', N'Karnataka',   1),
------(N'Sneha Verma',    '9840100004', N'Tamil Nadu',  2),
------(N'Vikram Menon',   '9840100005', N'Maharashtra', 1), 
------(N'Divya Iyer',     '9840100006', N'Karnataka',   3),
------(N'Rohan Das',      '9840100007', N'Tamil Nadu',  2),
------(N'Meera Pillai',   '9840100008', N'Maharashtra', 1),
------(N'Siddharth Jain', '9840100009', N'Karnataka',   2),
------(N'Ananya Sen',     '9840100010', N'Tamil Nadu',  3),
------(N'Rahul Bose',     '9840100011', N'Karnataka',   1); 

------INSERT INTO dbo.call_records (subscriber_id, call_date, duration_mins, data_used_gb) VALUES
------(1, '2026-10-05', 120, 32.50),
------(1, '2026-10-20',  95, 24.00), 
------(2, '2026-10-12', 310, 88.00),
------(3, '2026-10-15',  80, 18.20), 
------(4, '2026-10-18', 150, 41.00),
------(6, '2026-10-22', 240, 110.50),
------(7, '2026-11-02',  60, 12.00),
------(8, '2026-11-04',  45,  9.50),
------(9, '2026-11-06', 110, 27.30),
------(10,'2026-11-08', 200, 65.00);

------INSERT INTO dbo.invoices (subscriber_id, billing_month, due_date, amount, paid_date) VALUES
------(1, '2026-09-01', '2026-09-20', 649.00, '2026-09-18'),
------(2, '2026-09-01', '2026-09-20', 999.00, '2026-09-19'),
------(3, '2026-09-01', '2026-09-20', 349.00, NULL),       
------(1, '2026-10-01', '2026-10-20', 699.00, '2026-10-20'),
------(2, '2026-10-01', '2026-10-20', 999.00, NULL),      
------(4, '2026-10-01', '2026-10-20', 599.00, '2026-10-15'),
------(6, '2026-10-01', '2026-10-20', 999.00, '2026-10-19'),
------(7, '2026-11-01', '2026-11-20', 599.00, NULL);       

----SELECT 
----    UPPER(p.plan_name) AS plan_name,
----    ISNULL(SUM(cr.duration_mins), 0) AS total_call_minutes
----FROM dbo.plans p
----LEFT JOIN dbo.subscribers s ON p.plan_id = s.plan_id
----LEFT JOIN dbo.call_records cr ON s.subscriber_id = cr.subscriber_id
----GROUP BY p.plan_name
----ORDER BY total_call_minutes DESC;

----SELECT 
----    s.subscriber_id,
----    s.full_name,
----    s.phone_number,
----    p.plan_name,
----    p.data_limit_gb,
----    SUM(cr.data_used_gb) AS total_data_used_gb,
----    SUM(cr.data_used_gb) - p.data_limit_gb AS excess_data_gb
----FROM dbo.subscribers s
----JOIN dbo.plans p ON s.plan_id = p.plan_id
----JOIN dbo.call_records cr ON s.subscriber_id = cr.subscriber_id
----GROUP BY s.subscriber_id, s.full_name, s.phone_number, p.plan_name, p.data_limit_gb
----HAVING SUM(cr.data_used_gb) > p.data_limit_gb;

----SELECT 
----    FORMAT(billing_month, 'yyyy-MM') AS revenue_month,
----    COUNT(invoice_id) AS total_invoices,
----    SUM(amount) AS total_billed_revenue
----FROM dbo.invoices
----GROUP BY FORMAT(billing_month, 'yyyy-MM')
----ORDER BY revenue_month;

----SELECT 
----    CONCAT('INV-', FORMAT(i.billing_month, 'yyyyMM'), '-', RIGHT('0000' + CAST(i.invoice_id AS VARCHAR(4)), 4)) AS formatted_invoice_no,
----    s.full_name,
----    s.phone_number,
----    i.due_date,
----    i.amount,
----    DATEDIFF(DAY, i.due_date, '2026-11-17') AS days_overdue,
----    CASE 
----        WHEN i.paid_date IS NOT NULL THEN 'Paid'
----        WHEN DATEDIFF(DAY, i.due_date, '2026-11-17') > 15 THEN 'Critical Overdue (>15 Days)'
----        WHEN i.due_date < '2026-11-17' THEN 'Overdue (<=15 Days)'
----        ELSE 'Current / Due Soon'
----    END AS due_date_status
----FROM dbo.invoices i
----JOIN dbo.subscribers s ON i.subscriber_id = s.subscriber_id
----WHERE i.paid_date IS NULL
----  AND DATEDIFF(DAY, i.due_date, '2026-11-17') > 15;

----SELECT 
----    s.subscriber_id,
----    s.full_name,
----    s.phone_number,
----    s.circle,
----    p.plan_name
----FROM dbo.subscribers s
----JOIN dbo.plans p ON s.plan_id = p.plan_id
----LEFT JOIN dbo.call_records cr ON s.subscriber_id = cr.subscriber_id
----WHERE cr.record_id IS NULL;

----SELECT 
----    s.circle,
----    COUNT(DISTINCT s.subscriber_id) AS active_subscribers,
----    ISNULL(SUM(i.amount), 0) AS total_revenue,
----    ROUND(ISNULL(SUM(i.amount), 0) * 1.0 / COUNT(DISTINCT s.subscriber_id), 2) AS arpu
----FROM dbo.subscribers s
----LEFT JOIN dbo.invoices i ON s.subscriber_id = i.subscriber_id
----GROUP BY s.circle
----ORDER BY arpu DESC;

----SELECT 
----    p.plan_name,
----    p.monthly_fee,
----    COUNT(s.subscriber_id) AS subscriber_count,
----    CONCAT(ROUND(COUNT(s.subscriber_id) * 100.0 / SUM(COUNT(s.subscriber_id)) OVER (), 2), '%') AS popularity_share
----FROM dbo.plans p
----LEFT JOIN dbo.subscribers s ON p.plan_id = s.plan_id
----GROUP BY p.plan_name, p.monthly_fee
----ORDER BY subscriber_count DESC;

----SELECT TOP 10
----    s.subscriber_id,
----    s.full_name,
----    s.circle,
----    p.plan_name,
----    ISNULL(SUM(cr.data_used_gb), 0) AS total_data_gb,
----    ISNULL(SUM(cr.duration_mins), 0) AS total_call_mins
----FROM dbo.subscribers s
----JOIN dbo.plans p ON s.plan_id = p.plan_id
----LEFT JOIN dbo.call_records cr ON s.subscriber_id = cr.subscriber_id
----GROUP BY s.subscriber_id, s.full_name, s.circle, p.plan_name
----ORDER BY total_data_gb DESC;


--SELECT 
--    SUM(cr.duration_mins) AS sum_ignoring_nulls,
--    AVG(CAST(cr.duration_mins AS DECIMAL(10,2))) AS avg_excluding_missing_users,
--    AVG(CAST(ISNULL(cr.duration_mins, 0) AS DECIMAL(10,2))) AS avg_including_missing_users_as_zero
--FROM dbo.subscribers s
--LEFT JOIN dbo.call_records cr ON s.subscriber_id = cr.subscriber_id;