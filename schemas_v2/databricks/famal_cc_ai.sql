-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: famal_cc_ai
-- Generated: 2026-03-18T12:18:16.848604
-- Datasets: 1
-- ============================================

-- Dataset: GDS64007
CREATE SCHEMA IF NOT EXISTS famal_cc_ai;

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS famal_cc_ai.credit_finance_onboarding_dataset (
    id INT NOT NULL,
    customer_id STRING NOT NULL,
    onboarding_application_id STRING NOT NULL,
    corporate_group_id STRING,
    customer_legal_name STRING NOT NULL,
    customer_country_of_registration STRING NOT NULL,
    customer_industry_sector_code STRING NOT NULL,
    onboarding_channel STRING NOT NULL,
    onboarding_submission_timestamp TIMESTAMP NOT NULL,
    onboarding_decision_timestamp TIMESTAMP,
    onboarding_status STRING NOT NULL,
    kyc_completed_flag BOOLEAN NOT NULL,
    aml_risk_rating STRING,
    aml_risk_assessment_details MAP<STRING, STRING>,
    credit_bureau_reference_id STRING,
    credit_score_provider_name STRING,
    credit_score_value INT,
    credit_score_effective_date DATE,
    credit_bureau_enquiry_dates ARRAY<STRING>,
    total_outstanding_bank_debt_amount DECIMAL(18,2),
    annual_turnover_amount DECIMAL(18,2),
    annual_turnover_currency_code STRING,
    latest_financial_statement_date DATE,
    requested_credit_product_type STRING NOT NULL,
    requested_credit_limit_amount DECIMAL(18,2) NOT NULL,
    requested_credit_limit_currency_code STRING NOT NULL,
    approved_credit_limit_amount DECIMAL(18,2),
    approved_credit_term_months INT,
    collateral_required_flag BOOLEAN NOT NULL,
    collateral_valuation_amount DECIMAL(18,2),
    primary_relationship_manager_id STRING,
    gdpr_data_processing_consent_flag BOOLEAN NOT NULL,
    default_probability_12m DECIMAL(5,4),
    loss_given_default_percentage DECIMAL(5,2),
    data_lineage_source_system STRING NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_updated_timestamp TIMESTAMP,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_credit_finance_onboa PRIMARY KEY (id)
);


