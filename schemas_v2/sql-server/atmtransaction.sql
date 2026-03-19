-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: AtmTransaction
-- Generated: 2026-03-18T12:08:48.618528
-- Datasets: 1
-- ============================================

-- Dataset: GDS68195
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AtmTransaction')
    EXEC('CREATE SCHEMA [AtmTransaction]');

-- Core retail finance transaction fact table capturing monetary movements and contextual attributes pe
CREATE TABLE [AtmTransaction].[TblRetailFinanceTransaction] (
    TransactionId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    AccountId NVARCHAR(255) NOT NULL,
    ProductId NVARCHAR(255) NOT NULL,
    TransactionTimestamp DATETIME2 NOT NULL,
    BookingDate DATE NOT NULL,
    ValueDate DATE,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    TransactionCurrency NVARCHAR(255) NOT NULL,
    AccountCountryCode NVARCHAR(255) NOT NULL,
    TransactionType NVARCHAR(255) NOT NULL,
    TransactionChannel NVARCHAR(255),
    IsReversal BIT NOT NULL,
    OriginalTransactionId NVARCHAR(255),
    TransactionStatus NVARCHAR(255) NOT NULL,
    FeeAmount DECIMAL(18,4),
    TaxAmount DECIMAL(18,4),
    InterchangeFeeAmount DECIMAL(18,4),
    BalanceAfterTransaction DECIMAL(18,4),
    AvailableBalanceAfterTransaction DECIMAL(18,4),
    MerchantCategoryCode NVARCHAR(255),
    MerchantNameHash NVARCHAR(255),
    CounterpartyIbanMasked NVARCHAR(255),
    CounterpartyCountryCode NVARCHAR(255),
    CustomerSegmentCode NVARCHAR(255),
    ProductCategory NVARCHAR(255) NOT NULL,
    ProductSubcategory NVARCHAR(255),
    InterestRateApplied DECIMAL(18,4),
    OverdraftLimitAmount DECIMAL(18,4),
    IsOverdraftUtilized BIT NOT NULL,
    CustomerAgeBand NVARCHAR(255),
    CustomerResidencyRegion NVARCHAR(255),
    TransactionReferenceText NVARCHAR(255),
    ProcessingBatchId NVARCHAR(255),
    PostingLatencySeconds INT,
    MerchantLocation NVARCHAR(MAX),
    ProductMarginEstimate DECIMAL(18,4),
    ForecastBucketMonth NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblRetailFinanceTran PRIMARY KEY (TransactionId)
);

-- Per-transaction marketing and cross-sell context, including flags and channel campaign linkage.
CREATE TABLE [AtmTransaction].[TblTransactionMarketing] (
    TransactionId NVARCHAR(255) NOT NULL,
    CrossSellOfferFlag BIT NOT NULL,
    ChannelCampaignCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionMarket PRIMARY KEY (TransactionId)
);

-- Normalized list of marketing offer identifiers associated with each transaction.
CREATE TABLE [AtmTransaction].[TblTransactionOffer] (
    TransactionOfferId INT NOT NULL,
    TransactionId NVARCHAR(255) NOT NULL,
    RelatedOfferId NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionOffer PRIMARY KEY (TransactionOfferId)
);

-- Loyalty and cashback metrics accrued per transaction.
CREATE TABLE [AtmTransaction].[TblTransactionLoyalty] (
    TransactionId NVARCHAR(255) NOT NULL,
    CashbackAmount DECIMAL(18,4),
    LoyaltyPointsEarned INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionLoyalt PRIMARY KEY (TransactionId)
);

-- Fraud risk scoring information associated with each transaction.
CREATE TABLE [AtmTransaction].[TblTransactionFraudRisk] (
    TransactionId NVARCHAR(255) NOT NULL,
    FraudSuspicionScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionFraudR PRIMARY KEY (TransactionId)
);

-- Dispute and chargeback status information per transaction.
CREATE TABLE [AtmTransaction].[TblTransactionDispute] (
    TransactionId NVARCHAR(255) NOT NULL,
    IsDisputed BIT NOT NULL,
    DisputeResolutionStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionDisput PRIMARY KEY (TransactionId)
);

-- Regulatory, AML, and data privacy compliance attributes for each transaction.
CREATE TABLE [AtmTransaction].[TblTransactionCompliance] (
    TransactionId NVARCHAR(255) NOT NULL,
    RegulatoryReportingFlag BIT NOT NULL,
    AmlRiskClass NVARCHAR(255),
    GdpComplianceFlag BIT NOT NULL,
    DataMaskingLevel NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_TblTransactionCompli PRIMARY KEY (TransactionId)
);

ALTER TABLE [AtmTransaction].[TblTransactionMarketing] ADD CONSTRAINT FK_TblTransactionMarketing_Tra
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);

ALTER TABLE [AtmTransaction].[TblTransactionOffer] ADD CONSTRAINT FK_TblTransactionOffer_Transac
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);

ALTER TABLE [AtmTransaction].[TblTransactionLoyalty] ADD CONSTRAINT FK_TblTransactionLoyalty_Trans
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);

ALTER TABLE [AtmTransaction].[TblTransactionFraudRisk] ADD CONSTRAINT FK_TblTransactionFraudRisk_Tra
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);

ALTER TABLE [AtmTransaction].[TblTransactionDispute] ADD CONSTRAINT FK_TblTransactionDispute_Trans
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);

ALTER TABLE [AtmTransaction].[TblTransactionCompliance] ADD CONSTRAINT FK_TblTransactionCompliance_Tr
    FOREIGN KEY (TransactionId) REFERENCES [AtmTransaction].[TblRetailFinanceTransaction] (TransactionId);


