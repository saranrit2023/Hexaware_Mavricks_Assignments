--CREATE DATABASE BankLoanDB;
--USE BankLoanDB;

--CREATE TABLE Branches (
--    branch_id INT PRIMARY KEY,
--    branch_name VARCHAR(50),
--    city VARCHAR(50)
--);

--CREATE TABLE Customers (
--    customer_id INT PRIMARY KEY,
--    customer_name VARCHAR(50),
--    credit_score INT
--);

--CREATE TABLE Loans (
--    loan_id INT PRIMARY KEY,
--    customer_id INT REFERENCES Customers(customer_id),
--    branch_id INT REFERENCES Branches(branch_id),
--    loan_amount DECIMAL(12, 2),
--    overdue_instalments INT,
--    loan_status VARCHAR(20)
--);

--CREATE TABLE Repayments (
--    repayment_id INT PRIMARY KEY,
--    loan_id INT REFERENCES Loans(loan_id),
--    amount_paid DECIMAL(12, 2),
--    repayment_date DATE
--);

--CREATE TABLE Guarantors (
--    guarantor_record_id INT PRIMARY KEY,
--    loan_id INT REFERENCES Loans(loan_id),
--    guarantor_customer_id INT REFERENCES Customers(customer_id)
--);

--INSERT INTO Branches VALUES
--(1, 'Downtown Main', 'Mumbai'),
--(2, 'Tech Park Branch', 'Bengaluru'),
--(3, 'Heritage Square', 'Pune'),
--(4, 'Greenfield Branch', 'Hyderabad');

--INSERT INTO Customers VALUES
--(101, 'Aarav Mehta', 780),
--(102, 'Sneha Kapoor', 690),
--(103, 'Rohan Das', 720),
--(104, 'Meera Joshi', 810);

--INSERT INTO Loans VALUES
--(501, 101, 1, 500000.00, 0, 'Active'),
--(502, 101, 2, 300000.00, 1, 'Active'),  
--(503, 102, 1, 900000.00, 4, 'Overdue'), 
--(504, 103, 2, 200000.00, 5, 'Overdue'), 
--(505, 104, 3, 150000.00, 0, 'Active');

--INSERT INTO Guarantors VALUES
--(1, 503, 101),
--(2, 504, 104); 

--INSERT INTO Repayments VALUES
--(901, 501, 25000.00, '2026-11-01'),
--(902, 502, 15000.00, '2026-10-15'), 
--(903, 503, 30000.00, '2026-07-10'),
--(904, 505, 10000.00, '2026-08-01'); 


--SELECT l.loan_id, c.customer_name, b.branch_name, l.loan_amount, l.overdue_instalments
--FROM Loans l
--INNER JOIN Customers c ON l.customer_id = c.customer_id
--INNER JOIN Branches b ON l.branch_id = b.branch_id
--WHERE l.overdue_instalments > 3;

--SELECT c.customer_id, c.customer_name, COUNT(DISTINCT l.branch_id) AS branch_count
--FROM Customers c
--INNER JOIN Loans l ON c.customer_id = l.customer_id
--GROUP BY c.customer_id, c.customer_name
--HAVING COUNT(DISTINCT l.branch_id) > 1;

--SELECT DISTINCT g_cust.customer_id AS guarantor_id, 
--       g_cust.customer_name AS guarantor_name,
--       b_loan.loan_id AS their_own_loan_id,
--       g.loan_id AS guaranteed_loan_id
--FROM Guarantors g
--INNER JOIN Customers g_cust ON g.guarantor_customer_id = g_cust.customer_id
--INNER JOIN Loans b_loan ON g_cust.customer_id = b_loan.customer_id;

--SELECT b.branch_id, b.branch_name, b.city
--FROM Branches b
--LEFT JOIN Loans l ON b.branch_id = l.branch_id
--WHERE l.loan_id IS NULL;

--SELECT l.loan_id, c.customer_name, l.loan_amount
--FROM Loans l
--INNER JOIN Customers c ON l.customer_id = c.customer_id
--LEFT JOIN Repayments r ON l.loan_id = r.loan_id
--WHERE r.repayment_id IS NULL;

--SELECT l.loan_id, borrower.customer_name AS borrower, guarantor.customer_name AS guarantor
--FROM Guarantors g
--INNER JOIN Loans l ON g.loan_id = l.loan_id
--INNER JOIN Customers borrower ON l.customer_id = borrower.customer_id
--INNER JOIN Customers guarantor ON g.guarantor_customer_id = guarantor.customer_id;

--SELECT b.branch_name, COUNT(l.loan_id) AS total_loans, COALESCE(SUM(l.loan_amount), 0) AS total_exposure
--FROM Branches b
--LEFT JOIN Loans l ON b.branch_id = l.branch_id
--GROUP BY b.branch_name;

--SELECT l.loan_id, c.customer_name, l.loan_amount, COALESCE(SUM(r.amount_paid), 0) AS total_repaid
--FROM Loans l
--INNER JOIN Customers c ON l.customer_id = c.customer_id
--LEFT JOIN Repayments r ON l.loan_id = r.loan_id
--GROUP BY l.loan_id, c.customer_name, l.loan_amount;

--SELECT b.branch_name, l.loan_id, l.loan_amount
--FROM Branches b
--FULL OUTER JOIN Loans l ON b.branch_id = l.branch_id;

--SELECT l1.branch_id, l1.loan_id AS loan_1, l2.loan_id AS loan_2
--FROM Loans l1
--INNER JOIN Loans l2 
--    ON l1.branch_id = l2.branch_id 
--   AND l1.loan_id < l2.loan_id;

--SELECT c.customer_id, c.customer_name, SUM(l.loan_amount) AS total_exposure
--FROM Customers c
--INNER JOIN Loans l ON c.customer_id = l.customer_id
--GROUP BY c.customer_id, c.customer_name
--HAVING SUM(l.loan_amount) > (
--    SELECT AVG(loan_amount) FROM Loans
--);

--SELECT c.customer_name, b.branch_name, l1.loan_amount
--FROM Loans l1
--INNER JOIN Customers c ON l1.customer_id = c.customer_id
--INNER JOIN Branches b ON l1.branch_id = b.branch_id
--WHERE l1.loan_amount > (
--    SELECT AVG(l2.loan_amount)
--    FROM Loans l2
--    WHERE l2.branch_id = l1.branch_id -- Correlated to outer branch_id
--);


--SELECT c.customer_id, c.customer_name
--FROM Customers c
--WHERE EXISTS (
--    SELECT 1 
--    FROM Loans l 
--    WHERE l.customer_id = c.customer_id
--)
--AND NOT EXISTS (
--    SELECT 1 
--    FROM Loans l
--    INNER JOIN Repayments r ON l.loan_id = r.loan_id
--    WHERE l.customer_id = c.customer_id
--      AND r.repayment_date >= DATEADD(DAY, -60, GETDATE())
--);


--SELECT b.branch_id, b.branch_name, MAX(l.loan_amount) AS branch_max_loan
--FROM Branches b
--INNER JOIN Loans l ON b.branch_id = l.branch_id
--GROUP BY b.branch_id, b.branch_name
--HAVING MAX(l.loan_amount) > (
--    SELECT AVG(branch_max)
--    FROM (
--        SELECT MAX(loan_amount) AS branch_max
--        FROM Loans
--        GROUP BY branch_id
--    ) AS BranchMaxSummary
--);