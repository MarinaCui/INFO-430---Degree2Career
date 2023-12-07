-- Business rule for tblJob_posting: no user whose ExperienceDesc contains 'CSE' can have more than 2 applicationIDs on September to October every year
USE G7FinalProject
GO

CREATE OR ALTER FUNCTION check_CSE ()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
    SELECT *
    FROM tblUSER u
    JOIN tblEXP_USER eu ON u.UserID = eu.UserID
    JOIN tblExperience e ON eu.ExperienceID = e.ExperienceID
    JOIN tblAPPLICATION a ON u.UserID = a.UserID
    WHERE e.ExperienceDescr LIKE '%CSE%'
      AND MONTH(a.AppliedDate) BETWEEN 9 AND 10
      AND YEAR(a.AppliedDate) = YEAR(GETDATE()) 
    GROUP BY u.UserID
    HAVING COUNT(DISTINCT a.ApplicationID) > 2
)
    SET @RET = 1
    RETURN @RET
END 
GO

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT CSEapplicants
CHECK (dbo.check_CSE() = 0)
GO

--  No user can have an application with appliedDate less than 365 days from today and feedbackText less than 10 characters long.
CREATE OR ALTER FUNCTION checklength ()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = 0
    IF EXISTS (
    SELECT 1
    FROM tblUSER u
    INNER JOIN tblAPPLICATION a ON u.UserID = a.UserID
    INNER JOIN tblAPP_STATUS ast ON a.ApplicationID = ast.ApplicationID
    INNER JOIN tblFEEDBACK f ON ast.AppStatusID = f.AppStatusID
    WHERE DATEDIFF(DAY, a.AppliedDate, GETDATE()) < 365
      AND LEN(f.FeedbackText) < 10
)
    SET @RET = 1
    RETURN @RET
END
GO

ALTER TABLE tblFEEDBACK
ADD CONSTRAINT feedbacklength
CHECK (dbo.checklength() = 0)
GO

-- count how many department that was in all those companies who is under 'Software Engineering
CREATE OR ALTER FUNCTION num_dep()
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (
        SELECT COUNT(DISTINCT cd.DeptID)
    FROM tblcompany c
    JOIN tblcompany_dept cd ON c.CompanyID = cd.CompanyID
    JOIN tbldepartment d ON cd.DeptID = d.DeptID
	JOIN tblINDUSTRY ind on ind.IndustryID  = c.IndustryID
    WHERE c.IndustryID = ind.IndustryID
    )
    RETURN @RET
END
GO

ALTER TABLE tblCOMPANY
ADD num_departind AS num_dep()
GO

-- Calculate the number of an industry's job_posting which has a postedDate less than 365 days ago

CREATE OR ALTER FUNCTION yr_data (@industry INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (
        SELECT
    i.IndustryID,
    i.IndustryName,
    COUNT(DISTINCT jp.JobPostingID) AS NumJobPostings
FROM
    tblIndustry i
INNER JOIN
    tblcompany c ON i.IndustryID = c.IndustryID
INNER JOIN
    tblcompany_dept cd ON c.CompanyID = cd.CompanyID
INNER JOIN
    tbldepartment d ON cd.DeptID = d.DeptID
INNER JOIN
    tblJOB_POSTING jp ON cd.CompanyDeptID = jp.CompanyDeptID
WHERE
    i.IndustryName  = @industry
    AND jp.PostedDate >= DATEADD(DAY, -365, GETDATE())
GROUP BY
    i.IndustryID, i.IndustryName
    )
    RETURN @RET
END
GO

ALTER TABLE tblIndustry
ADD num1year AS yr_data(UserID)
GO
