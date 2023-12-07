
USE G7FinalProject
GO

--top companies" based on the number of departments in the 'Software Engineering' industry
CREATE VIEW vw_TopCompanies AS
SELECT
    c.CompanyID,
    c.CompanyName,
    COUNT(DISTINCT cd.DeptID) AS NumDepartmentsInSoftwareEngineering
FROM
    tblcompany c
JOIN
    tblcompany_dept cd ON c.CompanyID = cd.CompanyID
JOIN
    tbldepartment d ON cd.DeptID = d.DeptID
JOIN
    tblIndustry i ON c.IndustryID = i.IndustryID
WHERE
    i.IndustryName = 'Software Engineering'
GROUP BY
    c.CompanyID, c.CompanyName;
GO

--the top job postings in the '%Data%' industry with a posted date less than 365 days ago
CREATE VIEW vw_TopJobPostings AS
SELECT
    i.IndustryID,
    i.IndustryName,
    jp.JobPostingID,   
    jp.PostedDate
FROM
    tblIndustry i
JOIN
    tblcompany c ON i.IndustryID = c.IndustryID
JOIN
    tblcompany_dept cd ON c.CompanyID = cd.CompanyID
JOIN
    tbldepartment d ON cd.deptID = d.deptID
JOIN
    tblJOB_POSTING jp ON cd.CompanyDeptID = jp.CompanyDeptID
WHERE
    i.IndustryName LIKE '%Data%'
    AND jp.PostedDate >= DATEADD(DAY, -365, GETDATE());