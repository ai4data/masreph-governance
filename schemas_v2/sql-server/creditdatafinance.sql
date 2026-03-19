-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: CreditDataFinance
-- Generated: 2026-03-18T12:08:48.591060
-- Datasets: 1
-- ============================================

-- Dataset: GDS19104
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CreditDataFinance')
    EXEC('CREATE SCHEMA [CreditDataFinance]');

-- Commercial borrowing customer master data including demographics and segmentation attributes.
CREATE TABLE [CreditDataFinance].[tblBorrower] (
    BorrowerKey INT NOT NULL,
    BorrowerId NVARCHAR(255) NOT NULL,
    IndustrySectorCode NVARCHAR(255),
    BorrowerLocation NVARCHAR(MAX),
    BorrowerLegalForm NVARCHAR(255),
    BorrowerAnnualRevenue DECIMAL(18,4),
    BorrowerEmployeeCount INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerKey)
);

-- Commercial lending product master, defining product codes, names, and high-level segments.
CREATE TABLE [CreditDataFinance].[tblProduct] (
    ProductKey INT NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    ProductSegment NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductKey)
);

-- Commercial loan account master data including contractual terms, risk parameters, and static attribu
CREATE TABLE [CreditDataFinance].[tblLoanAccount] (
    LoanAccountKey INT NOT NULL,
    LoanAccountId NVARCHAR(255) NOT NULL,
    BorrowerKey INT NOT NULL,
    ProductKey INT NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    OriginationDate DATE NOT NULL,
    MaturityDate DATE,
    FirstPaymentDate DATE,
    InterestRate DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    PrincipalAmount DECIMAL(18,4) NOT NULL,
    PaymentFrequency NVARCHAR(255) NOT NULL,
    AmortizationType NVARCHAR(255),
    LoanPurpose NVARCHAR(255),
    CountryOfRisk NVARCHAR(255),
    CollateralType NVARCHAR(255),
    CollateralValue DECIMAL(18,4),
    LtvRatio DECIMAL(18,4),
    InternalRatingGrade NVARCHAR(255),
    ProbabilityOfDefault DECIMAL(18,4),
    LossGivenDefault DECIMAL(18,4),
    ExposureAtDefault DECIMAL(18,4),
    OriginationChannel NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    RiskMitigationFlag BIT NOT NULL,
    CrossSellIndicator BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLoanAccount PRIMARY KEY (LoanAccountKey)
);

-- Periodic loan account snapshot by reporting date and transaction, including balances, delinquency st
CREATE TABLE [CreditDataFinance].[tblLoanAccountSnapshot] (
    LoanAccountSnapshotKey INT NOT NULL,
    LoanAccountKey INT NOT NULL,
    TransactionId NVARCHAR(255) NOT NULL,
    ReportingDate DATE NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    LastPaymentDate DATE,
    DaysPastDue INT NOT NULL,
    NonAccrualFlag BIT NOT NULL,
    RestructuringFlag BIT NOT NULL,
    DefaultStatus NVARCHAR(255) NOT NULL,
    DefaultDate DATE,
    WriteOffAmount DECIMAL(18,4) NOT NULL,
    InterestAccruedMtd DECIMAL(18,4) NOT NULL,
    InterestIncomeYtd DECIMAL(18,4) NOT NULL,
    FeeIncomeYtd DECIMAL(18,4) NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    RecordUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLoanAccountSnapsh PRIMARY KEY (LoanAccountSnapshotKey)
);

ALTER TABLE [CreditDataFinance].[tblLoanAccount] ADD CONSTRAINT FK_tblLoanAccount_BorrowerKey
    FOREIGN KEY (BorrowerKey) REFERENCES [CreditDataFinance].[tblBorrower] (BorrowerKey);

ALTER TABLE [CreditDataFinance].[tblLoanAccount] ADD CONSTRAINT FK_tblLoanAccount_ProductKey
    FOREIGN KEY (ProductKey) REFERENCES [CreditDataFinance].[tblProduct] (ProductKey);

ALTER TABLE [CreditDataFinance].[tblLoanAccountSnapshot] ADD CONSTRAINT FK_tblLoanAccountSnapshot_Loan
    FOREIGN KEY (LoanAccountKey) REFERENCES [CreditDataFinance].[tblLoanAccount] (LoanAccountKey);


