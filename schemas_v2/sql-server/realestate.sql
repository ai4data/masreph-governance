-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: RealEstate
-- Generated: 2026-03-18T12:08:48.607327
-- Datasets: 3
-- ============================================

-- Dataset: GDS43922
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RealEstate')
    EXEC('CREATE SCHEMA [RealEstate]');

-- Core mortgage applicant master record including identity, relationship, consent, and profitability i
CREATE TABLE [RealEstate].[tblMortgageApplicant] (
    MortgageApplicantId NVARCHAR(255) NOT NULL,
    ClientGlobalId NVARCHAR(255) NOT NULL,
    CrmClientSegment NVARCHAR(255),
    ApplicantFirstName NVARCHAR(255) NOT NULL,
    ApplicantLastName NVARCHAR(255) NOT NULL,
    ApplicantDateOfBirth DATE NOT NULL,
    ApplicantCountryOfResidence NVARCHAR(255) NOT NULL,
    ApplicantNationalIdEncrypted NVARCHAR(255),
    ApplicantEmailAddress NVARCHAR(255),
    ApplicantMobilePhone NVARCHAR(255),
    KycCompletionStatus BIT NOT NULL,
    GdprConsentMarketing BIT NOT NULL,
    GdprConsentTimestamp DATETIME2,
    RelationshipManagerId NVARCHAR(255),
    ProfitabilityEstimatedLifetimeValue DECIMAL(18,4),
    CrossSellEligibilityFlags NVARCHAR(MAX),
    ApplicantContactPreferences NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMortgageApplicant PRIMARY KEY (MortgageApplicantId)
);

-- Mortgage application records including product selection, property details, financials, risk data, a
CREATE TABLE [RealEstate].[tblMortgageApplication] (
    ApplicationNumber NVARCHAR(255) NOT NULL,
    MortgageApplicantId NVARCHAR(255) NOT NULL,
    ApplicationSubmissionTimestamp DATETIME2 NOT NULL,
    ApplicationChannel NVARCHAR(255) NOT NULL,
    ApplicationStatusCode NVARCHAR(255) NOT NULL,
    ApplicationStatusTimestamp DATETIME2 NOT NULL,
    MortgageProductCode NVARCHAR(255) NOT NULL,
    MortgagePurposeCode NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    PropertyPostalCode NVARCHAR(255),
    RequestedLoanAmount DECIMAL(18,4) NOT NULL,
    ApprovedLoanAmount DECIMAL(18,4),
    MortgageInterestRate DECIMAL(18,4),
    LoanToValueRatio DECIMAL(18,4),
    ApplicantAnnualGrossIncome DECIMAL(18,4),
    HouseholdTotalMonthlyExpenses DECIMAL(18,4),
    ApplicantEmploymentStatus NVARCHAR(255),
    ApplicantEmployerName NVARCHAR(255),
    EmploymentStartDate DATE,
    ApplicantCreditScore INT,
    CreditScoreProviderName NVARCHAR(255),
    ApplicantExistingMortgageIndicator BIT NOT NULL,
    NumberOfExistingCreditObligations INT,
    TotalMonthlyDebtPayments DECIMAL(18,4),
    RiskGradeCode NVARCHAR(255),
    DeclineReasonCodes NVARCHAR(MAX),
    LastClientContactTimestamp DATETIME2,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMortgageApplicati PRIMARY KEY (ApplicationNumber)
);

ALTER TABLE [RealEstate].[tblMortgageApplication] ADD CONSTRAINT FK_tblMortgageApplication_Mort
    FOREIGN KEY (MortgageApplicantId) REFERENCES [RealEstate].[tblMortgageApplicant] (MortgageApplicantId);


-- Dataset: GDS45055
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RealEstate')
    EXEC('CREATE SCHEMA [RealEstate]');

