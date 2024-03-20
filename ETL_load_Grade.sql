use HighSchoolHD
go

If (object_id('vETLSubjectsData1') is not null) Drop View vETLSubjectsData1;
go
create view vETLSubjectsData1
as
select 
	[GradeID] as [Business_ID_Grade],
	[ID_Subject] as [ID_Subject],
	[Name] as [SubjectName],
	[StudentID] as [Business_ID_Student],
	[TeacherID] as [Business_ID_Teacher],
	[Grade] as [Grade]
from HighSchoolHD.dbo.Subject
join eDziennik.dbo.Grades on eDziennik.dbo.Grades.Subject = HighSchoolHD.dbo.Subject.Name
go

--select * from eDziennik.dbo.Grades
--go
--select * from vETLSubjectsData1
--go


If (object_id('vETLStudentsJoin1') is not null) Drop View vETLStudentsJoin1;
go
create view vETLStudentsJoin1
as
select Business_ID_Grade, ID_Subject, SubjectName, Grade, ID_Student, Business_ID_Teacher
from vETLSubjectsData1
join HighSchoolHD.dbo.Student on vETLSubjectsData1.Business_ID_Student = HighSchoolHD.dbo.Student.Business_ID
go

--select * from vETLStudentsJoin1
--go

If (object_id('vETLDates1') is not null) Drop View vETLDates1;
go
create view vETLDates1
as
SELECT GradeID, cnvrt.Year, cnvrt.Month, cnvrt.Day, cnvrt.Hour, cnvrt.Minute, ID_Date, ID_Time FROM
	(select GradeID,
		   SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),1,4) as Year,
		   case
		       when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '01' then 'January'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '02' then 'February'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '03' then 'March'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '04' then 'April'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '05' then 'May'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '06' then 'June'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '07' then 'July'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '08' then 'August'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '09' then 'September'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '10' then 'October'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '11' then 'November'
			   when SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),6,2) = '12' then 'December'
			end as Month,
		   SUBSTRING(CONVERT(VARCHAR(10), eDziennik.dbo.Grades.AssignDate, 120),9,2) as Day,
		   SUBSTRING(CONVERT(VARCHAR(8), eDziennik.dbo.Grades.AssignTime, 108),1,2) as Hour,
		   SUBSTRING(CONVERT(VARCHAR(8), eDziennik.dbo.Grades.AssignTime, 108),4,2) as Minute
from eDziennik.dbo.Grades) AS cnvrt
JOIN HighSchoolHD.dbo.Date ON HighSchoolHD.dbo.Date.Year = cnvrt.Year
	 AND HighSchoolHD.dbo.Date.Month = cnvrt.Month
	 AND HighSchoolHD.dbo.Date.Day = cnvrt.Day
JOIN HighSchoolHD.dbo.Time ON HighSchoolHD.dbo.Time.Hour = cnvrt.Hour
	 AND HighSchoolHD.dbo.Time.Minute = cnvrt.Minute
go

If (object_id('vETLTeachersJoin1') is not null) Drop View vETLTeachersJoin1;
go
create view vETLTeachersJoin1
as
select Business_ID_Grade, ID_Subject, SubjectName, Grade, ID_Student, ID_Teacher, ID_Date, ID_Time
from vETLStudentsJoin1
join HighSchoolHD.dbo.Teacher on vETLStudentsJoin1.Business_ID_Teacher = HighSchoolHD.dbo.Teacher.Business_ID
join vETLDates1 on vETLDates1.GradeID = Business_ID_Grade
go

merge into dbo.Grade as TT
	using vETLTeachersJoin1 as ST
		on TT.Business_ID = ST.Business_ID_Grade
		and TT.ID_Student = ST.ID_Student
		and TT.ID_Teacher = ST.ID_Teacher
		and TT.ID_Time = ST.ID_Time
		and TT.ID_Date = ST.ID_Date
		and TT.ID_Subject = ST.ID_Subject
		and TT.Grade = ST.Grade
			when not matched
				then 
					insert values (ST.Business_ID_Grade, ST.ID_Student, ST.ID_Teacher, ST.ID_Time, ST.ID_Date, ST.ID_Subject, ST.Grade);


drop view vETLTeachersJoin1;
drop view vETLDates1;
drop view vETLStudentsJoin1;
drop view vETLSubjectsData1;