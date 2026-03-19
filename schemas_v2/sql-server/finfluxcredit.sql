-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinfluxCredit
-- Generated: 2026-03-18T12:08:48.587549
-- Datasets: 7
-- ============================================

-- Dataset: GDS16599
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Core collateral record for consumer finance exposures, including valuation, risk, pledge, insurance 
CREATE TABLE [FinfluxCredit].[tblCollateral] (
    CollateralId UNIQUEIDENTIFIER NOT NULL,
    MasrephCustomerId NVARCHAR(12) NOT NULL,
    LoanContractId NVARCHAR(18) NOT NULL,
    CollateralType NVARCHAR(50) NOT NULL,
    AssetDescription NVARCHAR(512),
    CollateralCountryCode NVARCHAR(2) NOT NULL,
    CollateralCurrency NVARCHAR(3) NOT NULL,
    InitialValuationAmount DECIMAL(18,4) NOT NULL,
    CurrentValuationAmount DECIMAL(18,4),
    ValuationDate DATE,
    ValuationMethod NVARCHAR(50),
    ValuationProviderName NVARCHAR(128),
    OriginalLoanAmount DECIMAL(18,4) NOT NULL,
    OutstandingLoanBalance DECIMAL(18,4) NOT NULL,
    CurrentLtvRatio DECIMAL(18,4),
    LtvAtOriginationRatio DECIMAL(18,4),
    RegulatoryHaircutPercentage DECIMAL(18,4),
    EligibleCollateralFlag BIT NOT NULL,
    CollateralStatus NVARCHAR(50) NOT NULL,
    PledgeStartDate DATE NOT NULL,
    PledgeReleaseDate DATE,
    CollateralOwnerName NVARCHAR(128),
    OwnerRelationshipToBorrower NVARCHAR(50),
    CollateralAddressLine1 NVARCHAR(128),
    CollateralPostalCode NVARCHAR(16),
    RecoveryScenarioValue DECIMAL(18,4),
    ForcedSaleDiscountPercentage DECIMAL(18,4),
    InsuranceCoverageAmount DECIMAL(18,4),
    InsurancePolicyExpiryDate DATE,
    CreditRiskSegment NVARCHAR(50),
    LastStatusUpdateTimestamp DATETIME2 NOT NULL,
    DataSourceSystem NVARCHAR(50) NOT NULL,
    GdprPersonalDataFlag BIT NOT NULL,
    CollateralRiskScore INT,
    CollateralAttributeDetails NVARCHAR(MAX),
    SecuredExposureLimitAmount DECIMAL(18,4),
    CrossCollateralizationFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateral PRIMARY KEY (CollateralId)
);

-- Link table associating collateral records with their referenced digital document identifiers.
CREATE TABLE [FinfluxCredit].[tblCollateralDocument] (
    DocumentId UNIQUEIDENTIFIER NOT NULL,
    CollateralId UNIQUEIDENTIFIER NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralDocumen PRIMARY KEY (DocumentId)
);

ALTER TABLE [FinfluxCredit].[tblCollateralDocument] ADD CONSTRAINT FK_tblCollateralDocument_Colla
    FOREIGN KEY (CollateralId) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralId);


