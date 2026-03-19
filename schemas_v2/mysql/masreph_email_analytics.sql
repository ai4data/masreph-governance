-- ============================================
-- Platform: MYSQL
-- Schema/Source: masreph_email_analytics
-- Generated: 2026-03-18T11:58:31.417020
-- Datasets: 1
-- ============================================

-- Dataset: GDS95028

-- Email-level analytics facts for Masreph mobility finance communications, including delivery, engagem
CREATE TABLE IF NOT EXISTS `email_analytics_record` (
    record_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    masreph_customer_uid VARCHAR(255) NOT NULL,
    email_message_id VARCHAR(255) NOT NULL,
    email_thread_id VARCHAR(255),
    email_subject VARCHAR(255),
    email_direction VARCHAR(255) NOT NULL,
    sender_email_address VARCHAR(255) NOT NULL,
    recipient_email_address VARCHAR(255) NOT NULL,
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
    sentiment_score DECIMAL(18,4),
    revenue_opportunity_eur DECIMAL(18,4),
    profitability_score DECIMAL(18,4),
    gdpr_marketing_consent_flag TINYINT(1) NOT NULL,
    last_consent_update_date DATE,
    client_geography_region VARCHAR(255),
    device_type VARCHAR(255),
    client_mobility_profile JSON,
    pii_redaction_applied_flag TINYINT(1) NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    record_create_timestamp DATETIME NOT NULL,
    record_update_timestamp DATETIME,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_email_analytics_reco PRIMARY KEY (record_id)
);


