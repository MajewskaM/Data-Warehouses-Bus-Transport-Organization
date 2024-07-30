CREATE DATABASE BusTravel_DW collate Polish_CI_AS;
-- Latin1_General_CI_AS;
GO

USE BusTravel_DW
GO

--dimension Time
CREATE TABLE [TIME] (
    ID_Time INT IDENTITY(1,1) PRIMARY KEY,
    [Hour] INT,
    [Minutes] INT,
    TimeOfDay VARCHAR(20),
    -- )
    -- ('between 0 and 8', 'between 9 and 12', 'between 13 and 15', 'between 16 and 20', 'between 21 and 23')
	CONSTRAINT chk_TimeOfDay CHECK (TimeOfDay IN ('0-8', '9-12', '13-15', '16-20', '21-23')),
	CONSTRAINT chk_Hour CHECK ([Hour] >= 0 AND [Hour] <= 23),
	CONSTRAINT chk_Minutes CHECK (Minutes >= 0 AND Minutes <= 59),
    CONSTRAINT UNIQ_hour_min UNIQUE ([Hour],[Minutes])
);
GO

-- dimension Bus Office
CREATE TABLE BUS_OFFICE (
    ID_BusOffice INT IDENTITY(1,1) PRIMARY KEY,
    BusOfficeName VARCHAR(40) NOT NULL,
    Region VARCHAR(20) NOT NULL,
    City VARCHAR(15) NOT NULL,
    SizeCategory VARCHAR(15),
	CONSTRAINT chk_SizeCategory CHECK (SizeCategory IN ('small', 'average', 'big'))
);
GO

-- dimension Route
CREATE TABLE [ROUTE] (
    ID_Route INT IDENTITY(1,1) PRIMARY KEY,
    RouteNumber INT UNIQUE,
    RouteName VARCHAR(30) NOT NULL,
    StartStopName VARCHAR(40) NOT NULL,
    EndStopName VARCHAR(40) NOT NULL,
    ConnectionType VARCHAR(15),
	CONSTRAINT chk_ConnectionType CHECK (ConnectionType IN ('Airport', 'Non-Airport')),
	CONSTRAINT chk_RouteNumber CHECK (RouteNumber >= 0),
);
GO

-- dimension Date
CREATE TABLE [DATE] (
    ID_Date INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATE UNIQUE,
    [Year] INT,
    [Month] VARCHAR(10),
    MonthNo tinyint,
    DayOfWeek VARCHAR(10),
    DayOfWeekNo tinyint,
    TypeOfDay VARCHAR(15),
	CONSTRAINT chk_Year CHECK ([Year] >= 2018),
	CONSTRAINT chk_Month CHECK ([Month] IN ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')),
	CONSTRAINT chk_MonthNo CHECK (MonthNo >= 1 AND MonthNo <= 12),
	CONSTRAINT chk_DayOfWeek CHECK (DayOfWeek IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
	CONSTRAINT chk_DayOfWeekNo CHECK (DayOfWeekNo >= 1 AND DayOfWeekNo <= 7),
	CONSTRAINT chk_TypeOfDay CHECK (TypeOfDay IN ('working day', 'weekend', 'vacation'))
);
GO


-- dimension Junk
CREATE TABLE JUNK (
    ID_Junk INT IDENTITY(1,1) PRIMARY KEY,
    SatisfactionLevelCategory VARCHAR(6),
    OccupationCategory VARCHAR(8),
	CONSTRAINT chk_Satisfaction CHECK (SatisfactionLevelCategory IN ('none', 'low', 'medium', 'high')),
	CONSTRAINT chk_Occupation CHECK (OccupationCategory IN ('very low', 'low', 'medium', 'high')),
	CONSTRAINT UNIQ_sat_occ UNIQUE (SatisfactionLevelCategory,OccupationCategory)
);
GO


-- dimension Bus
CREATE TABLE BUS (
    ID_Bus INT IDENTITY(1,1) PRIMARY KEY,
    RegistrationNumber VARCHAR(8) NOT NULL,
    VIN VARCHAR(17) NOT NULL,
	FK_BusOffice INT FOREIGN KEY REFERENCES BUS_OFFICE,
    BusSizeCategory VARCHAR(15),
    TypeOfBus VARCHAR(9),
    AdditionalEquipment VARCHAR(3),
    FeedbackMonitor VARCHAR(3),
    AgeCategory VARCHAR(6),
	IsCurrent BIT,
	CONSTRAINT chk_Registration CHECK(LEN(RegistrationNumber) >= 2),
	CONSTRAINT chk_BusSizeCatgory CHECK (BusSizeCategory IN ('small', 'average', 'big')),
	CONSTRAINT chk_TypeOfBus CHECK (TypeOfBus IN ('minibus', 'standard', 'low floor')),
	CONSTRAINT chk_Equipment CHECK (AdditionalEquipment IN ('yes', 'no')),
	CONSTRAINT chk_Monitor CHECK (FeedbackMonitor IN ('yes', 'no')),
	CONSTRAINT chk_Age CHECK (AgeCategory IN ('new', 'middle', 'old')),
);
GO

-- fact table Bus Travel
CREATE TABLE BUS_TRAVEL (
	TicketsValidated INT,
	BusTotalCapacity INT,
    TotalSatisfactionLevelReceived INT,
    SatisfactionSurveysNumber INT,
    FK_TravelDate INT FOREIGN KEY REFERENCES [DATE],
    FK_UsedBus INT FOREIGN KEY REFERENCES BUS,
    FK_Route INT FOREIGN KEY REFERENCES [ROUTE],
    FK_ArrivalTime INT FOREIGN KEY REFERENCES [TIME],
    FK_DepartureTime INT FOREIGN KEY REFERENCES [TIME],
    FK_Junk INT FOREIGN KEY REFERENCES JUNK,
    ResponsibleRegionNumber INT NOT NULL,
	CONSTRAINT chk_Tickets CHECK (TicketsValidated >= 0),
	CONSTRAINT chk_Capacity CHECK(BusTotalCapacity >= 1 AND BusTotalCapacity <= 100),
	CONSTRAINT chk_SatisfactionRecieved  CHECK (TotalSatisfactionLevelReceived >= 0),
	CONSTRAINT chk_SurveysNumber CHECK (SatisfactionSurveysNumber >= 0),
	CONSTRAINT chk_Region CHECK(ResponsibleRegionNumber >= 1 AND ResponsibleRegionNumber <= 16),
    
	CONSTRAINT composite_pk PRIMARY KEY (
		FK_TravelDate,
		FK_UsedBus,
		FK_Route,
		FK_ArrivalTime,
		FK_DepartureTime,
		FK_Junk,
		ResponsibleRegionNumber
	)
);
GO


