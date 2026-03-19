-- ============================================
-- Platform: MYSQL
-- Schema/Source: american_office_systems
-- Generated: 2026-03-18T12:18:01.995488
-- Datasets: 1
-- ============================================

-- Dataset: GDS19125

-- This partner dataset supports mobility solutions operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS `advice_cost_process_data` (
    id INT NOT NULL,
    advice_cost_process_id CHAR(36) NOT NULL,
    partner_id VARCHAR(255) NOT NULL,
    partner_name VARCHAR(255) NOT NULL,
    mobility_contract_id VARCHAR(255),
    advice_request_id VARCHAR(255) NOT NULL,
    customer_segment_code VARCHAR(255),
    vehicle_category_code VARCHAR(255),
    advice_channel_code VARCHAR(255) NOT NULL,
    advisor_id VARCHAR(255),
    advisor_compensation_model VARCHAR(255),
    advice_start_timestamp DATETIME NOT NULL,
    advice_end_timestamp DATETIME,
    advice_duration_seconds INT,
    advice_fee_amount DECIMAL(15,2),
    commission_amount DECIMAL(15,2),
    cost_component_breakdown JSON,
    total_advice_cost_amount DECIMAL(18,4) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    country_iso_code VARCHAR(255) NOT NULL,
    fee_basis_type_code VARCHAR(255),
    commission_rate_percent DECIMAL(7,4),
    is_cross_sell_offer TINYINT(1) NOT NULL,
    processing_status_code VARCHAR(255) NOT NULL,
    cost_record_created_timestamp DATETIME NOT NULL,
    cost_record_last_updated_timestamp DATETIME,
    created_at DATETIME
    ,CONSTRAINT PK_advice_cost_process_ PRIMARY KEY (id)
);


