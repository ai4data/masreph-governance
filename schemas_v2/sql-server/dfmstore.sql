-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: DfmStore
-- Generated: 2026-03-18T12:08:48.604037
-- Datasets: 3
-- ============================================

-- Dataset: GDS41353
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DfmStore')
    EXEC('CREATE SCHEMA [DfmStore]');

-- Customer master data for Masreph leasing portfolio, including static attributes, consent and structu
CREATE TABLE [DfmStore].[tblCustomer] (
    CustomerKey INT NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    ResidencyCountryCode NVARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    EmploymentStatus NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    InvestmentRiskToleranceLevel NVARCHAR(255),
    PreferredInvestmentHorizon NVARCHAR(255),
    ConsentForDataProcessingFlag BIT NOT NULL,
    HasPriorRestructureFlag BIT NOT NULL,
    GeoLocationRiskBucket NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerKey)
);

-- Leasing contract master data, linking Masreph contracts and accounts to customers and contractual te
CREATE TABLE [DfmStore].[tblLeasingContract] (
    LeasingContractKey INT NOT NULL,
    MasrephContractId NVARCHAR(255) NOT NULL,
    LeasingAccountNumber NVARCHAR(255) NOT NULL,
    CustomerKey INT NOT NULL,
    LeaseTenorMonths INT,
    LeaseEffectiveDate DATE,
    LeaseMaturityDate DATE,
    PaymentFrequencyCode NVARCHAR(255),
    CurrencyCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeasingContract PRIMARY KEY (LeasingContractKey)
);

-- Behavioural and risk insight snapshots per customer and leasing contract, including dynamic financia
CREATE TABLE [DfmStore].[tblFinanceBehaviouralInsight] (
    BehaviourRecordId NVARCHAR(255) NOT NULL,
    CustomerKey INT NOT NULL,
    LeasingContractKey INT NOT NULL,
    CustomerRiskProfile NVARCHAR(255),
    MonthlyNetIncomeAmount DECIMAL(18,4),
    MonthlyFixedObligationsAmount DECIMAL(18,4),
    AverageMonthlyCardSpendAmount DECIMAL(18,4),
    AverageMonthlyCashWithdrawalAmount DECIMAL(18,4),
    AverageMonthlyInvestmentContributionAmount DECIMAL(18,4),
    CreditUtilizationRatio DECIMAL(18,4),
    MissedPaymentCountLast12M INT,
    DaysPastDueMaxLast12M INT,
    ActiveLeaseCount INT NOT NULL,
    TotalOutstandingLeaseBalance DECIMAL(18,4) NOT NULL,
    BehaviouralRiskScore DECIMAL(18,4),
    DigitalEngagementIndex DECIMAL(18,4),
    LastDelinquencyDate DATE,
    FraudSuspectedFlag BIT NOT NULL,
    SpendingCategoryDistribution NVARCHAR(MAX),
    BehaviouralAlertFlags NVARCHAR(MAX),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordEffectiveTimestamp DATETIME2 NOT NULL,
    RecordIngestionTimestamp DATETIME2 NOT NULL,
    ModelVersionIdentifier NVARCHAR(255) NOT NULL,
    RecordQualityScore DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblFinanceBehavioura PRIMARY KEY (BehaviourRecordId)
);

ALTER TABLE [DfmStore].[tblLeasingContract] ADD CONSTRAINT FK_tblLeasingContract_Customer
    FOREIGN KEY (CustomerKey) REFERENCES [DfmStore].[tblCustomer] (CustomerKey);

ALTER TABLE [DfmStore].[tblFinanceBehaviouralInsight] ADD CONSTRAINT FK_tblFinanceBehaviouralInsigh
    FOREIGN KEY (CustomerKey) REFERENCES [DfmStore].[tblCustomer] (CustomerKey);

ALTER TABLE [DfmStore].[tblFinanceBehaviouralInsight] ADD CONSTRAINT FK_tblFinanceBehaviouralInsigh
    FOREIGN KEY (LeasingContractKey) REFERENCES [DfmStore].[tblLeasingContract] (LeasingContractKey);


-- Dataset: GDS44498
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DfmStore')
    EXEC('CREATE SCHEMA [DfmStore]');

-- Core co-borrower risk analysis facts per co-borrower and primary commercial loan account, including 
CREATE TABLE [DfmStore].[tblCoBorrowerRiskAnalysis] (
    CoBorrowerRiskAnalysisId NVARCHAR(255) NOT NULL,
    PrimaryLoanAccountId NVARCHAR(255) NOT NULL,
    CoBorrowerPartyId NVARCHAR(255) NOT NULL,
    CoBorrowerRoleCode NVARCHAR(255) NOT NULL,
    CoBorrowerCountryOfResidence NVARCHAR(255) NOT NULL,
    CoBorrowerInternalRatingScore INT NOT NULL,
    CoBorrowerPd12M DECIMAL(18,4) NOT NULL,
    CoBorrowerLgdPercentage DECIMAL(18,4) NOT NULL,
    CoBorrowerExposureAtDefaultEur DECIMAL(18,4) NOT NULL,
    CoBorrowerHighRiskFlag BIT NOT NULL,
    RiskDriverCodes NVARCHAR(MAX),
    RiskAssessmentEffectiveDate DATE NOT NULL,
    LastRiskAssessmentTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCoBorrowerRiskAna PRIMARY KEY (CoBorrowerRiskAnalysisId)
);

