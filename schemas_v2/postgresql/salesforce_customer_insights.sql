-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: salesforce_customer_insights
-- Generated: 2026-03-18T12:17:47.437796
-- Datasets: 6
-- ============================================

-- Dataset: GDS31152
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Core client master data for mobility solutions, including segment, residence, onboarding, review fre
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_customer_number VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255) NOT NULL,
    client_residence_country VARCHAR(255) NOT NULL,
    eu_residency_flag BOOLEAN NOT NULL,
    client_onboarding_date DATE NOT NULL,
    first_mobility_contract_date DATE,
    review_frequency_months INTEGER NOT NULL,
    primary_contact_channel VARCHAR(255) NOT NULL,
    contact_preference_detail VARCHAR(255),
    kyc_review_status VARCHAR(255) NOT NULL,
    last_kyc_review_date DATE,
    gdpr_consent_status VARCHAR(255) NOT NULL,
    gdpr_consent_last_updated TIMESTAMPTZ,
    data_processing_purposes JSONB,
    relationship_manager_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Reference data for relationship managers responsible for mobility clients.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.relationship_managers (
    relationship_manager_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

-- Vehicles that are the primary financed mobility assets referenced in finance reviews.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.vehicles (
    vehicle_id INTEGER NOT NULL,
    vin VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_vehicles PRIMARY KEY (vehicle_id)
);

-- Mobility loan, lease, subscription, or fleet management contracts associated with finance reviews.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.mobility_contracts (
    contract_id VARCHAR(255) NOT NULL,
    mobility_solution_type VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_mobility_contracts PRIMARY KEY (contract_id)
);

-- Snapshots of financial review tracker records per client, including review status, profitability, ri
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.finance_reviews (
    finance_review_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    contract_id VARCHAR(255),
    vehicle_id INTEGER,
    review_timestamp TIMESTAMPTZ,
    next_scheduled_review_date DATE,
    review_status VARCHAR(255) NOT NULL,
    review_outcome_code VARCHAR(255),
    review_priority_score INTEGER NOT NULL,
    total_active_mobility_loans INTEGER NOT NULL,
    total_mobility_outstanding_balance_eur NUMERIC(18,4) NOT NULL,
    avg_interest_rate_active_loans NUMERIC(18,4),
    twelve_months_interest_income_eur NUMERIC(18,4) NOT NULL,
    twelve_months_fee_income_eur NUMERIC(18,4) NOT NULL,
    rolling_12m_credit_losses_eur NUMERIC(18,4),
    client_profitability_score INTEGER NOT NULL,
    profitability_band VARCHAR(255) NOT NULL,
    client_lifetime_value_eur NUMERIC(18,4),
    wallet_share_estimate_pct NUMERIC(18,4),
    cross_sell_opportunities_count INTEGER NOT NULL,
    last_client_contact_timestamp TIMESTAMPTZ,
    last_contact_outcome_code VARCHAR(255),
    client_satisfaction_score INTEGER,
    churn_risk_score NUMERIC(18,4),
    high_risk_client_flag BOOLEAN NOT NULL,
    credit_risk_rating VARCHAR(255),
    payment_behavior_indicator VARCHAR(255),
    late_payment_incidents_12m INTEGER NOT NULL,
    mobility_usage_pattern VARCHAR(255),
    relationship_tenure_years NUMERIC(18,4) NOT NULL,
    source_created_timestamp TIMESTAMPTZ NOT NULL,
    source_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_reviews PRIMARY KEY (finance_review_id)
);


-- Dataset: GDS32177
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Core client master data linking CRM insights to Masreph party records and core banking systems.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    client_legal_name VARCHAR(255) NOT NULL,
    client_country_code VARCHAR(255) NOT NULL,
    client_residency_status VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    leasing_customer_segment VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    primary_relationship_flag BOOLEAN NOT NULL,
    annual_turnover_eur NUMERIC(18,4),
    credit_risk_grade VARCHAR(255),
    kyc_review_due_date DATE,
    high_value_client_flag BOOLEAN NOT NULL,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_created_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Current CRM status, interaction, and leasing exposure metrics for each client.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_crm_states (
    client_id VARCHAR(255) NOT NULL,
    crm_account_status VARCHAR(255) NOT NULL,
    crm_account_status_date DATE NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    last_interaction_channel VARCHAR(255),
    interaction_preference_channel VARCHAR(255),
    total_active_leases_count INTEGER NOT NULL,
    total_outstanding_lease_balance_eur NUMERIC(18,4) NOT NULL,
    avg_lease_margin_bps NUMERIC(18,4),
    client_profitability_score NUMERIC(18,4),
    client_lifetime_value_eur NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_crm_states PRIMARY KEY (client_id)
);

-- GDPR-related marketing and data sharing consents for each client.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_consents (
    client_id VARCHAR(255) NOT NULL,
    consent_marketing_flag BOOLEAN NOT NULL,
    consent_data_sharing_flag BOOLEAN NOT NULL,
    gdpr_consent_capture_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_consents PRIMARY KEY (client_id)
);

-- Analytics-driven cross-sell, churn risk, and next-best-action recommendations for each client.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_cross_sell_insights (
    client_id VARCHAR(255) NOT NULL,
    cross_sell_opportunity_flag BOOLEAN NOT NULL,
    cross_sell_recommended_product VARCHAR(255),
    churn_risk_score NUMERIC(18,4),
    next_best_action_code VARCHAR(255),
    next_best_action_valid_to_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_cross_sell_in PRIMARY KEY (client_id)
);

ALTER TABLE salesforce_customer_insights.client_crm_states ADD CONSTRAINT FK_client_crm_states_client_id
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_consents ADD CONSTRAINT FK_client_consents_client_id
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_cross_sell_insights ADD CONSTRAINT FK_client_cross_sell_insights_
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);


