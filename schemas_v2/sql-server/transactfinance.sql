-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: TransactFinance
-- Generated: 2026-03-18T12:08:48.585259
-- Datasets: 15
-- ============================================

-- Dataset: GDS16494
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Borrowing entities linked to collateralised loans, including customer reference and demographic attr
CREATE TABLE [TransactFinance].[tblBorrower] (
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    BorrowerEntityType NVARCHAR(255) NOT NULL,
    BorrowerIndustryCodeNace NVARCHAR(255),
    BorrowerHeadcountBand NVARCHAR(255),
    BorrowerAnnualTurnoverEur DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerCustomerId)
);

-- Commercial finance facilities secured by property collateral.
CREATE TABLE [TransactFinance].[tblLoan] (
    LoanAccountId NVARCHAR(255) NOT NULL,
    LoanOriginationDate DATE NOT NULL,
    LoanMaturityDate DATE,
    LoanOutstandingBalanceEur DECIMAL(18,4) NOT NULL,
    LoanOriginalAmountEur DECIMAL(18,4) NOT NULL,
    LoanInterestRate DECIMAL(18,4) NOT NULL,
    LoanInterestRateType NVARCHAR(255) NOT NULL,
    LoanCurrencyCode NVARCHAR(255) NOT NULL,
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoan PRIMARY KEY (LoanAccountId)
);

-- Physical property assets pledged as collateral, including location, physical characteristics, enviro
CREATE TABLE [TransactFinance].[tblProperty] (
    PropertyId INT NOT NULL,
    PropertyCollateralType NVARCHAR(255) NOT NULL,
    PropertyUsageType NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    PropertyCity NVARCHAR(255) NOT NULL,
    PropertyPostalCode NVARCHAR(255),
    PropertyAddressLine NVARCHAR(255) NOT NULL,
    PropertyGrossLettableAreaSqm DECIMAL(18,4),
    PropertyConstructionYear INT,
    PropertyEnergyEfficiencyRating NVARCHAR(255),
    EnvironmentalRiskFlag BIT,
    FloodRiskZoneCode NVARCHAR(255),
    OccupancyRatePercent DECIMAL(18,4),
    MajorTenantName NVARCHAR(255),
    LeaseWeightedAverageUnexpiredTermYears DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblProperty PRIMARY KEY (PropertyId)
);

-- Formal property valuation records associated with collateral.
CREATE TABLE [TransactFinance].[tblValuation] (
    ValuationId NVARCHAR(255),
    ValuationEffectiveDate DATE,
    ValuationMarketValueEur DECIMAL(18,4),
    ValuationForcedSaleValueEur DECIMAL(18,4),
    ValuationMethodology NVARCHAR(255),
    ValuerFirmName NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblValuation PRIMARY KEY (ValuationId)
);

-- Collateral records linking properties to loans and capturing collateral-specific risk metrics and li
CREATE TABLE [TransactFinance].[tblCollateral] (
    CollateralId NVARCHAR(255) NOT NULL,
    LoanAccountId NVARCHAR(255) NOT NULL,
    PropertyId INT NOT NULL,
    ValuationId NVARCHAR(255),
    CurrentLtvPercent DECIMAL(18,4),
    OriginalLtvPercent DECIMAL(18,4),
    RegulatoryCollateralQuality NVARCHAR(255),
    CollateralLegalChargeRank NVARCHAR(255) NOT NULL,
    CollateralPledgeType NVARCHAR(255),
    CollateralRevaluationRequiredFlag BIT NOT NULL,
    CollateralStatusCode NVARCHAR(255) NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCollateral PRIMARY KEY (CollateralId)
);

ALTER TABLE [TransactFinance].[TransactFinance.tblLoan] ADD CONSTRAINT FK_TransactFinance.tblLoan_Bor
    FOREIGN KEY (BorrowerCustomerId) REFERENCES [TransactFinance].[TransactFinance.tblBorrower] (BorrowerCustomerId);

ALTER TABLE [TransactFinance].[TransactFinance.tblCollateral] ADD CONSTRAINT FK_TransactFinance.tblCollater
    FOREIGN KEY (LoanAccountId) REFERENCES [TransactFinance].[TransactFinance.tblLoan] (LoanAccountId);

ALTER TABLE [TransactFinance].[TransactFinance.tblCollateral] ADD CONSTRAINT FK_TransactFinance.tblCollater
    FOREIGN KEY (PropertyId) REFERENCES [TransactFinance].[TransactFinance.tblProperty] (PropertyId);

ALTER TABLE [TransactFinance].[TransactFinance.tblCollateral] ADD CONSTRAINT FK_TransactFinance.tblCollater
    FOREIGN KEY (ValuationId) REFERENCES [TransactFinance].[TransactFinance.tblValuation] (ValuationId);


