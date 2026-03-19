-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: ComplianceTransactionService
-- Generated: 2026-03-18T12:08:48.604037
-- Datasets: 2
-- ============================================

-- Dataset: GDS38588
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ComplianceTransactionService')
    EXEC('CREATE SCHEMA [ComplianceTransactionService]');

-- Customer-level compliance and KYC attributes related to leasing transactions.
CREATE TABLE [ComplianceTransactionService].[tblCustomerComplianceProfile] (
    CustomerComplianceProfileId INT NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CustomerLegalName NVARCHAR(255) NOT NULL,
    CustomerTaxId NVARCHAR(255),
    CustomerCountryCode NVARCHAR(255) NOT NULL,
    CustomerDateOfBirth DATE,
    CustomerOnboardingDate DATE,
    EuGdprDataSubjectFlag BIT NOT NULL,
    KycRiskRatingScore DECIMAL(18,4),
    PepFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomerComplianc PRIMARY KEY (CustomerComplianceProfileId)
);

-- Lease contract master data relevant for compliance and risk analysis.
CREATE TABLE [ComplianceTransactionService].[tblLeaseContract] (
    LeaseContractId INT NOT NULL,
    MasrephLeaseContractId NVARCHAR(255) NOT NULL,
    LeasingProductType NVARCHAR(255) NOT NULL,
    AssetCategoryCode NVARCHAR(255),
    LeasingContractStartDate DATE NOT NULL,
    LeasingContractEndDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

-- Filtered leasing transactions with associated compliance screening and lineage metadata.
CREATE TABLE [ComplianceTransactionService].[tblComplianceTransaction] (
    TransactionId NVARCHAR(255) NOT NULL,
    LeaseContractId INT NOT NULL,
    CustomerComplianceProfileId INT NOT NULL,
    CounterpartyBankIban NVARCHAR(255),
    TransactionCurrencyCode NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionValueDate DATE NOT NULL,
    TransactionBookingTimestamp DATETIME2 NOT NULL,
    TransactionTypeCode NVARCHAR(255) NOT NULL,
    TransactionSubtypeDesc NVARCHAR(255),
    RegulatoryFilterRuleId NVARCHAR(255) NOT NULL,
    RegulatoryFilterRuleVersion NVARCHAR(255) NOT NULL,
    ComplianceScreeningStatus NVARCHAR(255) NOT NULL,
    ComplianceScreeningFindings NVARCHAR(MAX),
    SanctionsListMatchFlag BIT NOT NULL,
    SanctionsListMatchScore DECIMAL(18,4),
    HighRiskCountryFlag BIT NOT NULL,
    DataLineageSourceSystem NVARCHAR(255) NOT NULL,
    DataLineageBatchId NVARCHAR(255),
    RealTimeStreamEventId NVARCHAR(255),
    OriginalTransactionId NVARCHAR(255),
    CorrectionIndicator BIT NOT NULL,
    ReversalIndicator BIT NOT NULL,
    AmlAlertGeneratedFlag BIT NOT NULL,
    AmlAlertId NVARCHAR(255),
    TransactionChannelCode NVARCHAR(255) NOT NULL,
    InitiationChannelDetail NVARCHAR(MAX),
    CreatedByUserId NVARCHAR(255) NOT NULL,
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    RecordActiveFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblComplianceTransac PRIMARY KEY (TransactionId)
);

ALTER TABLE [ComplianceTransactionService].[tblComplianceTransaction] ADD CONSTRAINT FK_tblComplianceTransaction_Cu
    FOREIGN KEY (CustomerComplianceProfileId) REFERENCES [ComplianceTransactionService].[tblCustomerComplianceProfile] (CustomerComplianceProfileId);

ALTER TABLE [ComplianceTransactionService].[tblComplianceTransaction] ADD CONSTRAINT FK_tblComplianceTransaction_Le
    FOREIGN KEY (LeaseContractId) REFERENCES [ComplianceTransactionService].[tblLeaseContract] (LeaseContractId);

ALTER TABLE [ComplianceTransactionService].[tblComplianceTransaction] ADD CONSTRAINT FK_tblComplianceTransaction_Or
    FOREIGN KEY (OriginalTransactionId) REFERENCES [ComplianceTransactionService].[tblComplianceTransaction] (TransactionId);


-- Dataset: GDS91391
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ComplianceTransactionService')
    EXEC('CREATE SCHEMA [ComplianceTransactionService]');

-- Customer-level compliance and risk profile attributes used to link and enrich filtered transactions.
CREATE TABLE [ComplianceTransactionService].[tblCustomerComplianceProfile] (
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    ExternalCustomerReference NVARCHAR(255),
    CustomerAgeBracket NVARCHAR(255),
    CustomerResidencyStatus NVARCHAR(255),
    CustomerRiskSegment NVARCHAR(255),
    PepFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomerComplianc PRIMARY KEY (MasrephCustomerId)
);

-- Filtered financial transactions with compliance, AML, sanctions, and processing metadata from the Co
CREATE TABLE [ComplianceTransactionService].[tblComplianceTransactionFilter] (
    TransactionFilterId NVARCHAR(255) NOT NULL,
    SourceSystemId NVARCHAR(255) NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    TransactionReference NVARCHAR(255) NOT NULL,
    OriginalTransactionId NVARCHAR(255),
    TransactionTimestamp DATETIME2 NOT NULL,
    FilterProcessedTimestamp DATETIME2 NOT NULL,
    ProcessingBusinessDate DATE NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionDirection NVARCHAR(255) NOT NULL,
    TransactionTypeCode NVARCHAR(255) NOT NULL,
    TransactionChannel NVARCHAR(255) NOT NULL,
    MobilityContractId NVARCHAR(255),
    VehicleIdentifier NVARCHAR(255),
    OriginatingCountryCode NVARCHAR(255) NOT NULL,
    CounterpartyCountryCode NVARCHAR(255),
    IbanMasked NVARCHAR(255),
    SanctionsScreeningStatus NVARCHAR(255) NOT NULL,
    SanctionsHitScore DECIMAL(18,4),
    AmlRuleTriggered BIT NOT NULL,
    AmlRuleCodes NVARCHAR(MAX),
    FilterDecisionCode NVARCHAR(255) NOT NULL,
    FilterRejectionReason NVARCHAR(255),
    ManualReviewRequiredFlag BIT NOT NULL,
    ManualReviewOutcome NVARCHAR(255),
    GdprDataMinimizationFlag BIT NOT NULL,
    DataObfuscationLevel NVARCHAR(255) NOT NULL,
    DataLineageReference NVARCHAR(255),
    StreamPartitionKey NVARCHAR(255) NOT NULL,
    RealTimeProcessingFlag BIT NOT NULL,
    RegulatoryRegimeCode NVARCHAR(255),
    ComplianceCaseId NVARCHAR(255),
    DataQualityScore DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblComplianceTransac PRIMARY KEY (TransactionFilterId)
);

ALTER TABLE [ComplianceTransactionService].[tblComplianceTransactionFilter] ADD CONSTRAINT FK_tblComplianceTransactionFil
    FOREIGN KEY (MasrephCustomerId) REFERENCES [ComplianceTransactionService].[tblCustomerComplianceProfile] (MasrephCustomerId);


