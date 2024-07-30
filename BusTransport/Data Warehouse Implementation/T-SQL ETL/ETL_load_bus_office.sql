USE BusTravel_DW;
GO


IF (OBJECT_ID('dbo.BusTemp') IS NOT NULL) DROP TABLE dbo.BusTemp;
CREATE TABLE dbo.BusTemp (
    BusServiceID INT,
    RegistrationNumber VARCHAR(100),
    VIN VARCHAR(100),
    Brand VARCHAR(20),
    [Type] VARCHAR(100),
    ProductionYear INT,
    SeatsNo INT,
    StandingPlacesNo INT,
    Wheelchair INT,
    AirConditioning INT,
    FeedbackMonitor INT
);
GO

-- SELECT * FROM dbo.BusTemp WHERE ProductionYear = 2018
-- 'WR92772', 'ZK16808'


BULK INSERT dbo.BusTemp
FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\EXCEL files\Bus_2020.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

BULK INSERT dbo.BusTemp
FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\EXCEL files\Bus_2021_additions.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

--SELECT * FROM dbo.BusTemp;

IF (OBJECT_ID('dbo.BusOfficeTemp') IS NOT NULL) DROP TABLE dbo.BusOfficeTemp;
CREATE TABLE dbo.BusOfficeTemp (
    BusServiceID INT,
    Name VARCHAR(100),
    Address VARCHAR(100),
    PostalCode VARCHAR(10),
    City VARCHAR(100),
    Region VARCHAR(100),
    Country VARCHAR(100),
    BusSlots INT
);
GO

BULK INSERT dbo.BusOfficeTemp
FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\EXCEL files\Service_Office_2020.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)



BULK INSERT dbo.BusOfficeTemp
FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\EXCEL files\Service_Office_2021.csv'
WITH (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
)



IF (OBJECT_ID('BusOfficeUsed') IS NOT NULL) DROP VIEW BusOfficeUsed;
GO

-- USING BUS OFFICES THAT ARE IN "ROUTESTRAVELLER" DATABASE
CREATE VIEW BusOfficeUsed
AS
SELECT
    DISTINCT BusServiceID
FROM [RoutesTraveller].dbo.[BUS] AS RT
JOIN dbo.BusTemp AS B ON RT.RegistrationNumber = B.RegistrationNumber
GO


IF (OBJECT_ID('vETLBusOfficeData') IS NOT NULL) DROP VIEW vETLBusOfficeData;
GO

-- USING BUSES THAT ARE IN "ROUTESTRAVELLER" DATABASE
CREATE VIEW vETLBusOfficeData
AS
SELECT
    BO.Name AS BusOfficeName,
    BO.Region AS Region,
    BO.City AS City,
    CASE 
        WHEN BO.BusSlots = 8 THEN 'small'
        WHEN BO.BusSlots = 9 THEN 'average'
        WHEN BO.BusSlots = 10 THEN 'big'
    END AS SizeCategory
FROM dbo.BusOfficeTemp AS BO
JOIN dbo.BusOfficeUsed AS B ON BO.BusServiceID = B.BusServiceID
GO

--SELECT * FROM dbo.vETLBusOfficeData;
--SELECT * FROM [dbo].BUS_OFFICE;

MERGE INTO [BusTravel_DW].dbo.BUS_OFFICE AS Target
	USING vETLBusOfficeData AS Source
	ON Target.BusOfficeName = Source.BusOfficeName
	AND Target.Region = Source.Region
    AND Target.City = Source.City
	AND Target.SizeCategory = Source.SizeCategory
		WHEN NOT MATCHED
			THEN
				INSERT VALUES (Source.BusOfficeName, Source.Region, Source.City, Source.SizeCategory)
	    WHEN MATCHED 
				AND ((Source.BusOfficeName <> Target.BusOfficeName) OR (Source.Region <> Target.Region) OR (Source.SizeCategory <> Target.SizeCategory))
		THEN
			UPDATE
			SET Target.BusOfficeName = Source.BusOfficeName, Target.Region = Source.Region, Target.SizeCategory = Source.SizeCategory
		;

-- SELECT * FROM .BUS_OFFICE;

DROP VIEW vETLBusOfficeData;
DROP VIEW BusOfficeUsed;