-- Dataset: GDS17035
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Customer-level master data for high net worth customers in the Wealth Deposit Insights domain.
CREATE TABLE [TransactFinance].[tblCustomer] (
    CustomerId INT NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CustomerSegmentCode NVARCHAR(255) NOT NULL,
    CustomerResidenceCountry NVARCHAR(255) NOT NULL,
    PrimaryMobilityRelationshipType NVARCHAR(255),
    MobilityRelationshipStartDate DATE,
    MobilityPartnerChannel NVARCHAR(255),
    HasActiveMobilityLease BIT NOT NULL,
    CustomerMarketingConsentFlag BIT NOT NULL,
    GdprDataProcessingBasis NVARCHAR(255) NOT NULL,
    CustomerBirthYear INT,
    CustomerRiskProfileCode NVARCHAR(255),
    MobilityUsagePattern NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    PreferredReportingCurrency NVARCHAR(255),
    CustomerGeoLocation NVARCHAR(MAX),
    MobilityProductsHeld NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Deposit account master data for primary wealth and mobility-related deposit accounts.
CREATE TABLE [TransactFinance].[tblDepositAccount] (
    DepositAccountId INT NOT NULL,
    CustomerId INT NOT NULL,
    DepositAccountIban NVARCHAR(255) NOT NULL,
    DepositAccountCurrency NVARCHAR(255) NOT NULL,
    DepositProductCode NVARCHAR(255) NOT NULL,
    DepositProductName NVARCHAR(255) NOT NULL,
    ProductCategory NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE NOT NULL,
    AccountCloseDate DATE,
    IsAccountActive BIT NOT NULL,
    MasrephLegalEntityCode NVARCHAR(255) NOT NULL,
    AccountOnboardingChannel NVARCHAR(255) NOT NULL,
    TaxReportingClassification NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblDepositAccount PRIMARY KEY (DepositAccountId)
);

-- Point-in-time snapshot of wealth deposit behaviors, balances, flows, and analytics metrics for mobil
CREATE TABLE [TransactFinance].[WealthDepositInsightsSnapshot] (
    WealthInsightsRecordId NVARCHAR(255) NOT NULL,
    CustomerId INT NOT NULL,
    DepositAccountId INT NOT NULL,
    CurrentBalanceAmount DECIMAL(18,4) NOT NULL,
    AverageDailyBalance90d DECIMAL(18,4) NOT NULL,
    AverageDailyBalance365d DECIMAL(18,4),
    TotalDeposits90d DECIMAL(18,4) NOT NULL,
    TotalWithdrawals90d DECIMAL(18,4) NOT NULL,
    NetInflows90d DECIMAL(18,4) NOT NULL,
    InterestRateCurrent DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    AccruedInterestAmountMonthToDate DECIMAL(18,4),
    YtdInterestPaidAmount DECIMAL(18,4),
    DepositTurnoverRatio365d DECIMAL(18,4),
    LinkedAutoLoanOutstandingAmount DECIMAL(18,4),
    DepositBehaviorClusterId INT,
    MobilityRevenueContributionScore DECIMAL(18,4),
    CrossSellPropensityAutoLoan DECIMAL(18,4),
    PortfolioAllocationBucket NVARCHAR(255),
    LastDepositTransactionTimestamp DATETIME2,
    LastWithdrawalTransactionTimestamp DATETIME2,
    MobilityPaymentShare90d DECIMAL(18,4),
    EsgMobilityAlignmentScore DECIMAL(18,4),
    DataSnapshotTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_WealthDepositInsight PRIMARY KEY (WealthInsightsRecordId)
);

ALTER TABLE [TransactFinance].[tblDepositAccount] ADD CONSTRAINT FK_tblDepositAccount_CustomerI
    FOREIGN KEY (CustomerId) REFERENCES [TransactFinance].[tblCustomer] (CustomerId);

ALTER TABLE [TransactFinance].[WealthDepositInsightsSnapshot] ADD CONSTRAINT FK_WealthDepositInsightsSnapsh
    FOREIGN KEY (CustomerId) REFERENCES [TransactFinance].[tblCustomer] (CustomerId);

ALTER TABLE [TransactFinance].[WealthDepositInsightsSnapshot] ADD CONSTRAINT FK_WealthDepositInsightsSnapsh
    FOREIGN KEY (DepositAccountId) REFERENCES [TransactFinance].[tblDepositAccount] (DepositAccountId);


-- Dataset: GDS17676
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Borrower master data including demographics, industry classification, and sector limits.
CREATE TABLE [TransactFinance].[tblBorrower] (
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    IndustrySectorCode NVARCHAR(255),
    BorrowerAnnualRevenue DECIMAL(18,4),
    BorrowerEmployeeCount INT,
    BorrowerCountryOfIncorporation NVARCHAR(255),
    BorrowerLegalForm NVARCHAR(255),
    SectorExposureLimit DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerCustomerId)
);

-- Loan facility master data including borrower linkage, contractual terms, and static product attribut
CREATE TABLE [TransactFinance].[tblLoan] (
    LoanAccountId NVARCHAR(255) NOT NULL,
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    CountryIsoCode NVARCHAR(255) NOT NULL,
    BookingEntityCode NVARCHAR(255) NOT NULL,
    LoanOriginationDate DATE NOT NULL,
    LoanMaturityDate DATE,
    FirstDrawdownDate DATE,
    CurrencyCode NVARCHAR(255) NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4),
    InterestRateIndex NVARCHAR(255),
    InterestRateResetFrequencyMonths INT,
    RepaymentFrequencyCode NVARCHAR(255) NOT NULL,
    ContractualPaymentAmount DECIMAL(18,4),
    CollateralTypeCode NVARCHAR(255),
    CollateralValue DECIMAL(18,4),
    OriginationChannelCode NVARCHAR(255),
    PrepaymentPenaltyFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoan PRIMARY KEY (LoanAccountId)
);

-- Periodic loan-level reporting snapshot capturing balances, risk metrics, status, and lineage as of a
CREATE TABLE [TransactFinance].[tblLoanReportingSnapshot] (
    DatasetRecordId NVARCHAR(255) NOT NULL,
    LoanAccountId NVARCHAR(255) NOT NULL,
    ReportingDate DATE NOT NULL,
    LastPaymentDate DATE,
    CurrentOutstandingBalance DECIMAL(18,4) NOT NULL,
    DaysPastDue INT NOT NULL,
    NonAccrualFlag BIT NOT NULL,
    LoanStatusCode NVARCHAR(255) NOT NULL,
    RestructuringFlag BIT NOT NULL,
    LtvRatio DECIMAL(18,4),
    ProbabilityOfDefault12m DECIMAL(18,4),
    LossGivenDefault DECIMAL(18,4),
    InternalRatingGrade NVARCHAR(255),
    ExternalRatingAgency NVARCHAR(255),
    ExternalRatingGrade NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    WriteOffAmount DECIMAL(18,4) NOT NULL,
    ImpairmentStageIfrs9 INT,
    LastCreditReviewDate DATE,
    NextCreditReviewDate DATE,
    DataRecordSourceSystem NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLoanReportingSnap PRIMARY KEY (DatasetRecordId)
);

ALTER TABLE [TransactFinance].[tblLoan] ADD CONSTRAINT FK_tblLoan_BorrowerCustomerId
    FOREIGN KEY (BorrowerCustomerId) REFERENCES [TransactFinance].[tblBorrower] (BorrowerCustomerId);

ALTER TABLE [TransactFinance].[tblLoanReportingSnapshot] ADD CONSTRAINT FK_tblLoanReportingSnapshot_Lo
    FOREIGN KEY (LoanAccountId) REFERENCES [TransactFinance].[tblLoan] (LoanAccountId);


-- Dataset: GDS23334
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Master data for borrowers associated with property finance contracts, including stable demographic a
CREATE TABLE [TransactFinance].[tblBorrower] (
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    BorrowerSegment NVARCHAR(255) NOT NULL,
    BorrowerCountryOfResidence NVARCHAR(255) NOT NULL,
    BorrowerIndustryCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerCustomerId)
);

