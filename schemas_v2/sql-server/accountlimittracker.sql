-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: AccountLimitTracker
-- Generated: 2026-03-18T12:08:48.583255
-- Datasets: 1
-- ============================================

-- Dataset: GDS14372
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AccountLimitTracker')
    EXEC('CREATE SCHEMA [AccountLimitTracker]');

-- Customer master data for Masreph commercial finance customers, including segmentation, geography, an
CREATE TABLE [AccountLimitTracker].[tblCustomer] (
    CustomerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    LegalEntityName NVARCHAR(255) NOT NULL,
    CustomerSegmentCode NVARCHAR(255) NOT NULL,
    CustomerSegmentDescription NVARCHAR(255) NOT NULL,
    CountryIsoCode NVARCHAR(255) NOT NULL,
    MarketSegmentRegion NVARCHAR(255) NOT NULL,
    PortfolioManagerId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Core commercial loan facility/account attributes, relatively static over the lifecycle (account, pro
CREATE TABLE [AccountLimitTracker].[tblLoanFacility] (
    LoanFacilityId INT NOT NULL,
    CustomerId INT NOT NULL,
    LoanAccountNumber NVARCHAR(255) NOT NULL,
    Iban NVARCHAR(255),
    ProductId NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    OriginationDate DATE NOT NULL,
    MaturityDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLoanFacility PRIMARY KEY (LoanFacilityId)
);

-- Snapshoted limit, utilization, risk, and performance metrics for each loan facility at a given repor
CREATE TABLE [AccountLimitTracker].[tblLoanFacilitySnapshot] (
    LimitTrackRecordId NVARCHAR(255) NOT NULL,
    LoanFacilityId INT NOT NULL,
    LastLimitReviewDate DATE,
    CreditLimitAmount DECIMAL(18,4) NOT NULL,
    UtilizedBalanceAmount DECIMAL(18,4) NOT NULL,
    UtilizationRatePct DECIMAL(18,4) NOT NULL,
    DaysPastDue INT NOT NULL,
    NonAccrualFlag BIT NOT NULL,
    LoanStatusCode NVARCHAR(255) NOT NULL,
    InterestRateAnnualPct DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    CollateralTypeCode NVARCHAR(255),
    CollateralValueAmount DECIMAL(18,4),
    InternalRatingGrade NVARCHAR(255),
    ProbabilityOfDefaultPct DECIMAL(18,4),
    ExpectedLossAmount DECIMAL(18,4),
    RevenueYtdAmount DECIMAL(18,4) NOT NULL,
    InterestIncomeYtdAmount DECIMAL(18,4) NOT NULL,
    FeeIncomeYtdAmount DECIMAL(18,4) NOT NULL,
    WriteOffAmountYtd DECIMAL(18,4) NOT NULL,
    RestructuringFlag BIT NOT NULL,
    CrossSellEligibilityFlag BIT NOT NULL,
    ReportingSnapshotTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLoanFacilitySnaps PRIMARY KEY (LimitTrackRecordId)
);

ALTER TABLE [AccountLimitTracker].[tblLoanFacility] ADD CONSTRAINT FK_tblLoanFacility_CustomerId
    FOREIGN KEY (CustomerId) REFERENCES [AccountLimitTracker].[tblCustomer] (CustomerId);

ALTER TABLE [AccountLimitTracker].[tblLoanFacilitySnapshot] ADD CONSTRAINT FK_tblLoanFacilitySnapshot_Loa
    FOREIGN KEY (LoanFacilityId) REFERENCES [AccountLimitTracker].[tblLoanFacility] (LoanFacilityId);


