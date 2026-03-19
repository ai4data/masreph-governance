-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: TradeFinanceTransactionsStore
-- Generated: 2026-03-18T12:08:48.581229
-- Datasets: 1
-- ============================================

-- Dataset: GDS12075
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TradeFinanceTransactionsStore')
    EXEC('CREATE SCHEMA [TradeFinanceTransactionsStore]');

-- Customer / lessee master for trade finance lease transactions
CREATE TABLE [TradeFinanceTransactionsStore].[tblCustomer] (
    CustomerId NVARCHAR(255) NOT NULL,
    LesseeName NVARCHAR(255) NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    CounterpartySector NVARCHAR(255),
    CrossSellIndicator BIT NOT NULL,
    KycReviewDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Lease or trade finance contract master linked to trade finance lease transactions
CREATE TABLE [TradeFinanceTransactionsStore].[tblContract] (
    ContractId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    LeaseTenorMonths INT NOT NULL,
    InterestRate DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblContract PRIMARY KEY (ContractId)
);

-- Managed portfolio or book definitions for trade finance lease transactions
CREATE TABLE [TradeFinanceTransactionsStore].[tblPortfolio] (
    PortfolioId NVARCHAR(255) NOT NULL,
    PortfolioName NVARCHAR(255) NOT NULL,
    ProductManagerId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPortfolio PRIMARY KEY (PortfolioId)
);

-- Core fact table for trade finance lease transactions, including instrument, risk, operational, and p
CREATE TABLE [TradeFinanceTransactionsStore].[tblTradeFinanceLeaseTransaction] (
    TransactionId NVARCHAR(255) NOT NULL,
    ContractId NVARCHAR(255) NOT NULL,
    PortfolioId NVARCHAR(255) NOT NULL,
    TradeInstrumentType NVARCHAR(255) NOT NULL,
    LetterOfCreditNumber NVARCHAR(255),
    GuaranteeReferenceNumber NVARCHAR(255),
    UnderlyingAssetType NVARCHAR(255) NOT NULL,
    UnderlyingAssetDescription NVARCHAR(255),
    CurrencyCode NVARCHAR(255) NOT NULL,
    TransactionAmount DECIMAL(18,4) NOT NULL,
    FinancedAmount DECIMAL(18,4) NOT NULL,
    TradeBookingDate DATE NOT NULL,
    ValueDate DATE NOT NULL,
    MaturityDate DATE NOT NULL,
    TransactionStatus NVARCHAR(255) NOT NULL,
    CreditRiskGrade NVARCHAR(255),
    CollateralCoverageRatio DECIMAL(18,4),
    IncotermCode NVARCHAR(255),
    ShipmentCountryOrigin NVARCHAR(255),
    ShipmentCountryDestination NVARCHAR(255),
    AsiaPacRegion NVARCHAR(255) NOT NULL,
    ProductSegment NVARCHAR(255) NOT NULL,
    ExpectedLossAmount DECIMAL(18,4),
    RealizedLossAmount DECIMAL(18,4),
    RevenueRecognitionStatus NVARCHAR(255) NOT NULL,
    LastStatusUpdateTimestamp DATETIME2 NOT NULL,
    BookingBranchCode NVARCHAR(255) NOT NULL,
    ComplianceFlagSanctions BIT NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblTradeFinanceLease PRIMARY KEY (TransactionId)
);

ALTER TABLE [TradeFinanceTransactionsStore].[tblContract] ADD CONSTRAINT FK_tblContract_CustomerId
    FOREIGN KEY (CustomerId) REFERENCES [TradeFinanceTransactionsStore].[tblCustomer] (CustomerId);

ALTER TABLE [TradeFinanceTransactionsStore].[tblTradeFinanceLeaseTransaction] ADD CONSTRAINT FK_tblTradeFinanceLeaseTransac
    FOREIGN KEY (ContractId) REFERENCES [TradeFinanceTransactionsStore].[tblContract] (ContractId);

ALTER TABLE [TradeFinanceTransactionsStore].[tblTradeFinanceLeaseTransaction] ADD CONSTRAINT FK_tblTradeFinanceLeaseTransac
    FOREIGN KEY (PortfolioId) REFERENCES [TradeFinanceTransactionsStore].[tblPortfolio] (PortfolioId);


