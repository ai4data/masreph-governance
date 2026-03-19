-- ============================================
-- Platform: MYSQL
-- Schema/Source: it_digital
-- Generated: 2026-03-18T11:58:31.407364
-- Datasets: 1
-- ============================================

-- Dataset: GDS64552

-- Dimension table containing unique IT service owners identified by employee ID.
CREATE TABLE IF NOT EXISTS `service_owner` (
    owner_employee_id VARCHAR(255) NOT NULL,
    owner_name VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_service_owner PRIMARY KEY (owner_employee_id)
);

-- Core table representing IT services in the enterprise service catalog, including lifecycle, risk, SL
CREATE TABLE IF NOT EXISTS `service` (
    service_id VARCHAR(255) NOT NULL,
    service_name VARCHAR(255) NOT NULL,
    service_description VARCHAR(255) NOT NULL,
    service_category VARCHAR(255) NOT NULL,
    service_owner_employee_id VARCHAR(255) NOT NULL,
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
    sla_availability_target_percent DECIMAL(18,4) NOT NULL,
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
    approximate_monthly_cost_usd DECIMAL(18,4),
    service_catalog_record_status VARCHAR(255) NOT NULL,
    technical_contact_email VARCHAR(255) NOT NULL,
    operational_runbook_url VARCHAR(255),
    data_retention_period_days INT,
    data_quality_score_percent DECIMAL(18,4),
    metadata_last_synchronized_timestamp DATETIME NOT NULL,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_service PRIMARY KEY (service_id)
);

ALTER TABLE it_digital.service ADD CONSTRAINT FK_service_service_owner_emplo
    FOREIGN KEY (service_owner_employee_id) REFERENCES it_digital.service_owner (owner_employee_id);


