-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: CorePaymentOperations
-- Generated: 2026-03-18T12:08:48.598361
-- Datasets: 4
-- ============================================

-- Dataset: GDS30718
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CorePaymentOperations')
    EXEC('CREATE SCHEMA [CorePaymentOperations]');

-- SEPA payment transactions captured from the core payment operations system for commercial finance an
CREATE TABLE [CorePaymentOperations].[tblSepaTransaction] (
    TransactionId NVARCHAR(255) NOT NULL,
    CustomerId INT NOT NULL,
    ProductId INT NOT NULL,
    SepaEndToEndId NVARCHAR(255),
    PaymentInstructionId NVARCHAR(255),
    SepaScheme NVARCHAR(255) NOT NULL,
    PaymentType NVARCHAR(255),
    InitiatingPartyName NVARCHAR(255) NOT NULL,
    DebtorIban NVARCHAR(255) NOT NULL,
    CreditorIban NVARCHAR(255) NOT NULL,
    DebtorBic NVARCHAR(255),
    CreditorBic NVARCHAR(255),
    DebtorCountryCode NVARCHAR(255) NOT NULL,
    CreditorCountryCode NVARCHAR(255) NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    MasrephFeeAmount DECIMAL(18,4),
    InterchangeFeeAmount DECIMAL(18,4),
    ValueDate DATE NOT NULL,
    ExecutionTimestamp DATETIME2 NOT NULL,
    BookingDate DATE NOT NULL,
    RequestedExecutionDate DATE,
    ProcessingStatus NVARCHAR(255) NOT NULL,
    SettlementStatus NVARCHAR(255),
    RejectionReasonCode NVARCHAR(255),
    ReturnReasonCode NVARCHAR(255),
    ChargeBearer NVARCHAR(255),
    IsInstantPayment BIT NOT NULL,
    IsCrossBorder BIT NOT NULL,
    IsRecurringPayment BIT,
    RecurringSeriesId NVARCHAR(255),
    PaymentPurposeCode NVARCHAR(255),
    RemittanceInformation NVARCHAR(255),
    ChannelIdentifier NVARCHAR(255),
    CutoffComplianceFlag BIT,
    ProcessingTimeMillis INT,
    RegulatoryReportingFlag BIT,
    AmlRiskScore DECIMAL(18,4),
    PortfolioBucket NVARCHAR(255),
    MasrephInternalAccountId NVARCHAR(255),
    PricingPlanCode NVARCHAR(255),
    RelatedTransactionIds NVARCHAR(MAX),
    FeeComponentBreakdown NVARCHAR(MAX),
    ConsentReferenceId NVARCHAR(255),
    DataQualityScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSepaTransaction PRIMARY KEY (TransactionId)
);

-- Commercial customer dimension for SEPA transactions, including segmentation and tenure attributes li
CREATE TABLE [CorePaymentOperations].[tblCustomer] (
    CustomerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    CustomerTenureMonths INT,
    RelationshipManagerId INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Masreph banking products and high-level categories under which SEPA transactions are processed.
CREATE TABLE [CorePaymentOperations].[tblProduct] (
    ProductId INT NOT NULL,
    MasrephProductId NVARCHAR(255) NOT NULL,
    ProductCategory NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductId)
);

-- Internal relationship manager reference data associated with commercial customers.
CREATE TABLE [CorePaymentOperations].[RelationshipManager] (
    RelationshipManagerId INT NOT NULL,
    MasrephRelationshipManagerId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_RelationshipManager PRIMARY KEY (RelationshipManagerId)
);

ALTER TABLE [CorePaymentOperations].[tblSepaTransaction] ADD CONSTRAINT FK_tblSepaTransaction_Customer
    FOREIGN KEY (CustomerId) REFERENCES [CorePaymentOperations].[tblCustomer] (CustomerId);

ALTER TABLE [CorePaymentOperations].[tblSepaTransaction] ADD CONSTRAINT FK_tblSepaTransaction_ProductI
    FOREIGN KEY (ProductId) REFERENCES [CorePaymentOperations].[tblProduct] (ProductId);

ALTER TABLE [CorePaymentOperations].[tblCustomer] ADD CONSTRAINT FK_tblCustomer_RelationshipMan
    FOREIGN KEY (RelationshipManagerId) REFERENCES [CorePaymentOperations].[RelationshipManager] (RelationshipManagerId);


-- Dataset: GDS74950
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CorePaymentOperations')
    EXEC('CREATE SCHEMA [CorePaymentOperations]');

