-- ============================================
-- Platform: MYSQL
-- Schema/Source: marketing_dwh
-- Generated: 2026-03-18T12:18:02.000757
-- Datasets: 1
-- ============================================

-- Dataset: GDS48895

-- This collateral dataset supports consumer finance operations. Key applications include asset valuati
CREATE TABLE IF NOT EXISTS `finance_segmentation_insights` (
    id INT NOT NULL,
    dataset_record_id CHAR(36) NOT NULL,
    masreph_customer_id VARCHAR(255) NOT NULL,
    collateral_asset_id VARCHAR(255) NOT NULL,
    collateral_asset_type VARCHAR(255) NOT NULL,
    collateral_segment_code VARCHAR(255) NOT NULL,
    collateral_segment_description VARCHAR(255),
    customer_risk_band VARCHAR(255) NOT NULL,
    customer_risk_score DECIMAL(5,2) NOT NULL,
    ltv_ratio_current DECIMAL(6,3) NOT NULL,
    ltv_ratio_at_origination DECIMAL(6,3),
    collateral_valuation_amount DECIMAL(18,2) NOT NULL,
    collateral_valuation_currency VARCHAR(255) NOT NULL,
    collateral_valuation_date DATE NOT NULL,
    collateral_recovery_rate_estimate DECIMAL(5,4),
    collateral_haircut_percentage DECIMAL(5,2),
    collateral_liquidity_category VARCHAR(255),
    collateral_location_details JSON,
    collateral_country_code VARCHAR(255) NOT NULL,
    collateral_postal_code VARCHAR(255),
    exposure_at_default DECIMAL(18,2),
    probability_of_default_12m DECIMAL(6,5),
    loss_given_default_estimate DECIMAL(5,4),
    collateral_status_code VARCHAR(255) NOT NULL,
    collateral_status_effective_date DATE,
    segmentation_model_version VARCHAR(255) NOT NULL,
    segmentation_feature_vector JSON,
    marketing_eligibility_flag TINYINT(1) NOT NULL,
    last_segmentation_timestamp DATETIME NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    record_effective_date DATE NOT NULL,
    record_expiry_date DATE,
    record_creation_timestamp DATETIME NOT NULL,
    is_historical_snapshot TINYINT(1) NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_finance_segmentation PRIMARY KEY (id)
);


