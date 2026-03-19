-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: CrossBorderPaymentOperations
-- Generated: 2026-03-18T12:08:48.616457
-- Datasets: 2
-- ============================================

-- Dataset: GDS68079
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CrossBorderPaymentOperations')
    EXEC('CREATE SCHEMA [CrossBorderPaymentOperations]');

-- Core lease product and contract attributes sourced from Masreph CrossPay Finance Dataset.
CREATE TABLE [CrossBorderPaymentOperations].[tblLeaseProduct] (
    LeaseProductId NVARCHAR(255) NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    ProductSegment NVARCHAR(255) NOT NULL,
    OriginatingCountryCode NVARCHAR(255) NOT NULL,
    CounterpartyCountryCode NVARCHAR(255) NOT NULL,
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE,
    ContractStatus NVARCHAR(255) NOT NULL,
    LeaseTermMonths INT NOT NULL,
    BillingFrequency NVARCHAR(255) NOT NULL,
    PrincipalAmount DECIMAL(18,4) NOT NULL,
    BookingCurrencyCode NVARCHAR(255) NOT NULL,
    PaymentCurrencyCode NVARCHAR(255) NOT NULL,
    FxSpotRate DECIMAL(18,4),
    FxRateSource NVARCHAR(255),
    CrossBorderIndicator BIT NOT NULL,
    InceptionTimestamp DATETIME2 NOT NULL,
    LastUpdateTimestamp DATETIME2 NOT NULL,
    EffectiveInterestRate DECIMAL(18,4) NOT NULL,
    UpfrontFeeAmount DECIMAL(18,4),
    UpfrontFeeWaivedIndicator BIT NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    DaysPastDue INT NOT NULL,
    NonPerformingIndicator BIT NOT NULL,
    LeaseAssetCategory NVARCHAR(255) NOT NULL,
    LeaseAssetResidualValue DECIMAL(18,4),
    CustomerResidencyStatus NVARCHAR(255),
    CustomerIndustryCode NVARCHAR(255),
    CustomerRiskGrade NVARCHAR(255),
    OnboardingChannel NVARCHAR(255) NOT NULL,
    ContractOriginationChannelRegion NVARCHAR(255),
    PaymentMethod NVARCHAR(255) NOT NULL,
    IbanHashed NVARCHAR(255),
    LesseeAgeAtOrigination INT,
    LesseeType NVARCHAR(255) NOT NULL,
    EarlyTerminationIndicator BIT NOT NULL,
    EarlyTerminationFeeAmount DECIMAL(18,4),
    RenewalOptionIndicator BIT NOT NULL,
    PurchaseOptionIndicator BIT NOT NULL,
    PurchaseOptionPrice DECIMAL(18,4),
    DataRecordSourceSystem NVARCHAR(255) NOT NULL,
    DataPrivacyClassification NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseProduct PRIMARY KEY (LeaseProductId)
);

-- Lease-level analytics, risk, profitability, and cross-sell metrics derived from Masreph CrossPay Fin
CREATE TABLE [CrossBorderPaymentOperations].[tblLeaseProductAnalytics] (
    LeaseProductId NVARCHAR(255) NOT NULL,
    PortfolioSegmentCode NVARCHAR(255),
    ExpectedLossRate DECIMAL(18,4),
    NetInterestIncomeToDate DECIMAL(18,4) NOT NULL,
    FeeIncomeToDate DECIMAL(18,4) NOT NULL,
    OperatingCostAllocatedToDate DECIMAL(18,4),
    ProductProfitabilityScore DECIMAL(18,4),
    CrossSellEligibilityFlag BIT NOT NULL,
    CrossSellProductRecommendation NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseProductAnaly PRIMARY KEY (LeaseProductId)
);


-- Dataset: GDS91110
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CrossBorderPaymentOperations')
    EXEC('CREATE SCHEMA [CrossBorderPaymentOperations]');

-- Masreph commercial finance customer master, linked to payments and enriched with industry and segmen
CREATE TABLE [CrossBorderPaymentOperations].[tblCustomer] (
    CustomerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    IndustrySectorCode NVARCHAR(255),
    ClientSegmentCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- External financial institutions handling the counterparty side of transactions, identified by BIC.
CREATE TABLE [CrossBorderPaymentOperations].[tblCounterpartyBank] (
    CounterpartyBankId INT NOT NULL,
    CounterpartyBankIdentifier NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCounterpartyBank PRIMARY KEY (CounterpartyBankId)
);

-- Batches or files grouping individual payment transactions submitted by clients.
CREATE TABLE [CrossBorderPaymentOperations].[tblPaymentBatch] (
    PaymentBatchKey INT NOT NULL,
    PaymentBatchId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPaymentBatch PRIMARY KEY (PaymentBatchKey)
);

-- Upstream operational systems providing payment records, for data lineage and integration management.
CREATE TABLE [CrossBorderPaymentOperations].[tblSourceSystem] (
    SourceSystemId INT NOT NULL,
    DataLineageSourceSystem NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSourceSystem PRIMARY KEY (SourceSystemId)
);

-- Cross-border and domestic commercial payment transactions with financial, operational, risk, and ana
CREATE TABLE [CrossBorderPaymentOperations].[tblPayment] (
    PaymentId NVARCHAR(255) NOT NULL,
    CustomerId INT NOT NULL,
    CounterpartyBankId INT NOT NULL,
    PaymentBatchKey INT,
    SourceSystemId INT NOT NULL,
    DebtorAccountIban NVARCHAR(255),
    CreditorAccountIban NVARCHAR(255),
    PaymentPlatformCode NVARCHAR(255) NOT NULL,
    PaymentProductType NVARCHAR(255) NOT NULL,
    PaymentInitiationChannel NVARCHAR(255) NOT NULL,
    PaymentExecutionTimestamp DATETIME2 NOT NULL,
    PaymentBookingDate DATE NOT NULL,
    ValueDate DATE,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionAmountEur DECIMAL(18,4),
    ExchangeRateApplied DECIMAL(18,4),
    FeeAmount DECIMAL(18,4),
    FeeCurrency NVARCHAR(255),
    InternalCostAmount DECIMAL(18,4),
    RevenueRecognitionFlag BIT NOT NULL,
    PaymentStatus NVARCHAR(255) NOT NULL,
    PaymentStatusReasonCode NVARCHAR(255),
    IsUrgentPayment BIT NOT NULL,
    IsCrossBorder BIT NOT NULL,
    OriginatingCountryCode NVARCHAR(255),
    BeneficiaryCountryCode NVARCHAR(255),
    OriginalPaymentId NVARCHAR(255),
    PaymentReferenceText NVARCHAR(255),
    RemittanceInformationStructure NVARCHAR(MAX),
    PaymentChannelLatencyMs INT,
    ProcessingSlaBreachedFlag BIT NOT NULL,
    LiquidityProductCode NVARCHAR(255),
    PricingPackageCode NVARCHAR(255),
    ChannelCostAllocationCode NVARCHAR(255),
    PortfolioBucketCode NVARCHAR(255),
    ProfitabilityScore DECIMAL(18,4),
    PaymentRiskRating NVARCHAR(255),
    FraudScreeningResultCode NVARCHAR(255),
    ComplianceScreeningFlags NVARCHAR(MAX),
    ChannelDeviceFingerprint NVARCHAR(255),
    CustomerConsentTimestamp DATETIME2,
    RecordIngestionTimestamp DATETIME2 NOT NULL,
    DataQualityIssueFlags NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPayment PRIMARY KEY (PaymentId)
);


