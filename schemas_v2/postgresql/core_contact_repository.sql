-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: core_contact_repository
-- Generated: 2026-03-18T12:17:47.424386
-- Datasets: 8
-- ============================================

-- Dataset: GDS11221
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Core client persona master record for retail leasing clients, including identifiers, demographics, a
CREATE TABLE IF NOT EXISTS core_contact_repository.finance_personas (
    client_persona_id VARCHAR(255) NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    leasing_customer_segment VARCHAR(255),
    primary_country_of_residence VARCHAR(255) NOT NULL,
    residency_status VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    age_years INTEGER NOT NULL,
    gender_code VARCHAR(255),
    marital_status VARCHAR(255),
    household_size INTEGER,
    employment_status VARCHAR(255) NOT NULL,
    occupation_category VARCHAR(255),
    employer_industry VARCHAR(255),
    annual_gross_income_eur NUMERIC(18,4),
    declared_net_worth_eur NUMERIC(18,4),
    relationship_start_date DATE NOT NULL,
    relationship_manager_id VARCHAR(255),
    segmentation_persona_label VARCHAR(255),
    referral_source_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_personas PRIMARY KEY (client_persona_id)
);

-- Per-client contact details and marketing channel preferences for leasing communications.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_contact_preferences (
    client_persona_id VARCHAR(255) NOT NULL,
    preferred_contact_channel VARCHAR(255),
    email_address VARCHAR(255),
    mobile_phone_country_code VARCHAR(255),
    mobile_phone_number VARCHAR(255),
    language_preference VARCHAR(255),
    preferred_contact_time_window VARCHAR(255),
    marketing_opt_in_email_flag BOOLEAN NOT NULL,
    marketing_opt_in_sms_flag BOOLEAN NOT NULL,
    marketing_opt_in_phone_flag BOOLEAN NOT NULL,
    bounced_email_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_contact_prefe PRIMARY KEY (client_persona_id)
);

-- Credit and KYC risk classifications for each client persona relevant to leasing decisions.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_risk_profiles (
    client_persona_id VARCHAR(255) NOT NULL,
    credit_risk_band VARCHAR(255),
    kyc_risk_rating VARCHAR(255) NOT NULL,
    politically_exposed_person_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_risk_profiles PRIMARY KEY (client_persona_id)
);

-- Aggregated leasing product holdings, balances, and value metrics per client persona.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_leasing_summaries (
    client_persona_id VARCHAR(255) NOT NULL,
    leasing_product_holding_count INTEGER NOT NULL,
    active_leasing_contract_count INTEGER NOT NULL,
    average_leasing_ticket_size_eur NUMERIC(18,4),
    total_outstanding_leasing_balance_eur NUMERIC(18,4) NOT NULL,
    leasing_profitability_score NUMERIC(18,4),
    cross_sell_uplift_potential_eur NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_leasing_summa PRIMARY KEY (client_persona_id)
);

-- Channel engagement, interaction recency, behavioral features, and complaint history per client perso
CREATE TABLE IF NOT EXISTS core_contact_repository.client_engagement_metrics (
    client_persona_id VARCHAR(255) NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    digital_channel_usage_index NUMERIC(18,4),
    last_digital_login_timestamp TIMESTAMPTZ,
    churn_risk_score NUMERIC(18,4),
    complaint_history_summary JSONB,
    behavioral_feature_vector JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_engagement_me PRIMARY KEY (client_persona_id)
);

-- Global GDPR and data processing consents and audit trail per client persona.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_consents (
    client_persona_id VARCHAR(255) NOT NULL,
    eu_gdpr_consent_version VARCHAR(255),
    data_processing_restriction_flag BOOLEAN NOT NULL,
    consent_audit_trail JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_consents PRIMARY KEY (client_persona_id)
);

ALTER TABLE core_contact_repository.client_contact_preferences ADD CONSTRAINT FK_client_contact_preferences_
    FOREIGN KEY (client_persona_id) REFERENCES core_contact_repository.finance_personas (client_persona_id);

ALTER TABLE core_contact_repository.client_risk_profiles ADD CONSTRAINT FK_client_risk_profiles_client
    FOREIGN KEY (client_persona_id) REFERENCES core_contact_repository.finance_personas (client_persona_id);

