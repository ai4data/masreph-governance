-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: microsoft_dynamics_365
-- Generated: 2026-03-18T12:18:16.846834
-- Datasets: 3
-- ============================================

-- Dataset: GDS37184
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.finance_crm_insights (
    id INT NOT NULL,
    dataset_record_id STRING NOT NULL,
    client_id STRING NOT NULL,
    client_legacy_reference STRING,
    client_name STRING NOT NULL,
    client_type STRING NOT NULL,
    primary_tax_id_hashed STRING,
    country_of_domicile STRING NOT NULL,
    domicile_region STRING NOT NULL,
    industry_sector STRING,
    relationship_manager_id STRING,
    relationship_manager_name STRING,
    client_onboarding_date DATE NOT NULL,
    first_leasing_contract_date DATE,
    last_contact_timestamp TIMESTAMP,
    preferred_contact_channel STRING,
    contact_opt_in_email_flag BOOLEAN NOT NULL,
    contact_opt_in_phone_flag BOOLEAN NOT NULL,
    contact_opt_in_post_flag BOOLEAN NOT NULL,
    gdpr_consent_status STRING NOT NULL,
    kyc_review_status STRING NOT NULL,
    kyc_last_review_date DATE,
    risk_rating_internal INT,
    credit_limit_leasing_total DECIMAL(18,2),
    outstanding_leasing_balance DECIMAL(18,2),
    average_lease_yield_pct DECIMAL(5,2),
    client_profitability_score INT,
    client_profitability_segment STRING,
    annual_revenue_estimated DECIMAL(18,2),
    cross_sell_opportunity_score INT,
    churn_risk_score INT,
    lease_contracts_active_count INT,
    lease_contracts_lifetime_count INT,
    last_marketing_campaign_name STRING,
    last_marketing_campaign_response STRING,
    next_best_action_code STRING,
    next_best_action_effective_date DATE,
    client_tier STRING,
    relationship_tenure_years DECIMAL(5,2),
    data_source_system STRING NOT NULL,
    record_archived_flag BOOLEAN NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_crm_insights PRIMARY KEY (id)
);


-- Dataset: GDS37860
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.finance_crm_insights (
    id INT NOT NULL,
    dataset_record_id STRING NOT NULL,
    client_id STRING NOT NULL,
    leasing_account_id STRING,
    relationship_manager_id STRING,
    client_legal_name STRING NOT NULL,
    client_segment STRING NOT NULL,
    industry_code_naics STRING,
    country_of_risk STRING NOT NULL,
    domicile_country STRING NOT NULL,
    client_inception_date DATE NOT NULL,
    relationship_start_date DATE,
    relationship_end_date DATE,
    relationship_status STRING NOT NULL,
    is_key_account BOOLEAN NOT NULL,
    annual_lease_revenue_local DECIMAL(15,2),
    annual_lease_revenue_usd DECIMAL(15,2),
    total_outstanding_leases_count INT NOT NULL,
    total_outstanding_exposure_local DECIMAL(18,2),
    total_outstanding_exposure_usd DECIMAL(18,2),
    average_lease_tenor_months INT,
    profitability_score DECIMAL(5,2),
    last_profitability_review_date DATE,
    contact_email_primary STRING,
    preferred_contact_channel STRING,
    last_interaction_timestamp TIMESTAMP,
    last_interaction_type STRING,
    last_interaction_outcome STRING,
    interaction_frequency_rolling_12m INT,
    churn_risk_flag BOOLEAN,
    churn_risk_score DECIMAL(5,2),
    cross_sell_opportunity_flag BOOLEAN,
    cross_sell_products_identified ARRAY<STRING>,
    client_satisfaction_score INT,
    client_satisfaction_last_updated DATE,
    kyc_review_status STRING,
    kyc_next_review_date DATE,
    compliance_risk_rating STRING,
    gdpr_consent_flag BOOLEAN,
    privacy_preferences MAP<STRING, STRING>,
    data_source_system STRING NOT NULL,
    record_effective_date DATE NOT NULL,
    record_expiry_date DATE,
    record_created_timestamp TIMESTAMP NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_crm_insights PRIMARY KEY (id)
);


-- Dataset: GDS98647
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_insight_finance_dataset (
    id INT NOT NULL,
    client_insight_id STRING NOT NULL,
    core_client_id STRING NOT NULL,
    client_type STRING NOT NULL,
    legal_entity_name STRING NOT NULL,
    client_segment_code STRING,
    primary_country_iso STRING NOT NULL,
    primary_relationship_manager_id STRING,
    primary_relationship_manager_name STRING,
    client_onboarding_date DATE NOT NULL,
    last_interaction_timestamp TIMESTAMP,
    preferred_contact_channel STRING,
    preferred_contact_language STRING,
    marketing_consent_flag BOOLEAN NOT NULL,
    marketing_consent_last_updated DATE,
    gdpr_data_processing_basis STRING,
    total_active_leases_count INT NOT NULL,
    outstanding_lease_exposure_eur DECIMAL(18,2) NOT NULL,
    average_lease_margin_bps DECIMAL(7,2),
    rolling_12m_lease_revenue_eur DECIMAL(18,2),
    client_profitability_score DECIMAL(5,2),
    credit_risk_rating_internal STRING,
    payment_behavior_index DECIMAL(4,2),
    average_days_past_due INT,
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    next_best_offer_category STRING,
    client_lifecycle_stage STRING,
    key_decision_maker_title STRING,
    industry_sector_nace_code STRING,
    annual_turnover_eur DECIMAL(18,2),
    contact_email_hashed STRING,
    primary_contact_phone_hashed STRING,
    client_record_status STRING NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_client_insight_finan PRIMARY KEY (id)
);


