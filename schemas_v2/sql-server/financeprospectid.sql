-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinanceProspectID
-- Generated: 2026-03-18T12:08:48.601886
-- Datasets: 4
-- ============================================

-- Dataset: GDS36670
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceProspectID')
    EXEC('CREATE SCHEMA [FinanceProspectID]');

-- Core client master data for the mobility finance platform, including identification, demographic att
CREATE TABLE [FinanceProspectID].[tblClient] (
    ClientId NVARCHAR(255) NOT NULL,
    CrmPartyId NVARCHAR(255) NOT NULL,
    NationalClientIdentifier NVARCHAR(255),
    ClientFullName NVARCHAR(255) NOT NULL,
    DateOfBirth DATE NOT NULL,
    CountryOfTaxResidence NVARCHAR(255) NOT NULL,
    ClientTenureMonths INT NOT NULL,
    RelationshipManagerId NVARCHAR(255),
    GeoMobilityPatternSegment NVARCHAR(255),
    HouseholdId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientId)
);

-- Household-level entity linking multiple clients and storing household-level wealth group classificat
CREATE TABLE [FinanceProspectID].[tblHousehold] (
    HouseholdId NVARCHAR(255),
    HouseholdWealthGroupCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblHousehold PRIMARY KEY (HouseholdId)
);

-- Wealth group identification records and financial/behavioral attributes used for segmentation, risk 
CREATE TABLE [FinanceProspectID].[tblClientWealthProfile] (
    ClientWealthProfileId INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    WealthGroupCode NVARCHAR(255) NOT NULL,
    WealthGroupDescription NVARCHAR(255),
    WealthSegmentEffectiveDate DATE NOT NULL,
    WealthSegmentExpiryDate DATE,
    AnnualGrossIncomeAmount DECIMAL(18,4),
    DeclaredNetWorthAmount DECIMAL(18,4),
    MonthlyDisposableIncomeAmount DECIMAL(18,4),
    PrimaryIncomeSourceCode NVARCHAR(255),
    RiskAppetiteLevelCode NVARCHAR(255),
    KycRiskRatingCode NVARCHAR(255),
    ClientProfitabilityScore INT,
    LifetimeValueSegmentCode NVARCHAR(255),
    PrimaryMobilityNeedsDescription NVARCHAR(255),
    ActiveVehicleLeaseCount INT NOT NULL,
    TotalOutstandingLeasingBalance DECIMAL(18,4) NOT NULL,
    LastVehicleLeaseStartDate DATE,
    LastVehicleLeaseEndDate DATE,
    CrossSellEligibilityFlag BIT NOT NULL,
    InvestmentProductHoldingFlag BIT NOT NULL,
    ClientSegmentationVersion NVARCHAR(255) NOT NULL,
    RecordSourceSystemCode NVARCHAR(255) NOT NULL,
    RecordCreatedTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    DataQualityScore INT,
    RecordActiveFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientWealthProfi PRIMARY KEY (ClientWealthProfileId)
);

-- Client-level consents, communication channel preferences, engagement scores, and last/next best cont
CREATE TABLE [FinanceProspectID].[tblClientContactPreference] (
    ClientContactPreferenceId INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    EuGdprConsentFlag BIT NOT NULL,
    PreferredContactChannelCode NVARCHAR(255),
    PreferredContactTimeWindows NVARCHAR(MAX),
    DigitalEngagementScore INT,
    AutoRenewalPreferenceFlag BIT,
    LastContactTimestamp DATETIME2,
    LastContactOutcomeCode NVARCHAR(255),
    NextBestActionCode NVARCHAR(255),
    NextBestOfferValueProposition NVARCHAR(255),
    ConsentToPersonalizedOffersFlag BIT NOT NULL,
    DataSharingThirdPartyFlag BIT NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientContactPref PRIMARY KEY (ClientContactPreferenceId)
);

ALTER TABLE [FinanceProspectID].[tblClientWealthProfile] ADD CONSTRAINT FK_tblClientWealthProfile_Clie
    FOREIGN KEY (ClientId) REFERENCES [FinanceProspectID].[tblClient] (ClientId);

ALTER TABLE [FinanceProspectID].[tblClientContactPreference] ADD CONSTRAINT FK_tblClientContactPreference_
    FOREIGN KEY (ClientId) REFERENCES [FinanceProspectID].[tblClient] (ClientId);

ALTER TABLE [FinanceProspectID].[tblClient] ADD CONSTRAINT FK_tblClient_HouseholdId
    FOREIGN KEY (HouseholdId) REFERENCES [FinanceProspectID].[tblHousehold] (HouseholdId);


-- Dataset: GDS42946
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceProspectID')
    EXEC('CREATE SCHEMA [FinanceProspectID]');

