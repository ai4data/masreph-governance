-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: ModernCorePayments
-- Generated: 2026-03-18T12:08:48.623087
-- Datasets: 1
-- ============================================

-- Dataset: GDS83534
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ModernCorePayments')
    EXEC('CREATE SCHEMA [ModernCorePayments]');

-- Core client persona identity, demographic, employment, and master record metadata for leasing client
CREATE TABLE [ModernCorePayments].[tblClientPersona] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    LeasingCustomerId NVARCHAR(255) NOT NULL,
    NationalIdHashed NVARCHAR(255),
    FullName NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    GenderCode NVARCHAR(255),
    DateOfBirth DATE NOT NULL,
    CountryOfResidence NVARCHAR(255) NOT NULL,
    ResidencyStatusCode NVARCHAR(255),
    PrimaryCity NVARCHAR(255),
    PostalCode NVARCHAR(255),
    OccupationTitle NVARCHAR(255),
    EmployerIndustrySector NVARCHAR(255),
    EmploymentStatusCode NVARCHAR(255),
    MonthlyNetIncomeAmount DECIMAL(18,4),
    DeclaredMonthlyExpenseAmount DECIMAL(18,4),
    RelationshipStartDate DATE,
    ReferralSourceChannel NVARCHAR(255),
    DataRecordCreationTimestamp DATETIME2 NOT NULL,
    DataRecordLastUpdateTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientPersona PRIMARY KEY (ClientPersonaId)
);

-- Aggregated leasing relationship metrics, risk appetite, and servicing context for each client person
CREATE TABLE [ModernCorePayments].[tblClientLeasingProfile] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    RiskAppetiteSegmentCode NVARCHAR(255),
    LeasingClientSegmentCode NVARCHAR(255),
    LastRelationshipReviewDate DATE,
    TotalActiveLeasesCount INT NOT NULL,
    TotalOutstandingLeasingBalance DECIMAL(18,4) NOT NULL,
    AvgLeaseTicketSizeAmount DECIMAL(18,4),
    LeaseProfitabilityScore DECIMAL(18,4),
    ClientLifetimeValueAmount DECIMAL(18,4),
    ChurnRiskScore DECIMAL(18,4),
    CrmRelationshipManagerId NVARCHAR(255),
    PrimaryBranchCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientLeasingProf PRIMARY KEY (ClientPersonaId)
);

-- Primary electronic contact details, communication channel and time preferences, and explicit marketi
CREATE TABLE [ModernCorePayments].[tblClientContactPreference] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    EmailAddress NVARCHAR(255),
    MobilePhoneHashed NVARCHAR(255),
    PreferredContactChannel NVARCHAR(255),
    PreferredLanguageCode NVARCHAR(255),
    PreferredContactTimeWindow NVARCHAR(255),
    MarketingOptInFlag BIT NOT NULL,
    GdprConsentCaptureTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientContactPref PRIMARY KEY (ClientPersonaId)
);

-- Marketing engagement, product holdings, eligibility, social and digital interaction metrics, and mod
CREATE TABLE [ModernCorePayments].[tblClientMarketingProfile] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    ProductHoldingArray NVARCHAR(MAX),
    CrossSellEligibilityFlag BIT NOT NULL,
    LastMarketingCampaignCode NVARCHAR(255),
    LastMarketingResponseCode NVARCHAR(255),
    SocialMediaEngagementLevel NVARCHAR(255),
    FinancialKnowledgeLevelCode NVARCHAR(255),
    PersonaArchetypeCode NVARCHAR(255),
    ServiceSatisfactionScore DECIMAL(18,4),
    DigitalEngagementScore DECIMAL(18,4),
    LastDigitalInteractionTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientMarketingPr PRIMARY KEY (ClientPersonaId)
);


