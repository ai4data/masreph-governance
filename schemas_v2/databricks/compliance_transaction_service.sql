-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: compliance_transaction_service
-- Generated: 2026-03-18T12:18:16.849602
-- Datasets: 1
-- ============================================

-- Dataset: GDS69297
CREATE SCHEMA IF NOT EXISTS compliance_transaction_service;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS compliance_transaction_service.compliance_transaction_filter_dataset (
    id INT NOT NULL,
    masreph_lease_contract_id STRING NOT NULL,
    filtered_transaction_id STRING NOT NULL,
    source_transaction_reference STRING NOT NULL,
    transaction_posting_timestamp TIMESTAMP NOT NULL,
    transaction_value_date DATE NOT NULL,
    transaction_currency_code STRING NOT NULL,
    transaction_amount_gross DECIMAL(15,2) NOT NULL,
    transaction_amount_net DECIMAL(15,2),
    customer_internal_id STRING NOT NULL,
    customer_segment_code STRING,
    lessee_country_of_residence STRING NOT NULL,
    beneficial_owner_risk_rating STRING,
    transaction_channel_code STRING NOT NULL,
    payment_instrument_type STRING,
    iban_masked STRING,
    counterparty_bank_bic STRING,
    compliance_filter_result_code STRING NOT NULL,
    is_transaction_blocked BOOLEAN NOT NULL,
    is_transaction_reportable BOOLEAN NOT NULL,
    suspicion_score DECIMAL(5,2),
    suspicion_score_version STRING,
    sanctions_screening_status STRING NOT NULL,
    sanctions_list_sources ARRAY<STRING>,
    pep_match_indicator BOOLEAN NOT NULL,
    pep_risk_level STRING,
    aml_alert_id STRING,
    aml_case_status STRING,
    gdpr_processing_legal_basis STRING NOT NULL,
    gdpr_data_subject_region STRING,
    personal_data_minimization_flag BOOLEAN NOT NULL,
    customer_consent_marketing BOOLEAN,
    customer_consent_timestamp TIMESTAMP,
    transaction_purpose_code STRING,
    transaction_purpose_description STRING,
    high_risk_country_flag BOOLEAN NOT NULL,
    high_risk_country_code STRING,
    customer_industry_nace_code STRING,
    lease_asset_category STRING NOT NULL,
    manual_review_required_flag BOOLEAN NOT NULL,
    manual_review_completed_timestamp TIMESTAMP,
    manual_review_outcome_code STRING,
    data_lineage_source_system STRING NOT NULL,
    data_lineage_batch_id STRING NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_update_timestamp TIMESTAMP NOT NULL,
    compliance_notes STRING,
    risk_flags MAP<STRING, STRING>,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_compliance_transacti PRIMARY KEY (id)
);