-- Lease financing contracts linked to property collateral, including loan amounts, interest terms, and
CREATE TABLE [TransactFinance].[tblLeaseContract] (
    LeaseContractId NVARCHAR(255) NOT NULL,
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    OriginalLoanAmount DECIMAL(18,4) NOT NULL,
    CurrentOutstandingBalance DECIMAL(18,4) NOT NULL,
    ContractCurrency NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    ReferenceRateIndex NVARCHAR(255),
    OriginationDate DATE NOT NULL,
    ContractMaturityDate DATE NOT NULL,
    BorrowerAgeAtOrigination INT,
    BorrowerEmploymentStatus NVARCHAR(255),
    BorrowerAnnualIncomeAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

-- Property collateral records securing lease contracts, including location, valuation, risk characteri
CREATE TABLE [TransactFinance].[tblPropertyCollateral] (
    CollateralId NVARCHAR(255) NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    PropertyCollateralType NVARCHAR(255) NOT NULL,
    PropertyUsageType NVARCHAR(255),
    PropertyAddress NVARCHAR(MAX) NOT NULL,
    PropertyPostalCode NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    PropertyValuationCurrency NVARCHAR(255) NOT NULL,
    InitialPropertyValuationAmount DECIMAL(18,4) NOT NULL,
    LatestPropertyValuationAmount DECIMAL(18,4),
    ValuationEffectiveDate DATE,
    ValuationMethodCode NVARCHAR(255),
    ValuationProviderType NVARCHAR(255),
    OriginalLoanToValueRatio DECIMAL(18,4) NOT NULL,
    CurrentLoanToValueRatio DECIMAL(18,4),
    RegulatoryCollateralClass NVARCHAR(255),
    CollateralHaircutPercentage DECIMAL(18,4),
    EnforcementStatus NVARCHAR(255) NOT NULL,
    EnforcementStartDate DATE,
    ForcedSaleDiscountPercentage DECIMAL(18,4),
    EnvironmentalRiskScore INT,
    PropertyEnergyPerformanceClass NVARCHAR(255),
    RiskFlags NVARCHAR(MAX),
    CollateralInsuranceCoverageAmount DECIMAL(18,4),
    CollateralInsuranceExpiryDate DATE,
    IsPrimaryCollateral BIT NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPropertyCollatera PRIMARY KEY (CollateralId)
);

ALTER TABLE [TransactFinance].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_BorrowerCu
    FOREIGN KEY (BorrowerCustomerId) REFERENCES [TransactFinance].[tblBorrower] (BorrowerCustomerId);

ALTER TABLE [TransactFinance].[tblPropertyCollateral] ADD CONSTRAINT FK_tblPropertyCollateral_Lease
    FOREIGN KEY (LeaseContractId) REFERENCES [TransactFinance].[tblLeaseContract] (LeaseContractId);


-- Dataset: GDS24120
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Master data for commercial finance accounts, including identifiers, static attributes, and configura
CREATE TABLE [TransactFinance].[tblAccount] (
    DatasetAccountId NVARCHAR(255) NOT NULL,
    SourceSystemId NVARCHAR(255) NOT NULL,
    LegalEntityId NVARCHAR(255) NOT NULL,
    AccountIban NVARCHAR(255) NOT NULL,
    AccountCurrencyCode NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE NOT NULL,
    AccountCloseDate DATE,
    AccountStatusCode NVARCHAR(255) NOT NULL,
    AccountSegmentCode NVARCHAR(255) NOT NULL,
    PrimaryProductCode NVARCHAR(255) NOT NULL,
    ProductFamilyName NVARCHAR(255),
    CountryIso2Code NVARCHAR(255) NOT NULL,
    CustomerIndustryCodeNace NVARCHAR(255),
    CreditLimitAmount DECIMAL(18,4),
    AccountManagerId NVARCHAR(255),
    OnboardingChannelCode NVARCHAR(255),
    GdpComplianceFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblAccount PRIMARY KEY (DatasetAccountId)
);

-- Time-series snapshot of financial balances, performance metrics, and risk measures for commercial ac
CREATE TABLE [TransactFinance].[tblAccountFinanceSnapshot] (
    AccountFinanceSnapshotId INT NOT NULL,
    AccountId NVARCHAR(255) NOT NULL,
    CurrentBalanceAmount DECIMAL(18,4) NOT NULL,
    AvailableBalanceAmount DECIMAL(18,4) NOT NULL,
    OverdueBalanceAmount DECIMAL(18,4),
    DaysPastDueCount INT,
    InterestRateAnnual DECIMAL(18,4),
    FeeIncomeMtdAmount DECIMAL(18,4) NOT NULL,
    FeeIncomeYtdAmount DECIMAL(18,4) NOT NULL,
    InterestIncomeMtdAmount DECIMAL(18,4) NOT NULL,
    InterestIncomeYtdAmount DECIMAL(18,4) NOT NULL,
    TransactionCountMtd INT NOT NULL,
    TransactionCountYtd INT NOT NULL,
    AvgTransactionAmount90d DECIMAL(18,4),
    LastTransactionTimestamp DATETIME2,
    NonperformingLoanFlag BIT NOT NULL,
    RiskRatingInternal NVARCHAR(255),
    ProbabilityOfDefaultPct DECIMAL(18,4),
    ExpectedLoss12mAmount DECIMAL(18,4),
    CollateralCoverageRatio DECIMAL(18,4),
    CrossSellProductCount INT,
    RevenueContributionScore DECIMAL(18,4),
    PortfolioSegmentBucket NVARCHAR(255),
    IsLiveDataFlag BIT NOT NULL,
    StreamingIngestTimestamp DATETIME2 NOT NULL,
    DataCaptureTimestamp DATETIME2 NOT NULL,
    RecordSourceEnvironment NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblAccountFinanceSna PRIMARY KEY (AccountFinanceSnapshotId)
);

ALTER TABLE [TransactFinance].[tblAccountFinanceSnapshot] ADD CONSTRAINT FK_tblAccountFinanceSnapshot_A
    FOREIGN KEY (AccountId) REFERENCES [TransactFinance].[tblAccount] (DatasetAccountId);


-- Dataset: GDS33552
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Represents a financial institution or consolidated client group node in the Finance Network Map, inc
CREATE TABLE [TransactFinance].[tblClientNode] (
    NetworkNodeId NVARCHAR(32) NOT NULL,
    MasrephClientId NVARCHAR(20) NOT NULL,
    InstitutionLegalName NVARCHAR(256) NOT NULL,
    InstitutionLei NVARCHAR(20),
    InstitutionCountryCode NVARCHAR(2) NOT NULL,
    InstitutionCity NVARCHAR(128),
    InstitutionSegment NVARCHAR(64) NOT NULL,
    CreditExposureEur DECIMAL(18,4),
    FundedExposureEur DECIMAL(18,4),
    UnfundedExposureEur DECIMAL(18,4),
    RiskRatingInternal NVARCHAR(16),
    RiskRatingExternal NVARCHAR(32),
    ProfitabilityScore DECIMAL(18,4),
    AnnualRevenueEur DECIMAL(18,4),
    AutoLendingActiveFlag BIT NOT NULL,
    PrimaryContactHashedId NVARCHAR(64),
    PrimaryContactRole NVARCHAR(64),
    PrimaryContactEmailDomain NVARCHAR(255),
    ClientOnboardingDate DATE,
    ClientLifecycleStage NVARCHAR(32) NOT NULL,
    StrategicImportanceTier NVARCHAR(16),
    CrossSellOpportunityScore DECIMAL(18,4),
    LastRelationshipReviewDate DATE,
    NextReviewDueDate DATE,
    SanctionsScreeningStatus NVARCHAR(32) NOT NULL,
    GdprProcessingLegalBasis NVARCHAR(64),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientNode PRIMARY KEY (NetworkNodeId)
);

-- Represents a relationship (edge) between two financial institutions in the Finance Network Map, incl
CREATE TABLE [TransactFinance].[tblFinanceNetworkEdge] (
    NetworkEdgeId NVARCHAR(32) NOT NULL,
    ParentInstitutionId NVARCHAR(24) NOT NULL,
    SubsidiaryInstitutionId NVARCHAR(24) NOT NULL,
    RelationshipType NVARCHAR(64) NOT NULL,
    RelationshipStartDate DATE NOT NULL,
    RelationshipEndDate DATE,
    RelationshipStatus NVARCHAR(32) NOT NULL,
    OwnershipPercentage DECIMAL(18,4),
    VotingRightsPercentage DECIMAL(18,4),
    MobilityFinancePortfolioFlag BIT NOT NULL,
    DataSourceSystem NVARCHAR(64) NOT NULL,
    DataRefreshTimestamp DATETIME2 NOT NULL,
    DataLineageObject NVARCHAR(MAX),
    AssociatedProductCodes NVARCHAR(MAX),
    RealTimeStreamEventId NVARCHAR(36),
    RecordActiveFlag BIT NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    ParentNetworkNodeId NVARCHAR(32),
    SubsidiaryNetworkNodeId NVARCHAR(32),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceNetworkEdg PRIMARY KEY (NetworkEdgeId)
);

ALTER TABLE [TransactFinance].[tblFinanceNetworkEdge] ADD CONSTRAINT FK_tblFinanceNetworkEdge_Paren
    FOREIGN KEY (ParentNetworkNodeId) REFERENCES [TransactFinance].[tblClientNode] (NetworkNodeId);

ALTER TABLE [TransactFinance].[tblFinanceNetworkEdge] ADD CONSTRAINT FK_tblFinanceNetworkEdge_Subsi
    FOREIGN KEY (SubsidiaryNetworkNodeId) REFERENCES [TransactFinance].[tblClientNode] (NetworkNodeId);


-- Dataset: GDS43307
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Master data for corporate customers placing deposits, including legal details, domicile, industry, a
CREATE TABLE [TransactFinance].[tblCorporateCustomer] (
    CorporateCustomerId INT NOT NULL,
    CorporateCustomerExternalId NVARCHAR(255) NOT NULL,
    CorporateLegalName NVARCHAR(255) NOT NULL,
    CorporateCountryOfDomicile NVARCHAR(255) NOT NULL,
    IndustryClassificationCode NVARCHAR(255),
    RelationshipManagerExternalId NVARCHAR(255),
    CustomerRatingInternal NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    GdpComplianceFlag BIT NOT NULL,
    ContactEmailAddress NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCorporateCustomer PRIMARY KEY (CorporateCustomerId)
);

-- Reference data for leasing-related deposit products offered to corporate customers.
CREATE TABLE [TransactFinance].[tblLeasingProduct] (
    LeasingProductId INT NOT NULL,
    LeasingProductCode NVARCHAR(255) NOT NULL,
    LeasingProductName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeasingProduct PRIMARY KEY (LeasingProductId)
);

-- Reference data for booking legal entities or branches within Europe that book the deposits.
CREATE TABLE [TransactFinance].[tblBookingEntity] (
    BookingEntityId INT NOT NULL,
    BookingEntityCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBookingEntity PRIMARY KEY (BookingEntityId)
);

-- Reference data for financial institutions holding the corporate deposits.
CREATE TABLE [TransactFinance].[tblFinancialInstitution] (
    FinancialInstitutionId INT NOT NULL,
    FinancialInstitutionBic NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblFinancialInstitut PRIMARY KEY (FinancialInstitutionId)
);

-- Reference data for internal portfolio segments (e.g., fleet leasing, equipment leasing).
CREATE TABLE [TransactFinance].[tblPortfolioSegment] (
    PortfolioSegmentId INT NOT NULL,
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblPortfolioSegment PRIMARY KEY (PortfolioSegmentId)
);

-- Fact table for corporate deposits, capturing financial terms, balances, lifecycle status, and links 
CREATE TABLE [TransactFinance].[tblCorporateDeposit] (
    DepositId NVARCHAR(255) NOT NULL,
    CorporateCustomerId INT NOT NULL,
    LeasingProductId INT NOT NULL,
    BookingEntityId INT NOT NULL,
    FinancialInstitutionId INT NOT NULL,
    PortfolioSegmentId INT NOT NULL,
    DepositAccountIban NVARCHAR(255) NOT NULL,
    DepositCurrencyCode NVARCHAR(255) NOT NULL,
    DepositPrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentDepositBalance DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4) NOT NULL,
    InterestRateIndex NVARCHAR(255),
    InterestRateSpreadBps INT,
    DepositStartDate DATE NOT NULL,
    DepositMaturityDate DATE,
    EarlyTerminationFlag BIT NOT NULL,
    EarlyTerminationPenaltyAmount DECIMAL(18,4),
    DepositStatusCode NVARCHAR(255) NOT NULL,
    LinkedLeaseContractId NVARCHAR(255),
    AutoRenewalFlag BIT NOT NULL,
    AutoRenewalTermMonths INT,
    AccruedInterestAmount DECIMAL(18,4) NOT NULL,
    InterestPaymentFrequency NVARCHAR(255) NOT NULL,
    LastInterestPaymentDate DATE,
    NextInterestPaymentDate DATE,
    CreationTimestamp DATETIME2 NOT NULL,
    LastUpdateTimestamp DATETIME2 NOT NULL,
    SourceSystemCode NVARCHAR(255) NOT NULL,
    MarketInterestRateSnapshot DECIMAL(18,4),
    HedgingInstrumentIndicator BIT NOT NULL,
    ExpectedAnnualInterestIncome DECIMAL(18,4),
    ProductProfitabilitySegment NVARCHAR(255),
    DataRecordVersion INT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCorporateDeposit PRIMARY KEY (DepositId)
);

