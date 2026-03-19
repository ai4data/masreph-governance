-- ============================================
-- Platform: FABRIC
-- Schema/Source: SharePoint
-- Generated: 2026-03-18T12:18:16.887336
-- Datasets: 1
-- ============================================

-- Dataset: GDS53198

-- This employee dataset supports innovation & technology operations. Key applications include data ana
CREATE TABLE [SharePoint].[FinanceCallRecords] (
    Id INT NOT NULL,
    CallRecordId UNIQUEIDENTIFIER NOT NULL,
    EmployeeId VARCHAR(255) NOT NULL,
    EmployeeRoleCode VARCHAR(255) NOT NULL,
    EmployeeRoleDescription VARCHAR(255),
    BusinessEntityCode VARCHAR(255) NOT NULL,
    CallStartTimestamp DATETIME2 NOT NULL,
    CallEndTimestamp DATETIME2,
    CallDurationSeconds INT,
    CallChannelType VARCHAR(255) NOT NULL,
    CustomerSegmentCode VARCHAR(255),
    ProductDiscussedCode VARCHAR(255),
    ProductDiscussedName VARCHAR(255),
    CallPurposeDescription VARCHAR(255),
    CallOutcomeCode VARCHAR(255) NOT NULL,
    CallOutcomeDescription VARCHAR(255),
    FollowUpRequiredFlag BIT NOT NULL,
    FollowUpDueDate DATE,
    RegionCode VARCHAR(255),
    LanguageCode VARCHAR(255),
    EscalationIndicator BIT NOT NULL,
    EscalationLevel VARCHAR(255),
    GdpComplianceFlag BIT NOT NULL,
    RecordingConsentFlag BIT NOT NULL,
    CreatedTimestamp DATETIME2 NOT NULL,
    LastUpdatedTimestamp DATETIME2 NOT NULL,
    SourceSystemCode VARCHAR(255) NOT NULL,
    LoadedAt DATETIME2,
    SourceSystem VARCHAR(255)
    ,CONSTRAINT PK_FinanceCallRecords PRIMARY KEY (Id)
);


