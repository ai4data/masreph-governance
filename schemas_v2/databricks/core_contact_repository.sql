-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: core_contact_repository
-- Generated: 2026-03-18T12:18:16.849602
-- Datasets: 1
-- ============================================

-- Dataset: GDS69106
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS core_contact_repository.finance_persona_data (
    id INT NOT NULL,
    client_id STRING NOT NULL,
    masreph_party_id STRING NOT NULL,
    external_crm_id STRING,
    national_id_hash STRING,
    customer_segment_code STRING NOT NULL,
    customer_segment_desc STRING,
    residence_country_code STRING NOT NULL,
    residence_country_name STRING,
    birth_date DATE,
    age_years INT,
    gender_code STRING,
    occupation_category STRING,
    employer_industry_code STRING,
    years_in_industry INT,
    annual_gross_income_amount DECIMAL(15,2),
    income_currency_code STRING,
    preferred_language_code STRING,
    risk_appetite_level STRING,
    leasing_relationship_start_date DATE,
    leasing_relationship_status STRING NOT NULL,
    primary_relationship_manager_id STRING,
    primary_relationship_manager_region STRING,
    total_active_leases_count INT NOT NULL,
    total_outstanding_leasing_balance DECIMAL(18,2) NOT NULL,
    avg_lease_ticket_size_amount DECIMAL(15,2),
    last_lease_start_date DATE,
    last_lease_end_date_expected DATE,
    last_contact_timestamp TIMESTAMP,
    last_contact_channel STRING,
    consent_marketing_flag BOOLEAN NOT NULL,
    consent_data_sharing_flag BOOLEAN NOT NULL,
    preferred_contact_channels STRING,
    email_contact_quality_score DECIMAL(5,2),
    mobile_phone_contact_quality_score DECIMAL(5,2),
    digital_engagement_score DECIMAL(6,2),
    onboarding_channel_code STRING,
    kyc_completion_status STRING NOT NULL,
    kyc_last_review_date DATE,
    credit_risk_grade STRING,
    churn_risk_score DECIMAL(5,4),
    profitability_12m_net_revenue DECIMAL(18,2),
    lifetime_value_estimate_amount DECIMAL(18,2),
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    gdpr_erasure_request_flag BOOLEAN NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_update_timestamp TIMESTAMP NOT NULL,
    data_source_system_code STRING NOT NULL,
    data_quality_issue_flag BOOLEAN NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_persona_data PRIMARY KEY (id)
);


