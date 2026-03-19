-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: InterFinanceMessages
-- Generated: 2026-03-18T12:08:48.593355
-- Datasets: 2
-- ============================================

-- Dataset: GDS26268
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'InterFinanceMessages')
    EXEC('CREATE SCHEMA [InterFinanceMessages]');

-- Stores inter-finance messages exchanged between institutions, including transactional, processing, a
CREATE TABLE [InterFinanceMessages].[TblInterFinanceMessage] (
    MessageId NVARCHAR(255) NOT NULL,
    MessageReference NVARCHAR(255) NOT NULL,
    CorrelationId NVARCHAR(255),
    MessageTypeCode NVARCHAR(255) NOT NULL,
    MessageSubtypeCode NVARCHAR(255),
    MessageDirection NVARCHAR(255) NOT NULL,
    SendingInstitutionBic NVARCHAR(255) NOT NULL,
    ReceivingInstitutionBic NVARCHAR(255) NOT NULL,
    SenderMessageTimestamp DATETIME2 NOT NULL,
    MasrephIngestTimestamp DATETIME2 NOT NULL,
    ValueDate DATE,
    TradeDate DATE,
    SettlementDate DATE,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    ExchangeRate DECIMAL(18,4),
    ChargesAmount DECIMAL(18,4),
    ChargesCurrency NVARCHAR(255),
    DebtorAccountIban NVARCHAR(255),
    CreditorAccountIban NVARCHAR(255),
    DebtorNameMasked NVARCHAR(255),
    CreditorNameMasked NVARCHAR(255),
    InstructionId NVARCHAR(255),
    EndToEndId NVARCHAR(255),
    RemittanceInformation NVARCHAR(255),
    MessageStatus NVARCHAR(255) NOT NULL,
    StatusReasonCode NVARCHAR(255),
    IsTimeCritical BIT NOT NULL,
    RegulatoryReportingFlag BIT NOT NULL,
    SanctionsScreeningResult NVARCHAR(255),
    CommercialProductType NVARCHAR(255),
    FacilityId NVARCHAR(255),
    CounterpartySectorCode NVARCHAR(255),
    OriginatingCountryCode NVARCHAR(255),
    BeneficiaryCountryCode NVARCHAR(255),
    ProcessingChannel NVARCHAR(255) NOT NULL,
    EnrichmentStatus NVARCHAR(255) NOT NULL,
    InternalCustomerIdHashed NVARCHAR(255),
    MessagePriorityCode NVARCHAR(255),
    MessageSizeBytes INT NOT NULL,
    RawMessageFormat NVARCHAR(255) NOT NULL,
    ProcessingTags NVARCHAR(MAX),
    DerivedMetrics NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblInterFinanceMessa PRIMARY KEY (MessageId)
);


-- Dataset: GDS47957
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'InterFinanceMessages')
    EXEC('CREATE SCHEMA [InterFinanceMessages]');

-- Core inter-finance message header, routing, financial, risk, compliance, and data-quality attributes
CREATE TABLE [InterFinanceMessages].[tblInterFinanceMessage] (
    MessageId NVARCHAR(255) NOT NULL,
    SourceInstitutionBic NVARCHAR(255) NOT NULL,
    DestinationInstitutionBic NVARCHAR(255) NOT NULL,
    MessageTypeCode NVARCHAR(255) NOT NULL,
    MessageSubtypeCode NVARCHAR(255),
    MessageDirection NVARCHAR(255) NOT NULL,
    MessageStatus NVARCHAR(255) NOT NULL,
    MessagePriority NVARCHAR(255),
    MessageChannelCode NVARCHAR(255),
    TransmissionTimestamp DATETIME2 NOT NULL,
    SettlementDate DATE,
    TradeDate DATE,
    ValueDate DATE,
    LeasingContractId NVARCHAR(255),
    MasrephInternalUnitCode NVARCHAR(255),
    LesseeCustomerId NVARCHAR(255),
    LesseeCountryCode NVARCHAR(255),
    LesseeSegmentCode NVARCHAR(255),
    CounterpartyInstitutionId NVARCHAR(255),
    InstrumentCurrencyCode NVARCHAR(255) NOT NULL,
    InstrumentNotionalAmount DECIMAL(18,4),
    LeaseTermMonths INT,
    InterestRatePercent DECIMAL(18,4),
    InterestRateType NVARCHAR(255),
    PaymentFrequencyCode NVARCHAR(255),
    NextPaymentDueDate DATE,
    PaymentAmount DECIMAL(18,4),
    OutstandingPrincipalAmount DECIMAL(18,4),
    CollateralTypeCode NVARCHAR(255),
    CollateralValueAmount DECIMAL(18,4),
    RiskRatingCode NVARCHAR(255),
    AmlFlag BIT NOT NULL,
    SanctionsScreeningStatus NVARCHAR(255),
    SanctionsScreeningHitList NVARCHAR(MAX),
    RegulatoryReportableFlag BIT NOT NULL,
    RegulatoryReportingCode NVARCHAR(255),
    MessageStatusChangeReason NVARCHAR(255),
    RejectionReasonCode NVARCHAR(255),
    OriginalMessageId NVARCHAR(255),
    RelatedTransactionId NVARCHAR(255),
    ProcessingBatchId NVARCHAR(255),
    BookingLocationCountryCode NVARCHAR(255),
    IngestionTimestamp DATETIME2 NOT NULL,
    LastUpdateTimestamp DATETIME2 NOT NULL,
    DataQualityScore DECIMAL(18,4),
    DataQualityIssueFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblInterFinanceMessa PRIMARY KEY (MessageId)
);

-- Large payload content associated with inter-finance messages, including the raw message as received 
CREATE TABLE [InterFinanceMessages].[InterFinanceMessagePayload] (
    MessageId NVARCHAR(255) NOT NULL,
    MessageRawPayload NVARCHAR(255),
    MessageParsedObject NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_InterFinanceMessageP PRIMARY KEY (MessageId)
);


