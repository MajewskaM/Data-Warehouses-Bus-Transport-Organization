USE BusTravel_DW;
GO

DROP TABLE IF EXISTS BUS_TRAVEL;
DROP TABLE IF EXISTS BUS;
DROP TABLE IF EXISTS JUNK;
DROP TABLE IF EXISTS [DATE];
DROP TABLE IF EXISTS [ROUTE];
DROP TABLE IF EXISTS [TIME];
DROP TABLE IF EXISTS BUS_OFFICE;
GO

USE master;
GO
ALTER DATABASE BusTravel_DW 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE BusTravel_DW;
