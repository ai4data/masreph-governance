-- ============================================
-- Platform: FABRIC
-- Schema/Source: TalentPool
-- Generated: 2026-03-18T12:18:16.886339
-- Datasets: 2
-- ============================================

-- Dataset: GDS46625

-- This employee dataset supports human resource office operations. Key applications include data analy
CREATE TABLE [TalentPool].[NetherlandsFinancePersonnelData] (
    Id INT NOT NULL,
    EmployeeId VARCHAR(255) NOT NULL,
    MasrephPersonnelKey UNIQUEIDENTIFIER NOT NULL,
    NationalIdHash VARCHAR(255) NOT NULL,
    FullName VARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    GenderCode VARCHAR(255),
    JobTitle VARCHAR(255) NOT NULL,
    JobFamily VARCHAR(255),
    DepartmentName VARCHAR(255) NOT NULL,
    BusinessUnit VARCHAR(255) NOT NULL,
    EmploymentStatus VARCHAR(255) NOT NULL,
    EmploymentType VARCHAR(255) NOT NULL,
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    BaseSalaryAnnualEur DECIMAL(15,2) NOT NULL,
    BonusTargetPercentage DECIMAL(5,2),
    FtePercentage DECIMAL(5,2) NOT NULL,
    WorkLocationCity VARCHAR(255) NOT NULL,
    WorkLocationPostalCode VARCHAR(255) NOT NULL,
    WorkCountryCode VARCHAR(255) NOT NULL,
    ManagerEmployeeId VARCHAR(255),
    WorkEmailAddress VARCHAR(320) NOT NULL,
    WorkPhoneNumber VARCHAR(255),
    IbanMasked VARCHAR(34),
    RecordEffectiveTimestamp DATETIME2 NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_NetherlandsFinancePe PRIMARY KEY (Id)
);


-- Dataset: GDS84371

-- This employee dataset supports human resource office operations. Key applications include data analy
CREATE TABLE [TalentPool].[NLFinanceTalentPool] (
    Id INT NOT NULL,
    TalentId UNIQUEIDENTIFIER NOT NULL,
    MasrephEmployeeId VARCHAR(255) NOT NULL,
    NationalIdentifierHash VARCHAR(255),
    FullName VARCHAR(255) NOT NULL,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
    Gender VARCHAR(255),
    DateOfBirth DATE,
    CountryOfCitizenship VARCHAR(255),
    WorkLocationCountry VARCHAR(255) NOT NULL,
    WorkLocationCity VARCHAR(255) NOT NULL,
    EmailAddress VARCHAR(320) NOT NULL,
    PhoneNumber VARCHAR(255),
    PrimaryLanguage VARCHAR(255),
    YearsOfFinancialExperience DECIMAL(4,1) NOT NULL,
    HighestEducationLevel VARCHAR(255),
    HighestEducationField VARCHAR(255),
    HighestEducationInstitution VARCHAR(255),
    CurrentRoleTitle VARCHAR(255) NOT NULL,
    CurrentDepartment VARCHAR(255) NOT NULL,
    EmploymentType VARCHAR(255) NOT NULL,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    IsActiveEmployee BIT NOT NULL,
    TalentPoolSegment VARCHAR(255),
    KeySkills VARCHAR(MAX),
    ProfessionalCertifications VARCHAR(MAX),
    LeadershipPotentialRating INT,
    PerformanceRatingLastCycle INT,
    AnnualBaseSalaryEur DECIMAL(15,2),
    VariableCompensationTargetPercent DECIMAL(5,2),
    InternalMobilityEligibility BIT NOT NULL,
    LastPromotionDate DATE,
    SuccessionPlanRole VARCHAR(255),
    CriticalRoleFlag BIT NOT NULL,
    RiskOfLeavingScore INT,
    LastInternalMoveDate DATE,
    ManagerEmployeeId VARCHAR(255),
    ManagerFullName VARCHAR(255),
    GdprConsentFlag BIT NOT NULL,
    GdprConsentDate DATE,
    DataSourceSystem VARCHAR(255) NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    ProfileReviewDueDate DATE,
    RemoteWorkEligibility BIT NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_NLFinanceTalentPool PRIMARY KEY (Id)
);


