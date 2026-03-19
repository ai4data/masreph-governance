-- ============================================
-- Platform: MYSQL
-- Schema/Source: pandadoc
-- Generated: 2026-03-18T12:18:01.996474
-- Datasets: 3
-- ============================================

-- Dataset: GDS30100

-- This product dataset supports mobility solutions operations. Key applications include product perfor
CREATE TABLE IF NOT EXISTS `bundle_finance_data` (
    id INT NOT NULL,
    bundle_finance_record_id CHAR(36) NOT NULL,
    masreph_customer_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(255) NOT NULL,
    contract_id VARCHAR(255) NOT NULL,
    vin_hash VARCHAR(255),
    vehicle_segment VARCHAR(255),
    country_code VARCHAR(255) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    schedule_start_date DATE NOT NULL,
    schedule_end_date DATE NOT NULL,
    first_payment_due_date DATE NOT NULL,
    last_payment_due_date DATE NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    number_of_installments INT NOT NULL,
    installment_amount DECIMAL(15,2) NOT NULL,
    balloon_payment_amount DECIMAL(15,2),
    interest_rate_annual DECIMAL(7,4) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    apr_effective DECIMAL(7,4),
    principal_amount DECIMAL(18,2) NOT NULL,
    outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    past_due_principal_amount DECIMAL(18,2) NOT NULL,
    next_payment_due_date DATE,
    next_payment_amount DECIMAL(15,2),
    payment_status_code VARCHAR(255) NOT NULL,
    contract_status_code VARCHAR(255) NOT NULL,
    delinquency_bucket VARCHAR(255) NOT NULL,
    write_off_flag TINYINT(1) NOT NULL,
    write_off_date DATE,
    origination_channel VARCHAR(255) NOT NULL,
    dealer_id VARCHAR(255),
    mobility_use_case_type VARCHAR(255),
    portfolio_segment_code VARCHAR(255) NOT NULL,
    exposure_at_default DECIMAL(18,2),
    probability_of_default_12m DECIMAL(6,4),
    loss_given_default_percentage DECIMAL(5,2),
    product_profit_margin_pct DECIMAL(5,2),
    revenue_month_to_date DECIMAL(18,2),
    revenue_year_to_date DECIMAL(18,2),
    customer_risk_rating VARCHAR(255),
    last_payment_received_timestamp DATETIME,
    data_source_system VARCHAR(255) NOT NULL,
    record_creation_timestamp DATETIME NOT NULL,
    record_last_updated_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_bundle_finance_data PRIMARY KEY (id)
);


-- Dataset: GDS40621

-- This product dataset supports commercial finance operations. Key applications include product perfor
CREATE TABLE IF NOT EXISTS `bundle_finance_data` (
    id INT NOT NULL,
    product_bundle_id CHAR(36) NOT NULL,
    product_bundle_name VARCHAR(255) NOT NULL,
    masreph_customer_id VARCHAR(255) NOT NULL,
    instrument_type VARCHAR(255) NOT NULL,
    trade_settlement_date DATE NOT NULL,
    reporting_currency VARCHAR(255) NOT NULL,
    notional_amount DECIMAL(18,2) NOT NULL,
    realized_pnl_amount DECIMAL(18,2),
    unrealized_pnl_amount DECIMAL(18,2),
    payment_status VARCHAR(255) NOT NULL,
    risk_rating INT,
    portfolio_allocation_pct DECIMAL(5,2),
    is_hedging_transaction TINYINT(1) NOT NULL,
    last_updated_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_bundle_finance_data PRIMARY KEY (id)
);


-- Dataset: GDS46714

-- This product dataset supports consumer finance operations. Key applications include product performa
CREATE TABLE IF NOT EXISTS `bundle_finance_data` (
    id INT NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    bundle_id VARCHAR(255),
    customer_segment_code VARCHAR(255) NOT NULL,
    market_region_code VARCHAR(255) NOT NULL,
    product_launch_date DATE,
    is_product_active TINYINT(1) NOT NULL,
    pricing_apr DECIMAL(6,3),
    annual_fee_amount DECIMAL(15,2),
    average_daily_balance DECIMAL(18,2),
    transaction_volume_30d INT NOT NULL,
    transaction_value_30d DECIMAL(18,2) NOT NULL,
    default_rate_12m DECIMAL(5,4),
    churn_rate_12m DECIMAL(5,4),
    avg_revenue_per_customer_month DECIMAL(15,4),
    cross_sell_uplift_index DECIMAL(6,3),
    primary_competitor_code VARCHAR(255),
    regulatory_product_category VARCHAR(255),
    gdpr_data_processing_basis VARCHAR(255) NOT NULL,
    customer_age_band_distribution DECIMAL(5,2),
    product_performance_score DECIMAL(5,2),
    last_performance_calc_timestamp DATETIME NOT NULL,
    product_metadata JSON,
    created_at DATETIME
    ,CONSTRAINT PK_bundle_finance_data PRIMARY KEY (id)
);


