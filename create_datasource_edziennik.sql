drop database if exists eDziennik
create database eDziennik
go

use eDziennik
go

drop table if exists Profiles
create table Profiles (
	ProfileID int not null primary key,
	ProfileName varchar (50) not null,
	Description varchar (1000),
)
go

drop table if exists Classes
create table Classes(
	ClassID int not null primary key,
	ClassName varchar (50) not null,
	NumberOfStudents int not null,
	ProfileID int not null,

	foreign key (ProfileID) references Profiles(ProfileID)
)
go

drop table if exists Students
create table Students (
	StudentID int not null primary key,
	FirstName varchar (50) not null,
	LastName varchar (50) not null,
	DateOfBirth date not null,
	Gender char (1) not null check (Gender IN('M', 'F')),
	Address varchar (100) not null,
	PhoneNumber varchar (16) not null, 
	Email varchar (100),
	AdmissionDate date not null,
	GraduationDate date,
	ProfileID int not null,
	ClassID int not null,

	foreign key (ProfileID) references Profiles(ProfileID),
	foreign key (ClassID) references Classes(ClassID),
)
go

drop table if exists Grades
create table Grades (
	GradeID int not null,
	Subject varchar (50) not null,
	Percentage decimal (5,2),
	Grade int not null,
	Comments varchar (255),
	StudentID int not null,
	TeacherID int not null,
	AssignDate date not null,
	AssignTime time not null,

	foreign key (StudentID) references Students(StudentID),
	foreign key (TeacherID) references Teachers(TeacherID),
	primary key (GradeID, StudentID, TeacherID)
)
go

drop table if exists Teachers
create table Teachers(
	TeacherID int not null primary key,
	FirstName varchar (50) not null,
	LastName varchar (50) not null,
	Email varchar (50) not null,
	PhoneNumber varchar (16) not null,
	HireDate date not null,
	Specialization varchar (100),
	ExperienceYears int not null,
	Age int not null
)
go

drop table if exists Attendances
create table Attendances (
	AttendanceID int not null,
	RoomNumber int,
	NumberOfHours int not null,
	IsPresent varchar (10) not null check (IsPresent IN('True', 'False')),
	IsExtracurricular varchar (10) not null check (IsExtracurricular IN('True', 'False')),
	IsOnline varchar (10) not null check (IsOnline IN('True', 'False')),
	Subject varchar (50) not null,
	StudentID int not null,
	TeacherID int not null,
	Date date not null,
	Time time not null,

	foreign key (TeacherID) references Teachers(TeacherID),
	foreign key (StudentID) references Students(StudentID),
	primary key (AttendanceID, TeacherID, StudentID)
)
go