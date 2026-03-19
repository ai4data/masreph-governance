-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: sf_crm_a
-- Generated: 2026-03-18T12:17:47.446815
-- Datasets: 4
-- ============================================

-- Dataset: GDS36744
CREATE SCHEMA IF NOT EXISTS sf_crm_a;

-- Core clearing firm client master with operational, risk, profitability, and relationship attributes.
CREATE TABLE IF NOT EXISTS sf_crm_a.clearing_firm_clients (
    clearing_firm_client_id VARCHAR(255) NOT NULL,
    third_settlement_party_id VARCHAR(255) NOT NULL,
    client_legal_name VARCHAR(255) NOT NULL,
    client_short_name VARCHAR(255),
    client_segment VARCHAR(255) NOT NULL,
    client_industry_sector VARCHAR(255),
    client_domicile_country_code VARCHAR(255) NOT NULL,
    client_onboarding_date DATE NOT NULL,
    client_risk_rating VARCHAR(255) NOT NULL,
    risk_rating_last_review_date DATE,
    relationship_manager_id VARCHAR(255) NOT NULL,
    primary_contact_encrypted_email VARCHAR(255),
    primary_contact_encrypted_phone VARCHAR(255),
    gdpr_consent_flag BOOLEAN NOT NULL,
    gdpr_consent_last_updated_ts TIMESTAMPTZ,
    kyc_completion_status VARCHAR(255) NOT NULL,
    kyc_last_review_date DATE,
    aml_risk_score NUMERIC(18,4) NOT NULL,
    aml_monitoring_status VARCHAR(255) NOT NULL,
    lease_portfolio_outstanding_balance_eur NUMERIC(18,4) NOT NULL,
    lease_portfolio_count_active INTEGER NOT NULL,
    avg_monthly_clearing_transaction_volume INTEGER NOT NULL,
    avg_monthly_clearing_transaction_value_eur NUMERIC(18,4) NOT NULL,
    last_12m_settlement_failure_rate_pct NUMERIC(18,4) NOT NULL,
    last_12m_disputed_transaction_rate_pct NUMERIC(18,4) NOT NULL,
    client_profitability_score NUMERIC(18,4) NOT NULL,
    trailing_12m_net_revenue_eur NUMERIC(18,4) NOT NULL,
    trailing_12m_operational_cost_eur NUMERIC(18,4) NOT NULL,
    trailing_12m_roi_pct NUMERIC(18,4) NOT NULL,
    preferred_communication_channel VARCHAR(255),
    client_lifecycle_stage VARCHAR(255) NOT NULL,
    service_level_tier VARCHAR(255) NOT NULL,
    credit_limit_eur NUMERIC(18,4) NOT NULL,
    credit_limit_utilization_pct NUMERIC(18,4) NOT NULL,
    margin_requirement_eur NUMERIC(18,4),
    margin_call_last_date DATE,
    cross_border_activity_flag BOOLEAN NOT NULL,
    eu_gdpr_data_retention_expiry_date DATE,
    data_sharing_opt_out_flag BOOLEAN NOT NULL,
    real_time_streaming_enabled_flag BOOLEAN NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    next_scheduled_review_date DATE,
    churn_risk_score NUMERIC(18,4) NOT NULL,
    notes_redacted_summary VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clearing_firm_client PRIMARY KEY (clearing_firm_client_id)
);

-- External third-party settlement entities associated with clearing firm clients.
CREATE TABLE IF NOT EXISTS sf_crm_a.third_settlement_parties (
    third_settlement_party_id VARCHAR(255) NOT NULL,
    legal_entity_identifier VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_third_settlement_par PRIMARY KEY (third_settlement_party_id)
);