ALTER TABLE core_contact_repository.client_leasing_summaries ADD CONSTRAINT FK_client_leasing_summaries_cl
    FOREIGN KEY (client_persona_id) REFERENCES core_contact_repository.finance_personas (client_persona_id);

ALTER TABLE core_contact_repository.client_engagement_metrics ADD CONSTRAINT FK_client_engagement_metrics_c
    FOREIGN KEY (client_persona_id) REFERENCES core_contact_repository.finance_personas (client_persona_id);

ALTER TABLE core_contact_repository.client_consents ADD CONSTRAINT FK_client_consents_client_pers
    FOREIGN KEY (client_persona_id) REFERENCES core_contact_repository.finance_personas (client_persona_id);


-- Dataset: GDS15128
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Core retail customer master data for Masreph Finance, including identifiers, demographics, relations
CREATE TABLE IF NOT EXISTS core_contact_repository.customers (
    customer_id VARCHAR(255) NOT NULL,
    masreph_party_guid VARCHAR(255) NOT NULL,
    customer_segment_id INTEGER NOT NULL,
    primary_country_of_residence VARCHAR(255) NOT NULL,
    customer_language_preference VARCHAR(255),
    birth_date DATE,
    age_years INTEGER,
    gender_code VARCHAR(255),
    marital_status VARCHAR(255),
    onboarding_channel VARCHAR(255),
    customer_since_date DATE NOT NULL,
    relationship_status VARCHAR(255) NOT NULL,
    kyc_completion_status VARCHAR(255) NOT NULL,
    consent_marketing_flag BOOLEAN NOT NULL,
    consent_data_processing_flag BOOLEAN NOT NULL,
    primary_email_address VARCHAR(255),
    primary_mobile_number VARCHAR(255),
    residence_city VARCHAR(255),
    residence_postal_code VARCHAR(255),
    employment_status VARCHAR(255),
    last_contact_timestamp TIMESTAMPTZ,
    preferred_contact_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);

-- Reference table for strategic customer segments used for pricing, service levels, and relationship m
CREATE TABLE IF NOT EXISTS core_contact_repository.customer_segments (
    customer_segment_id INTEGER NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    customer_segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_segments PRIMARY KEY (customer_segment_id)
);

-- Aggregated financial, risk, profitability, and product metrics per customer, used for exposure monit
CREATE TABLE IF NOT EXISTS core_contact_repository.customer_financial_metrics (
    customer_id VARCHAR(255) NOT NULL,
    risk_rating_score NUMERIC(18,4),
    annual_gross_income_amount NUMERIC(18,4),
    total_deposit_balance_eur NUMERIC(18,4) NOT NULL,
    total_loan_balance_eur NUMERIC(18,4) NOT NULL,
    current_month_fee_income_eur NUMERIC(18,4) NOT NULL,
    last_12m_interest_income_eur NUMERIC(18,4) NOT NULL,
    last_12m_interest_expense_eur NUMERIC(18,4) NOT NULL,
    profitability_segment VARCHAR(255),
    relationship_profitability_summary JSONB,
    churn_risk_score NUMERIC(18,4),
    active_product_count INTEGER NOT NULL,
    last_transaction_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_financial_m PRIMARY KEY (customer_id)
);

-- Per-customer, per-tag records capturing non-sensitive notes and service preference tags for CRM work
CREATE TABLE IF NOT EXISTS core_contact_repository.customer_note_tags (
    customer_note_tag_id INTEGER NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    tag VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_note_tags PRIMARY KEY (customer_note_tag_id)
);

ALTER TABLE core_contact_repository.customers ADD CONSTRAINT FK_customers_customer_segment_
    FOREIGN KEY (customer_segment_id) REFERENCES core_contact_repository.customer_segments (customer_segment_id);

ALTER TABLE core_contact_repository.customer_financial_metrics ADD CONSTRAINT FK_customer_financial_metrics_
    FOREIGN KEY (customer_id) REFERENCES core_contact_repository.customers (customer_id);

ALTER TABLE core_contact_repository.customer_note_tags ADD CONSTRAINT FK_customer_note_tags_customer
    FOREIGN KEY (customer_id) REFERENCES core_contact_repository.customers (customer_id);


