-- ============================================
-- Platform: MYSQL
-- Schema/Source: web_mobile_message_store
-- Generated: 2026-03-18T12:18:01.998472
-- Datasets: 3
-- ============================================

-- Dataset: GDS37743

-- This client dataset supports commercial finance operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `finance_message_data` (
    id INT NOT NULL,
    message_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    counterparty_contact_id VARCHAR(255),
    relationship_manager_id VARCHAR(255) NOT NULL,
    message_channel VARCHAR(320) NOT NULL,
    message_direction VARCHAR(255) NOT NULL,
    message_subject VARCHAR(255),
    message_body_summary VARCHAR(255),
    message_language_code VARCHAR(255),
    message_sent_timestamp DATETIME NOT NULL,
    message_received_timestamp DATETIME,
    client_timezone VARCHAR(255),
    client_segment_code VARCHAR(255),
    industry_sector_code VARCHAR(255),
    country_of_risk_code VARCHAR(255),
    message_topic_category VARCHAR(255),
    product_family_code VARCHAR(255),
    deal_opportunity_id VARCHAR(255),
    associated_facility_id VARCHAR(255),
    referenced_amount DECIMAL(18,2),
    referenced_currency_code VARCHAR(255),
    client_profitability_tier VARCHAR(255),
    message_priority_flag TINYINT(1) NOT NULL,
    requires_follow_up_flag TINYINT(1) NOT NULL,
    next_action_due_date DATE,
    message_read_flag TINYINT(1),
    message_response_time_seconds INT,
    gdpr_personal_data_flag TINYINT(1) NOT NULL,
    marketing_consent_status VARCHAR(255),
    pii_redaction_status VARCHAR(255) NOT NULL,
    sentiment_score DECIMAL(5,2),
    conversation_thread_id VARCHAR(255),
    created_in_source_system_code VARCHAR(320) NOT NULL,
    record_last_updated_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_finance_message_data PRIMARY KEY (id)
);


-- Dataset: GDS51167

-- This client dataset supports leasing operations. Key applications include relationship management, c
CREATE TABLE IF NOT EXISTS `finance_message_data` (
    id INT NOT NULL,
    message_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    counterparty_legal_name VARCHAR(255) NOT NULL,
    message_channel VARCHAR(320) NOT NULL,
    message_direction VARCHAR(255) NOT NULL,
    message_type VARCHAR(255) NOT NULL,
    message_subject VARCHAR(255),
    message_body_excerpt VARCHAR(255),
    message_timestamp DATETIME NOT NULL,
    message_language VARCHAR(255),
    client_segment_code VARCHAR(255),
    client_relationship_manager_id VARCHAR(255),
    related_contract_id VARCHAR(255),
    message_priority VARCHAR(255) NOT NULL,
    requires_follow_up TINYINT(1) NOT NULL,
    follow_up_due_date DATE,
    resolved_timestamp DATETIME,
    resolution_status VARCHAR(255) NOT NULL,
    escalation_level INT,
    client_preferred_channel VARCHAR(320),
    client_country_of_domicile VARCHAR(255),
    gdpr_marketing_consent_flag TINYINT(1) NOT NULL,
    gdpr_consent_capture_timestamp DATETIME,
    client_profitability_score DECIMAL(5,2),
    estimated_message_revenue_impact DECIMAL(15,2),
    potential_leasing_volume DECIMAL(18,2),
    currency_code VARCHAR(255),
    related_swift_message_type VARCHAR(255),
    client_contact_email_hash VARCHAR(255),
    client_contact_phone_hash VARCHAR(255),
    interaction_sentiment_score DECIMAL(3,2),
    interaction_topic_tags JSON,
    crm_case_id VARCHAR(255),
    service_level_breach_flag TINYINT(1) NOT NULL,
    created_by_system VARCHAR(255) NOT NULL,
    last_updated_timestamp DATETIME NOT NULL,
    data_classification_level VARCHAR(255) NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_finance_message_data PRIMARY KEY (id)
);


-- Dataset: GDS63931

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `secure_message_analytics` (
    id INT NOT NULL,
    dataset_message_id CHAR(36) NOT NULL,
    client_internal_id VARCHAR(255) NOT NULL,
    client_external_reference VARCHAR(255),
    relationship_manager_id VARCHAR(255),
    secure_thread_id VARCHAR(255) NOT NULL,
    secure_message_id VARCHAR(255) NOT NULL,
    parent_message_id VARCHAR(255),
    message_direction VARCHAR(255) NOT NULL,
    message_channel VARCHAR(255) NOT NULL,
    message_subject VARCHAR(255),
    message_body_text VARCHAR(255) NOT NULL,
    message_language_code VARCHAR(255) NOT NULL,
    message_creation_ts DATETIME NOT NULL,
    message_received_ts DATETIME NOT NULL,
    client_segment_code VARCHAR(255),
    client_country_iso2 VARCHAR(255) NOT NULL,
    product_category VARCHAR(255),
    mobility_finance_product_type VARCHAR(255),
    auto_loan_account_id VARCHAR(255),
    message_sentiment_score DECIMAL(5,4),
    message_sentiment_label VARCHAR(255),
    compliance_flagged_indicator TINYINT(1) NOT NULL,
    compliance_flag_reason_codes JSON,
    pii_detected_indicator TINYINT(1) NOT NULL,
    gdpr_marketing_consent_indicator TINYINT(1),
    marketing_consent_effective_date DATE,
    marketing_consent_source VARCHAR(255),
    client_profitability_score_12m DECIMAL(10,2),
    relationship_value_tier VARCHAR(255),
    cross_sell_propensity_score DECIMAL(5,4),
    service_issue_indicator TINYINT(1) NOT NULL,
    service_issue_category VARCHAR(255),
    response_required_indicator TINYINT(1) NOT NULL,
    first_response_ts DATETIME,
    first_response_elapsed_seconds INT,
    resolution_ts DATETIME,
    resolution_elapsed_seconds INT,
    message_priority_code VARCHAR(255) NOT NULL,
    message_read_indicator TINYINT(1) NOT NULL,
    attachment_present_indicator TINYINT(1) NOT NULL,
    attachment_count INT NOT NULL,
    mobility_channel_source VARCHAR(255),
    client_device_type VARCHAR(30),
    risk_alert_generated_indicator TINYINT(1) NOT NULL,
    risk_alert_severity_code VARCHAR(255),
    data_masking_applied_indicator TINYINT(1) NOT NULL,
    record_creation_ts DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_secure_message_analy PRIMARY KEY (id)
);


