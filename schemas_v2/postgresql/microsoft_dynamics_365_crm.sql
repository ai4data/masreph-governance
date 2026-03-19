-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: microsoft_dynamics_365_crm
-- Generated: 2026-03-18T12:17:47.449814
-- Datasets: 1
-- ============================================

-- Dataset: GDS76892
CREATE SCHEMA IF NOT EXISTS microsoft_dynamics_365_crm;

-- Core client insight records for commercial finance operations, one row per client entity.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365_crm.clients (
    client_id VARCHAR(255) NOT NULL,
    masreph_customer_number VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    client_segment_id INTEGER NOT NULL,
    relationship_manager_id INTEGER NOT NULL,
    industry_sector_id INTEGER NOT NULL,
    country_of_domicile VARCHAR(255) NOT NULL,
    onboarding_date DATE NOT NULL,
    kyc_review_date DATE,
    client_risk_rating VARCHAR(255),
    client_risk_category VARCHAR(255),
    is_sanctions_screening_active BOOLEAN NOT NULL,
    primary_contact_email VARCHAR(255),
    primary_contact_phone VARCHAR(255),
    annual_revenue_eur NUMERIC(18,4),
    total_outstanding_credit_eur NUMERIC(18,4),
    average_account_balance_eur NUMERIC(18,4),
    client_profitability_score NUMERIC(18,4),
    last_interaction_timestamp TIMESTAMPTZ,
    preferred_communication_channel VARCHAR(255),
    consent_marketing_communications BOOLEAN NOT NULL,
    digital_engagement_score NUMERIC(18,4),
    cross_sell_opportunity_flag BOOLEAN NOT NULL,
    cross_sell_opportunity_notes VARCHAR(255),
    key_products_held JSONB,
    relationship_tenure_years NUMERIC(18,4),
    client_status_code VARCHAR(255) NOT NULL,
    client_preference_profile JSONB,
    data_last_refreshed_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_clients PRIMARY KEY (client_id)
);

-- Reference data for internal client segment classifications used for commercial banking coverage and 
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365_crm.client_segments (
    client_segment_id INTEGER NOT NULL,
    client_segment_code VARCHAR(255) NOT NULL,
    client_segment_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_client_segments PRIMARY KEY (client_segment_id)
);

-- Reference data for standardized industry sector classifications (e.g., NACE) used for risk and profi
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365_crm.industry_sectors (
    industry_sector_id INTEGER NOT NULL,
    industry_sector_code VARCHAR(255) NOT NULL,
    industry_sector_description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_industry_sectors PRIMARY KEY (industry_sector_id)
);

-- Reference data for primary relationship managers responsible for commercial client relationships.
CREATE TABLE IF NOT EXISTS microsoft_dynamics_365_crm.relationship_managers (
    relationship_manager_id INTEGER NOT NULL,
    relationship_manager_code VARCHAR(255) NOT NULL,
    relationship_manager_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_relationship_manager PRIMARY KEY (relationship_manager_id)
);

ALTER TABLE microsoft_dynamics_365_crm.clients ADD CONSTRAINT FK_clients_client_segment_id
    FOREIGN KEY (client_segment_id) REFERENCES microsoft_dynamics_365_crm.client_segments (client_segment_id);

ALTER TABLE microsoft_dynamics_365_crm.clients ADD CONSTRAINT FK_clients_industry_sector_id
    FOREIGN KEY (industry_sector_id) REFERENCES microsoft_dynamics_365_crm.industry_sectors (industry_sector_id);

ALTER TABLE microsoft_dynamics_365_crm.clients ADD CONSTRAINT FK_clients_relationship_manage
    FOREIGN KEY (relationship_manager_id) REFERENCES microsoft_dynamics_365_crm.relationship_managers (relationship_manager_id);


