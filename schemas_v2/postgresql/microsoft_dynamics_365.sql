-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: microsoft_dynamics_365
-- Generated: 2026-03-18T12:17:47.432389
-- Datasets: 5
-- ============================================

-- Dataset: GDS17180
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- Client-level CRM insights and metrics for consumer finance customers.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.finance_crm_clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    crm_account_id VARCHAR(255) NOT NULL,
    residency_country_code VARCHAR(255) NOT NULL,
    gdpr_consent_flag BOOLEAN NOT NULL,
    marketing_opt_in_email_flag BOOLEAN NOT NULL,
    marketing_opt_in_sms_flag BOOLEAN NOT NULL,
    client_onboarding_date DATE NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    preferred_contact_channel VARCHAR(255),
    lifetime_value_eur NUMERIC(18,4),
    total_revenue_rolling_12m_eur NUMERIC(18,4),
    total_cost_rolling_12m_eur NUMERIC(18,4),
    profitability_score NUMERIC(18,4),
    churn_risk_score NUMERIC(18,4),
    cross_sell_propensity_score NUMERIC(18,4),
    current_product_count INTEGER NOT NULL,
    active_loan_count INTEGER NOT NULL,
    active_deposit_count INTEGER NOT NULL,
    delinquency_flag BOOLEAN NOT NULL,
    last_delinquency_date DATE,
    complaint_count_rolling_12m INTEGER NOT NULL,
    nps_latest_score INTEGER,
    digital_engagement_score NUMERIC(18,4),
    relationship_tenure_months INTEGER NOT NULL,
    household_size INTEGER,
    consent_capture_timestamp TIMESTAMPTZ,
    data_privacy_classification VARCHAR(255) NOT NULL,
    client_status_code VARCHAR(255) NOT NULL,
    crm_record_last_updated_ts TIMESTAMPTZ NOT NULL,
    customer_segment_id UUID,
    primary_relationship_manager_id UUID,
    primary_branch_id UUID,
    risk_rating_id UUID,
    income_band_id UUID,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_crm_clients PRIMARY KEY (client_id)
);

-- Reference data for customer marketing or risk segments used in CRM.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.customer_segments (
    customer_segment_id UUID NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    customer_segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_segments PRIMARY KEY (customer_segment_id)
);

