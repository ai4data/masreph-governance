-- ============================================
-- Platform: MYSQL
-- Schema/Source: startsida
-- Generated: 2026-03-18T12:18:01.994552
-- Datasets: 2
-- ============================================

-- Dataset: GDS14338

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `customer_info_finance` (
    id INT NOT NULL,
    customer_id CHAR(36) NOT NULL,
    customer_external_ref VARCHAR(255),
    customer_segment VARCHAR(255) NOT NULL,
    country_of_residence VARCHAR(255) NOT NULL,
    eu_gdpr_consent_flag TINYINT(1) NOT NULL,
    primary_contact_channel VARCHAR(320),
    email_address_hash VARCHAR(255),
    primary_credit_card_number_token VARCHAR(255) NOT NULL,
    credit_card_product_code VARCHAR(255) NOT NULL,
    credit_card_status VARCHAR(255) NOT NULL,
    account_open_date DATE NOT NULL,
    account_close_date DATE,
    billing_cycle_day INT NOT NULL,
    credit_limit_amount DECIMAL(15,2) NOT NULL,
    current_outstanding_balance DECIMAL(15,2) NOT NULL,
    statement_due_amount DECIMAL(15,2) NOT NULL,
    minimum_payment_amount DECIMAL(15,2) NOT NULL,
    last_payment_amount DECIMAL(15,2),
    last_payment_date DATE,
    days_past_due INT NOT NULL,
    annual_percentage_rate DECIMAL(5,2) NOT NULL,
    annual_fee_amount DECIMAL(10,2) NOT NULL,
    lifetime_interest_income DECIMAL(18,2) NOT NULL,
    lifetime_fee_income DECIMAL(18,2) NOT NULL,
    last_12m_purchase_volume DECIMAL(18,2) NOT NULL,
    last_12m_cash_advance_volume DECIMAL(18,2) NOT NULL,
    last_transaction_timestamp DATETIME,
    preferred_statement_language VARCHAR(255),
    marketing_opt_in_channels VARCHAR(320),
    risk_score_internal INT,
    cltv_12m_forecast DECIMAL(18,2),
    relationship_manager_id VARCHAR(255),
    primary_income_band VARCHAR(255),
    employment_status VARCHAR(255),
    customer_lifecycle_stage VARCHAR(255) NOT NULL,
    digital_engagement_score INT,
    contact_preferences_object JSON,
    data_record_last_updated_ts DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_customer_info_financ PRIMARY KEY (id)
);


-- Dataset: GDS82717

-- This client dataset supports consumer finance operations. Key applications include relationship mana
CREATE TABLE IF NOT EXISTS `customer_finance_data` (
    id INT NOT NULL,
    customer_id CHAR(36) NOT NULL,
    credit_card_account_id VARCHAR(255) NOT NULL,
    customer_segment_code VARCHAR(255),
    primary_relationship_manager_id VARCHAR(255),
    customer_country_code VARCHAR(255) NOT NULL,
    customer_residency_status VARCHAR(255),
    account_open_date DATE NOT NULL,
    account_close_date DATE,
    credit_score_value INT,
    credit_score_source VARCHAR(255),
    current_credit_limit_amount DECIMAL(15,2) NOT NULL,
    current_outstanding_balance_amount DECIMAL(15,2) NOT NULL,
    statement_cycle_day_number INT,
    days_past_due_count INT NOT NULL,
    delinquency_status_code VARCHAR(255) NOT NULL,
    annual_percentage_rate DECIMAL(5,2),
    last_purchase_timestamp DATETIME,
    monthly_spend_rolling_12m_amount DECIMAL(15,2),
    monthly_revenue_rolling_12m_amount DECIMAL(15,2),
    profitability_tier_code VARCHAR(255),
    cross_sell_eligibility_flag TINYINT(1) NOT NULL,
    marketing_consent_flag TINYINT(1) NOT NULL,
    data_processing_consent_flag TINYINT(1) NOT NULL,
    risk_appetite_category VARCHAR(255),
    churn_risk_score DECIMAL(5,4),
    lifetime_value_estimate_amount DECIMAL(18,2),
    customer_contact_preferences JSON,
    recent_transaction_categories JSON,
    record_last_updated_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_customer_finance_dat PRIMARY KEY (id)
);