ALTER TABLE [TransactFinance].[tblCorporateDeposit] ADD CONSTRAINT FK_tblCorporateDeposit_Corpora
    FOREIGN KEY (CorporateCustomerId) REFERENCES [TransactFinance].[tblCorporateCustomer] (CorporateCustomerId);

ALTER TABLE [TransactFinance].[tblCorporateDeposit] ADD CONSTRAINT FK_tblCorporateDeposit_Leasing
    FOREIGN KEY (LeasingProductId) REFERENCES [TransactFinance].[tblLeasingProduct] (LeasingProductId);

ALTER TABLE [TransactFinance].[tblCorporateDeposit] ADD CONSTRAINT FK_tblCorporateDeposit_Booking
    FOREIGN KEY (BookingEntityId) REFERENCES [TransactFinance].[tblBookingEntity] (BookingEntityId);

ALTER TABLE [TransactFinance].[tblCorporateDeposit] ADD CONSTRAINT FK_tblCorporateDeposit_Financi
    FOREIGN KEY (FinancialInstitutionId) REFERENCES [TransactFinance].[tblFinancialInstitution] (FinancialInstitutionId);

ALTER TABLE [TransactFinance].[tblCorporateDeposit] ADD CONSTRAINT FK_tblCorporateDeposit_Portfol
    FOREIGN KEY (PortfolioSegmentId) REFERENCES [TransactFinance].[tblPortfolioSegment] (PortfolioSegmentId);