-- Stores core SEPA payment transaction records for commercial finance analytics, including identifiers
CREATE TABLE [CorePaymentOperations].[tblSepaTransaction] (
    SepaTransactionId NVARCHAR(255) NOT NULL,
    EndToEndId NVARCHAR(255),
    InstructionId NVARCHAR(255) NOT NULL,
    DebtorIban NVARCHAR(255) NOT NULL,
    CreditorIban NVARCHAR(255) NOT NULL,
    DebtorBic NVARCHAR(255),
    CreditorBic NVARCHAR(255),
    DebtorCustomerId NVARCHAR(255) NOT NULL,
    CreditorCustomerId NVARCHAR(255),
    ProductCode NVARCHAR(255) NOT NULL,
    PaymentScheme NVARCHAR(255) NOT NULL,
    PaymentMethod NVARCHAR(255) NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    SettlementAmountEur DECIMAL(18,4),
    InterchangeFeeAmount DECIMAL(18,4),
    BankServiceFeeAmount DECIMAL(18,4),
    ValueDate DATE,
    ExecutionTimestamp DATETIME2 NOT NULL,
    BookingDate DATE NOT NULL,
    CutoffComplianceFlag BIT NOT NULL,
    PaymentStatusCode NVARCHAR(255) NOT NULL,
    PaymentStatusReason NVARCHAR(255),
    OriginatingCountryCode NVARCHAR(255) NOT NULL,
    BeneficiaryCountryCode NVARCHAR(255) NOT NULL,
    CorporateSegment NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    IsCrossBorderFlag BIT NOT NULL,
    RelatedLoanAccountId NVARCHAR(255),
    TreasuryPortfolioId NVARCHAR(255),
    CustomerMarginBand NVARCHAR(255),
    ProcessingChannelId NVARCHAR(255),
    RemittanceInformation NVARCHAR(255),
    BatchId NVARCHAR(255),
    RegulatoryReportingCode NVARCHAR(255),
    CustomerConsentFlag BIT NOT NULL,
    PaymentEnrichmentTags NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSepaTransaction PRIMARY KEY (SepaTransactionId)
);

-- Stores structured counterparty risk profile information associated with individual SEPA transactions
CREATE TABLE [CorePaymentOperations].[tblSepaCounterpartyRiskProfile] (
    SepaTransactionId NVARCHAR(255) NOT NULL,
    CounterpartyRiskProfile NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSepaCounterpartyR PRIMARY KEY (SepaTransactionId)
);

ALTER TABLE [CorePaymentOperations].[tblSepaCounterpartyRiskProfile] ADD CONSTRAINT FK_tblSepaCounterpartyRiskProf
    FOREIGN KEY (SepaTransactionId) REFERENCES [CorePaymentOperations].[tblSepaTransaction] (SepaTransactionId);


-- Dataset: GDS88327
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CorePaymentOperations')
    EXEC('CREATE SCHEMA [CorePaymentOperations]');

-- Lessee customer master data, consent, GDPR basis, and marketing eligibility.
CREATE TABLE [CorePaymentOperations].[tblLesseeCustomer] (
    LesseeCustomerKey INT NOT NULL,
    LesseeCustomerId NVARCHAR(255) NOT NULL,
    LesseeCustomerSegment NVARCHAR(255),
    LesseeResidencyCountry NVARCHAR(255),
    AnonymizedCustomerKey NVARCHAR(255) NOT NULL,
    MarketingConsentFlag BIT NOT NULL,
    GdprProcessingBasis NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLesseeCustomer PRIMARY KEY (LesseeCustomerKey)
);

-- Leasing product reference data including product code, description, and asset type.
CREATE TABLE [CorePaymentOperations].[tblLeaseProduct] (
    ProductKey INT NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductDescription NVARCHAR(255),
    AssetType NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseProduct PRIMARY KEY (ProductKey)
);

-- Lease contract master data linking customers, products, mandates, and core contract attributes.
CREATE TABLE [CorePaymentOperations].[tblLeaseContract] (
    LeaseContractKey INT NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    SepaMandateId NVARCHAR(255) NOT NULL,
    LesseeCustomerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CountryOfRisk NVARCHAR(255) NOT NULL,
    AssetMarketValueEur DECIMAL(18,4),
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE,
    ContractStatus NVARCHAR(255) NOT NULL,
    ExpectedResidualValueEur DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractKey)
);

