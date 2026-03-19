-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: customer_care
-- Generated: 2026-03-18T12:17:47.439821
-- Datasets: 6
-- ============================================

-- Dataset: GDS31985
CREATE SCHEMA IF NOT EXISTS customer_care;

-- Core client entity representing an individual private finance client within the mobility finance dom
CREATE TABLE IF NOT EXISTS customer_care.clients (
    client_id VARCHAR(255) NOT NULL,
    external_crm_client_ref VARCHAR(255),
    client_residency_country_code VARCHAR(255) NOT NULL,
    client_birth_date DATE,
    client_onboarding_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Time-variant snapshot of a client's mobility finance relationship, exposures, consents, risk and pro
CREATE TABLE IF NOT EXISTS customer_care.client_mobility_snapshots (
    client_mobility_snapshot_id INTEGER NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    primary_contact_email VARCHAR(255),
    primary_contact_mobile_number VARCHAR(255),
    consent_gdpr_marketing BOOLEAN NOT NULL,
    consent_telematics_data_sharing BOOLEAN NOT NULL,
    preferred_mobility_channel VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    relationship_status_code VARCHAR(255) NOT NULL,
    first_auto_loan_start_date DATE,
    latest_auto_loan_maturity_date DATE,
    active_auto_loan_count INTEGER NOT NULL,
    total_auto_loan_principal_outstanding NUMERIC(18,4) NOT NULL,
    total_mobility_credit_limit NUMERIC(18,4),
    average_monthly_mobility_spend_12m NUMERIC(18,4),
    lifetime_mobility_revenue NUMERIC(18,4),
    client_profitability_score INTEGER,
    risk_rating_internal VARCHAR(255),
    payment_behavior_score INTEGER,
    default_history_flag BOOLEAN NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    last_contact_channel VARCHAR(255),
    next_planned_contact_date DATE,
    mobility_infrastructure_partner_id VARCHAR(255),
    vehicle_usage_profile JSONB,
    mobility_service_subscriptions JSONB,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_effective_date DATE NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_mobility_snap PRIMARY KEY (client_mobility_snapshot_id)
);

ALTER TABLE customer_care.client_mobility_snapshots ADD CONSTRAINT FK_client_mobility_snapshots_c
    FOREIGN KEY (client_id) REFERENCES customer_care.clients (client_id);


-- Dataset: GDS41310
CREATE SCHEMA IF NOT EXISTS customer_care;

-- Core private finance client entity with identity, regulatory, relationship, and archive metadata.
CREATE TABLE IF NOT EXISTS customer_care.private_finance_clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_client_reference VARCHAR(255) NOT NULL,
    crm_account_id VARCHAR(255),
    national_client_identifier VARCHAR(255),
    customer_type VARCHAR(255) NOT NULL,
    residency_country_code VARCHAR(255) NOT NULL,
    primary_language_code VARCHAR(255),
    date_of_birth DATE,
    onboarding_date DATE NOT NULL,
    relationship_manager_id VARCHAR(255),
    relationship_segment_code VARCHAR(255),
    mobility_customer_flag BOOLEAN NOT NULL,
    auto_loan_relationship_flag BOOLEAN NOT NULL,
    primary_vehicle_usage_type VARCHAR(255),
    preferred_mobility_city VARCHAR(255),
    source_system_code VARCHAR(255) NOT NULL,
    record_created_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_private_finance_clie PRIMARY KEY (client_id)
);

-- Contact preferences, interaction metadata, and hashed contact identifiers for private finance client
CREATE TABLE IF NOT EXISTS customer_care.private_finance_client_contacts (
    client_id VARCHAR(255) NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    preferred_contact_channel VARCHAR(255),
    email_address_hash VARCHAR(255),
    mobile_phone_hash VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_private_finance_clie PRIMARY KEY (client_id)
);

-- Marketing, data sharing, and GDPR-related consent and erasure information for private finance client
CREATE TABLE IF NOT EXISTS customer_care.private_finance_client_consents (
    client_id VARCHAR(255) NOT NULL,
    consent_marketing_flag BOOLEAN NOT NULL,
    consent_data_sharing_flag BOOLEAN NOT NULL,
    consent_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    gdpr_erasure_requested_flag BOOLEAN NOT NULL,
    gdpr_erasure_effective_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_private_finance_clie PRIMARY KEY (client_id)
);

