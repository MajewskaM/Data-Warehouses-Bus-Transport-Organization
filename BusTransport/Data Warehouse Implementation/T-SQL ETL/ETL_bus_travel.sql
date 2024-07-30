USE BusTravel_DW;
GO

IF (OBJECT_ID('dbo.RegionsNumbersTemp') IS NOT NULL) DROP VIEW dbo.RegionsNumbersTemp;
GO
CREATE VIEW dbo.RegionsNumbersTemp AS
SELECT 
    DENSE_RANK() OVER (ORDER BY Region) AS RegionNumber,
    Region AS RegionName
FROM 
    (SELECT DISTINCT Region FROM dbo.BusOfficeTemp) AS DistinctRegions;
GO
-- SELECT * FROM dbo.RegionsNumbersTemp


IF (object_id('TicketsDataTemp') IS NOT NULL) Drop View TicketsDataTemp;
GO

CREATE VIEW TicketsDataTemp
AS
SELECT 
    RT.TravelID,
    COALESCE(COUNT(RT2.FK_Ticket), 0) AS TicketsValidated
FROM RoutesTraveller.dbo.TRAVEL AS RT
LEFT JOIN RoutesTraveller.dbo.[VALIDATION] AS RT2 ON RT2.FK_Travel = RT.TravelID
GROUP BY RT.TravelID
GO
-- SELECT * FROM dbo.TicketsDataTemp

IF (object_id('SatisfactionDataTemp') IS NOT NULL) Drop View SatisfactionDataTemp;
GO

CREATE VIEW SatisfactionDataTemp
AS
SELECT
    RT.TravelID,
    COALESCE(SUM(RT3.SatisfactionLevel), 0) AS TotalSatisfactionLevelReceived,
    COALESCE(COUNT(RT3.FeedbackID), 0) AS SatisfactionSurveysNumber
FROM RoutesTraveller.dbo.TRAVEL AS RT
LEFT JOIN RoutesTraveller.dbo.[FEEDBACK] AS RT3 ON RT3.FK_Travel = RT.TravelID
GROUP BY 
    RT.TravelID
GO
-- SELECT COUNT(*) FROM SatisfactionDataTemp

IF (OBJECT_ID('ScheduleDataTemp') IS NOT NULL) DROP VIEW ScheduleDataTemp;
GO

CREATE VIEW ScheduleDataTemp
AS
SELECT
    RT.TravelID,
    RT.FK_Schedule,
    S.DepartureTime,
    S.ArrivalTime
FROM RoutesTraveller.dbo.TRAVEL AS RT
JOIN RoutesTraveller.dbo.SCHEDULE AS S ON RT.FK_Schedule = S.ScheduleID;
GO
-- SELECT * FROM ScheduleDataTemp

IF (OBJECT_ID('CurrentBusesData') IS NOT NULL) DROP VIEW CurrentBusesData;
GO

CREATE VIEW CurrentBusesData
AS
SELECT BT.ID_Bus, B.RegistrationNumber, B.SeatsNo, B.StandingPlacesNo, B.BusServiceID AS FK_BusOffice
FROM [BusTravel_DW].dbo.BUS AS BT
JOIN dbo.BusTemp AS B ON B.RegistrationNumber = BT.RegistrationNumber
WHERE BT.IsCurrent = 1
GO

-- SELECT * FROM [BusTravel_DW].dbo.BUS WHERE IsCurrent = 1
-- SELECT * FROM CurrentBusesData


IF (object_id('vETLFBusTravelData') IS NOT NULL) DROP view vETLFBusTravelData;
GO
CREATE VIEW vETLFBusTravelData
AS
SELECT 
	TicketsValidated,
    BusTotalCapacity,
    TotalSatisfactionLevelReceived,
    SatisfactionSurveysNumber,
    FK_TravelDate,
    FK_UsedBus,
    FK_RouteNo,
    FK_ArrivalTime,
    FK_DepartureTime,
    FK_Junk = J.ID_Junk,
    ResponsibleRegionNumber
