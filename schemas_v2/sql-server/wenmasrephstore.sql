-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: WenMasrephStore
-- Generated: 2026-03-18T12:08:48.631191
-- Datasets: 1
-- ============================================

-- Dataset: GDS99796
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'WenMasrephStore')
    EXEC('CREATE SCHEMA [WenMasrephStore]');

-- Core master data for commercial client entities within the Finance Statement Insights platform.
CREATE TABLE [WenMasrephStore].[tblClientEntity] (
    ClientEntityId NVARCHAR(255) NOT NULL,
    ClientLegalName NVARCHAR(255) NOT NULL,
    ClientTradingName NVARCHAR(255),
    ClientSegment NVARCHAR(255) NOT NULL,
    ClientIndustryCodeNace NVARCHAR(255),
    ClientCountryOfIncorporation NVARCHAR(255) NOT NULL,
    ClientPrimaryRelationshipManagerId NVARCHAR(255) NOT NULL,
    ClientOnboardingDate DATE,
    ClientGroupId NVARCHAR(255),
    PrimaryContactEmailHash NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientEntity PRIMARY KEY (ClientEntityId)
);

-- Snapshot records of client-level finance, risk, relationship, and profitability metrics for Finance 
CREATE TABLE [WenMasrephStore].[tblClientFinanceStatementSnapshot] (
    ClientFinanceStatementSnapshotId INT NOT NULL,
    ClientEntityId NVARCHAR(255) NOT NULL,
    RelationshipStatus NVARCHAR(255) NOT NULL,
    RelationshipStatusEffectiveTimestamp DATETIME2 NOT NULL,
    LastInteractionTimestamp DATETIME2,
    LastInteractionChannel NVARCHAR(255),
    InteractionCountRolling12M INT NOT NULL,
    AnnualRevenueReported DECIMAL(18,4),
    AnnualRevenueCurrency NVARCHAR(255),
    EbitdaMarginPercentage DECIMAL(18,4),
    NetInterestIncomeRolling12M DECIMAL(18,4) NOT NULL,
    FeeIncomeRolling12M DECIMAL(18,4) NOT NULL,
    DirectCostsAllocatedRolling12M DECIMAL(18,4) NOT NULL,
    RiskWeightedAssetsClientLevel DECIMAL(18,4),
    ReturnOnCapitalRolling12M DECIMAL(18,4),
    CrossSellScore DECIMAL(18,4),
    WalletShareEstimatePercentage DECIMAL(18,4),
    PrimaryBankFlag BIT NOT NULL,
    CreditExposureCurrent DECIMAL(18,4) NOT NULL,
    CreditLimitApproved DECIMAL(18,4) NOT NULL,
    ProbabilityOfDefaultSegment NVARCHAR(255),
    GdprConsentMarketingFlag BIT NOT NULL,
    GdprConsentLastUpdatedTimestamp DATETIME2,
    KpiClientProfitBeforeTaxRolling12M DECIMAL(18,4) NOT NULL,
    KpiRelationshipTenureYears DECIMAL(18,4),
    PipelineOpportunityCountOpen INT NOT NULL,
    PipelineExpectedAnnualRevenue DECIMAL(18,4) NOT NULL,
    ClientSatisfactionScoreLatest INT,
    ServiceIssueCountRolling12M INT NOT NULL,
    KeyProductsHeld NVARCHAR(MAX),
    ClientRiskProfile NVARCHAR(MAX),
    DataSnapshotTimestamp DATETIME2 NOT NULL,
    RecordSourceSystem NVARCHAR(255) NOT NULL,
    RecordActiveFlag BIT NOT NULL,
    RecordValidFromDate DATE NOT NULL,
    RecordValidToDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientFinanceStat PRIMARY KEY (ClientFinanceStatementSnapshotId)
);

ALTER TABLE [WenMasrephStore].[tblClientFinanceStatementSnapshot] ADD CONSTRAINT FK_tblClientFinanceStatementSn
    FOREIGN KEY (ClientEntityId) REFERENCES [WenMasrephStore].[tblClientEntity] (ClientEntityId);


