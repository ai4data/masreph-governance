-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinanceAdvisorNetworkSystem
-- Generated: 2026-03-18T12:08:48.585259
-- Datasets: 3
-- ============================================

-- Dataset: GDS15504
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceAdvisorNetworkSystem')
    EXEC('CREATE SCHEMA [FinanceAdvisorNetworkSystem]');

-- Master data for financial advisors in the Finance Advisor Network, including contact, regulatory, ac
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblAdvisor] (
    AdvisorKey INT NOT NULL,
    AdvisorId NVARCHAR(255) NOT NULL,
    AdvisorExternalReference NVARCHAR(255),
    AdvisorFullName NVARCHAR(255) NOT NULL,
    AdvisorEmailAddress NVARCHAR(255) NOT NULL,
    AdvisorPhoneNumber NVARCHAR(255),
    AdvisorPrimaryOfficeCountry NVARCHAR(255) NOT NULL,
    AdvisorRegulatoryId NVARCHAR(255),
    AdvisorActiveFlag BIT NOT NULL,
    AdvisorOnboardingDate DATE NOT NULL,
    AdvisorLastActivityTimestamp DATETIME2,
    AdvisorCompensationModelCode NVARCHAR(255),
    AdvisorAumSegmentCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAdvisor PRIMARY KEY (AdvisorKey)
);

-- Master data for retail clients, including identity, contact, risk profile, regulatory consents, and 
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblClient] (
    ClientKey INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    ClientExternalReference NVARCHAR(255),
    ClientFullName NVARCHAR(255) NOT NULL,
    ClientDateOfBirth DATE NOT NULL,
    ClientCountryOfResidence NVARCHAR(255) NOT NULL,
    ClientEmailAddress NVARCHAR(255),
    ClientRiskProfileCode NVARCHAR(255) NOT NULL,
    ClientGdprMarketingConsentFlag BIT NOT NULL,
    ClientOnboardingDate DATE NOT NULL,
    ClientInvestmentObjectiveCode NVARCHAR(255),
    ClientEsgPreferenceFlag BIT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientKey)
);

-- Reference data for investment strategies and model portfolios, including identifiers, names, and ris
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblInvestmentStrategy] (
    InvestmentStrategyKey INT NOT NULL,
    InvestmentStrategyId NVARCHAR(255),
    InvestmentStrategyName NVARCHAR(255),
    InvestmentStrategyRiskLevel NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblInvestmentStrateg PRIMARY KEY (InvestmentStrategyKey)
);

-- Fact table capturing the relationship between advisors and clients, including relationship lifecycle
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] (
    AdvisorClientRelationshipId NVARCHAR(255) NOT NULL,
    AdvisorKey INT NOT NULL,
    ClientKey INT NOT NULL,
    InvestmentStrategyKey INT,
    PrimaryAdvisorFlag BIT NOT NULL,
    RelationshipStartDate DATE NOT NULL,
    RelationshipEndDate DATE,
    RelationshipStatusCode NVARCHAR(255) NOT NULL,
    StrategyAssignmentDate DATE,
    PortfolioCurrentMarketValue DECIMAL(18,4),
    PortfolioCurrencyCode NVARCHAR(255) NOT NULL,
    PortfolioNetInvestedAmount DECIMAL(18,4),
    PortfolioTimeWeightedReturn1Y DECIMAL(18,4),
    PortfolioTimeWeightedReturn3YAnnualized DECIMAL(18,4),
    PortfolioVolatility1Y DECIMAL(18,4),
    PortfolioSharpeRatio1Y DECIMAL(18,4),
    AdviceLastReviewDate DATE,
    AdviceNextReviewDueDate DATE,
    Trailing12mGrossRevenue DECIMAL(18,4),
    DataRecordCreationTimestamp DATETIME2 NOT NULL,
    DataRecordLastUpdateTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAdvisorClientRela PRIMARY KEY (AdvisorClientRelationshipId)
);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] ADD CONSTRAINT FK_tblAdvisorClientRelationshi
    FOREIGN KEY (AdvisorKey) REFERENCES [FinanceAdvisorNetworkSystem].[tblAdvisor] (AdvisorKey);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] ADD CONSTRAINT FK_tblAdvisorClientRelationshi
    FOREIGN KEY (ClientKey) REFERENCES [FinanceAdvisorNetworkSystem].[tblClient] (ClientKey);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] ADD CONSTRAINT FK_tblAdvisorClientRelationshi
    FOREIGN KEY (InvestmentStrategyKey) REFERENCES [FinanceAdvisorNetworkSystem].[tblInvestmentStrategy] (InvestmentStrategyKey);


