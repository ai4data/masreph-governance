-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: InterFinance
-- Generated: 2026-03-18T11:48:10.831538
-- Datasets: 1
-- ============================================

-- Dataset: GDS26268
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'InterFinance')
    EXEC('CREATE SCHEMA [InterFinance]');

-- Core inter-finance message facts representing each financial message exchanged between institutions.
CREATE TABLE [InterFinance].[TblInterFinanceMessage] (
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
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblInterFinanceMessa PRIMARY KEY (MessageId)
);

-- Per-message analytical extensions including processing tags and derived metrics for BI acceleration.
CREATE TABLE [InterFinance].[TblInterFinanceMessageAnalytics] (
    MessageId NVARCHAR(255) NOT NULL,
    ProcessingTags NVARCHAR(MAX),
    DerivedMetrics NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblInterFinanceMessa PRIMARY KEY (MessageId)
);

ALTER TABLE [InterFinance].[TblInterFinanceMessageAnalytics] ADD CONSTRAINT FK_TblInterFinanceMessageAnaly
    FOREIGN KEY (MessageId) REFERENCES [InterFinance].[TblInterFinanceMessage] (MessageId);


