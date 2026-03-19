-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: MasrephProductContractRegistry
-- Generated: 2026-03-18T12:08:48.580214
-- Datasets: 3
-- ============================================

-- Dataset: GDS11935
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'MasrephProductContractRegistry')
    EXEC('CREATE SCHEMA [MasrephProductContractRegistry]');

-- Reference data for external banking or financial institutions partnering with Masreph for mobility f
CREATE TABLE [MasrephProductContractRegistry].[TblPartnerInstitution] (
    PartnerInstitutionKey INT NOT NULL,
    PartnerInstitutionId NVARCHAR(255) NOT NULL,
    PartnerInstitutionName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblPartnerInstitutio PRIMARY KEY (PartnerInstitutionKey)
);

-- Vehicle reference data associated with financed assets in Masreph contracts.
CREATE TABLE [MasrephProductContractRegistry].[TblVehicle] (
    VehicleKey INT NOT NULL,
    VehicleVin NVARCHAR(255),
    VehicleRegistrationNumber NVARCHAR(255),
    VehicleType NVARCHAR(255),
    VehicleMake NVARCHAR(255),
    VehicleModel NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblVehicle PRIMARY KEY (VehicleKey)
);

-- Masreph financial contract registry capturing contract terms, lifecycle status, risk, and payment pe
CREATE TABLE [MasrephProductContractRegistry].[TblContract] (
    ContractId NVARCHAR(255) NOT NULL,
    PartnerInstitutionKey INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    ExternalCustomerReference NVARCHAR(255),
    ContractNumber NVARCHAR(255) NOT NULL,
    ContractType NVARCHAR(255) NOT NULL,
    ProductCategory NVARCHAR(255) NOT NULL,
    ProductSubtype NVARCHAR(255),
    VehicleKey INT,
    ContractStartDate DATE NOT NULL,
    ContractEndDate DATE,
    ContractSignatureTimestamp DATETIME2,
    ContractStatus NVARCHAR(255) NOT NULL,
    OriginationChannel NVARCHAR(255),
    CountryCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    PrincipalAmount DECIMAL(18,4) NOT NULL,
    FinancedAmount DECIMAL(18,4) NOT NULL,
    InterestRateAnnual DECIMAL(18,4) NOT NULL,
    PaymentFrequency NVARCHAR(255) NOT NULL,
    InstallmentAmount DECIMAL(18,4) NOT NULL,
    BalloonPaymentAmount DECIMAL(18,4),
    TermMonths INT NOT NULL,
    RemainingTermMonths INT,
    OutstandingPrincipalAmount DECIMAL(18,4),
    DaysPastDue INT,
    IsDelinquent BIT NOT NULL,
    LastPaymentDate DATE,
    LastPaymentAmount DECIMAL(18,4),
    NextPaymentDueDate DATE,
    EarlyTerminationFlag BIT NOT NULL,
    EarlyTerminationDate DATE,
    CustomerResidencyCountry NVARCHAR(255),
    CustomerSegment NVARCHAR(255),
    CreditScoreBand NVARCHAR(255),
    RiskGrade NVARCHAR(255),
    CustomerRiskIndicators NVARCHAR(MAX),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    RegulatoryReportingFlag BIT NOT NULL,
    ContractTags NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_TblContract PRIMARY KEY (ContractId)
);

ALTER TABLE [MasrephProductContractRegistry].[TblContract] ADD CONSTRAINT FK_TblContract_PartnerInstitut
    FOREIGN KEY (PartnerInstitutionKey) REFERENCES [MasrephProductContractRegistry].[TblPartnerInstitution] (PartnerInstitutionKey);

ALTER TABLE [MasrephProductContractRegistry].[TblContract] ADD CONSTRAINT FK_TblContract_VehicleKey
    FOREIGN KEY (VehicleKey) REFERENCES [MasrephProductContractRegistry].[TblVehicle] (VehicleKey);


-- Dataset: GDS61178
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'MasrephProductContractRegistry')
    EXEC('CREATE SCHEMA [MasrephProductContractRegistry]');

-- Master data for Masreph commercial customers associated with contracts
CREATE TABLE [MasrephProductContractRegistry].[tblCustomer] (
    CustomerId INT NOT NULL,
    MasrephCustomerId NVARCHAR(255) NOT NULL,
    CustomerLegalName NVARCHAR(255) NOT NULL,
    CustomerCountryOfIncorporation NVARCHAR(255) NOT NULL,
    CustomerSegment NVARCHAR(255),
    InternalRiskRating NVARCHAR(255),
    ExternalRiskRatings NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblCustomer PRIMARY KEY (CustomerId)
);

