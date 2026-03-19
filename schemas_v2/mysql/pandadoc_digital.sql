-- ============================================
-- Platform: MYSQL
-- Schema/Source: pandadoc_digital
-- Generated: 2026-03-18T11:58:31.400261
-- Datasets: 1
-- ============================================

-- Dataset: GDS46714

-- Product-level finance metrics and attributes for consumer finance products sourced from PandaDoc for
CREATE TABLE IF NOT EXISTS `bundle_finance_product` (
    product_id VARCHAR(255) NOT NULL,
    bundle_id VARCHAR(255),
    customer_segment_code VARCHAR(255) NOT NULL,
    market_region_code VARCHAR(255) NOT NULL,
    product_launch_date DATE,
    is_product_active TINYINT(1) NOT NULL,
    pricing_apr DECIMAL(18,4),
    annual_fee_amount DECIMAL(18,4),
    average_daily_balance DECIMAL(18,4),
    transaction_volume_30d INT NOT NULL,
    transaction_value_30d DECIMAL(18,4) NOT NULL,
    default_rate_12m DECIMAL(18,4),
    churn_rate_12m DECIMAL(18,4),
    avg_revenue_per_customer_month DECIMAL(18,4),
    cross_sell_uplift_index DECIMAL(18,4),
    primary_competitor_code VARCHAR(255),
    regulatory_product_category VARCHAR(255),
    gdpr_data_processing_basis VARCHAR(255) NOT NULL,
    customer_age_band_distribution JSON,
    product_performance_score DECIMAL(18,4),
    last_performance_calc_timestamp DATETIME NOT NULL,
    product_metadata JSON,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_bundle_finance_produ PRIMARY KEY (product_id)
);


