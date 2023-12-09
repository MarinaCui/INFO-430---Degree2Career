USE G7FinalProject
GO

-- Project 4: Stored Procedures, Business Rules, Computed Columns, Views

-- Stored Procedures

-- Helper Stored Procedures
CREATE OR ALTER PROCEDURE usp_GetUserID
@UFN VARCHAR(50),
@ULN VARCHAR(50),
@UDOB DATE,
@U_ID INT OUTPUT
AS
SET @U_ID = (SELECT UserID FROM tblUSER WHERE UserFName = @UFN and UserLName = @ULN and UserDOB = @UDOB)
GO

CREATE OR ALTER PROCEDURE usp_GetPositionID
@PN VARCHAR(50),
@P_ID INT OUTPUT
AS
SET @P_ID = (SELECT PositionID FROM tblPOSITION WHERE PositionName = @PN)
GO
 
CREATE OR ALTER PROCEDURE usp_GetLocationID
@LN VARCHAR(50),
@L_ID INT OUTPUT
AS
SET @L_ID = (SELECT LocationID FROM tblLOCATION WHERE LocationName = @LN)
GO

CREATE OR ALTER PROCEDURE usp_GetDeptID
@DN VARCHAR(50),
@D_ID INT OUTPUT
AS
SET @D_ID = (SELECT DeptID FROM tblDEPARTMENT WHERE DeptName = @DN)
GO

CREATE OR ALTER PROCEDURE usp_GetCompanyID
@CN VARCHAR(50),
@C_ID INT OUTPUT
AS
SET @C_ID = (SELECT CompanyID FROM tblCOMPANY WHERE CompanyName = @CN)
GO

CREATE OR ALTER PROCEDURE usp_GetUniversityID
@UniversityName VARCHAR(50),
@UniversityID INT OUTPUT
AS
SET @UniversityID = (SELECT UniversityID FROM tblUNIVERSITY WHERE UniversityName = @UniversityName)
GO

CREATE OR ALTER PROCEDURE usp_GetDegreeID
@DegreeName VARCHAR(50),
@DegreeID INT OUTPUT
AS
SET @DegreeID = (SELECT DegreeID FROM tblDEGREE WHERE DegreeName = @DegreeName)
GO


CREATE OR ALTER PROCEDURE usp_GetExperienceID
@ExperienceName VARCHAR(50),
@ExperienceID INT OUTPUT
AS
SET @ExperienceID = (SELECT ExperienceID FROM tblEXPERIENCE WHERE ExperienceName = @ExperienceName)
GO

CREATE OR ALTER PROCEDURE usp_GetCompanyDeptID
@DName varchar(50),
@CName varchar(50),
@CD_ID INT OUTPUT
AS
SET @CD_ID = (SELECT CD.CompanyDeptID 
			  FROM tblCOMPANY_DEPT CD
				JOIN tblDEPARTMENT D ON CD.DeptID = D.DeptID
				JOIN tblCOMPANY C ON CD.CompanyID = C.CompanyID
			  WHERE D.DeptName = @DName
				AND C.CompanyName = @CName)
GO

CREATE OR ALTER PROCEDURE usp_GetDepartmentID
@DepartmentName VARCHAR(50),
@DepartmentID INT OUTPUT
AS
SET @DepartmentID = (SELECT DeptID FROM tblDEPARTMENT WHERE DeptName = @DepartmentName)
GO

-- Aswin:

-- Apply to a Job Posting (Stored Procedure to INSERT into tblAPPLICATION)
CREATE OR ALTER PROCEDURE uspINSERT_tblAPPLICATION
@U_FN VARCHAR(50),
@U_LN VARCHAR(50),
@U_DOB DATE,
@P_N VARCHAR(50),
@L_N VARCHAR(50),
@D_N VARCHAR(50),
@C_N VARCHAR(50),
@AppDate DATE
AS

DECLARE @UID INT, @PID INT, @LID INT, @CID INT, @DID INT, @CDID INT, @JPID INT

EXEC usp_GetUserID
@UFN = @U_FN,
@ULN = @U_LN,
@UDOB = @U_DOB,
@U_ID = @UID OUTPUT

IF @UID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @UID is empty; check spelling';
	THROW 73829, '@UID cannot be NULL, process is terminating', 1;
	END

EXEC usp_GetPositionID
@PN = @P_N,
@P_ID = @PID OUTPUT

IF @PID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @PID is empty; check spelling';
	THROW 73829, '@PID cannot be NULL, process is terminating', 1;
	END

EXEC usp_GetLocationID
@LN = @L_N,
@L_ID = @LID OUTPUT

IF @LID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @LID is empty; check spelling';
	THROW 73829, '@LID cannot be NULL, process is terminating', 1;
	END

EXEC usp_GetCompanyID
@CN = @C_N,
@C_ID = @CID OUTPUT

IF @CID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @CID is empty; check spelling';
	THROW 73829, '@CID cannot be NULL, process is terminating', 1;
	END

EXEC usp_GetDeptID
@DN = @D_N,
@D_ID = @DID OUTPUT

IF @DID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @DID is empty; check spelling';
	THROW 73829, '@DID cannot be NULL, process is terminating', 1;
	END

SET @CDID = (SELECT CompanyDeptID FROM tblCOMPANY_DEPT WHERE CompanyID = @CID and DeptID = @DID)

