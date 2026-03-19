-- ============================================
-- Platform: MYSQL
-- Schema/Source: ms_office
-- Generated: 2026-03-18T12:18:01.997474
-- Datasets: 1
-- ============================================

-- Dataset: GDS31408

-- This client dataset supports innovation & technology operations. Key applications include relationsh
CREATE TABLE IF NOT EXISTS `finance_call_insights` (
    id INT NOT NULL,
    call_insight_id CHAR(36) NOT NULL,
    call_recording_id VARCHAR(255) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    client_legal_name VARCHAR(255) NOT NULL,
    client_segment VARCHAR(255) NOT NULL,
    client_industry_code VARCHAR(255),
    relationship_manager_id VARCHAR(255) NOT NULL,
    relationship_manager_name VARCHAR(255) NOT NULL,
    call_direction VARCHAR(255) NOT NULL,
    call_purpose_code VARCHAR(255) NOT NULL,
    call_purpose_description VARCHAR(255),
    call_start_timestamp DATETIME NOT NULL,
    call_end_timestamp DATETIME NOT NULL,
    call_duration_seconds INT NOT NULL,
    call_language_code VARCHAR(255),
    call_channel VARCHAR(30) NOT NULL,
    calling_country_iso2 VARCHAR(255),
    client_region VARCHAR(255) NOT NULL,
    client_revenue_band VARCHAR(255),
    client_profitability_score DECIMAL(5,2),
    cross_sell_opportunity_flag TINYINT(1) NOT NULL,
    upsell_opportunity_flag TINYINT(1) NOT NULL,
    churn_risk_score DECIMAL(5,4),
    sentiment_score DECIMAL(4,2),
    sentiment_trend VARCHAR(255),
    topics_detected JSON,
    action_items JSON,
    next_best_action_code VARCHAR(255),
    next_best_action_description VARCHAR(255),
    follow_up_required_flag TINYINT(1) NOT NULL,
    follow_up_due_date DATE,
    follow_up_owner_id VARCHAR(255),
    complaint_indicator TINYINT(1) NOT NULL,
    complaint_severity_code VARCHAR(255),
    regulatory_disclosure_made_flag TINYINT(1),
    pii_redaction_status VARCHAR(255) NOT NULL,
    gdpr_consent_status VARCHAR(255),
    data_lineage_source_system VARCHAR(255) NOT NULL,
    recording_storage_location VARCHAR(255),
    transcript_quality_score DECIMAL(4,2),
    language_detection_confidence DECIMAL(4,2),
    talk_listen_ratio DECIMAL(5,2),
    interruption_count INT,
    overlapping_speaker_indicator TINYINT(1),
    created_at DATETIME
    ,CONSTRAINT PK_finance_call_insight PRIMARY KEY (id)
);


