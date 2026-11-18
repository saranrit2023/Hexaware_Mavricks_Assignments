----CREATE DATABASE HospitalRecordsDB;

----USE HospitalRecordsDB;

----CREATE TABLE dbo.Departments (
----    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
----    DepartmentName NVARCHAR(100) NOT NULL UNIQUE,
----    FloorLocation NVARCHAR(50) NOT NULL
----);

----CREATE TABLE dbo.Doctors (
----    DoctorID INT IDENTITY(1,1) PRIMARY KEY,
----    DoctorName NVARCHAR(100) NOT NULL,
----    Specialization NVARCHAR(100) NOT NULL,
----    DepartmentID INT NOT NULL REFERENCES dbo.Departments(DepartmentID)
----);

----CREATE TABLE dbo.Patients (
----    PatientID INT IDENTITY(1,1) PRIMARY KEY,
----    PatientName NVARCHAR(100) NOT NULL,
----    Address NVARCHAR(200) NOT NULL,
----    Phone VARCHAR(15) NOT NULL UNIQUE
----);

----CREATE TABLE dbo.Visits (
----    VisitID INT IDENTITY(1,1) PRIMARY KEY,
----    PatientID INT NOT NULL REFERENCES dbo.Patients(PatientID),
----    DoctorID INT NOT NULL REFERENCES dbo.Doctors(DoctorID),
----    VisitDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
----    Diagnosis NVARCHAR(200) NOT NULL,
----    Prescription NVARCHAR(300) NULL,
----    VisitStatus VARCHAR(20) NOT NULL DEFAULT 'Open',
----    CONSTRAINT CK_Valid_VisitDate CHECK (VisitDate <= CAST(GETDATE() AS DATE))
----);

----CREATE TABLE dbo.Billing (
----    BillID INT IDENTITY(1,1) PRIMARY KEY,
----    VisitID INT NOT NULL UNIQUE REFERENCES dbo.Visits(VisitID) ON DELETE CASCADE,
----    BillAmount DECIMAL(10,2) NOT NULL,
----    PaymentStatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
----    CONSTRAINT CK_NonNegative_Bill CHECK (BillAmount >= 0)
----);

------ALTER TABLE dbo.patients 
----ADD insurance_id VARCHAR(40) NULL;

----ALTER TABLE dbo.Billing
----DROP CONSTRAINT CK_NonNegative_Bill;

----ALTER TABLE dbo.Billing
----ADD CONSTRAINT CK_NonNegative_Bill CHECK (BillAmount >= 0);

----EXEC sp_rename 'dbo.Billing', 'PatientBilling';

----EXEC sp_rename 'dbo.PatientBilling', 'Billing';

----INSERT INTO dbo.Departments (DepartmentName, FloorLocation) VALUES
----(N'Cardiology', N'2nd Floor - Wing A'),
----(N'Orthopedics', N'1st Floor - Wing B'),
----(N'General Medicine', N'Ground Floor');

----INSERT INTO dbo.Doctors (DoctorName, Specialization, DepartmentID) VALUES
----(N'Dr. Arvind Rao', N'Interventional Cardiologist', 1),
----(N'Dr. Sneha Menon', N'Pediatric Cardiologist', 1),
----(N'Dr. Vikram Sethi', N'Joint Replacement Surgeon', 2),
----(N'Dr. Priya Nair', N'Internal Medicine', 3);

----INSERT INTO dbo.Patients (PatientName, Address, Phone, insurance_id) VALUES
----(N'Ramesh Kumar', N'14 MG Road, Chennai', '9840011111', 'INS-9001'),
----(N'Anitha Raj', N'22 Anna Nagar, Chennai', '9840022222', NULL),
----(N'Karthik Das', N'78 Indiranagar, Bengaluru', '9840033333', 'INS-9002'),
----(N'Meena Kumari', N'9 T-Nagar, Chennai', '9840044444', 'INS-9003');

----INSERT INTO dbo.Visits (PatientID, DoctorID, VisitDate, Diagnosis, Prescription) VALUES
----(1, 1, '2026-10-12', N'Hypertension', N'Amlodipine 5mg once daily'),
----(2, 2, '2026-10-25', N'Arrhythmia', N'Metoprolol 25mg'),
----(3, 3, '2026-11-04', N'Knee Osteoarthritis', N'Physiotherapy + Paracetamol'),
----(4, 4, '2026-11-10', N'Viral Fever', N'Rest + Hydration + Dolo 650');

----INSERT INTO dbo.Billing (VisitID, BillAmount, PaymentStatus) VALUES
----(1, 2500.00, 'Paid'),
----(2, 3200.00, 'Pending'),
----(3, 1800.00, 'Paid'),
----(4, 600.00, 'Pending');

----UPDATE dbo.Visits
----SET VisitStatus = 'Closed'
----WHERE VisitID = 1;

----DELETE FROM dbo.Visits
----WHERE VisitID = 4;

--SELECT 
--    PatientID,
--    PatientName,
--    Address,
--    Phone
--FROM dbo.Patients
--WHERE PatientID IN (
--    SELECT PatientID 
--    FROM dbo.Visits
--    WHERE VisitDate >= '2026-10-01' 
--      AND VisitDate < '2026-11-01'
--);

--SELECT 
--    DoctorID,
--    DoctorName,
--    Specialization,
--    DepartmentID
--FROM dbo.Doctors
--WHERE DepartmentID IN (
--    SELECT DepartmentID 
--    FROM dbo.Departments
--    WHERE DepartmentName LIKE N'%Cardio%'
--);



