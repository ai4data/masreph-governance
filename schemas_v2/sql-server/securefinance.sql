-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: SecureFinance
-- Generated: 2026-03-18T12:08:48.596356
-- Datasets: 1
-- ============================================

-- Dataset: GDS28822
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'SecureFinance')
    EXEC('CREATE SCHEMA [SecureFinance]');

-- Master client entity capturing static and slowly-changing CRM, consent, profitability, risk, and eng
CREATE TABLE [SecureFinance].[TblClient] (
    ClientId NVARCHAR(255) NOT NULL,
    MasrephPartyId NVARCHAR(255) NOT NULL,
    ClientExternalReference NVARCHAR(255),
    ClientSegmentCode NVARCHAR(255) NOT NULL,
    ClientResidencyCountryCode NVARCHAR(255) NOT NULL,
    ClientPrimaryLanguageCode NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    RelationshipManagerRegion NVARCHAR(255),
    ClientProfitabilityScore DECIMAL(18,4),
    Rolling12mRevenueAmount DECIMAL(18,4),
    Rolling12mCostToServeAmount DECIMAL(18,4),
    ProductPortfolioSummary NVARCHAR(MAX),
    ClientRiskAppetiteLevel NVARCHAR(255),
    ClientLifecycleStageCode NVARCHAR(255) NOT NULL,
    ConsentMarketingEmailFlag BIT NOT NULL,
    ConsentTelephoneFlag BIT NOT NULL,
    ConsentDataProcessingFlag BIT NOT NULL,
    GdprConsentCaptureTimestamp DATETIME2,
    PreferredContactTimeWindow NVARCHAR(255),
    LastContactTimestamp DATETIME2,
    NextScheduledContactDate DATE,
    ClientChurnRiskScore DECIMAL(18,4),
    ClientSatisfactionScore INT,
    ReferralPotentialScore DECIMAL(18,4),
    CrossSellUpliftProbability DECIMAL(18,4),
    DigitalEngagementIndex DECIMAL(18,4),
    LastDigitalInteractionTimestamp DATETIME2,
    ClientIndustryCode NVARCHAR(255),
    HouseholdIncomeBandCode NVARCHAR(255),
    VipClientFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblClient PRIMARY KEY (ClientId)
);

-- Individual communication and interaction records between the client and the bank, including channel,
CREATE TABLE [SecureFinance].[TblClientCommunication] (
    CommunicationId NVARCHAR(255) NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    CommunicationChannelType NVARCHAR(255) NOT NULL,
    CommunicationDirectionCode NVARCHAR(255) NOT NULL,
    CommunicationStartTimestamp DATETIME2 NOT NULL,
    CommunicationEndTimestamp DATETIME2,
    CommunicationPurposeCode NVARCHAR(255) NOT NULL,
    CommunicationOutcomeCode NVARCHAR(255),
    CommunicationTopicTags NVARCHAR(MAX),
    SentimentScore DECIMAL(18,4),
    SentimentClassificationLabel NVARCHAR(255),
    EscalationRequiredFlag BIT NOT NULL,
    EscalationReasonCode NVARCHAR(255),
    NpsRatingValue INT,
    DataRecordSourceSystem NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblClientCommunicati PRIMARY KEY (CommunicationId)
);

ALTER TABLE [SecureFinance].[TblClientCommunication] ADD CONSTRAINT FK_TblClientCommunication_Clie
    FOREIGN KEY (ClientId) REFERENCES [SecureFinance].[TblClient] (ClientId);


