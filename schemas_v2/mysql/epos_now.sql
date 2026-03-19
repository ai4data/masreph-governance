-- ============================================
-- Platform: MYSQL
-- Schema/Source: epos_now
-- Generated: 2026-03-18T12:18:02.001756
-- Datasets: 1
-- ============================================

-- Dataset: GDS67220

-- This product dataset supports consumer finance operations. Key applications include product performa
CREATE TABLE IF NOT EXISTS `cashflow_at_schiphol_finance_dataset` (
    id INT NOT NULL,
    cashflow_record_id CHAR(36) NOT NULL,
    masreph_customer_id VARCHAR(255),
    product_id VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    cashflow_direction VARCHAR(255) NOT NULL,
    cashflow_type VARCHAR(255) NOT NULL,
    transaction_amount DECIMAL(18,2) NOT NULL,
    transaction_currency_code VARCHAR(255) NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_timestamp DATETIME NOT NULL,
    value_date DATE,
    booking_date DATE NOT NULL,
    airport_location_code VARCHAR(255) NOT NULL,
    terminal_code VARCHAR(255),
    counterparty_type VARCHAR(255) NOT NULL,
    counterparty_segment VARCHAR(255),
    payment_channel VARCHAR(255) NOT NULL,
    payment_method VARCHAR(255) NOT NULL,
    portfolio_id VARCHAR(255) NOT NULL,
    portfolio_name VARCHAR(255),
    business_line_code VARCHAR(255) NOT NULL,
    cashflow_status VARCHAR(255) NOT NULL,
    is_reconciled TINYINT(1) NOT NULL,
    reconciliation_timestamp DATETIME,
    gl_account_number VARCHAR(255) NOT NULL,
    cost_center_code VARCHAR(255),
    revenue_stream_code VARCHAR(255),
    inflow_outflow_category VARCHAR(255) NOT NULL,
    fx_rate_applied DECIMAL(12,6),
    amount_local_currency DECIMAL(18,2),
    amount_reporting_currency DECIMAL(18,2) NOT NULL,
    reporting_currency_code VARCHAR(255) NOT NULL,
    created_timestamp DATETIME NOT NULL,
    last_updated_timestamp DATETIME NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    is_estimated_amount TINYINT(1) NOT NULL,
    forecast_period_month VARCHAR(255),
    forecast_scenario_name VARCHAR(255),
    market_segment_code VARCHAR(255),
    product_performance_bucket VARCHAR(255),
    anomaly_flag TINYINT(1) NOT NULL,
    commentary_text VARCHAR(255),
    created_at DATETIME
    ,CONSTRAINT PK_cashflow_at_schiphol PRIMARY KEY (id)
);


