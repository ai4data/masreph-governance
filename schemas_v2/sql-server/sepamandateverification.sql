-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: SepaMandateVerification
-- Generated: 2026-03-18T12:08:48.612138
-- Datasets: 3
-- ============================================

-- Dataset: GDS58112
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SepaMandateVerification')
    EXEC('CREATE SCHEMA [SepaMandateVerification]');

-- Core SEPA lease contract data including customer linkage, financial terms, lifecycle status, risk an
CREATE TABLE [SepaMandateVerification].[tblSepaContract] (
    ContractId NVARCHAR(255) NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    LesseeName NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE,
    ContractSignatureTimestamp DATETIME2 NOT NULL,
    ContractStatus NVARCHAR(255) NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    PaymentFrequency NVARCHAR(255) NOT NULL,
    InstallmentAmount DECIMAL(18,4) NOT NULL,
    TotalFinancedAmount DECIMAL(18,4) NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    InterestRate DECIMAL(18,4) NOT NULL,
    ContractTermMonths INT NOT NULL,
    PortfolioSegment NVARCHAR(255) NOT NULL,
    RiskGrade NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    GdpComplianceFlag BIT NOT NULL,
    IsActiveContract BIT NOT NULL,
    BookingBranchCode NVARCHAR(255),
    SalesChannel NVARCHAR(255),
    EarlyTerminationFlag BIT NOT NULL,
    EarlyTerminationDate DATE,
    DelinquencyStatus NVARCHAR(255) NOT NULL,
    DaysPastDue INT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdateTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSepaContract PRIMARY KEY (ContractId)
);

-- SEPA direct debit mandate and collection validation data associated with each lease contract.
CREATE TABLE [SepaMandateVerification].[tblSepaMandate] (
    ContractId NVARCHAR(255) NOT NULL,
    SepaMandateId NVARCHAR(255) NOT NULL,
    Iban NVARCHAR(255) NOT NULL,
    Bic NVARCHAR(255),
    MandateStatus NVARCHAR(255) NOT NULL,
    ValidationStatus NVARCHAR(255) NOT NULL,
    ValidationErrorCode NVARCHAR(255),
    ValidationErrorDescription NVARCHAR(255),
    SepaScheme NVARCHAR(255) NOT NULL,
    CreditorIdentifier NVARCHAR(255) NOT NULL,
    MandateSignatureDate DATE NOT NULL,
    MandateAmendmentIndicator BIT NOT NULL,
    FirstCollectionIndicator BIT NOT NULL,
    FinalCollectionIndicator BIT NOT NULL,
    NextDebitDate DATE,
    LastDebitDate DATE,
    LastDebitStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSepaMandate PRIMARY KEY (ContractId)
);

-- Underlying leased asset information and residual value associated with each SEPA lease contract.
CREATE TABLE [SepaMandateVerification].[tblSepaContractAsset] (
    ContractId NVARCHAR(255) NOT NULL,
    AssetCategory NVARCHAR(255) NOT NULL,
    AssetDescription NVARCHAR(255),
    ResidualValueAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSepaContractAsset PRIMARY KEY (ContractId)
);

ALTER TABLE [SepaMandateVerification].[tblSepaMandate] ADD CONSTRAINT FK_tblSepaMandate_ContractId
    FOREIGN KEY (ContractId) REFERENCES [SepaMandateVerification].[tblSepaContract] (ContractId);

ALTER TABLE [SepaMandateVerification].[tblSepaContractAsset] ADD CONSTRAINT FK_tblSepaContractAsset_Contra
    FOREIGN KEY (ContractId) REFERENCES [SepaMandateVerification].[tblSepaContract] (ContractId);


-- Dataset: GDS60566
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SepaMandateVerification')
    EXEC('CREATE SCHEMA [SepaMandateVerification]');

-- Core SEPA mandate verification fact table storing mandate lifecycle, party accounts, risk, usage, an
CREATE TABLE [SepaMandateVerification].[tblSepaMandate] (
    MandateId NVARCHAR(255) NOT NULL,
    MandateReference NVARCHAR(255) NOT NULL,
    SepaScheme NVARCHAR(255) NOT NULL,
    CreditorId NVARCHAR(255) NOT NULL,
    DebtorIban NVARCHAR(255) NOT NULL,
    DebtorBic NVARCHAR(255),
    CreditorIban NVARCHAR(255) NOT NULL,
    CreditorBic NVARCHAR(255),
    DebtorName NVARCHAR(255) NOT NULL,
    CreditorName NVARCHAR(255) NOT NULL,
    MandateSignatureDate DATE NOT NULL,
    MandateVerificationDate DATE NOT NULL,
    MandateStatus NVARCHAR(255) NOT NULL,
    MandateStatusReason NVARCHAR(255),
    MandateType NVARCHAR(255) NOT NULL,
    BusinessSegment NVARCHAR(255) NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    FirstCollectionDate DATE,
    LastCollectionDate DATE,
    MandateRevocationDate DATE,
    MandateExpiryDate DATE,
    CollectionFrequency NVARCHAR(255),
    MaxCollectionAmount DECIMAL(18,4),
    AvgCollectionAmount12m DECIMAL(18,4),
    TotalCollections12m INT,
    TotalCollectionValue12m DECIMAL(18,4),
    RiskRating NVARCHAR(255),
    MandateChannel NVARCHAR(255),
    ConsentCaptureMethod NVARCHAR(255),
    VerificationMethod NVARCHAR(255),
    VerificationScore DECIMAL(18,4),
    IsMandateActive BIT NOT NULL,
    IsMandateAmended BIT NOT NULL,
    LastAmendmentDate DATE,
    AmendmentReasonCode NVARCHAR(255),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    IngestionTimestamp DATETIME2 NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    RecordEndDate DATE,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CrossSellEligibilityScore DECIMAL(18,4),
    RevenueForecast12m DECIMAL(18,4),
    ProductKey INT NOT NULL,
    PortfolioKey INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSepaMandate PRIMARY KEY (MandateId)
);