IF @CDID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @CDID is empty; somethings wrong';
	THROW 73829, '@CDID cannot be NULL, process is terminating', 1;
	END

SET @JPID = (SELECT JobPostingID from tblJOB_POSTING WHERE PositionID = @PID and LocationID = @LID and CompanyDeptID = @CDID)

IF @JPID IS NULL
	BEGIN
	PRINT 'Uhhh...it looks like the variable @JPID is empty; somethings wrong';
	THROW 73829, '@JPID cannot be NULL, process is terminating', 1;
	END

BEGIN TRANSACTION A1
INSERT INTO tblAPPLICATION (UserID, JobPostingID, AppliedDate)
VALUES (@UID, @JPID, @AppDate)

DECLARE @AID INT = (SELECT SCOPE_IDENTITY())

INSERT INTO tblAPP_STATUS (ApplicationID, StatusID,AppStatusDate)
VALUES (@AID, (SELECT StatusID FROM tblSTATUS WHERE StatusName = 'Applied'), @AppDate)

IF @@ERROR <> 0
	BEGIN
		PRINT 'Something broke during commit, rollingback transaction'
		ROLLBACK TRANSACTION A1
	END
ELSE
	COMMIT TRANSACTION A1
GO

-- Synthetic transaction for Stored Procedure to INSERT into tblAPPLICATION
CREATE OR ALTER PROCEDURE wrapper_uspINSERT_tblAPPLICATION
@RUN INT 
AS

DECLARE @UFN VARCHAR(50), @ULN VARCHAR(50), @UDOB DATE, @PN VARCHAR(50),
@LN VARCHAR(50), @DN VARCHAR(50), @CN VARCHAR(50), @ADate DATE

DECLARE @UserPK INT, @PositionPK INT, @LocationPK INT, @CompanyPK INT, @DeptPK INT

DECLARE @User_Count INT = (SELECT COUNT(*) FROM tblUSER)
DECLARE @Position_Count INT = (SELECT COUNT(*) FROM tblPOSITION)
DECLARE @Location_Count INT = (SELECT COUNT(*) FROM tblLOCATION)
DECLARE @Company_Count INT = (SELECT COUNT(*) FROM tblCOMPANY)
DECLARE @Dept_Count INT = (SELECT COUNT(*) FROM tblDEPARTMENT)

WHILE @RUN > 0
	BEGIN
	SET @UserPK = (SELECT RAND() * @User_Count + 1) 
	SET @PositionPK = (SELECT RAND() * @Position_Count + 1) 
	SET @LocationPK = (SELECT RAND() * @Location_Count + 1) 
	SET @CompanyPK = (SELECT RAND() * @Company_Count + 1) 
	SET @DeptPK = (SELECT RAND() * @Dept_Count + 1) 

	SET @UFN = (SELECT UserFName FROM tblUSER WHERE UserID = @UserPK)
	SET @ULN = (SELECT UserLName FROM tblUSER WHERE UserID = @UserPK)
	SET @UDOB = (SELECT UserDOB FROM tblUSER WHERE UserID = @UserPK)
	SET @PN = (SELECT PositionName FROM tblPOSITION WHERE PositionID = @PositionPK)
	SET @LN = (SELECT LocationName FROM tblLOCATION WHERE LocationID = @LocationPK)
	SET @DN = (SELECT DeptName FROM tblDEPARTMENT WHERE DeptID = @DeptPK)
	SET @CN = (SELECT CompanyName FROM tblCOMPANY WHERE CompanyID = @CompanyPK)

	SET @ADate =  (SELECT DATEADD(DAY, -(SELECT RAND() * 10000), GetDate()))

	EXEC uspINSERT_tblAPPLICATION
	@U_FN = @UFN,
	@U_LN = @ULN,
	@U_DOB = @UDOB,
	@P_N = @PN,
	@L_N = @LN,
	@D_N = @DN,
	@C_N = @CN,
	@AppDate = @ADate

	SET @RUN = @RUN - 1
	END
GO

-- Marina:

-- Give a Degree from a University for a User (Stored Procedure to INSERT into tblDEGREE_USER)
CREATE OR ALTER PROCEDURE uspINSERT_tblDEGREE_USER
@UniversityName VARCHAR(50),
@DegreeName VARCHAR(50),
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@DegreeUserDate DATE
AS

DECLARE @UniversityID INT, @DegreeID INT, @UserID INT

EXEC usp_GetUniversityID
@UniversityName = @UniversityName,
@UniversityID = @UniversityID OUTPUT

IF @UniversityID IS NULL
	BEGIN
	PRINT '@UniversityID is not found, please check your input or try another ID.';
	THROW 54412, '@UniversityID is null.', 1;
	END


EXEC usp_GetDegreeID
@DegreeName = @DegreeName,
@DegreeID = @DegreeID OUTPUT

IF @DegreeID IS NULL
	BEGIN
    PRINT '@DegreeID is not found, please check your input or try another ID.';
    THROW 54412, '@DegreeID is null.', 1;
	END

EXEC usp_GetUserID
@UFN = @Fname,
@ULN = @Lname,
@UDOB = @DOB,
@U_ID = @UserID OUTPUT

IF @UserID IS NULL
	BEGIN
    PRINT '@UserID is not found, please check your inputs.';
    THROW 54412, '@UserID is null.', 1;
	END

BEGIN TRANSACTION T1
INSERT INTO tblDEGREE_USER
VALUES (@DegreeID, @UserID, @UniversityID, @DegreeUserDate)