-- Dataset: GDS26337
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Core master data for Remedy commercial finance client entities, including lifecycle, risk, exposure,
CREATE TABLE IF NOT EXISTS core_contact_repository.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_entity_id VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    client_type VARCHAR(255) NOT NULL,
    client_status VARCHAR(255) NOT NULL,
    country_of_incorporation VARCHAR(255) NOT NULL,
    registration_number VARCHAR(255),
    tax_identification_number VARCHAR(255),
    industry_sector_code VARCHAR(255) NOT NULL,
    relationship_start_date DATE NOT NULL,
    relationship_end_date DATE,
    primary_relationship_manager_id VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255) NOT NULL,
    group_parent_client_id VARCHAR(255),
    ultimate_beneficial_owner_flag BOOLEAN NOT NULL,
    number_of_employees INTEGER,
    annual_turnover_amount NUMERIC(18,4),
    annual_turnover_currency VARCHAR(255),
    total_outstanding_exposure_amount NUMERIC(18,4) NOT NULL,
    total_outstanding_exposure_currency VARCHAR(255) NOT NULL,
    average_monthly_transaction_volume INTEGER,
    average_monthly_transaction_value NUMERIC(18,4),
    risk_rating VARCHAR(255),
    risk_rating_last_review_date DATE,
    credit_limit_amount NUMERIC(18,4),
    credit_limit_currency VARCHAR(255),
    credit_limit_last_review_date DATE,
    onboarding_channel VARCHAR(255),
    kyc_completion_date DATE,
    kyc_review_status VARCHAR(255),
    sanctions_screening_status VARCHAR(255),
    last_sanctions_screening_date DATE,
    contact_email_address VARCHAR(255),
    contact_phone_number VARCHAR(255),
    registered_address_line_1 VARCHAR(255),
    registered_address_city VARCHAR(255),
    registered_address_postal_code VARCHAR(255),
    registered_address_country VARCHAR(255),
    consent_to_marketing_flag BOOLEAN NOT NULL,
    data_processing_consent_flag BOOLEAN NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    last_product_purchased VARCHAR(255),
    profitability_score NUMERIC(18,4),
    client_lifecycle_stage VARCHAR(255),
    client_preferred_language VARCHAR(255),
    crm_source_system VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Reference data for primary relationship managers responsible for Remedy commercial finance clients.
CREATE TABLE IF NOT EXISTS core_contact_repository.relationship_managers (
    relationship_manager_id VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

-- Reference data for client industry sectors, keyed by standardized industry sector codes.
CREATE TABLE IF NOT EXISTS core_contact_repository.industry_sectors (
    industry_sector_code VARCHAR(255) NOT NULL,
    industry_sector_description VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_industry_sectors PRIMARY KEY (industry_sector_code)
);

ALTER TABLE core_contact_repository.clients ADD CONSTRAINT FK_clients_primary_relationshi
    FOREIGN KEY (primary_relationship_manager_id) REFERENCES core_contact_repository.relationship_managers (relationship_manager_id);

ALTER TABLE core_contact_repository.clients ADD CONSTRAINT FK_clients_industry_sector_cod
    FOREIGN KEY (industry_sector_code) REFERENCES core_contact_repository.industry_sectors (industry_sector_code);

ALTER TABLE core_contact_repository.clients ADD CONSTRAINT FK_clients_group_parent_client
    FOREIGN KEY (group_parent_client_id) REFERENCES core_contact_repository.clients (client_id);


-- Dataset: GDS38928
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Master data for corporate client legal entities participating in finance relationships, including do
CREATE TABLE IF NOT EXISTS core_contact_repository.clients (
    client_legal_entity_id VARCHAR(255) NOT NULL,
    client_domicile_country_code VARCHAR(255) NOT NULL,
    client_industry_sector_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_legal_entity_id)
);

-- Counterparties acting as lenders, investors, advisors, or other financial partners in corporate fina
CREATE TABLE IF NOT EXISTS core_contact_repository.financial_partners (
    financial_partner_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_financial_partners PRIMARY KEY (financial_partner_id)
);

