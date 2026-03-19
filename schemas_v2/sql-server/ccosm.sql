-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: Ccosm
-- Generated: 2026-03-18T12:08:48.622085
-- Datasets: 1
-- ============================================

-- Dataset: GDS77356
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Ccosm')
    EXEC('CREATE SCHEMA [Ccosm]');

-- Reference data for loan products used across consumer finance operations.
CREATE TABLE [Ccosm].[tblProduct] (
    ProductKey INT NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductCategory NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductKey)
);

-- Reference data for partner merchants and dealers involved in loan origination.
CREATE TABLE [Ccosm].[tblPartnerMerchant] (
    PartnerMerchantKey INT NOT NULL,
    PartnerMerchantId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPartnerMerchant PRIMARY KEY (PartnerMerchantKey)
);

-- Loan account dimension capturing contract-level and origination attributes for each loan.
CREATE TABLE [Ccosm].[tblLoanAccount] (
    LoanAccountKey INT NOT NULL,
    LoanAccountId NVARCHAR(255) NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    ProductKey INT NOT NULL,
    PartnerMerchantKey INT,
    ApplicationDate DATE NOT NULL,
    ApprovalDate DATE,
    DisbursementDate DATE,
    LoanCurrency NVARCHAR(255) NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    AnnualPercentageRate DECIMAL(18,4) NOT NULL,
    NominalInterestRate DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    TermMonths INT NOT NULL,
    InstallmentAmount DECIMAL(18,4) NOT NULL,
    BillingFrequency NVARCHAR(255) NOT NULL,
    CustomerAgeAtOrigination INT NOT NULL,
    CustomerCountryOfResidence NVARCHAR(255) NOT NULL,
    CustomerPostalCode NVARCHAR(255),
    CustomerRiskGrade NVARCHAR(255) NOT NULL,
    BureauScoreAtOrigination INT,
    ChannelOfOrigination NVARCHAR(255) NOT NULL,
    LoanPurposeCode NVARCHAR(255) NOT NULL,
    CollateralType NVARCHAR(255),
    LoanToValueRatio DECIMAL(18,4),
    PrepaymentPenaltyApplicable BIT NOT NULL,
    CompetitorRateBenchmark DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoanAccount PRIMARY KEY (LoanAccountKey)
);

-- Snapshot fact table capturing loan journey stages, risk metrics, and performance insights over time.
CREATE TABLE [Ccosm].[tblFinanceJourneyInsight] (
    JourneyInsightId NVARCHAR(255) NOT NULL,
    LoanAccountKey INT NOT NULL,
    JourneyStage NVARCHAR(255) NOT NULL,
    CurrentOutstandingPrincipal DECIMAL(18,4) NOT NULL,
    RemainingTermMonths INT NOT NULL,
    LoanStatus NVARCHAR(255) NOT NULL,
    DaysPastDue INT NOT NULL,
    IsNonPerformingLoan BIT NOT NULL,
    ChargeOffAmount DECIMAL(18,4),
    InterestIncomeMtd DECIMAL(18,4) NOT NULL,
    FeeIncomeMtd DECIMAL(18,4) NOT NULL,
    ExpectedLossLifetime DECIMAL(18,4) NOT NULL,
    ProbabilityOfDefault12m DECIMAL(18,4) NOT NULL,
    LossGivenDefault DECIMAL(18,4) NOT NULL,
    MasrephSegmentCode NVARCHAR(255),
    HasExistingMortgageWithMasreph BIT NOT NULL,
    NumberOfActiveProducts INT NOT NULL,
    CrossSellPropensityScore DECIMAL(18,4) NOT NULL,
    MarketingOptInEmail BIT NOT NULL,
    LastPaymentDate DATE,
    NextPaymentDueDate DATE NOT NULL,
    PortfolioSegment NVARCHAR(255) NOT NULL,
    SnapshotTimestamp DATETIME2 NOT NULL,
    TagsMarketInsights NVARCHAR(MAX),
    JourneyPerformanceMetrics NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceJourneyIns PRIMARY KEY (JourneyInsightId)
);

ALTER TABLE [Ccosm].[tblLoanAccount] ADD CONSTRAINT FK_tblLoanAccount_ProductKey
    FOREIGN KEY (ProductKey) REFERENCES [Ccosm].[tblProduct] (ProductKey);

ALTER TABLE [Ccosm].[tblLoanAccount] ADD CONSTRAINT FK_tblLoanAccount_PartnerMerch
    FOREIGN KEY (PartnerMerchantKey) REFERENCES [Ccosm].[tblPartnerMerchant] (PartnerMerchantKey);

ALTER TABLE [Ccosm].[tblFinanceJourneyInsight] ADD CONSTRAINT FK_tblFinanceJourneyInsight_Lo
    FOREIGN KEY (LoanAccountKey) REFERENCES [Ccosm].[tblLoanAccount] (LoanAccountKey);


