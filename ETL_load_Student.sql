use HighSchoolHD
go 
 
if (object_id('vETLStudentsData') is not null) drop view vETLStudentsData;
go
create view vETLStudentsData
as 
select distinct
	[ClassID] as [ID_Class],
	[StudentID] as [Business_ID],
	[Name] = Cast([FirstName] + ' ' + [LastName] as varchar(101))
from eDziennik.dbo.Students;
go

if (object_id('vETLClassesData') is not null) drop view vETLClassesData;
go
create view vETLClassesData
as 
select distinct
	[ID_Class] as [ID_Class],
	[Business_ID] as [ID_Class_Business]
from HighSchoolHD.dbo.Class;
go

if (object_id('vETLJoined') is not null) drop view vETLJoined;
go
create view vETLJoined
as 
select [vETLStudentsData].Business_ID, [vETLStudentsData].Name, [vETLClassesData].ID_Class from vETLStudentsData
join vETLClassesData on vETLStudentsData.ID_Class = vETLClassesData.ID_Class_Business
go

select * from vETLJoined

merge into dbo.Student as TT
	using vETLJoined as ST
		on TT.Name = ST.Name
		and TT.ID_Class = ST.ID_Class
			when not matched
				then 
					insert values(ST.Business_ID, ST.ID_Class, ST.Name)
		when not matched by source
			then delete;

drop view vETLJoined;
drop view vETLClassesData;
drop view vETLStudentsData;