-- Corporate finance relationships between Masreph, a client legal entity, and a financial partner, inc
CREATE TABLE IF NOT EXISTS core_contact_repository.corporate_finance_relationships (
    relationship_id VARCHAR(255) NOT NULL,
    client_legal_entity_id VARCHAR(255) NOT NULL,
    financial_partner_id VARCHAR(255) NOT NULL,
    relationship_role_code VARCHAR(255) NOT NULL,
    relationship_start_date DATE NOT NULL,
    relationship_end_date DATE,
    relationship_status_code VARCHAR(255) NOT NULL,
    primary_contact_email VARCHAR(255),
    primary_contact_phone_e164 VARCHAR(255),
    credit_exposure_limit_eur NUMERIC(18,4),
    outstanding_lease_balance_eur NUMERIC(18,4),
    relationship_profitability_score NUMERIC(18,4),
    last_interaction_timestamp TIMESTAMPTZ,
    interaction_channel_preference VARCHAR(255),
    kyc_risk_rating VARCHAR(255),
    gdpr_consent_flag BOOLEAN NOT NULL,
    masreph_region_code VARCHAR(255),
    cross_sell_opportunity_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_corporate_finance_re PRIMARY KEY (relationship_id)
);

-- Join table linking corporate finance relationships to associated product or portfolio family codes t
CREATE TABLE IF NOT EXISTS core_contact_repository.relationship_product_portfolios (
    relationship_id VARCHAR(255) NOT NULL,
    portfolio_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_product PRIMARY KEY (relationship_id, portfolio_code)
);


-- Dataset: GDS51049
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Core client persona master record with identity, demographic, residency, onboarding and lifecycle at
CREATE TABLE IF NOT EXISTS core_contact_repository.client_personas (
    client_id VARCHAR(255) NOT NULL,
    external_client_reference VARCHAR(255),
    national_id_hash VARCHAR(255),
    country_of_residence_code VARCHAR(255) NOT NULL,
    residency_status VARCHAR(255),
    birth_date DATE,
    gender_code VARCHAR(255),
    marital_status VARCHAR(255),
    number_of_dependents INTEGER,
    occupation_category VARCHAR(255),
    employment_status VARCHAR(255),
    employer_industry_code VARCHAR(255),
    annual_gross_income_eur NUMERIC(18,4),
    preferred_language_code VARCHAR(255),
    onboarding_channel VARCHAR(255),
    onboarding_date DATE NOT NULL,
    first_leasing_contract_date DATE,
    last_interaction_timestamp TIMESTAMPTZ,
    primary_relationship_manager_id VARCHAR(255),
    address_region_code VARCHAR(255),
    urbanization_level VARCHAR(255),
    life_cycle_stage_segment VARCHAR(255) NOT NULL,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_personas PRIMARY KEY (client_id)
);

-- Aggregated leasing exposure, risk, satisfaction and profitability metrics per client, used for credi
CREATE TABLE IF NOT EXISTS core_contact_repository.client_risk_and_value_metrics (
    client_id VARCHAR(255) NOT NULL,
    credit_risk_segment VARCHAR(255),
    leasing_product_affinity_segment JSONB,
    average_monthly_leasing_payment_eur NUMERIC(18,4),
    total_active_leasing_contracts INTEGER NOT NULL,
    total_leasing_exposure_eur NUMERIC(18,4) NOT NULL,
    payment_behavior_score NUMERIC(18,4),
    churn_risk_score NUMERIC(18,4),
    late_payment_last_12m_count INTEGER,
    nps_latest_score INTEGER,
    profitability_segment_12m VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_risk_and_valu PRIMARY KEY (client_id)
);

-- Client-level consent flags and audit timestamps for marketing communications and GDPR profiling.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_marketing_consents (
    client_id VARCHAR(255) NOT NULL,
    marketing_opt_in_flag BOOLEAN NOT NULL,
    marketing_opt_in_last_update TIMESTAMPTZ,
    consent_gdpr_profiled_flag BOOLEAN NOT NULL,
    consent_gdpr_profiled_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_marketing_con PRIMARY KEY (client_id)
);

-- Primary contact coordinates and channel preferences for each client.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_contact_details (
    client_id VARCHAR(255) NOT NULL,
    contact_email_address VARCHAR(255),
    contact_mobile_number VARCHAR(255),
    preferred_contact_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_contact_detai PRIMARY KEY (client_id)
);

-- Digital engagement scores and usage patterns across web and mobile platforms for each client.
CREATE TABLE IF NOT EXISTS core_contact_repository.client_digital_profiles (
    client_id VARCHAR(255) NOT NULL,
    digital_engagement_score NUMERIC(18,4),
    device_usage_profile JSONB,
    last_digital_login_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_digital_profi PRIMARY KEY (client_id)
);

