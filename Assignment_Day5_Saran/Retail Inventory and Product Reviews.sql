--CREATE DATABASE RetailInventoryDB;
--GO
--USE RetailInventoryDB;
--GO

--CREATE TABLE dbo.Suppliers (
--    SupplierID INT IDENTITY(1,1) PRIMARY KEY,
--    SupplierName NVARCHAR(100) NOT NULL UNIQUE,
--    SupplierPhone VARCHAR(20) NOT NULL
--);

--CREATE TABLE dbo.Warehouses (
--    WarehouseID INT IDENTITY(1,1) PRIMARY KEY,
--    WarehouseName NVARCHAR(100) NOT NULL UNIQUE
--);

--CREATE TABLE dbo.Products (
--    SKU VARCHAR(20) PRIMARY KEY,
--    ProductName NVARCHAR(100) NOT NULL,
--    Category NVARCHAR(50) NOT NULL DEFAULT N'General',
--    SupplierID INT NOT NULL REFERENCES dbo.Suppliers(SupplierID)
--);

--CREATE TABLE dbo.Inventory (
--    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
--    SKU VARCHAR(20) NOT NULL REFERENCES dbo.Products(SKU) ON DELETE CASCADE,
--    WarehouseID INT NOT NULL REFERENCES dbo.Warehouses(WarehouseID),
--    Quantity INT NOT NULL DEFAULT 0 CHECK (Quantity >= 0),
--    ReorderLevel INT NOT NULL DEFAULT 10 CHECK (ReorderLevel >= 0),
--    CONSTRAINT UQ_SKU_Warehouse UNIQUE (SKU, WarehouseID)
--);
--GO

--INSERT INTO dbo.Suppliers (SupplierName, SupplierPhone) VALUES
--(N'Apex Electronics', '9876543210'), (N'Global Apparel', '9876543211'),
--(N'FreshFarm Foods', '9876543212'),  (N'HomeStyle Decor', '9876543213'),
--(N'TechNova Ltd', '9876543214'),     (N'ActiveGear Co', '9876543215'),
--(N'PureBeauty Inc', '9876543216'),   (N'AutoParts Hub', '9876543217'),
--(N'BookWorld Dist', '9876543218'),   (N'GreenGarden Supply', '9876543219');

--select * from dbo.Suppliers;

--INSERT INTO dbo.Warehouses (WarehouseName) VALUES
--(N'Chennai Central'), (N'Mumbai West'), (N'Delhi North'), (N'Bengaluru South'),
--(N'Hyderabad Hub'),   (N'Kolkata East'), (N'Pune Depot'),  (N'Ahmedabad Store'),
--(N'Jaipur Unit'),     (N'Kochi Port');

--select * from dbo.Warehouses;

--INSERT INTO dbo.Products (SKU, ProductName, Category, SupplierID) VALUES
--('SKU-101', N'Wireless Mouse', N'Electronics', 1),
--('SKU-102', N'Cotton T-Shirt', N'Apparel', 2),
--('SKU-103', N'Organic Honey', N'Groceries', 3),
--('SKU-104', N'Ceramic Vase', N'Home', 4),
--('SKU-105', N'USB-C Hub', N'Electronics', 5),
--('SKU-106', N'Yoga Mat', N'Fitness', 6),
--('SKU-107', N'Aloe Gel', N'Personal Care', 7),
--('SKU-108', N'Car Air Filter', N'Automotive', 8),
--('SKU-109', N'SQL Mastery Book', N'Books', 9),
--('SKU-110', N'Garden Trowel', N'Gardening', 10);

--select * from dbo.Products;

--INSERT INTO dbo.Inventory (SKU, WarehouseID, Quantity, ReorderLevel) VALUES
--('SKU-101', 1, 50, 10), ('SKU-102', 2, 120, 25), ('SKU-103', 3, 40, 15),
--('SKU-104', 4, 18, 5),  ('SKU-105', 5, 75, 20),  ('SKU-106', 6, 60, 15),
--('SKU-107', 7, 90, 20), ('SKU-108', 8, 30, 10),  ('SKU-109', 9, 45, 10),
--('SKU-110', 10, 25, 5);

--select * from dbo.Inventory;

--INSERT INTO dbo.Products (SKU, ProductName, Category, SupplierID)
--VALUES ('SKU-101', N'Duplicate Mouse', N'Electronics', 1);

--INSERT INTO dbo.Products (SKU, ProductName, Category, SupplierID)
--VALUES ('SKU-999', N'Ghost Item', N'Electronics', 999);

--INSERT INTO dbo.Inventory (SKU, WarehouseID, Quantity, ReorderLevel)
--VALUES ('SKU-101', 2, -5, 10);

--INSERT INTO dbo.Products (SKU, ProductName, Category, SupplierID)
--VALUES ('SKU-111', NULL, N'Electronics', 1);

--SELECT * FROM dbo.Suppliers WHERE SupplierID = 1;

--UPDATE dbo.Suppliers
--SET SupplierPhone = '9999900000'
--WHERE SupplierID = 1;

--SELECT * FROM dbo.Suppliers WHERE SupplierID = 1;

--SELECT * FROM dbo.Products WHERE SKU = 'SKU-110';

--SELECT * FROM dbo.Inventory WHERE SKU = 'SKU-110';

--DELETE FROM dbo.Products
--WHERE SKU = 'SKU-110';

--SELECT * FROM dbo.Products WHERE SKU = 'SKU-110';

--SELECT * FROM dbo.Inventory WHERE SKU = 'SKU-110';