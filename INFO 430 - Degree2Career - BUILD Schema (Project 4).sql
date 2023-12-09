CREATE DATABASE G7FinalProject
GO

USE G7FinalProject
GO

CREATE TABLE tblUNIVERSITY (
    UniversityID INT IDENTITY(1,1) PRIMARY KEY,
    UniversityName VARCHAR(50) NOT NULL)

CREATE TABLE tblUSER (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    UserFName VARCHAR(50) NOT NULL,
    UserLName VARCHAR(50) NOT NULL,
	UserDOB DATE NOT NULL)

CREATE TABLE tblEXPERIENCE (
    ExperienceID INT IDENTITY(1,1) PRIMARY KEY,
    ExperienceName VARCHAR(50) NOT NULL,
	ExperienceDescr VARCHAR(500) NOT NULL)

CREATE TABLE tblEXP_USER (
    ExpUserID INT IDENTITY(1,1) PRIMARY KEY,
	UserID INT NOT NULL,
	ExperienceID INT NOT NULL,
    BeginDate DATE NOT NULL, 
	EndDate DATE NOT NULL)

CREATE TABLE tblDEGREE (
    DegreeID INT IDENTITY(1,1) PRIMARY KEY,
    DegreeName VARCHAR(50) NOT NULL)

CREATE TABLE tblDEGREE_USER (
	DegreeUserID INT IDENTITY(1,1) PRIMARY KEY,
	DegreeID INT NOT NULL,
	UserID INT NOT NULL,
	UniversityID INT NOT NULL,
	DegreeUserDate DATE NOT NULL)

CREATE TABLE tblLOCATION (
	LocationID INT IDENTITY(1,1) PRIMARY KEY,
	LocationName VARCHAR(50) NOT NULL)

CREATE TABLE tblPOSITION (
	PositionID INT IDENTITY(1,1) PRIMARY KEY,
	PositionName VARCHAR(50) NOT NULL)

CREATE TABLE tblDEPARTMENT (
	DeptID INT IDENTITY(1,1) PRIMARY KEY,
	DeptName VARCHAR(50) NOT NULL)

CREATE TABLE tblCOMPANY_DEPT (
	CompanyDeptID INT IDENTITY(1,1) PRIMARY KEY,
	DeptID INT NOT NULL,
	CompanyID INT NOT NULL)

CREATE TABLE tblJOB_POSTING (
    JobPostingID INT IDENTITY(1,1) PRIMARY KEY,
	PositionID INT NOT NULL,
	CompanyDeptID INT NOT NULL,
	LocationID INT NOT NULL,
    PostedDate DATE NOT NULL,
	DueDate DATE NOT NULL)

CREATE TABLE tblAPPLICATION (
    ApplicationID INT IDENTITY(1,1) PRIMARY KEY,
	UserID INT NOT NULL, 
	JobPostingID INT NOT NULL,
    AppliedDate DATE NOT NULL)

CREATE TABLE tblSTATUS (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL)

CREATE TABLE tblAPP_STATUS (
	AppStatusID INT IDENTITY(1,1) PRIMARY KEY,
	ApplicationID INT NOT NULL,
	StatusID INT NOT NULL,
	AppStatusDate DATE NOT NULL)

CREATE TABLE tblFEEDBACK (
    FeedbackID INT IDENTITY(1,1) PRIMARY KEY,
	AppStatusID INT NOT NULL,
	RatingID INT NOT NULL,
	FeedbackText VARCHAR(500) NOT NULL,
    FeedbackDate DATE NOT NULL)

CREATE TABLE tblRATING (
    RatingID INT IDENTITY(1,1) PRIMARY KEY,
    RatingName VARCHAR(50) NOT NULL,
	RatingValue INT NOT NULL)

CREATE TABLE tblCOMPANY (
    CompanyID INT IDENTITY(1,1) PRIMARY KEY,
	IndustryID INT NOT NULL,
    CompanyName VARCHAR(50) NOT NULL)

CREATE TABLE tblINDUSTRY (
    IndustryID INT IDENTITY(1,1) PRIMARY KEY,
    IndustryName VARCHAR(50) NOT NULL,
	IndustryDescr VARCHAR(500) NOT NULL)

ALTER TABLE tblEXP_USER
ADD CONSTRAINT FK1
FOREIGN KEY (UserID) 
REFERENCES tblUSER (UserID),
FOREIGN KEY (ExperienceID)
REFERENCES tblEXPERIENCE (ExperienceID);

ALTER TABLE tblDEGREE_USER
ADD CONSTRAINT FK2
FOREIGN KEY (DegreeID) 
REFERENCES tblDEGREE (DegreeID),
FOREIGN KEY (UserID) 
REFERENCES tblUSER (UserID),
FOREIGN KEY (UniversityID) 
REFERENCES tblUNIVERSITY (UniversityID);

ALTER TABLE tblAPPLICATION
ADD CONSTRAINT FK3
FOREIGN KEY (UserID)
REFERENCES tblUSER (UserID),
FOREIGN KEY (JobPostingID)
REFERENCES tblJOB_POSTING (JobPostingID);

ALTER TABLE tblAPP_STATUS
ADD CONSTRAINT FK4
FOREIGN KEY (ApplicationID)
REFERENCES tblAPPLICATION (ApplicationID),
FOREIGN KEY (StatusID)
REFERENCES tblSTATUS (StatusID);

ALTER TABLE tblFEEDBACK
ADD CONSTRAINT FK5
FOREIGN KEY (AppStatusID)
REFERENCES tblAPP_STATUS (AppStatusID),
FOREIGN KEY (RatingID)
REFERENCES tblRATING (RatingID);

ALTER TABLE tblCOMPANY
ADD CONSTRAINT FK6
FOREIGN KEY (IndustryID)
REFERENCES tblINDUSTRY (IndustryID);

ALTER TABLE tblCOMPANY_DEPT
ADD CONSTRAINT FK7
FOREIGN KEY (DeptID)
REFERENCES tblDEPARTMENT (DeptID),
FOREIGN KEY (CompanyID)
REFERENCES tblCOMPANY (CompanyID);

ALTER TABLE tblJOB_POSTING
ADD CONSTRAINT FK8
FOREIGN KEY (PositionID)
REFERENCES tblPOSITION (PositionID),
FOREIGN KEY (CompanyDeptID)
REFERENCES tblCOMPANY_DEPT (CompanyDeptID),
FOREIGN KEY (LocationID)
REFERENCES tblLOCATION (LocationID);