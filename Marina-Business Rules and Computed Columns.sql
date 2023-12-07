-- Business rule for tblDEGREE_USER: No one can apply for job if they graduated longer than two years ago. 

CREATE OR ALTER FUNCTION new_grads ()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF 
    EXISTS (
        SELECT *
        FROM tblDEGREE_USER D
        JOIN tblUSER U ON D.UserID = U.UserID
        JOIN tblAPPLICATION A ON U.UserID = A.UserID
        GROUP BY U.UserID 
        HAVING DATEDIFF(DAY, MAX(D.DegreeUserDate, GETDATE())) > 730
    )
    SET @RET = 1
    RETURN @RET
END 
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT check_new_grads
CHECK (dbo.new_grads() = 0)
GO

-- No job positions posted for over a year (365 days)
CREATE OR ALTER FUNCTION job_over_year ()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF 
    EXISTS (
        SELECT * 
        FROM tblCOMPANY C 
        JOIN tblCOMPANY_DEPT CD ON C.CompanyID = CD.CompanyID
        JOIN tblJOB_POSTING J ON CD.CompanyDeptID = J.CompanyDeptID
        WHERE DATEDIFF(DAY, J.PostedDate, J.DueDate) > 365
    )
    SET @RET = 1
    RETURN @RET
END
GO

ALTER TABLE tblJOB_POSTING 
ADD CONSTRAINT check_job_over_year
CHECK (dbo.job_over_year() = 0)
GO

-- Calculate the total experience of people who had been admitted by each company
CREATE OR ALTER FUNCTION num_exp(@PK INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (
        SELECT COUNT(EU.ExpUserID) AS total_exp
        FROM tblUSER U
        JOIN tblEXP_USER EU ON U.UserID = EU.UserID
        JOIN tblAPPLICATION A ON U.UserID = A.UserID
        JOIN tblAPP_STATUS AST ON A.ApplicationID = AST.ApplicationID
        JOIN tblSTATUS S ON A.StatusID = S.StatusID
        JOIN tblJOB_POSTING JP ON A.JobPostingID = JP.JobPostingID
        JOIN tblCOMPANY_DEPT CD ON JP.CompanyDeptID = CD.CompanyDeptID
        JOIN tblCOMPANY C ON CD.CompanyID = C.CompanyID
        WHERE S.StatusName = 'Send offer'
        AND C.CompanyID = @PK
        GROUP BY U.UserID
    )
    RETURN @RET
END
GO

ALTER TABLE tblCOMPANY
ADD num_experience AS num_exp(CompanyID)
GO

-- Calculate the Latest degree a user has.

CREATE OR ALTER FUNCTION latest_deg (@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (
        SELECT TOP 1 DU.DegreeID
        FROM tblDEGREE_USER DU
        WHERE UD.UserID = @UserID
        ORDER BY DU.DegreeUserDate DESC
    )
    RETURN @RET
END
GO

ALTER TABLE tblDEGREE_USER 
ADD latest_degree AS latest_deg(UserID)
GO
