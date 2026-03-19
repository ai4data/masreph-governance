-- ============================================
-- Platform: MYSQL
-- Schema/Source: sendgrid
-- Generated: 2026-03-18T12:18:01.999760
-- Datasets: 3
-- ============================================

-- Dataset: GDS40760

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `finance_email_analytics` (
    id INT NOT NULL,
    email_event_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    client_segment_code VARCHAR(255),
    email_message_id VARCHAR(255) NOT NULL,
    email_direction VARCHAR(255) NOT NULL,
    sender_email_address VARCHAR(320) NOT NULL,
    recipient_email_address VARCHAR(320) NOT NULL,
    cc_recipient_count INT,
    email_subject VARCHAR(255),
    email_sent_timestamp DATETIME NOT NULL,
    email_open_timestamp DATETIME,
    email_click_timestamp DATETIME,
    email_delivery_status VARCHAR(255) NOT NULL,
    bounce_reason_code VARCHAR(255),
    is_marketing_communication TINYINT(1) NOT NULL,
    marketing_consent_status VARCHAR(255),
    campaign_id VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    mobility_product_type VARCHAR(255),
    estimated_email_related_revenue DECIMAL(15,2),
    client_lifetime_value_segment VARCHAR(255),
    client_country_code VARCHAR(255) NOT NULL,
    email_language_code VARCHAR(255),
    client_response_flag TINYINT(1) NOT NULL,
    response_channel_type VARCHAR(320),
    gdpr_anonymization_flag TINYINT(1) NOT NULL,
    email_client_device_type VARCHAR(255),
    email_engagement_score DECIMAL(5,2),
    email_topic_classification VARCHAR(255),
    compliance_review_status VARCHAR(255),
    created_at DATETIME
    ,CONSTRAINT PK_finance_email_analyt PRIMARY KEY (id)
);


-- Dataset: GDS45952

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `finance_email_analytics` (
    id INT NOT NULL,
    dataset_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    client_email_address VARCHAR(320) NOT NULL,
    email_message_id VARCHAR(255) NOT NULL,
    email_thread_id VARCHAR(255),
    email_direction VARCHAR(255) NOT NULL,
    email_subject_normalized VARCHAR(255),
    email_body_classification VARCHAR(255),
    email_category VARCHAR(255),
    email_sent_timestamp DATETIME,
    email_received_timestamp DATETIME,
    email_open_timestamp DATETIME,
    email_first_click_timestamp DATETIME,
    email_open_count INT NOT NULL,
    email_click_count INT NOT NULL,
    email_bounce_flag TINYINT(1) NOT NULL,
    email_bounce_type VARCHAR(255),
    email_delivery_status VARCHAR(255) NOT NULL,
    email_spam_flag TINYINT(1) NOT NULL,
    email_priority_flag TINYINT(1) NOT NULL,
    email_language_code VARCHAR(255),
    client_consent_marketing_email TINYINT(1) NOT NULL,
    client_consent_timestamp DATETIME,
    client_segment_code VARCHAR(255),
    product_interest_codes JSON,
    relationship_manager_id VARCHAR(255),
    relationship_manager_region VARCHAR(255),
    client_lifecycle_stage VARCHAR(255),
    client_profitability_score DECIMAL(5,2),
    client_revenue_rolling_12m DECIMAL(15,2),
    email_response_time_seconds INT,
    is_client_reply TINYINT(1) NOT NULL,
    original_campaign_id VARCHAR(255),
    campaign_channel_source VARCHAR(255),
    client_risk_rating VARCHAR(255),
    client_country_code VARCHAR(255),
    pii_hash_key VARCHAR(255) NOT NULL,
    message_sent_from_domain VARCHAR(255),
    message_sent_to_domain VARCHAR(255),
    email_attachment_count INT NOT NULL,
    email_attachment_types JSON,
    complaint_indicator TINYINT(1) NOT NULL,
    service_request_created_flag TINYINT(1) NOT NULL,
    created_at_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_finance_email_analyt PRIMARY KEY (id)
);


-- Dataset: GDS67347

-- This client dataset supports commercial finance operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `finance_email_analytics` (
    id INT NOT NULL,
    dataset_record_id CHAR(36) NOT NULL,
    masreph_client_id VARCHAR(255) NOT NULL,
    client_legal_name VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    relationship_manager_name VARCHAR(255),
    email_thread_id VARCHAR(255) NOT NULL,
    email_message_id VARCHAR(255) NOT NULL,
    email_direction VARCHAR(255) NOT NULL,
    email_subject VARCHAR(255),
    email_sent_timestamp DATETIME NOT NULL,
    email_received_timestamp DATETIME,
    sender_email_address VARCHAR(320) NOT NULL,
    recipient_email_addresses VARCHAR(320) NOT NULL,
    cc_email_addresses VARCHAR(320),
    email_importance_flag TINYINT(1) NOT NULL,
    email_language_code VARCHAR(255),
    email_body_token_count INT,
    email_contains_financial_terms_flag TINYINT(1) NOT NULL,
    email_financing_product_category VARCHAR(255),
    email_response_time_minutes INT,
    client_engagement_score DECIMAL(5,2),
    potential_revenue_12m_eur DECIMAL(15,2),
    email_sent_business_unit VARCHAR(255),
    email_contains_pii_flag TINYINT(1) NOT NULL,
    email_retention_expiry_date DATE,
    last_engagement_channel VARCHAR(320),
    gdpr_legal_basis_code VARCHAR(255) NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_finance_email_analyt PRIMARY KEY (id)
);


