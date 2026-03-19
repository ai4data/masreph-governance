-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: dataedo_crdm
-- Generated: 2026-03-18T12:18:16.840292
-- Datasets: 1
-- ============================================

-- Dataset: GDS22898
CREATE SCHEMA IF NOT EXISTS dataedo_crdm;

-- This collateral dataset supports consumer finance operations. Key applications include asset valuati
CREATE TABLE IF NOT EXISTS dataedo_crdm.finance_segmentation_table (
    id INT NOT NULL,
    customer_id STRING NOT NULL,
    masreph_party_id STRING NOT NULL,
    collateral_segment_code STRING NOT NULL,
    collateral_segment_description STRING NOT NULL,
    customer_age_years INT,
    customer_gender_code STRING,
    customer_residence_country_code STRING NOT NULL,
    customer_income_bracket_code STRING,
    customer_employment_status STRING,
    collateral_type_code STRING NOT NULL,
    collateral_type_description STRING,
    collateral_valuation_amount DECIMAL(15,2),
    collateral_valuation_currency_code STRING NOT NULL,
    latest_valuation_date DATE,
    primary_loan_account_id STRING,
    loan_purpose_code STRING,
    outstanding_loan_balance DECIMAL(15,2),
    ltv_ratio_percent DECIMAL(6,2),
    delinquency_status_code STRING NOT NULL,
    days_past_due_max INT,
    default_risk_score DECIMAL(5,3),
    behavioral_score_band STRING,
    preferred_contact_channel STRING,
    consent_data_processing_flag BOOLEAN NOT NULL,
    secured_exposure_flag BOOLEAN NOT NULL,
    collateral_location_postal_code STRING,
    collateral_region_code STRING,
    portfolio_segment_code STRING NOT NULL,
    estimated_recovery_rate_percent DECIMAL(5,2),
    repossession_planned_flag BOOLEAN,
    last_repossession_assessment_date DATE,
    security_perfection_status STRING,
    security_registration_identifier STRING,
    customer_lifecycle_stage_code STRING,
    segmentation_effective_date DATE NOT NULL,
    segmentation_expiry_date DATE,
    segment_behavioral_flags ARRAY<STRING>,
    record_source_system_code STRING NOT NULL,
    record_created_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_segmentation PRIMARY KEY (id)
);


