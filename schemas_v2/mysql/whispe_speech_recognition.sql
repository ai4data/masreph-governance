-- ============================================
-- Platform: MYSQL
-- Schema/Source: whispe_speech_recognition
-- Generated: 2026-03-18T12:18:02.002850
-- Datasets: 1
-- ============================================

-- Dataset: GDS69369

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `call_insight_finance_dataset` (
    id INT NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    call_interaction_id CHAR(36) NOT NULL,
    customer_segment VARCHAR(255),
    primary_product_relationship VARCHAR(255),
    call_start_timestamp DATETIME NOT NULL,
    call_end_timestamp DATETIME,
    call_duration_seconds INT,
    call_reason_category VARCHAR(255),
    call_disposition_status VARCHAR(255),
    agent_id VARCHAR(255),
    agent_region_code VARCHAR(255),
    sentiment_score DECIMAL(3,2),
    cross_sell_offer_made_flag TINYINT(1) NOT NULL,
    cross_sell_products_offered JSON,
    revenue_impact_amount DECIMAL(15,2),
    churn_risk_score DECIMAL(5,4),
    complaint_flag TINYINT(1) NOT NULL,
    first_contact_resolution_flag TINYINT(1),
    customer_lifetime_value_score DECIMAL(15,2),
    customer_tenure_months INT,
    preferred_contact_channel VARCHAR(255),
    gdpr_consent_status VARCHAR(255),
    last_product_purchase_date DATE,
    call_transcript_redacted VARCHAR(255),
    created_at DATETIME
    ,CONSTRAINT PK_call_insight_finance PRIMARY KEY (id)
);


