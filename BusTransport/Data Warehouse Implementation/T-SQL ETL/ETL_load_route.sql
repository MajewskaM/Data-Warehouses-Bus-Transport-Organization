USE BusTravel_DW
GO

IF (object_id('dbo.BusStopsTemp') IS NOT NULL) DROP TABLE dbo.BusStopsTemp;
CREATE TABLE dbo.BusStopsTemp(BusStopID INT, [Name] VARCHAR(50), Longitude DECIMAL(10,4), Latitude DECIMAL(10,4), 
    SittingPlace INT, Airport INT, BusShelter INT);
GO

BULK INSERT dbo.BusStopsTemp
    FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\EXCEL files\Bus_Stops.csv'
    WITH
    (
    FIRSTROW = 1,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
    )

-- SELECT * FROM dbo.BusStopsTemp;


IF (object_id('vETLDimRouteData') IS NOT NULL) Drop View vETLDimRouteData;
GO

CREATE VIEW vETLDimRouteData
AS
SELECT
    RT.[RouteNumber],
	RT.[RouteName],
	bs1.[Name] AS [StartStopName],
	bs2.[Name] AS [EndStopName],
	CASE
		WHEN bs1.Airport = 1 OR bs2.Airport = 1 THEN 'Airport'
		ELSE 'Non-Airport'
	END AS [ConnectionType]
FROM [RoutesTraveller].dbo.[ROUTE] as RT
JOIN dbo.BusStopsTemp as bs1 on bs1.BusStopID = RT.StartStopID
JOIN dbo.BusStopsTemp as bs2 on bs2.BusStopID = RT.EndStopID;
GO

-- SELECT * FROM dbo.vETLDimRouteData;

-- SELECT * FROM [RoutesTraveller].dbo.[ROUTE];

MERGE INTO [BusTravel_DW].dbo.ROUTE AS TT
	USING vETLDimRouteData as RT
		ON TT.RouteNumber = RT.RouteNumber
		and TT.RouteName = RT.RouteName
		and TT.StartStopName = RT.StartStopName
		and TT.EndStopName = RT.EndStopName
        and TT.ConnectionType = RT.ConnectionType
			WHEN Not Matched
				THEN
					INSERT Values (
                        RT.RouteNumber,
                        RT.RouteName,
                        RT.StartStopName,
                        RT.EndStopName,
                        RT.ConnectionType
					)
			WHEN Matched -- when number and name match but the stops or connection type not
				AND ((RT.StartStopName <> TT.StartStopName) OR (RT.EndStopName <> TT.EndStopName) OR (RT.ConnectionType <> TT.ConnectionType))
			THEN
				UPDATE
				SET TT.StartStopName = RT.StartStopName, TT.EndStopName = RT.EndStopName, TT.ConnectionType = RT.ConnectionType
			;

-- SELECT * FROM dbo.[ROUTE];
DROP TABLE dbo.BusStopsTemp;
Drop VIEW vETLDimRouteData