-- Risk, performance, and revenue metrics at the lease contract level.
CREATE TABLE [CorePaymentOperations].[tblLeaseContractMetrics] (
    LeaseContractMetricsKey INT NOT NULL,
    LeaseContractKey INT NOT NULL,
    DefaultFlag BIT NOT NULL,
    WriteOffAmountEur DECIMAL(18,4),
    EffectiveInterestRate DECIMAL(18,4),
    InternalRateOfReturn DECIMAL(18,4),
    PortfolioSegment NVARCHAR(255),
    ProductMarginBps INT,
    RevenueRecognizedMtdEur DECIMAL(18,4),
    RevenueRecognizedYtdEur DECIMAL(18,4),
    LossGivenDefaultPercentage DECIMAL(18,4),
    ProbabilityOfDefaultPercentage DECIMAL(18,4),
    UtilizationRatePercentage DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseContractMetr PRIMARY KEY (LeaseContractMetricsKey)
);

-- SEPA payment transactions linked to lease contracts, including amounts, dates, channels, and operati
CREATE TABLE [CorePaymentOperations].[tblSepaPaymentTransaction] (
    DatasetRecordId NVARCHAR(255) NOT NULL,
    LeaseContractKey INT NOT NULL,
    PaymentDueDate DATE NOT NULL,
    PaymentExecutionTimestamp DATETIME2,
    PaymentAmountEur DECIMAL(18,4) NOT NULL,
    PaymentCurrency NVARCHAR(255) NOT NULL,
    SepaPaymentScheme NVARCHAR(255) NOT NULL,
    DebtorIban NVARCHAR(255) NOT NULL,
    DebtorBic NVARCHAR(255),
    CreditorIban NVARCHAR(255) NOT NULL,
    CreditorBic NVARCHAR(255),
    EndToEndTransactionId NVARCHAR(255),
    BatchBookingIndicator BIT,
    SettlementDate DATE,
    SettlementStatus NVARCHAR(255) NOT NULL,
    PaymentChannel NVARCHAR(255),
    DaysPastDue INT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdateTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblSepaPaymentTransa PRIMARY KEY (DatasetRecordId)
);


-- Dataset: GDS92545
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CorePaymentOperations')
    EXEC('CREATE SCHEMA [CorePaymentOperations]');

-- Customer master data for leasing customers involved in SEPA transactions.
CREATE TABLE [CorePaymentOperations].[tblCustomer] (
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CustomerCountryCode NVARCHAR(255) NOT NULL,
    RiskRatingScore INT,
    GdprConsentFlag BIT NOT NULL,
    CrossSellEligibilityFlag BIT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerInternalId)
);

-- Leasing contract master records linked to SEPA payments.
CREATE TABLE [CorePaymentOperations].[tblLeaseContract] (
    LeaseContractId NVARCHAR(255) NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    ContractProductCode NVARCHAR(255) NOT NULL,
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE,
    FirstDueDate DATE,
    LastPaymentDate DATE,
    LeaseTermMonths INT NOT NULL,
    PaymentFrequency NVARCHAR(255) NOT NULL,
    LeaseInterestRate DECIMAL(18,4),
    PortfolioSegmentCode NVARCHAR(255),
    InternalProfitabilityIndex DECIMAL(18,4),
    EarlyTerminationFlag BIT NOT NULL,
    ChannelSourceCode NVARCHAR(255),
    ProductPerformanceBucket NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

-- Individual SEPA payment transactions associated with leasing contracts.
CREATE TABLE [CorePaymentOperations].[tblSepaTransaction] (
    DatasetRecordId NVARCHAR(255) NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    SepaTransactionId NVARCHAR(255) NOT NULL,
    IbanDebtor NVARCHAR(255) NOT NULL,
    IbanCreditor NVARCHAR(255) NOT NULL,
    BicDebtorBank NVARCHAR(255),
    BicCreditorBank NVARCHAR(255) NOT NULL,
    MandateReference NVARCHAR(255) NOT NULL,
    SepaSchemeType NVARCHAR(255) NOT NULL,
    PaymentInstrumentType NVARCHAR(255) NOT NULL,
    TransactionBookingDate DATE NOT NULL,
    TransactionValueDate DATE,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    LeaseOutstandingPrincipal DECIMAL(18,4),
    TransactionStatusCode NVARCHAR(255) NOT NULL,
    DirectDebitReturnReasonCode NVARCHAR(255),
    DataRecordTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSepaTransaction PRIMARY KEY (DatasetRecordId)
);

ALTER TABLE [CorePaymentOperations].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_CustomerIn
    FOREIGN KEY (CustomerInternalId) REFERENCES [CorePaymentOperations].[tblCustomer] (CustomerInternalId);

ALTER TABLE [CorePaymentOperations].[tblSepaTransaction] ADD CONSTRAINT FK_tblSepaTransaction_LeaseCon
    FOREIGN KEY (LeaseContractId) REFERENCES [CorePaymentOperations].[tblLeaseContract] (LeaseContractId);


