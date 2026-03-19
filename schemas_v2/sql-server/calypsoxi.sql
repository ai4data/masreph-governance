-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: CalypsoXI
-- Generated: 2026-03-18T12:08:48.599360
-- Datasets: 1
-- ============================================

-- Dataset: GDS34553
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CalypsoXI')
    EXEC('CREATE SCHEMA [CalypsoXI]');

-- Fact table for Finance Trade Insights records with trade-level metrics, risk parameters, profitabili
CREATE TABLE [CalypsoXI].[tblTradeFinanceInsight] (
    DatasetTradeInsightId NVARCHAR(255) NOT NULL,
    ProductKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    TradeContractKey INT NOT NULL,
    FacilityKey INT,
    BookingEntityKey INT NOT NULL,
    PortfolioSegmentKey INT NOT NULL,
    PortfolioManagerKey INT,
    MarketRegionKey INT NOT NULL,
    TradeReferenceNumber NVARCHAR(255) NOT NULL,
    TradeBookingDate DATE NOT NULL,
    TradeValueDate DATE NOT NULL,
    TradeMaturityDate DATE,
    TradeStatus NVARCHAR(255) NOT NULL,
    TradeCurrencyCode NVARCHAR(255) NOT NULL,
    TradeNotionalAmount DECIMAL(18,4) NOT NULL,
    TradeOutstandingPrincipal DECIMAL(18,4) NOT NULL,
    TradeInterestRate DECIMAL(18,4),
    TradePricingSpreadBps INT,
    TradeFeeIncomeAmount DECIMAL(18,4),
    TradeCommissionAmount DECIMAL(18,4),
    TradeRealizedPnlAmount DECIMAL(18,4),
    TradeUnrealizedPnlAmount DECIMAL(18,4),
    TradeRiskRating NVARCHAR(255),
    ProbabilityOfDefaultPct DECIMAL(18,4),
    LossGivenDefaultPct DECIMAL(18,4),
    ExposureAtDefaultAmount DECIMAL(18,4),
    UtilizationRatioPct DECIMAL(18,4),
    DaysPastDue INT,
    IsCrossSellOpportunity BIT NOT NULL,
    CrossSellProductRecommendation NVARCHAR(255),
    ProductRoiPct DECIMAL(18,4),
    ProductRevenueAmount DECIMAL(18,4),
    ProductCostAmount DECIMAL(18,4),
    ProductMarginPct DECIMAL(18,4),
    DataRecordTimestamp DATETIME2 NOT NULL,
    IsRecordActive BIT NOT NULL,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    DataQualityScorePct DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblTradeFinanceInsig PRIMARY KEY (DatasetTradeInsightId)
);

-- Dimension table for trade finance products and product type attributes.
CREATE TABLE [CalypsoXI].[tblProduct] (
    ProductKey INT NOT NULL,
    MasrephProductId NVARCHAR(255) NOT NULL,
    ProductTypeCode NVARCHAR(255) NOT NULL,
    ProductTypeDescription NVARCHAR(255) NOT NULL,
    TradeFinanceInstrument NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductKey)
);

-- Dimension table for Masreph customers and their segmentation and industry attributes.
CREATE TABLE [CalypsoXI].[tblCustomer] (
    CustomerKey INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CounterpartySegment NVARCHAR(255) NOT NULL,
    CounterpartyCountryCode NVARCHAR(255) NOT NULL,
    ClientIndustrySector NVARCHAR(255),
    ClientRevenueBand NVARCHAR(255),
    ClientRelationshipTenureYears DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerKey)
);

-- Dimension table for trade finance contracts or facility agreements.
CREATE TABLE [CalypsoXI].[tblTradeContract] (
    TradeContractKey INT NOT NULL,
    TradeContractId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblTradeContract PRIMARY KEY (TradeContractKey)
);

-- Dimension table for lending or trade finance facilities under which products are booked.
CREATE TABLE [CalypsoXI].[tblFacility] (
    FacilityKey INT NOT NULL,
    FacilityId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblFacility PRIMARY KEY (FacilityKey)
);

-- Dimension table for booking legal entities and branches/desks.
CREATE TABLE [CalypsoXI].[tblBookingEntity] (
    BookingEntityKey INT NOT NULL,
    BookingEntityCode NVARCHAR(255) NOT NULL,
    BookingBranchCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBookingEntity PRIMARY KEY (BookingEntityKey)
);

-- Dimension table for strategic portfolio segments and their competitiveness characteristics.
CREATE TABLE [CalypsoXI].[tblPortfolioSegment] (
    PortfolioSegmentKey INT NOT NULL,
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    MarketCompetitivenessScore INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPortfolioSegment PRIMARY KEY (PortfolioSegmentKey)
);

-- Dimension table for portfolio and relationship managers overseeing trades.
CREATE TABLE [CalypsoXI].[tblPortfolioManager] (
    PortfolioManagerKey INT NOT NULL,
    PortfolioManagerId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPortfolioManager PRIMARY KEY (PortfolioManagerKey)
);

-- Dimension table for market regions associated with trades.
CREATE TABLE [CalypsoXI].[tblMarketRegion] (
    MarketRegionKey INT NOT NULL,
    MarketRegionCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMarketRegion PRIMARY KEY (MarketRegionKey)
);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Prod
    FOREIGN KEY (ProductKey) REFERENCES [CalypsoXI].[tblProduct] (ProductKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Cust
    FOREIGN KEY (CustomerKey) REFERENCES [CalypsoXI].[tblCustomer] (CustomerKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Trad
    FOREIGN KEY (TradeContractKey) REFERENCES [CalypsoXI].[tblTradeContract] (TradeContractKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Faci
    FOREIGN KEY (FacilityKey) REFERENCES [CalypsoXI].[tblFacility] (FacilityKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Book
    FOREIGN KEY (BookingEntityKey) REFERENCES [CalypsoXI].[tblBookingEntity] (BookingEntityKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Port
    FOREIGN KEY (PortfolioSegmentKey) REFERENCES [CalypsoXI].[tblPortfolioSegment] (PortfolioSegmentKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Port
    FOREIGN KEY (PortfolioManagerKey) REFERENCES [CalypsoXI].[tblPortfolioManager] (PortfolioManagerKey);

ALTER TABLE [CalypsoXI].[tblTradeFinanceInsight] ADD CONSTRAINT FK_tblTradeFinanceInsight_Mark
    FOREIGN KEY (MarketRegionKey) REFERENCES [CalypsoXI].[tblMarketRegion] (MarketRegionKey);


