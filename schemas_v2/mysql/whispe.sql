-- ============================================
-- Platform: MYSQL
-- Schema/Source: whispe
-- Generated: 2026-03-18T11:58:31.410309
-- Datasets: 1
-- ============================================

-- Dataset: GDS69369

-- Retail banking customer master data and interaction-time attributes used for segmentation, value, ri
CREATE TABLE IF NOT EXISTS `customer` (
    customer_id VARCHAR(255) NOT NULL,
    customer_segment VARCHAR(255),
    primary_product_relationship VARCHAR(255),
    churn_risk_score DECIMAL(18,4),
    customer_lifetime_value_score DECIMAL(18,4),
    customer_tenure_months INT,
    preferred_contact_channel VARCHAR(255),
    gdpr_consent_status VARCHAR(255),
    last_product_purchase_date DATE,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_customer PRIMARY KEY (customer_id)
);

-- Call center agent master data including regional assignment for performance and coverage analytics.
CREATE TABLE IF NOT EXISTS `agent` (
    agent_id VARCHAR(255),
    agent_region_code VARCHAR(255),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_agent PRIMARY KEY (agent_id)
);

-- Individual call center interactions enriched with operational metrics, sentiment, commercial impact 
CREATE TABLE IF NOT EXISTS `call_interaction` (
    call_interaction_id VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    agent_id VARCHAR(255),
    call_start_timestamp DATETIME NOT NULL,
    call_end_timestamp DATETIME,
    call_duration_seconds INT,
    call_reason_category VARCHAR(255),
    call_disposition_status VARCHAR(255),
    sentiment_score DECIMAL(18,4),
    cross_sell_offer_made_flag TINYINT(1) NOT NULL,
    cross_sell_products_offered JSON,
    revenue_impact_amount DECIMAL(18,4),
    complaint_flag TINYINT(1) NOT NULL,
    first_contact_resolution_flag TINYINT(1),
    call_transcript_redacted TEXT,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_call_interaction PRIMARY KEY (call_interaction_id)
);

ALTER TABLE whispe.call_interaction ADD CONSTRAINT FK_call_interaction_customer_i
    FOREIGN KEY (customer_id) REFERENCES whispe.customer (customer_id);

ALTER TABLE whispe.call_interaction ADD CONSTRAINT FK_call_interaction_agent_id
    FOREIGN KEY (agent_id) REFERENCES whispe.agent (agent_id);