-- Dataset: GDS34054
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceAdvisorNetworkSystem')
    EXEC('CREATE SCHEMA [FinanceAdvisorNetworkSystem]');

-- Stores individual mortgage data usage consent instances, including status, scope, legal basis, and l
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblMortgageConsent] (
    ConsentId NVARCHAR(255) NOT NULL,
    MortgageApplicationKey INT NOT NULL,
    ConsentStatus NVARCHAR(255) NOT NULL,
    ConsentSource NVARCHAR(255) NOT NULL,
    ConsentChannel NVARCHAR(255) NOT NULL,
    ConsentCaptureTimestamp DATETIME2 NOT NULL,
    ConsentEffectiveDate DATE NOT NULL,
    ConsentExpirationDate DATE,
    ConsentVersion NVARCHAR(255) NOT NULL,
    ConsentScope NVARCHAR(255) NOT NULL,
    ConsentWithdrawnFlag BIT NOT NULL,
    ConsentWithdrawnTimestamp DATETIME2,
    ConsentPurposeMortgageAssessmentFlag BIT NOT NULL,
    ConsentPurposeMarketingFlag BIT NOT NULL,
    ConsentPurposeCrossSellFlag BIT NOT NULL,
    DataSharingThirdPartyFlag BIT NOT NULL,
    DataSharingAnalyticsFlag BIT NOT NULL,
    DataSharingGeoFlag BIT NOT NULL,
    MarketingOptOutFlag BIT NOT NULL,
    DataRetentionPeriodDays INT,
    LastConsentReviewDate DATE,
    GdprLegalBasisCode NVARCHAR(255) NOT NULL,
    DataLineageSystemSource NVARCHAR(255) NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMortgageConsent PRIMARY KEY (ConsentId)
);

-- Represents mortgage applications associated with consents, including customer snapshot, loan terms, 
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblMortgageApplication] (
    MortgageApplicationKey INT NOT NULL,
    MortgageApplicationId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    MortgageProductKey INT NOT NULL,
    InterestRate DECIMAL(18,4) NOT NULL,
    LtvRatio DECIMAL(18,4) NOT NULL,
    DtiRatio DECIMAL(18,4),
    PropertyValueAmount DECIMAL(18,4) NOT NULL,
    LoanAmountApproved DECIMAL(18,4),
    LoanTermMonths INT NOT NULL,
    CustomerAgeAtApplication INT NOT NULL,
    CustomerResidencyCountryCode NVARCHAR(255) NOT NULL,
    CustomerEmploymentStatus NVARCHAR(255),
    CreditScoreBand NVARCHAR(255),
    RiskGrade NVARCHAR(255),
    ApplicationDecisionStatus NVARCHAR(255) NOT NULL,
    ApplicationDecisionTimestamp DATETIME2,
    PortfolioSegment NVARCHAR(255),
    KycCompletedFlag BIT NOT NULL,
    AmlScreeningStatus NVARCHAR(255),
    ChannelCampaignId NVARCHAR(255),
    PortfolioExpectedAnnualRevenue DECIMAL(18,4),
    PortfolioRiskWeight DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMortgageApplicati PRIMARY KEY (MortgageApplicationKey)
);