IF @@ERROR <> 0
   BEGIN
       PRINT 'Something wrong with GetUniversityID, GetDegreeID, or GetUserID procedure.';
       ROLLBACK TRANSACTION T1
   END
ELSE
   COMMIT TRANSACTION T1
GO

-- Synthetic Transacation for Stored Procedure to INSERT into tblDEGREE_USER
CREATE OR ALTER PROCEDURE wrapper_uspINSERT_tblDEGREE_USER
@RUN INT
AS

DECLARE @UniversityName VARCHAR(50), @DegreeName VARCHAR(50), @F VARCHAR(50), @L VARCHAR(50), @Birthday DATE, @DegreeDate DATE
DECLARE @UniversityPK INT, @DegreePK INT, @UserPK INT
DECLARE @University_Count INT = (SELECT COUNT(*) FROM tblUNIVERSITY)
DECLARE @DegreeCount INT = (SELECT COUNT(*) FROM tblDEGREE)
DECLARE @UserCount INT = (SELECT COUNT(*) FROM tblUSER)


WHILE @RUN > 0
   BEGIN
   SET @UniversityPK = (SELECT RAND() * @University_Count + 1)
   IF NOT EXISTS (SELECT UniversityID FROM tblUNIVERSITY WHERE UniversityID = @UniversityPK)
       BEGIN
           PRINT 'Found a blank PK for UniversityID; re-running the look-up process'
           SET @UniversityPK = (SELECT RAND()* @University_Count + 1)
       END
      
   SET @DegreePK = (SELECT RAND()* @DegreeCount + 1)
   IF NOT EXISTS (SELECT DegreeID FROM tblDEGREE WHERE DegreeID = @DegreePK)
       BEGIN
           PRINT 'Found a blank PK for DegreeID; re-running the look-up process'
           SET @DegreePK = (SELECT RAND()* @DegreeCount + 1)
       END
  
   SET @UserPK = (SELECT RAND() * @UserCount + 1)
   IF NOT EXISTS (SELECT UserID FROM tblUSER WHERE UserID = @UserPK)
       BEGIN
           PRINT 'Found a blank PK for UserID, re-running the look-up process'
           SET @UserPK = (SELECT RAND()*@UserCount + 1)
       END
  
   SET @UniversityName = (SELECT UniversityName FROM tblUNIVERSITY WHERE UniversityID = @UniversityPK)
   SET @DegreeName = (SELECT DegreeName FROM tblDEGREE WHERE DegreeID = @DegreePK)
   SET @F = (SELECT UserFname FROM tblUSER WHERE UserID = @UserPK)
   SET @L = (SELECT UserLname FROM tblUSER WHERE UserID = @UserPK)
   SET @Birthday = (SELECT UserDOB FROM tblUSER WHERE UserID = @UserPK)
   SET @DegreeDate = (SELECT DATEADD(DAY, -(SELECT RAND()*10000), GetDate()))

   EXEC uspINSERT_tblDEGREE_USER
   @UniversityName = @UniversityName,
   @DegreeName = @DegreeName,
   @Fname = @F,
   @Lname = @L,
   @DOB = @Birthday,
   @DegreeUserDate = @DegreeDate

   SET @RUN = @RUN - 1
   END
GO

-- Add an Experience for a User (Stored Procedure to INSERT into tblEXP_USER)
CREATE OR ALTER PROCEDURE uspINSERT_tblEXP_USER
@ExperienceName VARCHAR(50),
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@BeginDate DATE,
@EndDate DATE
AS

DECLARE @UserID INT, @ExperienceID INT

EXEC usp_GetUserID
@UFN = @Fname,
@ULN = @Lname,
@UDOB = @DOB,
@U_ID = @UserID OUTPUT
IF @UserID IS NULL
BEGIN
   PRINT '@UserID is not found, please check your inputs.';
   THROW 54412, '@UserID is null.', 1;
END

EXEC usp_GetExperienceID
@ExperienceName = @ExperienceName,
@ExperienceID = @ExperienceID OUTPUT
IF @ExperienceID IS NULL
BEGIN
   PRINT '@ExperienceID is not found, please try other inputs.';
   THROW 54412, '@ExperienceID is null.', 1;
END

BEGIN TRANSACTION T2
   INSERT INTO tblEXP_USER
   VALUES (@UserID, @ExperienceID, @BeginDate, @EndDate)
   IF @@ERROR <> 0
       BEGIN
           PRINT 'Something wrong with GetUserID or GetExperienceID procedure.'
           ROLLBACK TRANSACTION T2
       END
   ELSE
       COMMIT TRANSACTION T2
GO

-- Synthetic Transacation for Stored Procedure to INSERT into tblEXP_USER
CREATE OR ALTER PROCEDURE wrapper_uspINSERT_tblEXP_USER
@RUN INT
AS

DECLARE @Fname VARCHAR(50), @Lname VARCHAR(50), @DOB VARCHAR(50), @ExperienceName VARCHAR(50), @BeginDate DATE, @EndDate DATE
DECLARE @UserPK INT, @ExpPK INT
DECLARE @User_Count INT = (SELECT COUNT(*) FROM tblUSER)
DECLARE @ExpCount INT = (SELECT COUNT(*) FROM tblEXPERIENCE)

