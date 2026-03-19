-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: afad_finance_store
-- Generated: 2026-03-18T12:18:16.851605
-- Datasets: 1
-- ============================================

-- Dataset: GDS81456
CREATE SCHEMA IF NOT EXISTS afad_finance_store;

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS afad_finance_store.authorized_finance_agents_dataset (
    id INT NOT NULL,
    agent_id STRING NOT NULL,
    masreph_client_id STRING NOT NULL,
    agent_external_reference STRING,
    agent_full_name STRING NOT NULL,
    agent_type STRING NOT NULL,
    primary_contact_name STRING,
    primary_contact_email STRING,
    primary_contact_phone STRING,
    agent_legal_entity_identifier STRING,
    agent_country_of_operation STRING NOT NULL,
    agent_region_code STRING,
    agent_city STRING,
    agent_postal_code STRING,
    agent_address_line_1 STRING,
    agent_address_line_2 STRING,
    agent_status STRING NOT NULL,
    agent_onboarding_date DATE,
    authorization_expiry_date DATE,
    last_review_date DATE,
    next_review_due_date DATE,
    total_active_leasing_contracts INT,
    outstanding_leasing_exposure_eur DECIMAL(18,2),
    ytd_leasing_volume_eur DECIMAL(18,2),
    prior_year_leasing_volume_eur DECIMAL(18,2),
    average_margin_bps DECIMAL(7,2),
    average_ticket_size_eur DECIMAL(18,2),
    agent_expertise_segments ARRAY<STRING>,
    supported_product_types ARRAY<STRING>,
    preferred_contact_channel STRING,
    marketing_consent_flag BOOLEAN NOT NULL,
    marketing_consent_last_updated TIMESTAMP,
    data_privacy_classification STRING NOT NULL,
    gdpr_data_subject_flag BOOLEAN NOT NULL,
    last_activity_timestamp TIMESTAMP,
    agent_risk_rating STRING,
    commission_scheme_code STRING,
    default_commission_rate_bps DECIMAL(7,2),
    agent_profitability_score DECIMAL(5,2),
    agent_notes STRING,
    source_system_code STRING NOT NULL,
    record_created_timestamp TIMESTAMP NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_authorized_finance_a PRIMARY KEY (id)
);


