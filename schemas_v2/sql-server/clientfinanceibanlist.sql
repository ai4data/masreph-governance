-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: ClientFinanceIbanList
-- Generated: 2026-03-18T12:08:48.619534
-- Datasets: 1
-- ============================================

-- Dataset: GDS72632
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ClientFinanceIbanList')
    EXEC('CREATE SCHEMA [ClientFinanceIbanList]');

-- Core IBAN-level client finance record including relationship, risk, balance, activity, consent, and 
CREATE TABLE [ClientFinanceIbanList].[tblClientFinanceIban] (
    DatasetId NVARCHAR(255) NOT NULL,
    MasrephClientId NVARCHAR(255) NOT NULL,
    ExternalClientReference NVARCHAR(255),
    Iban NVARCHAR(255) NOT NULL,
    IbanCountryCode NVARCHAR(255) NOT NULL,
    IbanCurrencyCode NVARCHAR(255) NOT NULL,
    BicSwiftCode NVARCHAR(255),
    AccountStatus NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE NOT NULL,
    AccountCloseDate DATE,
    PrimaryAccountFlag BIT NOT NULL,
    AccountType NVARCHAR(255) NOT NULL,
    AccountPurpose NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    RelationshipSegment NVARCHAR(255),
    ClientResidencyCountry NVARCHAR(255),
    ClientRiskRating NVARCHAR(255),
    AverageMonthlyBalanceEur DECIMAL(18,4),
    CurrentBalanceEur DECIMAL(18,4),
    OverdraftLimitEur DECIMAL(18,4),
    InterestRateApr DECIMAL(18,4),
    FeeIncomeYtdEur DECIMAL(18,4),
    InterestIncomeYtdEur DECIMAL(18,4),
    LastTransactionTimestamp DATETIME2,
    LastContactTimestamp DATETIME2,
    PreferredContactChannel NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    GdprProcessingLegalBasis NVARCHAR(255) NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    DataIngestionTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    RecordActiveFlag BIT NOT NULL,
    IbanValidationStatus NVARCHAR(255) NOT NULL,
    IbanValidationResult NVARCHAR(MAX),
    ProfitabilityScore12M DECIMAL(18,4),
    CrossSellPropensityScore DECIMAL(18,4),
    ChurnRiskScore DECIMAL(18,4),
    DataQualityIssueFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientFinanceIban PRIMARY KEY (DatasetId)
);

-- Associative table listing internal product codes linked to each IBAN record.
CREATE TABLE [ClientFinanceIbanList].[tblClientFinanceIbanProduct] (
    DatasetId NVARCHAR(255) NOT NULL,
    AssociatedProductCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientFinanceIban PRIMARY KEY (DatasetId, AssociatedProductCode)
);


