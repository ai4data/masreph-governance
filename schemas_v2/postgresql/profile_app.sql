-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: profile_app
-- Generated: 2026-03-18T12:17:47.442816
-- Datasets: 2
-- ============================================

-- Dataset: GDS35720
CREATE SCHEMA IF NOT EXISTS profile_app;

-- Core finance profile for a retail client, linking to core banking and holding stable client attribut
CREATE TABLE IF NOT EXISTS profile_app.finance_profiles (
    client_profile_id VARCHAR(255) NOT NULL,
    core_banking_client_id VARCHAR(255) NOT NULL,
    national_client_identifier VARCHAR(255),
    client_segment_code VARCHAR(255) NOT NULL,
    residence_country_code VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    profile_creation_timestamp TIMESTAMPTZ NOT NULL,
    profile_last_update_timestamp TIMESTAMPTZ NOT NULL,
    highest_education_level VARCHAR(255),
    employment_status VARCHAR(255) NOT NULL,
    primary_employer_industry VARCHAR(255),
    data_privacy_classification VARCHAR(255) NOT NULL,
    pep_flag BOOLEAN NOT NULL,
    crm_relationship_manager_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_profiles PRIMARY KEY (client_profile_id)
);

-- Current income, expense, and debt position for a client finance profile, used for affordability and 
CREATE TABLE IF NOT EXISTS profile_app.finance_profile_financials (
    finance_profile_financial_id VARCHAR(255) NOT NULL,
    client_profile_id VARCHAR(255) NOT NULL,
    annual_gross_income_amount NUMERIC(18,4) NOT NULL,
    income_source_type VARCHAR(255) NOT NULL,
    monthly_recurrent_expense_amount NUMERIC(18,4),
    monthly_housing_cost_amount NUMERIC(18,4),
    total_outstanding_unsecured_debt_amount NUMERIC(18,4) NOT NULL,
    total_outstanding_mortgage_debt_amount NUMERIC(18,4),
    number_of_active_personal_loans INTEGER NOT NULL,
    credit_limit_all_products_amount NUMERIC(18,4),
    credit_utilization_ratio NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_profile_fina PRIMARY KEY (finance_profile_financial_id)
);

-- Risk and scoring metrics associated with a client finance profile, combining bureau and internal beh
CREATE TABLE IF NOT EXISTS profile_app.finance_profile_risk_metrics (
    finance_profile_risk_metrics_id VARCHAR(255) NOT NULL,
    client_profile_id VARCHAR(255) NOT NULL,
    credit_bureau_score INTEGER,
    internal_behavioral_score INTEGER,
    risk_rating_code VARCHAR(255) NOT NULL,
    last_credit_bureau_pull_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_profile_risk PRIMARY KEY (finance_profile_risk_metrics_id)
);

-- GDPR-related consents and communication channel preferences for a client finance profile.
CREATE TABLE IF NOT EXISTS profile_app.finance_profile_consents (
    finance_profile_consent_id VARCHAR(255) NOT NULL,
    client_profile_id VARCHAR(255) NOT NULL,
    consent_personal_data_processing BOOLEAN NOT NULL,
    consent_marketing_communications BOOLEAN NOT NULL,
    preferred_contact_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_profile_cons PRIMARY KEY (finance_profile_consent_id)
);

-- Profitability, churn risk, offer recommendations, and last interaction channel for a client finance 
CREATE TABLE IF NOT EXISTS profile_app.finance_profile_relationship_metrics (
    finance_profile_relationship_metrics_id VARCHAR(255) NOT NULL,
    client_profile_id VARCHAR(255) NOT NULL,
    profitability_rolling_12m_amount NUMERIC(18,4),
    churn_risk_score NUMERIC(18,4),
    next_best_offer_personal_loan_amount NUMERIC(18,4),
    last_interaction_channel VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_finance_profile_rela PRIMARY KEY (finance_profile_relationship_metrics_id)
);

ALTER TABLE profile_app.finance_profile_financials ADD CONSTRAINT FK_finance_profile_financials_
    FOREIGN KEY (client_profile_id) REFERENCES profile_app.finance_profiles (client_profile_id);

ALTER TABLE profile_app.finance_profile_risk_metrics ADD CONSTRAINT FK_finance_profile_risk_metric
    FOREIGN KEY (client_profile_id) REFERENCES profile_app.finance_profiles (client_profile_id);

ALTER TABLE profile_app.finance_profile_consents ADD CONSTRAINT FK_finance_profile_consents_cl
    FOREIGN KEY (client_profile_id) REFERENCES profile_app.finance_profiles (client_profile_id);

ALTER TABLE profile_app.finance_profile_relationship_metrics ADD CONSTRAINT FK_finance_profile_relationshi
    FOREIGN KEY (client_profile_id) REFERENCES profile_app.finance_profiles (client_profile_id);


-- Dataset: GDS79955
CREATE SCHEMA IF NOT EXISTS profile_app;

-- This risk management dataset supports consumer finance operations. Key applications include data ana
CREATE TABLE IF NOT EXISTS profile_app.creditrisk_finance_dataset (
    id INTEGER NOT NULL,
    loan_account_id VARCHAR(255) NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    hashed_customer_national_id VARCHAR(255),
    country_iso_code VARCHAR(255) NOT NULL,
    product_type VARCHAR(255) NOT NULL,
    application_channel VARCHAR(255),
    origination_date DATE NOT NULL,
    first_disbursement_timestamp TIMESTAMPTZ,
    loan_currency_code VARCHAR(255) NOT NULL,
    original_principal_amount NUMERIC(15,2) NOT NULL,
    current_outstanding_principal NUMERIC(15,2) NOT NULL,
    interest_rate_annual_pct NUMERIC(5,3) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    loan_term_months INTEGER NOT NULL,
    remaining_term_months INTEGER,
    repayment_frequency VARCHAR(255) NOT NULL,
    installment_amount NUMERIC(15,2) NOT NULL,
    next_payment_due_date DATE,
    days_past_due INTEGER NOT NULL,
    delinquency_status VARCHAR(255) NOT NULL,
    default_flag BOOLEAN NOT NULL,
    default_date DATE,
    write_off_amount NUMERIC(15,2),
    impairment_stage_ifrs9 INTEGER NOT NULL,
    probability_of_default_12m NUMERIC(6,5) NOT NULL,
    probability_of_default_lifetime NUMERIC(6,5) NOT NULL,
    loss_given_default_pct NUMERIC(5,3) NOT NULL,
    exposure_at_default_amount NUMERIC(15,2) NOT NULL,
    behavioral_scorecard_band VARCHAR(255),
    application_credit_score INTEGER,
    income_verified_amount NUMERIC(15,2),
    employment_status VARCHAR(255),
    residence_type VARCHAR(255),
    debt_to_income_ratio_pct NUMERIC(6,3),
    utilization_rate_pct NUMERIC(6,3),
    consent_to_data_processing_flag BOOLEAN NOT NULL,
    last_status_update_timestamp TIMESTAMPTZ NOT NULL,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    gdpr_erasure_requested_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_creditrisk_finance_d PRIMARY KEY (id)
);