-- Dataset: GDS54466
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Core client persona identity, cross-system keys, demographic and segment information for retail leas
CREATE TABLE [TransactFinance].[tblClientPersona] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    CoreClientId NVARCHAR(255) NOT NULL,
    CrmPartyId NVARCHAR(255),
    PrimarySegmentCode NVARCHAR(255) NOT NULL,
    PrimarySegmentDescription NVARCHAR(255) NOT NULL,
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    EuResidencyStatus BIT NOT NULL,
    ClientBirthDate DATE,
    ClientAgeYears INT,
    GenderCode NVARCHAR(255),
    MaritalStatusCode NVARCHAR(255),
    HouseholdSize INT,
    EmploymentStatusCode NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    AnnualGrossIncomeEur DECIMAL(18,4),
    NetMonthlyDisposableIncomeEur DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientPersona PRIMARY KEY (ClientPersonaId)
);

-- Risk rating and aggregated leasing exposure and performance metrics for each client persona.
CREATE TABLE [TransactFinance].[tblClientPersonaRiskExposure] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    RiskRatingBand NVARCHAR(255),
    CurrentLeasingExposureEur DECIMAL(18,4) NOT NULL,
    LifetimeLeasingRevenueEur DECIMAL(18,4) NOT NULL,
    LifetimeLeasingMarginEur DECIMAL(18,4) NOT NULL,
    LastLeasingContractStartDate DATE,
    TotalActiveLeasingContracts INT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientPersonaRisk PRIMARY KEY (ClientPersonaId)
);

-- Contact details, communication preferences, and marketing consent status for each client persona.
CREATE TABLE [TransactFinance].[tblClientPersonaContact] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    PreferredContactChannel NVARCHAR(255),
    PrimaryEmailAddress NVARCHAR(255),
    MobilePhoneNumber NVARCHAR(255),
    MarketingConsentStatus NVARCHAR(255) NOT NULL,
    MarketingConsentLastUpdated DATETIME2 NOT NULL,
    LastOutboundContactTimestamp DATETIME2,
    PreferredLanguageCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientPersonaCont PRIMARY KEY (ClientPersonaId)
);

-- Analytics-driven behavioral clustering, digital engagement, and derived persona attributes for each 
CREATE TABLE [TransactFinance].[tblClientPersonaAnalytics] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    PersonaBehavioralClusterId NVARCHAR(255),
    PersonaAttributesJson NVARCHAR(MAX),
    ProductInterestTags NVARCHAR(MAX),
    DigitalEngagementScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientPersonaAnal PRIMARY KEY (ClientPersonaId)
);

ALTER TABLE [TransactFinance].[tblClientPersonaRiskExposure] ADD CONSTRAINT FK_tblClientPersonaRiskExposur
    FOREIGN KEY (ClientPersonaId) REFERENCES [TransactFinance].[tblClientPersona] (ClientPersonaId);

ALTER TABLE [TransactFinance].[tblClientPersonaContact] ADD CONSTRAINT FK_tblClientPersonaContact_Cli
    FOREIGN KEY (ClientPersonaId) REFERENCES [TransactFinance].[tblClientPersona] (ClientPersonaId);

ALTER TABLE [TransactFinance].[tblClientPersonaAnalytics] ADD CONSTRAINT FK_tblClientPersonaAnalytics_C
    FOREIGN KEY (ClientPersonaId) REFERENCES [TransactFinance].[tblClientPersona] (ClientPersonaId);


-- Dataset: GDS55869
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Finance persona dimension capturing retail client demographic, behavioral, risk, and marketing attri
CREATE TABLE [TransactFinance].[tblFinancePersona] (
    PersonaId NVARCHAR(255) NOT NULL,
    CoreClientId NVARCHAR(255) NOT NULL,
    CrmPartyId NVARCHAR(255),
    NationalIdHash NVARCHAR(255),
    FullName NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    GenderCode NVARCHAR(255),
    DateOfBirth DATE NOT NULL,
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    PreferredLanguageCode NVARCHAR(255),
    MaritalStatusCode NVARCHAR(255),
    EmploymentStatusCode NVARCHAR(255) NOT NULL,
    EmployerIndustryCode NVARCHAR(255),
    AnnualGrossIncomeAmount DECIMAL(18,4),
    PrimaryOccupationDesc NVARCHAR(255),
    ResidentialCityName NVARCHAR(255),
    ResidentialPostalCode NVARCHAR(255),
    PrimaryContactEmail NVARCHAR(255),
    PrimaryMobileNumber NVARCHAR(255),
    PreferredContactChannelCode NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    PrivacyConsentLastUpdatedTs DATETIME2,
    RiskProfileSegmentCode NVARCHAR(255),
    CreditScoreValue INT,
    TotalActiveLeasesCount INT NOT NULL,
    LifetimeLeaseVolumeAmount DECIMAL(18,4) NOT NULL,
    AvgMonthlyLeasePaymentAmount DECIMAL(18,4),
    LeaseArrearsLast12mFlag BIT NOT NULL,
    PrimaryAssetCategoryCode NVARCHAR(255),
    RelationshipTenureMonths INT NOT NULL,
    OnboardingChannelCode NVARCHAR(255),
    LastProductInteractionTs DATETIME2,
    DigitalEngagementScore DECIMAL(18,4),
    RmAssignedFlag BIT NOT NULL,
    RmIdentifier NVARCHAR(255),
    ProfitabilitySegmentCode NVARCHAR(255),
    Rolling12mNetRevenueAmount DECIMAL(18,4),
    ChurnRiskScore DECIMAL(18,4),
    PreferredContactTimeBand NVARCHAR(255),
    LifecycleStageCode NVARCHAR(255) NOT NULL,
    SegmentMembershipTags NVARCHAR(MAX),
    LastMarketingCampaignResponseObj NVARCHAR(MAX),
    DataRecordEffectiveDate DATE NOT NULL,
    DataRecordExpiryDate DATE,
    RecordCreatedTs DATETIME2 NOT NULL,
    RecordLastUpdatedTs DATETIME2 NOT NULL,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordActiveFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblFinancePersona PRIMARY KEY (PersonaId, DataRecordEffectiveDate)
);