-- Pledge of a collateral asset securing a loan, including linkage to loan, asset, customer, and pledge
CREATE TABLE [RealEstate].[AssetPledge] (
    AssetPledgeKey INT NOT NULL,
    PledgeIdentifier NVARCHAR(255) NOT NULL,
    LoanContractKey INT NOT NULL,
    CollateralAssetKey INT NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CollateralEligibilityFlag BIT NOT NULL,
    CollateralStatusCode NVARCHAR(255) NOT NULL,
    RiskSegmentCode NVARCHAR(255),
    RecoveryStrategyCode NVARCHAR(255),
    EnvironmentalRiskFlag BIT,
    LastRevaluationDate DATE,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_AssetPledge PRIMARY KEY (AssetPledgeKey)
);

-- Master data for collateral assets (primarily real estate), including identifiers and property locati
CREATE TABLE [RealEstate].[CollateralAsset] (
    CollateralAssetKey INT NOT NULL,
    CollateralAssetIdentifier NVARCHAR(255) NOT NULL,
    CollateralAssetType NVARCHAR(255) NOT NULL,
    CollateralAssetSubtype NVARCHAR(255),
    CollateralDescription NVARCHAR(255),
    PropertyAddressLine1 NVARCHAR(255) NOT NULL,
    PropertyAddressPostalCode NVARCHAR(255) NOT NULL,
    PropertyAddressCity NVARCHAR(255) NOT NULL,
    PropertyAddressCountryCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_CollateralAsset PRIMARY KEY (CollateralAssetKey)
);

-- Loan contract reference data for mortgage exposures secured by pledged collateral.
CREATE TABLE [RealEstate].[LoanContract] (
    LoanContractKey INT NOT NULL,
    LoanContractIdentifier NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_LoanContract PRIMARY KEY (LoanContractKey)
);

-- Time-variant valuations of pledged assets, including valuation method, amounts, and loan exposure sn
CREATE TABLE [RealEstate].[tblAssetValuation] (
    AssetValuationKey INT NOT NULL,
    AssetPledgeKey INT NOT NULL,
    ValuationDate DATE NOT NULL,
    ValuationTimestamp DATETIME2 NOT NULL,
    ValuerFirmName NVARCHAR(255),
    ValuationMethodCode NVARCHAR(255) NOT NULL,
    MarketValuationAmount DECIMAL(18,4) NOT NULL,
    ForcedSaleValuationAmount DECIMAL(18,4),
    ValuationCurrencyCode NVARCHAR(255) NOT NULL,
    LoanOutstandingBalanceAmount DECIMAL(18,4) NOT NULL,
    LoanOriginalAmount DECIMAL(18,4) NOT NULL,
    LoanToValueRatio DECIMAL(18,4) NOT NULL,
    RegulatoryHaircutPercentage DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAssetValuation PRIMARY KEY (AssetValuationKey)
);

-- Insurance information associated with pledged collateral assets, including policy and expiry details
CREATE TABLE [RealEstate].[tblCollateralInsurance] (
    CollateralInsuranceKey INT NOT NULL,
    AssetPledgeKey INT NOT NULL,
    CollateralInsurancePolicyNumber NVARCHAR(255),
    CollateralInsuranceExpiryDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralInsuran PRIMARY KEY (CollateralInsuranceKey)
);

ALTER TABLE [RealEstate].[AssetPledge] ADD CONSTRAINT FK_AssetPledge_LoanContractKey
    FOREIGN KEY (LoanContractKey) REFERENCES [RealEstate].[LoanContract] (LoanContractKey);

ALTER TABLE [RealEstate].[AssetPledge] ADD CONSTRAINT FK_AssetPledge_CollateralAsset
    FOREIGN KEY (CollateralAssetKey) REFERENCES [RealEstate].[CollateralAsset] (CollateralAssetKey);

ALTER TABLE [RealEstate].[tblAssetValuation] ADD CONSTRAINT FK_tblAssetValuation_AssetPled
    FOREIGN KEY (AssetPledgeKey) REFERENCES [RealEstate].[AssetPledge] (AssetPledgeKey);

