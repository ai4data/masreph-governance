-- ============================================
-- Platform: FABRIC
-- Schema/Source: BlueDolphin
-- Generated: 2026-03-18T12:18:16.876149
-- Datasets: 1
-- ============================================

-- Dataset: GDS22148

-- This partner dataset supports innovation & technology operations. Key applications include data anal
CREATE TABLE [BlueDolphin].[FinanceCapModelData] (
    Id INT NOT NULL,
    RecordId UNIQUEIDENTIFIER NOT NULL,
    SourceSystemCode VARCHAR(255) NOT NULL,
    IngestionTimestamp DATETIME2 NOT NULL,
    EventTimestamp DATETIME2 NOT NULL,
    PartnerEntityId VARCHAR(255) NOT NULL,
    CorporateClientId VARCHAR(255),
    InstrumentId VARCHAR(255) NOT NULL,
    InstrumentType VARCHAR(255) NOT NULL,
    AssetClass VARCHAR(255) NOT NULL,
    RiskFactorId VARCHAR(255),
    PositionQty DECIMAL(20,4) NOT NULL,
    PositionCurrency VARCHAR(255) NOT NULL,
    MarketValueLocal DECIMAL(22,4),
    MarketValueReporting DECIMAL(22,4),
    ReportingCurrency VARCHAR(255) NOT NULL,
    ExposureAtDefault DECIMAL(22,4),
    ProbabilityOfDefault DECIMAL(10,6),
    LossGivenDefault DECIMAL(6,4),
    ExpectedLossAmount DECIMAL(22,4),
    UnexpectedLossAmount DECIMAL(22,4),
    ValueAtRisk99 DECIMAL(22,4),
    ExpectedShortfall975 DECIMAL(22,4),
    RiskWeight DECIMAL(6,4),
    RiskWeightedAssets DECIMAL(24,2),
    CapitalChargeAmount DECIMAL(24,2),
    LeverageExposureAmount DECIMAL(24,2),
    CounterpartyRatingInternal VARCHAR(255),
    CounterpartyRatingExternal VARCHAR(255),
    CountryOfRisk VARCHAR(255),
    SectorCode VARCHAR(255),
    CollateralValue DECIMAL(22,2),
    CollateralType VARCHAR(255),
    ModelVersionId VARCHAR(255) NOT NULL,
    ModelRunId VARCHAR(255) NOT NULL,
    ScenarioId VARCHAR(255),
    ScenarioType VARCHAR(255),
    IsLiveData BIT NOT NULL,
    IsPreProduction BIT NOT NULL,
    DataQualityScore DECIMAL(5,2),
    DataQualityIssues VARCHAR(MAX),
    ProcessingStatus VARCHAR(255) NOT NULL,
    ProcessingBatchId VARCHAR(255),
    ModelInputFlags VARCHAR(MAX),
    GdpRegionCode VARCHAR(255),
    MacroScenarioGdpGrowth DECIMAL(6,3),
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    SourceRecordReference VARCHAR(255),
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_FinanceCapModelData PRIMARY KEY (Id)
);


