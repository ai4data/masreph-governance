-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: Appello
-- Generated: 2026-03-18T12:08:48.578728
-- Datasets: 3
-- ============================================

-- Dataset: GDS11118
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Appello')
    EXEC('CREATE SCHEMA [Appello]');

-- Customer master data for collateral and credit protection, including identity, residency, and consen
CREATE TABLE [Appello].[Customer] (
    CustomerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    ExternalCustomerReference NVARCHAR(255),
    CustomerFullName NVARCHAR(255) NOT NULL,
    CustomerDateOfBirth DATE NOT NULL,
    CustomerNationalIdHash NVARCHAR(255) NOT NULL,
    CustomerResidenceCountryCode NVARCHAR(255) NOT NULL,
    CustomerGdprConsentFlag BIT NOT NULL,
    MarketingCommunicationConsentFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_Customer PRIMARY KEY (CustomerId)
);

-- Underlying auto or mobility loan contracts, including principal, currency, and linkage to customer a
CREATE TABLE [Appello].[LoanContract] (
    LoanContractKey INT NOT NULL,
    CustomerId INT NOT NULL,
    CollateralAssetKey INT NOT NULL,
    LoanContractId NVARCHAR(255) NOT NULL,
    LoanOriginationDate DATE NOT NULL,
    LoanPrincipalAmount DECIMAL(18,4) NOT NULL,
    LoanCurrencyCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_LoanContract PRIMARY KEY (LoanContractKey)
);

-- Credit protection product contracts linked to loans, including coverage, premiums, and lifecycle sta
CREATE TABLE [Appello].[CreditProtectionContract] (
    CreditProtectionContractKey INT NOT NULL,
    LoanContractKey INT NOT NULL,
    CreditProtectionProductId NVARCHAR(255) NOT NULL,
    CreditProtectionProductName NVARCHAR(255) NOT NULL,
    CreditProtectionCoverageType NVARCHAR(255) NOT NULL,
    CreditProtectionPremiumAmount DECIMAL(18,4) NOT NULL,
    CreditProtectionPremiumCurrency NVARCHAR(255) NOT NULL,
    CreditProtectionStartDate DATE NOT NULL,
    CreditProtectionEndDate DATE,
    CreditProtectionStatus NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_CreditProtectionCont PRIMARY KEY (CreditProtectionContractKey)
);

-- Collateral asset master data, including asset identifiers, type, vehicle details, and primary locati
CREATE TABLE [Appello].[CollateralAsset] (
    CollateralAssetKey INT NOT NULL,
    CollateralAssetId NVARCHAR(255) NOT NULL,
    CollateralAssetType NVARCHAR(255) NOT NULL,
    CollateralVehicleVin NVARCHAR(255) NOT NULL,
    CollateralVehicleRegistrationNumber NVARCHAR(255),
    CollateralLocationCountryCode NVARCHAR(255) NOT NULL,
    CollateralLocationPostalCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_CollateralAsset PRIMARY KEY (CollateralAssetKey)
);

-- Point-in-time valuations for collateral assets, including market and forced sale values and valuatio
CREATE TABLE [Appello].[CollateralValuation] (
    CollateralValuationKey INT NOT NULL,
    CollateralAssetKey INT NOT NULL,
    CollateralMarketValueAmount DECIMAL(18,4) NOT NULL,
    CollateralForcedSaleValueAmount DECIMAL(18,4),
    CollateralValuationDate DATE NOT NULL,
    ValuationMethodCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_CollateralValuation PRIMARY KEY (CollateralValuationKey)
);

-- Credit Sentinel snapshot records combining loan, collateral, credit protection, and risk assessment 
CREATE TABLE [Appello].[CreditSentinelRecord] (
    CreditSentinelRecordId NVARCHAR(255) NOT NULL,
    LoanContractKey INT NOT NULL,
    CollateralValuationKey INT NOT NULL,
    CreditProtectionContractKey INT NOT NULL,
    RiskSegmentCode NVARCHAR(255) NOT NULL,
    ExpectedLossRate DECIMAL(18,4) NOT NULL,
    ProbabilityOfDefault12m DECIMAL(18,4) NOT NULL,
    LossGivenDefaultPercentage DECIMAL(18,4) NOT NULL,
    LoanToValueRatio DECIMAL(18,4) NOT NULL,
    RepossessionFeasibilityScore DECIMAL(18,4),
    CollateralRiskFlags NVARCHAR(MAX),
    RecoveryStrategyPlan NVARCHAR(MAX),
    LastRiskReviewTimestamp DATETIME2 NOT NULL,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    RecordExpirationDate DATE,
    StreamingIngestionTimestamp DATETIME2 NOT NULL,
    PiiEncryptionStatus NVARCHAR(255) NOT NULL,
    SecurityClassificationLevel NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_CreditSentinelRecord PRIMARY KEY (CreditSentinelRecordId)
);

