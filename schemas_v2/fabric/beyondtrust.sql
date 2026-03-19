-- ============================================
-- Platform: FABRIC
-- Schema/Source: Beyondtrust
-- Generated: 2026-03-18T12:18:16.885336
-- Datasets: 1
-- ============================================

-- Dataset: GDS45323

-- This client dataset supports innovation & technology operations. Key applications include relationsh
CREATE TABLE [Beyondtrust].[SecureFinanceAccessDatasetSFAD] (
    Id INT NOT NULL,
    ClientId UNIQUEIDENTIFIER NOT NULL,
    MasrephRelationshipId VARCHAR(255) NOT NULL,
    ClientSegmentCode VARCHAR(255) NOT NULL,
    ClientResidencyCountryCode VARCHAR(255) NOT NULL,
    OnboardingDate DATE NOT NULL,
    LastInteractionTimestamp DATETIME2,
    PrimaryChannelPreference VARCHAR(255),
    ConsentMarketingFlag BIT NOT NULL,
    ConsentDataSharingFlag BIT NOT NULL,
    AnnualClientRevenueEur DECIMAL(15,2),
    AnnualProfitabilityScore DECIMAL(5,2),
    Interaction12mCount INT,
    RiskAppetiteCategory VARCHAR(255),
    RelationshipManagerOrganizationUnit VARCHAR(255),
    DigitalEngagementIndex DECIMAL(6,3),
    ProductPortfolioSummary VARCHAR(MAX),
    InteractionChannelHistory VARCHAR(MAX),
    DataClassificationLevel VARCHAR(255) NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    IsActiveRelationship BIT NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_SecureFinanceAccessD PRIMARY KEY (Id)
);


