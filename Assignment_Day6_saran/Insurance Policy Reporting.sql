--CREATE DATABASE InsuranceReportingDB;

--USE InsuranceReportingDB;

--CREATE TABLE dbo.customers (
--    customer_id INT IDENTITY(1,1) PRIMARY KEY,
--    full_name NVARCHAR(100) NOT NULL,
--    date_of_birth DATE NOT NULL,
--    city NVARCHAR(50) NOT NULL
--);

--CREATE TABLE dbo.policies (
--    policy_id INT IDENTITY(1,1) PRIMARY KEY,
--    policy_number VARCHAR(20) NOT NULL UNIQUE,
--    customer_id INT NOT NULL REFERENCES dbo.customers(customer_id),
--    product_name NVARCHAR(50) NOT NULL,
--    agent_name NVARCHAR(100) NOT NULL,
--    start_date DATE NOT NULL,
--    end_date DATE NOT NULL,
--    status VARCHAR(20) NOT NULL DEFAULT 'Active'
--);

--CREATE TABLE dbo.premiums (
--    premium_id INT IDENTITY(1,1) PRIMARY KEY,
--    policy_id INT NOT NULL REFERENCES dbo.policies(policy_id),
--    amount DECIMAL(12,2) NOT NULL,
--    paid_date DATE NOT NULL
--);

--CREATE TABLE dbo.claims (
--    claim_id INT IDENTITY(1,1) PRIMARY KEY,
--    policy_id INT NOT NULL REFERENCES dbo.policies(policy_id),
--    claim_date DATE NOT NULL,
--    claim_amount DECIMAL(12,2) NOT NULL,
--    claim_status VARCHAR(20) NOT NULL
--);

---- Seed Sample Data (Reference Date: 2026-11-17)
--INSERT INTO dbo.customers (full_name, date_of_birth, city) VALUES
--(N'Rajesh Sharma', '1998-05-10', N'Mumbai'),    -- Age 28 (18-30)
--(N'Anita Desai',   '1984-08-22', N'Bengaluru'), -- Age 42 (31-50)
--(N'Suresh Menon',  '1966-02-14', N'Chennai'),   -- Age 60 (51+)
--(N'Kavita Joshi',  '1990-11-01', N'Pune'),      -- Age 36 (31-50)
--(N'Vikram Singh',  '1972-07-19', N'Delhi');     -- Age 54 (51+)

--INSERT INTO dbo.policies (policy_number, customer_id, product_name, agent_name, start_date, end_date, status) VALUES
--('POL-2026-1001', 1, N'Health Shield',  N'Agent Arjun',  '2025-12-01', '2026-12-01', 'Active'),  -- Expires in 14 days
--('POL-2026-1002', 1, N'Motor Protect',  N'Agent Priya',  '2026-09-15', '2027-09-15', 'Active'),  -- Customer 1 has 2 active policies
--('POL-2026-1003', 2, N'Term Life Max',  N'Agent Arjun',  '2026-09-20', '2027-09-20', 'Active'),
--('POL-2026-1004', 2, N'Health Shield',  N'Agent Karan',  '2025-12-10', '2026-12-10', 'Active'),  -- Customer 2 has 2 active policies; expires in 23 days
--('POL-2026-1005', 3, N'Senior Care',    N'Agent Neha',   '2026-10-05', '2027-10-05', 'Active'),
--('POL-2026-1006', 4, N'Motor Protect',  N'Agent Rohan',  '2026-10-18', '2027-10-18', 'Active'),
--('POL-2026-1007', 5, N'Term Life Max',  N'Agent Meera',  '2026-11-02', '2027-11-02', 'Active'),
--('POL-2026-1008', 3, N'Motor Protect',  N'Agent Priya',  '2025-05-01', '2026-05-01', 'Expired');

--INSERT INTO dbo.premiums (policy_id, amount, paid_date) VALUES
--(1, 15000.00, '2025-12-01'),
--(2, 12000.00, '2026-09-15'),
--(3, 25000.00, '2026-09-20'),
--(4, 18000.00, '2025-12-10'),
--(5, 30000.00, '2026-10-05'),
--(6, 14000.00, '2026-10-18'),
--(7, 28000.00, '2026-11-02'),
--(8, 10000.00, '2025-05-01');

--INSERT INTO dbo.claims (policy_id, claim_date, claim_amount, claim_status) VALUES
--(1, '2026-06-15', 10000.00, 'Settled'),
--(4, '2026-08-20',  6500.00, 'Settled'),
--(2, '2026-10-10',  9000.00, 'Approved'),
--(5, '2026-11-05', 12000.00, 'Pending');

