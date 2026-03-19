-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: InsureDataFinanceCatalog
-- Generated: 2026-03-18T12:08:48.591060
-- Datasets: 1
-- ============================================

-- Dataset: GDS19343
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'InsureDataFinanceCatalog')
    EXEC('CREATE SCHEMA [InsureDataFinanceCatalog]');

-- Core customer master record for Masreph consumer customers, including identity, lifecycle, regulator
CREATE TABLE [InsureDataFinanceCatalog].[Customer] (
    CustomerId NVARCHAR(255) NOT NULL,
    MasrephClientNumber NVARCHAR(255) NOT NULL,
    GlobalPartyId NVARCHAR(255),
    CustomerLifecycleStage NVARCHAR(255) NOT NULL,
    CustomerStatus NVARCHAR(255) NOT NULL,
    CustomerType NVARCHAR(255) NOT NULL,
    FullNameEncrypted NVARCHAR(255) NOT NULL,
    PreferredLanguageCode NVARCHAR(255),
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    EuResidencyFlag BIT NOT NULL,
    PrimaryIncomeBand NVARCHAR(255),
    EmploymentStatus NVARCHAR(255),
    RegulatoryClientClassification NVARCHAR(255) NOT NULL,
    KycReviewNextDueDate DATE,
    CustomerProfileJson NVARCHAR(MAX),
    CustomerSegmentId INT NOT NULL,
    PrimaryRelationshipManagerId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
);

-- Lookup table defining customer segments and their business descriptions for Masreph consumer custome
CREATE TABLE [InsureDataFinanceCatalog].[CustomerSegment] (
    CustomerSegmentId INT NOT NULL,
    CustomerSegmentCode NVARCHAR(255) NOT NULL,
    CustomerSegmentDescription NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_CustomerSegment PRIMARY KEY (CustomerSegmentId)
);

-- Master data for Masreph relationship managers responsible for customer relationships.
CREATE TABLE [InsureDataFinanceCatalog].[RelationshipManager] (
    RelationshipManagerId NVARCHAR(255) NOT NULL,
    RelationshipManagerName NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_RelationshipManager PRIMARY KEY (RelationshipManagerId)
);

-- Customer GDPR consent, hashed contact identifiers, and preferred communication channels.
CREATE TABLE [InsureDataFinanceCatalog].[tblCustomerConsent] (
    CustomerId NVARCHAR(255) NOT NULL,
    PrimaryEmailHash NVARCHAR(255),
    PrimaryPhoneHash NVARCHAR(255),
    GdprConsentMarketingFlag BIT NOT NULL,
    GdprConsentDataProcessingFlag BIT NOT NULL,
    ConsentLastUpdatedTimestamp DATETIME2,
    PreferredContactChannels NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomerConsent PRIMARY KEY (CustomerId)
);

-- Customer onboarding, interaction, product holding counts, marketing engagement, satisfaction, and ch
CREATE TABLE [InsureDataFinanceCatalog].[tblCustomerEngagement] (
    CustomerId NVARCHAR(255) NOT NULL,
    OnboardingChannel NVARCHAR(255),
    OnboardingDate DATE,
    FirstProductOpenDate DATE,
    LastInteractionTimestamp DATETIME2,
    LastInteractionChannel NVARCHAR(255),
    InteractionPropensityScore DECIMAL(18,4),
    TotalActiveProductsCount INT NOT NULL,
    ActiveInsurancePoliciesCount INT NOT NULL,
    ActiveCreditAccountsCount INT NOT NULL,
    PrimaryRelationshipValueBand NVARCHAR(255),
    CrossSellOpportunityFlag BIT NOT NULL,
    LastMarketingCampaignId NVARCHAR(255),
    LastMarketingResponseCode NVARCHAR(255),
    CustomerSatisfactionIndex DECIMAL(18,4),
    NetPromoterScoreSegment NVARCHAR(255),
    ComplaintOpenCasesCount INT NOT NULL,
    ChurnRiskScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomerEngagemen PRIMARY KEY (CustomerId)
);

-- Customer-level risk rating, profitability, and lifetime value measures for InsureFin portfolios.
CREATE TABLE [InsureDataFinanceCatalog].[tblCustomerRiskProfitability] (
    CustomerId NVARCHAR(255) NOT NULL,
    CustomerRiskRating INT,
    AnnualizedRevenueEur DECIMAL(18,4),
    AnnualizedDirectCostEur DECIMAL(18,4),
    ContributionMarginEur DECIMAL(18,4),
    RiskAdjustedProfitEur DECIMAL(18,4),
    Clv12mEur DECIMAL(18,4),
    Clv36mEur DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomerRiskProfi PRIMARY KEY (CustomerId)
);

ALTER TABLE [InsureDataFinanceCatalog].[Customer] ADD CONSTRAINT FK_Customer_CustomerSegmentId
    FOREIGN KEY (CustomerSegmentId) REFERENCES [InsureDataFinanceCatalog].[CustomerSegment] (CustomerSegmentId);

ALTER TABLE [InsureDataFinanceCatalog].[Customer] ADD CONSTRAINT FK_Customer_PrimaryRelationshi
    FOREIGN KEY (PrimaryRelationshipManagerId) REFERENCES [InsureDataFinanceCatalog].[RelationshipManager] (RelationshipManagerId);

ALTER TABLE [InsureDataFinanceCatalog].[tblCustomerConsent] ADD CONSTRAINT FK_tblCustomerConsent_Customer
    FOREIGN KEY (CustomerId) REFERENCES [InsureDataFinanceCatalog].[Customer] (CustomerId);

ALTER TABLE [InsureDataFinanceCatalog].[tblCustomerEngagement] ADD CONSTRAINT FK_tblCustomerEngagement_Custo
    FOREIGN KEY (CustomerId) REFERENCES [InsureDataFinanceCatalog].[Customer] (CustomerId);

ALTER TABLE [InsureDataFinanceCatalog].[tblCustomerRiskProfitability] ADD CONSTRAINT FK_tblCustomerRiskProfitabilit
    FOREIGN KEY (CustomerId) REFERENCES [InsureDataFinanceCatalog].[Customer] (CustomerId);


