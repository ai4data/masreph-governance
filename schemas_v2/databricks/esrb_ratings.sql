-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: esrb_ratings
-- Generated: 2026-03-18T12:18:16.836940
-- Datasets: 1
-- ============================================

-- Dataset: GDS20020
CREATE SCHEMA IF NOT EXISTS esrb_ratings;

-- This finance dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE IF NOT EXISTS esrb_ratings.quotaflex_finance_terms (
    id INT NOT NULL,
    masreph_contract_id STRING NOT NULL,
    lessee_customer_id STRING NOT NULL,
    lease_agreement_number STRING NOT NULL,
    product_type_code STRING NOT NULL,
    asset_category STRING NOT NULL,
    asset_description STRING,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    first_rental_date DATE,
    contract_status STRING NOT NULL,
    currency_code STRING NOT NULL,
    principal_financed_amount DECIMAL(15,2) NOT NULL,
    total_contract_value DECIMAL(17,2) NOT NULL,
    nominal_interest_rate DECIMAL(7,4) NOT NULL,
    effective_interest_rate DECIMAL(7,4),
    payment_frequency_code STRING NOT NULL,
    scheduled_instalment_amount DECIMAL(15,2) NOT NULL,
    residual_value_amount DECIMAL(15,2),
    upfront_fee_amount DECIMAL(15,2),
    documentation_fee_amount DECIMAL(15,2),
    penalty_interest_rate DECIMAL(7,4),
    early_termination_fee_pct DECIMAL(5,2),
    credit_risk_rating STRING,
    internal_profitability_index DECIMAL(9,4),
    irr_calculation_method STRING,
    cost_center_code STRING NOT NULL,
    sales_region_code STRING NOT NULL,
    marketing_consent_flag BOOLEAN NOT NULL,
    gdpr_processing_legal_basis STRING,
    customer_industry_sector STRING,
    risk_mitigation_instrument ARRAY<STRING>,
    collateral_valuation_amount DECIMAL(15,2),
    write_off_flag BOOLEAN NOT NULL,
    write_off_date DATE,
    last_status_update_timestamp TIMESTAMP NOT NULL,
    data_source_system_code STRING NOT NULL,
    record_effective_date DATE NOT NULL,
    record_archival_flag BOOLEAN NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_quotaflex_finance_te PRIMARY KEY (id)
);