-- Core prospect entity for FinanceProspectID France, including identification, classification, CRM fun
CREATE TABLE [FinanceProspectID].[tblProspect] (
    ProspectId NVARCHAR(255) NOT NULL,
    ProspectExternalRef NVARCHAR(255),
    ProspectType NVARCHAR(255) NOT NULL,
    LegalFormCode NVARCHAR(255),
    ResidencyCountryCode NVARCHAR(255) NOT NULL,
    ClientSegmentCode NVARCHAR(255),
    CrmLeadSource NVARCHAR(255),
    ProspectStatus NVARCHAR(255) NOT NULL,
    StatusLastUpdatedTs DATETIME2 NOT NULL,
    RelationshipManagerId NVARCHAR(255),
    LeadCampaignCode NVARCHAR(255),
    DataRecordCreatedTs DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspect PRIMARY KEY (ProspectId)
);

-- Contact, communication, consent, GDPR, and address information for a prospect, maintained in a 1-1 r
CREATE TABLE [FinanceProspectID].[tblProspectContact] (
    ProspectId NVARCHAR(255) NOT NULL,
    PreferredLanguageCode NVARCHAR(255),
    InitialContactDate DATE,
    LastContactDate DATE,
    NextPlannedContactDate DATE,
    PrimaryContactChannel NVARCHAR(255),
    ConsentMarketingFlag BIT NOT NULL,
    ConsentDataSharingFlag BIT NOT NULL,
    ConsentLastUpdatedDate DATE NOT NULL,
    GdprErasureRequestedFlag BIT NOT NULL,
    GdprErasureRequestDate DATE,
    RegionCodeInsee NVARCHAR(255),
    ContactEmailAddress NVARCHAR(255),
    ContactMobilePhoneE164 NVARCHAR(255),
    ContactPostalCode NVARCHAR(255),
    ContactCity NVARCHAR(255),
    ContactGeolocation NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspectContact PRIMARY KEY (ProspectId)
);

-- Financial, risk, product preference, vehicle usage, and value metrics for a prospect, maintained in 
CREATE TABLE [FinanceProspectID].[tblProspectFinancialProfile] (
    ProspectId NVARCHAR(255) NOT NULL,
    NationalIdHash NVARCHAR(255),
    BirthDate DATE,
    BusinessIncorporationDate DATE,
    AnnualIncomeAmount DECIMAL(18,4),
    EstimatedAnnualTurnoverAmount DECIMAL(18,4),
    CreditRiskRating NVARCHAR(255),
    PreferredFinancingProduct NVARCHAR(255),
    PreferredLeaseTermMonths INT,
    PreferredMonthlyBudgetAmount DECIMAL(18,4),
    VehicleUsagePurpose NVARCHAR(255),
    PreferredVehicleCategory NVARCHAR(255),
    InterestedVehicleModels NVARCHAR(MAX),
    CurrentVehicleOwnershipStatus NVARCHAR(255),
    ExistingAutoLoansCount INT,
    ExistingAutoMonthlyPaymentAmount DECIMAL(18,4),
    ProfitabilityScore DECIMAL(18,4),
    LifetimeValueEur DECIMAL(18,4),
    ChurnRiskScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspectFinancial PRIMARY KEY (ProspectId)
);


-- Dataset: GDS51478
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceProspectID')
    EXEC('CREATE SCHEMA [FinanceProspectID]');

-- Core KYC contact master data linking client entities to individual contacts and their primary identi
CREATE TABLE [FinanceProspectID].[tblClientKycContact] (
    ClientKycContactId NVARCHAR(255) NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    ContactRole NVARCHAR(255) NOT NULL,
    ContactFirstName NVARCHAR(255) NOT NULL,
    ContactLastName NVARCHAR(255) NOT NULL,
    ContactPreferredLanguage NVARCHAR(255),
    ContactEmailAddress NVARCHAR(255),
    ContactMobilePhone NVARCHAR(255),
    ContactBusinessPhone NVARCHAR(255),
    ContactJobTitle NVARCHAR(255),
    ContactDepartment NVARCHAR(255),
    ContactAddressCountry NVARCHAR(255),
    ContactAddressCity NVARCHAR(255),
    ContactAddressPostalCode NVARCHAR(255),
    IsPrimaryKycContact BIT NOT NULL,
    IsDecisionMaker BIT,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientKycContact PRIMARY KEY (ClientKycContactId)
);

-- KYC risk and regulatory assessment details for a client contact, including risk rating, review dates
CREATE TABLE [FinanceProspectID].[tblClientKycAssessment] (
    ClientKycContactId NVARCHAR(255) NOT NULL,
    KycRiskRating NVARCHAR(255),
    KycLastReviewDate DATE,
    KycNextReviewDueDate DATE,
    PepStatus NVARCHAR(255),
    SanctionsScreeningStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientKycAssessme PRIMARY KEY (ClientKycContactId)
);

-- GDPR consent status and audit trail for marketing and informational communications to a client conta
CREATE TABLE [FinanceProspectID].[tblClientContactConsent] (
    ClientKycContactId NVARCHAR(255) NOT NULL,
    GdprConsentMarketing BIT NOT NULL,
    GdprConsentTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientContactCons PRIMARY KEY (ClientKycContactId)
);

