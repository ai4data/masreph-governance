-- ============================================
-- Platform: MYSQL
-- Schema/Source: docuverify
-- Generated: 2026-03-18T12:18:02.004756
-- Datasets: 1
-- ============================================

-- Dataset: GDS84897

-- This client dataset supports mobility solutions operations. Key applications include relationship ma
CREATE TABLE IF NOT EXISTS `docuverify_finance_dataset` (
    id INT NOT NULL,
    client_id CHAR(36) NOT NULL,
    docuverify_document_id VARCHAR(255) NOT NULL,
    client_external_reference VARCHAR(255),
    country_of_residence VARCHAR(255) NOT NULL,
    primary_relationship_manager_id VARCHAR(255),
    client_segment VARCHAR(255) NOT NULL,
    preferred_contact_channel VARCHAR(320),
    kyc_verification_status VARCHAR(255) NOT NULL,
    kyc_last_review_date DATE,
    gdpr_consent_flag TINYINT(1) NOT NULL,
    gdpr_consent_timestamp DATETIME,
    onboarding_channel VARCHAR(255),
    relationship_start_date DATE NOT NULL,
    relationship_status VARCHAR(255) NOT NULL,
    total_outstanding_balance_eur DECIMAL(15,2),
    total_approved_credit_limit_eur DECIMAL(15,2),
    credit_utilization_ratio DECIMAL(5,4),
    verified_monthly_net_income_eur DECIMAL(13,2),
    verified_employment_status VARCHAR(255),
    mobility_product_portfolio JSON,
    primary_vehicle_usage_type VARCHAR(255),
    client_profitability_rolling_12m_eur DECIMAL(15,2),
    expected_lifetime_value_eur DECIMAL(15,2),
    risk_rating_internal VARCHAR(255),
    document_set_type VARCHAR(255) NOT NULL,
    document_capture_timestamp DATETIME NOT NULL,
    document_verification_outcome VARCHAR(255) NOT NULL,
    last_mobility_interaction_timestamp DATETIME,
    contact_opt_out_marketing_flag TINYINT(1) NOT NULL,
    arrears_status VARCHAR(255),
    current_delinquent_amount_eur DECIMAL(15,2),
    mobility_behavior_summary JSON,
    data_record_last_updated_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_docuverify_finance_d PRIMARY KEY (id)
);