-- Dataset: GDS39213
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Core client master for Mobility Solutions, including identifiers, basic classification, lifecycle st
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    crm_client_reference VARCHAR(255) NOT NULL,
    client_full_name VARCHAR(255) NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    primary_mobility_product_type VARCHAR(255),
    auto_loan_contract_id VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    client_status VARCHAR(255) NOT NULL,
    client_residency_country_code VARCHAR(255) NOT NULL,
    data_record_created_ts TIMESTAMPTZ NOT NULL,
    data_record_source_system VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Lookup table for client segment codes and their business descriptions.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_segments (
    segment_code VARCHAR(255) NOT NULL,
    segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_segments PRIMARY KEY (segment_code)
);

-- Directory of relationship managers and teams handling client relationships.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.relationship_managers (
    relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_manager_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

-- Client communication preferences, language, and consent/marketing opt-in settings.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_contact_preferences (
    client_id VARCHAR(255) NOT NULL,
    client_preferred_language VARCHAR(255),
    client_contact_channel_preference VARCHAR(255),
    gdpr_consent_flag BOOLEAN NOT NULL,
    gdpr_consent_last_updated_ts TIMESTAMPTZ,
    marketing_opt_in_flag BOOLEAN NOT NULL,
    marketing_opt_in_channel_list JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_contact_prefe PRIMARY KEY (client_id)
);

-- KYC completion status and client risk assessment information for Mobility Solutions.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_kyc_risk_assessments (
    client_id VARCHAR(255) NOT NULL,
    kyc_completion_status VARCHAR(255) NOT NULL,
    kyc_last_review_date DATE,
    risk_rating_score INTEGER,
    risk_rating_band VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_kyc_risk_asse PRIMARY KEY (client_id)
);

-- Aggregated financial exposure, payment behavior, and profitability metrics at client level.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_financial_summaries (
    client_id VARCHAR(255) NOT NULL,
    total_outstanding_auto_loan_balance NUMERIC(18,4),
    average_monthly_installment_amount NUMERIC(18,4),
    last_payment_date DATE,
    last_payment_amount NUMERIC(18,4),
    days_past_due INTEGER NOT NULL,
    client_profitability_score NUMERIC(18,4),
    rolling_12m_revenue_amount NUMERIC(18,4),
    rolling_12m_interest_income_amount NUMERIC(18,4),
    rolling_12m_fee_income_amount NUMERIC(18,4),
    rolling_12m_credit_loss_amount NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_financial_sum PRIMARY KEY (client_id)
);

-- Mobility usage profile and recent CRM/mobility interaction metrics at client level.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_mobility_engagements (
    client_id VARCHAR(255) NOT NULL,
    mobility_usage_profile JSONB,
    last_mobility_interaction_ts TIMESTAMPTZ,
    last_crm_interaction_channel VARCHAR(255),
    crm_interaction_count_90d INTEGER NOT NULL,
    active_mobility_contract_count INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_mobility_enga PRIMARY KEY (client_id)
);

-- Churn risk classification and next best offer recommendations for each client.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_churn_and_offers (
    client_id VARCHAR(255) NOT NULL,
    churn_risk_flag BOOLEAN NOT NULL,
    churn_risk_reason_code VARCHAR(255),
    next_best_offer_code VARCHAR(255),
    next_best_offer_eligibility_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_churn_and_off PRIMARY KEY (client_id)
);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_client_segment_code
    FOREIGN KEY (client_segment_code) REFERENCES salesforce_customer_insights.client_segments (segment_code);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_relationship_manage
    FOREIGN KEY (relationship_manager_id) REFERENCES salesforce_customer_insights.relationship_managers (relationship_manager_id);

ALTER TABLE salesforce_customer_insights.client_contact_preferences ADD CONSTRAINT FK_client_contact_preferences_
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_kyc_risk_assessments ADD CONSTRAINT FK_client_kyc_risk_assessments
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_financial_summaries ADD CONSTRAINT FK_client_financial_summaries_
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_mobility_engagements ADD CONSTRAINT FK_client_mobility_engagements
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.client_churn_and_offers ADD CONSTRAINT FK_client_churn_and_offers_cli
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);