-- KYC status, risk scores, arrears, write-off, and churn propensity metrics for private finance client
CREATE TABLE IF NOT EXISTS customer_care.private_finance_client_kyc_risks (
    client_id VARCHAR(255) NOT NULL,
    kyc_completion_status VARCHAR(255) NOT NULL,
    kyc_review_date DATE,
    risk_profile_score NUMERIC(18,4),
    risk_profile_band VARCHAR(255),
    payment_behavior_score NUMERIC(18,4),
    arrears_last_12m_count INTEGER,
    write_off_indicator BOOLEAN NOT NULL,
    write_off_date DATE,
    churn_propensity_score NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_private_finance_clie PRIMARY KEY (client_id)
);

-- Aggregated financial exposure, profitability, utilization, and product metrics for private finance c
CREATE TABLE IF NOT EXISTS customer_care.private_finance_client_financials (
    client_id VARCHAR(255) NOT NULL,
    client_profitability_score NUMERIC(18,4),
    lifetime_value_eur NUMERIC(18,4),
    current_auto_loan_balance_eur NUMERIC(18,4),
    current_auto_lease_balance_eur NUMERIC(18,4),
    total_outstanding_balance_eur NUMERIC(18,4),
    avg_monthly_txn_volume_eur NUMERIC(18,4),
    avg_monthly_auto_payment_eur NUMERIC(18,4),
    mobility_product_count INTEGER NOT NULL,
    active_contracts_count INTEGER NOT NULL,
    last_mobility_product_start_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_private_finance_clie PRIMARY KEY (client_id)
);

ALTER TABLE customer_care.private_finance_client_contacts ADD CONSTRAINT FK_private_finance_client_cont
    FOREIGN KEY (client_id) REFERENCES customer_care.private_finance_clients (client_id);

ALTER TABLE customer_care.private_finance_client_consents ADD CONSTRAINT FK_private_finance_client_cons
    FOREIGN KEY (client_id) REFERENCES customer_care.private_finance_clients (client_id);

ALTER TABLE customer_care.private_finance_client_kyc_risks ADD CONSTRAINT FK_private_finance_client_kyc_
    FOREIGN KEY (client_id) REFERENCES customer_care.private_finance_clients (client_id);

ALTER TABLE customer_care.private_finance_client_financials ADD CONSTRAINT FK_private_finance_client_fina
    FOREIGN KEY (client_id) REFERENCES customer_care.private_finance_clients (client_id);


-- Dataset: GDS46057
CREATE SCHEMA IF NOT EXISTS customer_care;

-- Master data for relationship managers responsible for mobility finance client relationships, includi
CREATE TABLE IF NOT EXISTS customer_care.relationship_managers (
    relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_manager_region_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

-- Core client entity and current mobility finance relationship snapshot for private clients in the Mas
CREATE TABLE IF NOT EXISTS customer_care.clients (
    client_entity_id VARCHAR(255) NOT NULL,
    external_crm_client_id VARCHAR(255),
    client_global_party_id VARCHAR(255) NOT NULL,
    client_type_code VARCHAR(255) NOT NULL,
    primary_country_of_residence VARCHAR(255) NOT NULL,
    preferred_communication_language VARCHAR(255),
    client_segment_code VARCHAR(255),
    client_risk_rating VARCHAR(255),
    mobility_relationship_start_date DATE NOT NULL,
    mobility_relationship_status VARCHAR(255) NOT NULL,
    relationship_status_effective_timestamp TIMESTAMPTZ NOT NULL,
    primary_mobility_product_type VARCHAR(255),
    active_mobility_product_count INTEGER NOT NULL,
    total_outstanding_mobility_balance NUMERIC(18,4) NOT NULL,
    twelve_month_mobility_revenue NUMERIC(18,4),
    twelve_month_mobility_cost_to_serve NUMERIC(18,4),
    twelve_month_mobility_profit NUMERIC(18,4),
    lifetime_mobility_revenue NUMERIC(18,4),
    lifetime_mobility_profit NUMERIC(18,4),
    relationship_profitability_band VARCHAR(255),
    primary_relationship_manager_id VARCHAR(255),
    client_preferred_contact_channel VARCHAR(255),
    client_marketing_consent_flag BOOLEAN NOT NULL,
    client_data_processing_consent_timestamp TIMESTAMPTZ,
    client_kafka_stream_key VARCHAR(255) NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    last_interaction_channel VARCHAR(255),
    last_interaction_outcome_code VARCHAR(255),
    open_service_case_count INTEGER NOT NULL,
    client_default_history_flag BOOLEAN NOT NULL,
    latest_mobility_dpd_bucket VARCHAR(255),
    annual_personal_net_income_band VARCHAR(255),
    primary_employment_status VARCHAR(255),
    primary_vehicle_usage_type VARCHAR(255),
    active_geolocation_consent_flag BOOLEAN NOT NULL,
    mobility_app_enrollment_flag BOOLEAN NOT NULL,
    mobility_app_last_login_timestamp TIMESTAMPTZ,
    client_primary_email_hash VARCHAR(255),
    client_primary_msisdn_hash VARCHAR(255),
    client_home_postal_code VARCHAR(255),
    client_lifecycle_stage VARCHAR(255),
    client_behavioral_cluster_id VARCHAR(255),
    client_relationship_metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_entity_id)
);

