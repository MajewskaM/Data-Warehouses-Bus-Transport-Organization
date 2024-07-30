use RoutesTraveller;
GO

-- data for 2020
BULK INSERT dbo.BUS FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Bus_Registration_Type_2020.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.ROUTE FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Route.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.SCHEDULE FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Schedule.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.TICKET FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Ticket_2020.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.TRAVEL FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Travel_2020.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.VALIDATION FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Validation_2020.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.FEEDBACK FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Feedback_2020.bulk' WITH (FIELDTERMINATOR=',')