-- Product dimension table storing Masreph banking products associated with SEPA mandates.
CREATE TABLE [SepaMandateVerification].[tblProduct] (
    ProductKey INT NOT NULL,
    ProductId NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductFamily NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductKey)
);

-- Portfolio dimension table representing commercial finance portfolios or relationship groups assigned
CREATE TABLE [SepaMandateVerification].[tblPortfolio] (
    PortfolioKey INT NOT NULL,
    PortfolioId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPortfolio PRIMARY KEY (PortfolioKey)
);

ALTER TABLE [SepaMandateVerification].[tblSepaMandate] ADD CONSTRAINT FK_tblSepaMandate_ProductKey
    FOREIGN KEY (ProductKey) REFERENCES [SepaMandateVerification].[tblProduct] (ProductKey);

ALTER TABLE [SepaMandateVerification].[tblSepaMandate] ADD CONSTRAINT FK_tblSepaMandate_PortfolioKey
    FOREIGN KEY (PortfolioKey) REFERENCES [SepaMandateVerification].[tblPortfolio] (PortfolioKey);


-- Dataset: GDS78561
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SepaMandateVerification')
    EXEC('CREATE SCHEMA [SepaMandateVerification]');

-- Master table storing SEPA payment rules and configuration for Masreph Nederland mobility products.
CREATE TABLE [SepaMandateVerification].[tblSepaPaymentRule] (
    RuleId NVARCHAR(255) NOT NULL,
    RuleVersion NVARCHAR(255) NOT NULL,
    SepaSchemeType NVARCHAR(255) NOT NULL,
    RuleName NVARCHAR(255) NOT NULL,
    RuleDescription NVARCHAR(MAX),
    EffectiveStartDate DATE NOT NULL,
    EffectiveEndDate DATE,
    IsActiveRule BIT NOT NULL,
    CountryIsoCode NVARCHAR(255) NOT NULL,
    ApplicableCustomerSegment NVARCHAR(255),
    PaymentFrequencyCode NVARCHAR(255),
    MaxTransactionAmountEur DECIMAL(18,4),
    MinTransactionAmountEur DECIMAL(18,4),
    CutoffTimeCet NVARCHAR(255),
    SettlementCycleDays INT,
    RequiresMandateReference BIT NOT NULL,
    MandateReferenceFormat NVARCHAR(255),
    RequiresIbanValidation BIT NOT NULL,
    AllowedCurrencyCode NVARCHAR(255) NOT NULL,
    MaxFailedCollections INT,
    ChargebackWindowDays INT,
    RequiresDebtorName BIT NOT NULL,
    RequiresDebtorAddress BIT NOT NULL,
    RequiresCreditorIdentifier BIT NOT NULL,
    CreditorIdentifierFormat NVARCHAR(255),
    MobilityProductCode NVARCHAR(255),
    BusinessLine NVARCHAR(255) NOT NULL,
    RulePriority INT,
    ExceptionHandlingPolicy NVARCHAR(MAX),
    RequiresRealTimeScreening BIT NOT NULL,
    ApplicableChannel NVARCHAR(255),
    RuleSourceReference NVARCHAR(255),
    CreatedTimestamp DATETIME2 NOT NULL,
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedByUserId NVARCHAR(255),
    RequiresCustomerConsent BIT NOT NULL,
    CustomerConsentValidityDays INT,
    DataRetentionPeriodDays INT,
    IsCrossBorderAllowed BIT NOT NULL,
    MaxDailyVolumePerCustomer INT,
    PortfolioImpactScore DECIMAL(18,4),
    InitiatingPartyType NVARCHAR(255),
    IsInstantPaymentSupported BIT NOT NULL,
    InstantPaymentCutoffTimeCet NVARCHAR(255),
    FeePricingModel NVARCHAR(255),
    AverageProcessingLatencyMs INT,
    RelatedKpiCodes NVARCHAR(MAX),
    ComplianceRiskRating NVARCHAR(255),
    PublishingStatus NVARCHAR(255) NOT NULL,
    ApplicableContractTenorMonths NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSepaPaymentRule PRIMARY KEY (RuleId)
);