-- Dataset: GDS43425
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Normalized log of finance-related activities and interactions for consumer clients.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.finance_activity_logs (
    activity_log_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    interaction_id VARCHAR(255),
    transaction_id VARCHAR(255),
    account_id VARCHAR(255),
    call_center_agent_id VARCHAR(255),
    marketing_campaign_id VARCHAR(255),
    activity_type_code VARCHAR(255) NOT NULL,
    activity_subtype_code VARCHAR(255),
    activity_timestamp TIMESTAMPTZ NOT NULL,
    activity_channel VARCHAR(255) NOT NULL,
    product_type_code VARCHAR(255),
    currency_code VARCHAR(255),
    transaction_amount NUMERIC(18,4),
    transaction_direction VARCHAR(255),
    fee_amount NUMERIC(18,4),
    interest_amount NUMERIC(18,4),
    balance_after_activity NUMERIC(18,4),
    client_segment_code VARCHAR(255),
    relationship_tenure_months INTEGER,
    profitability_contribution_amount NUMERIC(18,4),
    cross_sell_offer_flag BOOLEAN NOT NULL,
    cross_sell_offer_accepted_flag BOOLEAN NOT NULL,
    primary_reason_code VARCHAR(255),
    resolution_status_code VARCHAR(255),
    first_contact_resolution_flag BOOLEAN,
    call_duration_seconds INTEGER,
    client_sentiment_score NUMERIC(18,4),
    complaint_flag BOOLEAN NOT NULL,
    complaint_category_code VARCHAR(255),
    fraud_review_flag BOOLEAN NOT NULL,
    activity_notes_masked VARCHAR(255),
    related_account_ids JSONB,
    activity_location JSONB,
    service_level_breach_flag BOOLEAN,
    created_timestamp TIMESTAMPTZ NOT NULL,
    last_updated_timestamp TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_activity_log PRIMARY KEY (activity_log_id)
);

