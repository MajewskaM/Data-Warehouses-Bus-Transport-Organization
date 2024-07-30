CREATE DATABASE RoutesTraveller;
GO

USE RoutesTraveller;
GO

CREATE TABLE BUS (
    RegistrationNumber VARCHAR(8) PRIMARY KEY CHECK(LEN(RegistrationNumber) >= 2),
    Type VARCHAR(9) NOT NULL CHECK (Type IN ('minibus',
	'standard', 'low floor')),
    FeedbackMonitor INT CHECK (FeedbackMonitor IN (0, 1))
);
GO

CREATE TABLE ROUTE (
    RouteNumber INT IDENTITY PRIMARY KEY,
    RouteName VARCHAR(30) NOT NULL CHECK(LEN(RouteName) >= 2),
    StartStopID INT NOT NULL,
    EndStopID INT NOT NULL
);

GO
CREATE TABLE SCHEDULE (
    ScheduleID INT IDENTITY PRIMARY KEY,
    FK_Route INT REFERENCES ROUTE(RouteNumber) NOT NULL,
	DepartureTime TIME NOT NULL,
    ArrivalTime TIME NOT NULL,
    DayType VARCHAR(7) NOT NULL CHECK (DayType IN ('weekday', 'weekend', 'holiday'))
);

GO
CREATE TABLE TICKET (
    TicketID INT IDENTITY PRIMARY KEY,
    -- to allow only letters (alphabet)
    Name VARCHAR(20) NOT NULL CHECK(LEN(Name) >= 2 AND Name NOT LIKE '%' +'[^A-Z]'+'%'),
    Surname VARCHAR(50) NOT NULL CHECK(LEN(Surname) >= 2 AND Surname NOT LIKE '%' +'[^A-Z]'+'%'),
    Email VARCHAR(40) NOT NULL CHECK (Email LIKE '%@%' AND LEN(Email) >= 4)
);

GO
CREATE TABLE TRAVEL (
    TravelID INT IDENTITY PRIMARY KEY,
    FK_Bus VARCHAR(8) REFERENCES BUS(RegistrationNumber) NOT NULL,
    FK_Route INT REFERENCES ROUTE(RouteNumber) NOT NULL,
    FK_Schedule INT REFERENCES SCHEDULE(ScheduleID) NOT NULL,
    IssuedDate DATE NOT NULL,
    CHECK (IssuedDate >= '2018-01-01' AND IssuedDate <= '2050-01-01'),
);

GO
CREATE TABLE VALIDATION (
    PRIMARY KEY (FK_Ticket, FK_Travel),
    FK_Ticket INT REFERENCES TICKET(TicketID) NOT NULL,
    FK_Travel INT REFERENCES TRAVEL(TravelID) NOT NULL
);

GO
CREATE TABLE FEEDBACK (
    FeedbackID INT IDENTITY PRIMARY KEY,
    FK_Travel INT NOT NULL REFERENCES TRAVEL(TravelID),
    SatisfactionLevel INT NOT NULL CHECK (SatisfactionLevel BETWEEN 1 AND 10),
);
GO