-- External professional presence and network indicators for clients, supporting business development a
CREATE TABLE IF NOT EXISTS core_contact_repository.client_professional_profiles (
    client_id VARCHAR(255) NOT NULL,
    social_media_professional_presence_flag BOOLEAN,
    professional_network_size_estimate INTEGER,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_professional_ PRIMARY KEY (client_id)
);

ALTER TABLE core_contact_repository.client_risk_and_value_metrics ADD CONSTRAINT FK_client_risk_and_value_metri
    FOREIGN KEY (client_id) REFERENCES core_contact_repository.client_personas (client_id);

ALTER TABLE core_contact_repository.client_marketing_consents ADD CONSTRAINT FK_client_marketing_consents_c
    FOREIGN KEY (client_id) REFERENCES core_contact_repository.client_personas (client_id);

ALTER TABLE core_contact_repository.client_contact_details ADD CONSTRAINT FK_client_contact_details_clie
    FOREIGN KEY (client_id) REFERENCES core_contact_repository.client_personas (client_id);

ALTER TABLE core_contact_repository.client_digital_profiles ADD CONSTRAINT FK_client_digital_profiles_cli
    FOREIGN KEY (client_id) REFERENCES core_contact_repository.client_personas (client_id);

ALTER TABLE core_contact_repository.client_professional_profiles ADD CONSTRAINT FK_client_professional_profile
    FOREIGN KEY (client_id) REFERENCES core_contact_repository.client_personas (client_id);


-- Dataset: GDS76710
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- Core personal finance profile for a retail client within the Masreph mobility solutions platform.
CREATE TABLE IF NOT EXISTS core_contact_repository.personal_finance_profiles (
    client_profile_id VARCHAR(255) NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    crm_party_id VARCHAR(255) NOT NULL,
    client_residency_country VARCHAR(255) NOT NULL,
    primary_contact_language VARCHAR(255),
    client_birth_date DATE,
    monthly_net_income_amount NUMERIC(18,4),
    monthly_recurring_expense_amount NUMERIC(18,4),
    monthly_mobility_spend_amount NUMERIC(18,4),
    auto_loan_outstanding_balance NUMERIC(18,4),
    credit_utilization_ratio NUMERIC(18,4),
    investment_risk_profile_code VARCHAR(255),
    primary_investment_horizon_years INTEGER,
    preferred_mobility_finance_product VARCHAR(255),
    preferred_vehicle_segment VARCHAR(255),
    savings_rate_percentage NUMERIC(18,4),
    client_profitability_segment VARCHAR(255),
    annual_relationship_revenue_amount NUMERIC(18,4),
    annual_relationship_cost_to_serve_amount NUMERIC(18,4),
    gdpr_marketing_consent_flag BOOLEAN NOT NULL,
    data_processing_consent_timestamp TIMESTAMPTZ,
    digital_engagement_score INTEGER,
    last_mobility_product_purchase_date DATE,
    client_relationship_stage_code VARCHAR(255) NOT NULL,
    contact_preference_profile JSONB,
    profile_last_update_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_personal_finance_pro PRIMARY KEY (client_profile_id)
);

-- Investment products held by a personal finance profile, normalized from the investment_products_held
CREATE TABLE IF NOT EXISTS core_contact_repository.personal_finance_profile_investment_products (
    client_profile_id VARCHAR(255) NOT NULL,
    investment_product_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_personal_finance_pro PRIMARY KEY (client_profile_id, investment_product_name)
);

-- Preferred contact channels for a personal finance profile, normalized from the preferred_contact_cha
CREATE TABLE IF NOT EXISTS core_contact_repository.personal_finance_profile_preferred_contact_channels (
    client_profile_id VARCHAR(255) NOT NULL,
    contact_channel VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_personal_finance_pro PRIMARY KEY (client_profile_id, contact_channel)
);

ALTER TABLE core_contact_repository.personal_finance_profile_investment_products ADD CONSTRAINT FK_personal_finance_profile_in
    FOREIGN KEY (client_profile_id) REFERENCES core_contact_repository.personal_finance_profiles (client_profile_id);

ALTER TABLE core_contact_repository.personal_finance_profile_preferred_contact_channels ADD CONSTRAINT FK_personal_finance_profile_pr
    FOREIGN KEY (client_profile_id) REFERENCES core_contact_repository.personal_finance_profiles (client_profile_id);


