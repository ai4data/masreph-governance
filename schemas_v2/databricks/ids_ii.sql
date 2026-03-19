-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: ids_ii
-- Generated: 2026-03-18T12:18:16.844295
-- Datasets: 2
-- ============================================

-- Dataset: GDS31114
CREATE SCHEMA IF NOT EXISTS ids_ii;

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS ids_ii.finance_profile_data (
    id INT NOT NULL,
    client_profile_id STRING NOT NULL,
    masreph_client_reference STRING NOT NULL,
    external_crm_client_id STRING,
    customer_type STRING NOT NULL,
    residency_country_code STRING NOT NULL,
    primary_mobility_product_type STRING NOT NULL,
    onboarding_channel STRING,
    relationship_start_date DATE NOT NULL,
    relationship_status STRING NOT NULL,
    preferred_contact_language STRING,
    annual_gross_income_amount DECIMAL(15,2),
    income_currency_code STRING,
    primary_income_source STRING,
    monthly_recurring_expense_amount DECIMAL(15,2),
    auto_loan_outstanding_balance DECIMAL(15,2),
    auto_loan_interest_rate DECIMAL(5,3),
    number_of_active_mobility_contracts INT NOT NULL,
    last_mobility_contract_start_date DATE,
    last_mobility_contract_end_date DATE,
    preferred_financing_term_months INT,
    risk_segment_code STRING,
    credit_score_internal INT,
    credit_score_last_update_timestamp TIMESTAMP,
    investment_risk_appetite STRING,
    preferred_investment_horizon_years INT,
    sustainable_investment_preference_flag BOOLEAN,
    monthly_savings_capacity_estimate DECIMAL(15,2),
    profitability_segment_code STRING,
    twelve_month_revenue_contribution DECIMAL(15,2),
    twelve_month_cost_to_serve DECIMAL(15,2),
    relationship_profitability_index DECIMAL(6,3),
    churn_risk_score DECIMAL(5,4),
    next_best_offer_category STRING,
    next_best_offer_eligibility_flag BOOLEAN,
    digital_engagement_level STRING,
    primary_mobile_device_os STRING,
    consent_personal_data_processing_flag BOOLEAN NOT NULL,
    consent_marketing_communications_flag BOOLEAN NOT NULL,
    consent_data_sharing_third_parties_flag BOOLEAN NOT NULL,
    consent_last_updated_timestamp TIMESTAMP NOT NULL,
    kyc_completion_status STRING NOT NULL,
    kyc_last_review_date DATE,
    pep_flag BOOLEAN NOT NULL,
    aml_monitoring_risk_level STRING NOT NULL,
    last_interaction_channel STRING,
    last_interaction_timestamp TIMESTAMP,
    data_record_source_system STRING NOT NULL,
    data_record_created_timestamp TIMESTAMP NOT NULL,
    data_record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_profile_data PRIMARY KEY (id)
);


-- Dataset: GDS98467
CREATE SCHEMA IF NOT EXISTS ids_ii;

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS ids_ii.non_contact_finance_registry (
    id INT NOT NULL,
    registry_record_id STRING NOT NULL,
    client_internal_id STRING NOT NULL,
    masreph_customer_number STRING NOT NULL,
    client_segment_code STRING,
    client_residence_country_code STRING NOT NULL,
    primary_mobile_channel_id STRING,
    preferred_contact_language_code STRING,
    online_bank_enrollment_date DATE,
    first_non_contact_txn_date DATE,
    last_non_contact_txn_timestamp TIMESTAMP,
    non_contact_txn_count_12m INT NOT NULL,
    non_contact_txn_volume_12m DECIMAL(15,2) NOT NULL,
    avg_non_contact_txn_value_12m DECIMAL(15,2),
    non_contact_txn_decline_rate_12m DECIMAL(5,2),
    active_non_contact_account_count INT NOT NULL,
    primary_non_contact_account_iban STRING,
    mobility_product_type STRING,
    mobility_contract_id STRING,
    mobility_usage_pattern MAP<STRING, STRING>,
    relationship_manager_id STRING,
    relationship_tenure_months INT NOT NULL,
    client_profitability_score DECIMAL(6,2),
    client_profitability_band STRING,
    digital_engagement_score DECIMAL(5,2),
    churn_risk_flag BOOLEAN NOT NULL,
    gdpr_consent_flag BOOLEAN NOT NULL,
    gdpr_consent_last_updated TIMESTAMP,
    kyc_status_code STRING NOT NULL,
    risk_rating_internal INT,
    last_kyc_review_date DATE,
    preferred_mobility_service_region STRING,
    last_login_channel STRING,
    last_login_timestamp TIMESTAMP,
    device_fingerprint_hash STRING,
    payment_tokenization_status STRING NOT NULL,
    recurring_payment_profile_count INT NOT NULL,
    recurring_payment_profiles ARRAY<STRING>,
    client_value_tier_change_timestamp TIMESTAMP,
    marketing_opt_in_channels ARRAY<STRING>,
    data_source_system_code STRING NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_update_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_non_contact_finance_ PRIMARY KEY (id)
);


