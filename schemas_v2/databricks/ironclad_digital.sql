-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: ironclad_digital
-- Generated: 2026-03-18T12:18:16.847329
-- Datasets: 2
-- ============================================

-- Dataset: GDS38297
CREATE SCHEMA IF NOT EXISTS ironclad_digital;

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS ironclad_digital.finance_access_contracts (
    id INT NOT NULL,
    contract_id STRING NOT NULL,
    masreph_entity_id STRING NOT NULL,
    customer_party_id STRING NOT NULL,
    customer_type STRING NOT NULL,
    contract_number STRING NOT NULL,
    contract_type STRING NOT NULL,
    contract_sub_type STRING,
    contract_status STRING NOT NULL,
    contract_signed_date DATE,
    contract_effective_date DATE NOT NULL,
    contract_expiry_date DATE,
    contract_termination_date DATE,
    contracting_jurisdiction_country STRING NOT NULL,
    contract_currency_code STRING NOT NULL,
    contract_credit_limit_amount DECIMAL(18,2),
    contract_utilized_amount DECIMAL(18,2),
    contract_interest_rate DECIMAL(7,4),
    repayment_frequency STRING,
    contract_term_months INT,
    early_repayment_allowed_flag BOOLEAN NOT NULL,
    collateral_required_flag BOOLEAN NOT NULL,
    digital_channel_access_flag BOOLEAN NOT NULL,
    access_product_code STRING NOT NULL,
    access_product_name STRING NOT NULL,
    onboarding_channel STRING,
    risk_rating_code STRING,
    risk_review_date DATE,
    data_sharing_consent_flag BOOLEAN NOT NULL,
    gdp_compliance_flag BOOLEAN NOT NULL,
    archival_status STRING NOT NULL,
    archival_timestamp TIMESTAMP,
    source_system_code STRING NOT NULL,
    source_system_contract_key STRING NOT NULL,
    record_created_timestamp TIMESTAMP NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    data_quality_score DECIMAL(5,2),
    data_sensitivity_classification STRING NOT NULL,
    reporting_region_code STRING,
    contract_notes STRING,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_access_contr PRIMARY KEY (id)
);


-- Dataset: GDS62630
CREATE SCHEMA IF NOT EXISTS ironclad_digital;

-- This it dataset supports leasing operations. Key applications include data analysis, reporting, busi
CREATE TABLE IF NOT EXISTS ironclad_digital.digital_finance_authorization_data (
    id INT NOT NULL,
    authorization_id STRING NOT NULL,
    lease_application_id STRING NOT NULL,
    customer_masreph_id STRING NOT NULL,
    authorization_timestamp TIMESTAMP NOT NULL,
    authorization_status STRING NOT NULL,
    authorized_amount DECIMAL(15,2) NOT NULL,
    currency_code STRING NOT NULL,
    channel_type STRING NOT NULL,
    device_fingerprint STRING,
    psu_ip_address STRING,
    consent_granted_flag BOOLEAN NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_digital_finance_auth PRIMARY KEY (id)
);