-- Dataset: GDS85519
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- This client dataset supports commercial finance operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS core_contact_repository.finance_persona_data (
    id INTEGER NOT NULL,
    client_persona_id UUID NOT NULL,
    masreph_client_internal_id VARCHAR(255) NOT NULL,
    client_global_party_id VARCHAR(255),
    client_segment_code VARCHAR(255) NOT NULL,
    client_segment_description VARCHAR(255),
    primary_relationship_manager_id VARCHAR(255),
    primary_relationship_manager_name VARCHAR(255),
    client_legal_residence_country_code VARCHAR(255) NOT NULL,
    client_preferred_language_code VARCHAR(255),
    client_preferred_contact_channel VARCHAR(320),
    client_contact_email_address VARCHAR(320),
    client_contact_mobile_number VARCHAR(255),
    client_industry_specialization VARCHAR(255),
    client_professional_role_title VARCHAR(255),
    client_seniority_level VARCHAR(255),
    client_employer_name VARCHAR(255),
    client_employer_industry_code VARCHAR(255),
    client_annual_income_amount NUMERIC(15,2),
    client_total_assets_under_management NUMERIC(18,2),
    client_profitability_score NUMERIC(5,2),
    client_risk_appetite_category VARCHAR(255),
    client_consent_marketing_flag BOOLEAN NOT NULL,
    client_consent_data_sharing_flag BOOLEAN NOT NULL,
    client_lifecycle_stage VARCHAR(255) NOT NULL,
    first_onboarding_date DATE,
    last_interaction_timestamp TIMESTAMPTZ,
    last_product_purchase_date DATE,
    active_credit_products_count INTEGER,
    active_deposit_products_count INTEGER,
    last_12m_revenue_contribution_amount NUMERIC(18,2),
    potential_revenue_uplift_score NUMERIC(5,2),
    digital_engagement_score NUMERIC(6,2),
    preferred_meeting_location_city VARCHAR(255),
    eu_gdpr_data_processing_basis VARCHAR(255) NOT NULL,
    kyc_risk_rating VARCHAR(255),
    churn_propensity_score NUMERIC(4,3),
    behavioral_persona_cluster_id INTEGER,
    recent_interaction_channels VARCHAR(320),
    additional_persona_attributes JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_persona_data PRIMARY KEY (id)
);


-- Dataset: GDS96306
CREATE SCHEMA IF NOT EXISTS core_contact_repository;

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS core_contact_repository.corporate_client_insights (
    id INTEGER NOT NULL,
    corporate_client_id UUID NOT NULL,
    masreph_client_reference VARCHAR(255) NOT NULL,
    global_ultimate_parent_id VARCHAR(255),
    legal_entity_name VARCHAR(255) NOT NULL,
    legal_entity_identifier VARCHAR(255),
    country_of_incorporation VARCHAR(255) NOT NULL,
    registered_address_line_1 VARCHAR(255) NOT NULL,
    registered_address_city VARCHAR(255) NOT NULL,
    registered_address_postal_code VARCHAR(255) NOT NULL,
    industry_sector_code VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    relationship_manager_region VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    client_status VARCHAR(255) NOT NULL,
    kyc_review_next_due_date DATE,
    risk_rating_internal VARCHAR(255),
    risk_rating_external_agency VARCHAR(255),
    credit_limit_total_eur NUMERIC(15,2),
    outstanding_exposure_eur NUMERIC(15,2),
    annual_revenue_eur NUMERIC(17,2),
    profitability_rolling_12m_eur NUMERIC(15,2),
    profitability_breakdown_12m JSONB,
    roi_rolling_12m_percent NUMERIC(5,2),
    wallet_share_estimated_percent NUMERIC(5,2),
    primary_banking_channel VARCHAR(255),
    preferred_contact_method VARCHAR(320),
    consent_to_marketing_communications BOOLEAN NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    last_product_purchased_code VARCHAR(255),
    product_portfolio_summary JSONB,
    cross_sell_score NUMERIC(5,2),
    churn_risk_score NUMERIC(5,2),
    sanctions_screening_flag BOOLEAN NOT NULL,
    data_privacy_consent_version VARCHAR(255),
    last_financial_statement_date DATE,
    client_segment_classification VARCHAR(255),
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_corporate_client_ins PRIMARY KEY (id)
);


