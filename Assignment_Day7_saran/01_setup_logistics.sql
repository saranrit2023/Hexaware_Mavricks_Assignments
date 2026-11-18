------create database logisticsdb;
----use logisticsdb;

---- 1. Create Tables
--CREATE TABLE Hubs (
--    hub_id INT PRIMARY KEY,
--    hub_name VARCHAR(50),
--    city VARCHAR(50)
--);

--CREATE TABLE Carriers (
--    carrier_id INT PRIMARY KEY,
--    carrier_name VARCHAR(50),
--    service_tier VARCHAR(20)
--);

--CREATE TABLE Customers (
--    customer_id INT PRIMARY KEY,
--    customer_name VARCHAR(50),
--    region VARCHAR(30)
--);

--CREATE TABLE Employees (
--    emp_id INT PRIMARY KEY,
--    emp_name VARCHAR(50),
--    role VARCHAR(30),
--    supervisor_id INT NULL REFERENCES Employees(emp_id),
--    hub_id INT REFERENCES Hubs(hub_id)
--);

--CREATE TABLE Shipments (
--    shipment_id INT PRIMARY KEY,
--    customer_id INT REFERENCES Customers(customer_id),
--    carrier_id INT REFERENCES Carriers(carrier_id),
--    origin_hub_id INT REFERENCES Hubs(hub_id),
--    shipping_cost DECIMAL(10, 2),
--    expected_date DATE,
--    actual_date DATE NULL
--);

--CREATE TABLE DeliveryEvents (
--    event_id INT PRIMARY KEY,
--    shipment_id INT REFERENCES Shipments(shipment_id),
--    event_status VARCHAR(30),
--    event_time DATETIME
--);

---- 2. Seed Data
--INSERT INTO Hubs VALUES
--(1, 'North Hub', 'Delhi'),
--(2, 'West Hub', 'Mumbai'),
--(3, 'South Hub', 'Chennai'),
--(4, 'East Hub', 'Kolkata'); 

--INSERT INTO Carriers VALUES
--(10, 'SwiftFreight', 'Express'),
--(20, 'BlueDart Logistics', 'Standard'),
--(30, 'CargoMax', 'Economy');

--INSERT INTO Customers VALUES
--(101, 'Apex Retail', 'North'),
--(102, 'Zenith Electronics', 'West'),
--(103, 'OmniMart', 'South');

--INSERT INTO Employees VALUES
--(1, 'Rajesh Sharma', 'Regional Director', NULL, 1),
--(2, 'Anita Verma', 'Hub Manager', 1, 1),
--(3, 'Vikram Singh', 'Dispatch Lead', 2, 1),
--(4, 'Priya Nair', 'Hub Manager', 1, 2);

--INSERT INTO Shipments VALUES
--(1001, 101, 10, 1, 500.00, '2026-10-01', '2026-10-01'), 
--(1002, 101, 20, 2, 750.00, '2026-10-02', '2026-10-06'), 
--(1003, 101, 30, 3, 600.00, '2026-10-03', '2026-10-07'), 
--(1004, 102, 10, 1, 900.00, '2026-10-04', '2026-10-05'), 
--(1005, 102, 20, 1, 650.00, '2026-10-05', '2026-10-09'), 
--(1006, 103, 30, 2, 1200.00, '2026-10-06', '2026-10-06'),
--(1007, 101, 10, 4, 450.00, '2026-10-07', '2026-10-08');

--DELETE FROM Shipments WHERE shipment_id = 1007;

--INSERT INTO Shipments VALUES (1007, 101, 10, 4, 450.00, '2026-10-07', '2026-10-08');
--INSERT INTO Hubs VALUES (5, 'Central Hub', 'Nagpur');

--INSERT INTO DeliveryEvents VALUES
--(1, 1001, 'Picked Up', '2026-10-01 08:00:00'),
--(2, 1001, 'Delivered', '2026-10-01 18:00:00'),
--(3, 1002, 'Picked Up', '2026-10-02 09:00:00'),
--(4, 1002, 'In Transit - Delayed', '2026-10-05 14:00:00');

--select * from Hubs;
select * from Carriers;
--select * from Employees;
select * from Shipments;
--select * from DeliveryEvents;
select * from Customers;

--select c.carrier_name, s.shipment_id, datediff(day, s.expected_date, s.actual_date) as delaydate from Carriers c join Shipments s on c.carrier_id = s.carrier_id where datediff(day, s.expected_date, s.actual_date) > 2

--select h.hub_id, h.hub_name, h.city	
--from hubs h left join Shipments s 
--on h.hub_id = s.origin_hub_id
--where s.shipment_id = ;

--SELECT e.emp_name AS employee, e.role AS emp_role, 
--       COALESCE(sup.emp_name, 'No Supervisor (Top Level)') AS supervisor
--FROM Employees e
--LEFT JOIN Employees sup ON e.supervisor_id = sup.emp_id;

