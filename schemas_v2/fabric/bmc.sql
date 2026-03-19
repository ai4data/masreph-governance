-- ============================================
-- Platform: FABRIC
-- Schema/Source: BMC
-- Generated: 2026-03-18T12:18:16.884337
-- Datasets: 1
-- ============================================

-- Dataset: GDS44893

-- This collateral dataset supports leasing operations. Key applications include asset valuation, risk 
CREATE TABLE [BMC].[LegalFinanceArchiveDataset] (
    Id INT NOT NULL,
    LegalFinanceRecordId UNIQUEIDENTIFIER NOT NULL,
    MasrephCaseId VARCHAR(255) NOT NULL,
    ExternalCaseReference VARCHAR(255),
    LesseeCustomerId VARCHAR(255) NOT NULL,
    LesseeName VARCHAR(255) NOT NULL,
    CounterpartyLei VARCHAR(255),
    JurisdictionCountryCode VARCHAR(255) NOT NULL,
    LegalVenueName VARCHAR(255),
    CollateralAssetId VARCHAR(255) NOT NULL,
    CollateralAssetType VARCHAR(255) NOT NULL,
    CollateralAssetDescription VARCHAR(255),
    CollateralValuationAmount DECIMAL(18,2) NOT NULL,
    CollateralValuationCurrency VARCHAR(255) NOT NULL,
    CollateralValuationDate DATE NOT NULL,
    LoanOutstandingPrincipal DECIMAL(18,2) NOT NULL,
    LoanToValueRatio DECIMAL(5,2) NOT NULL,
    LegalCaseFilingDate DATE,
    LegalCaseCloseDate DATE,
    LegalCaseStatus VARCHAR(255) NOT NULL,
    ProceedingType VARCHAR(255) NOT NULL,
    JudgmentAmountAwarded DECIMAL(18,2),
    JudgmentInterestRate DECIMAL(5,3),
    RecoveryCostsAmount DECIMAL(18,2),
    RecoveryCostsCurrency VARCHAR(255),
    RecoveryRealizedAmount DECIMAL(18,2),
    RecoveryRealizedDate DATE,
    EnforcementActionType VARCHAR(255),
    EnforcementStatus VARCHAR(255) NOT NULL,
    ImpairmentFlag BIT NOT NULL,
    WriteOffAmount DECIMAL(18,2),
    WriteOffDate DATE,
    RiskSegmentCode VARCHAR(255) NOT NULL,
    InternalRatingGrade VARCHAR(255),
    ProbabilityOfDefault DECIMAL(6,4),
    LossGivenDefault DECIMAL(5,2),
    ExposureAtDefault DECIMAL(18,2),
    DataSourceSystem VARCHAR(255) NOT NULL,
    IngestionTimestamp DATETIME2 NOT NULL,
    LastUpdateTimestamp DATETIME2 NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    GdprPersonalDataFlag BIT NOT NULL,
    SecurityClassificationLevel VARCHAR(255) NOT NULL,
    StreamingEventId UNIQUEIDENTIFIER NOT NULL,
    LegalDocumentMetadata VARCHAR(MAX),
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_LegalFinanceArchiveD PRIMARY KEY (Id)
);


