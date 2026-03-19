-- ============================================
-- Platform: MYSQL
-- Schema/Source: digital_payment_tokens
-- Generated: 2026-03-18T12:18:02.004756
-- Datasets: 1
-- ============================================

-- Dataset: GDS90705

-- This product dataset supports mobility solutions operations. Key applications include product perfor
CREATE TABLE IF NOT EXISTS `digital_payment_tokens_dataset` (
    id INT NOT NULL,
    digital_payment_token_id VARCHAR(255) NOT NULL,
    token_type_code VARCHAR(255) NOT NULL,
    token_network_scheme VARCHAR(255) NOT NULL,
    masreph_product_id VARCHAR(255) NOT NULL,
    mobility_contract_id VARCHAR(255),
    customer_segment_code VARCHAR(255),
    vehicle_usage_category VARCHAR(255),
    transaction_id CHAR(36) NOT NULL,
    payment_schedule_id VARCHAR(255) NOT NULL,
    scheduled_payment_date DATE NOT NULL,
    actual_settlement_timestamp DATETIME,
    payment_status_code VARCHAR(255) NOT NULL,
    payment_status_reason VARCHAR(255),
    transaction_amount DECIMAL(18,2) NOT NULL,
    transaction_currency_code VARCHAR(255) NOT NULL,
    fx_conversion_rate DECIMAL(18,8),
    transaction_amount_eur DECIMAL(18,2),
    interchange_fee_amount DECIMAL(18,4),
    issuer_rebate_amount DECIMAL(18,4),
    merchant_id VARCHAR(255),
    merchant_category_code VARCHAR(255),
    mobility_service_type VARCHAR(255),
    route_or_zone_id VARCHAR(255),
    payment_channel_code VARCHAR(255) NOT NULL,
    device_type_code VARCHAR(30),
    geo_region_code VARCHAR(255),
    recurring_payment_flag TINYINT(1) NOT NULL,
    installment_sequence_number INT,
    remaining_installments_count INT,
    remaining_principal_amount DECIMAL(18,2),
    late_payment_flag TINYINT(1) NOT NULL,
    days_past_due_count INT,
    portfolio_segment_code VARCHAR(255),
    product_margin_basis_points INT,
    revenue_recognition_date DATE,
    record_created_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_digital_payment_toke PRIMARY KEY (id)
);