SELECT 
    CONCAT(REPLICATE('*', LEN(p.policy_number) - 4), RIGHT(p.policy_number, 4)) AS masked_policy_no,
    c.full_name AS customer_name,
    p.product_name,
    p.end_date,
    DATEDIFF(DAY, '2026-11-17', p.end_date) AS days_to_expiry
FROM dbo.policies p
JOIN dbo.customers c ON p.customer_id = c.customer_id
WHERE p.status = 'Active'
  AND p.end_date BETWEEN '2026-11-17' AND DATEADD(DAY, 30, '2026-11-17')
ORDER BY p.end_date ASC;

SELECT 
    UPPER(p.product_name) AS product_name,
    COUNT(DISTINCT p.policy_id) AS policy_count,
    SUM(pr.amount) AS total_premium_collected
FROM dbo.policies p
JOIN dbo.premiums pr ON p.policy_id = pr.policy_id
GROUP BY p.product_name
ORDER BY total_premium_collected DESC;

SELECT 
    c.customer_id,
    c.full_name,
    c.city,
    COUNT(p.policy_id) AS active_policy_count
FROM dbo.customers c
JOIN dbo.policies p ON c.customer_id = p.customer_id
WHERE p.status = 'Active'
GROUP BY c.customer_id, c.full_name, c.city
HAVING COUNT(p.policy_id) > 1;

WITH ProductPremiums AS (
    SELECT p.product_name, SUM(pr.amount) AS total_premium
    FROM dbo.policies p
    JOIN dbo.premiums pr ON p.policy_id = pr.policy_id
    GROUP BY p.product_name
),
ProductClaims AS (
    SELECT p.product_name, ISNULL(SUM(cl.claim_amount), 0) AS total_claims
    FROM dbo.policies p
    LEFT JOIN dbo.claims cl ON p.policy_id = cl.policy_id
    GROUP BY p.product_name
)
SELECT 
    pp.product_name,
    pp.total_premium,
    pc.total_claims,
    ROUND((pc.total_claims * 100.0) / pp.total_premium, 2) AS claim_ratio_pct
FROM ProductPremiums pp
JOIN ProductClaims pc ON pp.product_name = pc.product_name
ORDER BY claim_ratio_pct DESC;

SELECT 
    CONCAT('XXXX-XXXX-', RIGHT(p.policy_number, 4)) AS masked_policy_no,
    c.full_name AS customer_name,
    p.product_name,
    DATEDIFF(MONTH, p.start_date, '2026-11-17') AS policy_age_months,
    p.status
FROM dbo.policies p
JOIN dbo.customers c ON p.customer_id = c.customer_id
LEFT JOIN dbo.claims cl ON p.policy_id = cl.policy_id
WHERE cl.claim_id IS NULL;

SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, c.date_of_birth, '2026-11-17') BETWEEN 18 AND 30 THEN '18-30 (Young Adult)'
        WHEN DATEDIFF(YEAR, c.date_of_birth, '2026-11-17') BETWEEN 31 AND 50 THEN '31-50 (Mid-Career)'
        ELSE '51+ (Senior)'
    END AS age_band,
    COUNT(DISTINCT p.policy_id) AS policies_count,
    ROUND(AVG(pr.amount), 2) AS avg_premium
FROM dbo.customers c
JOIN dbo.policies p ON c.customer_id = p.customer_id
JOIN dbo.premiums pr ON p.policy_id = pr.policy_id
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, c.date_of_birth, '2026-11-17') BETWEEN 18 AND 30 THEN '18-30 (Young Adult)'
        WHEN DATEDIFF(YEAR, c.date_of_birth, '2026-11-17') BETWEEN 31 AND 50 THEN '31-50 (Mid-Career)'
        ELSE '51+ (Senior)'
    END
ORDER BY age_band;

SELECT 
    FORMAT(start_date, 'yyyy-MM') AS issue_month,
    COUNT(policy_id) AS new_policies_issued
FROM dbo.policies
GROUP BY FORMAT(start_date, 'yyyy-MM')
ORDER BY issue_month;

SELECT TOP 5
    UPPER(p.agent_name) AS agent_name,
    COUNT(DISTINCT p.policy_id) AS policies_sold,
    SUM(pr.amount) AS total_premium_generated
FROM dbo.policies p
JOIN dbo.premiums pr ON p.policy_id = pr.policy_id
GROUP BY p.agent_name
ORDER BY total_premium_generated DESC;