-- Dataset: GDS57730
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Stores core borrower entity details including legal identity, sector, size, and credit rating.
CREATE TABLE [TransactFinance].[tblBorrower] (
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    BorrowerLegalName NVARCHAR(255) NOT NULL,
    BorrowerIndustrySectorCode NVARCHAR(255),
    BorrowerCountryOfIncorporation NVARCHAR(255) NOT NULL,
    BorrowerAnnualTurnoverAmount DECIMAL(18,4),
    BorrowerEmployeeCount INT,
    BorrowerCreditRating NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerCustomerId)
);

-- Represents credit facilities secured (wholly or partly) by collateral, including loan terms and bala
CREATE TABLE [TransactFinance].[tblFacility] (
    FacilityReferenceNumber NVARCHAR(255) NOT NULL,
    LoanAccountId NVARCHAR(255) NOT NULL,
    BorrowerCustomerId NVARCHAR(255) NOT NULL,
    FacilityTypeCode NVARCHAR(255) NOT NULL,
    FacilityCommitmentAmount DECIMAL(18,4) NOT NULL,
    DrawnLoanBalanceAmount DECIMAL(18,4) NOT NULL,
    InterestRateTypeCode NVARCHAR(255) NOT NULL,
    InterestRateMarginPercent DECIMAL(18,4) NOT NULL,
    BaseRateIndexName NVARCHAR(255),
    BaseRateValuePercent DECIMAL(18,4),
    OriginationDate DATE NOT NULL,
    MaturityDate DATE,
    NextPaymentDueDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFacility PRIMARY KEY (FacilityReferenceNumber)
);

-- Captures physical collateral property details including location, type, size, and environmental char
CREATE TABLE [TransactFinance].[tblCollateralProperty] (
    CollateralId NVARCHAR(255) NOT NULL,
    PropertyAddressLine1 NVARCHAR(255) NOT NULL,
    PropertyAddressPostcode NVARCHAR(255) NOT NULL,
    PropertyCountryCode NVARCHAR(255) NOT NULL,
    PropertyTypeCode NVARCHAR(255) NOT NULL,
    PropertyOccupancyStatusCode NVARCHAR(255),
    PropertyFloorAreaSqm DECIMAL(18,4),
    PropertyConstructionYear INT,
    EnvironmentalRiskScore DECIMAL(18,4),
    FloodRiskZoneCode NVARCHAR(255),
    EnergyPerformanceCertificateRating NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCollateralPropert PRIMARY KEY (CollateralId)
);

-- Stores the latest valuation details for each collateral property.
CREATE TABLE [TransactFinance].[tblPropertyValuation] (
    CollateralId NVARCHAR(255) NOT NULL,
    LatestValuationAmount DECIMAL(18,4) NOT NULL,
    LatestValuationCurrencyCode NVARCHAR(255) NOT NULL,
    LatestValuationDate DATE NOT NULL,
    ValuationMethodCode NVARCHAR(255),
    ValuationFirmName NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPropertyValuation PRIMARY KEY (CollateralId)
);

-- Core fact table linking facilities to collateral properties, with collateral coverage, legal enforce
CREATE TABLE [TransactFinance].[tblPropertyFinanceRecord] (
    PropertyFinanceRecordId NVARCHAR(255) NOT NULL,
    FacilityReferenceNumber NVARCHAR(255) NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    LoanToValuePercent DECIMAL(18,4) NOT NULL,
    HaircutAppliedPercent DECIMAL(18,4),
    CollateralEligibilityStatusCode NVARCHAR(255) NOT NULL,
    CollateralEnforceabilityFlag BIT NOT NULL,
    ChargeRegistrationDate DATE,
    ChargePriorityRank INT,
    RecoveryValueEstimateAmount DECIMAL(18,4),
    RecoveryScenarioCode NVARCHAR(255),
    RecordEffectiveTimestamp DATETIME2 NOT NULL,
    SourceSystemCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblPropertyFinanceRe PRIMARY KEY (PropertyFinanceRecordId)
);

ALTER TABLE [TransactFinance].[tblFacility] ADD CONSTRAINT FK_tblFacility_BorrowerCustome
    FOREIGN KEY (BorrowerCustomerId) REFERENCES [TransactFinance].[tblBorrower] (BorrowerCustomerId);

ALTER TABLE [TransactFinance].[tblPropertyValuation] ADD CONSTRAINT FK_tblPropertyValuation_Collat
    FOREIGN KEY (CollateralId) REFERENCES [TransactFinance].[tblCollateralProperty] (CollateralId);

ALTER TABLE [TransactFinance].[tblPropertyFinanceRecord] ADD CONSTRAINT FK_tblPropertyFinanceRecord_Fa
    FOREIGN KEY (FacilityReferenceNumber) REFERENCES [TransactFinance].[tblFacility] (FacilityReferenceNumber);

ALTER TABLE [TransactFinance].[tblPropertyFinanceRecord] ADD CONSTRAINT FK_tblPropertyFinanceRecord_Co
    FOREIGN KEY (CollateralId) REFERENCES [TransactFinance].[tblCollateralProperty] (CollateralId);


-- Dataset: GDS61281
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Finance account master records for leasing products sourced from TransactFinance, including balances
CREATE TABLE [TransactFinance].[tblFinanceAccount] (
    AccountId NVARCHAR(255) NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    AccountIban NVARCHAR(255),
    AccountCurrency NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE NOT NULL,
    AccountCloseDate DATE,
    AccountStatus NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    LeaseTermMonths INT NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    AccruedInterestAmount DECIMAL(18,4) NOT NULL,
    NextPaymentDueDate DATE,
    NextPaymentAmount DECIMAL(18,4),
    DaysPastDue INT NOT NULL,
    WriteOffFlag BIT NOT NULL,
    PortfolioSegment NVARCHAR(255) NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    BookingBranchCode NVARCHAR(255),
    EffectiveInterestRate DECIMAL(18,4) NOT NULL,
    LastTransactionTimestamp DATETIME2,
    MonthlyPaymentAmount DECIMAL(18,4) NOT NULL,
    CollateralType NVARCHAR(255),
    CrossSellEligibilityScore DECIMAL(18,4),
    RiskRating INT NOT NULL,
    ProductPerformanceClassification NVARCHAR(255),
    RevenueRecognitionMethod NVARCHAR(255),
    ProductFeatureCodes NVARCHAR(MAX),
    MarketingConsentFlags NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceAccount PRIMARY KEY (AccountId)
);


