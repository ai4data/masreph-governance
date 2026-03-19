-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: DigitalFinanceMessages
-- Generated: 2026-03-18T12:08:48.609228
-- Datasets: 1
-- ============================================

-- Dataset: GDS52380
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DigitalFinanceMessages')
    EXEC('CREATE SCHEMA [DigitalFinanceMessages]');

-- Core secure finance message record including transport, security, processing status, revenue impact,
CREATE TABLE [DigitalFinanceMessages].[tblSecureFinanceMessage] (
    MessageId INT NOT NULL,
    DatasetMessageId NVARCHAR(255) NOT NULL,
    MessageUuid NVARCHAR(255) NOT NULL,
    ClientSnapshotId INT NOT NULL,
    ConversationThreadId INT NOT NULL,
    MessageSequenceNumber INT NOT NULL,
    MessageDirection NVARCHAR(255) NOT NULL,
    MessageChannel NVARCHAR(255) NOT NULL,
    MessageTypeCode NVARCHAR(255) NOT NULL,
    MessageSubject NVARCHAR(255),
    MessagePriorityCode NVARCHAR(255) NOT NULL,
    MessageCreatedTimestamp DATETIME2 NOT NULL,
    MessageSentTimestamp DATETIME2,
    MessageReceivedTimestamp DATETIME2,
    MessageProcessingStatus NVARCHAR(255) NOT NULL,
    MessageEncryptedPayload NVARCHAR(MAX) NOT NULL,
    EncryptionAlgorithm NVARCHAR(255) NOT NULL,
    EncryptionKeyIdentifier NVARCHAR(255) NOT NULL,
    DigitalSignatureHash NVARCHAR(255),
    IsSignatureVerified BIT NOT NULL,
    GdprPersonalDataFlag BIT NOT NULL,
    MessageLanguageCode NVARCHAR(255),
    LeasingContractId NVARCHAR(255),
    RelatedTransactionReference NVARCHAR(255),
    LeasingAssetType NVARCHAR(255),
    LeasingProductCode NVARCHAR(255),
    EstimatedMessageRevenueImpact DECIMAL(18,4),
    ReplyRequiredFlag BIT NOT NULL,
    ReplyDueDate DATE,
    AttachmentsMetadata NVARCHAR(MAX),
    PiiFieldsMasked NVARCHAR(MAX),
    CreatedBySystemId NVARCHAR(255) NOT NULL,
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    DataQualityScore DECIMAL(18,4),
    StreamingIngestTimestamp DATETIME2 NOT NULL,
    MessageSentimentScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblSecureFinanceMess PRIMARY KEY (MessageId)
);

-- Snapshot of client and relationship context associated with secure finance messages at the time of i
CREATE TABLE [DigitalFinanceMessages].[tblClientSnapshot] (
    ClientSnapshotId INT NOT NULL,
    MasrephClientId NVARCHAR(255) NOT NULL,
    ExternalClientReference NVARCHAR(255),
    ClientCountryCode NVARCHAR(255),
    ClientSegmentCode NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    RelationshipManagerName NVARCHAR(255),
    ProfitabilitySegment NVARCHAR(255),
    ClientLifecycleStage NVARCHAR(255),
    ClientSatisfactionScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientSnapshot PRIMARY KEY (ClientSnapshotId)
);

-- Conversation threads grouping related secure finance messages and tracking thread-level metadata.
CREATE TABLE [DigitalFinanceMessages].[tblConversationThread] (
    ConversationThreadId INT NOT NULL,
    ConversationThreadUuid NVARCHAR(255) NOT NULL,
    LastReplyTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblConversationThrea PRIMARY KEY (ConversationThreadId)
);


