USE BusTravel_DW;
GO

IF (OBJECT_ID('dbo.vETLBusData') IS NOT NULL) DROP View dbo.vETLBusData;
GO

CREATE VIEW vETLBusData
AS
SELECT
    RT.[RegistrationNumber],
	bs.VIN AS VIN,
    RT.[Type] AS TypeOfBus,
	bs.BusServiceID AS FK_BusOffice,
	CASE
        WHEN bs.SeatsNo + bs.StandingPlacesNo <= 8 THEN 'small'
        WHEN bs.SeatsNo + bs.StandingPlacesNo <= 17 THEN 'average'
        ELSE 'big'
    END AS BusSizeCategory,
	CASE WHEN bs.Wheelchair = 1 OR bs.AirConditioning = 1 THEN 'yes' ELSE 'no' END AS AdditionalEquipment,
    CASE WHEN RT.FeedbackMonitor = 1 THEN 'yes' ELSE 'no' END AS FeedbackMonitor,
	CASE	
		-- Extract the oldest used year in travels from RoutesTraveller Database
		-- Normally we would use here YEAR(CURRENT_TIMESTAMP)
        WHEN ((SELECT YEAR(MAX(IssuedDate)) FROM [RoutesTraveller].dbo.[TRAVEL]) - bs.ProductionYear) < 3 THEN 'new'
        WHEN ((SELECT YEAR(MAX(IssuedDate)) FROM [RoutesTraveller].dbo.[TRAVEL]) - bs.ProductionYear) BETWEEN 3 AND 10 THEN 'middle'
        ELSE 'old'
    END AS AgeCategory,
	IsCurrent = 1
FROM [RoutesTraveller].dbo.[BUS] AS RT
JOIN dbo.BusTemp AS bs ON bs.RegistrationNumber = RT.RegistrationNumber;
GO

Select * from vETLBusData

MERGE INTO [BusTravel_DW].dbo.BUS AS BT
	USING vETLBusData as RT
		ON BT.RegistrationNumber = RT.RegistrationNumber
		AND BT.VIN = RT.VIN
			WHEN Not Matched
				THEN
					INSERT Values (
                        RT.RegistrationNumber,
						RT.VIN,
						RT.FK_BusOffice,
						RT.BusSizeCategory,
						RT.TypeOfBus,
						RT.AdditionalEquipment,
						RT.FeedbackMonitor,
						RT.AgeCategory,
						1
					)
			WHEN Matched 
				AND (BT.FK_BusOffice <> RT.FK_BusOffice 
				OR RT.BusSizeCategory <> BT.BusSizeCategory 
				OR RT.AdditionalEquipment <> BT.AdditionalEquipment 
				OR RT.FeedbackMonitor <> BT.FeedbackMonitor
				OR RT.AgeCategory <> BT.AgeCategory)
				THEN
					UPDATE
					SET  BT.IsCurrent = 0 
			;

-- Loaded BUSES
--SELECT * FROM [BusTravel_DW].dbo.BUS;

-- INSERTING CHANGED ROWS TO THE DIMSELLER TABLE, FOR UPDATES
INSERT INTO [BusTravel_DW].dbo.BUS (
	RegistrationNumber,
	VIN,
	FK_BusOffice,
	BusSizeCategory,
	TypeOfBus,
	AdditionalEquipment,
	FeedbackMonitor,
	AgeCategory,
	IsCurrent					
	)
	SELECT 
		RegistrationNumber,
		VIN,
		FK_BusOffice,
		BusSizeCategory,
		TypeOfBus,
		AdditionalEquipment,
		FeedbackMonitor,
		AgeCategory,
		1 
	FROM vETLBusData
	EXCEPT
	SELECT 
		RegistrationNumber,
		VIN,
		FK_BusOffice,
		BusSizeCategory,
		TypeOfBus,
		AdditionalEquipment,
		FeedbackMonitor,
		AgeCategory,
		1 
	FROM [BusTravel_DW].dbo.BUS;


Drop VIEW vETLBusData;

-- SELECT * FROM [BusTravel_DW].dbo.BUS WHERE RegistrationNumber = 'CT82530'
-- SELECT * FROM [BusTravel_DW].dbo.BUS WHERE RegistrationNumber = 'WR92772'
-- SELECT * FROM [BusTravel_DW].dbo.BUS WHERE RegistrationNumber = 'ZK16808'
-- SELECT * FROM [RoutesTraveller].dbo.TRAVEL WHERE FK_Bus = 'ZK16808'
-- SELECT * FROM [BusTravel_DW].dbo.BUS_TRAVEL WHERE FK_Bus = 'ZK16808'
-- 'ZK16808' - with 0 feedback monitor
