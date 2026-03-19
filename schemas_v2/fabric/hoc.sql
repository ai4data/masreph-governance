-- ============================================
-- Platform: FABRIC
-- Schema/Source: HOC
-- Generated: 2026-03-18T12:18:16.882146
-- Datasets: 2
-- ============================================

-- Dataset: GDS42305

-- This risk management dataset supports consumer finance operations. Key applications include data ana
CREATE TABLE [HOC].[RiskFinanceInsightsDataset] (
    Id INT NOT NULL,
    CustomerRiskId UNIQUEIDENTIFIER NOT NULL,
    MasrephCustomerInternalId VARCHAR(255) NOT NULL,
    AccountId VARCHAR(255) NOT NULL,
    ProductType VARCHAR(255) NOT NULL,
    PortfolioSegment VARCHAR(255),
    CustomerCountryIso2 VARCHAR(255) NOT NULL,
    CustomerAgeYears INT,
    ApplicationDate DATE NOT NULL,
    AccountOpenDate DATE,
    ReportingPeriodTimestamp DATETIME2 NOT NULL,
    CurrencyCode VARCHAR(255) NOT NULL,
    CurrentBalanceAmount DECIMAL(15,2) NOT NULL,
    CreditLimitAmount DECIMAL(15,2),
    DaysPastDue INT NOT NULL,
    DelinquencyStatus VARCHAR(255) NOT NULL,
    ProbabilityOfDefault12m DECIMAL(5,4),
    LossGivenDefaultPercentage DECIMAL(5,2),
    ExposureAtDefaultAmount DECIMAL(15,2),
    BehaviorScorecardScore INT,
    RiskSegment VARCHAR(255),
    RestructuringFlag BIT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    DefaultDate DATE,
    ConsentToProcessPiiFlag BIT NOT NULL,
    ActiveRiskFlags VARCHAR(MAX),
    DataSourceSystem VARCHAR(255) NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_RiskFinanceInsightsD PRIMARY KEY (Id)
);


-- Dataset: GDS88396

-- This risk management dataset supports commercial finance operations. Key applications include data a
CREATE TABLE [HOC].[RiskFinanceInsightsDataset] (
    Id INT NOT NULL,
    MasrephCustomerId VARCHAR(255) NOT NULL,
    LegalEntityName VARCHAR(255) NOT NULL,
    CustomerSegmentCode VARCHAR(255) NOT NULL,
    CounterpartyRatingInternal VARCHAR(255),
    CounterpartyRatingExternal VARCHAR(255),
    CountryOfRisk VARCHAR(255) NOT NULL,
    IndustryNaceCode VARCHAR(255),
    LoanAccountId VARCHAR(255) NOT NULL,
    FacilityType VARCHAR(255) NOT NULL,
    FacilityLimitAmount DECIMAL(18,2) NOT NULL,
    FacilityCurrencyCode VARCHAR(255) NOT NULL,
    CurrentOutstandingAmount DECIMAL(18,2) NOT NULL,
    UndrawnCommitmentAmount DECIMAL(18,2),
    EffectiveInterestRate DECIMAL(7,5),
    InterestRateIndex VARCHAR(255),
    LoanOriginationDate DATE NOT NULL,
    LoanMaturityDate DATE NOT NULL,
    DaysPastDue INT NOT NULL,
    DefaultStatusFlag BIT NOT NULL,
    DefaultDate DATE,
    ImpairmentStage VARCHAR(255) NOT NULL,
    ProbabilityOfDefault12m DECIMAL(6,5),
    ProbabilityOfDefaultLifetime DECIMAL(6,5),
    LossGivenDefault DECIMAL(5,4),
    ExposureAtDefault DECIMAL(20,2),
    ExpectedCreditLossAmount DECIMAL(20,2),
    CollateralCoverageRatio DECIMAL(8,4),
    PrimaryCollateralType VARCHAR(255),
    CollateralValuedAmount DECIMAL(20,2),
    CollateralValuationDate DATE,
    BorrowerGroupId VARCHAR(255),
    ConsolidatedGroupExposure DECIMAL(20,2),
    RestructuringFlag BIT NOT NULL,
    RestructuringEffectiveDate DATE,
    CovenantBreachFlag BIT NOT NULL,
    CovenantBreachDate DATE,
    RiskReportingSnapshotTs DATETIME2 NOT NULL,
    CounterpartyLei VARCHAR(255),
    RiskCountryGdpWeight DECIMAL(7,4),
    SensitiveDataMaskingLevel VARCHAR(255) NOT NULL,
    PortfolioBucket VARCHAR(255) NOT NULL,
    ExpectedLossContribution DECIMAL(20,4),
    RiskDataQualityScore INT NOT NULL,
    RegulatoryExposureClass VARCHAR(255) NOT NULL,
    RiskLimitBreachFlag BIT NOT NULL,
    RiskCommentaryNotes VARCHAR(255),
    MacroeconomicScenarioWeights VARCHAR(MAX),
    CounterpartyContactSummary VARCHAR(MAX),
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_RiskFinanceInsightsD PRIMARY KEY (Id)
);


