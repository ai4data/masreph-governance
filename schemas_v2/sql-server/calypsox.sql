-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: CalypsoX
-- Generated: 2026-03-18T12:08:48.625107
-- Datasets: 1
-- ============================================

-- Dataset: GDS88223
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'CalypsoX')
    EXEC('CREATE SCHEMA [CalypsoX]');

-- Master data for leased assets that may be subject to repossession, including core identification and
CREATE TABLE [CalypsoX].[tblLeaseAsset] (
    LeaseAssetKey INT NOT NULL,
    AssetId NVARCHAR(255) NOT NULL,
    AssetCategory NVARCHAR(255) NOT NULL,
    AssetMake NVARCHAR(255),
    AssetModel NVARCHAR(255),
    AssetVin NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseAsset PRIMARY KEY (LeaseAssetKey)
);

-- Lease contract master data associated with repossessed assets, including customer linkage, product d
CREATE TABLE [CalypsoX].[tblLeaseContract] (
    LeaseContractKey INT NOT NULL,
    LeaseContractId NVARCHAR(255) NOT NULL,
    CustomerId NVARCHAR(255) NOT NULL,
    LeaseAssetKey INT NOT NULL,
    CountryCode NVARCHAR(255) NOT NULL,
    MasrephProductCode NVARCHAR(255) NOT NULL,
    PortfolioSegment NVARCHAR(255) NOT NULL,
    BookingBranchCode NVARCHAR(255),
    OriginationDate DATE NOT NULL,
    LeaseStartDate DATE NOT NULL,
    LeaseEndDate DATE,
    ContractCurrencyCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblLeaseContract PRIMARY KEY (LeaseContractKey)
);

-- Internal teams or external agencies responsible for executing repossession activities.
CREATE TABLE [CalypsoX].[tblRepoAgent] (
    RepoAgentKey INT NOT NULL,
    RepoAgentId NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblRepoAgent PRIMARY KEY (RepoAgentKey)
);

-- Remarketing strategies used to dispose of repossessed assets (e.g., auction, dealer network, direct 
CREATE TABLE [CalypsoX].[tblRemarketingStrategy] (
    RemarketingStrategyKey INT NOT NULL,
    RemarketingStrategyCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblRemarketingStrate PRIMARY KEY (RemarketingStrategyKey)
);

-- Fact table capturing repossession events and performance metrics for leased assets, linked to lease 
CREATE TABLE [CalypsoX].[tblFinanceRepoInsight] (
    RepoInsightId NVARCHAR(255) NOT NULL,
    LeaseContractKey INT NOT NULL,
    RepoAgentKey INT,
    RemarketingStrategyKey INT,
    RepoEventDate DATE NOT NULL,
    RepoCompletionDate DATE,
    RepoStatus NVARCHAR(255) NOT NULL,
    DaysPastDueAtRepo INT,
    ExposureAtDefaultAmount DECIMAL(18,4),
    OutstandingPrincipalAmount DECIMAL(18,4) NOT NULL,
    AccruedInterestAmount DECIMAL(18,4),
    RepoRecoveryAmount DECIMAL(18,4),
    RecoveryRatePct DECIMAL(18,4),
    LossGivenRepossessionPct DECIMAL(18,4),
    WriteOffAmount DECIMAL(18,4),
    LegalActionFlag BIT NOT NULL,
    VoluntarySurrenderFlag BIT NOT NULL,
    CollateralValuationAmount DECIMAL(18,4),
    CollateralValuationDate DATE,
    ResaleDate DATE,
    ResaleProceedsAmount DECIMAL(18,4),
    ResaleExpenseAmount DECIMAL(18,4),
    NetRecoveryAmount DECIMAL(18,4),
    InternalRatingBeforeRepo NVARCHAR(255),
    InternalRatingAfterRepo NVARCHAR(255),
    ProbabilityOfDefaultPct DECIMAL(18,4),
    CrossSellEligibilityFlag BIT NOT NULL,
    PortfolioOptimizationBucket NVARCHAR(255),
    DataSourceSystem NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordUpdateTimestamp DATETIME2,
    GdprConsentFlag BIT NOT NULL,
    RepoResolutionStatus NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblFinanceRepoInsigh PRIMARY KEY (RepoInsightId)
);

ALTER TABLE [CalypsoX].[tblLeaseContract] ADD CONSTRAINT FK_tblLeaseContract_LeaseAsset
    FOREIGN KEY (LeaseAssetKey) REFERENCES [CalypsoX].[tblLeaseAsset] (LeaseAssetKey);

ALTER TABLE [CalypsoX].[tblFinanceRepoInsight] ADD CONSTRAINT FK_tblFinanceRepoInsight_Lease
    FOREIGN KEY (LeaseContractKey) REFERENCES [CalypsoX].[tblLeaseContract] (LeaseContractKey);

ALTER TABLE [CalypsoX].[tblFinanceRepoInsight] ADD CONSTRAINT FK_tblFinanceRepoInsight_RepoA
    FOREIGN KEY (RepoAgentKey) REFERENCES [CalypsoX].[tblRepoAgent] (RepoAgentKey);

ALTER TABLE [CalypsoX].[tblFinanceRepoInsight] ADD CONSTRAINT FK_tblFinanceRepoInsight_Remar
    FOREIGN KEY (RemarketingStrategyKey) REFERENCES [CalypsoX].[tblRemarketingStrategy] (RemarketingStrategyKey);


