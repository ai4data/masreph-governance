-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinanceNetworkService
-- Generated: 2026-03-18T11:48:10.811275
-- Datasets: 1
-- ============================================

-- Dataset: GDS10546
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceNetworkService')
    EXEC('CREATE SCHEMA [FinanceNetworkService]');

-- Commercial client master entity including identification, segmentation, and contact details.
CREATE TABLE [FinanceNetworkService].[tblClient] (
    ClientKey INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    ClientLegalName NVARCHAR(255) NOT NULL,
    ClientTradingName NVARCHAR(255),
    ClientRegistrationNumber NVARCHAR(255) NOT NULL,
    ClientCountryIso2 NVARCHAR(255) NOT NULL,
    ClientIndustryCodeNace NVARCHAR(255),
    UltimateParentClientId NVARCHAR(255),
    ClientOnboardingDate DATE NOT NULL,
    AnnualTurnoverAmount DECIMAL(18,4),
    EbitdaMarginPercent DECIMAL(18,4),
    GdprConsentFlag BIT NOT NULL,
    PreferredCommunicationLanguage NVARCHAR(255),
    ClientSegment NVARCHAR(255) NOT NULL,
    ClientTier NVARCHAR(255),
    OnboardingChannel NVARCHAR(255),
    PrimaryContactEmail NVARCHAR(255),
    PrimaryContactPhone NVARCHAR(255),
    SanctionScreeningStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientKey)
);

-- Lending legal entity within the group providing asset-based lending facilities.
CREATE TABLE [FinanceNetworkService].[tblLender] (
    LenderKey INT NOT NULL,
    LenderId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLender PRIMARY KEY (LenderKey)
);

-- Internal relationship manager responsible for commercial client relationships.
CREATE TABLE [FinanceNetworkService].[tblRelationshipManager] (
    RelationshipManagerKey INT NOT NULL,
    RelationshipManagerId NVARCHAR(255) NOT NULL,
    RelationshipManagerName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblRelationshipManag PRIMARY KEY (RelationshipManagerKey)
);

-- Commercial finance relationship between a client and a lender, including risk, exposure, engagement,
CREATE TABLE [FinanceNetworkService].[tblRelationship] (
    RelationshipKey INT NOT NULL,
    RelationshipId NVARCHAR(255) NOT NULL,
    ClientKey INT NOT NULL,
    LenderKey INT NOT NULL,
    RelationshipManagerKey INT NOT NULL,
    FacilityId NVARCHAR(255),
    CreditRiskRating NVARCHAR(255),
    AmlRiskRating NVARCHAR(255),
    KycReviewDate DATE,
    KycNextReviewDate DATE,
    RelationshipStatus NVARCHAR(255) NOT NULL,
    RelationshipStartDate DATE NOT NULL,
    RelationshipEndDate DATE,
    PrimaryBankFlag BIT NOT NULL,
    TotalAbExposureAmount DECIMAL(18,4) NOT NULL,
    UtilizedAbExposureAmount DECIMAL(18,4) NOT NULL,
    AverageLoanYieldPercent DECIMAL(18,4),
    ClientProfitabilityScore INT,
    LastContactTimestamp DATETIME2,
    LastContactChannel NVARCHAR(255),
    NextContactDueDate DATE,
    ContactFrequencyDays INT,
    CrossSellOpportunityFlag BIT NOT NULL,
    CrossSellProductsIdentified NVARCHAR(MAX),
    CovenantBreachFlag BIT NOT NULL,
    DaysPastDueMax INT,
    WatchlistFlag BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblRelationship PRIMARY KEY (RelationshipKey)
);

ALTER TABLE [FinanceNetworkService].[tblRelationship] ADD CONSTRAINT FK_tblRelationship_ClientKey
    FOREIGN KEY (ClientKey) REFERENCES [FinanceNetworkService].[tblClient] (ClientKey);

ALTER TABLE [FinanceNetworkService].[tblRelationship] ADD CONSTRAINT FK_tblRelationship_LenderKey
    FOREIGN KEY (LenderKey) REFERENCES [FinanceNetworkService].[tblLender] (LenderKey);

ALTER TABLE [FinanceNetworkService].[tblRelationship] ADD CONSTRAINT FK_tblRelationship_Relationshi
    FOREIGN KEY (RelationshipManagerKey) REFERENCES [FinanceNetworkService].[tblRelationshipManager] (RelationshipManagerKey);

ALTER TABLE [FinanceNetworkService].[tblClient] ADD CONSTRAINT FK_tblClient_UltimateParentCli
    FOREIGN KEY (UltimateParentClientId) REFERENCES [FinanceNetworkService].[tblClient] (ClientId);


