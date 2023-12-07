-- Get IndustryID Stored Procedure
USE G7FinalProject
GO

CREATE OR ALTER PROCEDURE GetCompanyID
@CompanyName VARCHAR(50),
@CompanyID INT OUTPUT
AS
SET @CompanyID = (
    SELECT tblCOMPANY.CompanyID
    FROM tblCompany 
    WHERE tblCOMPANY.CompanyName = @CompanyName
)
GO

-- Get DepartmentID Stored Procedure
CREATE OR ALTER PROCEDURE GetDepartmentID
@DepartmentName VARCHAR(50),
@DepartmentID INT OUTPUT
AS
SET @DepartmentID = (
    SELECT tblDepartment.DeptID
    FROM tblDepartment 
    WHERE DeptName = @DepartmentName
)
GO

-- Get IndustryID Stored Procesure 
CREATE OR ALTER PROCEDURE GetIndustryID
@Industryname VARCHAR(50),

@IndustryID INT OUTPUT
AS
SET @IndustryID = (
    SELECT IndustryID
    FROM tblIndustry 
    WHERE Industryname = @Industryname
    
)
GO



-- Insert Procedure for tblDepartment_Company
CREATE OR ALTER PROCEDURE InsertDepartmentCompany
@CompanyName VARCHAR(50),
@DepartmentName VARCHAR(50)

AS
DECLARE @CompanyID INT, @DepartmentID INT
EXEC GetCompanyID
@CompanyName = @CompanyName,
@CompanyID = @CompanyID OUTPUT
IF @CompanyID IS NULL
BEGIN
    PRINT '@CompanyID is not found, please check your input or try another ID.';
    THROW 54412, '@CompanyID is null.', 1;
END

EXEC GetDepartmentID
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

-- Synthetic Transaction of InsertDepartmentCompany Procedure
CREATE OR ALTER PROCEDURE wrapper_InsertDepartmentCompany
@RUN INT 
AS
DECLARE 
    @CompanyName VARCHAR(50),
    @DepartmentName VARCHAR(50)
    

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
    

    EXEC InsertDepartmentCompany
    @CompanyName = @CompanyName,
    @DepartmentName = @DepartmentName   
    SET @RUN = @RUN - 1
    END 
GO