-- Defines mortgage products referenced by applications and consents, including product identifiers, ty
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblMortgageProduct] (
    MortgageProductKey INT NOT NULL,
    ProductId NVARCHAR(255) NOT NULL,
    ProductType NVARCHAR(255) NOT NULL,
    MortgageProductName NVARCHAR(255) NOT NULL,
    MortgageInterestType NVARCHAR(255) NOT NULL,
    MortgageRateType NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblMortgageProduct PRIMARY KEY (MortgageProductKey)
);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblMortgageConsent] ADD CONSTRAINT FK_tblMortgageConsent_Mortgage
    FOREIGN KEY (MortgageApplicationKey) REFERENCES [FinanceAdvisorNetworkSystem].[tblMortgageApplication] (MortgageApplicationKey);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblMortgageApplication] ADD CONSTRAINT FK_tblMortgageApplication_Mort
    FOREIGN KEY (MortgageProductKey) REFERENCES [FinanceAdvisorNetworkSystem].[tblMortgageProduct] (MortgageProductKey);


-- Dataset: GDS67273
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceAdvisorNetworkSystem')
    EXEC('CREATE SCHEMA [FinanceAdvisorNetworkSystem]');

-- Financial advisors participating in the Masreph Finance Advisor Network, including regulatory and op
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblAdvisor] (
    AdvisorId NVARCHAR(255) NOT NULL,
    AdvisorExternalRef NVARCHAR(255),
    AdvisorFullName NVARCHAR(255) NOT NULL,
    AdvisorRegulatorId NVARCHAR(255),
    AdvisorLicenseStatus NVARCHAR(255) NOT NULL,
    AdvisorCountryCode NVARCHAR(255) NOT NULL,
    AdvisorRegion NVARCHAR(255),
    AdvisorOnboardDate DATE NOT NULL,
    AdvisorOffboardDate DATE,
    AdvisorActiveFlag BIT NOT NULL,
    AdvisorPerformanceMetrics NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblAdvisor PRIMARY KEY (AdvisorId)
);

-- Clients served by financial advisors, including segmentation, consent, and residency information.
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblClient] (
    ClientId NVARCHAR(255) NOT NULL,
    ClientMasrephCustomerId NVARCHAR(255),
    ClientSegment NVARCHAR(255) NOT NULL,
    ClientConsentMarketingFlag BIT NOT NULL,
    ClientPrimaryVehicleType NVARCHAR(255),
    ClientResidencyCountryCode NVARCHAR(255) NOT NULL,
    ClientContactChannels NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientId)
);

-- Relationships between advisors and clients, including investment strategy, portfolio performance, an
CREATE TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] (
    AdvisorId NVARCHAR(255) NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    RelationshipStartDate DATE NOT NULL,
    InvestmentStrategyCode NVARCHAR(255) NOT NULL,
    InvestmentStrategyDescription NVARCHAR(255),
    RiskProfileScore INT NOT NULL,
    RiskProfileLastAssessedDate DATE,
    PortfolioMarketValueEur DECIMAL(18,4),
    PortfolioInceptionDate DATE,
    YtdPortfolioReturnPct DECIMAL(18,4),
    Trailing12mPortfolioReturnPct DECIMAL(18,4),
    AutoLoanOutstandingBalanceEur DECIMAL(18,4),
    AutoLoanInterestRatePct DECIMAL(18,4),
    AutoLoanMaturityDate DATE,
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreateTimestamp DATETIME2 NOT NULL,
    RecordUpdateTimestamp DATETIME2,
    InvestmentProductMix NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblAdvisorClientRela PRIMARY KEY (AdvisorId, ClientId)
);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] ADD CONSTRAINT FK_tblAdvisorClientRelationshi
    FOREIGN KEY (AdvisorId) REFERENCES [FinanceAdvisorNetworkSystem].[tblAdvisor] (AdvisorId);

ALTER TABLE [FinanceAdvisorNetworkSystem].[tblAdvisorClientRelationship] ADD CONSTRAINT FK_tblAdvisorClientRelationshi
    FOREIGN KEY (ClientId) REFERENCES [FinanceAdvisorNetworkSystem].[tblClient] (ClientId);


