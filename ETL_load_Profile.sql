-- filling Profile table
use HighSchoolHD
go

if (object_id('vETLProfilesData') is not null) drop view vETLProfilesData;
go
create view vETLProfilesData
as 
select distinct
	[ProfileID] as [Business_ID],
	[ProfileName] as [ProfileName]
from eDziennik.dbo.Profiles;
go

merge into dbo.Profile as TT
	using vETLProfilesData as ST
		on TT.ProfileName = ST.ProfileName
			when not matched
				then 
					insert values(ST.Business_ID,
					ST.ProfileName)
		when not matched by source
			then delete;

drop view vETLProfilesData;

