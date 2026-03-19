-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: finflux_credit
-- Generated: 2026-03-18T12:18:16.834961
-- Datasets: 3
-- ============================================

-- Dataset: GDS15274
CREATE SCHEMA IF NOT EXISTS finflux_credit;

-- This collateral dataset supports commercial finance operations. Key applications include asset valua
CREATE TABLE IF NOT EXISTS finflux_credit.creditshield_finance_dataset (
    id INT NOT NULL,
    collateral_id STRING NOT NULL,
    facility_id STRING NOT NULL,
    customer_id STRING NOT NULL,
    customer_name STRING NOT NULL,
    customer_segment STRING,
    country_of_risk STRING NOT NULL,
    collateral_type STRING NOT NULL,
    collateral_sub_type STRING,
    asset_description STRING,
    asset_location_address STRING,
    asset_location_country STRING,
    currency_code STRING NOT NULL,
    original_valuation_amount DECIMAL(18,2) NOT NULL,
    latest_valuation_amount DECIMAL(18,2),
    valuation_date_latest DATE,
    valuation_date_original DATE NOT NULL,
    valuation_method STRING,
    loan_to_value_ratio DECIMAL(6,3),
    haircut_percentage DECIMAL(5,2),
    risk_grade_internal STRING,
    risk_grade_external STRING,
    pledged_amount DECIMAL(18,2),
    lien_rank INT,
    perfection_status STRING NOT NULL,
    perfection_date DATE,
    collateral_status STRING NOT NULL,
    enforcement_status STRING,
    enforcement_start_date DATE,
    recovery_value_estimate DECIMAL(18,2),
    recovery_timeline_months INT,
    environmental_social_risk_flag BOOLEAN,
    legal_dispute_flag BOOLEAN,
    insurance_policy_number STRING,
    insurance_expiry_date DATE,
    insurance_coverage_amount DECIMAL(18,2),
    owner_name STRING,
    owner_identifier STRING,
    owner_residency_country STRING,
    consent_marketing_flag BOOLEAN,
    consent_data_processing_flag BOOLEAN NOT NULL,
    created_timestamp TIMESTAMP NOT NULL,
    last_updated_timestamp TIMESTAMP,
    source_system_code STRING NOT NULL,
    gdp_compliance_flag BOOLEAN NOT NULL,
    data_sensitivity_class STRING NOT NULL,
    archival_status_date DATE,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_creditshield_finance PRIMARY KEY (id)
);


-- Dataset: GDS54234
CREATE SCHEMA IF NOT EXISTS finflux_credit;

-- This collateral dataset supports leasing operations. Key applications include asset valuation, risk 
CREATE TABLE IF NOT EXISTS finflux_credit.creditshield_finance_dataset (
    id INT NOT NULL,
    collateral_id STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_segment_code STRING,
    collateral_type_code STRING NOT NULL,
    collateral_description STRING,
    asset_manufacturer_name STRING,
    asset_model_name STRING,
    asset_serial_number STRING,
    asset_category_code STRING NOT NULL,
    country_of_risk_code STRING NOT NULL,
    booking_legal_entity_code STRING NOT NULL,
    collateral_currency_code STRING NOT NULL,
    original_asset_value_amount DECIMAL(18,2) NOT NULL,
    original_asset_value_date DATE NOT NULL,
    current_asset_book_value_amount DECIMAL(18,2),
    current_market_value_amount DECIMAL(18,2),
    market_valuation_date DATE,
    valuation_method_code STRING,
    loan_outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    loan_to_value_ratio_percent DECIMAL(5,2),
    collateral_haircut_percent DECIMAL(5,2),
    collateral_eligibility_flag BOOLEAN NOT NULL,
    collateral_status_code STRING NOT NULL,
    repossession_status_code STRING,
    repossession_date DATE,
    recovery_strategy_code STRING,
    expected_recovery_rate_percent DECIMAL(5,2),
    expected_time_to_recovery_months INT,
    recovery_channel_codes_array ARRAY<STRING>,
    impairment_indicator_flag BOOLEAN NOT NULL,
    impairment_recognition_date DATE,
    write_off_amount DECIMAL(18,2),
    insurance_policy_number STRING,
    insurance_coverage_amount DECIMAL(18,2),
    insurance_expiry_date DATE,
    geographic_location_object MAP<STRING, STRING>,
    asset_usage_mileage_integer INT,
    asset_usage_hours_integer INT,
    customer_consent_marketing_flag BOOLEAN NOT NULL,
    customer_consent_data_sharing_flag BOOLEAN NOT NULL,
    collateral_registration_id STRING,
    collateral_perfection_date DATE,
    gdp_compliance_flag BOOLEAN NOT NULL,
    data_source_system_code STRING NOT NULL,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_update_timestamp TIMESTAMP NOT NULL,
    archival_status_code STRING NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_creditshield_finance PRIMARY KEY (id)
);


-- Dataset: GDS68732
CREATE SCHEMA IF NOT EXISTS finflux_credit;

-- This product dataset supports leasing operations. Key applications include product performance analy
CREATE TABLE IF NOT EXISTS finflux_credit.finance_insights_dataset (
    id INT NOT NULL,
    finance_insights_record_id STRING NOT NULL,
    masreph_lease_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_birth_date DATE,
    customer_residency_country_code STRING NOT NULL,
    product_code STRING NOT NULL,
    product_name STRING NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    lease_term_months INT NOT NULL,
    lease_principal_amount DECIMAL(15,2) NOT NULL,
    lease_outstanding_balance DECIMAL(15,2) NOT NULL,
    lease_status_code STRING NOT NULL,
    interest_rate_annual DECIMAL(5,4) NOT NULL,
    payment_frequency_code STRING NOT NULL,
    next_payment_due_date DATE,
    days_past_due INT NOT NULL,
    default_flag BOOLEAN NOT NULL,
    write_off_date DATE,
    portfolio_segment_code STRING NOT NULL,
    leased_asset_type STRING NOT NULL,
    leased_asset_market_value DECIMAL(15,2),
    internal_rating_grade STRING,
    expected_loss_12m_amount DECIMAL(15,2),
    effective_interest_rate_annual DECIMAL(6,4),
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    customer_consent_marketing_flag BOOLEAN NOT NULL,
    record_effective_timestamp TIMESTAMP NOT NULL,
    record_expiry_timestamp TIMESTAMP,
    data_source_system_code STRING NOT NULL,
    customer_domicile_region STRING,
    contract_currency_code STRING NOT NULL,
    portfolio_yield_segment_bucket STRING,
    lease_margin_annual_bps INT,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_insights_dat PRIMARY KEY (id)
);


