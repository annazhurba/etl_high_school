drop database if exists HighSchoolHD
create database HighSchoolHD
go

use HighSchoolHD
go

drop table if exists Profile
create table Profile (
	ID_Profile int not null IDENTITY(1,1) primary key,
	Business_ID int not null,
	ProfileName varchar (50) not null check (ProfileName in('Mathematics and Physics', 'Informatics', 'Chemistry and Biology', 
				'Linguistics','History and Social Sciences', 'Art and Architecture'))
)
go

drop table if exists Class
create table Class (
	ID_Class int not null IDENTITY(1,1) primary key,
	Business_ID int not null,
	ID_Profile int not null,
	ClassName varchar (50) not null check (ClassName in('1A', '1B', '1C', '1D', '1E', '1F', '2A', '2B', '2C', '2D', '2E', '2F', '3A', '3B', '3C', '3D', '3E', '3F')),
	NumberOfStudents varchar (50) not null check (NumberOfStudents in('Under 17', 'From 17 to 25', 'Above 25')),

	foreign key (ID_Profile) references Profile(ID_Profile)
)
go

drop table if exists Student
create table Student (
	ID_Student int not null IDENTITY(1,1) primary key,
	Business_ID int not null,
	ID_Class int not null,
	Name varchar (101) not null,

	foreign key (ID_Class) references Class(ID_Class)
)
go

drop table if exists Subject 
create table Subject (
	ID_Subject int not null IDENTITY(1,1) primary key,
	Name varchar (50) not null check (Name in('Mathematics', 'English', 'Physics', 'History', 'Art', 'Computer Science', 'Music', 'Geography', 'Physical education', 'Polish language' ))
)
go

drop table if exists Teacher
create table Teacher(
	ID_Teacher int not null IDENTITY(1,1) primary key,
	Business_ID int not null,
	Name varchar (101) not null,
	Specialization varchar (100) check (Specialization in('Mathematics', 'English', 'Physics', 'History', 'Art', 'Computer Science', 'Music', 'Geography', 'Physical education', 'Polish language' )), /*enum??*/
	ExperienceYears varchar (30) not null check (ExperienceYears in ('Up to one year', 'Between one and five years', 'More than five years'))
)
go

drop table if exists Date
create table Date(
	ID_Date int not null IDENTITY(1,1) primary key,
	Day int not null check (Day > 0),
	Month varchar(11) not null check(Month in ('January', 'February', 'March', 'April', 'May', 'June', 'July',  'August', 'September', 'October', 'November', 'December')),
	Year int not null check (Year < 2060),
	isNearHoliday varchar(20) not null check (isNearHoliday in ('Not near holiday', 'Near holiday')),
	WeekDay varchar (12) not null check (WeekDay in ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))
)
go

drop table if exists Time
create table Time (
	ID_Time int not null IDENTITY(1,1) primary key,
	Hour int not null check (Hour >= 0 and Hour < 24),
	Minute int not null check (Minute >= 0 and Minute < 60)
)
go

drop table if exists Attendance
create table Attendance(
	Business_ID int null,
	ID_Teacher int not null,
	ID_Student int not null, 
	ID_Subject int not null,
	ID_Date int not null, 
	ID_Time int not null,
	isPresent bit not null,
	isExtracurricular bit not null,
	isOnline bit not null,
	NumberOfHours int not null, 

	foreign key (ID_Student) references Student(ID_Student),
	foreign key (ID_Subject) references Subject(ID_Subject),
	foreign key (ID_Date) references Date(ID_Date),
	foreign key (ID_Time) references Time(ID_Time),
	foreign key (ID_Teacher) references Teacher(ID_Teacher),
	primary key (ID_Student, ID_Teacher, ID_Subject, ID_Date, ID_Time)
)
go

drop table if exists FinalExam 
create table FinalExam(
	ID_Date int,
	ID_Student int not null,
	ID_Subject int,
	Result int check (Result >= 0 and Result <= 100),

	foreign key (ID_Student) references Student(ID_Student),
	foreign key (ID_Subject) references Subject(ID_Subject),
	foreign key (ID_Date) references Date(ID_Date),

	primary key (ID_Student)
)
go

drop table if exists Grade
create table Grade(
	Business_ID int not null,
	ID_Student int not null,
	ID_Teacher int not null,
	ID_Time int not null,
	ID_Date int not null,
	ID_Subject int not null,
	Grade int not null check (Grade >= 1 and Grade <=6), 

	foreign key (ID_Student) references Student(ID_Student),
	foreign key (ID_Teacher) references Teacher(ID_Teacher),
	foreign key (ID_Subject) references Subject(ID_Subject),
	foreign key (ID_Date) references Date(ID_Date),
	foreign key (ID_Time) references Time(ID_Time),

	primary key (ID_Student, ID_Teacher, ID_Date, ID_Time, ID_Subject)
)
go