WHILE @RUN > 0
   BEGIN
   SET @UserPK = (SELECT RAND() * @User_Count + 1)
   SET @ExpPK = (SELECT RAND() * @ExpCount + 1)
   SET @Fname = (SELECT UserFname FROM tblUSER WHERE UserID = @UserPK)
   SET @Lname = (SELECT UserLname FROM tblUSER WHERE UserID = @UserPK)
   SET @DOB = (SELECT UserDOB FROM tblUSER WHERE USERID = @UserPK)
   SET @ExperienceName = (SELECT ExperienceName FROM tblEXPERIENCE WHERE ExperienceID = @ExpPK)
   SET @BeginDate = (SELECT DATEADD(DAY, -(SELECT RAND() * 10000), GetDate()))
   SET @EndDate = (SELECT DATEADD(DAY, -(SELECT RAND() * 10000), GetDate()))

   EXEC uspINSERT_tblEXP_USER
   @ExperienceName = @ExperienceName,
   @Fname = @Fname,
   @Lname = @Lname,
   @DOB = @DOB,
   @BeginDate = @BeginDate,
   @EndDate = @EndDate
   SET @RUN = @RUN - 1
   END
GO

-- Cafter:

-- Create a new Job Posting (Stored Procedure to INSERT into tblJOB_POSTING)
CREATE or ALTER PROCEDURE uspINSERT_tblJOB_POSTING
@pname varchar(50),
@dname varchar(50),
@cname varchar(50),
@lname varchar(50)
AS

DECLARE @P_ID2 INT, @CD_ID2 INT, @L_ID2 INT
EXEC usp_GetPositionID
@PN = @pname,
@P_ID = @P_ID2 OUTPUT
IF @P_ID2 IS NULL
   BEGIN
       PRINT '@P_ID2 is empty...check spelling';
       THROW 65000, '@P_ID2 cannot be NULL', 1;
   END

EXEC usp_GetCompanyDeptID
@DName = dname,
@CName = cname,
@CD_ID = @CD_ID2 OUTPUT
IF @CD_ID2 IS NULL
   BEGIN
       PRINT '@CD_ID2 is empty...check spelling';
       THROW 65000, '@CD_ID2 cannot be NULL', 1;
   END

EXEC usp_GetLocationID
@LN = lname,
@L_ID = @L_ID2
IF @L_ID2 IS NULL
   BEGIN
       PRINT '@L_ID2 is empty...check spelling';
       THROW 65000, '@L_ID2 cannot be NULL', 1;
   END

BEGIN TRANSACTION G1
INSERT INTO tblJOB_POSTING (PositionID, CompanyDeptID, LocationID)
VALUES (@P_ID2, @CD_ID2, @L_ID2)
IF @@ERROR <> 0
   BEGIN
       ROLLBACK TRANSACTION G1
   END
ELSE
COMMIT TRANSACTION G1
GO

-- Synthetic Transaction for Stored Procedure to INSERT into tblJOB_POSTING
CREATE or ALTER PROCEDURE wrapper_uspINSERT_tblJOB_POSTING
@Run INT
AS

DECLARE @posty varchar(50), @depty varchar(50), @compy varchar(50), @locy varchar(50)
DECLARE @Position_PK INT, @CompDept_PK INT, @Location_PK INT
DECLARE @Position_Count INT = (SELECT COUNT(*) FROM tblPOSITION)
DECLARE @CompDept_Count INT = (SELECT COUNT(*) FROM tblJOB_POSTING)
DECLARE @Location_Count INT = (SELECT COUNT(*) FROM tblLOCATION)

WHILE @Run > 0
   BEGIN
   SET @Position_PK = (SELECT RAND() * @Position_Count + 1)
   SET @posty = (SELECT PositionName FROM tblPOSITION WHERE PositionID = @Position_PK)
   SET @CompDept_PK = (SELECT RAND() * @CompDept_Count + 1)
   SET @depty = (SELECT D.DeptName FROM tblDEPARTMENT D JOIN tblCOMPANY_DEPT CD ON D.DeptID = CD.DeptID WHERE CD.CompanyDeptID = @CompDept_PK)
   SET @compy = (SELECT C.CompanyName FROM tblCOMPANY C JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID WHERE CD.CompanyDeptID = @CompDept_PK)
   SET @Location_PK = (SELECT RAND() * @Location_Count + 1)
   SET @locy = (SELECT LocationName FROM tblLOCATION WHERE LocationID = @Location_PK)

   EXEC uspINSERT_tblJOB_POSTING
   @pname = @posty,
   @dname = @depty,
   @cname = @compy,
   @lname = @locy

   SET @Run = @Run - 1
   END
GO

-- Danny:

-- Add a Department to a Company (Stored Procedure to INSERT into tblCOMPANY_DEPT)
CREATE OR ALTER PROCEDURE uspINSERT_tblCOMPANY_DEPT
@CompanyName VARCHAR(50),
@DepartmentName VARCHAR(50)
AS

DECLARE @CompanyID INT, @DepartmentID INT

EXEC usp_GetCompanyID
@CN = @CompanyName,
@C_ID = @CompanyID OUTPUT

IF @CompanyID IS NULL
BEGIN
    PRINT '@CompanyID is not found, please check your input or try another ID.';
    THROW 54412, '@CompanyID is null.', 1;
END

EXEC usp_GetDepartmentID
@DepartmentName = @DepartmentName,
@DepartmentID = @DepartmentID OUTPUT
IF @DepartmentID IS NULL
BEGIN
    PRINT '@DepartmentID is not found, please check your input or try another ID.';
    THROW 54412, '@DepartmentID is null.', 1;
