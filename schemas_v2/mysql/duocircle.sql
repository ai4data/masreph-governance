-- ============================================
-- Platform: MYSQL
-- Schema/Source: duocircle
-- Generated: 2026-03-18T12:18:01.993567
-- Datasets: 1
-- ============================================

-- Dataset: GDS10355

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `client_email_feedback_dataset` (
    id INT NOT NULL,
    feedback_id CHAR(36) NOT NULL,
    client_id VARCHAR(255) NOT NULL,
    email_message_id VARCHAR(255) NOT NULL,
    email_received_timestamp DATETIME NOT NULL,
    email_subject_line VARCHAR(255),
    email_body_redacted VARCHAR(255) NOT NULL,
    client_email_address_hash VARCHAR(255) NOT NULL,
    product_relationship_category VARCHAR(255),
    sentiment_score DECIMAL(5,2),
    sentiment_label VARCHAR(255),
    nps_feedback_score INT,
    client_profitability_segment VARCHAR(255),
    csat_rating_derived DECIMAL(3,1),
    follow_up_required_flag TINYINT(1) NOT NULL,
    case_reference_id VARCHAR(255),
    first_response_timestamp DATETIME,
    response_time_minutes INT,
    feedback_topics JSON,
    gdpr_erasure_requested_flag TINYINT(1) NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_client_email_feedbac PRIMARY KEY (id)
);


