-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: RealEstateSqlServer
-- Generated: 2026-03-18T12:08:48.584255
-- Datasets: 1
-- ============================================

-- Dataset: GDS15308
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RealEstateSqlServer')
    EXEC('CREATE SCHEMA [RealEstateSqlServer]');

-- Core applicant master data, employment, income, indebtedness, risk and CRM segmentation for mortgage
CREATE TABLE [RealEstateSqlServer].[tblMortgageApplicant] (
    ApplicantId NVARCHAR(255) NOT NULL,
    ApplicantFirstName NVARCHAR(255) NOT NULL,
    ApplicantLastName NVARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    CountryOfResidence NVARCHAR(255) NOT NULL,
    TaxResidencyCountry NVARCHAR(255),
    NationalIdHashed NVARCHAR(255) NOT NULL,
    EmailAddress NVARCHAR(255),
    MobilePhoneHashed NVARCHAR(255),
    EmploymentStatus NVARCHAR(255) NOT NULL,
    EmployerIndustry NVARCHAR(255),
    YearsWithCurrentEmployer DECIMAL(18,4),
    AnnualGrossIncome DECIMAL(18,4) NOT NULL,
    MonthlyNetIncome DECIMAL(18,4),
    TotalExistingDebtAmount DECIMAL(18,4),
    MonthlyDebtServiceAmount DECIMAL(18,4),
    RelationshipTenureYears DECIMAL(18,4),
    KycRiskRating NVARCHAR(255),
    GdprConsentMarketingFlag BIT NOT NULL,
    CrmClientSegment NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblMortgageApplicant PRIMARY KEY (ApplicantId)
);

-- Mortgage application instances with product, risk, collateral, profitability and communication attri
CREATE TABLE [RealEstateSqlServer].[tblMortgageApplication] (
    ApplicationId NVARCHAR(255) NOT NULL,
    ApplicantId NVARCHAR(255) NOT NULL,
    MortgageProductCode NVARCHAR(255) NOT NULL,
    ApplicationSubmissionTimestamp DATETIME2 NOT NULL,
    ApplicationChannel NVARCHAR(255) NOT NULL,
    ApplicationStatus NVARCHAR(255) NOT NULL,
    ApplicationStatusTimestamp DATETIME2 NOT NULL,
    CreditScore INT NOT NULL,
    CreditScoreProvider NVARCHAR(255),
    LoanAmountRequested DECIMAL(18,4) NOT NULL,
    LoanTermMonths INT NOT NULL,
    InterestRateOffered DECIMAL(18,4),
    LoanToValueRatio DECIMAL(18,4),
    PropertyCountry NVARCHAR(255) NOT NULL,
    PropertyType NVARCHAR(255) NOT NULL,
    PropertyValueEstimated DECIMAL(18,4),
    CoApplicantFlag BIT NOT NULL,
    CrossSellEligibilitySegment NVARCHAR(255),
    ProfitabilityScore DECIMAL(18,4),
    ExpectedLifetimeValue DECIMAL(18,4),
    LastContactTimestamp DATETIME2,
    PreferredContactChannel NVARCHAR(255),
    ReferralSourceCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblMortgageApplicati PRIMARY KEY (ApplicationId)
);

ALTER TABLE [RealEstateSqlServer].[tblMortgageApplication] ADD CONSTRAINT FK_tblMortgageApplication_Appl
    FOREIGN KEY (ApplicantId) REFERENCES [RealEstateSqlServer].[tblMortgageApplicant] (ApplicantId);