-- Reference data for relationship managers responsible for clients.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.relationship_managers (
    relationship_manager_id UUID NOT NULL,
    rm_external_id VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

-- Reference data for primary branches associated with clients.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.branches (
    branch_id UUID NOT NULL,
    branch_external_id VARCHAR(255) NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_branches PRIMARY KEY (branch_id)
);

-- Reference data for internal credit risk ratings assigned to clients.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.risk_ratings (
    risk_rating_id UUID NOT NULL,
    risk_rating_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_risk_ratings PRIMARY KEY (risk_rating_id)
);

-- Reference data for client income band classifications.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.income_bands (
    income_band_id UUID NOT NULL,
    income_band_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_income_bands PRIMARY KEY (income_band_id)
);

ALTER TABLE microsoft_dynamics_365.finance_crm_clients ADD CONSTRAINT FK_finance_crm_clients_custome
    FOREIGN KEY (customer_segment_id) REFERENCES microsoft_dynamics_365.customer_segments (customer_segment_id);

ALTER TABLE microsoft_dynamics_365.finance_crm_clients ADD CONSTRAINT FK_finance_crm_clients_primary
    FOREIGN KEY (primary_relationship_manager_id) REFERENCES microsoft_dynamics_365.relationship_managers (relationship_manager_id);

ALTER TABLE microsoft_dynamics_365.finance_crm_clients ADD CONSTRAINT FK_finance_crm_clients_primary
    FOREIGN KEY (primary_branch_id) REFERENCES microsoft_dynamics_365.branches (branch_id);

ALTER TABLE microsoft_dynamics_365.finance_crm_clients ADD CONSTRAINT FK_finance_crm_clients_risk_ra
    FOREIGN KEY (risk_rating_id) REFERENCES microsoft_dynamics_365.risk_ratings (risk_rating_id);

ALTER TABLE microsoft_dynamics_365.finance_crm_clients ADD CONSTRAINT FK_finance_crm_clients_income_
    FOREIGN KEY (income_band_id) REFERENCES microsoft_dynamics_365.income_bands (income_band_id);


-- Dataset: GDS37418
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- Core client master data and profile attributes for the Masreph client insight platform.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_customer_number VARCHAR(255) NOT NULL,
    client_segment_id INTEGER,
    primary_country_of_residence VARCHAR(255) NOT NULL,
    client_onboarding_date DATE NOT NULL,
    last_relationship_review_date DATE,
    client_lifecycle_status VARCHAR(255) NOT NULL,
    preferred_communication_channel VARCHAR(255),
    email_address VARCHAR(255),
    mobile_phone_country_code VARCHAR(255),
    mobile_phone_number VARCHAR(255),
    client_preferred_contact_time_window VARCHAR(255),
    client_language_preference VARCHAR(255),
    household_id INTEGER,
    employment_status VARCHAR(255),
    primary_relationship_manager_id INTEGER,
    client_complaint_indicator BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Client-level consent flags for marketing communications and GDPR data processing.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_consents (
    client_id VARCHAR(255) NOT NULL,
    consent_marketing_communications BOOLEAN NOT NULL,
    consent_data_processing_gdpr BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_consents PRIMARY KEY (client_id)
);

-- Aggregated financial metrics and profitability indicators for each client.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_financial_profiles (
    client_id VARCHAR(255) NOT NULL,
    annual_income_amount NUMERIC(18,4),
    total_deposit_balance_eur NUMERIC(18,4) NOT NULL,
    total_loan_balance_eur NUMERIC(18,4) NOT NULL,
    relationship_profitability_score NUMERIC(18,4),
    last_12m_net_revenue_eur NUMERIC(18,4),
    cross_sell_product_count INTEGER NOT NULL,
    churn_risk_score NUMERIC(18,4),
    next_best_offer_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_financial_pro PRIMARY KEY (client_id)
);

-- Digital engagement and recent contact information for each client.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_engagement_metrics (
    client_id VARCHAR(255) NOT NULL,
    digital_engagement_index NUMERIC(18,4),
    last_contact_timestamp TIMESTAMPTZ,
    last_contact_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_engagement_me PRIMARY KEY (client_id)
);

-- Behavioral and strategic tags assigned to clients for micro-segmentation and targeting.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_tags (
    id INTEGER NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    tag VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_tags PRIMARY KEY (id)
);

-- Reference data for client marketing and relationship segments.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_segments (
    id INTEGER NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    client_segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_segments PRIMARY KEY (id)
);

-- Household entities grouping multiple clients for aggregated analysis and marketing.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.households (
    id INTEGER NOT NULL,
    household_external_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_households PRIMARY KEY (id)
);

-- Relationship manager reference data for assigning client coverage responsibility.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.relationship_managers (
    id INTEGER NOT NULL,
    relationship_manager_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (id)
);

ALTER TABLE microsoft_dynamics_365.clients ADD CONSTRAINT FK_clients_client_segment_id
    FOREIGN KEY (client_segment_id) REFERENCES microsoft_dynamics_365.client_segments (id);

ALTER TABLE microsoft_dynamics_365.clients ADD CONSTRAINT FK_clients_household_id
    FOREIGN KEY (household_id) REFERENCES microsoft_dynamics_365.households (id);

ALTER TABLE microsoft_dynamics_365.clients ADD CONSTRAINT FK_clients_primary_relationshi
    FOREIGN KEY (primary_relationship_manager_id) REFERENCES microsoft_dynamics_365.relationship_managers (id);

ALTER TABLE microsoft_dynamics_365.client_consents ADD CONSTRAINT FK_client_consents_client_id
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);

ALTER TABLE microsoft_dynamics_365.client_financial_profiles ADD CONSTRAINT FK_client_financial_profiles_c
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);

ALTER TABLE microsoft_dynamics_365.client_engagement_metrics ADD CONSTRAINT FK_client_engagement_metrics_c
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);

ALTER TABLE microsoft_dynamics_365.client_tags ADD CONSTRAINT FK_client_tags_client_id
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);


-- Dataset: GDS41009
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- Core client entity for Finance Connect Insights, representing a unique retail consumer with property
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.clients (
    client_id UUID NOT NULL,
    client_reference_key VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    onboarding_channel VARCHAR(255),
    first_engagement_date DATE,
    consent_marketing_communications_flag BOOLEAN NOT NULL,
    gdpr_data_processing_basis VARCHAR(255) NOT NULL,
    data_privacy_masking_level VARCHAR(255) NOT NULL,
    record_source_system_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Primary property finance facility associated to a client, including loan identifiers, property chara
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.property_loan_accounts (
    property_loan_account_pk UUID NOT NULL,
    client_id UUID NOT NULL,
    property_loan_account_id VARCHAR(255),
    primary_property_type VARCHAR(255),
    primary_residence_flag BOOLEAN,
    portfolio_region_code VARCHAR(255),
    property_loan_outstanding_balance NUMERIC(18,4),
    property_loan_limit_amount NUMERIC(18,4),
    avg_monthly_repayment_amount NUMERIC(18,4),
    interest_rate_current NUMERIC(18,4),
    arrears_status_code VARCHAR(255),
    days_past_due INTEGER,
    risk_grade_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_property_loan_accoun PRIMARY KEY (property_loan_account_pk)
);

-- Snapshot of Finance Connect Insights metrics and analytical scores for a client, linking to the unde
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_insights (
    client_insight_id VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL,
    property_loan_account_pk UUID,
    client_segment_code VARCHAR(255),
    client_relationship_tenure_months INTEGER NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    preferred_contact_channels JSONB,
    nps_latest_score INTEGER,
    client_profitability_score NUMERIC(18,4),
    annual_property_finance_revenue NUMERIC(18,4),
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    churn_risk_score NUMERIC(18,4),
    client_engagement_index NUMERIC(18,4),
    last_campaign_response_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_insights PRIMARY KEY (client_insight_id)
);

ALTER TABLE microsoft_dynamics_365.property_loan_accounts ADD CONSTRAINT FK_property_loan_accounts_clie
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);