ALTER TABLE [Appello].[Appello.LoanContract] ADD CONSTRAINT FK_Appello.LoanContract_Custom
    FOREIGN KEY (CustomerId) REFERENCES [Appello].[Appello.Customer] (CustomerId);

ALTER TABLE [Appello].[Appello.LoanContract] ADD CONSTRAINT FK_Appello.LoanContract_Collat
    FOREIGN KEY (CollateralAssetKey) REFERENCES [Appello].[Appello.CollateralAsset] (CollateralAssetKey);

ALTER TABLE [Appello].[Appello.CreditProtectionContract] ADD CONSTRAINT FK_Appello.CreditProtectionCon
    FOREIGN KEY (LoanContractKey) REFERENCES [Appello].[Appello.LoanContract] (LoanContractKey);

ALTER TABLE [Appello].[Appello.CollateralValuation] ADD CONSTRAINT FK_Appello.CollateralValuation
    FOREIGN KEY (CollateralAssetKey) REFERENCES [Appello].[Appello.CollateralAsset] (CollateralAssetKey);

ALTER TABLE [Appello].[Appello.CreditSentinelRecord] ADD CONSTRAINT FK_Appello.CreditSentinelRecor
    FOREIGN KEY (LoanContractKey) REFERENCES [Appello].[Appello.LoanContract] (LoanContractKey);

ALTER TABLE [Appello].[Appello.CreditSentinelRecord] ADD CONSTRAINT FK_Appello.CreditSentinelRecor
    FOREIGN KEY (CollateralValuationKey) REFERENCES [Appello].[Appello.CollateralValuation] (CollateralValuationKey);

ALTER TABLE [Appello].[Appello.CreditSentinelRecord] ADD CONSTRAINT FK_Appello.CreditSentinelRecor
    FOREIGN KEY (CreditProtectionContractKey) REFERENCES [Appello].[Appello.CreditProtectionContract] (CreditProtectionContractKey);


-- Dataset: GDS32305
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Appello')
    EXEC('CREATE SCHEMA [Appello]');

-- Core collateral record including valuation, exposure linkage, legal status, risk characteristics, an
CREATE TABLE [Appello].[Appello.tblCollateral] (
    CollateralRecordId NVARCHAR(255) NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255) NOT NULL,
    CollateralTypeCode NVARCHAR(255) NOT NULL,
    CollateralDescription NVARCHAR(255),
    JurisdictionCountryCode NVARCHAR(255) NOT NULL,
    CollateralCurrency NVARCHAR(255) NOT NULL,
    InitialValuationAmount DECIMAL(18,4) NOT NULL,
    LatestValuationAmount DECIMAL(18,4),
    ValuationEffectiveDate DATE,
    ValuationMethodCode NVARCHAR(255),
    HaircutPercentage DECIMAL(18,4),
    EligibleCollateralValue DECIMAL(18,4),
    LoanExposureId NVARCHAR(255) NOT NULL,
    SecuredExposureAmount DECIMAL(18,4),
    LoanToValueRatio DECIMAL(18,4),
    EnforceabilityStatus NVARCHAR(255),
    SecurityRanking NVARCHAR(255),
    CollateralRegistrationId NVARCHAR(255),
    RegistrationDate DATE,
    EnvironmentalRiskFlag BIT,
    CollateralLocationAddress NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    PersonalDataPresentFlag BIT NOT NULL,
    StreamIngestionTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CollateralStatusCode NVARCHAR(255) NOT NULL,
    ExpectedRecoveryRate DECIMAL(18,4),
    RecoveryCostPercentage DECIMAL(18,4),
    GdpComplianceFlag BIT NOT NULL,
    CollateralAttributeJson NVARCHAR(MAX),
    AssociatedRiskRatings NVARCHAR(MAX),
    SensitiveDataClassification NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_Appello.tblCollatera PRIMARY KEY (CollateralRecordId)
);

