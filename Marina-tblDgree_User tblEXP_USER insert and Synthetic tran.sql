-- Get UniversityID Stored Procedure
CREATE OR ALTER PROCEDURE GetUniversityID
@UniversityName VARCHAR(50),
@UniversityID INT OUTPUT
AS
SET @UniversityID = (
    SELECT UniversityID
    FROM tblUNIVERSITY 
    WHERE UniversityName = @UniversityName
)
GO

-- Get DegreeID Stored Procedure
CREATE OR ALTER PROCEDURE GetDegreeID
@DegreeName VARCHAR(50),
@DegreeID INT OUTPUT
AS
SET @DegreeID = (
    SELECT DegreeID
    FROM tblDEGREE 
    WHERE DegreeName = @DegreeName
)
GO

-- Get UserID Stored Procesure 
CREATE OR ALTER PROCEDURE GetUserID
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@UserID INT OUTPUT
AS
SET @UserID = (
    SELECT UserID
    FROM tblUSER 
    WHERE UserFname = @Fname
    AND UserLname = @Lname
    AND UserDOB  = @DOB 
)
GO

-- Get ExperienceID Stored Procedure
CREATE OR ALTER PROCEDURE GetExperienceID
@ExperienceName VARCHAR(50),
@ExperienceID INT OUTPUT
AS
SET @ExperienceID = (
    SELECT ExperienceID
    FROM tblEXPERIENCE 
    WHERE ExperienceName = @ExperienceName
)
GO

-- Insert Procedure for tblDEGREE_USER
CREATE OR ALTER PROCEDURE InsertDegreeUser
@UniversityName VARCHAR(50),
@DegreeName VARCHAR(50),
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@DegreeUserDate DATE
AS
DECLARE @UniversityID INT, @DegreeID INT, @UserID INT
EXEC GetUniversityID
@UniversityName = @UniversityName,
@UniversityID = @UniversityID OUTPUT
IF @UniversityID IS NULL
BEGIN
    PRINT '@UniversityID is not found, please check your input or try another ID.';
    THROW 54412, '@UniversityID is null.', 1;
END

EXEC GetDegreeID
@DegreeName = @DegreeName,
@DegreeID = @DgreeID OUTPUT
IF @DegreeID IS NULL
BEGIN
    PRINT '@DegreeID is not found, please check your input or try another ID.';
    THROW 54412, '@DegreeID is null.', 1;
END

EXEC GetUserID
@Fname = @Fname,
@Lname = @Lname,
@DOB = @DOB,
@UserID = @UserID OUTPUT
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

-- Insert Procedure for tblEXP_USER
CREATE OR ALTER PROCEDURE insertExpUser
@ExperienceName VARCHAR(50),
@Fname VARCHAR(50),
@Lname VARCHAR(50),
@DOB DATE,
@BeginDate DATE,
@EndDate DATE
AS
DECLARE @UserID INT, @ExperienceID INT 
EXEC GetUserID
@Fname = @Fname,
@Lname = @Lname,
@DOB = @DOB,
@UserID = @UserID OUTPUT
IF @UserID IS NULL
BEGIN 
    PRINT '@UserID is not fount, please check your inputs.';
    THROW 54412, '@UserID is null.', 1;
END

EXEC GetExperienceID
@ExperienceName = @ExperienceName,
@ExperienceID = @ExperienceID OUTPUT
IF @ExperienceIF IS NULL
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

-- Synthetic Transaction of InsertDegreeUser Procedure
CREATE OR ALTER PROCEDURE wrapper_InsertDegreeUser
@RUN INT 
AS
DECLARE 
    @UniversityName VARCHAR(50),
    @DegreeName VARCHAR(50),
    @F VARCHAR(50),
    @L VARCHAR(50),
    @Birthday DATE,
    @DegreeDate DATE

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
            SET @UserID = (SELECT RAND()*@UserCount + 1)
        END
    
    SET @UniversityName = (SELECT UniversityName FROM tblUNIVERSITY WHERE UniversityID = @UniversityPK)
    SET @DegreeName = (SELECT DegreeName FROM tblDEGREE WHERE DegreeID = @DegreePK)
    SET @F = (SELECT UserFname FROM tblUSER WHERE UserID = @UserPK)
    SET @L = (SELECT UserLname FROM tblUSER WHERE UserID = @UserPK)
    SET @Birthday = (SELECT UserDOB FROM tblUSER WHERE UserID = @UserPK)
    SET @DegreeDate = (SELECT DATEADD(DAY, -(SELECT RAND()*10000), GetDate()))

    EXEC InsertDegreeUser
    @UniversityName = @UniversityName,
    @DegreeName = @DegreeName,
    @Fname = @F,
    @Lname = @L,
    @DOB = @Birthday,
    @DegreeUserDate = @DegreeDate 
    SET @RUN = @RUN - 1
    END 
GO

-- Synthetic tansaction for InsertExpUser procedure.
CREATE OR ALTER PROCEDURE wrapper_InsertExpUser
@RUN INT
AS 
DECLARE 
    @Fname VARCHAR(50),
    @Lname VARCHAR(50),
    @DOB VARCHAR(50),
    @ExperienceName VARCHAR(50),
    @BeginDate DATE,
    @EndDate DATE

DECLARE @UserPK INT, @ExpPK INT
DECLARE @User_Count INT = (SELECT COUNT(*) FROM tblUSER)
DECLARE @ExpCount INT = (SELECT COUNT(*) FROM tblEXPERIENCE)

WHILE @RUN > 0
BEGIN
    SET @UserPK = (SELECT RAND() * @User_Count + 1)
    SET @ExpPK = (SELECT RAND() * @ExpCount + 1)
    SET @Fname = (SELECT UserFname FROM tblUSER WHERE UserID = @UserFK)
    SET @Lname = (SELECT UserLname FROM tblUSER WHERE UserID = @UserFK)
    SET @DOB = (SELECT UserDOB FROM tblUSER WHERE USERID = @UserFK)
    SET @ExpName = (SELECT ExperienceName FROM tblEXPERIENCE WHERE ExperienceID = @ExperienceID)
    SET @BeginDate = (SELECT DATEDIFF(DAY, -RAND() * 100000, GETDATE()))
    SET @EndDate = (SELECT DATEDIFF(DAY, -RAND() * 10000, GETDATE()))

    EXEC InsertExpUser 
    @ExperienceName = @ExperienceName,
    @Fname = @Fname,
    @Lname = @Lname,
    @DOB = @DOB,
    @BeginDate = @BeginDate,
    @EndDate = @EndDate
    SET @RUN = @RUN - 1
    END
GO