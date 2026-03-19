-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: none
-- Generated: 2026-03-18T12:17:47.448824
-- Datasets: 1
-- ============================================

-- Dataset: GDS65243
CREATE SCHEMA IF NOT EXISTS none;

-- Reference data for retail client segments, including code and business description.
CREATE TABLE IF NOT EXISTS none.client_segments (
    client_segment_id INTEGER NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    client_segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_segments PRIMARY KEY (client_segment_id)
);

-- Core master data for retail clients in the Masreph consumer finance CRM.
CREATE TABLE IF NOT EXISTS none.retail_clients (
    client_id VARCHAR(255) NOT NULL,
    client_masreph_party_number VARCHAR(255) NOT NULL,
    client_segment_id INTEGER NOT NULL,
    primary_relationship_manager_id VARCHAR(255),
    relationship_start_date DATE NOT NULL,
    relationship_status VARCHAR(255) NOT NULL,
    country_of_residence_code VARCHAR(255) NOT NULL,
    primary_branch_code VARCHAR(255),
    primary_language_code VARCHAR(255),
    primary_product_group VARCHAR(255),
    client_lifecycle_stage VARCHAR(255) NOT NULL,
    crm_relationship_tier VARCHAR(255),
    annual_income_band_code VARCHAR(255),
    employment_status_code VARCHAR(255),
    primary_iban_masked VARCHAR(255),
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_clients PRIMARY KEY (client_id)
);

-- Risk rating and KYC status information for each retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_risk_kyc (
    client_id VARCHAR(255) NOT NULL,
    client_risk_rating VARCHAR(255),
    kyc_completion_status VARCHAR(255) NOT NULL,
    kyc_last_review_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_risk_k PRIMARY KEY (client_id)
);

-- Aggregated financial exposure and profitability metrics per retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_financials (
    client_id VARCHAR(255) NOT NULL,
    total_outstanding_balance NUMERIC(18,4) NOT NULL,
    total_deposit_balance NUMERIC(18,4),
    net_interest_income_ytd NUMERIC(18,4),
    fee_income_ytd NUMERIC(18,4),
    cost_to_serve_ytd NUMERIC(18,4),
    client_profit_contribution_ytd NUMERIC(18,4),
    number_of_active_products INTEGER NOT NULL,
    last_product_open_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_financ PRIMARY KEY (client_id)
);

-- Predictive and behavioral analytics scores for each retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_analytics (
    client_id VARCHAR(255) NOT NULL,
    cross_sell_score NUMERIC(18,4),
    churn_risk_score NUMERIC(18,4),
    digital_engagement_index INTEGER,
    last_login_timestamp TIMESTAMPTZ,
    lifetime_value_score NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_analyt PRIMARY KEY (client_id)
);

-- Marketing and relationship preferences per retail client, including preferred channels and next best
CREATE TABLE IF NOT EXISTS none.retail_client_marketing_preferences (
    client_id VARCHAR(255) NOT NULL,
    preferred_communication_channel VARCHAR(255),
    next_best_action_code VARCHAR(255),
    next_best_action_valid_to_date DATE,
    marketing_segment_tags JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_market PRIMARY KEY (client_id)
);

-- GDPR and communication consent settings for each retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_consents (
    client_id VARCHAR(255) NOT NULL,
    communication_opt_in_flag BOOLEAN NOT NULL,
    gdpr_consent_last_updated_ts TIMESTAMPTZ,
    consent_for_profiling_flag BOOLEAN NOT NULL,
    data_minimization_exclusion_flag BOOLEAN NOT NULL,
    do_not_contact_reasons JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_consen PRIMARY KEY (client_id)
);

-- Summary of recent contact activity and last interaction details for each retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_contact_stats (
    client_id VARCHAR(255) NOT NULL,
    last_contact_channel VARCHAR(255),
    last_contact_timestamp TIMESTAMPTZ,
    last_contact_outcome_code VARCHAR(255),
    client_contact_summary JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_contac PRIMARY KEY (client_id)
);

-- Complaint-related indicators and satisfaction scores per retail client.
CREATE TABLE IF NOT EXISTS none.retail_client_complaint_stats (
    client_id VARCHAR(255) NOT NULL,
    complaint_indicator_flag BOOLEAN NOT NULL,
    open_complaints_count INTEGER NOT NULL,
    client_satisfaction_index INTEGER,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_retail_client_compla PRIMARY KEY (client_id)
);

ALTER TABLE none.retail_clients ADD CONSTRAINT FK_retail_clients_client_segme
    FOREIGN KEY (client_segment_id) REFERENCES none.client_segments (client_segment_id);

ALTER TABLE none.retail_client_risk_kyc ADD CONSTRAINT FK_retail_client_risk_kyc_clie
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_financials ADD CONSTRAINT FK_retail_client_financials_cl
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_analytics ADD CONSTRAINT FK_retail_client_analytics_cli
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_marketing_preferences ADD CONSTRAINT FK_retail_client_marketing_pre
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_consents ADD CONSTRAINT FK_retail_client_consents_clie
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_contact_stats ADD CONSTRAINT FK_retail_client_contact_stats
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);

ALTER TABLE none.retail_client_complaint_stats ADD CONSTRAINT FK_retail_client_complaint_sta
    FOREIGN KEY (client_id) REFERENCES none.retail_clients (client_id);