-- Credit protection details associated with a collateral record, including guarantees, insurance, and 
CREATE TABLE [Appello].[Appello.tblCollateralCreditProtection] (
    CollateralRecordId NVARCHAR(255) NOT NULL,
    CreditProtectionType NVARCHAR(255),
    ProtectionProviderName NVARCHAR(255),
    ProtectionEffectiveDate DATE,
    ProtectionExpiryDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_Appello.tblCollatera PRIMARY KEY (CollateralRecordId)
);

ALTER TABLE [Appello].[Appello.tblCollateralCreditProtection] ADD CONSTRAINT FK_Appello.tblCollateralCredit
    FOREIGN KEY (CollateralRecordId) REFERENCES [Appello].[Appello.tblCollateral] (CollateralRecordId);


-- Dataset: GDS45843
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Appello')
    EXEC('CREATE SCHEMA [Appello]');

-- Core loan account master data and contractual attributes for mobility finance products.
CREATE TABLE [Appello].[tblLoanAccount] (
    LoanAccountId NVARCHAR(255) NOT NULL,
    MasrephProductCode NVARCHAR(255) NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    ContractNumber NVARCHAR(255) NOT NULL,
    VehicleVin NVARCHAR(255),
    CountryCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    BookingDate DATE NOT NULL,
    LoanStartDate DATE NOT NULL,
    ContractualMaturityDate DATE NOT NULL,
    InterestRateAnnual DECIMAL(18,4) NOT NULL,
    LoanOriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    LoanTermMonths INT NOT NULL,
    ProductSegment NVARCHAR(255) NOT NULL,
    MobilitySolutionType NVARCHAR(255),
    AcquisitionChannel NVARCHAR(255),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    GdprConsentFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoanAccount PRIMARY KEY (LoanAccountId)
);

-- Current arrears status, payment schedule dates, and outstanding financial amounts for each loan acco
CREATE TABLE [Appello].[tblLoanFinancialStatus] (
    LoanAccountId NVARCHAR(255) NOT NULL,
    LastPaymentDate DATE,
    NextPaymentDueDate DATE,
    DaysPastDue INT NOT NULL,
    ArrearsStatusCode NVARCHAR(255) NOT NULL,
    ArrearsStatusDescription NVARCHAR(255),
    ArrearsReasonCodes NVARCHAR(MAX),
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    OutstandingInterestAmount DECIMAL(18,4) NOT NULL,
    TotalOutstandingAmount DECIMAL(18,4) NOT NULL,
    CurrentInstallmentAmount DECIMAL(18,4) NOT NULL,
    MinimumPaymentDueAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoanFinancialStat PRIMARY KEY (LoanAccountId)
);

-- Risk, portfolio segmentation, collateral, and behavioral profile metrics for each loan account.
CREATE TABLE [Appello].[tblLoanRiskProfile] (
    LoanAccountId NVARCHAR(255) NOT NULL,
    PortfolioSegmentCode NVARCHAR(255),
    RiskRatingScore INT,
    ProbabilityOfDefault12m DECIMAL(18,4),
    NonAccrualFlag BIT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    RestructuringFlag BIT NOT NULL,
    CollateralType NVARCHAR(255),
    CollateralValuationAmount DECIMAL(18,4),
    LtvRatioCurrent DECIMAL(18,4),
    RegionMarketCluster NVARCHAR(255),
    PaymentBehaviorProfile NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoanRiskProfile PRIMARY KEY (LoanAccountId)
);

ALTER TABLE [Appello].[Appello.tblLoanFinancialStatus] ADD CONSTRAINT FK_Appello.tblLoanFinancialSta
    FOREIGN KEY (LoanAccountId) REFERENCES [Appello].[Appello.tblLoanAccount] (LoanAccountId);

ALTER TABLE [Appello].[Appello.tblLoanRiskProfile] ADD CONSTRAINT FK_Appello.tblLoanRiskProfile_
    FOREIGN KEY (LoanAccountId) REFERENCES [Appello].[Appello.tblLoanAccount] (LoanAccountId);


