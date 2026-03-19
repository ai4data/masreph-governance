-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: AccountNumber
-- Generated: 2026-03-18T12:08:48.620051
-- Datasets: 1
-- ============================================

-- Dataset: GDS77133
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AccountNumber')
    EXEC('CREATE SCHEMA [AccountNumber]');

-- Snapshot of finance account classification and performance attributes for leasing accounts as of a g
CREATE TABLE [AccountNumber].[tblFinanceAccountSnapshot] (
    FinanceAccountId NVARCHAR(255) NOT NULL,
    ModelingSnapshotDate DATE NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    ProductId INT NOT NULL,
    CustomerSegmentCode NVARCHAR(255) NOT NULL,
    CustomerResidenceCountry NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE NOT NULL,
    AccountMaturityDate DATE,
    InitialPrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentOutstandingPrincipal DECIMAL(18,4) NOT NULL,
    ContractInterestRate DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    LeaseTermMonths INT NOT NULL,
    PaymentFrequencyCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    AccountStatusCode NVARCHAR(255) NOT NULL,
    DaysPastDue INT NOT NULL,
    NonAccrualIndicator BIT NOT NULL,
    InternalRatingGrade NVARCHAR(255),
    ExpectedLossRate DECIMAL(18,4),
    EffectiveYieldRate DECIMAL(18,4),
    UpfrontFeeAmount DECIMAL(18,4),
    ResidualValueAmount DECIMAL(18,4),
    AssetDescription NVARCHAR(255),
    ChannelOriginCode NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    CustomerLifetimeValueScore DECIMAL(18,4),
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    MarginOverReferenceRate DECIMAL(18,4),
    ReferenceRateIndex NVARCHAR(255),
    WriteOffAmount DECIMAL(18,4) NOT NULL,
    RecoveryAmount DECIMAL(18,4) NOT NULL,
    LastPaymentDate DATE,
    AnnualizedRevenueAmount DECIMAL(18,4),
    EffectiveAccountStartTimestamp DATETIME2 NOT NULL,
    MasrephLegalEntityCode NVARCHAR(255) NOT NULL,
    GdprPersonalDataFlag BIT NOT NULL,
    CustomerAgeBand NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    AssociatedProductsArray NVARCHAR(MAX),
    ProductPerformanceMetrics NVARCHAR(MAX),
    CompetitivePricingIndex DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceAccountSna PRIMARY KEY (FinanceAccountId, ModelingSnapshotDate)
);

-- Reference data for leasing products, including product code, name, family, and associated asset cate
CREATE TABLE [AccountNumber].[tblProduct] (
    ProductId INT NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductFamily NVARCHAR(255) NOT NULL,
    AssetCategoryCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductId)
);

ALTER TABLE [AccountNumber].[tblFinanceAccountSnapshot] ADD CONSTRAINT FK_tblFinanceAccountSnapshot_P
    FOREIGN KEY (ProductId) REFERENCES [AccountNumber].[tblProduct] (ProductId);


