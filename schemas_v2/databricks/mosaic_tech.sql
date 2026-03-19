-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: mosaic_tech
-- Generated: 2026-03-18T12:18:16.838942
-- Datasets: 3
-- ============================================

-- Dataset: GDS21491
CREATE SCHEMA IF NOT EXISTS mosaic_tech;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS mosaic_tech.finance_exposure_data (
    id INT NOT NULL,
    exposure_id STRING NOT NULL,
    source_system_code STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_legal_name STRING NOT NULL,
    customer_country_code STRING NOT NULL,
    customer_industry_code STRING,
    counterparty_risk_rating STRING NOT NULL,
    exposure_currency_code STRING NOT NULL,
    exposure_ead_amount DECIMAL(18,2) NOT NULL,
    exposure_lgd_percentage DECIMAL(5,2) NOT NULL,
    exposure_pd_percentage DECIMAL(6,4) NOT NULL,
    exposure_tenor_months INT NOT NULL,
    interest_rate_type STRING NOT NULL,
    interest_rate_decimal DECIMAL(7,5) NOT NULL,
    collateral_type STRING,
    collateral_valuation_amount DECIMAL(18,2),
    collateral_valuation_date DATE,
    is_collateral_insured BOOLEAN NOT NULL,
    market_risk_exposure_amount DECIMAL(18,2),
    credit_risk_exposure_amount DECIMAL(18,2) NOT NULL,
    operational_risk_exposure_amount DECIMAL(18,2),
    total_risk_exposure_amount DECIMAL(18,2) NOT NULL,
    exposure_status_code STRING NOT NULL,
    exposure_status_timestamp TIMESTAMP NOT NULL,
    reporting_date DATE NOT NULL,
    risk_reporting_region STRING NOT NULL,
    basel_segment_code STRING,
    days_past_due INT NOT NULL,
    default_indicator BOOLEAN NOT NULL,
    impairment_stage_code STRING NOT NULL,
    expected_credit_loss_12m_amount DECIMAL(18,2),
    lifetime_expected_credit_loss_amount DECIMAL(18,2),
    last_payment_date DATE,
    next_payment_due_date DATE,
    lease_maturity_date DATE NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    last_updated_timestamp TIMESTAMP NOT NULL,
    risk_mitigation_instruments ARRAY<STRING>,
    regulatory_portfolio_code STRING,
    customer_risk_appetite_score INT,
    customer_contact_email STRING,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_exposure_dat PRIMARY KEY (id)
);


-- Dataset: GDS36169
CREATE SCHEMA IF NOT EXISTS mosaic_tech;

-- This risk management dataset supports consumer finance operations. Key applications include data ana
CREATE TABLE IF NOT EXISTS mosaic_tech.finance_exposure_data (
    id INT NOT NULL,
    exposure_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    external_customer_reference STRING,
    product_type STRING NOT NULL,
    contract_id STRING NOT NULL,
    account_iban STRING,
    counterparty_country_code STRING NOT NULL,
    currency_code STRING NOT NULL,
    exposure_as_of_date DATE NOT NULL,
    origination_date DATE NOT NULL,
    maturity_date DATE,
    days_past_due INT NOT NULL,
    current_principal_balance DECIMAL(15,2) NOT NULL,
    current_interest_accrued DECIMAL(15,2) NOT NULL,
    credit_limit_amount DECIMAL(15,2),
    undrawn_commitment_amount DECIMAL(15,2),
    interest_rate_type STRING NOT NULL,
    contract_interest_rate DECIMAL(7,4) NOT NULL,
    effective_interest_rate DECIMAL(7,4),
    probability_of_default_12m DECIMAL(6,5) NOT NULL,
    loss_given_default DECIMAL(5,4) NOT NULL,
    exposure_at_default DECIMAL(18,2) NOT NULL,
    expected_credit_loss_12m DECIMAL(18,2) NOT NULL,
    ifrs9_stage STRING NOT NULL,
    credit_risk_rating STRING NOT NULL,
    collateral_type STRING NOT NULL,
    collateral_value DECIMAL(18,2),
    loan_to_value_ratio DECIMAL(6,4),
    market_risk_sensitivity_bucket STRING NOT NULL,
    operational_risk_flag BOOLEAN NOT NULL,
    default_status_flag BOOLEAN NOT NULL,
    nonperforming_exposure_flag BOOLEAN NOT NULL,
    restructuring_status STRING NOT NULL,
    segment_code STRING NOT NULL,
    behavioral_score INT,
    utilization_ratio DECIMAL(6,4),
    data_record_created_timestamp TIMESTAMP NOT NULL,
    last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_exposure_dat PRIMARY KEY (id)
);


-- Dataset: GDS64703
CREATE SCHEMA IF NOT EXISTS mosaic_tech;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS mosaic_tech.finance_exposure_data (
    id INT NOT NULL,
    exposure_record_id STRING NOT NULL,
    source_system_code STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    lessee_customer_id STRING NOT NULL,
    lessee_legal_name STRING NOT NULL,
    lessee_country_iso2 STRING NOT NULL,
    lessee_industry_nace_code STRING,
    lessee_tax_id_hash STRING,
    counterparty_risk_segment STRING,
    exposure_currency_code STRING NOT NULL,
    exposure_start_date DATE NOT NULL,
    exposure_end_date DATE,
    reporting_date DATE NOT NULL,
    exposure_outstanding_amount DECIMAL(18,2) NOT NULL,
    exposure_limit_amount DECIMAL(18,2),
    exposure_utilization_ratio DECIMAL(9,6),
    days_past_due INT NOT NULL,
    credit_risk_grade STRING,
    probability_of_default_12m DECIMAL(5,4),
    loss_given_default_percentage DECIMAL(5,2),
    exposure_type STRING NOT NULL,
    collateral_type STRING,
    collateral_valuation_amount DECIMAL(18,2),
    collateral_valuation_date DATE,
    interest_rate_type STRING NOT NULL,
    effective_interest_rate DECIMAL(7,4),
    payment_frequency_code STRING NOT NULL,
    is_non_performing_exposure BOOLEAN NOT NULL,
    impairment_stage_ifrs9 STRING NOT NULL,
    expected_credit_loss_12m_amount DECIMAL(18,2),
    expected_credit_loss_lifetime_amount DECIMAL(18,2),
    market_risk_sensitivity_vector ARRAY<STRING>,
    operational_risk_event_flag BOOLEAN NOT NULL,
    restructuring_flag BOOLEAN NOT NULL,
    last_status_update_timestamp TIMESTAMP NOT NULL,
    data_origin_region STRING NOT NULL,
    gdpr_personal_data_flag BOOLEAN NOT NULL,
    record_processing_status STRING NOT NULL,
    risk_factor_summary MAP<STRING, STRING>,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_exposure_dat PRIMARY KEY (id)
);


