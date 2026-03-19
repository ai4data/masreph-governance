-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: FinHub
-- Generated: 2026-03-18T12:08:48.627606
-- Datasets: 1
-- ============================================

-- Dataset: GDS90319
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'FinHub')
    EXEC('CREATE SCHEMA [FinHub]');

-- Master data for commercial clients, including identification, segmentation, domicile and risk-relate
CREATE TABLE [FinHub].[tblClient] (
    ClientKey INT NOT NULL,
    ClientId NVARCHAR(255) NOT NULL,
    ClientGlobalUltimateParentId NVARCHAR(255),
    ClientName NVARCHAR(255) NOT NULL,
    ClientSegmentCode NVARCHAR(255) NOT NULL,
    ClientSegmentDescription NVARCHAR(255) NOT NULL,
    ClientCountryIso2 NVARCHAR(255) NOT NULL,
    ClientRiskRating NVARCHAR(255),
    ClientRiskRatingDate DATE,
    ClientIndustryNaceCode NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblClient PRIMARY KEY (ClientKey)
);

-- Core banking account master linked to structures, including identifiers, currency, lifecycle status 
CREATE TABLE [FinHub].[tblAccount] (
    AccountKey INT NOT NULL,
    AccountId NVARCHAR(255),
    AccountIban NVARCHAR(255),
    AccountCurrencyCode NVARCHAR(255) NOT NULL,
    AccountOpenDate DATE,
    AccountStatusCode NVARCHAR(255) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAccount PRIMARY KEY (AccountKey)
);

-- Client accountability structure nodes representing hierarchical relationship, booking entity, exposu
CREATE TABLE [FinHub].[tblAccountStructure] (
    AccountStructureKey INT NOT NULL,
    AccountStructureId NVARCHAR(255) NOT NULL,
    ParentAccountStructureId NVARCHAR(255),
    ClientKey INT NOT NULL,
    MasrephLegalEntityId NVARCHAR(255) NOT NULL,
    AccountKey INT,
    IsStructuringEntity BIT NOT NULL,
    StructureEffectiveDate DATE NOT NULL,
    StructureEndDate DATE,
    ExposureAmountEur DECIMAL(18,4),
    UndrawnCommitmentEur DECIMAL(18,4),
    ProbabilityOfDefaultPct DECIMAL(18,4),
    LossGivenDefaultPct DECIMAL(18,4),
    DataSourceSystemCode NVARCHAR(255) NOT NULL,
    RegulatoryReportingFlag BIT NOT NULL,
    CreditOfficerEmployeeId NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_tblAccountStructure PRIMARY KEY (AccountStructureKey)
);

-- Fact table representing individual Client Accountability Structure Dataset (CASD) records, linking s
CREATE TABLE [FinHub].[CasdRecord] (
    CasdRecordId NVARCHAR(255) NOT NULL,
    AccountStructureKey INT NOT NULL,
    StreamingIngestionPartitionKey NVARCHAR(255) NOT NULL,
    RecordCreationTimestamp DATETIME2 NOT NULL,
    RecordLastUpdatedTimestamp DATETIME2 NOT NULL,
    IsRecordActive BIT NOT NULL,
    GdprPersonalDataFlag BIT NOT NULL,
    DataQualityScore DECIMAL(18,4) NOT NULL,
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2 NOT NULL
    ,CONSTRAINT PK_CasdRecord PRIMARY KEY (CasdRecordId)
);

ALTER TABLE [FinHub].[FinHub.tblAccountStructure] ADD CONSTRAINT FK_FinHub.tblAccountStructure_
    FOREIGN KEY (ClientKey) REFERENCES [FinHub].[FinHub.tblClient] (ClientKey);

ALTER TABLE [FinHub].[FinHub.tblAccountStructure] ADD CONSTRAINT FK_FinHub.tblAccountStructure_
    FOREIGN KEY (AccountKey) REFERENCES [FinHub].[FinHub.tblAccount] (AccountKey);

ALTER TABLE [FinHub].[FinHub.CasdRecord] ADD CONSTRAINT FK_FinHub.CasdRecord_AccountSt
    FOREIGN KEY (AccountStructureKey) REFERENCES [FinHub].[FinHub.tblAccountStructure] (AccountStructureKey);

ALTER TABLE [FinHub].[FinHub.tblAccountStructure] ADD CONSTRAINT FK_FinHub.tblAccountStructure_
    FOREIGN KEY (ParentAccountStructureId) REFERENCES [FinHub].[FinHub.tblAccountStructure] (AccountStructureId);


