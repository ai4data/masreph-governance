-- ============================================
-- Platform: MYSQL
-- Schema/Source: processmaker
-- Generated: 2026-03-18T12:18:02.003758
-- Datasets: 2
-- ============================================

-- Dataset: GDS75934

-- This partner dataset supports commercial finance operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS `commercial_finance_forms` (
    id INT NOT NULL,
    form_id CHAR(36) NOT NULL,
    partner_org_id VARCHAR(255) NOT NULL,
    masreph_loan_id VARCHAR(255),
    legal_entity_name VARCHAR(255) NOT NULL,
    borrower_registration_number VARCHAR(255),
    borrower_country_code VARCHAR(255) NOT NULL,
    loan_facility_type VARCHAR(255) NOT NULL,
    loan_purpose_description VARCHAR(255),
    currency_code VARCHAR(255) NOT NULL,
    principal_amount DECIMAL(18,2) NOT NULL,
    interest_rate_annual DECIMAL(7,4),
    interest_rate_type VARCHAR(255),
    loan_start_date DATE,
    loan_maturity_date DATE,
    repayment_frequency VARCHAR(255),
    collateral_type VARCHAR(255),
    collateral_valuation_amount DECIMAL(18,2),
    collateral_valuation_date DATE,
    security_agreement_id VARCHAR(255),
    promissory_note_id VARCHAR(255),
    additional_collateral_ids JSON,
    form_effective_timestamp DATETIME,
    form_status VARCHAR(255) NOT NULL,
    form_source_channel VARCHAR(320) NOT NULL,
    counterparty_risk_rating VARCHAR(255),
    covenant_summary_text VARCHAR(255),
    governing_law_jurisdiction VARCHAR(255),
    signatory_count INT,
    primary_contact_email VARCHAR(320),
    primary_contact_phone VARCHAR(255),
    kyc_completed_flag TINYINT(1) NOT NULL,
    last_review_timestamp DATETIME,
    data_sharing_consent_flag TINYINT(1),
    aml_risk_score DECIMAL(5,2),
    document_storage_location VARCHAR(255),
    form_metadata_json JSON,
    created_at DATETIME
    ,CONSTRAINT PK_commercial_finance_f PRIMARY KEY (id)
);


-- Dataset: GDS90879

-- This partner dataset supports consumer finance operations. Key applications include data analysis, r
CREATE TABLE IF NOT EXISTS `consumer_finance_forms_dataset` (
    id INT NOT NULL,
    form_id CHAR(36) NOT NULL,
    partner_institution_id VARCHAR(255) NOT NULL,
    customer_hashed_id VARCHAR(255) NOT NULL,
    form_type_code VARCHAR(255) NOT NULL,
    form_submission_channel VARCHAR(255) NOT NULL,
    form_submission_timestamp DATETIME NOT NULL,
    form_effective_date DATE,
    product_category VARCHAR(255) NOT NULL,
    requested_credit_amount DECIMAL(15,2),
    approved_credit_amount DECIMAL(15,2),
    form_status_code VARCHAR(255) NOT NULL,
    consent_gdpr_flag TINYINT(1) NOT NULL,
    country_of_residence_code VARCHAR(255),
    application_risk_score DECIMAL(5,2),
    reviewer_user_id VARCHAR(255),
    form_metadata JSON,
    created_at DATETIME
    ,CONSTRAINT PK_consumer_finance_for PRIMARY KEY (id)
);


