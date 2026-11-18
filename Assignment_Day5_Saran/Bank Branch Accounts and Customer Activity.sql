----CREATE DATABASE BankBranchDB;

----USE BankBranchDB;


----CREATE TABLE dbo.Branches (
----    BranchID INT IDENTITY(1,1) PRIMARY KEY,
----    BranchCode VARCHAR(10) NOT NULL UNIQUE,
----    BranchName NVARCHAR(100) NOT NULL,
----    City NVARCHAR(50) NOT NULL
----);

----CREATE TABLE dbo.RelationshipManagers (
----    ManagerID INT IDENTITY(1,1) PRIMARY KEY,
----    EmployeeCode VARCHAR(15) NOT NULL UNIQUE,
----    ManagerName NVARCHAR(100) NOT NULL,
----    BranchID INT NOT NULL REFERENCES dbo.Branches(BranchID) ON UPDATE CASCADE ON DELETE NO ACTION
----);

----CREATE TABLE dbo.Customers (
----    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
----    Email VARCHAR(100) NOT NULL UNIQUE,
----    FullName NVARCHAR(100) NOT NULL,
----    Address NVARCHAR(200) NOT NULL
----);

----CREATE TABLE dbo.Accounts (
----    AccountID INT IDENTITY(1,1) PRIMARY KEY,
----    AccountNumber VARCHAR(20) NOT NULL UNIQUE,
----    CustomerID INT NOT NULL REFERENCES dbo.Customers(CustomerID) ON DELETE NO ACTION,
----    BranchID INT NOT NULL REFERENCES dbo.Branches(BranchID) ON DELETE NO ACTION,
----    AccountType VARCHAR(20) NOT NULL CHECK (AccountType IN ('Savings', 'Current', 'Salary')),
----    Balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
----    OpenedDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
----    LastTransactionText NVARCHAR(255) NULL,
----    CONSTRAINT CK_Savings_NonNegative CHECK (
----        (AccountType = 'Savings' AND Balance >= 0) OR (AccountType <> 'Savings')
----    )
----);

--CREATE TABLE dbo.TestAudit (
--    AuditID INT IDENTITY(1,1) PRIMARY KEY,
--    Note VARCHAR(50)
--);

--INSERT INTO dbo.TestAudit (Note) VALUES ('Row 1'), ('Row 2');
--BEGIN TRANSACTION;
--    DELETE FROM dbo.TestAudit;
--ROLLBACK TRANSACTION;
--SELECT * FROM dbo.TestAudit; 

--DELETE FROM dbo.TestAudit; 
--INSERT INTO dbo.TestAudit (Note) VALUES ('Row 3');
--SELECT * FROM dbo.TestAudit;

--BEGIN TRANSACTION;
--    TRUNCATE TABLE dbo.TestAudit;
--ROLLBACK TRANSACTION;
--SELECT * FROM dbo.TestAudit;

--TRUNCATE TABLE dbo.TestAudit;
--INSERT INTO dbo.TestAudit (Note) VALUES ('Row After Truncate');
--SELECT * FROM dbo.TestAudit;

--DROP TABLE dbo.TestAudit;