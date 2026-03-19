-- ============================================
-- Platform: FABRIC
-- Schema/Source: SharepointGPAA
-- Generated: 2026-03-18T12:18:16.880146
-- Datasets: 1
-- ============================================

-- Dataset: GDS33678

-- This partner dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE [SharepointGPAA].[FinanceContractsDataset] (
    Id INT NOT NULL,
    ContractId UNIQUEIDENTIFIER NOT NULL,
    PartnerContractReference VARCHAR(255) NOT NULL,
    LesseeCustomerId VARCHAR(255) NOT NULL,
    LessorEntityCode VARCHAR(255) NOT NULL,
    AssetId VARCHAR(255),
    AssetCategory VARCHAR(255),
    AssetDescription VARCHAR(255),
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE NOT NULL,
    ContractSignatureDate DATE,
    ContractStatus VARCHAR(255) NOT NULL,
    ContractTermMonths INT NOT NULL,
    CurrencyCode VARCHAR(255) NOT NULL,
    FinancedAmount DECIMAL(15,2) NOT NULL,
    InterestRateAnnual DECIMAL(7,4) NOT NULL,
    PaymentFrequency VARCHAR(255) NOT NULL,
    PaymentDayOfMonth INT,
    InstallmentAmount DECIMAL(15,2) NOT NULL,
    BalloonPaymentAmount DECIMAL(15,2),
    ResidualValueAmount DECIMAL(15,2),
    OutstandingPrincipalAmount DECIMAL(15,2) NOT NULL,
    DaysPastDue INT NOT NULL,
    IsDelinquent BIT NOT NULL,
    LastPaymentDate DATE,
    NextPaymentDueDate DATE,
    TerminationDate DATE,
    TerminationReasonCode VARCHAR(255),
    DefaultFlag BIT NOT NULL,
    DefaultDate DATE,
    RestructuringFlag BIT NOT NULL,
    RestructuringDate DATE,
    EarlySettlementAmount DECIMAL(15,2),
    PenaltyInterestAccruedAmount DECIMAL(15,2) NOT NULL,
    OriginationChannel VARCHAR(255),
    CountryOfContract VARCHAR(255) NOT NULL,
    BookingBranchCode VARCHAR(255),
    RiskRatingInternal VARCHAR(255),
    CollateralType VARCHAR(255),
    CollateralValuationAmount DECIMAL(15,2),
    ReportingSegmentCode VARCHAR(255),
    PaymentScheduleSnapshot VARCHAR(MAX),
    CreatedTimestamp DATETIME2 NOT NULL,
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    DataSourceSystem VARCHAR(255) NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_FinanceContractsData PRIMARY KEY (Id)
);