-- Dataset: GDS66158
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Core finance persona record for an individual client in commercial finance, including identifiers, c
CREATE TABLE [TransactFinance].[tblFinancePersona] (
    FinancePersonaId NVARCHAR(255) NOT NULL,
    CrmPartyId NVARCHAR(255) NOT NULL,
    ClientLegacyId NVARCHAR(255),
    ClientSegmentCode NVARCHAR(255) NOT NULL,
    RiskAppetiteCode NVARCHAR(255),
    BehavioralSegmentCode NVARCHAR(255),
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    PrimaryRelationshipManagerId NVARCHAR(255),
    PrimaryRelationshipManagerName NVARCHAR(255),
    PreferredContactChannel NVARCHAR(255),
    EmailAddress NVARCHAR(255),
    MobilePhoneNumber NVARCHAR(255),
    IndustrySpecialism NVARCHAR(255),
    EmploymentRoleTitle NVARCHAR(255),
    AnnualPersonalIncomeAmount DECIMAL(18,4),
    NetInvestableAssetsAmount DECIMAL(18,4),
    OnboardingDate DATE NOT NULL,
    FirstCommercialProductOpenDate DATE,
    LastInteractionTimestamp DATETIME2,
    InteractionPreferenceJson NVARCHAR(MAX),
    MarketingConsentFlag BIT NOT NULL,
    ProfilingConsentFlag BIT NOT NULL,
    GdprConsentLastUpdatedDate DATE,
    ChurnRiskScore DECIMAL(18,4),
    ProfitabilityScore12m DECIMAL(18,4),
    RevenueContribution12mAmount DECIMAL(18,4),
    CostToServe12mAmount DECIMAL(18,4),
    RelationshipTenureMonths INT NOT NULL,
    DigitalEngagementScore DECIMAL(18,4),
    PreferredMeetingLocation NVARCHAR(255),
    LanguagesSpoken NVARCHAR(MAX),
    ProfessionalNetworkInfluenceScore DECIMAL(18,4),
    CrossSellPropensityScore DECIMAL(18,4),
    LastCampaignRespondedCode NVARCHAR(255),
    LastCampaignResponseDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblFinancePersona PRIMARY KEY (FinancePersonaId)
);

-- Reference data for strategic client segments used to classify finance personas.
CREATE TABLE [TransactFinance].[tblClientSegment] (
    ClientSegmentCode NVARCHAR(255) NOT NULL,
    ClientSegmentDescription NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientSegment PRIMARY KEY (ClientSegmentCode)
);

-- Reference data for client risk appetite classifications and their descriptions.
CREATE TABLE [TransactFinance].[tblRiskAppetite] (
    RiskAppetiteCode NVARCHAR(255) NOT NULL,
    RiskAppetiteDescription NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblRiskAppetite PRIMARY KEY (RiskAppetiteCode)
);

-- Reference data for behavioral segments derived from client interaction and product usage patterns.
CREATE TABLE [TransactFinance].[tblBehavioralSegment] (
    BehavioralSegmentCode NVARCHAR(255) NOT NULL,
    BehavioralSegmentDescription NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBehavioralSegment PRIMARY KEY (BehavioralSegmentCode)
);

-- Reference data for countries of residence associated with finance personas.
CREATE TABLE [TransactFinance].[tblCountryOfResidence] (
    CountryOfResidenceCode NVARCHAR(255) NOT NULL,
    CountryOfResidenceName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCountryOfResidenc PRIMARY KEY (CountryOfResidenceCode)
);

-- Reference data for source systems and channels from which finance persona records are ingested.
CREATE TABLE [TransactFinance].[tblDataSourceSystem] (
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    DataSourceSystemDescription NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblDataSourceSystem PRIMARY KEY (DataSourceSystemCode)
);

ALTER TABLE [TransactFinance].[tblFinancePersona] ADD CONSTRAINT FK_tblFinancePersona_ClientSeg
    FOREIGN KEY (ClientSegmentCode) REFERENCES [TransactFinance].[tblClientSegment] (ClientSegmentCode);

ALTER TABLE [TransactFinance].[tblFinancePersona] ADD CONSTRAINT FK_tblFinancePersona_RiskAppet
    FOREIGN KEY (RiskAppetiteCode) REFERENCES [TransactFinance].[tblRiskAppetite] (RiskAppetiteCode);

ALTER TABLE [TransactFinance].[tblFinancePersona] ADD CONSTRAINT FK_tblFinancePersona_Behaviora
    FOREIGN KEY (BehavioralSegmentCode) REFERENCES [TransactFinance].[tblBehavioralSegment] (BehavioralSegmentCode);

ALTER TABLE [TransactFinance].[tblFinancePersona] ADD CONSTRAINT FK_tblFinancePersona_CountryOf
    FOREIGN KEY (CountryOfResidenceCode) REFERENCES [TransactFinance].[tblCountryOfResidence] (CountryOfResidenceCode);

ALTER TABLE [TransactFinance].[tblFinancePersona] ADD CONSTRAINT FK_tblFinancePersona_DataSourc
    FOREIGN KEY (DataSourceSystemCode) REFERENCES [TransactFinance].[tblDataSourceSystem] (DataSourceSystemCode);


-- Dataset: GDS75398
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Core client master data for retail leasing clients, including identity, demographics, residency, inc
CREATE TABLE [TransactFinance].[TblClientCore] (
    ClientId INT NOT NULL,
    CoreClientId NVARCHAR(255) NOT NULL,
    LocalResidentIdHash NVARCHAR(255),
    FullNameNormalized NVARCHAR(255) NOT NULL,
    PreferredName NVARCHAR(255),
    DateOfBirth DATE,
    GenderCode NVARCHAR(255),
    MaritalStatusCode NVARCHAR(255),
    OccupationCategory NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    AnnualDeclaredIncomeAmount DECIMAL(18,4),
    CountryOfResidence NVARCHAR(255) NOT NULL,
    CityOfResidence NVARCHAR(255),
    PostalCode NVARCHAR(255),
    PrimaryCurrencyCode NVARCHAR(255) NOT NULL,
    PreferredLanguageCode NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    RelationshipSegmentCode NVARCHAR(255),
    DataProtectionRestrictionFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblClientCore PRIMARY KEY (ClientId)
);

-- Versioned client persona snapshots for leasing operations, capturing contact preferences, risk profi
CREATE TABLE [TransactFinance].[TblClientPersonaSnapshot] (
    ClientPersonaId NVARCHAR(255) NOT NULL,
    ClientId INT NOT NULL,
    PrimaryContactEmail NVARCHAR(255),
    PrimaryContactMobile NVARCHAR(255),
    RiskProfileSegment NVARCHAR(255),
    LeasingClientTenureMonths INT,
    FirstLeasingContractStartDate DATE,
    LatestInteractionTimestamp DATETIME2,
    PreferredContactChannel NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    MarketingConsentLastUpdated DATE,
    DigitalEngagementScore DECIMAL(18,4),
    AvgMonthlyLeasePaymentAmount DECIMAL(18,4),
    LifetimeLeasingRevenueAmount DECIMAL(18,4),
    LifetimeLeasingMarginAmount DECIMAL(18,4),
    CurrentActiveLeaseCount INT,
    DelinquencyFlag BIT NOT NULL,
    MaxHistoricalDpd INT,
    BehavioralSegmentCode NVARCHAR(255),
    ChannelAffinityRankings NVARCHAR(MAX),
    LastMarketingCampaignResponse NVARCHAR(255),
    LastMarketingResponseTimestamp DATETIME2,
    PersonaRecordEffectiveDate DATE NOT NULL,
    PersonaRecordExpiryDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblClientPersonaSnap PRIMARY KEY (ClientPersonaId)
);

