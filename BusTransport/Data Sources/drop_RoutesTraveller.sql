USE RoutesTraveller;
GO

DROP TABLE IF EXISTS FEEDBACK;
DROP TABLE IF EXISTS VALIDATION;
DROP TABLE IF EXISTS TRAVEL;
DROP TABLE IF EXISTS TICKET;
DROP TABLE IF EXISTS SCHEDULE;
DROP TABLE IF EXISTS ROUTE;
DROP TABLE IF EXISTS BUS;
GO

USE master;
GO
ALTER DATABASE RoutesTraveller 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE RoutesTraveller;