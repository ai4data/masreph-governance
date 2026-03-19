-- ============================================
-- Platform: FABRIC
-- Schema/Source: HRworkforcestore
-- Generated: 2026-03-18T12:18:16.888339
-- Datasets: 1
-- ============================================

-- Dataset: GDS86803

-- This employee dataset supports human resource office operations. Key applications include data analy
CREATE TABLE [HRworkforcestore].[MasrephWorkforceInsights] (
    Id INT NOT NULL,
    EmployeeId VARCHAR(255) NOT NULL,
    GlobalEmployeeIdentifier UNIQUEIDENTIFIER NOT NULL,
    LegalEntityCode VARCHAR(255) NOT NULL,
    EmployingCountryCode VARCHAR(255) NOT NULL,
    BusinessUnitName VARCHAR(255) NOT NULL,
    DepartmentName VARCHAR(255) NOT NULL,
    JobFamily VARCHAR(255) NOT NULL,
    JobTitle VARCHAR(255) NOT NULL,
    GradeLevel VARCHAR(255) NOT NULL,
    EmploymentType VARCHAR(255) NOT NULL,
    EmploymentStatus VARCHAR(255) NOT NULL,
    HireDate DATE NOT NULL,
    TerminationDate DATE,
    YearsOfService DECIMAL(5,2) NOT NULL,
    BaseCurrencyCode VARCHAR(255) NOT NULL,
    AnnualBaseSalaryAmount DECIMAL(15,2) NOT NULL,
    AnnualTargetBonusAmount DECIMAL(15,2),
    LastBonusPayoutAmount DECIMAL(15,2),
    BonusEligibilityFlag BIT NOT NULL,
    OvertimeEligibilityFlag BIT NOT NULL,
    FullTimeEquivalentRatio DECIMAL(3,2) NOT NULL,
    WorkLocationCity VARCHAR(255) NOT NULL,
    WorkLocationCountry VARCHAR(255) NOT NULL,
    ManagerEmployeeId VARCHAR(255),
    ManagerLevel VARCHAR(255),
    PerformanceRatingLatest VARCHAR(255),
    PerformanceRatingTrend VARCHAR(255),
    PotentialAssessmentScore INT,
    SuccessionPlanCriticalRoleFlag BIT NOT NULL,
    GenderIdentity VARCHAR(255),
    YearOfBirth INT,
    HighestEducationLevel VARCHAR(255),
    TenureBand VARCHAR(255) NOT NULL,
    RiskOfAttritionScore DECIMAL(5,4),
    LastPromotionDate DATE,
    InternalMobilityMovesCount INT NOT NULL,
    ActiveMarketingConsentFlag BIT NOT NULL,
    MarketingConsentLastUpdatedTs DATETIME2 NOT NULL,
    UnionMembershipFlag BIT,
    WorkingHoursPerWeek DECIMAL(4,1) NOT NULL,
    RemoteWorkEligibilityFlag BIT NOT NULL,
    LastSalaryReviewDate DATE,
    SalaryIncreasePercentageLastReview DECIMAL(5,2),
    HeadcountReportingGroup VARCHAR(255) NOT NULL,
    DataPrivacyConsentScope VARCHAR(255),
    RecordEffectiveTimestamp DATETIME2 NOT NULL,
    RecordSourceSystemCode VARCHAR(255) NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_MasrephWorkforceInsi PRIMARY KEY (Id)
);


