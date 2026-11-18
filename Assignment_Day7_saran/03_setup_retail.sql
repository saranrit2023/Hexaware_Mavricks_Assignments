--CREATE DATABASE RetailReturnsDB;

--USE RetailReturnsDB;

--CREATE TABLE Stores (
--    store_id INT PRIMARY KEY,
--    store_name VARCHAR(50),
--    region VARCHAR(30)
--);

--CREATE TABLE Products (
--    product_id INT PRIMARY KEY,
--    product_name VARCHAR(50),
--    category VARCHAR(30),
--    unit_price DECIMAL(10, 2)
--);

--CREATE TABLE Customers (
--    customer_id INT PRIMARY KEY,
--    customer_name VARCHAR(50),
--    city VARCHAR(50)
--);

--CREATE TABLE Employees (
--    emp_id INT PRIMARY KEY,
--    emp_name VARCHAR(50),
--    role VARCHAR(30),
--    manager_id INT NULL REFERENCES Employees(emp_id),
--    store_id INT REFERENCES Stores(store_id)
--);

--CREATE TABLE Orders (
--    order_id INT PRIMARY KEY,
--    customer_id INT REFERENCES Customers(customer_id),
--    store_id INT REFERENCES Stores(store_id),
--    product_id INT REFERENCES Products(product_id),
--    order_date DATE
--);

--CREATE TABLE Returns (
--    return_id INT PRIMARY KEY,
--    order_id INT REFERENCES Orders(order_id),
--    return_reason VARCHAR(50),
--    return_date DATE
--);

--CREATE TABLE Refunds (
--    refund_id INT PRIMARY KEY,
--    return_id INT NULL REFERENCES Returns(return_id),
--    refund_amount DECIMAL(10, 2),
--    refund_date DATE
--);

--INSERT INTO Stores VALUES
--(1, 'Metro Flagship', 'North'),
--(2, 'City Center Mall', 'North'),
--(3, 'Harbor Plaza', 'South'),
--(4, 'Tech Valley Outlet', 'South');

--INSERT INTO Products VALUES
--(10, 'Wireless Headphones', 'Electronics', 5000.00),
--(20, 'Running Shoes', 'Apparel', 3000.00),
--(30, 'Smart Watch', 'Electronics', 8000.00);

--INSERT INTO Customers VALUES
--(101, 'Karan Malhotra', 'Delhi'),
--(102, 'Divya Nair', 'Kochi'),
--(103, 'Siddharth Rao', 'Bengaluru');

--INSERT INTO Employees VALUES
--(1, 'Neha Gupta', 'Regional Manager', NULL, 1),
--(2, 'Arjun Verma', 'Store Manager', 1, 1),
--(3, 'Pooja Iyer', 'Returns Specialist', 2, 1),
--(4, 'Manish Tiwari', 'Store Manager', 1, 3);

--INSERT INTO Orders VALUES
--(1001, 101, 1, 10, '2026-10-01'),
--(1002, 101, 1, 10, '2026-10-02'),
--(1003, 102, 2, 10, '2026-10-03'),
--(1004, 103, 3, 10, '2026-10-04'),
--(1005, 102, 3, 20, '2026-10-05'),
--(1006, 103, 4, 20, '2026-10-06'),
--(1007, 101, 2, 30, '2026-10-07'),
--(1008, 103, 4, 30, '2026-10-08');

--INSERT INTO Returns VALUES
--(501, 1001, 'Defective', '2026-10-05'),
--(502, 1003, 'Wrong Size', '2026-10-06'),
--(503, 1005, 'Damaged Box', '2026-10-08'),
--(504, 1006, 'Changed Mind', '2026-10-09');

--INSERT INTO Refunds VALUES
--(901, 501, 5000.00, '2026-10-07'),
--(902, 502, 5000.00, '2026-10-08'),
--(903, 503, 3000.00, '2026-10-10'),
--(904, NULL, 500.00, '2026-10-11');

SELECT p.product_id, p.product_name,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COUNT(DISTINCT r.return_id) AS total_returns,
       CAST(COUNT(DISTINCT r.return_id) * 100.0 / COUNT(DISTINCT o.order_id) AS DECIMAL(5,2)) AS return_rate_pct
FROM Products p
INNER JOIN Orders o ON p.product_id = o.product_id
LEFT JOIN Returns r ON o.order_id = r.order_id
GROUP BY p.product_id, p.product_name
HAVING (COUNT(DISTINCT r.return_id) * 100.0 / COUNT(DISTINCT o.order_id)) > 10;

SELECT DISTINCT c.customer_id, c.customer_name, r.return_id, r.return_reason
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Returns r ON o.order_id = r.order_id
LEFT JOIN Refunds rf ON r.return_id = rf.return_id
WHERE rf.refund_id IS NULL;

SELECT s.store_id, s.store_name, s.region, SUM(rf.refund_amount) AS total_refund_value
FROM Stores s
INNER JOIN Orders o ON s.store_id = o.store_id
INNER JOIN Returns r ON o.order_id = r.order_id
INNER JOIN Refunds rf ON r.return_id = rf.return_id
GROUP BY s.store_id, s.store_name, s.region
ORDER BY total_refund_value DESC;

SELECT e.emp_name AS employee, e.role,
       COALESCE(m.emp_name, 'Top-Level Executive') AS manager
FROM Employees e
LEFT JOIN Employees m ON e.manager_id = m.emp_id;

