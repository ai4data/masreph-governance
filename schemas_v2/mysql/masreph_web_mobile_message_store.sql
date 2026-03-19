-- ============================================
-- Platform: MYSQL
-- Schema/Source: masreph_web_mobile_message_store
-- Generated: 2026-03-18T11:58:31.404623
-- Datasets: 1
-- ============================================

-- Dataset: GDS63931

-- Core client entity for mobility and CRM analytics, storing stable client-level identifiers, segmenta
CREATE TABLE IF NOT EXISTS `client` (
    id BIGINT NOT NULL,
    client_internal_id VARCHAR(255) NOT NULL,
    client_external_reference VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    client_segment_code VARCHAR(255),
    client_country_iso2 VARCHAR(255) NOT NULL,
    gdpr_marketing_consent_indicator TINYINT(1),
    marketing_consent_effective_date DATE,
    marketing_consent_source VARCHAR(255),
    client_profitability_score_12m DECIMAL(18,4),
    relationship_value_tier VARCHAR(255),
    cross_sell_propensity_score DECIMAL(18,4),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_client PRIMARY KEY (id)
);

-- Conversation-level entity representing a secure messaging thread between a client and the bank, incl
CREATE TABLE IF NOT EXISTS `secure_message_thread` (
    id BIGINT NOT NULL,
    secure_thread_id VARCHAR(255) NOT NULL,
    client_id BIGINT NOT NULL,
    product_category VARCHAR(255),
    mobility_finance_product_type VARCHAR(255),
    auto_loan_account_id VARCHAR(255),
    resolution_ts DATETIME,
    resolution_elapsed_seconds INT,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_secure_message_threa PRIMARY KEY (id)
);

-- Fact table at secure message level containing content, sentiment, compliance, operational, and risk 
CREATE TABLE IF NOT EXISTS `secure_message_analytic` (
    dataset_message_id VARCHAR(255) NOT NULL,
    thread_id BIGINT NOT NULL,
    secure_message_id VARCHAR(255) NOT NULL,
    parent_message_id VARCHAR(255),
    message_direction VARCHAR(255) NOT NULL,
    message_channel VARCHAR(255) NOT NULL,
    message_subject VARCHAR(255),
    message_body_text TEXT NOT NULL,
    message_language_code VARCHAR(255) NOT NULL,
    message_creation_ts DATETIME NOT NULL,
    message_received_ts DATETIME NOT NULL,
    message_sentiment_score DECIMAL(18,4),
    message_sentiment_label VARCHAR(255),
    compliance_flagged_indicator TINYINT(1) NOT NULL,
    compliance_flag_reason_codes JSON,
    pii_detected_indicator TINYINT(1) NOT NULL,
    service_issue_indicator TINYINT(1) NOT NULL,
    service_issue_category VARCHAR(255),
    response_required_indicator TINYINT(1) NOT NULL,
    first_response_ts DATETIME,
    first_response_elapsed_seconds INT,
    message_priority_code VARCHAR(255) NOT NULL,
    message_read_indicator TINYINT(1) NOT NULL,
    attachment_present_indicator TINYINT(1) NOT NULL,
    attachment_count INT NOT NULL,
    mobility_channel_source VARCHAR(255),
    client_device_type VARCHAR(255),
    risk_alert_generated_indicator TINYINT(1) NOT NULL,
    risk_alert_severity_code VARCHAR(255),
    data_masking_applied_indicator TINYINT(1) NOT NULL,
    record_creation_ts DATETIME NOT NULL,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_secure_message_analy PRIMARY KEY (dataset_message_id)
);

ALTER TABLE masreph_web_mobile_message_store.secure_message_thread ADD CONSTRAINT FK_secure_message_thread_clien
    FOREIGN KEY (client_id) REFERENCES masreph_web_mobile_message_store.client (id);

ALTER TABLE masreph_web_mobile_message_store.secure_message_analytic ADD CONSTRAINT FK_secure_message_analytic_thr
    FOREIGN KEY (thread_id) REFERENCES masreph_web_mobile_message_store.secure_message_thread (id);


