-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinanceNetwork
-- Generated: 2026-03-18T12:08:48.576743
-- Datasets: 1
-- ============================================

-- Dataset: GDS10546
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceNetwork')
    EXEC('CREATE SCHEMA [FinanceNetwork]');

-- Core commercial client entity master data for the Commercial Finance Network.
CREATE TABLE [FinanceNetwork].[TblClient] (
    ClientId NVARCHAR(255) NOT NULL,
    ClientLegalName NVARCHAR(255) NOT NULL,
    ClientTradingName NVARCHAR(255),
    ClientRegistrationNumber NVARCHAR(255) NOT NULL,
    ClientCountryIso2 NVARCHAR(255) NOT NULL,
    ClientIndustryCodeNace NVARCHAR(255),
    ClientOnboardingDate DATE NOT NULL,
    AnnualTurnoverAmount DECIMAL(18,4),
    EbitdaMarginPercent DECIMAL(18,4),
    AmlRiskRating NVARCHAR(255),
    KycReviewDate DATE,
    KycNextReviewDate DATE,
    GdprConsentFlag BIT NOT NULL,
    PreferredCommunicationLanguage NVARCHAR(255),
    ClientSegment NVARCHAR(255) NOT NULL,
    ClientTier NVARCHAR(255),
    OnboardingChannel NVARCHAR(255),
    PrimaryContactEmail NVARCHAR(255),
    PrimaryContactPhone NVARCHAR(255),
    UltimateParentClientId NVARCHAR(255),
    SanctionScreeningStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblClient PRIMARY KEY (ClientId)
);

-- Lender legal entities providing asset-based lending facilities within the Commercial Finance Network
CREATE TABLE [FinanceNetwork].[TblLender] (
    LenderId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLender PRIMARY KEY (LenderId)
);

-- Internal relationship managers responsible for commercial client relationships.
CREATE TABLE [FinanceNetwork].[TblRelationshipManager] (
    RelationshipManagerId NVARCHAR(255) NOT NULL,
    RelationshipManagerName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblRelationshipManag PRIMARY KEY (RelationshipManagerId)
);

-- Commercial finance relationships between clients and lenders, including facilities, exposure, profit
CREATE TABLE [FinanceNetwork].[TblClientRelationship] (
    RelationshipId NVARCHAR(255) NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    LenderId NVARCHAR(255) NOT NULL,
    RelationshipManagerId NVARCHAR(255) NOT NULL,
    FacilityId NVARCHAR(255),
    CreditRiskRating NVARCHAR(255),
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
    ,CONSTRAINT PK_TblClientRelationshi PRIMARY KEY (RelationshipId)
);

ALTER TABLE [FinanceNetwork].[TblClientRelationship] ADD CONSTRAINT FK_TblClientRelationship_Clien
    FOREIGN KEY (ClientId) REFERENCES [FinanceNetwork].[TblClient] (ClientId);

ALTER TABLE [FinanceNetwork].[TblClientRelationship] ADD CONSTRAINT FK_TblClientRelationship_Lende
    FOREIGN KEY (LenderId) REFERENCES [FinanceNetwork].[TblLender] (LenderId);

ALTER TABLE [FinanceNetwork].[TblClientRelationship] ADD CONSTRAINT FK_TblClientRelationship_Relat
    FOREIGN KEY (RelationshipManagerId) REFERENCES [FinanceNetwork].[TblRelationshipManager] (RelationshipManagerId);

ALTER TABLE [FinanceNetwork].[TblClient] ADD CONSTRAINT FK_TblClient_UltimateParentCli
    FOREIGN KEY (UltimateParentClientId) REFERENCES [FinanceNetwork].[TblClient] (ClientId);