ALTER TABLE customer_care.clients ADD CONSTRAINT FK_clients_primary_relationshi
    FOREIGN KEY (primary_relationship_manager_id) REFERENCES customer_care.relationship_managers (relationship_manager_id);


-- Dataset: GDS73539
CREATE SCHEMA IF NOT EXISTS customer_care;

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS customer_care.wealth_record_archive_dataset (
    id INTEGER NOT NULL,
    wealth_record_id VARCHAR(255) NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    household_id VARCHAR(255),
    client_global_uuid UUID NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    client_full_name VARCHAR(255) NOT NULL,
    primary_country_of_residence VARCHAR(255) NOT NULL,
    client_date_of_birth DATE NOT NULL,
    client_onboarding_date DATE NOT NULL,
    client_risk_profile_code VARCHAR(255),
    client_risk_profile_last_review_ts TIMESTAMPTZ,
    primary_relationship_manager_id VARCHAR(255),
    primary_relationship_manager_name VARCHAR(255),
    mobility_client_flag BOOLEAN NOT NULL,
    primary_mobility_product_type VARCHAR(255),
    active_auto_loan_count INTEGER NOT NULL,
    total_auto_loan_outstanding_balance_eur NUMERIC(18,2) NOT NULL,
    total_investment_portfolio_value_eur NUMERIC(20,2),
    total_deposit_balance_eur NUMERIC(20,2),
    total_liabilities_balance_eur NUMERIC(20,2),
    net_worth_eur NUMERIC(21,2),
    net_worth_effective_date DATE,
    wealth_tier_code VARCHAR(255),
    profitability_rolling_12m_eur NUMERIC(18,2),
    revenue_rolling_12m_eur NUMERIC(18,2),
    cost_to_serve_rolling_12m_eur NUMERIC(18,2),
    relationship_tenure_years INTEGER NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    preferred_contact_channel VARCHAR(255),
    consent_personal_data_processing_flag BOOLEAN NOT NULL,
    consent_marketing_communications_flag BOOLEAN NOT NULL,
    gdpr_data_processing_basis VARCHAR(255) NOT NULL,
    pep_status_flag BOOLEAN,
    tax_residency_country_code VARCHAR(255),
    last_kyc_review_date DATE,
    kyc_status_code VARCHAR(255),
    data_quality_score NUMERIC(5,2),
    record_source_system VARCHAR(255) NOT NULL,
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_update_timestamp TIMESTAMPTZ,
    archive_record_version_number INTEGER NOT NULL,
    is_current_active_profile_flag BOOLEAN NOT NULL,
    primary_contact_email VARCHAR(320),
    primary_contact_mobile_number VARCHAR(255),
    comments_relationship_strategy VARCHAR(255),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_wealth_record_archiv PRIMARY KEY (id)
);