-- Dataset: GDS31916
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Customer master data as used within Masreph for leasing products.
CREATE TABLE [FinfluxCredit].[tblCustomer] (
    CustomerId INT NOT NULL,
    CustomerMasrephId NVARCHAR(255) NOT NULL,
    CustomerResidencyCountryCode NVARCHAR(255),
    MasrephRelationshipId NVARCHAR(255),
    GdprConsentMarketingFlag BIT NOT NULL,
    InternalCustomerProfitabilityScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Core lease contract entity capturing contractual terms and static attributes.
CREATE TABLE [FinfluxCredit].[tblLeaseContract] (
    LeaseContractId INT NOT NULL,
    LeaseContractNumber NVARCHAR(255) NOT NULL,
    CustomerId INT NOT NULL,
    LesseeSegmentCode NVARCHAR(255) NOT NULL,
    ProductFamily NVARCHAR(255) NOT NULL,
    ProductSubType NVARCHAR(255) NOT NULL,
    AssetCategoryCode NVARCHAR(255) NOT NULL,
    OriginationChannel NVARCHAR(255),
    ApplicationId NVARCHAR(255),
    ApprovedLeaseAmount DECIMAL(18,4) NOT NULL,
    OutstandingPrincipalBalance DECIMAL(18,4) NOT NULL,
    ContractCurrencyCode NVARCHAR(255) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4) NOT NULL,
    EffectiveAnnualPercentageRate DECIMAL(18,4),
    LeaseTermMonths INT NOT NULL,
    PaymentFrequencyCode NVARCHAR(255) NOT NULL,
    ScheduledInstalmentAmount DECIMAL(18,4) NOT NULL,
    OriginationDate DATE NOT NULL,
    FirstPaymentDate DATE,
    ContractMaturityDate DATE NOT NULL,
    ContractStatusCode NVARCHAR(255) NOT NULL,
    CountryOfRiskCode NVARCHAR(255) NOT NULL,
    MasrephPortfolioCode NVARCHAR(255) NOT NULL,
    CrossSellEligibilityFlag BIT NOT NULL,
    WriteOffAmount DECIMAL(18,4) NOT NULL,
    PrepaymentIndicator BIT NOT NULL,
    PrepaymentDate DATE,
    DataRecordTimestamp DATETIME2 NOT NULL,
    PaymentMethodCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

-- Current payment and delinquency status for each lease contract.
CREATE TABLE [FinfluxCredit].[tblLeasePaymentStatus] (
    LeasePaymentStatusId INT NOT NULL,
    LeaseContractId INT NOT NULL,
    DaysPastDue INT NOT NULL,
    CurrentDelinquencyBucket NVARCHAR(255) NOT NULL,
    TotalAmountPastDue DECIMAL(18,4) NOT NULL,
    LastPaymentDate DATE,
    LastPaymentAmount DECIMAL(18,4),
    NonAccrualStatusFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeasePaymentStatu PRIMARY KEY (LeasePaymentStatusId)
);

-- Credit risk, expected loss, and restructuring information for each lease contract.
CREATE TABLE [FinfluxCredit].[tblLeaseRiskProfile] (
    LeaseRiskProfileId INT NOT NULL,
    LeaseContractId INT NOT NULL,
    CreditScoreValue INT,
    CreditScoreProvider NVARCHAR(255),
    InternalRiskGrade NVARCHAR(255),
    LoanToValueRatio DECIMAL(18,4),
    ExpectedLossRate DECIMAL(18,4),
    LifetimeExpectedLossAmount DECIMAL(18,4),
    RestructuredIndicator BIT NOT NULL,
    RestructureEffectiveDate DATE,
    RiskFlagCodes NVARCHAR(MAX),
    CounterpartyRiskProfile NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseRiskProfile PRIMARY KEY (LeaseRiskProfileId)
);

-- Most recent collateral valuation details for assets underlying lease contracts.
CREATE TABLE [FinfluxCredit].[tblCollateralValuation] (
    CollateralValuationId INT NOT NULL,
    LeaseContractId INT NOT NULL,
    CollateralValuationAmount DECIMAL(18,4),
    CollateralValuationDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralValuati PRIMARY KEY (CollateralValuationId)
);

ALTER TABLE [FinfluxCredit].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_CustomerId
    FOREIGN KEY (CustomerId) REFERENCES [FinfluxCredit].[tblCustomer] (CustomerId);

ALTER TABLE [FinfluxCredit].[tblLeasePaymentStatus] ADD CONSTRAINT FK_tblLeasePaymentStatus_Lease
    FOREIGN KEY (LeaseContractId) REFERENCES [FinfluxCredit].[tblLeaseContract] (LeaseContractId);

ALTER TABLE [FinfluxCredit].[tblLeaseRiskProfile] ADD CONSTRAINT FK_tblLeaseRiskProfile_LeaseCo
    FOREIGN KEY (LeaseContractId) REFERENCES [FinfluxCredit].[tblLeaseContract] (LeaseContractId);

ALTER TABLE [FinfluxCredit].[tblCollateralValuation] ADD CONSTRAINT FK_tblCollateralValuation_Leas
    FOREIGN KEY (LeaseContractId) REFERENCES [FinfluxCredit].[tblLeaseContract] (LeaseContractId);


-- Dataset: GDS50145
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Borrower master data for Masreph customers linked to lease contracts, including identity, demographi
CREATE TABLE [FinfluxCredit].[tblBorrower] (
    BorrowerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    ExternalBorrowerReference NVARCHAR(255),
    BorrowerFullName NVARCHAR(255) NOT NULL,
    BorrowerDateOfBirth DATE,
    BorrowerCountryOfResidence NVARCHAR(255) NOT NULL,
    BorrowerSegment NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    GdprProcessingBasis NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerId)
);

