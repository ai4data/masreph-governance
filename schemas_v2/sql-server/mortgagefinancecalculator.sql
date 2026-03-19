-- ============================================
-- Platform: SQL-SERVER
-- Schema/Source: MortgageFinanceCalculator
-- Generated: 2026-03-18T12:08:48.614460
-- Datasets: 1
-- ============================================

-- Dataset: GDS65848
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'MortgageFinanceCalculator')
    EXEC('CREATE SCHEMA [MortgageFinanceCalculator]');

-- Captures individual mortgage finance calculator runs, including inputs, derived metrics, and decisio
CREATE TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] (
    MortgageCalculationId NVARCHAR(255) NOT NULL,
    CustomerReferenceId NVARCHAR(255),
    PropertyLocationCountryCode NVARCHAR(255) NOT NULL,
    CurrencyCode NVARCHAR(255) NOT NULL,
    LoanAmount DECIMAL(18,4) NOT NULL,
    DownPaymentAmount DECIMAL(18,4),
    PropertyPurchasePrice DECIMAL(18,4),
    LoanToValueRatioPct DECIMAL(18,4),
    InterestRateAnnualPct DECIMAL(18,4) NOT NULL,
    InterestRateTypeCode NVARCHAR(255) NOT NULL,
    AmortizationTypeCode NVARCHAR(255) NOT NULL,
    LoanTermMonths INT NOT NULL,
    RepaymentFrequencyCode NVARCHAR(255) NOT NULL,
    LoanStartDate DATE NOT NULL,
    FirstPaymentDate DATE,
    MonthlyPaymentAmount DECIMAL(18,4),
    TotalInterestPayable DECIMAL(18,4),
    TotalPaymentAmount DECIMAL(18,4),
    DebtToIncomeRatioPct DECIMAL(18,4),
    RiskRatingScore INT,
    EligibilityStatusCode NVARCHAR(255),
    IsPreApprovalScenario BIT NOT NULL,
    CalculatorRunTimestamp DATETIME2 NOT NULL,
    ScenarioName NVARCHAR(255),
    CreatedDate DATETIME2 NOT NULL,
    ModifiedDate DATETIME2
    ,CONSTRAINT PK_tblMortgageCalculati PRIMARY KEY (MortgageCalculationId)
);

-- Reference table for property location countries used in mortgage scenarios, based on ISO-3166-1-alph
CREATE TABLE [MortgageFinanceCalculator].[Country] (
    CountryCode NVARCHAR(255) NOT NULL,
    CountryName NVARCHAR(255)
    ,CONSTRAINT PK_Country PRIMARY KEY (CountryCode)
);

-- Reference table for currencies used in mortgage calculations, based on ISO-4217 codes.
CREATE TABLE [MortgageFinanceCalculator].[Currency] (
    CurrencyCode NVARCHAR(255) NOT NULL,
    CurrencyName NVARCHAR(255)
    ,CONSTRAINT PK_Currency PRIMARY KEY (CurrencyCode)
);

-- Reference table defining interest rate types such as fixed, variable, or hybrid.
CREATE TABLE [MortgageFinanceCalculator].[InterestRateType] (
    InterestRateTypeCode NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255)
    ,CONSTRAINT PK_InterestRateType PRIMARY KEY (InterestRateTypeCode)
);

-- Reference table defining amortization structures such as principal-and-interest or interest-only.
CREATE TABLE [MortgageFinanceCalculator].[AmortizationType] (
    AmortizationTypeCode NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255)
    ,CONSTRAINT PK_AmortizationType PRIMARY KEY (AmortizationTypeCode)
);

-- Reference table defining repayment frequencies such as monthly, biweekly, or weekly.
CREATE TABLE [MortgageFinanceCalculator].[RepaymentFrequency] (
    RepaymentFrequencyCode NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255)
    ,CONSTRAINT PK_RepaymentFrequency PRIMARY KEY (RepaymentFrequencyCode)
);

-- Reference table defining eligibility statuses for mortgage scenarios.
CREATE TABLE [MortgageFinanceCalculator].[EligibilityStatus] (
    EligibilityStatusCode NVARCHAR(255) NOT NULL,
    Description NVARCHAR(255)
    ,CONSTRAINT PK_EligibilityStatus PRIMARY KEY (EligibilityStatusCode)
);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Prop
    FOREIGN KEY (PropertyLocationCountryCode) REFERENCES [MortgageFinanceCalculator].[Country] (CountryCode);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Curr
    FOREIGN KEY (CurrencyCode) REFERENCES [MortgageFinanceCalculator].[Currency] (CurrencyCode);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Inte
    FOREIGN KEY (InterestRateTypeCode) REFERENCES [MortgageFinanceCalculator].[InterestRateType] (InterestRateTypeCode);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Amor
    FOREIGN KEY (AmortizationTypeCode) REFERENCES [MortgageFinanceCalculator].[AmortizationType] (AmortizationTypeCode);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Repa
    FOREIGN KEY (RepaymentFrequencyCode) REFERENCES [MortgageFinanceCalculator].[RepaymentFrequency] (RepaymentFrequencyCode);

ALTER TABLE [MortgageFinanceCalculator].[tblMortgageCalculation] ADD CONSTRAINT FK_tblMortgageCalculation_Elig
    FOREIGN KEY (EligibilityStatusCode) REFERENCES [MortgageFinanceCalculator].[EligibilityStatus] (EligibilityStatusCode);


