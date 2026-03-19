-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: Finance360CustomerInsights
-- Generated: 2026-03-18T12:08:48.592076
-- Datasets: 1
-- ============================================

-- Dataset: GDS20467
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Finance360CustomerInsights')
    EXEC('CREATE SCHEMA [Finance360CustomerInsights]');

-- Core static and contractual attributes of each financial derivative trade linked to property finance
CREATE TABLE [Finance360CustomerInsights].[tblDerivativeTrade] (
    TradeId NVARCHAR(255) NOT NULL,
    PropertyLoanId NVARCHAR(255) NOT NULL,
    CustomerUin NVARCHAR(255) NOT NULL,
    DerivativeProductType NVARCHAR(255) NOT NULL,
    TradeExecutionTimestamp DATETIME2 NOT NULL,
    TradeValueDate DATE NOT NULL,
    TradeMaturityDate DATE NOT NULL,
    NotionalAmount DECIMAL(18,2) NOT NULL,
    NotionalCurrency NVARCHAR(255) NOT NULL,
    FixedRate DECIMAL(7,5),
    FloatingRateIndex NVARCHAR(255),
    CounterpartyLei NVARCHAR(255),
    TradeStatus NVARCHAR(255) NOT NULL,
    IsCollateralized BIT NOT NULL,
    HedgeRelationshipType NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblDerivativeTrade PRIMARY KEY (TradeId)
);

-- Valuation snapshots and risk metrics for derivative trades, supporting mark-to-market, sensitivity a
CREATE TABLE [Finance360CustomerInsights].[tblDerivativeTradeValuation] (
    TradeValuationId INT NOT NULL,
    TradeId NVARCHAR(255) NOT NULL,
    CurrentMarkToMarket DECIMAL(20,4),
    ValuationTimestamp DATETIME2,
    RiskSensitivityVector NVARCHAR(MAX),
    MarketDataSource NVARCHAR(255),
    SupportedValuationTenors NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblDerivativeTradeVa PRIMARY KEY (TradeValuationId)
);

ALTER TABLE [Finance360CustomerInsights].[tblDerivativeTradeValuation] ADD CONSTRAINT FK_tblDerivativeTradeValuation
    FOREIGN KEY (TradeId) REFERENCES [Finance360CustomerInsights].[tblDerivativeTrade] (TradeId);