--SELECT h.hub_name, s.shipment_id, s.shipping_cost
--FROM Hubs h
--FULL OUTER JOIN Shipments s ON h.hub_id = s.origin_hub_id;

--SELECT cu.customer_name, h.hub_name AS origin, ca.carrier_name, s.shipping_cost
--FROM Shipments s
--INNER JOIN Customers cu ON s.customer_id = cu.customer_id
--INNER JOIN Hubs h ON s.origin_hub_id = h.hub_id
--INNER JOIN Carriers ca ON s.carrier_id = ca.carrier_id;

--SELECT s.shipment_id, s.expected_date
--FROM Shipments s
--LEFT JOIN DeliveryEvents de ON s.shipment_id = de.shipment_id
--WHERE de.event_id IS NULL;

--SELECT cu.customer_name, COUNT(s.shipment_id) AS total_shipments, SUM(s.shipping_cost) AS total_spend
--FROM Customers cu
--INNER JOIN Shipments s ON cu.customer_id = s.customer_id
--GROUP BY cu.customer_name;

--SELECT ca.carrier_name, COUNT(s.shipment_id) AS shipment_count
--FROM Carriers ca
--LEFT JOIN Shipments s ON ca.carrier_id = s.carrier_id
--GROUP BY ca.carrier_name;

--SELECT s.shipment_id, de.event_status, de.event_time
--FROM Shipments s
--INNER JOIN DeliveryEvents de ON s.shipment_id = de.shipment_id
--WHERE s.actual_date > s.expected_date;

--SELECT s1.customer_id, s1.shipment_id AS shipment_1, s2.shipment_id AS shipment_2
--FROM Shipments s1
--INNER JOIN Shipments s2 
--    ON s1.customer_id = s2.customer_id 
--   AND s1.shipment_id < s2.shipment_id
--   AND s1.origin_hub_id <> s2.origin_hub_id;

--SELECT customer_name 
--FROM Customers
--WHERE customer_id IN (
--    SELECT s.customer_id 
--    FROM Shipments s
--    INNER JOIN Carriers c ON s.carrier_id = c.carrier_id
--    WHERE c.service_tier = 'Express'
--);

--SELECT c.customer_id, c.customer_name
--FROM Customers c
--WHERE NOT EXISTS (
--    SELECT h.hub_id 
--    FROM Hubs h
--    WHERE h.hub_id <= 4 -- Active hubs
--      AND NOT EXISTS (
--          SELECT 1 
--          FROM Shipments s 
--          WHERE s.customer_id = c.customer_id 
--            AND s.origin_hub_id = h.hub_id
--      )
--);

--SELECT c.carrier_name, AVG(CAST(DATEDIFF(DAY, s.expected_date, s.actual_date) AS FLOAT)) AS avg_delay
--FROM Carriers c
--INNER JOIN Shipments s ON c.carrier_id = s.carrier_id
--GROUP BY c.carrier_name
--HAVING AVG(CAST(DATEDIFF(DAY, s.expected_date, s.actual_date) AS FLOAT)) > ALL (
--    SELECT DATEDIFF(DAY, s2.expected_date, s2.actual_date)
--    FROM Shipments s2
--    INNER JOIN Carriers c2 ON s2.carrier_id = c2.carrier_id
--    WHERE c2.service_tier = 'Express'
--);

--SELECT shipment_id, shipping_cost
--FROM Shipments
--WHERE shipping_cost > ANY (
--    SELECT s.shipping_cost 
--    FROM Shipments s
--    INNER JOIN Carriers c ON s.carrier_id = c.carrier_id
--    WHERE c.carrier_name = 'SwiftFreight'
--);

--SELECT DISTINCT cu.customer_name
--FROM Customers cu
--INNER JOIN Shipments s ON cu.customer_id = s.customer_id
--INNER JOIN Carriers c ON s.carrier_id = c.carrier_id
--WHERE c.service_tier = 'Express';

--SELECT hub_name FROM Hubs h WHERE NOT EXISTS (SELECT 1 FROM Shipments s WHERE s.origin_hub_id = h.hub_id);

--SELECT h.hub_name
--FROM Hubs h
--LEFT JOIN Shipments s ON h.hub_id = s.origin_hub_id
--WHERE s.shipment_id IS NULL;

--SELECT s1.origin_hub_id, h.hub_name, MAX(s1.shipping_cost) AS second_highest_cost
--FROM Shipments s1
--INNER JOIN Hubs h ON s1.origin_hub_id = h.hub_id
--WHERE s1.shipping_cost < (
--    SELECT MAX(s2.shipping_cost)
--    FROM Shipments s2
--    WHERE s2.origin_hub_id = s1.origin_hub_id
--)
--GROUP BY s1.origin_hub_id, h.hub_name;



