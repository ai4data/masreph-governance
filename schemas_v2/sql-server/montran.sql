-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: Montran
-- Generated: 2026-03-18T12:08:48.582247
-- Datasets: 1
-- ============================================

-- Dataset: GDS12343
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'Montran')
    EXEC('CREATE SCHEMA [Montran]');

-- Master data for leasing product configurations used across lease contracts.
CREATE TABLE [Montran].[tblProduct] (
    ProductKey INT NOT NULL,
    ProductId NVARCHAR(255) NOT NULL,
    LeaseProductType NVARCHAR(255) NOT NULL,
    InternalProductSegment NVARCHAR(255) NOT NULL,
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductKey)
);

-- Corporate lessee master data used for joining leasing exposure with broader relationship data.
CREATE TABLE [Montran].[tblCorporateCustomer] (
    CorporateCustomerKey INT NOT NULL,
    CorporateCustomerId NVARCHAR(255) NOT NULL,
    LesseeLegalName NVARCHAR(255) NOT NULL,
    LesseeIndustrySector NVARCHAR(255) NOT NULL,
    LesseeCountryCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCorporateCustomer PRIMARY KEY (CorporateCustomerKey)
);

-- Core static attributes of lease contracts including linkage to product and corporate customer.
CREATE TABLE [Montran].[tblLeaseContract] (
    LeaseContractKey INT NOT NULL,
    MasrephLeaseId NVARCHAR(255) NOT NULL,
    LeaseContractNumber NVARCHAR(255) NOT NULL,
    ProductKey INT NOT NULL,
    CorporateCustomerKey INT NOT NULL,
    AssetType NVARCHAR(255) NOT NULL,
    AssetDescription NVARCHAR(255),
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE NOT NULL,
    FirstPaymentDate DATE,
    PaymentFrequencyCode NVARCHAR(255) NOT NULL,
    LeaseTermMonths INT NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    ImplicitInterestRate DECIMAL(18,4),
    EffectiveYieldRate DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractKey)
);

-- Time-variant snapshot of lease contract performance, status, risk, and cashflow optimization metrics
CREATE TABLE [Montran].[tblLeaseContractSnapshot] (
    LeaseContractSnapshotKey INT NOT NULL,
    LeaseContractKey INT NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    PaymentAmountScheduled DECIMAL(18,4) NOT NULL,
    PaymentAmountActual DECIMAL(18,4),
    LastPaymentDate DATE,
    DaysPastDue INT NOT NULL,
    NonPerformingFlag BIT NOT NULL,
    ContractStatus NVARCHAR(255) NOT NULL,
    EarlyTerminationFlag BIT NOT NULL,
    EarlyTerminationDate DATE,
    RestructuringFlag BIT NOT NULL,
    RestructuringDate DATE,
    RiskRatingInternal NVARCHAR(255) NOT NULL,
    RiskWeightedAssetAmount DECIMAL(18,4),
    ExpectedCreditLoss12m DECIMAL(18,4),
    NetInvestmentInLease DECIMAL(18,4),
    OperatingMarginRate DECIMAL(18,4),
    RoaePercentage DECIMAL(18,4),
    CrossSellScore DECIMAL(18,4),
    DataSnapshotTimestamp DATETIME2 NOT NULL,
    SourceSystemCode NVARCHAR(255) NOT NULL,
    RecordEffectiveDate DATE NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContractSnap PRIMARY KEY (LeaseContractSnapshotKey)
);

ALTER TABLE [Montran].[Montran.tblLeaseContract] ADD CONSTRAINT FK_Montran.tblLeaseContract_Pr
    FOREIGN KEY (ProductKey) REFERENCES [Montran].[Montran.tblProduct] (ProductKey);

ALTER TABLE [Montran].[Montran.tblLeaseContract] ADD CONSTRAINT FK_Montran.tblLeaseContract_Co
    FOREIGN KEY (CorporateCustomerKey) REFERENCES [Montran].[Montran.tblCorporateCustomer] (CorporateCustomerKey);

ALTER TABLE [Montran].[Montran.tblLeaseContractSnapshot] ADD CONSTRAINT FK_Montran.tblLeaseContractSna
    FOREIGN KEY (LeaseContractKey) REFERENCES [Montran].[Montran.tblLeaseContract] (LeaseContractKey);


