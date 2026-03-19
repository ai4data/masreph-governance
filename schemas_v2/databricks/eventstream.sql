-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: eventstream
-- Generated: 2026-03-18T12:18:16.842285
-- Datasets: 2
-- ============================================

-- Dataset: GDS29104
CREATE SCHEMA IF NOT EXISTS eventstream;

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS eventstream.finance360_customer_journey (
    id INT NOT NULL,
    dataset_customer_journey_id STRING NOT NULL,
    masreph_client_id STRING NOT NULL,
    external_crm_customer_id STRING,
    customer_lifecycle_stage STRING NOT NULL,
    customer_segment_code STRING,
    primary_mobility_product_type STRING,
    onboarding_channel STRING,
    onboarding_date DATE,
    first_product_activation_timestamp TIMESTAMP,
    home_country_code STRING,
    residency_status STRING,
    gdpr_consent_marketing_flag BOOLEAN NOT NULL,
    gdpr_consent_timestamp TIMESTAMP,
    preferred_communication_channel STRING,
    relationship_manager_id STRING,
    relationship_manager_region STRING,
    total_active_auto_loans_count INT NOT NULL,
    total_active_auto_loans_balance DECIMAL(15,2) NOT NULL,
    avg_monthly_mobility_spend_amount DECIMAL(13,2),
    last_12m_mobility_revenue_amount DECIMAL(15,2),
    customer_profitability_score DECIMAL(5,2),
    churn_risk_score DECIMAL(5,2),
    cross_sell_propensity_score DECIMAL(5,2),
    last_contact_timestamp TIMESTAMP,
    last_contact_channel STRING,
    last_contact_outcome_code STRING,
    net_promoter_score INT,
    customer_satisfaction_index DECIMAL(5,2),
    mobility_usage_pattern_json MAP<STRING, STRING>,
    interaction_history_events ARRAY<STRING>,
    risk_rating_internal STRING,
    kyc_review_due_date DATE,
    customer_tenure_days INT,
    is_fleet_customer_flag BOOLEAN NOT NULL,
    fleet_size_estimate INT,
    preferred_dealer_network_code STRING,
    last_vehicle_purchase_date DATE,
    next_renewal_event_date DATE,
    delinq_30d_flag BOOLEAN NOT NULL,
    delinq_90d_flag BOOLEAN NOT NULL,
    collections_status_code STRING,
    last_payment_timestamp TIMESTAMP,
    avg_days_past_due DECIMAL(6,2),
    digital_engagement_score DECIMAL(5,2),
    mobile_app_active_flag BOOLEAN NOT NULL,
    data_record_source_system STRING NOT NULL,
    data_record_created_timestamp TIMESTAMP NOT NULL,
    data_record_updated_timestamp TIMESTAMP,
    record_partition_date DATE NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance360_customer_ PRIMARY KEY (id)
);


-- Dataset: GDS52932
CREATE SCHEMA IF NOT EXISTS eventstream;

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS eventstream.finance360_customer_journey (
    id INT NOT NULL,
    customer_journey_id STRING NOT NULL,
    customer_id_hash STRING NOT NULL,
    crm_party_id STRING NOT NULL,
    mortgage_account_id STRING,
    lead_source_channel STRING,
    customer_segment_code STRING,
    customer_risk_band STRING,
    primary_product_holding STRING,
    relationship_manager_id STRING,
    first_contact_date DATE,
    latest_interaction_timestamp TIMESTAMP,
    mortgage_application_id STRING,
    mortgage_application_stage STRING,
    application_submission_date DATE,
    application_decision_timestamp TIMESTAMP,
    application_decision_outcome STRING,
    booked_mortgage_principal_amount DECIMAL(15,2),
    booked_mortgage_interest_rate DECIMAL(5,3),
    current_mortgage_balance_amount DECIMAL(15,2),
    mortgage_product_type STRING,
    property_usage_type STRING,
    customer_lifecycle_stage STRING,
    customer_tenure_days INT,
    total_relationship_revenue_amount DECIMAL(15,2),
    total_relationship_cost_amount DECIMAL(15,2),
    customer_profitability_score DECIMAL(6,3),
    cross_sell_propensity_score DECIMAL(5,4),
    churn_risk_score DECIMAL(5,4),
    digital_engagement_score DECIMAL(6,2),
    consent_marketing_communications_flag BOOLEAN NOT NULL,
    consent_data_processing_flag BOOLEAN NOT NULL,
    last_marketing_contact_timestamp TIMESTAMP,
    preferred_contact_channel STRING,
    complaint_indicator_flag BOOLEAN NOT NULL,
    last_complaint_date DATE,
    net_promoter_score INT,
    number_of_active_products INT,
    missed_payment_in_last_12m_flag BOOLEAN NOT NULL,
    last_payment_due_date DATE,
    last_payment_received_date DATE,
    data_record_created_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance360_customer_ PRIMARY KEY (id)
);


