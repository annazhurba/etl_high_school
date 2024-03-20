use HighSchoolHD;

drop table if exists StagingFinalExam
CREATE TABLE StagingFinalExam (
    student_id INT,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    subject VARCHAR(255),
    date_of_exam VARCHAR(255),
    result VARCHAR(255)
);


BULK INSERT StagingFinalExam
FROM 'C:\Users\Anna\Documents\SQL Server Management Studio\T-SQL\PrincipalsExcel_t1.csv'
WITH (
    DATAFILETYPE = 'widechar',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, -- Skip the header row -- UTF-8 encoding
	KEEPNULLS
);

--select * from StagingFinalExam
--go

DELETE FROM StagingFinalExam
WHERE student_id IS NULL
   OR first_name IS NULL
   OR last_name IS NULL
   OR subject IS NULL
   OR date_of_exam IS NULL
   OR result IS NULL

--select * from StagingFinalExam
--go

UPDATE StagingFinalExam
SET result = REPLACE(result, '%', '');

--select * from StagingFinalExam
--go

UPDATE StagingFinalExam
SET student_id = (
    SELECT h.ID_Student
    FROM eDziennik.dbo.Students AS e
    JOIN HighSchoolHD.dbo.Student AS h ON (e.FirstName + ' ' + e.LastName) = h.Name
    WHERE e.StudentID = student_id
);


--SELECT * FROM StagingFinalExam;
--go
merge into dbo.FinalExam as TT
	using (
					SELECT
						d.ID_Date,
						se.student_id,
						sub.ID_Subject,
						CAST(se.result AS INT) AS Result
					FROM
						StagingFinalExam se
					LEFT JOIN
						Date d ON CONVERT(VARCHAR, d.Year) + '-' + 
								  FORMAT(
									  CASE d.Month
										  WHEN 'January' THEN 01
										  WHEN 'February' THEN 02
										  WHEN 'March' THEN 03
										  WHEN 'April' THEN 04
										  WHEN 'May' THEN 05
										  WHEN 'June' THEN 06
										  WHEN 'July' THEN 07
										  WHEN 'August' THEN 08
										  WHEN 'September' THEN 09
										  WHEN 'October' THEN 10
										  WHEN 'November' THEN 11
										  WHEN 'December' THEN 12
									  END, '00'
								  ) + '-' + 
								  RIGHT('00' + CAST(d.Day AS VARCHAR), 2) = se.date_of_exam
					LEFT JOIN
						Subject sub ON sub.Name IN (se.subject)
	) as ST
	on TT.ID_Student = ST.student_id
	when not matched 
		then
			insert (ID_Date, ID_Student, ID_Subject, Result)
			values (ST.ID_Date, ST.student_id, ST.ID_Subject, ST.Result);
					


--SELECT * FROM FinalExam;


DROP TABLE IF EXISTS StagingFinalExam;