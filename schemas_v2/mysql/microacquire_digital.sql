-- ============================================
-- Platform: MYSQL
-- Schema/Source: microacquire_digital
-- Generated: 2026-03-18T11:58:31.401622
-- Datasets: 2
-- ============================================

-- Dataset: GDS52300

-- Collateral used in trade finance and mobility-related financing, including valuation, risk, legal, a
CREATE TABLE IF NOT EXISTS `collateral` (
    collateral_id VARCHAR(255) NOT NULL,
    trade_finance_facility_id VARCHAR(255) NOT NULL,
    loan_contract_id VARCHAR(255) NOT NULL,
    mobility_solution_contract_id VARCHAR(255),
    customer_id VARCHAR(255) NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    customer_country_code VARCHAR(255) NOT NULL,
    collateral_type VARCHAR(255) NOT NULL,
    asset_category VARCHAR(255) NOT NULL,
    vehicle_identification_number VARCHAR(255),
    vehicle_registration_number VARCHAR(255),
    asset_make VARCHAR(255),
    asset_model VARCHAR(255),
    asset_model_year INT,
    asset_primary_color VARCHAR(255),
    asset_location_country_code VARCHAR(255),
    asset_location_city VARCHAR(255),
    asset_ownership_type VARCHAR(255) NOT NULL,
    collateral_valuation_currency VARCHAR(255) NOT NULL,
    collateral_market_value_amount DECIMAL(18,4) NOT NULL,
    collateral_forced_sale_value_amount DECIMAL(18,4),
    collateral_valuation_date DATE NOT NULL,
    valuation_method_code VARCHAR(255) NOT NULL,
    valuation_provider_name VARCHAR(255),
    collateral_valuation_details JSON,
    loan_to_value_ratio DECIMAL(18,4) NOT NULL,
    collateral_haircut_percentage DECIMAL(18,4) NOT NULL,
    collateral_status_code VARCHAR(255) NOT NULL,
    collateral_perfection_status VARCHAR(255) NOT NULL,
    pledge_start_date DATE NOT NULL,
    pledge_end_date DATE,
    is_collateral_insured TINYINT(1) NOT NULL,
    collateral_insurance_policy_number VARCHAR(255),
    collateral_insurance_expiry_date DATE,
    risk_rating_score INT,
    risk_rating_class VARCHAR(255),
    recovery_rate_estimate DECIMAL(18,4),
    asset_usage_restrictions JSON,
    legal_lien_type VARCHAR(255),
    repossession_eligibility_flag TINYINT(1) NOT NULL,
    repossession_trigger_reason VARCHAR(255),
    last_status_update_timestamp DATETIME NOT NULL,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_creation_timestamp DATETIME NOT NULL,
    record_last_modified_timestamp DATETIME NOT NULL,
    gdpr_data_subject_flag TINYINT(1) NOT NULL,
    collateral_owner_name_hashed VARCHAR(255),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_collateral PRIMARY KEY (collateral_id)
);


-- Dataset: GDS80116

-- Collateral records used in trade finance facilities within the Masreph trade finance platform, sourc
CREATE TABLE IF NOT EXISTS `trade_finance_collateral` (
    collateral_id VARCHAR(255) NOT NULL,
    facility_id VARCHAR(255) NOT NULL,
    obligor_id VARCHAR(255) NOT NULL,
    trade_transaction_id VARCHAR(255),
    collateral_type_code VARCHAR(255) NOT NULL,
    collateral_description VARCHAR(255),
    collateral_country_code VARCHAR(255) NOT NULL,
    collateral_currency_code VARCHAR(255) NOT NULL,
    collateral_valuation_amount DECIMAL(18,4) NOT NULL,
    collateral_valuation_date DATE NOT NULL,
    collateral_valuation_method VARCHAR(255),
    collateral_haircut_percentage DECIMAL(18,4) NOT NULL,
    collateral_adjusted_value DECIMAL(18,4) NOT NULL,
    loan_to_value_ratio DECIMAL(18,4) NOT NULL,
    collateral_margin_requirement DECIMAL(18,4),
    collateral_eligibility_flag TINYINT(1) NOT NULL,
    collateral_status_code VARCHAR(255) NOT NULL,
    collateral_status_date DATE NOT NULL,
    pledge_start_date DATE NOT NULL,
    pledge_end_date DATE,
    collateral_owner_name VARCHAR(255),
    collateral_owner_lei VARCHAR(255),
    collateral_location_address VARCHAR(255),
    collateral_insurance_policy_number VARCHAR(255),
    collateral_insured_value DECIMAL(18,4),
    collateral_insurance_expiry_date DATE,
    collateral_concentration_limit_pct DECIMAL(18,4),
    collateral_realization_time_days INT,
    collateral_recovery_rate_estimate DECIMAL(18,4),
    collateral_enforceability_flag TINYINT(1) NOT NULL,
    collateral_legal_agreement_id VARCHAR(255) NOT NULL,
    collateral_custodian_name VARCHAR(255),
    collateral_custody_account_id VARCHAR(255),
    last_update_timestamp DATETIME NOT NULL,
    created_timestamp DATETIME NOT NULL,
    source_system_code VARCHAR(255) NOT NULL,
    masreph_business_unit_code VARCHAR(255) NOT NULL,
    regulatory_collateral_classification VARCHAR(255),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_trade_finance_collat PRIMARY KEY (collateral_id)
);


