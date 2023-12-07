-- popularity of industries
CREATE VIEW indust AS
SELECT  JP.JobPostingID, COUNT(ApplicationID) AS indust_pop
FROM tblAPPLICATION A 
JOIN tblJOB_POSTING JP ON A.JobPostingID = JP.JobPostingID
JOIN tblCOMPANY_DEPT CD ON JP.CompanyDeptID = CD.CompanyDeptID
JOIN tblCOMPANY C ON CD.CompanyID = C.CompanyID
JOIN tblINDUSTRY I ON C.IndustryID = I.IndustryID
GROUP BY I.IndustryID
ORDER BY COUNT(ApplicationID) DESC
GO

-- popularity of job location
CREATE VIEW location AS 
SELECT JP.JobPostingID, COUNT(ApplicationID) AS loc_pop
FROM tblJOB_POSTING JP
JOIN tblAPPLICATION A ON JP.JobPostingID = A.JobPostingID
GROUP BY JP.LocationID
ORDER BY COUNT(ApplicationID) DESC
GO

-- Case statement that category jobs prospects according the popularity of their industries and location
SELECT (
    CASE 
        WHEN indust_pop > 70000 AND loc_pop > 70000 
            THEN 'Starlight Sectors'
        WHEN indust_pop BETWEEN 40000 AND 69999 AND loc_pop BETWEEN 40000 AND 69999
            THEN 'Steady Streamers'
        WHEN indust_pop BETWEEN 10000 AND 39999 AND loc_pop BETWEEN 10000 AND 39999
            THEN 'Rising Stars'
        WHEN indust_pop BETWEEN 100 AND 9999 AND loc_pop BETWEEN 100 AND 9999
            THEN 'Quiet Quarters'
        ELSE 'Think it over'
    END
) AS job_pros, COUNT(*) AS num_job_pros
FROM indust i 
JOIN location l ON i.JobPostingID = l.JobPostingID
GROUP BY (
    CASE 
        WHEN indust_pop > 70000 AND loc_pop > 70000 
            THEN 'Starlight Sectors'
        WHEN indust_pop BETWEEN 40000 AND 69999 AND loc_pop BETWEEN 40000 AND 69999
            THEN 'Steady Streamers'
        WHEN indust_pop BETWEEN 10000 AND 39999 AND loc_pop BETWEEN 10000 AND 39999
            THEN 'Rising Stars'
        WHEN indust_pop BETWEEN 100 AND 9999 AND loc_pop BETWEEN 100 AND 9999
            THEN 'Quiet Quarters'
        ELSE 'Think it over'
    END
)