ALTER TABLE [TransactFinance].[TblClientPersonaSnapshot] ADD CONSTRAINT FK_TblClientPersonaSnapshot_Cl
    FOREIGN KEY (ClientId) REFERENCES [TransactFinance].[TblClientCore] (ClientId);


-- Dataset: GDS79434
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Client legal entities participating in leasing or financing arrangements.
CREATE TABLE [TransactFinance].[tblClientLegalEntity] (
    ClientLegalEntityId NVARCHAR(20) NOT NULL,
    ClientLegalEntityName NVARCHAR(255) NOT NULL,
    DomicileCountryCode NVARCHAR(2) NOT NULL,
    IndustrySectorCode NVARCHAR(10) NOT NULL,
    IndustrySectorDescription NVARCHAR(255) NOT NULL,
    AnnualClientRevenueEur DECIMAL(18,4),
    KycRiskRating NVARCHAR(50),
    KycLastReviewDate DATE,
    SanctionsScreeningStatus NVARCHAR(50),
    DataPrivacyConsentFlag BIT NOT NULL,
    GdprConsentEffectiveDate DATE,
    ContactPreferenceChannel NVARCHAR(50),
    PrimaryContactEmail NVARCHAR(255),
    PrimaryContactPhone NVARCHAR(50),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientLegalEntity PRIMARY KEY (ClientLegalEntityId)
);

-- Financial counterparties such as lenders, investors, advisors, or leasing partners.
CREATE TABLE [TransactFinance].[tblCounterparty] (
    CounterpartyLegalEntityId NVARCHAR(20) NOT NULL,
    CounterpartyName NVARCHAR(255) NOT NULL,
    CounterpartyType NVARCHAR(50) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCounterparty PRIMARY KEY (CounterpartyLegalEntityId)
);

-- Primary relationship managers responsible for client coverage.
CREATE TABLE [TransactFinance].[tblRelationshipManager] (
    RelationshipManagerId NVARCHAR(12) NOT NULL,
    RelationshipManagerName NVARCHAR(120) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblRelationshipManag PRIMARY KEY (RelationshipManagerId)
);

-- Corporate finance relationships between client legal entities and financial counterparties, includin
CREATE TABLE [TransactFinance].[tblCorporateFinanceRelationship] (
    RelationshipId NVARCHAR(36) NOT NULL,
    ParentRelationshipId NVARCHAR(36),
    ClientLegalEntityId NVARCHAR(20) NOT NULL,
    CounterpartyLegalEntityId NVARCHAR(20) NOT NULL,
    RelationshipManagerId NVARCHAR(12) NOT NULL,
    RelationshipRole NVARCHAR(50) NOT NULL,
    RelationshipHierarchyLevel NVARCHAR(50) NOT NULL,
    RelationshipStatus NVARCHAR(50) NOT NULL,
    RelationshipStartDate DATE NOT NULL,
    RelationshipEndDate DATE,
    BookingCenterCountryCode NVARCHAR(2) NOT NULL,
    AnnualLeasingVolumeEur DECIMAL(18,4),
    TotalOutstandingLeaseBalanceEur DECIMAL(18,4) NOT NULL,
    AverageLeaseMarginBps DECIMAL(18,4),
    RelationshipProfitabilityScore INT,
    LastProfitabilityReviewDate DATE,
    NextReviewDueDate DATE,
    OnboardingChannel NVARCHAR(50),
    DealPipelineStage NVARCHAR(50),
    ActiveDealCount INT NOT NULL,
    LastInteractionTimestamp DATETIME2,
    LastInteractionType NVARCHAR(50),
    RelationshipRegion NVARCHAR(50) NOT NULL,
    CrossSellPotentialScore INT,
    CovenantBreachFlag BIT NOT NULL,
    CovenantBreachLastDate DATE,
    AdvisoryMandateCount INT NOT NULL,
    KeyProducts NVARCHAR(MAX),
    AdditionalRelationshipAttributes NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCorporateFinanceR PRIMARY KEY (RelationshipId)
);


-- Dataset: GDS92046
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'TransactFinance')
    EXEC('CREATE SCHEMA [TransactFinance]');

-- Core client entity for leasing and retail banking; stores stable identifiers and core attributes.
CREATE TABLE [TransactFinance].[tblClient] (
    ClientId NVARCHAR(255) NOT NULL,
    FirstOnboardDate DATE NOT NULL,
    CountryOfResidence NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientId)
);

-- Time-variant snapshot of client leasing persona, relationship, risk, marketing, engagement, and prof
CREATE TABLE [TransactFinance].[tblClientFinancePersonaSnapshot] (
    ClientFinancePersonaSnapshotId INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    DataRecordEffectiveDate DATE NOT NULL,
    PersonaId NVARCHAR(255),
    LeasingCustomerSegment NVARCHAR(255),
    RelationshipManagerId NVARCHAR(255),
    LatestInteractionTimestamp DATETIME2,
    PreferredContactChannel NVARCHAR(255),
    EmailOptInFlag BIT NOT NULL,
    GdprConsentStatus NVARCHAR(255) NOT NULL,
    KycCompletionStatus NVARCHAR(255) NOT NULL,
    LeasingProductHoldingCount INT NOT NULL,
    ActiveLeasingContractCount INT NOT NULL,
    TotalOutstandingLeasingBalance DECIMAL(18,4) NOT NULL,
    AvgMonthlyLeasingPaymentAmount DECIMAL(18,4),
    LastPaymentDate DATE,
    DelinquencyStatus NVARCHAR(255) NOT NULL,
    RiskScore DECIMAL(18,4),
    ChurnPropensityScore DECIMAL(18,4),
    ClientProfitabilityLtmAmount DECIMAL(18,4),
    ProfitabilityScore INT,
    MarketingCampaignSource NVARCHAR(255),
    OccupationGroup NVARCHAR(255),
    IndustrySectorCode NVARCHAR(255),
    AnnualIncomeBand NVARCHAR(255),
    ResidentialPostcodeSector NVARCHAR(255),
    AgeBand NVARCHAR(255),
    DigitalEngagementScore INT,
    MobileAppLoginFrequency30d INT,
    BranchVisitFrequency90d INT,
    PreferredContactTimeBand NVARCHAR(255),
    LifecycleStage NVARCHAR(255) NOT NULL,
    NextBestProductOfferCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClientFinancePers PRIMARY KEY (ClientFinancePersonaSnapshotId)
);


