use HighSchoolHD
go

DECLARE @hour int = 0
DECLARE @min INT = 0
DECLARE @index INT = 1

WHILE @hour < 24 BEGIN
	SET @min = 0
	
	WHILE @min < 60 BEGIN
		
		insert into Time("Hour", "Minute") values (@hour, @min);

		SET @index += 1
		SET @min += 1
	
	END
	SET @hour += 1
END