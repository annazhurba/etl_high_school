use HighSchoolHD
go

If (object_id('vETLClassesData') is not null) Drop View vETLClassesData;
go
create view vETLClassesData
as
select distinct
	[ClassID] as [Business_ID],
	[ProfileID] as [Business_ID_Profile],
	[ClassName] as [ClassName],
	case 
		when [NumberOfStudents] < 17 then 'Under 17'
		when [NumberOfStudents] between 17 and 25 then 'From 17 to 25'
		when [NumberOfStudents] > 25 then 'Above 25'
	end as [NumberOfStudents]
from eDziennik.dbo.Classes
go

If (object_id('vETLProfilesData') is not null) Drop View vETLProfilesData;
go
create view vETLProfilesData
as
select distinct 
	[ID_Profile] = [ID_Profile],
	[Business_ID] = [Business_ID]
from HighSchoolHD.dbo.Profile
go

If (object_id('vETLJoined') is not null) Drop View vETLJoined;
go
create view vETLJoined
as 
select [vETLClassesData].Business_ID, [vETLClassesData].ClassName, [vETLClassesData].NumberOfStudents, [vETLProfilesData].ID_Profile from vETLClassesData
join vETLProfilesData on vETLClassesData.Business_ID_Profile = vETLProfilesData.Business_ID
go

select * from vETLJoined

merge into dbo.Class as TT
	using vETLJoined as ST
		on TT.ClassName = ST.ClassName
		and TT.ID_Profile = ST.ID_Profile
			when not matched
				then 
					insert values (ST.Business_ID, ST.ID_Profile, ST.ClassName, ST.NumberOfStudents); 

drop view vETLJoined;
drop view vETLProfilesData;
drop view vETLClassesData;