END

BEGIN TRANSACTION T1
INSERT INTO tblCOMPANY_DEPT 
VALUES (@DepartmentID, @CompanyID)

IF @@ERROR <> 0
    BEGIN 
        PRINT 'Something wrong with GetCompanyID, GetDepartmentID, or GetCompanyID procedure.';
        ROLLBACK TRANSACTION T1
    END
ELSE 
    COMMIT TRANSACTION T1
GO


-- Synthetic Transaction for Stored Procedure to INSERT into tblCOMPANY_DEPT
CREATE OR ALTER PROCEDURE wrapper_uspINSERT_tblCOMPANY_DEPT
@RUN INT 
AS

DECLARE @CompanyName VARCHAR(50), @DepartmentName VARCHAR(50)
DECLARE @CompanyPK INT, @DepartmentPK INT 
DECLARE @Company_Count INT = (SELECT COUNT(*) FROM tblCompany)
DECLARE @DepartmentCount INT = (SELECT COUNT(*) FROM tblDepartment)
DECLARE @CompanyCount INT = (SELECT COUNT(*) FROM tblCompany)

WHILE @RUN > 0
    BEGIN 
    SET @CompanyPK = (SELECT RAND() * @Company_Count + 1)
    IF NOT EXISTS (SELECT CompanyID FROM tblCompany WHERE CompanyID = @CompanyPK)
        BEGIN 
            PRINT 'Found a blank PK for CompanyID; re-running the look-up process'
            SET @CompanyPK = (SELECT RAND()* @Company_Count + 1)
        END
        
    SET @DepartmentPK = (SELECT RAND()* @DepartmentCount + 1)
    IF NOT EXISTS (SELECT DeptID FROM tblDepartment WHERE DeptID = @DepartmentPK)
        BEGIN
            PRINT 'Found a blank PK for DepartmentID; re-running the look-up process'
            SET @DepartmentPK = (SELECT RAND()* @DepartmentCount + 1)
        END
    
    SET @CompanyPK = (SELECT RAND() * @CompanyCount + 1)
    IF NOT EXISTS (SELECT CompanyID FROM tblCompany WHERE CompanyID = @CompanyPK)
        BEGIN
            PRINT 'Found a blank PK for CompanyID, re-running the look-up process'
            SET @CompanyPK = (SELECT RAND()*@CompanyCount + 1)
        END
    
    SET @CompanyName = (SELECT CompanyName FROM tblCompany WHERE CompanyID = @CompanyPK)
    SET @DepartmentName = (SELECT DeptName FROM tblDepartment WHERE DeptID = @DepartmentPK)
    SET @CompanyName = (SELECT CompanyName FROM tblCompany WHERE CompanyID = @CompanyPK)
    
    EXEC uspINSERT_tblCOMPANY_DEPT
    @CompanyName = @CompanyName,
    @DepartmentName = @DepartmentName   
    SET @RUN = @RUN - 1
	END 
GO

-- Business Rules

-- Aswin:

-- Users need to be 18 or older to apply for a job 
CREATE OR ALTER FUNCTION fn_noUserBelow18Applications()
RETURNS INTEGER
AS
BEGIN 
DECLARE @RET INTEGER = 0
IF EXISTS 
	(SELECT * 
	FROM tblUSER U
		join tblAPPLICATION A on U.UserID = A.UserID
	WHERE U.UserDOB > DATEADD(YEAR, -18, GETDATE()))
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT CK__noUserBelow18Applications
CHECK (dbo.fn_noUserBelow18Applications() = 0)
GO

-- Users can only apply to one job in a company-department at a time
CREATE OR ALTER FUNCTION fn_onlyOneAppCompDept(@CompDeptID INT)
RETURNS INTEGER
AS
BEGIN 
DECLARE @RET INTEGER = 0
IF EXISTS 
	(SELECT U.UserID, COUNT(A.ApplicationID) as numApps
	FROM tblUSER U
		join tblAPPLICATION A on U.UserID = A.UserID
		join tblJOB_POSTING JP on A.JobPostingID = JP.JobPostingID
		join tblCOMPANY_DEPT CD on JP.CompanyDeptID = CD.CompanyDeptID
		join tblAPP_STATUS APS on A.ApplicationID = APS.ApplicationID
		join tblSTATUS S on APS.StatusID = S.StatusID
	WHERE S.StatusName = 'Applied' or S.StatusName = 'Under Consideration'
		and CD.CompanyDeptID = @CompDeptID
	GROUP BY U.UserID
	HAVING COUNT(A.ApplicationID) > 1)
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblCOMPANY_DEPT
ADD CONSTRAINT CK_onlyOneAppCompDept
CHECK (dbo.fn_onlyOneAppCompDept(CompanyDeptID) = 0)
GO

-- Marina:

-- No User can apply for job if they graduated longer than two years ago
CREATE OR ALTER FUNCTION fn_onlyNewGrads2Yrs()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS 
	(SELECT A.ApplicationID
    FROM tblAPPLICATION A
		JOIN tblUSER U ON A.UserID = U.UserID
		JOIN tblDEGREE_USER DU ON U.UserID = DU.UserID
	GROUP BY A.ApplicationID
    HAVING DATEDIFF(DAY, MAX(DU.DegreeUserDate), GETDATE()) > 730)
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT CK_onlyNewGrads2Yrs
CHECK (dbo.fn_onlyNewGrads2Yrs() = 0)
GO

