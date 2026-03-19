-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: StreamlinePayments
-- Generated: 2026-03-18T12:08:48.606177
-- Datasets: 1
-- ============================================

-- Dataset: GDS41843
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'StreamlinePayments')
    EXEC('CREATE SCHEMA [StreamlinePayments]');

-- Fact table capturing authorization decisions for commercial finance transactions, including risk, sc
CREATE TABLE [StreamlinePayments].[tblFinanceAuthorization] (
    AuthorizationId NVARCHAR(255) NOT NULL,
    PartnerId NVARCHAR(255) NOT NULL,
    TransactionId NVARCHAR(255) NOT NULL,
    OriginalRequestId NVARCHAR(255),
    CustomerLegalEntityId NVARCHAR(255) NOT NULL,
    CounterpartyIban NVARCHAR(255),
    CounterpartyName NVARCHAR(255),
    TransactionCurrency NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    AuthorizedAmount DECIMAL(18,4),
    ExchangeRate DECIMAL(18,4),
    AuthorizationStatus NVARCHAR(255) NOT NULL,
    AuthorizationDecisionCode NVARCHAR(255) NOT NULL,
    AuthorizationDecisionReason NVARCHAR(255),
    RiskScore DECIMAL(18,4),
    RiskBand NVARCHAR(255),
    ChannelType NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    FacilityId NVARCHAR(255),
    LimitCheckResult NVARCHAR(255) NOT NULL,
    AvailableCreditLimit DECIMAL(18,4),
    OverLimitIndicator BIT NOT NULL,
    ManualReviewRequired BIT NOT NULL,
    ManualReviewerId NVARCHAR(255),
    ManualReviewTimestamp DATETIME2,
    DecisionTimestamp DATETIME2 NOT NULL,
    RequestReceivedTimestamp DATETIME2 NOT NULL,
    SettlementExpectedDate DATE,
    MerchantCategoryCode NVARCHAR(255),
    TransactionPurposeCode NVARCHAR(255),
    SanctionScreeningResult NVARCHAR(255),
    FraudScreeningResult NVARCHAR(255),
    DuplicateTransactionIndicator BIT NOT NULL,
    RegionalRegulatoryFlag NVARCHAR(255),
    GdprConsentFlag BIT,
    DataLineageReference NVARCHAR(255),
    RecordCreateTimestamp DATETIME2 NOT NULL,
    RecordUpdateTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceAuthorizat PRIMARY KEY (AuthorizationId)
);

-- Dimension table for external commercial finance partners submitting transactions for authorization.
CREATE TABLE [StreamlinePayments].[tblPartner] (
    PartnerId NVARCHAR(255) NOT NULL,
    PartnerName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPartner PRIMARY KEY (PartnerId)
);

-- Dimension table for corporate customer legal entities, including segment and country classification.
CREATE TABLE [StreamlinePayments].[tblCustomerLegalEntity] (
    CustomerLegalEntityId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255) NOT NULL,
    CustomerCountryCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomerLegalEnti PRIMARY KEY (CustomerLegalEntityId)
);

-- Dimension table for merchant or industry categories associated with counterparties.
CREATE TABLE [StreamlinePayments].[tblMerchantCategory] (
    MerchantCategoryCode NVARCHAR(255) NOT NULL,
    MerchantCategoryDescription NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblMerchantCategory PRIMARY KEY (MerchantCategoryCode)
);

-- Dimension table for declared transaction purposes, including code and descriptive text.
CREATE TABLE [StreamlinePayments].[tblTransactionPurpose] (
    TransactionPurposeCode NVARCHAR(255) NOT NULL,
    TransactionPurposeDescription NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblTransactionPurpos PRIMARY KEY (TransactionPurposeCode)
);

ALTER TABLE [StreamlinePayments].[tblFinanceAuthorization] ADD CONSTRAINT FK_tblFinanceAuthorization_Par
    FOREIGN KEY (PartnerId) REFERENCES [StreamlinePayments].[tblPartner] (PartnerId);

ALTER TABLE [StreamlinePayments].[tblFinanceAuthorization] ADD CONSTRAINT FK_tblFinanceAuthorization_Cus
    FOREIGN KEY (CustomerLegalEntityId) REFERENCES [StreamlinePayments].[tblCustomerLegalEntity] (CustomerLegalEntityId);

ALTER TABLE [StreamlinePayments].[tblFinanceAuthorization] ADD CONSTRAINT FK_tblFinanceAuthorization_Mer
    FOREIGN KEY (MerchantCategoryCode) REFERENCES [StreamlinePayments].[tblMerchantCategory] (MerchantCategoryCode);

ALTER TABLE [StreamlinePayments].[tblFinanceAuthorization] ADD CONSTRAINT FK_tblFinanceAuthorization_Tra
    FOREIGN KEY (TransactionPurposeCode) REFERENCES [StreamlinePayments].[tblTransactionPurpose] (TransactionPurposeCode);