-- Regulatory and compliance-related indicators associated with a co-borrower risk analysis, stored as 
CREATE TABLE [DfmStore].[tblCoBorrowerRegulatoryCompliance] (
    CoBorrowerRiskAnalysisId NVARCHAR(255) NOT NULL,
    RegulatoryComplianceIndicators NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCoBorrowerRegulat PRIMARY KEY (CoBorrowerRiskAnalysisId)
);

ALTER TABLE [DfmStore].[tblCoBorrowerRegulatoryCompliance] ADD CONSTRAINT FK_tblCoBorrowerRegulatoryComp
    FOREIGN KEY (CoBorrowerRiskAnalysisId) REFERENCES [DfmStore].[tblCoBorrowerRiskAnalysis] (CoBorrowerRiskAnalysisId);


-- Dataset: GDS60554
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'DfmStore')
    EXEC('CREATE SCHEMA [DfmStore]');

-- Co-borrower master data and privacy attributes used across lease contracts and ratings.
CREATE TABLE [DfmStore].[tblCoBorrower] (
    CoBorrowerPartyId NVARCHAR(255) NOT NULL,
    ExternalId NVARCHAR(255),
    FullName NVARCHAR(255) NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    ResidenceCountry NVARCHAR(255),
    Segment NVARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    TaxIdentifierHash NVARCHAR(255),
    GdprConsentFlag BIT NOT NULL,
    PiiMinimizationLevel NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCoBorrower PRIMARY KEY (CoBorrowerPartyId)
);

-- Lease contracts under which co-borrower obligations and ratings are managed.
CREATE TABLE [DfmStore].[tblLeaseContract] (
    LeaseContractId NVARCHAR(255) NOT NULL,
    MasterAgreementId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

-- Credit ratings, scores, and risk metrics for co-borrowers at lease-contract level, including overrid
CREATE TABLE [DfmStore].[tblCoBorrowerRating] (
    RatingRecordId NVARCHAR(255) NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    CoBorrowerPartyId NVARCHAR(255) NOT NULL,
    RatingAgencyCode NVARCHAR(255) NOT NULL,
    InternalRatingModelCode NVARCHAR(255) NOT NULL,
    RatingVersionNumber INT NOT NULL,
    CreditRatingCode NVARCHAR(255) NOT NULL,
    CreditRatingDescription NVARCHAR(255),
    CreditScoreNumeric INT NOT NULL,
    ProbabilityOfDefault12M DECIMAL(18,4) NOT NULL,
    LossGivenDefaultPct DECIMAL(18,4),
    ExposureAtDefaultAmount DECIMAL(18,4),
    CurrencyCode NVARCHAR(255) NOT NULL,
    RatingEffectiveDate DATE NOT NULL,
    RatingExpiryDate DATE,
    RatingReviewTimestamp DATETIME2 NOT NULL,
    RatingStatusCode NVARCHAR(255) NOT NULL,
    RatingReasonCode NVARCHAR(255),
    RatingReasonDescription NVARCHAR(255),
    OverrideIndicator BIT NOT NULL,
    OverrideReasonText NVARCHAR(255),
    OverrideApproverId NVARCHAR(255),
    OverrideApprovalTimestamp DATETIME2,
    CollateralCoverageRatio DECIMAL(18,4),
    TotalLeaseExposureAmount DECIMAL(18,4),
    DaysPastDueCurrent INT NOT NULL,
    NonPerformingIndicator BIT NOT NULL,
    WatchlistIndicator BIT NOT NULL,
    RestructuringIndicator BIT NOT NULL,
    BehavioralScoreSegment NVARCHAR(255),
    LastPaymentDate DATE,
    NextPaymentDueDate DATE,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    IngestionTimestamp DATETIME2 NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdateTimestamp DATETIME2 NOT NULL,
    DataQualityScore DECIMAL(18,4) NOT NULL,
    DataLineageReference NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCoBorrowerRating PRIMARY KEY (RatingRecordId)
);

ALTER TABLE [DfmStore].[tblCoBorrowerRating] ADD CONSTRAINT FK_tblCoBorrowerRating_CoBorro
    FOREIGN KEY (CoBorrowerPartyId) REFERENCES [DfmStore].[tblCoBorrower] (CoBorrowerPartyId);

ALTER TABLE [DfmStore].[tblCoBorrowerRating] ADD CONSTRAINT FK_tblCoBorrowerRating_LeaseCo
    FOREIGN KEY (LeaseContractId) REFERENCES [DfmStore].[tblLeaseContract] (LeaseContractId);


