-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: InsureDataFinance
-- Generated: 2026-03-18T12:08:48.615464
-- Datasets: 1
-- ============================================

-- Dataset: GDS67506
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'InsureDataFinance')
    EXEC('CREATE SCHEMA [InsureDataFinance]');

-- Represents a single InsureData Finance dataset extract instance, including snapshot timing, source s
CREATE TABLE [InsureDataFinance].[tblDatasetInstance] (
    DatasetInstanceKey INT NOT NULL,
    DatasetId NVARCHAR(255) NOT NULL,
    DataSnapshotTimestamp DATETIME2 NOT NULL,
    SourceSystemName NVARCHAR(255) NOT NULL,
    DataLineageMetadata NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblDatasetInstance PRIMARY KEY (DatasetInstanceKey)
);

-- Master data for insurance company legal entities providing mobility-related financial products.
CREATE TABLE [InsureDataFinance].[tblInsurerLegalEntity] (
    InsurerLegalEntityKey INT NOT NULL,
    InsurerLegalEntityId NVARCHAR(255) NOT NULL,
    InsurerLegalEntityName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblInsurerLegalEntit PRIMARY KEY (InsurerLegalEntityKey)
);

-- Master data for mobility-related insurance and finance products, including category, sub-segment, an
CREATE TABLE [InsureDataFinance].[tblMobilityProduct] (
    MobilityProductKey INT NOT NULL,
    MobilityProductId NVARCHAR(255) NOT NULL,
    MobilityProductName NVARCHAR(255) NOT NULL,
    ProductCategory NVARCHAR(255) NOT NULL,
    ProductSubSegment NVARCHAR(255),
    CrossSellProductCodes NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMobilityProduct PRIMARY KEY (MobilityProductKey)
);

-- Reporting period dimension capturing start and end dates and the associated fiscal year.
CREATE TABLE [InsureDataFinance].[tblReportingPeriod] (
    ReportingPeriodKey INT NOT NULL,
    ReportingPeriodStartDate DATE NOT NULL,
    ReportingPeriodEndDate DATE NOT NULL,
    ReportingFiscalYear INT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblReportingPeriod PRIMARY KEY (ReportingPeriodKey)
);

-- Fact table containing financial, risk, and operational performance metrics for mobility products by 
CREATE TABLE [InsureDataFinance].[tblProductFinancialPerformance] (
    RecordId NVARCHAR(255) NOT NULL,
    DatasetInstanceKey INT NOT NULL,
    InsurerLegalEntityKey INT NOT NULL,
    MobilityProductKey INT NOT NULL,
    ReportingPeriodKey INT NOT NULL,
    EuCountryIsoCode NVARCHAR(255) NOT NULL,
    PolicyCurrencyCode NVARCHAR(255) NOT NULL,
    DistributionChannel NVARCHAR(255) NOT NULL,
    DigitalChannelIndicator BIT NOT NULL,
    CustomerSegmentCode NVARCHAR(255),
    CustomerMarketingConsentFlag BIT NOT NULL,
    CustomerAgeBracket NVARCHAR(255),
    PolicyCountActive INT NOT NULL,
    GrossWrittenPremiumAmount DECIMAL(18,4) NOT NULL,
    NetEarnedPremiumAmount DECIMAL(18,4) NOT NULL,
    ClaimsIncurredAmount DECIMAL(18,4) NOT NULL,
    LossRatioPercent DECIMAL(18,4) NOT NULL,
    CombinedRatioPercent DECIMAL(18,4),
    OutstandingClaimsReserveAmount DECIMAL(18,4),
    TotalInvestedAssetsAmount DECIMAL(18,4),
    TotalLiabilitiesAmount DECIMAL(18,4),
    SolvencyCoverageRatioPercent DECIMAL(18,4),
    AutoLoanExposureAmount DECIMAL(18,4),
    AverageLoanToValuePercent DECIMAL(18,4),
    PortfolioDefaultRatePercent DECIMAL(18,4),
    CancellationRatePercent DECIMAL(18,4),
    NewBusinessPremiumAmount DECIMAL(18,4),
    RenewalPremiumAmount DECIMAL(18,4),
    PolicyAverageTermMonths DECIMAL(18,4),
    AverageClaimSeverityAmount DECIMAL(18,4),
    ClaimFrequencyPer1000Policies DECIMAL(18,4),
    ProductProfitabilityIndex DECIMAL(18,4),
    RecordQualityStatus NVARCHAR(255) NOT NULL,
    IsRecordActive BIT NOT NULL,
    CompetitivePositionRank INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProductFinancialP PRIMARY KEY (RecordId)
);

ALTER TABLE [InsureDataFinance].[tblProductFinancialPerformance] ADD CONSTRAINT FK_tblProductFinancialPerforma
    FOREIGN KEY (DatasetInstanceKey) REFERENCES [InsureDataFinance].[tblDatasetInstance] (DatasetInstanceKey);

ALTER TABLE [InsureDataFinance].[tblProductFinancialPerformance] ADD CONSTRAINT FK_tblProductFinancialPerforma
    FOREIGN KEY (InsurerLegalEntityKey) REFERENCES [InsureDataFinance].[tblInsurerLegalEntity] (InsurerLegalEntityKey);

ALTER TABLE [InsureDataFinance].[tblProductFinancialPerformance] ADD CONSTRAINT FK_tblProductFinancialPerforma
    FOREIGN KEY (MobilityProductKey) REFERENCES [InsureDataFinance].[tblMobilityProduct] (MobilityProductKey);

ALTER TABLE [InsureDataFinance].[tblProductFinancialPerformance] ADD CONSTRAINT FK_tblProductFinancialPerforma
    FOREIGN KEY (ReportingPeriodKey) REFERENCES [InsureDataFinance].[tblReportingPeriod] (ReportingPeriodKey);