-- Leasing product master data defining product configuration and associated asset classification.
CREATE TABLE [FinfluxCredit].[tblProduct] (
    ProductId INT NOT NULL,
    ProductCode NVARCHAR(255) NOT NULL,
    ProductName NVARCHAR(255) NOT NULL,
    AssetType NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProduct PRIMARY KEY (ProductId)
);

-- Credit finance details and risk metrics at the individual lease contract level, including exposure, 
CREATE TABLE [FinfluxCredit].[tblLeaseContract] (
    LeaseContractId NVARCHAR(255) NOT NULL,
    BorrowerId INT NOT NULL,
    ProductId INT NOT NULL,
    AssetDescription NVARCHAR(255),
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE,
    OriginalLeaseTermMonths INT NOT NULL,
    RemainingLeaseTermMonths INT,
    CurrencyCode NVARCHAR(255) NOT NULL,
    OriginalPrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentOutstandingPrincipal DECIMAL(18,4) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4) NOT NULL,
    EffectiveAnnualPercentageRate DECIMAL(18,4),
    InstallmentFrequency NVARCHAR(255) NOT NULL,
    ScheduledInstallmentAmount DECIMAL(18,4) NOT NULL,
    NextDueDate DATE,
    DaysPastDue INT NOT NULL,
    TotalPastDueAmount DECIMAL(18,4) NOT NULL,
    ContractStatus NVARCHAR(255) NOT NULL,
    NonAccrualFlag BIT NOT NULL,
    WriteOffAmount DECIMAL(18,4),
    CollateralValuationAmount DECIMAL(18,4),
    CollateralValuationDate DATE,
    InternalCreditRating NVARCHAR(255),
    ProbabilityOfDefault12m DECIMAL(18,4),
    PrimaryDealerId NVARCHAR(255),
    OriginationChannel NVARCHAR(255) NOT NULL,
    OriginationTimestamp DATETIME2 NOT NULL,
    LastPaymentDate DATE,
    LastPaymentAmount DECIMAL(18,4),
    PrepaymentFlag BIT NOT NULL,
    PrepaymentPenaltyAmount DECIMAL(18,4),
    LeaseMarginBps INT,
    ExpectedLossLifetime DECIMAL(18,4),
    ReportingSnapshotTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractId)
);

ALTER TABLE [FinfluxCredit].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_BorrowerId
    FOREIGN KEY (BorrowerId) REFERENCES [FinfluxCredit].[tblBorrower] (BorrowerId);

ALTER TABLE [FinfluxCredit].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_ProductId
    FOREIGN KEY (ProductId) REFERENCES [FinfluxCredit].[tblProduct] (ProductId);