-- Consumer clients participating in finance activities, with core regulatory and communication attribu
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.clients (
    client_id VARCHAR(255) NOT NULL,
    household_id VARCHAR(255),
    gdp_residency_country_code VARCHAR(255),
    gdpr_data_subject_region VARCHAR(255),
    consent_for_marketing_flag BOOLEAN NOT NULL,
    client_language_preference VARCHAR(255),
    client_time_zone VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Household or relationship clusters grouping related clients for analysis and management.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.households (
    household_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_households PRIMARY KEY (household_id)
);

-- Broader client interaction sessions that can contain multiple finance activities.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.interactions (
    interaction_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_interactions PRIMARY KEY (interaction_id)
);

-- Call center or virtual agents handling client interactions, identified without personal details.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.call_center_agents (
    call_center_agent_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_call_center_agents PRIMARY KEY (call_center_agent_id)
);

-- Financial accounts impacted by finance activities, such as credit cards, loans, or deposit accounts.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.accounts (
    account_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_accounts PRIMARY KEY (account_id)
);

-- Financial transactions associated with finance activities, enabling linkage to core banking systems.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.transactions (
    transaction_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_transactions PRIMARY KEY (transaction_id)
);

-- Marketing campaigns that can be associated with finance activities for attribution and performance t
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.marketing_campaigns (
    marketing_campaign_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_marketing_campaigns PRIMARY KEY (marketing_campaign_id)
);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_clien
    FOREIGN KEY (client_id) REFERENCES salesforce_customer_insights.clients (client_id);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_household_id
    FOREIGN KEY (household_id) REFERENCES salesforce_customer_insights.households (household_id);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_inter
    FOREIGN KEY (interaction_id) REFERENCES salesforce_customer_insights.interactions (interaction_id);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_call_
    FOREIGN KEY (call_center_agent_id) REFERENCES salesforce_customer_insights.call_center_agents (call_center_agent_id);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_accou
    FOREIGN KEY (account_id) REFERENCES salesforce_customer_insights.accounts (account_id);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_trans
    FOREIGN KEY (transaction_id) REFERENCES salesforce_customer_insights.transactions (transaction_id);

ALTER TABLE salesforce_customer_insights.finance_activity_logs ADD CONSTRAINT FK_finance_activity_logs_marke
    FOREIGN KEY (marketing_campaign_id) REFERENCES salesforce_customer_insights.marketing_campaigns (marketing_campaign_id);


-- Dataset: GDS57414
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Person/prospect master data including identity, contact details, residence and client identifier use
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.persons (
    person_id UUID NOT NULL,
    masreph_client_id VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    full_name VARCHAR(255),
    email_address VARCHAR(255),
    mobile_phone_number VARCHAR(255),
    country_of_residence VARCHAR(255),
    preferred_language VARCHAR(255),
    household_size INTEGER,
    geo_location_coordinates JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_persons PRIMARY KEY (person_id)
);

-- Core propensity finance lead records including lifecycle status, source, ownership, financial attrib
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.leads (
    lead_id VARCHAR(255) NOT NULL,
    person_id UUID,
    external_crm_lead_id VARCHAR(255),
    marketing_campaign_id VARCHAR(255),
    lead_source_channel VARCHAR(255) NOT NULL,
    lead_sub_source VARCHAR(255),
    primary_mobility_need VARCHAR(255),
    vehicle_usage_pattern VARCHAR(255),
    estimated_annual_mileage_km INTEGER,
    employment_status VARCHAR(255),
    employer_industry VARCHAR(255),
    monthly_net_income_eur NUMERIC(18,4),
    existing_auto_loan_indicator BOOLEAN,
    existing_banking_relationship_level VARCHAR(255),
    preferred_dealer_partner_id VARCHAR(255),
    consent_personal_data_processing BOOLEAN NOT NULL,
    consent_marketing_communications BOOLEAN NOT NULL,
    gdpr_consent_timestamp TIMESTAMPTZ,
    lead_created_timestamp TIMESTAMPTZ NOT NULL,
    lead_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    lead_status VARCHAR(255) NOT NULL,
    lead_status_reason VARCHAR(255),
    lead_owner_user_id VARCHAR(255),
    data_record_source_system VARCHAR(255) NOT NULL,
    pii_anonymization_level VARCHAR(255) NOT NULL,
    record_active_indicator BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leads PRIMARY KEY (lead_id)
);

-- Analytical scores, value estimates, segmentation and next-best-action recommendations for each lead.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.lead_analytics (
    lead_id VARCHAR(255) NOT NULL,
    lead_priority_score NUMERIC(18,4),
    propensity_auto_loan_approval_score NUMERIC(18,4),
    propensity_cross_sell_score NUMERIC(18,4),
    expected_lifetime_value_eur NUMERIC(18,4),
    predicted_profit_margin_pct NUMERIC(18,4),
    next_best_product_offer VARCHAR(255),
    next_best_contact_channel VARCHAR(255),
    next_best_contact_time_window VARCHAR(255),
    client_segment VARCHAR(255),
    risk_appetite_segment VARCHAR(255),
    data_quality_score NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lead_analytics PRIMARY KEY (lead_id)
);

-- Aggregated engagement and contact metrics for each lead over recent periods.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.lead_engagement_metrics (
    lead_id VARCHAR(255) NOT NULL,
    last_contact_timestamp TIMESTAMPTZ,
    last_contact_outcome VARCHAR(255),
    number_of_contacts_last_90_days INTEGER,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lead_engagement_metr PRIMARY KEY (lead_id)
);

ALTER TABLE salesforce_customer_insights.leads ADD CONSTRAINT FK_leads_person_id
    FOREIGN KEY (person_id) REFERENCES salesforce_customer_insights.persons (person_id);

ALTER TABLE salesforce_customer_insights.lead_analytics ADD CONSTRAINT FK_lead_analytics_lead_id
    FOREIGN KEY (lead_id) REFERENCES salesforce_customer_insights.leads (lead_id);

ALTER TABLE salesforce_customer_insights.lead_engagement_metrics ADD CONSTRAINT FK_lead_engagement_metrics_lea
    FOREIGN KEY (lead_id) REFERENCES salesforce_customer_insights.leads (lead_id);


-- Dataset: GDS73170
CREATE SCHEMA IF NOT EXISTS salesforce_customer_insights;

-- Master data for primary relationship managers responsible for commercial finance clients.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.relationship_managers (
    relationship_manager_key INTEGER NOT NULL,
    relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_manager_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_key)
);

