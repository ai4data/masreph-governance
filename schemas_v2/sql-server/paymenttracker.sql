-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: PaymentTracker
-- Generated: 2026-03-18T12:08:48.589541
-- Datasets: 3
-- ============================================

-- Dataset: GDS18707
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'PaymentTracker')
    EXEC('CREATE SCHEMA [PaymentTracker]');

-- Customer master for leasing, including risk segment and domicile information used in payment progres
CREATE TABLE [PaymentTracker].[tblCustomer] (
    CustomerKey INT NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    CountryIsoCode NVARCHAR(255) NOT NULL,
    CustomerRiskSegment NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerKey)
);

-- Lease contract master including core contractual terms such as product, portfolio, dates, and origin
CREATE TABLE [PaymentTracker].[tblLeaseContract] (
    LeaseContractKey INT NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    CustomerKey INT NOT NULL,
    ProductId NVARCHAR(255) NOT NULL,
    PortfolioId NVARCHAR(255),
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    InterestRateEffective DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractKey)
);

-- Fact table capturing the status and financial breakdown of each lease payment event, including timin
CREATE TABLE [PaymentTracker].[tblPaymentProgress] (
    PaymentProgressId NVARCHAR(255) NOT NULL,
    LeaseContractKey INT NOT NULL,
    PaymentScheduleId NVARCHAR(255),
    PaymentSequenceNumber INT NOT NULL,
    PaymentDueDate DATE NOT NULL,
    PaymentPostedTimestamp DATETIME2,
    PaymentCurrencyCode NVARCHAR(255) NOT NULL,
    ScheduledPaymentAmount DECIMAL(18,4) NOT NULL,
    ActualPaymentAmount DECIMAL(18,4),
    PrincipalComponentAmount DECIMAL(18,4),
    InterestComponentAmount DECIMAL(18,4),
    FeeComponentAmount DECIMAL(18,4),
    PaymentStatusCode NVARCHAR(255) NOT NULL,
    PaymentStatusReason NVARCHAR(255),
    DaysPastDue INT NOT NULL,
    PaymentAllocationMethod NVARCHAR(255),
    PaymentChannelCode NVARCHAR(255),
    PaymentMethodCode NVARCHAR(255),
    MandateReference NVARCHAR(255),
    IbanMasked NVARCHAR(255),
    BicSwiftCode NVARCHAR(255),
    RemainingPrincipalBalance DECIMAL(18,4),
    IsFinalInstallment BIT NOT NULL,
    NonAccrualFlag BIT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    CollectionStrategyCode NVARCHAR(255),
    RevenueRecognitionStatus NVARCHAR(255),
    LastStatusUpdateTimestamp DATETIME2 NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordIngestionTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPaymentProgress PRIMARY KEY (PaymentProgressId)
);

ALTER TABLE [PaymentTracker].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_CustomerKe
    FOREIGN KEY (CustomerKey) REFERENCES [PaymentTracker].[tblCustomer] (CustomerKey);

ALTER TABLE [PaymentTracker].[tblPaymentProgress] ADD CONSTRAINT FK_tblPaymentProgress_LeaseCon
    FOREIGN KEY (LeaseContractKey) REFERENCES [PaymentTracker].[tblLeaseContract] (LeaseContractKey);


-- Dataset: GDS38849
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'PaymentTracker')
    EXEC('CREATE SCHEMA [PaymentTracker]');

-- Tracks the status and characteristics of individual payment events across Masreph’s consumer finance
CREATE TABLE [PaymentTracker].[tblPaymentProgress] (
    PaymentProgressId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    AccountId NVARCHAR(255) NOT NULL,
    ContractId NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    PaymentId NVARCHAR(255) NOT NULL,
    PaymentSequenceNumber INT NOT NULL,
    ScheduledPaymentDate DATE NOT NULL,
    ActualPaymentDate DATE,
    PaymentPostedTimestamp DATETIME2,
    ScheduledPaymentAmount DECIMAL(18,4) NOT NULL,
    ActualPaymentAmount DECIMAL(18,4),
    PrincipalComponentAmount DECIMAL(18,4),
    InterestComponentAmount DECIMAL(18,4),
    FeeComponentAmount DECIMAL(18,4),
    CurrencyCode NVARCHAR(255) NOT NULL,
    PaymentChannel NVARCHAR(255) NOT NULL,
    PaymentMethod NVARCHAR(255),
    PaymentStatus NVARCHAR(255) NOT NULL,
    PaymentStatusReason NVARCHAR(255),
    DaysPastDue INT,
    DelinquencyBucket NVARCHAR(255),
    RemainingPrincipalBalance DECIMAL(18,4),
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    InterestRateAnnualized DECIMAL(18,4),
    PaymentHolidayFlag BIT NOT NULL,
    RestructuredContractFlag BIT NOT NULL,
    PrepaymentFlag BIT NOT NULL,
    PrepaymentAmount DECIMAL(18,4),
    MasrephRegionCode NVARCHAR(255) NOT NULL,
    CountryOfBooking NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    PaymentProgressRatio DECIMAL(18,4),
    ArrearsBalanceAmount DECIMAL(18,4),
    WriteOffFlag BIT NOT NULL,
    PaymentReversalFlag BIT NOT NULL,
    PaymentReversalReasonCode NVARCHAR(255),
    PaymentReferenceExternal NVARCHAR(255),
    DebtorIbanMasked NVARCHAR(255),
    PaymentInitiationTimestamp DATETIME2,
    ProcessingLatencySeconds INT,
    PaymentAllocationStrategy NVARCHAR(255),
    ExpectedFutureInstallmentsCount INT,
    InternalCollectionStage NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    PaymentBehaviorScore DECIMAL(18,4),
    ForecastedDefaultProbability12m DECIMAL(18,4),
    PaymentTags NVARCHAR(MAX),
    OperationalMetadata NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPaymentProgress PRIMARY KEY (PaymentProgressId)
);