-- No job positions posted for over a year (365 days)
CREATE OR ALTER FUNCTION fn_noJobs365()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS 
	(SELECT *
    FROM tblCOMPANY C
		JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
		JOIN tblJOB_POSTING J ON CD.CompanyDeptID = J.CompanyDeptID
    WHERE DATEDIFF(DAY, J.PostedDate, J.DueDate) > 365)
	BEGIN
		SET @RET = 1
	END
   RETURN @RET
END
GO


ALTER TABLE tblJOB_POSTING
ADD CONSTRAINT CK_noJobs365
CHECK (dbo.fn_noJobs365() = 0)
GO

-- Cafter:

-- No application will have an applied date that is after due date or before posted date
CREATE OR ALTER FUNCTION fn_noAppPastDueOrBeforePost()
RETURNS INTEGER
AS
BEGIN 
DECLARE @RET INTEGER = 0
IF EXISTS 
	(SELECT * 
	FROM TBLAPPLICATION A
		JOIN TBLJOB_POSTING JP ON A.JobPostingID = JP.JobPostingID
	WHERE A.AppliedDate > JP.DueDate
		OR A.AppliedDate < JP.PostedDate)
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblApplication
ADD CONSTRAINT CK__noAppPastDueOrBeforePost
CHECK (dbo.fn_noAppPastDueOrBeforePost() = 0)
GO

-- No User that is over 40 Years old and has less than two experiences can apply for a job
CREATE OR ALTER FUNCTION fn_noUser40And2Exp()
RETURNS INTEGER
AS
BEGIN 
DECLARE @RET INTEGER = 0
IF EXISTS 
	(SELECT * 
	FROM TBLAPPLICATION A
		JOIN TBLUSER U ON A.UserID = U.UserID
		JOIN TBLEXP_USER EU ON U.UserID = EU.UserID
		JOIN TBLEXPERIENCE E ON EU.ExperienceID = E.ExperienceID
	WHERE DATEDIFF(YEAR, U.UserDOB, GETDATE()) > 40
	GROUP BY U.UserID, U.UserFName, U.UserLName
	HAVING COUNT(E.ExperienceID) < 2)
	BEGIN
		SET @RET = 1
	END
RETURN @RET
END
GO

ALTER TABLE tblUser
ADD CONSTRAINT CK__noUser40And2Exp
CHECK (dbo.fn_noUser40And2Exp() = 0)
GO

-- Danny:

-- No Users who have an Experience Description that contains 'CSE' can have more than 2 applications on September to October
CREATE OR ALTER FUNCTION fn_noUserExpCSE2AppSeptOct ()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS 
	(SELECT *
    FROM tblUSER U
		JOIN tblEXP_USER EU ON U.UserID = EU.UserID
		JOIN tblEXPERIENCE E ON EU.ExperienceID = E.ExperienceID
		JOIN tblAPPLICATION A ON U.UserID = A.UserID
    WHERE E.ExperienceDescr LIKE '%CSE%'
		AND MONTH(A.AppliedDate) BETWEEN 9 AND 10
    GROUP BY U.UserID
    HAVING COUNT(DISTINCT A.ApplicationID) > 2)
	BEGIN
		SET @RET = 1
	END
    RETURN @RET
END 
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT CK_noUserExpCSE2AppSeptOct
CHECK (dbo.fn_noUserExpCSE2AppSeptOct() = 0)
GO

-- No User can have an application with an applied date within 365 days before today and also Feedback that is less than 10 characters long
CREATE OR ALTER FUNCTION fn_noUserAppDate365AndFB10Char ()
RETURNS INT
AS
BEGIN
DECLARE @RET INT = 0
IF EXISTS 
	(SELECT *
     FROM TBLUSER U
		JOIN TBLAPPLICATION A ON U.UserID = A.UserID
        JOIN TBLAPP_STATUS AST ON A.ApplicationID = AST.ApplicationID
        JOIN TBLFEEDBACK F ON AST.AppStatusID = F.AppStatusID
     WHERE DATEDIFF(DAY, A.AppliedDate, GETDATE()) < 365
        AND LEN(F.FeedbackText) < 10)
	BEGIN
        SET @RET = 1
	END
    RETURN @RET
END
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT CK_noUserAppDate365AndFB10Char
CHECK (dbo.fn_noUserAppDate365AndFB10Char() = 0)
GO

-- Views

-- Aswin:

-- Top 10 Applied Positions
CREATE OR ALTER VIEW vw_RankedApplPositions
AS
SELECT P.PositionID, P.PositionName, COUNT(ApplicationID) as numApplicationsPostions, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as DRank
FROM tblPOSITION P 
	JOIN tblJOB_POSTING JP on P.PositionID = JP.PositionID
	JOIN tblAPPLICATION A on JP.JobPostingID = A.JobPostingID
GROUP BY P.PositionID, P.PositionName
GO

CREATE OR ALTER VIEW vw_Top5AppliedPositions
AS
SELECT PositionName, numApplicationsPostions, DRank
FROM vw_RankedApplPositions
WHERE DRank BETWEEN 1 AND 10
GO

