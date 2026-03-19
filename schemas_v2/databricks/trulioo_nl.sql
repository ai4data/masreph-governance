-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: trulioo_nl
-- Generated: 2026-03-18T12:18:16.841274
-- Datasets: 2
-- ============================================

-- Dataset: GDS28301
CREATE SCHEMA IF NOT EXISTS trulioo_nl;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS trulioo_nl.finance_crime_detection_dataset (
    id INT NOT NULL,
    customer_id STRING NOT NULL,
    customer_leasing_account_id STRING NOT NULL,
    transaction_id STRING NOT NULL,
    transaction_timestamp TIMESTAMP NOT NULL,
    transaction_value_amount DECIMAL(18,2) NOT NULL,
    transaction_currency_code STRING NOT NULL,
    transaction_type_code STRING NOT NULL,
    transaction_channel STRING,
    counterparty_name STRING,
    counterparty_country_code STRING,
    customer_residence_country_code STRING NOT NULL,
    customer_date_of_birth DATE,
    customer_full_name STRING NOT NULL,
    customer_national_id_hash STRING,
    customer_risk_rating STRING,
    risk_score_transaction DECIMAL(5,2),
    risk_score_customer_behavior DECIMAL(6,3),
    alert_generated_flag BOOLEAN NOT NULL,
    alert_id STRING,
    alert_priority_code STRING,
    screening_status_code STRING NOT NULL,
    screening_last_run_timestamp TIMESTAMP,
    pep_flag BOOLEAN,
    sanctions_match_flag BOOLEAN,
    sanctions_match_score DECIMAL(5,2),
    customer_segment_code STRING,
    relationship_manager_id STRING,
    customer_onboarding_date DATE NOT NULL,
    customer_status_code STRING NOT NULL,
    primary_contact_email_hash STRING,
    primary_contact_phone_hash STRING,
    customer_profitability_score DECIMAL(10,2),
    lifetime_lease_volume_amount DECIMAL(18,2),
    open_lease_contract_count INT,
    days_past_due_max INT,
    transaction_geo_location STRING,
    customer_home_branch_code STRING,
    payment_method_code STRING,
    originating_iban_masked STRING,
    beneficiary_iban_masked STRING,
    suspicious_activity_flag BOOLEAN NOT NULL,
    suspicious_activity_reason_code STRING,
    case_reference_id STRING,
    gdpr_processing_basis_code STRING NOT NULL,
    data_record_effective_date DATE NOT NULL,
    data_record_expiry_date DATE,
    created_timestamp TIMESTAMP NOT NULL,
    last_updated_timestamp TIMESTAMP,
    source_system_code STRING NOT NULL,
    data_quality_score DECIMAL(4,2),
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_crime_detect PRIMARY KEY (id)
);


-- Dataset: GDS98125
CREATE SCHEMA IF NOT EXISTS trulioo_nl;

-- This risk management dataset supports commercial finance operations. Key applications include data a
CREATE TABLE IF NOT EXISTS trulioo_nl.finance_risk_detection_dataset (
    id INT NOT NULL,
    transaction_id STRING NOT NULL,
    transaction_reference_number STRING NOT NULL,
    masreph_customer_id STRING NOT NULL,
    account_iban STRING NOT NULL,
    counterparty_account_iban STRING,
    transaction_timestamp TIMESTAMP NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_currency_code STRING NOT NULL,
    transaction_amount DECIMAL(18,2) NOT NULL,
    transaction_type_code STRING NOT NULL,
    transaction_channel STRING NOT NULL,
    transaction_status STRING NOT NULL,
    risk_case_id STRING,
    risk_assessment_score DECIMAL(5,2) NOT NULL,
    risk_assessment_level STRING NOT NULL,
    is_fraud_suspected BOOLEAN NOT NULL,
    fraud_alert_generated_flag BOOLEAN NOT NULL,
    fraud_alert_id STRING,
    booking_country_code STRING NOT NULL,
    booking_branch_id STRING,
    counterparty_name STRING,
    counterparty_country_code STRING,
    counterparty_bank_bic STRING,
    merchant_category_code STRING,
    corporate_group_id STRING,
    lending_facility_id STRING,
    product_type STRING NOT NULL,
    business_unit_code STRING NOT NULL,
    industry_sector_code STRING,
    transaction_purpose_description STRING,
    origin_system_name STRING NOT NULL,
    data_source_category STRING NOT NULL,
    ingestion_batch_id STRING NOT NULL,
    record_create_timestamp TIMESTAMP NOT NULL,
    record_update_timestamp TIMESTAMP,
    is_record_active BOOLEAN NOT NULL,
    aml_monitoring_flag BOOLEAN NOT NULL,
    kyc_review_required_flag BOOLEAN NOT NULL,
    credit_risk_rating STRING,
    operational_risk_indicator STRING,
    sanction_screening_result STRING NOT NULL,
    pep_flag BOOLEAN NOT NULL,
    gdp_compliance_flag BOOLEAN NOT NULL,
    anomaly_score DECIMAL(6,4),
    anomaly_reason_code STRING,
    manual_review_required_flag BOOLEAN NOT NULL,
    reviewer_user_id STRING,
    review_completion_timestamp TIMESTAMP,
    comments_text STRING,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_risk_detecti PRIMARY KEY (id)
);