-- Dataset: GDS75841
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Core collateral asset record including identification, asset characteristics, status, and system met
CREATE TABLE [FinfluxCredit].[tblCollateral] (
    CollateralKey INT NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    AssetType NVARCHAR(255) NOT NULL,
    AssetSubtype NVARCHAR(255),
    AssetDescription NVARCHAR(255),
    AssetManufacturerName NVARCHAR(255),
    AssetModel NVARCHAR(255),
    AssetSerialNumber NVARCHAR(255),
    AssetPurchasePrice DECIMAL(18,4) NOT NULL,
    AssetCurrencyCode NVARCHAR(255) NOT NULL,
    CollateralStatusCode NVARCHAR(255) NOT NULL,
    CollateralRiskGrade NVARCHAR(255),
    CollateralLastReviewTimestamp DATETIME2 NOT NULL,
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdateTimestamp DATETIME2 NOT NULL,
    PiiDataPresentFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateral PRIMARY KEY (CollateralKey)
);

-- Exposure and leasing contract-related attributes associated with a collateral asset, including custo
CREATE TABLE [FinfluxCredit].[tblCollateralExposure] (
    CollateralExposureKey INT NOT NULL,
    CollateralKey INT NOT NULL,
    LeasingContractId NVARCHAR(255) NOT NULL,
    CustomerInternalId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255) NOT NULL,
    CustomerCountryCode NVARCHAR(255) NOT NULL,
    CustomerMarketingConsentFlag BIT NOT NULL,
    OutstandingExposureAmount DECIMAL(18,4) NOT NULL,
    ContractStartDate DATE NOT NULL,
    ContractMaturityDate DATE NOT NULL,
    DaysPastDue INT NOT NULL,
    DefaultStatusFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralExposur PRIMARY KEY (CollateralExposureKey)
);

-- Valuation metrics for a collateral asset, including current and initial valuations, haircuts, eligib
CREATE TABLE [FinfluxCredit].[tblCollateralValuation] (
    CollateralValuationKey INT NOT NULL,
    CollateralKey INT NOT NULL,
    AssetInitialValuationAmount DECIMAL(18,4),
    AssetCurrentValuationAmount DECIMAL(18,4),
    ValuationEffectiveDate DATE,
    ValuationMethodCode NVARCHAR(255),
    ValuationSourceType NVARCHAR(255),
    MarketValueHaircutPercentage DECIMAL(18,4),
    EligibleCollateralValue DECIMAL(18,4),
    LoanToValuePercentage DECIMAL(18,4),
    LoanToEligibleCollateralPercentage DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralValuati PRIMARY KEY (CollateralValuationKey)
);

-- Legal registration details for the collateral, including registry references, dates, and legal owner
CREATE TABLE [FinfluxCredit].[tblCollateralRegistration] (
    CollateralRegistrationKey INT NOT NULL,
    CollateralKey INT NOT NULL,
    CollateralRegistrationFlag BIT NOT NULL,
    CollateralRegistrationReference NVARCHAR(255),
    CollateralRegistrationDate DATE,
    LegalOwnerName NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralRegistr PRIMARY KEY (CollateralRegistrationKey)
);

-- Credit protection and insurance information related to the collateral, including guarantees, pledger
CREATE TABLE [FinfluxCredit].[tblCollateralProtection] (
    CollateralProtectionKey INT NOT NULL,
    CollateralKey INT NOT NULL,
    PledgerCustomerId NVARCHAR(255),
    GuaranteeTypeCode NVARCHAR(255),
    InsurancePolicyNumber NVARCHAR(255),
    InsuranceCoverageAmount DECIMAL(18,4),
    InsuranceExpiryDate DATE,
    ResidualValueGuaranteedAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralProtect PRIMARY KEY (CollateralProtectionKey)
);

-- Recovery and repossession details for collateral assets, including recovery strategy and estimated p
CREATE TABLE [FinfluxCredit].[tblCollateralRecovery] (
    CollateralRecoveryKey INT NOT NULL,
    CollateralKey INT NOT NULL,
    RepossessionDate DATE,
    RecoveryStrategyCode NVARCHAR(255),
    EstimatedRecoveryAmount DECIMAL(18,4),
    RecoveryCostsEstimateAmount DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralRecover PRIMARY KEY (CollateralRecoveryKey)
);

ALTER TABLE [FinfluxCredit].[tblCollateralExposure] ADD CONSTRAINT FK_tblCollateralExposure_Colla
    FOREIGN KEY (CollateralKey) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralKey);

