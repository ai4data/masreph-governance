-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: alvaria
-- Generated: 2026-03-18T12:17:47.435390
-- Datasets: 2
-- ============================================

-- Dataset: GDS17439
CREATE SCHEMA IF NOT EXISTS alvaria;

-- Master data for retail clients engaging in dialogues, including cross-system identifiers and relativ
CREATE TABLE IF NOT EXISTS alvaria.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    client_hashed_identifier VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255),
    client_country_code VARCHAR(255) NOT NULL,
    client_language_preference VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Reference data for relationship managers responsible for clients at the time of dialogues.
CREATE TABLE IF NOT EXISTS alvaria.relationship_managers (
    primary_relationship_manager_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (primary_relationship_manager_id)
);

-- Reference data for financial products that may be sold or upgraded during dialogues.
CREATE TABLE IF NOT EXISTS alvaria.products (
    product_sold_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_products PRIMARY KEY (product_sold_code)
);

-- Reference data for client issues or cases that can span multiple dialogues.
CREATE TABLE IF NOT EXISTS alvaria.issues (
    issue_reference_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_issues PRIMARY KEY (issue_reference_id)
);

-- Fact table capturing individual client dialogues/interactions including operational, analytical, and
CREATE TABLE IF NOT EXISTS alvaria.dialogues (
    dialogue_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    primary_relationship_manager_id VARCHAR(255),
    dialogue_external_ref VARCHAR(255),
    dialogue_start_timestamp TIMESTAMPTZ NOT NULL,
    dialogue_end_timestamp TIMESTAMPTZ,
    dialogue_channel VARCHAR(255) NOT NULL,
    dialogue_sub_channel VARCHAR(255),
    dialogue_intent_primary VARCHAR(255) NOT NULL,
    dialogue_intent_secondary VARCHAR(255),
    dialogue_sentiment_score NUMERIC(18,4),
    dialogue_sentiment_label VARCHAR(255),
    dialogue_duration_seconds INTEGER,
    is_first_contact_for_issue BOOLEAN NOT NULL,
    issue_reference_id VARCHAR(255),
    dialogue_outcome_code VARCHAR(255) NOT NULL,
    sales_conversion_flag BOOLEAN NOT NULL,
    product_sold_code VARCHAR(255),
    estimated_dialogue_revenue_12m NUMERIC(18,4),
    estimated_dialogue_cost NUMERIC(18,4),
    client_total_revenue_12m NUMERIC(18,4),
    client_total_cost_12m NUMERIC(18,4),
    client_profitability_segment VARCHAR(255),
    cross_sell_opportunity_score NUMERIC(18,4),
    client_risk_profile_code VARCHAR(255),
    requires_additional_kyc_check BOOLEAN NOT NULL,
    gdpr_consent_marketing_flag BOOLEAN NOT NULL,
    gdpr_consent_timestamp TIMESTAMPTZ,
    client_contact_point_used VARCHAR(255),
    client_contact_point_masked VARCHAR(255),
    dialogue_transcript_reference VARCHAR(255),
    dialogue_keywords_extracted JSONB,
    service_level_agreement_breached BOOLEAN NOT NULL,
    client_lifetime_value_score NUMERIC(18,4),
    dialogue_follow_up_due_date DATE,
    agent_performance_score NUMERIC(18,4),
    dialogue_metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_dialogues PRIMARY KEY (dialogue_id)
);

ALTER TABLE alvaria.dialogues ADD CONSTRAINT FK_dialogues_client_id
    FOREIGN KEY (client_id) REFERENCES alvaria.clients (client_id);

ALTER TABLE alvaria.dialogues ADD CONSTRAINT FK_dialogues_primary_relations
    FOREIGN KEY (primary_relationship_manager_id) REFERENCES alvaria.relationship_managers (primary_relationship_manager_id);

ALTER TABLE alvaria.dialogues ADD CONSTRAINT FK_dialogues_issue_reference_i
    FOREIGN KEY (issue_reference_id) REFERENCES alvaria.issues (issue_reference_id);