ALTER TABLE [RealEstate].[tblCollateralInsurance] ADD CONSTRAINT FK_tblCollateralInsurance_Asse
    FOREIGN KEY (AssetPledgeKey) REFERENCES [RealEstate].[AssetPledge] (AssetPledgeKey);


-- Dataset: GDS75867
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RealEstate')
    EXEC('CREATE SCHEMA [RealEstate]');

-- Master record of mortgage applicants, capturing personal, contact, employment, and relationship-leve
CREATE TABLE [RealEstate].[tblApplicant] (
    ApplicantId NVARCHAR(255) NOT NULL,
    ClientGlobalId NVARCHAR(255) NOT NULL,
    ApplicantFirstName NVARCHAR(255) NOT NULL,
    ApplicantLastName NVARCHAR(255) NOT NULL,
    ApplicantDateOfBirth DATE NOT NULL,
    ApplicantCountryOfResidence NVARCHAR(255) NOT NULL,
    ApplicantPrimaryPhone NVARCHAR(255),
    ApplicantEmailAddress NVARCHAR(255),
    ApplicantEmploymentStatus NVARCHAR(255) NOT NULL,
    ApplicantEmployerName NVARCHAR(255),
    ApplicantAnnualGrossIncome DECIMAL(18,4) NOT NULL,
    ApplicantAdditionalIncomeAmount DECIMAL(18,4),
    ApplicantIncomeCurrency NVARCHAR(255) NOT NULL,
    KycCompletedFlag BIT NOT NULL,
    PepIndicator BIT NOT NULL,
    ConsentToMarketingFlag BIT NOT NULL,
    ClientProfitabilitySegment NVARCHAR(255),
    PredictedClvAmount DECIMAL(18,4),
    CrossSellEligibilityScore DECIMAL(18,4),
    PreferredContactChannel NVARCHAR(255),
    GdprConsentRecordId NVARCHAR(255),
    CurrentMortgageHolderFlag BIT NOT NULL,
    ExistingBankCustomerFlag BIT NOT NULL,
    ApplicantEmploymentStartDate DATE,
    ApplicantIndustrySectorCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblApplicant PRIMARY KEY (ApplicantId)
);

-- Individual mortgage applications linked to applicants, capturing loan request details, credit assess
CREATE TABLE [RealEstate].[tblMortgageApplication] (
    ApplicationNumber NVARCHAR(255) NOT NULL,
    ApplicantId NVARCHAR(255) NOT NULL,
    ApplicationSubmissionTimestamp DATETIME2 NOT NULL,
    ApplicationChannel NVARCHAR(255) NOT NULL,
    CreditScoreValue INT NOT NULL,
    CreditScoreProvider NVARCHAR(255) NOT NULL,
    LoanPurposeCode NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    RequestedLoanAmount DECIMAL(18,4) NOT NULL,
    RequestedLoanTermMonths INT NOT NULL,
    RequestedInterestRate DECIMAL(18,4),
    LtvRatio DECIMAL(18,4),
    DtiRatio DECIMAL(18,4),
    ApplicationStatusCode NVARCHAR(255) NOT NULL,
    ApplicationStatusTimestamp DATETIME2 NOT NULL,
    ConsentToCreditCheckFlag BIT NOT NULL,
    RiskGradeCode NVARCHAR(255),
    MortgageProductCode NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    LastContactTimestamp DATETIME2,
    DataRetentionExpiryDate DATE,
    ApplicationSourceCampaignCode NVARCHAR(255),
    NumberOfDependents INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblMortgageApplicati PRIMARY KEY (ApplicationNumber)
);

ALTER TABLE [RealEstate].[tblMortgageApplication] ADD CONSTRAINT FK_tblMortgageApplication_Appl
    FOREIGN KEY (ApplicantId) REFERENCES [RealEstate].[tblApplicant] (ApplicantId);