-- Top 10 Applied Companies
CREATE OR ALTER VIEW vw_RankedApplComp
AS
SELECT C.CompanyID, C.CompanyName, COUNT(ApplicationID) as numApplicationsCompanies, DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as DRank
FROM tblCOMPANY C
	JOIN tblCOMPANY_DEPT CD on C.CompanyID = CD.CompanyID
	JOIN tblJOB_POSTING JP on CD.CompanyDeptID = JP.CompanyDeptID
	JOIN tblAPPLICATION A on JP.JobPostingID = A.JobPostingID
GROUP BY C.CompanyID, C.CompanyName
GO

CREATE OR ALTER VIEW vw_Top5AppliedCompanies
AS
SELECT CompanyName, numApplicationsCompanies, DRank
FROM vw_RankedApplComp
WHERE DRank BETWEEN 1 AND 10
GO

-- Marina:

-- Top 5 Applied Industries
CREATE OR ALTER VIEW vw_Top5AppliedIndust 
AS
SELECT TOP 5 I.IndustryID, I.IndustryName, COUNT(ApplicationID) AS NumAppsIndustry
FROM tblINDUSTRY I
	JOIN tblCOMPANY C ON I.IndustryID = C.IndustryID
	JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
	JOIN tblJOB_POSTING JP ON CD.CompanyDeptID = JP.CompanyDeptID
	JOIN tblAPPLICATION A on A.JobPostingID = JP.JobPostingID
GROUP BY I.IndustryID, I.IndustryName
ORDER BY COUNT(ApplicationID) DESC
GO


-- Top 5 Applied Job Location
CREATE OR ALTER VIEW vw_Top5AppliedJobLoc 
AS
SELECT TOP 5 L.LocationID, L.LocationName, COUNT(ApplicationID) AS NumAppsLoc
FROM tblLOCATION L
	JOIN tblJOB_POSTING JP ON L.LocationID = JP.LocationID
	JOIN tblAPPLICATION A on A.JobPostingID = JP.JobPostingID
GROUP BY L.LocationID, L.LocationName
ORDER BY COUNT(ApplicationID) DESC
GO

-- Cafter:

-- Top 10 Applicants' Universities
CREATE OR ALTER VIEW vw_Top10University
AS
SELECT TOP 10 U.UniversityID, U.UniversityName, COUNT(DISTINCT A.UserID) AS NumberOfApplicants
FROM tblUNIVERSITY U
   JOIN tblDEGREE_USER DU ON U.UniversityID = DU.UniversityID
   JOIN tblAPPLICATION A ON DU.UserID = A.UserID
GROUP BY U.UniversityID, U.UniversityName
ORDER BY NumberOfApplicants DESC
GO


-- Top 5 Degrees Of Applicants
CREATE OR ALTER VIEW vw_Top5Degree AS
SELECT TOP 5 D.DegreeID, D.DegreeName, COUNT(*) AS NumberOfDegreeHolders
FROM tblDEGREE_USER DU
   JOIN tblDEGREE D ON DU.DegreeID = D.DegreeID
GROUP BY D.DegreeID, D.DegreeName
ORDER BY NumberOfDegreeHolders DESC
GO

-- Danny:

-- Top 5 Companies in the 'Software Engineering' industry based on number of departments
CREATE OR ALTER VIEW vw_Top5CompaniesSoftwareNumDepts
AS
SELECT TOP 5 C.CompanyID, C.CompanyName, COUNT(DISTINCT CD.DeptID) AS NumDepartmentsInSoftwareEngineering
FROM tblCOMPANY C
   JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
   JOIN tblDEPARTMENT D ON CD.DeptID = D.DeptID
   JOIN tblINDUSTRY I ON C.IndustryID = I.IndustryID
WHERE I.IndustryName = 'Software Engineering'
GROUP BY C.CompanyID, C.CompanyName
ORDER BY NumDepartmentsInSoftwareEngineering DESC
GO

-- Top 10 applied Job Postings in the “Data” Industry that were posted less than a year ago
CREATE OR ALTER VIEW vw_TopJobPostingsDataIndus365
AS
SELECT TOP 10 JP.JobPostingID, P.PositionName, C.CompanyName, I.IndustryName, JP.PostedDate
FROM tblINDUSTRY I
   JOIN tblCOMPANY C ON I.IndustryID = C.IndustryID
   JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
   JOIN tblDEPARTMENT D ON CD.DeptID = D.DeptID
   JOIN tblJOB_POSTING JP ON CD.CompanyDeptID = JP.CompanyDeptID
   JOIN tblPOSITION P on JP.PositionID = P.PositionID
WHERE I.IndustryName LIKE '%Data%'
   AND JP.PostedDate >= DATEADD(DAY, -365, GETDATE())
GROUP BY JP.JobPostingID, P.PositionName, C.CompanyName, I.IndustryName, JP.PostedDate
ORDER BY JP.PostedDate DESC
GO

-- Computed Columns

-- Aswin:

-- Number of Applications for each User
CREATE OR ALTER FUNCTION fn_numAppsUser(@PK INT)
RETURNS INT
AS
BEGIN 
	DECLARE @RET INT = 
	(SELECT COUNT(A.ApplicationID)
	 FROM tblUSER U
		join tblAPPLICATION A on U.UserID = A.UserID
	 WHERE U.UserID = @PK)
RETURN @RET
END
GO

ALTER TABLE tblUSER
ADD NumApplications AS (dbo.fn_numAppsUser(UserID))
GO