-- Dataset: GDS77519
CREATE SCHEMA IF NOT EXISTS customer_care;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS customer_care.corporate_finance_records_archive (
    id INTEGER NOT NULL,
    client_entity_id UUID NOT NULL,
    client_legal_name VARCHAR(255) NOT NULL,
    client_commercial_name VARCHAR(255),
    client_country_of_registration VARCHAR(255) NOT NULL,
    client_lei_code VARCHAR(255),
    client_industry_sector_code VARCHAR(255) NOT NULL,
    client_size_segment VARCHAR(255) NOT NULL,
    client_group_id VARCHAR(255),
    ultimate_parent_name VARCHAR(255),
    preferred_relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_start_date DATE NOT NULL,
    relationship_status VARCHAR(255) NOT NULL,
    kyc_completion_date DATE,
    kyc_risk_rating VARCHAR(255),
    primary_contact_person_name VARCHAR(255),
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    client_preferred_language VARCHAR(255),
    client_profitability_score NUMERIC(5,2),
    rolling_12m_revenue_eur NUMERIC(18,2),
    rolling_12m_leasing_margin_eur NUMERIC(18,2),
    total_outstanding_leasing_exposure_eur NUMERIC(18,2),
    avg_transaction_size_eur NUMERIC(18,2),
    last_transaction_timestamp TIMESTAMPTZ,
    last_interaction_timestamp TIMESTAMPTZ,
    interaction_channel_last_used VARCHAR(320),
    strategic_relationship_flag BOOLEAN NOT NULL,
    cross_sell_potential_score NUMERIC(5,2),
    lead_origin_source VARCHAR(255),
    primary_onboarding_channel VARCHAR(255),
    client_rating_internal VARCHAR(255),
    client_default_probability_1y NUMERIC(6,4),
    client_domicile_city VARCHAR(255),
    client_domicile_country VARCHAR(255),
    gdpr_processing_consent_flag BOOLEAN NOT NULL,
    marketing_opt_out_flag BOOLEAN NOT NULL,
    primary_currency_code VARCHAR(255),
    transaction_history_summary JSONB,
    key_products_used JSONB,
    m_and_a_activity_flag BOOLEAN NOT NULL,
    last_m_and_a_transaction_date DATE,
    avg_days_since_last_contact INTEGER,
    relationship_tier VARCHAR(255),
    annual_client_revenue_eur NUMERIC(18,2),
    employee_count INTEGER,
    client_lifecycle_stage VARCHAR(255) NOT NULL,
    relationship_termination_date DATE,
    data_privacy_restriction_level VARCHAR(255) NOT NULL,
    client_record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_corporate_finance_re PRIMARY KEY (id)
);


-- Dataset: GDS79707
CREATE SCHEMA IF NOT EXISTS customer_care;

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS customer_care.finance_record_archive (
    id INTEGER NOT NULL,
    finance_record_id UUID NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    core_banking_customer_id VARCHAR(255),
    external_crm_client_id VARCHAR(255),
    client_full_name VARCHAR(255) NOT NULL,
    client_residency_country_code VARCHAR(255) NOT NULL,
    domicile_region_code VARCHAR(255),
    client_segment_code VARCHAR(255) NOT NULL,
    client_risk_rating VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    client_contact_channel_preferences JSONB,
    consent_gdpr_marketing_flag BOOLEAN NOT NULL,
    consent_data_processing_timestamp TIMESTAMPTZ,
    client_onboarding_date DATE NOT NULL,
    client_exit_date DATE,
    client_status_code VARCHAR(255) NOT NULL,
    preferred_communication_channel VARCHAR(255),
    annual_gross_income_amount NUMERIC(15,2),
    total_outstanding_loan_balance NUMERIC(15,2) NOT NULL,
    total_deposit_balance_amount NUMERIC(15,2) NOT NULL,
    average_monthly_transaction_volume INTEGER,
    last_financial_review_date DATE,
    next_scheduled_review_date DATE,
    profitability_score NUMERIC(5,2),
    rolling_12m_revenue_amount NUMERIC(15,2),
    rolling_12m_cost_to_serve_amount NUMERIC(15,2),
    client_lifetime_value_amount NUMERIC(18,2),
    churn_risk_score NUMERIC(5,2),
    cross_sell_propensity_score NUMERIC(5,2),
    delinquency_flag BOOLEAN NOT NULL,
    pep_flag BOOLEAN NOT NULL,
    kyc_last_review_timestamp TIMESTAMPTZ,
    client_primary_branch_code VARCHAR(255),
    last_interaction_timestamp TIMESTAMPTZ,
    last_interaction_channel VARCHAR(255),
    complaint_indicator_flag BOOLEAN NOT NULL,
    client_demographic_profile JSONB,
    preferred_language_code VARCHAR(255),
    data_source_system_code VARCHAR(255) NOT NULL,
    record_ingestion_timestamp TIMESTAMPTZ NOT NULL,
    record_active_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_record_archi PRIMARY KEY (id)
);


