USE HighSchoolHD;
go

DECLARE @CurrentDate DATE = '2000-01-01';
DECLARE @EndDate DATE = '2045-12-31';

DELETE FROM Date;

DROP TABLE IF EXISTS Holidays;
CREATE TABLE Holidays (
    HolidayMonth INT NOT NULL CHECK (HolidayMonth BETWEEN 1 AND 12),
    HolidayDay INT NOT NULL CHECK (HolidayDay BETWEEN 1 AND 31),
    HolidayName VARCHAR(255) NOT NULL,
    PRIMARY KEY (HolidayMonth, HolidayDay)
);

INSERT INTO Holidays (HolidayMonth, HolidayDay, HolidayName)
VALUES 
    (1, 1, 'New Year Day'),
    (1, 6, 'Epiphany'),
    (5, 1, 'Labor Day'),
    (5, 3, 'Constitution Day'),
    (8, 15, 'Assumption of Mary'),
    (11, 1, 'All Saints Day'),
    (11, 11, 'Independence Day'),
    (12, 25, 'Christmas Day'),
    (12, 26, 'Second Christmas Day'),
    (4, 1, 'April Fools Day'),
	(1, 20, 'Grandmothers Day'),
    (6, 1, 'Children Day');

WHILE @CurrentDate <= @EndDate
BEGIN
	DECLARE @IsNearHoliday VARCHAR(20) = 'Not near holiday';

    IF EXISTS (
        SELECT 1
        FROM Holidays
        WHERE 
            HolidayMonth = MONTH(DATEADD(DAY, 1, @CurrentDate))
            AND HolidayDay = DAY(DATEADD(DAY, 1, @CurrentDate))
    )
    BEGIN
        SET @IsNearHoliday = 'Near holiday';
    END;

    INSERT INTO Date (Day, Month, Year, isNearHoliday, WeekDay)
    VALUES (
        DAY(@CurrentDate),
        DATENAME(MONTH, @CurrentDate),
        YEAR(@CurrentDate),
        @IsNearHoliday,
        DATENAME(WEEKDAY, @CurrentDate)
    );

    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END;

DROP TABLE IF EXISTS Holidays;