FROM
	(SELECT 
    TicketsValidated,
    BusTotalCapacity,
    TotalSatisfactionLevelReceived,
    SatisfactionSurveysNumber,
    FK_TravelDate = D.ID_Date,
    FK_UsedBus = B.ID_Bus,
    FK_RouteNo = R.ID_Route,
    FK_ArrivalTime = TA.ID_Time,
    FK_DepartureTime = TD.ID_Time,
    CASE
        WHEN SatisfactionSurveysNumber = 0 OR CAST(TotalSatisfactionLevelReceived AS FLOAT) / CAST(SatisfactionSurveysNumber AS FLOAT) <= 3 THEN 'low'
        WHEN CAST(TotalSatisfactionLevelReceived AS FLOAT) / CAST(SatisfactionSurveysNumber AS FLOAT) <= 7 THEN 'medium'
        ELSE 'high'
    END AS [SourceSatisfactionCategory],
    CASE
        WHEN CAST(TicketsValidated AS FLOAT) / CAST(BusTotalCapacity AS FLOAT) <= 0.15 THEN 'very low'
        WHEN CAST(TicketsValidated AS FLOAT) / CAST(BusTotalCapacity AS FLOAT) <= 0.3 THEN 'low'
        WHEN CAST(TicketsValidated AS FLOAT) / CAST(BusTotalCapacity AS FLOAT) <= 0.75 THEN 'medium'
        ELSE 'high'
    END AS [SourceOccupationCategory],
    ResponsibleRegionNumber = RN.RegionNumber
	FROM 
		(SELECT
			TicketsValidated,
			BusTotalCapacity,
			TotalSatisfactionLevelReceived,
			SatisfactionSurveysNumber,
            S.ArrivalTime,
            S.DepartureTime,
			FK_Bus,
			FK_Route,
			IssuedDate
		FROM 
			(SELECT 
				*, BT.SeatsNo + BT.StandingPlacesNo AS BusTotalCapacity 
			FROM RoutesTraveller.dbo.TRAVEL AS RT1
			JOIN dbo.CurrentBusesData AS BT ON BT.RegistrationNumber = RT1.FK_Bus) AS RT
		    LEFT JOIN dbo.TicketsDataTemp AS TCK ON TCK.TravelID = RT.TravelID
			JOIN dbo.SatisfactionDataTemp AS SAT ON SAT.TravelID = RT.TravelID
            JOIN dbo.ScheduleDataTemp AS S ON S.TravelID = RT.TravelID
		) AS x
		JOIN dbo.CurrentBusesData AS B ON B.RegistrationNumber = x.FK_Bus
		JOIN dbo.ROUTE AS R ON R.RouteNumber = x.FK_Route
		JOIN dbo.[DATE] AS D ON CONVERT(VARCHAR(10), D.Date, 111) = CONVERT(VARCHAR(10), x.IssuedDate, 111)
		JOIN dbo.[TIME] AS TA ON DATEPART(HOUR, ArrivalTime) = TA.[Hour] AND DATEPART(MINUTE, ArrivalTime) = TA.[Minutes]
		JOIN dbo.[TIME] AS TD ON DATEPART(HOUR, DepartureTime) = TD.[Hour] AND DATEPART(MINUTE, DepartureTime) = TD.[Minutes]
		JOIN dbo.BusOfficeTemp AS BO ON BO.BusServiceID = B.FK_BusOffice
		JOIN dbo.RegionsNumbersTemp AS RN ON RN.RegionName = BO.Region
		) AS Y
JOIN dbo.JUNK AS J ON J.SatisfactionLevelCategory = Y.SourceSatisfactionCategory AND J.OccupationCategory = Y.SourceOccupationCategory

GO

SELECT * FROM vETLFBusTravelData

MERGE INTO [BusTravel_DW].dbo.BUS_TRAVEL AS BT
USING vETLFBusTravelData AS RT
	ON BT.FK_TravelDate = RT.FK_TravelDate
    AND BT.FK_Route = RT.FK_RouteNo
    AND BT.FK_ArrivalTime = RT.FK_ArrivalTime
    AND BT.FK_DepartureTime = RT.FK_DepartureTime
    AND BT.FK_Junk = RT.FK_Junk
    AND BT.ResponsibleRegionNumber = RT.ResponsibleRegionNumber
		WHEN NOT MATCHED 
			THEN
				INSERT VALUES (
				RT.TicketsValidated, 
				RT.BusTotalCapacity, 
				RT.TotalSatisfactionLevelReceived, 
				RT.SatisfactionSurveysNumber, 
				RT.FK_TravelDate, 
				RT.FK_UsedBus, 
				RT.FK_RouteNo, 
				RT.FK_ArrivalTime, 
				RT.FK_DepartureTime, 
				RT.FK_Junk, 
				RT.ResponsibleRegionNumber
				);


DROP TABLE dbo.BusOfficeTemp;
DROP TABLE dbo.BusTemp;
DROP VIEW CurrentBusesData;
DROP VIEW vETLFBusTravelData;
DROP VIEW dbo.TicketsDataTemp;
DROP VIEW dbo.SatisfactionDataTemp;
DROP VIEW dbo.RegionsNumbersTemp;
DROP VIEW dbo.ScheduleDataTemp;


-- SELECT * FROM [BusTravel_DW].dbo.BUS_TRAVEL WHERE FK_UsedBus = 129 OR FK_UsedBus = 241
-- SELECT * FROM [BusTravel_DW].dbo.BUS WHERE IsCurrent = 0

-- Checking changes in 2021 year (2nd timestamp)
-- e.g. buses should be in other AgeCategory - WR92772, and ZK16808
-- For 'ZK16808' additionally feedback monitor is updated

-- INSERT INTO [RoutesTraveller].dbo.TRAVEL VALUES
-- ('ZK16808', 4, 25, '2021-04-01')
-- 110629

-- SELECT * FROM [BusTravel_DW].dbo.BUS_TRAVEL
-- WHERE FK_TravelDate = 366 AND FK_Route = 4 AND FK_ArrivalTime = 850 AND FK_DepartureTime = 522 AND FK_Junk = 5