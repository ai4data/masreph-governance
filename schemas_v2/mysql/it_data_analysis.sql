-- ============================================
-- Platform: MYSQL
-- Schema/Source: it_data_analysis
-- Generated: 2026-03-18T11:58:31.413263
-- Datasets: 1
-- ============================================

-- Dataset: GDS83647

-- Core IT investment records combining financials, delivery status, operational metrics, and technical
CREATE TABLE IF NOT EXISTS `it_investment` (
    investment_id VARCHAR(255) NOT NULL,
    project_code VARCHAR(255) NOT NULL,
    portfolio_id VARCHAR(255),
    cost_center_code VARCHAR(255) NOT NULL,
    application_name VARCHAR(255) NOT NULL,
    environment_name VARCHAR(255) NOT NULL,
    region_code VARCHAR(255),
    cloud_provider VARCHAR(255),
    investment_category VARCHAR(255) NOT NULL,
    investment_subcategory VARCHAR(255),
    funding_source VARCHAR(255),
    capex_opex_flag VARCHAR(255) NOT NULL,
    planned_start_date DATE NOT NULL,
    planned_end_date DATE,
    actual_start_timestamp DATETIME,
    actual_end_timestamp DATETIME,
    deployment_timestamp DATETIME,
    record_ingest_timestamp DATETIME NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    approved_budget_amount DECIMAL(18,4),
    forecast_spend_amount DECIMAL(18,4),
    actual_spend_amount DECIMAL(18,4),
    fiscal_year INT NOT NULL,
    business_unit_name VARCHAR(255),
    it_owner_employee_id VARCHAR(255),
    vendor_name VARCHAR(255),
    contract_id VARCHAR(255),
    contract_renewal_date DATE,
    strategic_priority_rank INT,
    roi_percentage DECIMAL(18,4),
    npv_amount DECIMAL(18,4),
    gdp_compliance_flag TINYINT(1) NOT NULL,
    data_classification_level VARCHAR(255) NOT NULL,
    operational_risk_rating VARCHAR(255),
    project_health_status VARCHAR(255) NOT NULL,
    agile_release_train_name VARCHAR(255),
    sprint_number INT,
    change_ticket_id VARCHAR(255),
    deployment_status VARCHAR(255) NOT NULL,
    incident_count_30d INT NOT NULL,
    kpi_uptime_percentage_30d DECIMAL(18,4),
    data_latency_ms INT,
    streaming_topic_name VARCHAR(255),
    source_system_name VARCHAR(255) NOT NULL,
    record_hash VARCHAR(255) NOT NULL,
    is_active_record TINYINT(1) NOT NULL,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_it_investment PRIMARY KEY (investment_id)
);


