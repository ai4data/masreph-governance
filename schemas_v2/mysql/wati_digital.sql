-- ============================================
-- Platform: MYSQL
-- Schema/Source: wati_digital
-- Generated: 2026-03-18T11:58:31.394574
-- Datasets: 1
-- ============================================

-- Dataset: GDS38798

-- Digital finance messages linked to Masreph clients, channels, and profitability attributes for CRM a
CREATE TABLE IF NOT EXISTS `digital_finance_message` (
    message_id VARCHAR(255) NOT NULL,
    client_masreph_id VARCHAR(255) NOT NULL,
    primary_account_iban VARCHAR(255),
    message_timestamp DATETIME NOT NULL,
    digital_channel_type VARCHAR(255) NOT NULL,
    message_direction VARCHAR(255) NOT NULL,
    related_transaction_amount DECIMAL(18,4),
    message_sentiment_score DECIMAL(18,4),
    contains_personal_data_flag TINYINT(1) NOT NULL,
    marketing_consent_status VARCHAR(255) NOT NULL,
    client_profitability_segment VARCHAR(255),
    interaction_topic_tags JSON,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_digital_finance_mess PRIMARY KEY (message_id)
);


