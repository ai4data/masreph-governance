-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: AssetViewFinance
-- Generated: 2026-03-18T12:08:48.594359
-- Datasets: 1
-- ============================================

-- Dataset: GDS26734
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'AssetViewFinance')
    EXEC('CREATE SCHEMA [AssetViewFinance]');

-- Master data for borrowing entities, including segmentation and financial attributes used for risk an
CREATE TABLE [AssetViewFinance].[tblCustomerBorrower] (
    CustomerId NVARCHAR(255) NOT NULL,
    BorrowerSegment NVARCHAR(255) NOT NULL,
    BorrowerIndustryCode NVARCHAR(255),
    BorrowerLegalForm NVARCHAR(255),
    BorrowerIncorporationDate DATE,
    BorrowerAnnualRevenue DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomerBorrower PRIMARY KEY (CustomerId)
);

-- Loan facility data secured by property collateral, including amounts, terms, interest characteristic
CREATE TABLE [AssetViewFinance].[tblLoan] (
    LoanId NVARCHAR(255) NOT NULL,
    FacilityId NVARCHAR(255),
    CustomerId NVARCHAR(255) NOT NULL,
    OriginalLoanAmount DECIMAL(18,4) NOT NULL,
    OutstandingLoanBalance DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    CurrentInterestRate DECIMAL(18,4) NOT NULL,
    LoanStartDate DATE NOT NULL,
    LoanMaturityDate DATE NOT NULL,
    AmortizationType NVARCHAR(255) NOT NULL,
    DelinquencyStatus NVARCHAR(255) NOT NULL,
    DaysPastDue INT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoan PRIMARY KEY (LoanId)
);

-- Property collateral records linked to loans, capturing asset characteristics, location, collateral r
CREATE TABLE [AssetViewFinance].[tblPropertyCollateral] (
    CollateralId NVARCHAR(255) NOT NULL,
    LoanId NVARCHAR(255) NOT NULL,
    PropertyCollateralType NVARCHAR(255) NOT NULL,
    PropertyUsageType NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    PropertyCity NVARCHAR(255) NOT NULL,
    PropertyPostalCode NVARCHAR(255),
    PropertyAddressLine1 NVARCHAR(255) NOT NULL,
    PropertyAddressLine2 NVARCHAR(255),
    PropertyLatitude DECIMAL(18,4),
    PropertyLongitude DECIMAL(18,4),
    CollateralPriorityRank INT NOT NULL,
    CollateralStatus NVARCHAR(255) NOT NULL,
    LoanToValueRatio DECIMAL(18,4) NOT NULL,
    RegulatoryLtvCategory NVARCHAR(255) NOT NULL,
    LastInspectionDate DATE,
    OccupancyStatus NVARCHAR(255),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPropertyCollatera PRIMARY KEY (CollateralId)
);

-- Latest valuation and collateral-specific risk metrics for each property collateral record, supportin
CREATE TABLE [AssetViewFinance].[tblCollateralValuationRisk] (
    CollateralId NVARCHAR(255) NOT NULL,
    ValuationDate DATE NOT NULL,
    LatestValuationAmount DECIMAL(18,4) NOT NULL,
    ValuationCurrencyCode NVARCHAR(255) NOT NULL,
    ValuationMethod NVARCHAR(255) NOT NULL,
    ValuationSource NVARCHAR(255) NOT NULL,
    EnvironmentalRiskScore DECIMAL(18,4),
    MarketabilityScore INT,
    RiskGrade NVARCHAR(255) NOT NULL,
    RecoveryStrategyCode NVARCHAR(255),
    ForcedSaleDiscountRate DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCollateralValuati PRIMARY KEY (CollateralId)
);


