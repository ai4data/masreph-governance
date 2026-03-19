-- ============================================
-- Platform: FABRIC
-- Schema/Source: Qualys
-- Generated: 2026-03-18T12:18:16.878155
-- Datasets: 2
-- ============================================

-- Dataset: GDS26996

-- This risk management dataset supports commercial finance operations. Key applications include data a
CREATE TABLE [Qualys].[RiskclassificationdataABL] (
    Id INT NOT NULL,
    RiskEventId UNIQUEIDENTIFIER NOT NULL,
    FacilityId VARCHAR(255) NOT NULL,
    CustomerLegalEntityId VARCHAR(255) NOT NULL,
    EventTypeCode VARCHAR(255) NOT NULL,
    EventDescription VARCHAR(255),
    EventOccurrenceDate DATE NOT NULL,
    EventReportedTimestamp DATETIME2 NOT NULL,
    EventSeverityLevel VARCHAR(255) NOT NULL,
    EventStatusCode VARCHAR(255) NOT NULL,
    CurrencyCode VARCHAR(255) NOT NULL,
    ExposureAtEventAmount DECIMAL(18,2) NOT NULL,
    SecuredExposureAmount DECIMAL(18,2) NOT NULL,
    CollateralTypeCode VARCHAR(255) NOT NULL,
    CollateralValuationAmount DECIMAL(18,2),
    CollateralValuationDate DATE,
    ProbabilityOfDefaultPercentage DECIMAL(5,3),
    LossGivenDefaultPercentage DECIMAL(5,2),
    ExpectedLossAmount DECIMAL(18,2),
    EconomicCapitalChargeAmount DECIMAL(18,2),
    InternalRatingGrade VARCHAR(255) NOT NULL,
    ExternalRatingAgency VARCHAR(255),
    ExternalRatingGrade VARCHAR(255),
    CountryOfRiskCode VARCHAR(255) NOT NULL,
    EuMemberStateFlag BIT NOT NULL,
    IndustrySectorCode VARCHAR(255) NOT NULL,
    ObligorGroupId VARCHAR(255),
    DaysPastDueAtEvent INT,
    NonAccrualStatusFlag BIT NOT NULL,
    ForbearanceStatusFlag BIT NOT NULL,
    RestructuringIndicator BIT NOT NULL,
    DefaultStatusCode VARCHAR(255) NOT NULL,
    DefaultDate DATE,
    WriteOffAmount DECIMAL(18,2),
    SpecificProvisionAmount DECIMAL(18,2),
    Ifrs9StageCode VARCHAR(255) NOT NULL,
    InternalEventOwnerId VARCHAR(255),
    BusinessUnitCode VARCHAR(255) NOT NULL,
    MitigationActions VARCHAR(MAX),
    EventSourceSystem VARCHAR(255) NOT NULL,
    DataQualityScore DECIMAL(5,2),
    GdprPersonalDataFlag BIT NOT NULL,
    ReportingPeriodEndDate DATE NOT NULL,
    LoanToValueRatioPercentage DECIMAL(6,2),
    AdvanceRatePercentage DECIMAL(5,2) NOT NULL,
    EligibleCollateralAmount DECIMAL(18,2),
    BorrowingBaseDeficitAmount DECIMAL(18,2),
    RiskEventCategory VARCHAR(255) NOT NULL,
    EventTriggerClause VARCHAR(255),
    ScenarioAnalysisId VARCHAR(255),
    AuditTrailMetadata VARCHAR(MAX) NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_Riskclassificationda PRIMARY KEY (Id)
);


-- Dataset: GDS41662

-- This risk management dataset supports commercial finance operations. Key applications include data a
CREATE TABLE [Qualys].[RiskclassificationdataABL] (
    Id INT NOT NULL,
    RiskEventId UNIQUEIDENTIFIER NOT NULL,
    FacilityId VARCHAR(255) NOT NULL,
    BorrowerLegalEntityId VARCHAR(255) NOT NULL,
    BorrowerName VARCHAR(255) NOT NULL,
    BorrowerDomesticRegistrationNumber VARCHAR(255),
    CountryOfRisk VARCHAR(255) NOT NULL,
    IndustrySectorCode VARCHAR(255),
    RiskEventType VARCHAR(255) NOT NULL,
    RiskEventDescription VARCHAR(255),
    RiskEventSeverityCode VARCHAR(255) NOT NULL,
    RiskEventDate DATE NOT NULL,
    RiskEventRecordedTimestamp DATETIME2 NOT NULL,
    ReportingCurrencyCode VARCHAR(255) NOT NULL,
    ExposureAtDefaultAmount DECIMAL(18,2),
    OutstandingLoanBalanceAmount DECIMAL(18,2) NOT NULL,
    UndrawnCommittedAmount DECIMAL(18,2),
    CollateralType VARCHAR(255),
    CollateralAppraisedValueAmount DECIMAL(18,2),
    AdvanceRatePercentage DECIMAL(5,2),
    LoanToValuePercentage DECIMAL(6,2),
    InternalRiskRating VARCHAR(255),
    ExternalRatingAgencyCode VARCHAR(255),
    ProbabilityOfDefaultPercentage DECIMAL(7,4),
    LossGivenDefaultPercentage DECIMAL(6,2),
    ExpectedLossAmount DECIMAL(18,2),
    DaysPastDue INT,
    NonAccrualStatusFlag BIT NOT NULL,
    CovenantBreachIndicator BIT NOT NULL,
    WatchlistClassification VARCHAR(255),
    CountryRiskScore INT,
    IndustryRiskScore INT,
    AmlSanctionsHitIndicator BIT NOT NULL,
    RegulatoryClassifications VARCHAR(MAX),
    BorrowerRiskProfile VARCHAR(MAX),
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_Riskclassificationda PRIMARY KEY (Id)
);


