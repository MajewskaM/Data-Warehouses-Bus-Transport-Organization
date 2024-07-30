use RoutesTraveller;
GO

-- 2021 data additions
BULK INSERT dbo.BUS FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Bus_Registration_Type_2021.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.TICKET FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Ticket_2021_additions.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.TRAVEL FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Travel_2021_additions.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.VALIDATION FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Validation_2021_additions.bulk' WITH (FIELDTERMINATOR=',')
BULK INSERT dbo.FEEDBACK FROM 'D:\Studia\sem4\data warehouses\BusTravel\Data Sources\RoutesTravellerData\Feedback_2021_additions.bulk' WITH (FIELDTERMINATOR=',')
