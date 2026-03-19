-- ============================================
-- Platform: MYSQL
-- Schema/Source: email_analytics
-- Generated: 2026-03-18T12:18:01.995488
-- Datasets: 2
-- ============================================

-- Dataset: GDS16209

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `finance_email_analytics` (
    id INT NOT NULL,
    email_event_id CHAR(36) NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    client_global_id VARCHAR(255),
    email_address_hashed VARCHAR(255) NOT NULL,
    email_address_domain VARCHAR(255),
    email_campaign_id VARCHAR(255),
    email_campaign_name VARCHAR(255),
    email_channel_source VARCHAR(255) NOT NULL,
    email_sent_timestamp DATETIME NOT NULL,
    email_delivered_timestamp DATETIME,
    email_open_timestamp_first DATETIME,
    email_open_count INT NOT NULL,
    email_click_count INT NOT NULL,
    email_bounce_flag TINYINT(1) NOT NULL,
    email_bounce_reason VARCHAR(255),
    email_unsubscribe_flag TINYINT(1) NOT NULL,
    marketing_consent_status VARCHAR(255) NOT NULL,
    marketing_consent_timestamp DATETIME,
    relationship_manager_id VARCHAR(255),
    relationship_segment_code VARCHAR(255),
    product_interest_category VARCHAR(255),
    client_profitability_segment VARCHAR(255),
    client_region_code VARCHAR(255),
    client_country_iso2 VARCHAR(255),
    preferred_language_code VARCHAR(255),
    device_type VARCHAR(255),
    email_client_name VARCHAR(255),
    email_read_duration_seconds INT,
    time_to_first_open_seconds INT,
    click_through_revenue_estimate DECIMAL(15,2) NOT NULL,
    client_lifecycle_stage VARCHAR(255),
    service_issue_indicator TINYINT(1) NOT NULL,
    service_issue_category VARCHAR(255),
    sentiment_score DECIMAL(3,2),
    sentiment_classification VARCHAR(255),
    gdpr_erasure_requested_flag TINYINT(1) NOT NULL,
    data_processing_legal_basis VARCHAR(255) NOT NULL,
    event_ingestion_timestamp DATETIME NOT NULL,
    email_metadata_json JSON,
    created_at DATETIME
    ,CONSTRAINT PK_finance_email_analyt PRIMARY KEY (id)
);


-- Dataset: GDS95028

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `finance_email_analytics` (
    id INT NOT NULL,
    record_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    masreph_customer_uid VARCHAR(255) NOT NULL,
    email_message_id VARCHAR(255) NOT NULL,
    email_thread_id VARCHAR(255),
    email_subject VARCHAR(255),
    email_direction VARCHAR(255) NOT NULL,
    sender_email_address VARCHAR(320) NOT NULL,
    recipient_email_address VARCHAR(320) NOT NULL,
    recipient_client_id VARCHAR(255),
    cc_recipient_count INT,
    bcc_recipient_count INT,
    email_sent_timestamp DATETIME NOT NULL,
    email_received_timestamp DATETIME,
    email_open_timestamp DATETIME,
    email_first_click_timestamp DATETIME,
    email_last_interaction_timestamp DATETIME,
    email_delivery_status VARCHAR(255) NOT NULL,
    email_bounce_type VARCHAR(255),
    email_spam_flag TINYINT(1) NOT NULL,
    email_priority_level VARCHAR(255),
    email_channel_source VARCHAR(255) NOT NULL,
    email_language_code VARCHAR(255),
    email_body_tokenized JSON,
    email_category VARCHAR(255),
    mobility_product_segment VARCHAR(255),
    auto_loan_account_flag TINYINT(1) NOT NULL,
    relationship_manager_id VARCHAR(255),
    relationship_stage VARCHAR(255),
    client_value_tier VARCHAR(255),
    email_response_time_seconds INT,
    email_thread_length INT,
    sentiment_score DECIMAL(5,2),
    revenue_opportunity_eur DECIMAL(15,2),
    profitability_score DECIMAL(6,3),
    gdpr_marketing_consent_flag TINYINT(1) NOT NULL,
    last_consent_update_date DATE,
    client_geography_region VARCHAR(255),
    device_type VARCHAR(255),
    client_mobility_profile JSON,
    pii_redaction_applied_flag TINYINT(1) NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    record_create_timestamp DATETIME NOT NULL,
    record_update_timestamp DATETIME,
    created_at DATETIME
    ,CONSTRAINT PK_finance_email_analyt PRIMARY KEY (id)
);