-- Reference data for internal commercial banking segment or coverage codes assigned to clients.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.client_segments (
    client_segment_id INTEGER NOT NULL,
    segment_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_segments PRIMARY KEY (client_segment_id)
);

-- Industry master data based on NACE Rev.2 codes for client primary business activities.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.industries (
    industry_id INTEGER NOT NULL,
    industry_nace_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_industries PRIMARY KEY (industry_id)
);

-- Corporate group master data representing global ultimate parent entities for clients.
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.corporate_groups (
    corporate_group_id INTEGER NOT NULL,
    global_ultimate_parent_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_corporate_groups PRIMARY KEY (corporate_group_id)
);

-- Core commercial finance client master and CRM insight metrics sourced from Salesforce Customer Insig
CREATE TABLE IF NOT EXISTS salesforce_customer_insights.clients (
    client_id VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    country_of_incorporation VARCHAR(255) NOT NULL,
    corporate_group_id INTEGER,
    relationship_manager_key INTEGER NOT NULL,
    client_segment_id INTEGER NOT NULL,
    industry_id INTEGER,
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(255),
    client_onboarding_date DATE NOT NULL,
    last_interaction_timestamp TIMESTAMPTZ,
    last_interaction_channel VARCHAR(255),
    last_interaction_type VARCHAR(255),
    crm_activity_score_90d NUMERIC(18,4) NOT NULL,
    annual_client_revenue_eur NUMERIC(18,4),
    annual_client_cost_eur NUMERIC(18,4),
    annual_client_profit_eur NUMERIC(18,4),
    risk_adjusted_return_on_capital_pct NUMERIC(18,4),
    total_outstanding_exposure_eur NUMERIC(18,4),
    client_lending_products JSONB,
    client_wallet_share_estimate_pct NUMERIC(18,4),
    cross_sell_opportunity_score NUMERIC(18,4),
    churn_risk_flag BOOLEAN NOT NULL,
    gdpr_contact_consent_flag BOOLEAN NOT NULL,
    client_status VARCHAR(255) NOT NULL,
    next_planned_activity_date DATE,
    client_satisfaction_score NUMERIC(18,4),
    client_preferred_language VARCHAR(255),
    client_geo_hierarchy JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_relationship_manage
    FOREIGN KEY (relationship_manager_key) REFERENCES salesforce_customer_insights.relationship_managers (relationship_manager_key);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_client_segment_id
    FOREIGN KEY (client_segment_id) REFERENCES salesforce_customer_insights.client_segments (client_segment_id);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_industry_id
    FOREIGN KEY (industry_id) REFERENCES salesforce_customer_insights.industries (industry_id);

ALTER TABLE salesforce_customer_insights.clients ADD CONSTRAINT FK_clients_corporate_group_id
    FOREIGN KEY (corporate_group_id) REFERENCES salesforce_customer_insights.corporate_groups (corporate_group_id);


