-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: AfadFinanceStore
-- Generated: 2026-03-18T12:08:48.595354
-- Datasets: 2
-- ============================================

-- Dataset: GDS28450
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AfadFinanceStore')
    EXEC('CREATE SCHEMA [AfadFinanceStore]');

-- Master data for authorized finance agents originating mobility finance business, including identity,
CREATE TABLE [AfadFinanceStore].[tblAuthorizedFinanceAgent] (
    AgentId NVARCHAR(255) NOT NULL,
    MasrephClientId NVARCHAR(255) NOT NULL,
    AgentExternalReferenceId NVARCHAR(255),
    AgentFullLegalName NVARCHAR(255) NOT NULL,
    AgentPreferredName NVARCHAR(255),
    AgentType NVARCHAR(255) NOT NULL,
    RegistrationCountryCode NVARCHAR(255) NOT NULL,
    RegistrationNumber NVARCHAR(255),
    EuGdprConsentFlag BIT NOT NULL,
    PrimaryContactEmail NVARCHAR(255),
    PrimaryContactPhoneNumber NVARCHAR(255),
    OfficeAddressLine1 NVARCHAR(255),
    OfficeAddressLine2 NVARCHAR(255),
    OfficeCity NVARCHAR(255),
    OfficePostalCode NVARCHAR(255),
    OfficeCountryCode NVARCHAR(255),
    PrimaryLanguageCode NVARCHAR(255),
    SupportedLanguageCodes NVARCHAR(MAX),
    MobilitySpecializationSegment NVARCHAR(255),
    ProductExpertiseList NVARCHAR(MAX),
    ActiveAgentFlag BIT NOT NULL,
    OnboardingDate DATE NOT NULL,
    OffboardingDate DATE,
    LastContractRenewalDate DATE,
    AccreditationLevel NVARCHAR(255),
    AvgAnnualAutoLoanOriginations INT,
    AvgAnnualFinancedVolumeEur DECIMAL(18,4),
    CurrentQuarterOriginationsCount INT,
    CurrentQuarterFinancedVolumeEur DECIMAL(18,4),
    YtdCommissionEarnedEur DECIMAL(18,4),
    LifetimeCommissionEarnedEur DECIMAL(18,4),
    CurrentCommissionRatePct DECIMAL(18,4),
    RiskRating NVARCHAR(255),
    ComplianceStatus NVARCHAR(255),
    LastComplianceReviewDate DATE,
    LastContactTimestamp DATETIME2,
    RelationshipManagerId NVARCHAR(255),
    CrmChannelPreference NVARCHAR(255),
    DigitalPortalEnrollmentFlag BIT NOT NULL,
    KycDocumentStatus NVARCHAR(255),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    DeletionIndicatorFlag BIT NOT NULL,
    NotesFreeText NVARCHAR(MAX),
    AgentGeoCoordinates NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAuthorizedFinance PRIMARY KEY (AgentId)
);


-- Dataset: GDS48909
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AfadFinanceStore')
    EXEC('CREATE SCHEMA [AfadFinanceStore]');

-- Core master record for each authorized finance agent, including regulatory status, office/contact de
CREATE TABLE [AfadFinanceStore].[tblAuthorizedFinanceAgent] (
    AgentId NVARCHAR(255) NOT NULL,
    MasrephClientId NVARCHAR(255),
    AgentExternalReference NVARCHAR(255),
    AgentFullName NVARCHAR(255) NOT NULL,
    AgentFirstName NVARCHAR(255),
    AgentLastName NVARCHAR(255),
    AgentType NVARCHAR(255) NOT NULL,
    AgentRoleDescription NVARCHAR(255),
    RegulatorRegistrationNumber NVARCHAR(255),
    RegulatorName NVARCHAR(255),
    RegulatorCountryCode NVARCHAR(255),
    LicenseStatus NVARCHAR(255) NOT NULL,
    LicenseIssueDate DATE,
    LicenseExpiryDate DATE,
    PrimaryOfficeCountryCode NVARCHAR(255) NOT NULL,
    PrimaryOfficeCity NVARCHAR(255) NOT NULL,
    PrimaryOfficePostalCode NVARCHAR(255),
    PrimaryOfficeAddressLine1 NVARCHAR(255),
    PrimaryOfficePhoneNumber NVARCHAR(255),
    PrimaryOfficeEmail NVARCHAR(255),
    PreferredContactChannel NVARCHAR(255),
    ProductExpertiseSegment NVARCHAR(255) NOT NULL,
    ProductExpertiseDetail NVARCHAR(255),
    AverageMonthlyClientRevenue DECIMAL(15,2),
    ActiveClientCount INT,
    PortfolioOutstandingBalance DECIMAL(18,2),
    CommissionRateStandard DECIMAL(5,4),
    CommissionRatePromo DECIMAL(5,4),
    RiskTier NVARCHAR(255),
    KycTrainingCompletedFlag BIT NOT NULL,
    LastKycTrainingDate DATE,
    GdprAcknowledgementFlag BIT NOT NULL,
    LastContactTimestamp DATETIME2,
    AgentOnboardingDate DATE NOT NULL,
    AgentTerminationDate DATE,
    AgentActiveFlag BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    RecordEffectiveStartDate DATE NOT NULL,
    RecordEffectiveEndDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAuthorizedFinance PRIMARY KEY (AgentId)
);

-- Languages in which each authorized finance agent can professionally serve clients (one row per agent
CREATE TABLE [AfadFinanceStore].[tblAuthorizedFinanceAgentLanguage] (
    AgentId NVARCHAR(255) NOT NULL,
    LanguageCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAuthorizedFinance PRIMARY KEY (AgentId, LanguageCode)
);

ALTER TABLE [AfadFinanceStore].[tblAuthorizedFinanceAgentLanguage] ADD CONSTRAINT FK_tblAuthorizedFinanceAgentLa
    FOREIGN KEY (AgentId) REFERENCES [AfadFinanceStore].[tblAuthorizedFinanceAgent] (AgentId);


