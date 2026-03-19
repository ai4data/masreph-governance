-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: RiskWatchFinance
-- Generated: 2026-03-18T12:08:48.624102
-- Datasets: 1
-- ============================================

-- Dataset: GDS86686
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'RiskWatchFinance')
    EXEC('CREATE SCHEMA [RiskWatchFinance]');

-- Customer master data for consumer borrowers associated with personal loans.
CREATE TABLE [RiskWatchFinance].[TblCustomer] (
    CustomerId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    GdprConsentFlag BIT NOT NULL,
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblCustomer PRIMARY KEY (CustomerId)
);

-- Loan application details capturing origination attributes and channel information.
CREATE TABLE [RiskWatchFinance].[TblLoanApplication] (
    ApplicationId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    LoanPurposeCode NVARCHAR(255) NOT NULL,
    ApplicationChannel NVARCHAR(255) NOT NULL,
    ApplicationDate DATE NOT NULL,
    ApprovalDate DATE,
    OriginationBranchCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLoanApplication PRIMARY KEY (ApplicationId)
);

-- Core personal loan contract and financial information, including balances and lifecycle dates.
CREATE TABLE [RiskWatchFinance].[TblLoan] (
    LoanId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    ApplicationId NVARCHAR(255) NOT NULL,
    SourceSystemId NVARCHAR(255) NOT NULL,
    LoanAccountNumber NVARCHAR(255) NOT NULL,
    ProductTypeCode NVARCHAR(255) NOT NULL,
    DisbursementDate DATE,
    MaturityDate DATE,
    LastPaymentDate DATE,
    PrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentOutstandingBalance DECIMAL(18,4) NOT NULL,
    InterestRateAnnual DECIMAL(18,4) NOT NULL,
    OriginationFeeAmount DECIMAL(18,4),
    LateFeeAccruedAmount DECIMAL(18,4),
    CurrencyCode NVARCHAR(255) NOT NULL,
    TermMonths INT NOT NULL,
    RepaymentFrequencyCode NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordUpdateTimestamp DATETIME2 NOT NULL,
    DataQualityScore DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLoan PRIMARY KEY (LoanId)
);

-- Risk assessment metrics and model outputs associated with each loan at origination and for monitorin
CREATE TABLE [RiskWatchFinance].[TblLoanRiskAssessment] (
    LoanId NVARCHAR(255) NOT NULL,
    CreditScoreValue INT,
    InternalRiskRating NVARCHAR(MAX),
    ProbabilityOfDefault12M DECIMAL(18,4),
    LossGivenDefaultPercentage DECIMAL(18,4),
    ExposureAtDefaultAmount DECIMAL(18,4),
    DebtToIncomeRatio DECIMAL(18,4),
    LoanToValueRatio DECIMAL(18,4),
    EmploymentStatusCode NVARCHAR(255),
    AnnualGrossIncomeAmount DECIMAL(18,4),
    VerificationStatusCode NVARCHAR(255),
    RiskSegmentCode NVARCHAR(255),
    ModelVersionIdentifier NVARCHAR(255),
    RiskAlertCodes NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLoanRiskAssessmen PRIMARY KEY (LoanId)
);

-- Collateral details associated with each loan, including type and valuation.
CREATE TABLE [RiskWatchFinance].[TblLoanCollateral] (
    LoanId NVARCHAR(255) NOT NULL,
    CollateralTypeCode NVARCHAR(255),
    CollateralValuationAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLoanCollateral PRIMARY KEY (LoanId)
);

-- Current delinquency, default, and restructuring status for each loan.
CREATE TABLE [RiskWatchFinance].[TblLoanStatus] (
    LoanId NVARCHAR(255) NOT NULL,
    DaysPastDue INT NOT NULL,
    DelinquencyStatusCode NVARCHAR(255) NOT NULL,
    NonAccrualStatusFlag BIT NOT NULL,
    RestructuringFlag BIT NOT NULL,
    WriteOffAmount DECIMAL(18,4) NOT NULL,
    DefaultDate DATE,
    ForbearanceFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblLoanStatus PRIMARY KEY (LoanId)
);

ALTER TABLE [RiskWatchFinance].[TblLoanApplication] ADD CONSTRAINT FK_TblLoanApplication_Customer
    FOREIGN KEY (CustomerId) REFERENCES [RiskWatchFinance].[TblCustomer] (CustomerId);

ALTER TABLE [RiskWatchFinance].[TblLoan] ADD CONSTRAINT FK_TblLoan_CustomerId
    FOREIGN KEY (CustomerId) REFERENCES [RiskWatchFinance].[TblCustomer] (CustomerId);

ALTER TABLE [RiskWatchFinance].[TblLoan] ADD CONSTRAINT FK_TblLoan_ApplicationId
    FOREIGN KEY (ApplicationId) REFERENCES [RiskWatchFinance].[TblLoanApplication] (ApplicationId);

ALTER TABLE [RiskWatchFinance].[TblLoanRiskAssessment] ADD CONSTRAINT FK_TblLoanRiskAssessment_LoanI
    FOREIGN KEY (LoanId) REFERENCES [RiskWatchFinance].[TblLoan] (LoanId);

ALTER TABLE [RiskWatchFinance].[TblLoanCollateral] ADD CONSTRAINT FK_TblLoanCollateral_LoanId
    FOREIGN KEY (LoanId) REFERENCES [RiskWatchFinance].[TblLoan] (LoanId);

ALTER TABLE [RiskWatchFinance].[TblLoanStatus] ADD CONSTRAINT FK_TblLoanStatus_LoanId
    FOREIGN KEY (LoanId) REFERENCES [RiskWatchFinance].[TblLoan] (LoanId);