-- Number of Applications for each Job Posting
CREATE OR ALTER FUNCTION fn_numAppsJobPosting(@PK_ID INT)
RETURNS INT
AS
BEGIN 
	DECLARE @RET INT = 
	(SELECT COUNT(A.ApplicationID)
	 FROM tblJOB_POSTING JP
		join tblAPPLICATION A on JP.JobPostingID = A.JobPostingID
	 WHERE JP.JobPostingID = @PK_ID)
RETURN @RET
END
GO

ALTER TABLE tblJOB_POSTING
ADD NumApplications AS (dbo.fn_numAppsJobPosting(JobPostingID))
GO

-- Marina:

-- Total experience of Users who have been accepted by each company
CREATE OR ALTER FUNCTION fn_totalExp(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT = 
	(SELECT COUNT(EU.ExpUserID)
     FROM tblUSER U
	   JOIN tblEXP_USER EU ON U.UserID = EU.UserID
	   JOIN tblAPPLICATION A ON U.UserID = A.UserID
	   JOIN tblAPP_STATUS AST ON A.ApplicationID = AST.ApplicationID
	   JOIN tblSTATUS S ON AST.StatusID = S.StatusID
	   JOIN tblJOB_POSTING JP ON A.JobPostingID = JP.JobPostingID
	   JOIN tblCOMPANY_DEPT CD ON JP.CompanyDeptID = CD.CompanyDeptID
	   JOIN tblCOMPANY C ON CD.CompanyID = C.CompanyID
     WHERE S.StatusName = 'Offer Sent'
	   AND C.CompanyID = @PK_ID)
RETURN @RET
END
GO

ALTER TABLE tblCOMPANY
ADD TotalExperience AS (dbo.fn_totalExp(CompanyID))
GO

-- Most recent degree each user has
CREATE OR ALTER FUNCTION fn_latestDeg(@PK_ID INT)
RETURNS VARCHAR(50)
AS
BEGIN
   DECLARE @RET VARCHAR(50) = 
   (SELECT TOP 1 D.DegreeName
	FROM tblDEGREE D
		JOIN tblDEGREE_USER DU on D.DegreeID = DU.DegreeID
		JOIN tblUSER U on DU.UserID = U.UserID
    WHERE U.UserID = @PK_ID
    ORDER BY DU.DegreeUserDate DESC)
RETURN @RET
END
GO


ALTER TABLE tblUSER
ADD LatestDegree AS (dbo.fn_latestDeg(UserID))
GO

-- Cafter

-- Number of Feedbacks on each application
CREATE OR ALTER FUNCTION fn_numFeedback(@PK_ID INT)
RETURNS INT
AS
BEGIN
   DECLARE @RET INT =
   (SELECT COUNT(F.FeedbackID)
    FROM tblAPPLICATION A
       JOIN tblAPP_STATUS AP ON A.ApplicationID = AP.ApplicationID
       JOIN tblFEEDBACK F ON AP.AppStatusID = F.AppStatusID
    WHERE A.ApplicationID = @PK_ID)
RETURN @RET
END
GO

ALTER TABLE tblAPPLICATION
ADD NumberFeedbacks AS (dbo.fn_numFeedback(ApplicationID))
GO

-- Duration of application process for each user
CREATE OR ALTER FUNCTION fn_durAppProc(@PK_ID INT)
RETURNS INT
AS
BEGIN
	DECLARE @RET INT =
    (SELECT DATEDIFF(DAY, A.AppliedDate, AP.AppStatusDate)
    FROM tblAPPLICATION A
       JOIN tblAPP_STATUS AP ON A.ApplicationID = AP.ApplicationID
       JOIN tblUSER U ON A.UserID = U.UserID
    WHERE U.UserID = @PK_ID)
RETURN @RET
END
GO

ALTER TABLE tblAPPLICATION
ADD ApplicationDuration AS (dbo.fn_durAppProc(UserID))
GO

-- Danny

-- Number of Departments for companies who are in the 'Software Engineering’ Industry
CREATE OR ALTER FUNCTION fn_numDepartmentsSoftware(@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 
	(SELECT COUNT(CD.DeptID)
	FROM tblCOMPANY C
    	JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
		JOIN tblDEPARTMENT D ON CD.DeptID = D.DeptID
		JOIN tblINDUSTRY I on I.IndustryID  = C.IndustryID
	WHERE C.CompanyID = @PK_ID
		AND IndustryName = 'Software Engineering')
RETURN @RET
END
GO
ALTER TABLE tblCOMPANY
ADD NumDepartmentsSoftware AS (dbo.fn_numDepartmentsSoftware(CompanyID))
GO

-- Number of Job Postings that were posted less than 365 days ago for each Industry
CREATE OR ALTER FUNCTION fn_numJP365Indus(@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 
	(SELECT COUNT(DISTINCT JP.JobPostingID)
	FROM tblINDUSTRY I
		JOIN tblCOMPANY C ON I.IndustryID = C.IndustryID
		JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
		JOIN tblDEPARTMENT D ON CD.DeptID = D.DeptID
		JOIN tblJOB_POSTING JP ON cd.CompanyDeptID = JP.CompanyDeptID
	WHERE
		I.IndustryID  = @PK_ID
		AND JP.PostedDate > DATEADD(DAY, -365, GETDATE()))
    RETURN @RET
END
GO

ALTER TABLE tblINDUSTRY
ADD NumJobPostings365 AS (dbo.fn_numJP365Indus(IndustryID))
GO