ALTER TABLE [FinfluxCredit].[tblCollateralValuation] ADD CONSTRAINT FK_tblCollateralValuation_Coll
    FOREIGN KEY (CollateralKey) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralKey);

ALTER TABLE [FinfluxCredit].[tblCollateralRegistration] ADD CONSTRAINT FK_tblCollateralRegistration_C
    FOREIGN KEY (CollateralKey) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralKey);

ALTER TABLE [FinfluxCredit].[tblCollateralProtection] ADD CONSTRAINT FK_tblCollateralProtection_Col
    FOREIGN KEY (CollateralKey) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralKey);

ALTER TABLE [FinfluxCredit].[tblCollateralRecovery] ADD CONSTRAINT FK_tblCollateralRecovery_Colla
    FOREIGN KEY (CollateralKey) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralKey);


-- Dataset: GDS76808
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Core collateral master record for assets pledged against commercial finance facilities.
CREATE TABLE [FinfluxCredit].[tblCollateral] (
    CollateralId NVARCHAR(255) NOT NULL,
    CollateralExternalRef NVARCHAR(255),
    FacilityId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    CustomerSegmentCode NVARCHAR(255),
    CollateralTypeCode NVARCHAR(255) NOT NULL,
    CollateralSubtypeDesc NVARCHAR(255),
    JurisdictionCountryCode NVARCHAR(255) NOT NULL,
    CollateralCurrencyCode NVARCHAR(255) NOT NULL,
    CollateralStatusCode NVARCHAR(255) NOT NULL,
    CollateralStatusEffectiveDate DATE NOT NULL,
    LegalOwnerName NVARCHAR(255),
    PledgedOwnerName NVARCHAR(255),
    FirstLienFlag BIT NOT NULL,
    PerfectionDate DATE,
    RegistrationAuthorityName NVARCHAR(255),
    RegistrationReferenceNumber NVARCHAR(255),
    EnforcementRestrictionFlag BIT NOT NULL,
    EnforcementRestrictionReason NVARCHAR(255),
    CollateralLocationAddress NVARCHAR(255),
    GeoCoordinates NVARCHAR(MAX),
    CollateralDocumentIds NVARCHAR(MAX),
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateral PRIMARY KEY (CollateralId)
);

-- Current valuation and secured exposure metrics associated with each collateral asset.
CREATE TABLE [FinfluxCredit].[tblCollateralValuation] (
    CollateralValuationId INT NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    CollateralValuationAmount DECIMAL(18,4) NOT NULL,
    CollateralValuationDate DATE NOT NULL,
    ValuationMethodCode NVARCHAR(255),
    ValuationFirmName NVARCHAR(255),
    LoanOutstandingAmount DECIMAL(18,4) NOT NULL,
    LoanToValueRatio DECIMAL(18,4) NOT NULL,
    HaircutPercentage DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralValuati PRIMARY KEY (CollateralValuationId)
);

-- Risk grading and environmental risk characteristics of collateral assets.
CREATE TABLE [FinfluxCredit].[tblCollateralRisk] (
    CollateralRiskId INT NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    CollateralRiskGrade NVARCHAR(255),
    RiskGradeEffectiveDate DATE,
    EnvironmentalRiskScore INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralRisk PRIMARY KEY (CollateralRiskId)
);

-- Inspection schedule and tracking information for collateral assets.
CREATE TABLE [FinfluxCredit].[tblCollateralInspection] (
    CollateralInspectionId INT NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    LastInspectionDate DATE,
    NextInspectionDueDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralInspect PRIMARY KEY (CollateralInspectionId)
);

-- Marketing and data privacy consent records linked to collateral-related customer data.
CREATE TABLE [FinfluxCredit].[tblCollateralConsent] (
    CollateralConsentId INT NOT NULL,
    CollateralId NVARCHAR(255) NOT NULL,
    MarketingConsentFlag BIT NOT NULL,
    DataPrivacyConsentTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCollateralConsent PRIMARY KEY (CollateralConsentId)
);

