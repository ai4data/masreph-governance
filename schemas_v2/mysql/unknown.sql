-- ============================================
-- Platform: MYSQL
-- Schema/Source: unknown
-- Generated: 2026-03-18T12:18:01.999760
-- Datasets: 3
-- ============================================

-- Dataset: GDS46419

-- This it dataset supports leasing operations. Key applications include data analysis, reporting, busi
CREATE TABLE IF NOT EXISTS `it_data_analysis_dataset` (
    id INT NOT NULL,
    leasing_contract_id VARCHAR(255) NOT NULL,
    third_settlement_party_id VARCHAR(255) NOT NULL,
    third_settlement_party_name VARCHAR(255) NOT NULL,
    counterparty_iban VARCHAR(34),
    settlement_currency VARCHAR(255) NOT NULL,
    scheduled_settlement_date DATE NOT NULL,
    actual_settlement_timestamp DATETIME,
    settlement_amount DECIMAL(15,2) NOT NULL,
    settlement_status VARCHAR(255) NOT NULL,
    failure_reason_code VARCHAR(255),
    source_system_code VARCHAR(255) NOT NULL,
    source_message_id VARCHAR(255) NOT NULL,
    streaming_event_id CHAR(36) NOT NULL,
    streaming_partition_key VARCHAR(255) NOT NULL,
    streaming_offset INT NOT NULL,
    lease_term_months INT,
    lease_asset_type VARCHAR(255),
    interest_rate DECIMAL(7,4),
    principal_outstanding_amount DECIMAL(15,2),
    country_of_risk VARCHAR(255),
    gdpr_personal_data_flag TINYINT(1) NOT NULL,
    is_test_transaction TINYINT(1) NOT NULL,
    created_timestamp DATETIME NOT NULL,
    last_updated_timestamp DATETIME NOT NULL,
    data_quality_score DECIMAL(5,2),
    created_at DATETIME
    ,CONSTRAINT PK_it_data_analysis_dat PRIMARY KEY (id)
);


-- Dataset: GDS64552

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS `it_data_analysis_dataset` (
    id INT NOT NULL,
    service_id CHAR(36) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    service_description VARCHAR(255) NOT NULL,
    service_category VARCHAR(255) NOT NULL,
    service_owner_employee_id VARCHAR(255) NOT NULL,
    service_owner_name VARCHAR(255) NOT NULL,
    service_risk_tier VARCHAR(255) NOT NULL,
    service_criticality_level VARCHAR(255) NOT NULL,
    service_status VARCHAR(255) NOT NULL,
    service_created_timestamp DATETIME NOT NULL,
    service_last_updated_timestamp DATETIME NOT NULL,
    production_go_live_date DATE,
    decommission_planned_date DATE,
    consuming_business_unit VARCHAR(255) NOT NULL,
    supported_channels JSON,
    data_sensitivity_classification VARCHAR(255) NOT NULL,
    regulatory_impact_flag TINYINT(1) NOT NULL,
    gdpr_personal_data_flag TINYINT(1) NOT NULL,
    pci_data_flag TINYINT(1) NOT NULL,
    service_sla_tier VARCHAR(255) NOT NULL,
    sla_response_time_seconds INT,
    sla_availability_target_percent DECIMAL(5,2) NOT NULL,
    incident_volume_last_30_days INT NOT NULL,
    major_incident_count_last_12_months INT NOT NULL,
    current_release_version VARCHAR(255) NOT NULL,
    last_release_deployment_timestamp DATETIME,
    next_release_planned_date DATE,
    change_freeze_window_flag TINYINT(1) NOT NULL,
    primary_data_center_region VARCHAR(255) NOT NULL,
    dr_data_center_region VARCHAR(255),
    rto_minutes INT,
    rpo_minutes INT,
    integration_pattern VARCHAR(255) NOT NULL,
    upstream_systems JSON,
    downstream_systems JSON,
    average_daily_event_volume INT,
    peak_hourly_event_volume INT,
    approximate_monthly_cost_usd DECIMAL(15,2),
    service_catalog_record_status VARCHAR(255) NOT NULL,
    technical_contact_email VARCHAR(320) NOT NULL,
    operational_runbook_url TEXT,
    data_retention_period_days INT,
    data_quality_score_percent DECIMAL(5,2),
    metadata_last_synchronized_timestamp DATETIME NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_it_data_analysis_dat PRIMARY KEY (id)
);


-- Dataset: GDS83647

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS `it_data_analysis_dataset` (
    id INT NOT NULL,
    investment_id CHAR(36) NOT NULL,
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
    approved_budget_amount DECIMAL(18,2),
    forecast_spend_amount DECIMAL(18,2),
    actual_spend_amount DECIMAL(18,2),
    fiscal_year INT NOT NULL,
    business_unit_name VARCHAR(255),
    it_owner_employee_id VARCHAR(255),
    vendor_name VARCHAR(255),
    contract_id VARCHAR(255),
    contract_renewal_date DATE,
    strategic_priority_rank INT,
    roi_percentage DECIMAL(5,2),
    npv_amount DECIMAL(18,2),
    gdp_compliance_flag TINYINT(1) NOT NULL,
    data_classification_level VARCHAR(255) NOT NULL,
    operational_risk_rating VARCHAR(255),
    project_health_status VARCHAR(255) NOT NULL,
    agile_release_train_name VARCHAR(255),
    sprint_number INT,
    change_ticket_id VARCHAR(255),
    deployment_status VARCHAR(255) NOT NULL,
    incident_count_30d INT NOT NULL,
    kpi_uptime_percentage_30d DECIMAL(5,2),
    data_latency_ms INT,
    streaming_topic_name VARCHAR(255),
    source_system_name VARCHAR(255) NOT NULL,
    record_hash VARCHAR(255) NOT NULL,
    is_active_record TINYINT(1) NOT NULL,
    created_at DATETIME
    ,CONSTRAINT PK_it_data_analysis_dat PRIMARY KEY (id)
);


