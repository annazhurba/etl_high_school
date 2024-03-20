use HighSchoolHD
go 
 
if (object_id('vETLTeachersData') is not null) drop view vETLTeachersData;
go
create view vETLTeachersData
as 
select distinct
	[TeacherID] as [Business_ID],
	[Name] = Cast([FirstName] + ' ' + [LastName] as varchar(101)),
	[Specialization] as [Specialization],
	case 
		when [ExperienceYears] < 1 then 'Up to one year'
		when [ExperienceYears] between 1 and 5 then 'Between one and five years'
		when [ExperienceYears] > 5 then 'More than five years'
	end as [ExperienceYears]
from eDziennik.dbo.Teachers;
go

merge into dbo.Teacher as TT
	using vETLTeachersData as ST
		on TT.Name = ST.Name
			when not matched
				then 
					insert values(ST.Business_ID, ST.Name,
					ST.Specialization, ST.ExperienceYears)
			when matched
				and (TT.ExperienceYears <> ST.ExperienceYears
				or TT.Specialization <> ST.Specialization)
				then
					update
					set TT.ExperienceYears = ST.ExperienceYears,
					TT.Specialization = ST.Specialization;


drop view vETLTeachersData;