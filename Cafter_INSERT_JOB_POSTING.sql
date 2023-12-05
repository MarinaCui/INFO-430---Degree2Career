-- INSERT NEW JOB_POSTING
-- GetPositionID
CREATE PROCEDURE GetPositionID
@PosName varchar(50),
@P_ID INT OUTPUT
AS 

SET @P_ID = (SELECT PostionID
FROM tblPOSITION 
WHERE PositionName = @PosName)
GO

-- GetCompanyDeptID
CREATE PROCEDURE GetCompanyDeptID
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

-- GetLocationID
CREATE PROCEDURE GetLocationID
@LocName varchar(50),
@L_ID INT OUTPUT
AS
SET @L_ID = (SELECT LocationID 
FROM tblLOCATION
WHERE LocationName = @LocName)
GO

-- Base stored procedure INSERT NEW JOB_POSTING
CREATE PROCEDURE G7_INSERT_JOB_POSTING
@pname varchar(50),
@dname varchar(50),
@cname varchar(50),
@lname varchar(50)
AS

DECLARE @P_ID2 INT, @CD_ID2 INT, @L_ID2 INT

EXEC GetPositionID
@PosName = @pname,
@P_ID = @P_ID2 OUTPUT
IF @P_ID2 IS NULL
    BEGIN
        PRINT '@P_ID2 is empty...check spelling';
        THROW 65000, '@P_ID2 cannot be NULL', 1;
    END

EXEC GetCompanyDeptID
@DName = dname,
@CName = cname,
@CD_ID = @CD_ID2 OUTPUT
IF @CD_ID2 IS NULL
    BEGIN
        PRINT '@CD_ID2 is empty...check spelling';
        THROW 65000, '@CD_ID2 cannot be NULL', 1;
    END

EXEC GetLocationID
@LocName = lname,
@L_ID = @L_ID2
IF @L_ID2 IS NULL
    BEGIN
        PRINT '@L_ID2 is empty...check spelling';
        THROW 65000, '@L_ID2 cannot be NULL', 1;
    END

BEGIN TRANSACTION G1
INSERT INTO tblJOB_POSTING (PostionID, CompanyDeptID, LocationID)
VALUES (@P_ID2, @CD_ID2, @L_ID2)
IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION G1
    END
ELSE
COMMIT TRANSACTION G1
GO

-- Synthetic Transaction for tblJOB_POSTING
CREATE PROCEDURE wrapper_uspINSERT_JOB_POSTING
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
    SET @depty = (SELECT D.DeptName 
                FROM tblDEPARTMENT D
                    JOIN tblCOMPANY_DEPT CD ON D.DeptID = CD.DeptID
                WHERE CD.CompanyDeptID = @CompDept_PK)
    SET @compy = (SELECT C.CompanyName
                FROM tblCOMPANY C
                    JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
                WHERE CD.CompanyDeptID = @CompDept_PK)

    SET @Location_PK = (SELECT RAND() * @Location_Count + 1) 
    SET @locy = (SELECT LocationName FROM tblLOCATION WHERE LocationID = @Location_PK)

    EXEC G7_INSERT_JOB_POSTING
    @pname = @posty,
    @dname = @depty,
    @cname = @compy,
    @lname = @locy

    SET @Run = @Run - 1
END 
GO

EXEC wrapper_uspINSERT_JOB_POSTING 100