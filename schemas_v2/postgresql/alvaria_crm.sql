-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: alvaria_crm
-- Generated: 2026-03-18T11:56:02.410627
-- Datasets: 1
-- ============================================

-- Dataset: GDS17439
CREATE SCHEMA IF NOT EXISTS alvaria_crm;

-- Unique retail clients participating in finance dialogues, including core identifiers and static prof
CREATE TABLE IF NOT EXISTS alvaria_crm.clients (
    client_pk INTEGER NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    masreph_party_id VARCHAR(255) NOT NULL,
    client_hashed_identifier VARCHAR(255) NOT NULL,
    client_country_code VARCHAR(255) NOT NULL,
    client_language_preference VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_pk)
);

-- Financial products that may be sold or upgraded during client dialogues.
CREATE TABLE IF NOT EXISTS alvaria_crm.products (
    product_pk INTEGER NOT NULL,
    product_sold_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_products PRIMARY KEY (product_pk)
);

-- Client issues or cases that can be linked to multiple dialogues for holistic resolution tracking.
CREATE TABLE IF NOT EXISTS alvaria_crm.issues (
    issue_pk INTEGER NOT NULL,
    issue_reference_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_issues PRIMARY KEY (issue_pk)
);

-- Individual client dialogues/interactions enriched with operational, analytical, and profitability at
CREATE TABLE IF NOT EXISTS alvaria_crm.dialogues (
    dialogue_id VARCHAR(255) NOT NULL,
    client_pk INTEGER NOT NULL,
    dialogue_external_ref VARCHAR(255),
    primary_relationship_manager_id VARCHAR(255),
    dialogue_start_timestamp TIMESTAMPTZ NOT NULL,
    dialogue_end_timestamp TIMESTAMPTZ,
    dialogue_channel VARCHAR(255) NOT NULL,
    dialogue_sub_channel VARCHAR(255),
    client_segment VARCHAR(255),
    dialogue_intent_primary VARCHAR(255) NOT NULL,
    dialogue_intent_secondary VARCHAR(255),
    dialogue_sentiment_score NUMERIC(18,4),
    dialogue_sentiment_label VARCHAR(255),
    dialogue_duration_seconds INTEGER,
    is_first_contact_for_issue BOOLEAN NOT NULL,
    issue_pk INTEGER,
    dialogue_outcome_code VARCHAR(255) NOT NULL,
    sales_conversion_flag BOOLEAN NOT NULL,
    product_pk INTEGER,
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

ALTER TABLE alvaria_crm.dialogues ADD CONSTRAINT FK_dialogues_client_pk
    FOREIGN KEY (client_pk) REFERENCES alvaria_crm.clients (client_pk);

ALTER TABLE alvaria_crm.dialogues ADD CONSTRAINT FK_dialogues_product_pk
    FOREIGN KEY (product_pk) REFERENCES alvaria_crm.products (product_pk);

ALTER TABLE alvaria_crm.dialogues ADD CONSTRAINT FK_dialogues_issue_pk
    FOREIGN KEY (issue_pk) REFERENCES alvaria_crm.issues (issue_pk);