-- Commercial summary metrics for a client contact, including attributed revenue and number of active c
CREATE TABLE [FinanceProspectID].[tblClientContactCommercialSummary] (
    ClientKycContactId NVARCHAR(255) NOT NULL,
    AnnualRevenueLinkedToContact DECIMAL(18,4),
    NumberOfActiveContracts INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientContactComm PRIMARY KEY (ClientKycContactId)
);

-- Interaction preferences and recent interaction metadata for a client contact, including preferred ch
CREATE TABLE [FinanceProspectID].[tblClientContactInteractionPreference] (
    ClientKycContactId NVARCHAR(255) NOT NULL,
    ContactPreferredContactChannel NVARCHAR(255),
    LastInteractionTimestamp DATETIME2,
    PreferredMeetingLocationType NVARCHAR(255),
    ContactTimeZone NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClientContactInte PRIMARY KEY (ClientKycContactId)
);


-- Dataset: GDS81862
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinanceProspectID')
    EXEC('CREATE SCHEMA [FinanceProspectID]');

-- Core prospect identity, CRM linkage, demographics, residence, and source system timestamps.
CREATE TABLE [FinanceProspectID].[tblProspect] (
    ProspectId NVARCHAR(255) NOT NULL,
    CrmLeadId NVARCHAR(255),
    ProspectHashId NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(255) NOT NULL,
    LastName NVARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    ResidenceCountryCode NVARCHAR(255) NOT NULL,
    ResidencePostalCode NVARCHAR(255),
    PreferredLanguageCode NVARCHAR(255),
    ProspectCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    HouseholdSizeCount INT,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspect PRIMARY KEY (ProspectId)
);

-- Prospect contact details, preferred communication channels, and GDPR/marketing consent information.
CREATE TABLE [FinanceProspectID].[tblProspectContactConsent] (
    ProspectId NVARCHAR(255) NOT NULL,
    PrimaryContactChannel NVARCHAR(255),
    EmailAddress NVARCHAR(255),
    MobilePhoneNumber NVARCHAR(255),
    MarketingConsentFlag BIT NOT NULL,
    DataProcessingConsentFlag BIT NOT NULL,
    GdprConsentCaptureMethod NVARCHAR(255),
    LastInteractionTimestamp DATETIME2,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspectContactCo PRIMARY KEY (ProspectId)
);

-- Prospect employment, income, indebtedness, credit bureau data, internal risk metrics, and financial 
CREATE TABLE [FinanceProspectID].[tblProspectFinancialProfile] (
    ProspectId NVARCHAR(255) NOT NULL,
    EmploymentStatus NVARCHAR(255),
    EmployerName NVARCHAR(255),
    MonthlyGrossIncomeAmount DECIMAL(18,4),
    MonthlyNetIncomeAmount DECIMAL(18,4),
    TotalMonthlyDebtPaymentsAmount DECIMAL(18,4),
    DebtToIncomeRatio DECIMAL(18,4),
    ExternalCreditScore INT,
    CreditScoreProviderName NVARCHAR(255),
    CreditScoreLastUpdatedDate DATE,
    RiskGrade NVARCHAR(255),
    AutoLeaseInterestRateOffer DECIMAL(18,4),
    MaximumLeaseAmountApproved DECIMAL(18,4),
    PreferredVehicleSegment NVARCHAR(255),
    IntendedLeaseTermMonths INT,
    DownPaymentCapabilityAmount DECIMAL(18,4),
    ExistingAutoLoanOutstandingBalance DECIMAL(18,4),
    ClientSegment NVARCHAR(255),
    ProfitabilityScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspectFinancial PRIMARY KEY (ProspectId)
);

-- Prospect funnel status, lead source, KYC progress, existing leasing relationship, and churn risk.
CREATE TABLE [FinanceProspectID].[tblProspectLifecycle] (
    ProspectId NVARCHAR(255) NOT NULL,
    ProspectStatus NVARCHAR(255) NOT NULL,
    LeadSourceChannel NVARCHAR(255),
    KycCompletionStatus NVARCHAR(255) NOT NULL,
    ExistingLeasingRelationshipFlag BIT NOT NULL,
    ChurnRiskScore DECIMAL(18,4),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblProspectLifecycle PRIMARY KEY (ProspectId)
);

ALTER TABLE [FinanceProspectID].[tblProspectContactConsent] ADD CONSTRAINT FK_tblProspectContactConsent_P
    FOREIGN KEY (ProspectId) REFERENCES [FinanceProspectID].[tblProspect] (ProspectId);

ALTER TABLE [FinanceProspectID].[tblProspectFinancialProfile] ADD CONSTRAINT FK_tblProspectFinancialProfile
    FOREIGN KEY (ProspectId) REFERENCES [FinanceProspectID].[tblProspect] (ProspectId);

ALTER TABLE [FinanceProspectID].[tblProspectLifecycle] ADD CONSTRAINT FK_tblProspectLifecycle_Prospe
    FOREIGN KEY (ProspectId) REFERENCES [FinanceProspectID].[tblProspect] (ProspectId);