SELECT p.product_id, p.product_name
FROM Products p
LEFT JOIN Orders o ON p.product_id = o.product_id
LEFT JOIN Returns r ON o.order_id = r.order_id
WHERE r.return_id IS NULL;

SELECT c.customer_name, s.store_name, p.product_name, r.return_reason, rf.refund_amount
FROM Refunds rf
INNER JOIN Returns r ON rf.return_id = r.return_id
INNER JOIN Orders o ON r.order_id = o.order_id
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN Stores s ON o.store_id = s.store_id
INNER JOIN Products p ON o.product_id = p.product_id;

SELECT s.store_id, s.store_name
FROM Stores s
LEFT JOIN Orders o ON s.store_id = o.store_id
LEFT JOIN Returns r ON o.order_id = r.order_id
LEFT JOIN Refunds rf ON r.return_id = rf.return_id
GROUP BY s.store_id, s.store_name
HAVING COUNT(rf.refund_id) = 0;

SELECT r.return_id, r.return_reason, rf.refund_id, rf.refund_amount
FROM Returns r
FULL OUTER JOIN Refunds rf ON r.return_id = rf.return_id;

SELECT r.return_reason, COUNT(rf.refund_id) AS refund_count, SUM(rf.refund_amount) AS total_amount
FROM Returns r
INNER JOIN Refunds rf ON r.return_id = rf.return_id
GROUP BY r.return_reason;

SELECT o1.customer_id, o1.order_id AS order_1, o2.order_id AS order_2
FROM Orders o1
INNER JOIN Orders o2 
    ON o1.customer_id = o2.customer_id 
   AND o1.order_id < o2.order_id
   AND o1.store_id <> o2.store_id;

SELECT return_id, return_reason
FROM Returns
WHERE return_id IN (SELECT return_id FROM Refunds);

SELECT return_id, return_reason
FROM Returns
WHERE return_id NOT IN (SELECT return_id FROM Refunds);

SELECT r.return_id, r.return_reason
FROM Returns r
WHERE NOT EXISTS (
    SELECT 1 
    FROM Refunds rf 
    WHERE rf.return_id = r.return_id
);


SELECT s1.store_id, s1.store_name, s1.region, COALESCE(SUM(rf1.refund_amount), 0) AS store_refunds
FROM Stores s1
LEFT JOIN Orders o1 ON s1.store_id = o1.store_id
LEFT JOIN Returns r1 ON o1.order_id = r1.order_id
LEFT JOIN Refunds rf1 ON r1.return_id = rf1.return_id
GROUP BY s1.store_id, s1.store_name, s1.region
HAVING COALESCE(SUM(rf1.refund_amount), 0) > ALL (
    SELECT COALESCE(SUM(rf2.refund_amount), 0)
    FROM Stores s2
    LEFT JOIN Orders o2 ON s2.store_id = o2.store_id
    LEFT JOIN Returns r2 ON o2.order_id = r2.order_id
    LEFT JOIN Refunds rf2 ON r2.return_id = rf2.return_id
    WHERE s2.region = s1.region 
      AND s2.store_id <> s1.store_id
    GROUP BY s2.store_id
);

SELECT s1.store_id, s1.store_name, s1.region, COALESCE(SUM(rf1.refund_amount), 0) AS store_refunds
FROM Stores s1
LEFT JOIN Orders o1 ON s1.store_id = o1.store_id
LEFT JOIN Returns r1 ON o1.order_id = r1.order_id
LEFT JOIN Refunds rf1 ON r1.return_id = rf1.return_id
GROUP BY s1.store_id, s1.store_name, s1.region
HAVING COALESCE(SUM(rf1.refund_amount), 0) > ANY (
    SELECT COALESCE(SUM(rf2.refund_amount), 0)
    FROM Stores s2
    LEFT JOIN Orders o2 ON s2.store_id = o2.store_id
    LEFT JOIN Returns r2 ON o2.order_id = r2.order_id
    LEFT JOIN Refunds rf2 ON r2.return_id = rf2.return_id
    WHERE s2.region = s1.region 
      AND s2.store_id <> s1.store_id
    GROUP BY s2.store_id
);


SELECT c.customer_id, c.customer_name, SUM(rf.refund_amount) AS total_refunded
FROM Customers c
INNER JOIN Orders o ON c.customer_id = o.customer_id
INNER JOIN Returns r ON o.order_id = r.order_id
INNER JOIN Refunds rf ON r.return_id = rf.return_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(rf.refund_amount) > (
    SELECT AVG(refund_amount)
    FROM Refunds
    WHERE return_id IN (SELECT return_id FROM Returns)
);

SELECT DISTINCT p.product_id, p.product_name
FROM Products p
INNER JOIN Orders o ON p.product_id = o.product_id
INNER JOIN Returns r ON o.order_id = r.order_id
WHERE o.store_id IN (
    SELECT o2.store_id
    FROM Orders o2
    INNER JOIN Returns r2 ON o2.order_id = r2.order_id
    INNER JOIN Refunds rf2 ON r2.return_id = rf2.return_id
    GROUP BY o2.store_id
    HAVING SUM(rf2.refund_amount) = (
        SELECT MAX(store_total)
        FROM (
            SELECT SUM(rf3.refund_amount) AS store_total
            FROM Orders o3
            INNER JOIN Returns r3 ON o3.order_id = r3.order_id
            INNER JOIN Refunds rf3 ON r3.return_id = rf3.return_id
            GROUP BY o3.store_id
        ) AS StoreTotals
    )
);