-- Dataset: GDS67609
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'PaymentTracker')
    EXEC('CREATE SCHEMA [PaymentTracker]');

-- Customer master for mobility finance contracts and payments.
CREATE TABLE [PaymentTracker].[tblCustomer] (
    CustomerKey INT NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerKey)
);

-- Contract-level attributes for mobility finance agreements and their repayment schedules.
CREATE TABLE [PaymentTracker].[tblContract] (
    ContractKey INT NOT NULL,
    ContractId NVARCHAR(255) NOT NULL,
    PaymentScheduleId NVARCHAR(255) NOT NULL,
    LoanAccountNumber NVARCHAR(255) NOT NULL,
    MasrephProductId NVARCHAR(255) NOT NULL,
    VehicleId NVARCHAR(255),
    OriginationDate DATE NOT NULL,
    ContractMaturityDate DATE,
    ContractTermMonths INT NOT NULL,
    InterestRateAnnual DECIMAL(18,4) NOT NULL,
    ProductSegmentCode NVARCHAR(255) NOT NULL,
    MobilityUseCase NVARCHAR(255),
    CountryCode NVARCHAR(255) NOT NULL,
    RegionCode NVARCHAR(255),
    PortfolioSegment NVARCHAR(255),
    RestructuringFlag BIT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    WriteOffDate DATE,
    RecoveryAmount DECIMAL(18,4),
    PortfolioOptimizationScore DECIMAL(18,4),
    CustomerKey INT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblContract PRIMARY KEY (ContractKey)
);

-- Reference data for payment methods and channels used for installments.
CREATE TABLE [PaymentTracker].[tblPaymentMethod] (
    PaymentMethodKey INT NOT NULL,
    PaymentMethodCode NVARCHAR(255),
    PaymentChannel NVARCHAR(255),
    MandateReference NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPaymentMethod PRIMARY KEY (PaymentMethodKey)
);

-- Masked payer bank account and BIC information for payments.
CREATE TABLE [PaymentTracker].[tblBankAccount] (
    BankAccountKey INT NOT NULL,
    IbanMasked NVARCHAR(255),
    BicCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBankAccount PRIMARY KEY (BankAccountKey)
);

-- Reference table for cross-sell and upsell campaign offers related to payments.
CREATE TABLE [PaymentTracker].[tblCrossSellOffer] (
    CrossSellOfferKey INT NOT NULL,
    CrossSellOfferCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCrossSellOffer PRIMARY KEY (CrossSellOfferKey)
);

-- Fact table tracking scheduled and actual payments, delinquencies, and related operational metrics fo
CREATE TABLE [PaymentTracker].[tblPaymentProgress] (
    PaymentProgressKey INT NOT NULL,
    DatasetRecordId NVARCHAR(255) NOT NULL,
    ContractKey INT NOT NULL,
    PaymentMethodKey INT,
    BankAccountKey INT,
    CrossSellOfferKey INT,
    PaymentSequenceNumber INT NOT NULL,
    ScheduledPaymentDate DATE NOT NULL,
    ActualPaymentDate DATE,
    PaymentPostedTimestamp DATETIME2,
    PaymentCurrencyCode NVARCHAR(255) NOT NULL,
    ScheduledPaymentAmount DECIMAL(18,4) NOT NULL,
    ActualPaymentAmount DECIMAL(18,4),
    PrincipalComponentAmount DECIMAL(18,4),
    InterestComponentAmount DECIMAL(18,4),
    FeeComponentAmount DECIMAL(18,4),
    RemainingPrincipalBalance DECIMAL(18,4),
    DaysPastDue INT,
    PaymentStatusCode NVARCHAR(255) NOT NULL,
    PaymentStatusDescription NVARCHAR(255),
    DelinquencyBucket NVARCHAR(255),
    CrossSellOfferFlag BIT NOT NULL,
    GdpComplianceFlag BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    RecordLoadTimestamp DATETIME2 NOT NULL,
    IsHistoricalRecord BIT NOT NULL,
    ChurnRiskScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPaymentProgress PRIMARY KEY (PaymentProgressKey)
);