ALTER TABLE [FinfluxCredit].[tblCollateralValuation] ADD CONSTRAINT FK_tblCollateralValuation_Coll
    FOREIGN KEY (CollateralId) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralId);

ALTER TABLE [FinfluxCredit].[tblCollateralRisk] ADD CONSTRAINT FK_tblCollateralRisk_Collatera
    FOREIGN KEY (CollateralId) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralId);

ALTER TABLE [FinfluxCredit].[tblCollateralInspection] ADD CONSTRAINT FK_tblCollateralInspection_Col
    FOREIGN KEY (CollateralId) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralId);

ALTER TABLE [FinfluxCredit].[tblCollateralConsent] ADD CONSTRAINT FK_tblCollateralConsent_Collat
    FOREIGN KEY (CollateralId) REFERENCES [FinfluxCredit].[tblCollateral] (CollateralId);


-- Dataset: GDS88800
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Corporate borrower master data for Masreph commercial customers.
CREATE TABLE [FinfluxCredit].[tblBorrower] (
    BorrowerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CorporateBorrowerLegalName NVARCHAR(255) NOT NULL,
    BorrowerIndustrySector NVARCHAR(255) NOT NULL,
    ExternalCreditRatingAgency NVARCHAR(255),
    ExternalCreditRating NVARCHAR(255),
    ConsentToDataProcessingFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblBorrower PRIMARY KEY (BorrowerId)
);

-- Booking branch or business unit where credit agreements are recorded.
CREATE TABLE [FinfluxCredit].[tblBookingBranch] (
    BookingBranchKey INT NOT NULL,
    BookingBranchId NVARCHAR(255) NOT NULL,
    BookingBranchCountryCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblBookingBranch PRIMARY KEY (BookingBranchKey)
);

-- Credit finance agreements between Masreph and corporate borrowers for loans, credit lines, and relat
CREATE TABLE [FinfluxCredit].[tblCreditAgreement] (
    CreditAgreementId NVARCHAR(255) NOT NULL,
    BorrowerId INT NOT NULL,
    BookingBranchKey INT NOT NULL,
    AgreementTypeCode NVARCHAR(255) NOT NULL,
    AgreementStatusCode NVARCHAR(255) NOT NULL,
    AgreementSignedDate DATE NOT NULL,
    AgreementMaturityDate DATE,
    InitialPrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentOutstandingBalance DECIMAL(18,4) NOT NULL,
    CreditLimitAmount DECIMAL(18,4),
    InterestRateType NVARCHAR(255) NOT NULL,
    BaseInterestRate DECIMAL(18,4),
    InterestRateSpread DECIMAL(18,4) NOT NULL,
    EffectiveInterestRate DECIMAL(18,4) NOT NULL,
    PaymentFrequencyCode NVARCHAR(255) NOT NULL,
    NextPaymentDueDate DATE,
    DaysPastDue INT NOT NULL,
    CollateralTypeCode NVARCHAR(255),
    CollateralValuationAmount DECIMAL(18,4),
    LoanPurposeDescription NVARCHAR(255),
    OriginationChannelCode NVARCHAR(255) NOT NULL,
    RelationshipManagerId NVARCHAR(255),
    CurrencyCode NVARCHAR(255) NOT NULL,
    NonPerformingExposureFlag BIT NOT NULL,
    InternalCreditRating NVARCHAR(255),
    CovenantBreachFlag BIT NOT NULL,
    RestructuringFlag BIT NOT NULL,
    EarlyRepaymentPenaltyPercent DECIMAL(18,4),
    AmortizationTypeCode NVARCHAR(255) NOT NULL,
    PortfolioSegmentCode NVARCHAR(255) NOT NULL,
    CrossSellEligibilityFlag BIT NOT NULL,
    ProductProfitabilityMarginPercent DECIMAL(18,4),
    ExpectedLossPercent DECIMAL(18,4),
    LastReviewTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCreditAgreement PRIMARY KEY (CreditAgreementId)
);

