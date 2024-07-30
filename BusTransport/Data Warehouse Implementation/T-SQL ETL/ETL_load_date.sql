USE BusTravel_DW
GO

-- Fill Time Lookup Table
-- Step a: Declare variables used in processing
DECLARE @StartDate DATE; 
DECLARE @EndDate DATE;

-- Step b:  Fill the variables with values for the range of years needed
SELECT @StartDate = '2020-04-01', @EndDate = '2021-09-01';

-- Step c:  Use a while loop to add dates to the table
DECLARE @DateInProcess DATETIME = @StartDate;

WHILE @DateInProcess <= @EndDate
BEGIN
    -- Add a row into the date dimension table for this date
    INSERT INTO [dbo].[DATE] 
    ( [Date]
    , [Year]
    , [Month]
    , MonthNo
    , DayOfWeek
    , DayOfWeekNo
    , TypeOfDay
    )
    VALUES ( 
      @DateInProcess, -- [Date]
      CAST(YEAR(@DateInProcess) AS VARCHAR(4)), -- [Year]
      CAST(DATENAME(month, @DateInProcess) AS VARCHAR(10)), -- [Month]
      CAST(MONTH(@DateInProcess) AS TINYINT), -- [MonthNo]
      CAST(DATENAME(dw, @DateInProcess) AS VARCHAR(10)), -- [DayOfWeek]
      CAST(DATEPART(dw, @DateInProcess) AS TINYINT), -- [DayOfWeekNo]
      CASE
        WHEN DATEPART(dw, @DateInProcess) IN (7,1) THEN 'weekend'
        ELSE 'working day'
      END
    );  

    -- Check if the date is within the vacation period (July 1st to August 31st)
    IF @DateInProcess >= '2020-07-01' AND @DateInProcess <= '2020-08-31'
    BEGIN
        UPDATE [dbo].[DATE]
        SET TypeOfDay = 'vacation'
        WHERE [Date] = @DateInProcess;
    END
	IF @DateInProcess >= '2021-07-01' AND @DateInProcess <= '2021-08-31'
    BEGIN
        UPDATE [dbo].[DATE]
        SET TypeOfDay = 'vacation'
        WHERE [Date] = @DateInProcess;
    END
    -- Add a day and loop again
    SET @DateInProcess = DATEADD(DAY, 1, @DateInProcess);
END
GO