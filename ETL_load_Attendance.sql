use HighSchoolHD
go

--Business_ID
--ID_Teacher
--ID_Student
--ID_Subject
--ID_Date
--ID_Time
--isPresent
--isExtracurricular
--isOnline
--NumberOfHours

If (object_id('vETLSubjectsData') is not null) Drop View vETLSubjectsData;
go
create view vETLSubjectsData
as
select 
	[AttendanceID] as [Business_ID_Attendance],
	[ID_Subject] as [ID_Subject],
	[Name] as [SubjectName],
	[StudentID] as [Business_ID_Student],
	[TeacherID] as [Business_ID_Teacher],
	--date,time
	[IsPresent] as [isPresent],
	[IsExtracurricular] as [isExtracurricular],
	[IsOnline] as [isOnline],
	[NumberOfHours] as [NumberOfHours]
from HighSchoolHD.dbo.Subject
join eDziennik.dbo.Attendances on eDziennik.dbo.Attendances.Subject = HighSchoolHD.dbo.Subject.Name
go

--select * from vETLSubjectsData
--go

If (object_id('vETLStudentsJoin') is not null) Drop View vETLStudentsJoin;
go
create view vETLStudentsJoin
as
select Business_ID_Attendance, ID_Subject, SubjectName, ID_Student, Business_ID_Teacher, isPresent, isExtracurricular, isOnline, NumberOfHours
from vETLSubjectsData
join HighSchoolHD.dbo.Student on vETLSubjectsData.Business_ID_Student = HighSchoolHD.dbo.Student.Business_ID
go

--select * from vETLStudentsJoin
--go

If (object_id('vETLDates') is not null) Drop View vETLDates;
go
create view vETLDates
as
SELECT AttendanceID, cnvrt.Year, cnvrt.Month, cnvrt.Day, cnvrt.Hour, cnvrt.Minute, ID_Date, ID_Time FROM
	(select AttendanceID,
		   SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),1,4) as Year,
		   case
		       when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '01' then 'January'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '02' then 'February'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '03' then 'March'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '04' then 'April'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '05' then 'May'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '06' then 'June'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '07' then 'July'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '08' then 'August'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '09' then 'September'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '10' then 'October'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '11' then 'November'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),6,2) = '12' then 'December'
			end as Month,
		   SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Attendances.Date, 120),9,2) as Day,
		   SUBSTRING(CONVERT(VARCHAR(8), eDziennik.dbo.Attendances.Time, 108),1,2) as Hour,
		   SUBSTRING(CONVERT(VARCHAR(8), eDziennik.dbo.Attendances.Time, 108),4,2) as Minute
from eDziennik.dbo.Attendances) AS cnvrt
JOIN HighSchoolHD.dbo.Date ON HighSchoolHD.dbo.Date.Year = cnvrt.Year
	 AND HighSchoolHD.dbo.Date.Month = cnvrt.Month
	 AND HighSchoolHD.dbo.Date.Day = cnvrt.Day
JOIN HighSchoolHD.dbo.Time ON HighSchoolHD.dbo.Time.Hour = cnvrt.Hour
	 AND HighSchoolHD.dbo.Time.Minute = cnvrt.Minute
go

--select * from vETLDates
--go

IF (OBJECT_ID('vETLTeachersJoin') IS NOT NULL) DROP VIEW vETLTeachersJoin;
GO

CREATE VIEW vETLTeachersJoin
AS
SELECT
    Business_ID_Attendance,
    ID_Subject,
    SubjectName,
    ID_Student,
    ID_Teacher,
    ID_Date,
    ID_Time,
    isPresent,
    isExtracurricular,
    isOnline,
    NumberOfHours
FROM (
    SELECT
        Business_ID_Attendance,
        ID_Subject,
        SubjectName,
        ID_Student,
        ID_Teacher,
        ID_Date,
        ID_Time,
        isPresent,
        isExtracurricular,
        isOnline,
        NumberOfHours,
        ROW_NUMBER() OVER (PARTITION BY ID_Student, ID_Teacher, ID_Date, ID_Time, ID_Subject ORDER BY ID_Student DESC) AS RowNum
    FROM
        vETLStudentsJoin
    JOIN
        HighSchoolHD.dbo.Teacher ON vETLStudentsJoin.Business_ID_Teacher = HighSchoolHD.dbo.Teacher.Business_ID
    JOIN
        vETLDates ON vETLDates.AttendanceID = Business_ID_Attendance
) AS Ranked
WHERE
    RowNum = 1;
GO

merge into dbo.Attendance as TT
	using vETLTeachersJoin as ST
		on TT.ID_Subject = ST.ID_Subject
		and TT.ID_Student = ST.ID_Student
		and TT.ID_Teacher = ST.ID_Teacher
		and TT.ID_Time = ST.ID_Time
		and TT.ID_Date = ST.ID_Date
			when not matched
				then 
					insert values (ST.Business_ID_Attendance, ST.ID_Teacher, ST.ID_Student, ST.ID_Subject, ST.ID_Date, ST.ID_Time, ST.isPresent, ST.isExtracurricular, ST.isOnline, ST.NumberOfHours)
			when matched 
			and (TT.isPresent <> ST.isPresent
			OR TT.isExtracurricular <> ST.isExtracurricular
			OR TT.isOnline <> ST.isOnline
			OR TT.NumberOfHours <> ST.NumberOfHours)
				then 
				update set TT.isPresent = ST.isPresent,
				TT.isExtracurricular = ST.isExtracurricular,
				TT.isOnline = ST.isOnline,
				TT.NumberOfHours = ST.NumberOfHours;


drop view vETLTeachersJoin;
drop view vETLDates;
drop view vETLStudentsJoin;
drop view vETLSubjectsData;
