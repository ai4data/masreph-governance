-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: credit_finance_service
-- Generated: 2026-03-18T12:18:16.845801
-- Datasets: 1
-- ============================================

-- Dataset: GDS31745
CREATE SCHEMA IF NOT EXISTS credit_finance_service;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS credit_finance_service.credit_risk_ratings_dataset_ (
    id INT NOT NULL,
    credit_risk_record_id STRING NOT NULL,
    source_system_id STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_external_id STRING,
    customer_segment_code STRING NOT NULL,
    customer_residency_country_code STRING NOT NULL,
    customer_industry_nace_code STRING,
    customer_legal_form_code STRING,
    customer_age_years INT,
    customer_onboarding_date DATE NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    reporting_date DATE NOT NULL,
    portfolio_region_code STRING NOT NULL,
    asset_type_code STRING NOT NULL,
    asset_residual_value DECIMAL(18,2),
    outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    total_exposure_at_default DECIMAL(18,2) NOT NULL,
    days_past_due INT NOT NULL,
    delinquency_bucket_code STRING NOT NULL,
    default_flag BOOLEAN NOT NULL,
    default_date DATE,
    restructuring_flag BOOLEAN NOT NULL,
    forbearance_flag BOOLEAN NOT NULL,
    credit_risk_rating_internal STRING NOT NULL,
    credit_risk_rating_external STRING,
    probability_of_default_12m DECIMAL(6,5) NOT NULL,
    loss_given_default_percentage DECIMAL(5,2) NOT NULL,
    exposure_at_default_amount DECIMAL(18,2) NOT NULL,
    expected_credit_loss_12m_amount DECIMAL(18,2) NOT NULL,
    expected_credit_loss_lifetime_amount DECIMAL(18,2) NOT NULL,
    collateral_type_code STRING,
    collateral_value_amount DECIMAL(18,2),
    guarantee_coverage_percentage DECIMAL(5,2),
    interest_rate_effective DECIMAL(5,3) NOT NULL,
    contract_currency_code STRING NOT NULL,
    write_off_flag BOOLEAN NOT NULL,
    write_off_date DATE,
    credit_risk_officer_id STRING,
    last_rating_review_date DATE NOT NULL,
    next_rating_review_due_date DATE,
    risk_factor_codes ARRAY<STRING>,
    data_source_system_code STRING NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_update_timestamp TIMESTAMP NOT NULL,
    gdpr_anonymization_profile MAP<STRING, STRING>,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_credit_risk_ratings_ PRIMARY KEY (id)
);


