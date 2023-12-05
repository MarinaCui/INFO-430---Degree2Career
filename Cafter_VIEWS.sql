-- View 1: Top 10 Applicants' Universities 
CREATE VIEW vw_Top10university 
AS
SELECT TOP 10 U.UniversityName, COUNT(DISTINCT A.UserID) AS NumberOfApplicants
FROM 
    tblUNIVERSITY U
    JOIN tblDEGREE_USER DU ON U.UniversityID = DU.UniversityID
    JOIN tblAPPLICATION A ON DU.UserID = A.UserID
GROUP BY U.UniversityName
ORDER BY NumberOfApplicants DESC
GO

-- View 2: Top 5 Degrees
CREATE VIEW vw_Top5Degree AS
SELECT TOP 5 D.DegreeName, COUNT(*) AS NumberOfDegreeHolders
FROM tblDEGREE_USER DU
    JOIN tblDEGREE D ON DU.DegreeID = D.DegreeID
GROUP BY D.DegreeName
ORDER BY NumberOfDegreeHolders DESC