-- Registry of Masreph commercial finance contracts with lifecycle, financial, collateral, and covenant
CREATE TABLE [MasrephProductContractRegistry].[tblContract] (
    ContractId NVARCHAR(255) NOT NULL,
    CustomerId INT NOT NULL,
    ExternalPartnerContractId NVARCHAR(255),
    ContractVersionNumber INT NOT NULL,
    ContractType NVARCHAR(255) NOT NULL,
    ProductFamily NVARCHAR(255) NOT NULL,
    ProductSubType NVARCHAR(255),
    ContractStatus NVARCHAR(255) NOT NULL,
    StatusEffectiveDate DATE NOT NULL,
    OriginationDate DATE NOT NULL,
    ActivationTimestamp DATETIME2,
    MaturityDate DATE,
    InitialPrincipalAmount DECIMAL(18,4) NOT NULL,
    CurrentPrincipalBalance DECIMAL(18,4) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    InterestRateType NVARCHAR(255) NOT NULL,
    NominalInterestRate DECIMAL(18,4),
    InterestCalculationMethod NVARCHAR(255),
    RepaymentFrequency NVARCHAR(255),
    RepaymentDayOfMonth INT,
    NextInstalmentDueDate DATE,
    NextInstalmentAmount DECIMAL(18,4),
    CollateralType NVARCHAR(255),
    CollateralValuationAmount DECIMAL(18,4),
    CollateralValuationDate DATE,
    CollateralCurrencyCode NVARCHAR(255),
    MasrephLegalEntityId NVARCHAR(255) NOT NULL,
    CreditCommitteeApprovalDate DATE,
    CreditLimitAmount DECIMAL(18,4),
    UtilizedLimitAmount DECIMAL(18,4),
    CovenantSummary NVARCHAR(MAX),
    CovenantComplianceStatus NVARCHAR(255),
    LastCovenantReviewDate DATE,
    DefaultIndicator BIT NOT NULL,
    DefaultDate DATE,
    EarlyRepaymentAllowed BIT,
    GoverningLawCountry NVARCHAR(255),
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblContract PRIMARY KEY (ContractId)
);

ALTER TABLE [MasrephProductContractRegistry].[tblContract] ADD CONSTRAINT FK_tblContract_CustomerId
    FOREIGN KEY (CustomerId) REFERENCES [MasrephProductContractRegistry].[tblCustomer] (CustomerId);


-- Dataset: GDS64283
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'MasrephProductContractRegistry')
    EXEC('CREATE SCHEMA [MasrephProductContractRegistry]');

-- Reference data for partner institutions offering financial products in the Masreph registry.
CREATE TABLE [MasrephProductContractRegistry].[tblExternalInstitution] (
    ExternalInstitutionId NVARCHAR(20) NOT NULL,
    ExternalInstitutionName NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblExternalInstituti PRIMARY KEY (ExternalInstitutionId)
);

-- Financial product registry entries from partner institutions, including terms, pricing, risk, regula
CREATE TABLE [MasrephProductContractRegistry].[tblFinancialProduct] (
    ProductRegistryId NVARCHAR(255) NOT NULL,
    PartnerProductCode NVARCHAR(32) NOT NULL,
    ExternalInstitutionId NVARCHAR(20) NOT NULL,
    ProductCategory NVARCHAR(50) NOT NULL,
    ProductSubCategory NVARCHAR(100),
    ProductName NVARCHAR(150) NOT NULL,
    ProductDescription NVARCHAR(MAX),
    ProductCurrencyCode NVARCHAR(3) NOT NULL,
    ProductStartDate DATE,
    ProductEndDate DATE,
    ProductStatus NVARCHAR(50) NOT NULL,
    IsLeasingEligible BIT NOT NULL,
    LeasingTermMinMonths INT,
    LeasingTermMaxMonths INT,
    MinFinancingAmount DECIMAL(18,4),
    MaxFinancingAmount DECIMAL(18,4),
    InterestRateType NVARCHAR(50),
    InterestRateMin DECIMAL(18,4),
    InterestRateMax DECIMAL(18,4),
    FeeStructureDescription NVARCHAR(MAX),
    UpfrontFeeAmount DECIMAL(18,4),
    RecurringFeeAmount DECIMAL(18,4),
    RepaymentFrequency NVARCHAR(50),
    CollateralRequiredFlag BIT NOT NULL,
    CollateralType NVARCHAR(100),
    EarlyTerminationAllowed BIT NOT NULL,
    EarlyTerminationFeePercent DECIMAL(18,4),
    GracePeriodMonths INT,
    RiskRatingInternal NVARCHAR(20),
    RiskRatingExternal NVARCHAR(50),
    TargetCustomerSegment NVARCHAR(50),
    CountryOfOffer NVARCHAR(2) NOT NULL,
    EuRegulatoryClassification NVARCHAR(100),
    KycRequiredLevel NVARCHAR(50),
    UnderwritingRequiredFlag BIT NOT NULL,
    DigitalOnboardingAvailable BIT NOT NULL,
    ApplicationChannelList NVARCHAR(MAX),
    SupportedCustomerTypes NVARCHAR(MAX),
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedTimestamp DATETIME2 NOT NULL,
    DataSourceSystem NVARCHAR(100) NOT NULL,
    MasrephProductMappingId NVARCHAR(36),
    GdprDataProcessingBasis NVARCHAR(50),
    MarketingConsentRequired BIT NOT NULL,
    LanguageOfContract NVARCHAR(2),
    MaxLoanToValuePercent DECIMAL(18,4),
    InsuranceCoveragePercent DECIMAL(18,4),
    InvestmentRiskProfile NVARCHAR(50),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinancialProduct PRIMARY KEY (ProductRegistryId)
);

ALTER TABLE [MasrephProductContractRegistry].[tblFinancialProduct] ADD CONSTRAINT FK_tblFinancialProduct_Externa
    FOREIGN KEY (ExternalInstitutionId) REFERENCES [MasrephProductContractRegistry].[tblExternalInstitution] (ExternalInstitutionId);