ALTER TABLE microsoft_dynamics_365.client_insights ADD CONSTRAINT FK_client_insights_client_id
    FOREIGN KEY (client_id) REFERENCES microsoft_dynamics_365.clients (client_id);

ALTER TABLE microsoft_dynamics_365.client_insights ADD CONSTRAINT FK_client_insights_property_lo
    FOREIGN KEY (property_loan_account_pk) REFERENCES microsoft_dynamics_365.property_loan_accounts (property_loan_account_pk);


-- Dataset: GDS79712
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.client_insight_finance_dataset (
    id INTEGER NOT NULL,
    client_id UUID NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    crm_account_id VARCHAR(255),
    customer_type VARCHAR(255) NOT NULL,
    client_status VARCHAR(255) NOT NULL,
    primary_relationship_manager_id VARCHAR(255),
    primary_relationship_manager_name VARCHAR(255),
    client_segment VARCHAR(255),
    industry_sector_code VARCHAR(255),
    country_of_residence VARCHAR(255) NOT NULL,
    primary_client_language VARCHAR(255),
    client_onboarding_date DATE,
    first_lease_start_date DATE,
    last_lease_end_date DATE,
    number_of_active_leases INTEGER NOT NULL,
    total_outstanding_lease_balance NUMERIC(18,2) NOT NULL,
    ytd_lease_revenue NUMERIC(18,2),
    prior_year_lease_revenue NUMERIC(18,2),
    average_lease_margin_bps INTEGER,
    average_lease_term_months INTEGER,
    client_profitability_score NUMERIC(6,2),
    cross_sell_potential_score NUMERIC(5,2),
    risk_rating_internal VARCHAR(255),
    days_past_due_max_last_12m INTEGER,
    has_any_delinquent_leases_flag BOOLEAN NOT NULL,
    client_lifetime_value_estimate NUMERIC(18,2),
    primary_email_address VARCHAR(320),
    primary_phone_number VARCHAR(255),
    preferred_contact_channel VARCHAR(320),
    contact_opt_in_email_flag BOOLEAN NOT NULL,
    contact_opt_in_phone_flag BOOLEAN NOT NULL,
    gdpr_consent_status VARCHAR(255) NOT NULL,
    gdpr_consent_last_updated TIMESTAMPTZ,
    kyc_review_next_due_date DATE,
    client_profitability_bucket VARCHAR(255),
    relationship_tenure_years NUMERIC(5,2),
    last_contact_timestamp TIMESTAMPTZ,
    last_contact_channel VARCHAR(320),
    open_opportunity_count INTEGER NOT NULL,
    open_opportunity_estimated_value NUMERIC(18,2),
    product_holding_categories JSONB,
    primary_bank_iban_masked VARCHAR(34),
    client_preferred_contact_times JSONB,
    client_risk_flags JSONB,
    client_contact_preferences JSONB,
    client_financial_profile JSONB,
    client_location_coordinates JSONB,
    record_created_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_client_insight_finan PRIMARY KEY (id)
);


-- Dataset: GDS87943
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365.finance_crm_insights (
    id INTEGER NOT NULL,
    client_id UUID NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    client_global_lei VARCHAR(255),
    customer_segment VARCHAR(255) NOT NULL,
    client_risk_rating INTEGER NOT NULL,
    primary_relationship_manager_id VARCHAR(255) NOT NULL,
    primary_relationship_manager_name VARCHAR(255) NOT NULL,
    client_onboarding_date DATE NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    preferred_contact_channel VARCHAR(320),
    consent_marketing_communications_flag BOOLEAN NOT NULL,
    consent_data_processing_flag BOOLEAN NOT NULL,
    client_profitability_score NUMERIC(7,4),
    total_active_lease_count INTEGER NOT NULL,
    total_lease_outstanding_balance NUMERIC(15,2) NOT NULL,
    avg_lease_yield_rate NUMERIC(5,4),
    region_country_code VARCHAR(255) NOT NULL,
    industry_sector_code VARCHAR(255),
    client_lifecycle_stage VARCHAR(255) NOT NULL,
    churn_risk_score NUMERIC(5,4),
    nps_latest_score INTEGER,
    nps_latest_survey_date DATE,
    key_decision_maker_name VARCHAR(255),
    key_decision_maker_role VARCHAR(255),
    annual_turnover_eur NUMERIC(18,2),
    cross_sell_opportunity_flag BOOLEAN NOT NULL,
    cross_sell_product_recommendations JSONB,
    last_interaction_type VARCHAR(320),
    last_interaction_outcome VARCHAR(255),
    next_best_action_code VARCHAR(255),
    next_best_action_due_date DATE,
    data_record_last_updated_ts TIMESTAMPTZ NOT NULL,
    pii_data_masking_level VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_crm_insights PRIMARY KEY (id)
);


