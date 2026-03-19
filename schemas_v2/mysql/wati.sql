-- ============================================
-- Platform: MYSQL
-- Schema/Source: wati
-- Generated: 2026-03-18T12:18:01.998472
-- Datasets: 2
-- ============================================

-- Dataset: GDS38798

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `digital_finance_messages` (
    id INT NOT NULL,
    message_id CHAR(36) NOT NULL,
    client_masreph_id VARCHAR(255) NOT NULL,
    primary_account_iban VARCHAR(34),
    message_timestamp DATETIME NOT NULL,
    digital_channel_type VARCHAR(320) NOT NULL,
    message_direction VARCHAR(255) NOT NULL,
    related_transaction_amount DECIMAL(15,2),
    message_sentiment_score DECIMAL(5,4),
    contains_personal_data_flag TINYINT(1) NOT NULL,
    marketing_consent_status VARCHAR(255) NOT NULL,
    client_profitability_segment VARCHAR(255),
    interaction_topic_tags JSON,
    created_at DATETIME
    ,CONSTRAINT PK_digital_finance_mess PRIMARY KEY (id)
);


-- Dataset: GDS53228

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `secure_finance_messages` (
    id INT NOT NULL,
    secure_message_id CHAR(36) NOT NULL,
    client_master_id VARCHAR(255) NOT NULL,
    counterparty_institution_bic VARCHAR(255) NOT NULL,
    message_sent_timestamp DATETIME NOT NULL,
    message_received_timestamp DATETIME,
    encryption_algorithm_code VARCHAR(255) NOT NULL,
    message_ciphertext VARCHAR(255) NOT NULL,
    message_type_code VARCHAR(255) NOT NULL,
    mobility_product_category VARCHAR(255),
    client_profitability_score DECIMAL(7,3),
    estimated_message_revenue_eur DECIMAL(15,2),
    marketing_consent_flag TINYINT(1) NOT NULL,
    data_sharing_consent_flag TINYINT(1) NOT NULL,
    message_delivery_status VARCHAR(255) NOT NULL,
    relationship_manager_user_id VARCHAR(255),
    masreph_relationship_segment_code VARCHAR(255),
    created_at DATETIME
    ,CONSTRAINT PK_secure_finance_messa PRIMARY KEY (id)
);