ALTER TABLE [FinfluxCredit].[tblCreditAgreement] ADD CONSTRAINT FK_tblCreditAgreement_Borrower
    FOREIGN KEY (BorrowerId) REFERENCES [FinfluxCredit].[tblBorrower] (BorrowerId);

ALTER TABLE [FinfluxCredit].[tblCreditAgreement] ADD CONSTRAINT FK_tblCreditAgreement_BookingB
    FOREIGN KEY (BookingBranchKey) REFERENCES [FinfluxCredit].[tblBookingBranch] (BookingBranchKey);


-- Dataset: GDS97093
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinfluxCredit')
    EXEC('CREATE SCHEMA [FinfluxCredit]');

-- Customer master data for Masreph customers involved in leasing products.
CREATE TABLE [FinfluxCredit].[tblCustomer] (
    CustomerKey INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    CustomerCountryCode NVARCHAR(255) NOT NULL,
    CustomerBirthDate DATE,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerKey)
);

-- Leasing contract, product, and collateral-level information.
CREATE TABLE [FinfluxCredit].[tblLeaseContract] (
    LeaseContractKey INT NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    LeaseProductCode NVARCHAR(255) NOT NULL,
    LeaseProductName NVARCHAR(255) NOT NULL,
    LeaseStartDate DATE NOT NULL,
    LeaseMaturityDate DATE NOT NULL,
    LeaseInterestRate DECIMAL(18,4) NOT NULL,
    OutstandingLeasePrincipal DECIMAL(18,4) NOT NULL,
    TotalMonthlyInstallmentAmount DECIMAL(18,4) NOT NULL,
    EarlyTerminationFlag BIT NOT NULL,
    LeaseResidualValue DECIMAL(18,4),
    CollateralType NVARCHAR(255),
    CollateralValuationAmount DECIMAL(18,4),
    ProductProfitMarginPct DECIMAL(18,4),
    NetInterestIncomeLtd DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractKey)
);

-- Credit finance profile per lease exposure, including risk metrics, delinquency and behavioral inform
CREATE TABLE [FinfluxCredit].[tblCreditFinanceProfile] (
    CreditProfileKey INT NOT NULL,
    CreditProfileId NVARCHAR(255) NOT NULL,
    CustomerKey INT NOT NULL,
    LeaseContractKey INT NOT NULL,
    CustomerRiskGrade NVARCHAR(255),
    ApplicationScore INT,
    BehavioralScore INT,
    ProbabilityOfDefault12m DECIMAL(18,4),
    LossGivenDefaultPct DECIMAL(18,4),
    ExposureAtDefaultAmount DECIMAL(18,4),
    DaysPastDue INT NOT NULL,
    CurrentDelinquencyStatus NVARCHAR(255) NOT NULL,
    MaximumDelinquencyLast12m INT,
    NumberOfActiveLeases INT,
    LastPaymentDate DATE,
    LastPaymentAmount DECIMAL(18,4),
    NextPaymentDueDate DATE,
    NextPaymentAmount DECIMAL(18,4),
    WriteOffFlag BIT NOT NULL,
    WriteOffDate DATE,
    InternalCollectionStage NVARCHAR(255),
    CrossSellEligibilityFlag BIT NOT NULL,
    PortfolioSegmentCode NVARCHAR(255),
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblCreditFinanceProf PRIMARY KEY (CreditProfileKey)
);

ALTER TABLE [FinfluxCredit].[tblCreditFinanceProfile] ADD CONSTRAINT FK_tblCreditFinanceProfile_Cus
    FOREIGN KEY (CustomerKey) REFERENCES [FinfluxCredit].[tblCustomer] (CustomerKey);

ALTER TABLE [FinfluxCredit].[tblCreditFinanceProfile] ADD CONSTRAINT FK_tblCreditFinanceProfile_Lea
    FOREIGN KEY (LeaseContractKey) REFERENCES [FinfluxCredit].[tblLeaseContract] (LeaseContractKey);