ALTER TABLE alvaria.dialogues ADD CONSTRAINT FK_dialogues_product_sold_code
    FOREIGN KEY (product_sold_code) REFERENCES alvaria.products (product_sold_code);


-- Dataset: GDS20617
CREATE SCHEMA IF NOT EXISTS alvaria;

-- Masreph clients linked to finance dialogues, with CRM, risk, profitability, and consent attributes a
CREATE TABLE IF NOT EXISTS alvaria.clients (
    client_key UUID NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255),
    client_profitability_score NUMERIC(18,4),
    client_lifetime_value_eur NUMERIC(18,4),
    client_country_code VARCHAR(255),
    client_city_name VARCHAR(255),
    consent_to_contact_marketing BOOLEAN NOT NULL,
    gdpr_consent_timestamp TIMESTAMPTZ,
    is_high_risk_client BOOLEAN NOT NULL,
    risk_reason_codes JSONB,
    masreph_relationship_tenure_months INTEGER,
    client_preferred_contact_time_window VARCHAR(255),
    client_contact_email_hashed VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_key)
);

-- Relationship managers handling client finance dialogues, identified by the external RM identifier.
CREATE TABLE IF NOT EXISTS alvaria.relationship_managers (
    relationship_manager_key UUID NOT NULL,
    relationship_manager_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_key)
);

-- Individual finance dialogue instances between Masreph and clients across channels, with contextual, 
CREATE TABLE IF NOT EXISTS alvaria.finance_dialogues (
    dialogue_id VARCHAR(255) NOT NULL,
    client_key UUID NOT NULL,
    relationship_manager_key UUID,
    conversation_timestamp TIMESTAMPTZ NOT NULL,
    interaction_channel VARCHAR(255) NOT NULL,
    client_language_code VARCHAR(255),
    interaction_type VARCHAR(255) NOT NULL,
    product_category VARCHAR(255),
    financing_need_amount NUMERIC(18,4),
    loan_application_id VARCHAR(255),
    interaction_sentiment_score NUMERIC(18,4),
    sentiment_label VARCHAR(255),
    next_best_action_recommended VARCHAR(255),
    next_best_action_confidence NUMERIC(18,4),
    follow_up_required BOOLEAN NOT NULL,
    follow_up_due_date DATE,
    mobility_asset_type VARCHAR(255),
    vehicle_vin_hashed VARCHAR(255),
    client_country_code VARCHAR(255),
    client_city_name VARCHAR(255),
    conversation_duration_seconds INTEGER,
    conversation_transcript_text VARCHAR(255),
    key_topics_extracted JSONB,
    regulatory_disclosure_provided BOOLEAN NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    record_created_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    interaction_outcome_status VARCHAR(255) NOT NULL,
    deal_conversion_probability NUMERIC(18,4),
    estimated_revenue_impact_eur NUMERIC(18,4),
    cross_sell_products_suggested JSONB,
    consent_to_contact_marketing BOOLEAN,
    gdpr_consent_timestamp TIMESTAMPTZ,
    is_high_risk_client BOOLEAN,
    risk_reason_codes JSONB,
    masreph_relationship_tenure_months INTEGER,
    client_segment VARCHAR(255),
    client_profitability_score NUMERIC(18,4),
    client_lifetime_value_eur NUMERIC(18,4),
    client_preferred_contact_time_window VARCHAR(255),
    client_contact_email_hashed VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_dialogues PRIMARY KEY (dialogue_id)
);

ALTER TABLE alvaria.finance_dialogues ADD CONSTRAINT FK_finance_dialogues_client_ke
    FOREIGN KEY (client_key) REFERENCES alvaria.clients (client_key);

ALTER TABLE alvaria.finance_dialogues ADD CONSTRAINT FK_finance_dialogues_relations
    FOREIGN KEY (relationship_manager_key) REFERENCES alvaria.relationship_managers (relationship_manager_key);