-- Primary relationship managers responsible for clearing firm clients.
CREATE TABLE IF NOT EXISTS sf_crm_a.relationship_managers (
    relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_manager_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

ALTER TABLE sf_crm_a.clearing_firm_clients ADD CONSTRAINT FK_clearing_firm_clients_relat
    FOREIGN KEY (relationship_manager_id) REFERENCES sf_crm_a.relationship_managers (relationship_manager_id);

ALTER TABLE sf_crm_a.clearing_firm_clients ADD CONSTRAINT FK_clearing_firm_clients_third
    FOREIGN KEY (third_settlement_party_id) REFERENCES sf_crm_a.third_settlement_parties (third_settlement_party_id);


-- Dataset: GDS83631
CREATE SCHEMA IF NOT EXISTS sf_crm_a;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS sf_crm_a.clearing_firm_data_insights (
    id INTEGER NOT NULL,
    clearing_firm_id UUID NOT NULL,
    clearing_firm_legal_name VARCHAR(255) NOT NULL,
    clearing_firm_short_name VARCHAR(255),
    clearing_firm_internal_code VARCHAR(255) NOT NULL,
    global_legal_entity_identifier VARCHAR(255),
    country_of_incorporation VARCHAR(255) NOT NULL,
    primary_operating_region VARCHAR(255) NOT NULL,
    regulatory_registration_number VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    relationship_status VARCHAR(255) NOT NULL,
    kyc_completion_date DATE,
    kyc_review_next_due_date DATE,
    risk_rating_internal VARCHAR(255) NOT NULL,
    credit_limit_approved_amount NUMERIC(18,2),
    credit_limit_currency VARCHAR(255),
    annual_leasing_transaction_volume NUMERIC(20,2),
    annual_leasing_transaction_count INTEGER,
    net_revenue_ytd NUMERIC(20,2),
    direct_cost_ytd NUMERIC(20,2),
    contribution_margin_ytd NUMERIC(20,2),
    relationship_manager_id VARCHAR(255),
    relationship_segment VARCHAR(255),
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    preferred_communication_channel VARCHAR(320),
    service_level_tier VARCHAR(255),
    is_revenue_share_agreement BOOLEAN NOT NULL,
    revenue_share_percentage NUMERIC(5,2),
    cross_sell_opportunity_score NUMERIC(5,2),
    last_interaction_timestamp TIMESTAMPTZ,
    interaction_frequency_90d INTEGER,
    sentiment_score_90d NUMERIC(4,2),
    operational_incident_count_12m INTEGER,
    average_settlement_latency_seconds NUMERIC(10,2),
    data_privacy_region VARCHAR(255),
    gdp_sensitive_indicator BOOLEAN NOT NULL,
    streaming_data_subscription_flag BOOLEAN NOT NULL,
    last_stream_event_timestamp TIMESTAMPTZ,
    preferred_settlement_currency VARCHAR(255),
    clearing_bank_swift_bic VARCHAR(11),
    data_record_last_updated TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_clearing_firm_data_i PRIMARY KEY (id)
);


-- Dataset: GDS83650
CREATE SCHEMA IF NOT EXISTS sf_crm_a;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS sf_crm_a.clearing_firm_data_insights (
    id INTEGER NOT NULL,
    clearing_firm_id VARCHAR(255) NOT NULL,
    clearing_firm_legal_name VARCHAR(255) NOT NULL,
    clearing_firm_short_name VARCHAR(255),
    global_lei VARCHAR(255),
    swift_bic VARCHAR(255),
    domicile_country_code VARCHAR(255) NOT NULL,
    regulatory_region_code VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    relationship_start_date DATE,
    relationship_status VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    relationship_tier VARCHAR(255),
    leasing_business_segment VARCHAR(255),
    primary_settlement_currency VARCHAR(255) NOT NULL,
    active_leasing_contract_count INTEGER NOT NULL,
    total_outstanding_leasing_balance NUMERIC(18,2) NOT NULL,
    avg_leasing_contract_margin_pct NUMERIC(5,2),
    ytd_leasing_revenue NUMERIC(18,2) NOT NULL,
    ytd_clearing_fees NUMERIC(18,2) NOT NULL,
    ytd_other_fee_income NUMERIC(18,2),
    last_12m_write_off_amount NUMERIC(18,2),
    credit_risk_rating VARCHAR(255),
    credit_limit_amount NUMERIC(18,2),
    credit_limit_utilization_pct NUMERIC(5,2),
    kyc_completed_flag BOOLEAN NOT NULL,
    last_kyc_review_date DATE,
    aml_risk_category VARCHAR(255),
    gdpr_consent_flag BOOLEAN,
    data_sharing_restriction_level VARCHAR(255),
    preferred_contact_channel VARCHAR(320),
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    last_client_interaction_timestamp TIMESTAMPTZ,
    last_client_interaction_channel VARCHAR(320),
    client_satisfaction_score NUMERIC(4,2),
    cross_sell_opportunity_score NUMERIC(5,2),
    churn_risk_score NUMERIC(5,2),
    profitability_segment VARCHAR(255),
    ytd_profit_before_tax NUMERIC(18,2),
    rolling_12m_roe_pct NUMERIC(6,3),
    average_settlement_latency_seconds NUMERIC(10,3),
    settlement_failure_rate_pct NUMERIC(5,2),
    dispute_case_open_count INTEGER NOT NULL,
    dispute_case_rolling_12m_count INTEGER NOT NULL,
    data_record_source_system VARCHAR(255) NOT NULL,
    data_record_created_timestamp TIMESTAMPTZ NOT NULL,
    data_record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    is_record_active BOOLEAN NOT NULL,
    reporting_fiscal_year INTEGER NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_clearing_firm_data_i PRIMARY KEY (id)
);


-- Dataset: GDS93504
CREATE SCHEMA IF NOT EXISTS sf_crm_a;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS sf_crm_a.clearing_firm_data_insights (
    id INTEGER NOT NULL,
    clearing_firm_id UUID NOT NULL,
    clearing_firm_legal_name VARCHAR(255) NOT NULL,
    clearing_firm_lei VARCHAR(255),
    clearing_firm_external_reference VARCHAR(255),
    parent_institution_id VARCHAR(255),
    primary_region_code VARCHAR(255) NOT NULL,
    domicile_country_code VARCHAR(255) NOT NULL,
    onboarding_date DATE NOT NULL,
    offboarding_date DATE,
    relationship_status VARCHAR(255) NOT NULL,
    primary_relationship_manager_id VARCHAR(255),
    client_risk_rating VARCHAR(255),
    sanctions_screening_status VARCHAR(255) NOT NULL,
    gdp_gdpr_compliance_flag BOOLEAN NOT NULL,
    kyc_last_review_date DATE,
    kyc_next_review_date DATE,
    client_segment_code VARCHAR(255),
    preferred_communication_channel VARCHAR(320),
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    service_level_tier VARCHAR(255),
    service_level_breach_count_12m INTEGER NOT NULL,
    active_leasing_contracts_count INTEGER NOT NULL,
    annual_settlement_volume_amount NUMERIC(18,2) NOT NULL,
    annual_settlement_volume_currency VARCHAR(255) NOT NULL,
    net_revenue_12m_amount NUMERIC(18,2) NOT NULL,
    direct_costs_12m_amount NUMERIC(18,2) NOT NULL,
    contribution_margin_12m_amount NUMERIC(18,2) NOT NULL,
    return_on_allocated_capital_pct NUMERIC(5,2),
    allocated_economic_capital_amount NUMERIC(18,2),
    average_settlement_latency_seconds NUMERIC(10,3),
    real_time_connectivity_flag BOOLEAN NOT NULL,
    streaming_channel_identifier VARCHAR(255),
    last_stream_heartbeat_timestamp TIMESTAMPTZ,
    crm_account_id VARCHAR(255),
    last_relationship_interaction_timestamp TIMESTAMPTZ,
    open_opportunity_count INTEGER NOT NULL,
    pipeline_12m_expected_revenue_amount NUMERIC(18,2),
    client_profitability_category VARCHAR(255),
    dispute_rate_bps_12m NUMERIC(7,3),
    average_collection_period_days NUMERIC(6,2),
    data_privacy_profile VARCHAR(255),
    sensitive_data_masking_flag BOOLEAN NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_clearing_firm_data_i PRIMARY KEY (id)
);


