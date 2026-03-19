-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: TessiSavingsSolution
-- Generated: 2026-03-18T12:08:48.610605
-- Datasets: 1
-- ============================================

-- Dataset: GDS54232
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TessiSavingsSolution')
    EXEC('CREATE SCHEMA [TessiSavingsSolution]');

-- Stores detailed financial calculation records from the Masreph finance calculator, including loan me
CREATE TABLE [TessiSavingsSolution].[tblFinanceCalculationRecord] (
    RecordId NVARCHAR(255) NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    LoanAccountId NVARCHAR(255),
    CalculationBatchId NVARCHAR(255),
    ScenarioId NVARCHAR(255),
    CalculationTimestamp DATETIME2 NOT NULL,
    ValuationDate DATE NOT NULL,
    LoanStartDate DATE,
    LoanMaturityDate DATE,
    PaymentDueDate DATE,
    CurrencyCode NVARCHAR(255) NOT NULL,
    PrincipalAmount DECIMAL(18,4) NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4),
    InterestRateAnnual DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    CompoundingFrequency NVARCHAR(255),
    DayCountConvention NVARCHAR(255),
    PaymentFrequency NVARCHAR(255),
    InstallmentAmountCalculated DECIMAL(18,4),
    InterestAmountCalculated DECIMAL(18,4),
    PrincipalAmountCalculated DECIMAL(18,4),
    RemainingTermMonths INT,
    AmortizationType NVARCHAR(255),
    RateFixingDate DATE,
    IndexRateValue DECIMAL(18,4),
    CreditSpreadBps INT,
    DiscountRateAnnual DECIMAL(18,4),
    NetPresentValueAmount DECIMAL(18,4),
    InternalRateOfReturn DECIMAL(18,4),
    EffectiveAnnualPercentageRate DECIMAL(18,4),
    PaymentStatusCode NVARCHAR(255),
    CalculationStatusCode NVARCHAR(255) NOT NULL,
    IsHistoricalRecord BIT NOT NULL,
    IsLiveStream BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    SourceSystemEventId NVARCHAR(255),
    CalculationEngineVersion NVARCHAR(255) NOT NULL,
    RiskSegmentCode NVARCHAR(255),
    ProductTypeCode NVARCHAR(255) NOT NULL,
    CountryIsoCode NVARCHAR(255),
    CustomerSegmentCode NVARCHAR(255),
    DataIngestionTimestamp DATETIME2 NOT NULL,
    LastUpdateTimestamp DATETIME2,
    TagsArray NVARCHAR(MAX),
    CalculationParametersJson NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceCalculatio PRIMARY KEY (RecordId)
);


