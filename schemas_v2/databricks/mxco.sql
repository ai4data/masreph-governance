-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: mxco
-- Generated: 2026-03-18T12:18:16.853608
-- Datasets: 1
-- ============================================

-- Dataset: GDS96051
CREATE SCHEMA IF NOT EXISTS mxco;

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS mxco.client_repair_tracker_dataset (
    id INT NOT NULL,
    repair_case_id STRING NOT NULL,
    source_system_id STRING NOT NULL,
    client_internal_id STRING NOT NULL,
    client_segment STRING,
    client_country_code STRING,
    complaint_channel STRING,
    complaint_category STRING NOT NULL,
    complaint_subcategory STRING,
    issue_severity_level STRING NOT NULL,
    priority_code STRING NOT NULL,
    complaint_received_timestamp TIMESTAMP NOT NULL,
    first_response_timestamp TIMESTAMP,
    resolution_timestamp TIMESTAMP,
    sla_due_timestamp TIMESTAMP,
    sla_breached_flag BOOLEAN NOT NULL,
    complaint_status STRING NOT NULL,
    root_cause_code STRING,
    root_cause_description STRING,
    resolution_summary STRING,
    monetary_impact_amount DECIMAL(15,2),
    compensation_amount DECIMAL(15,2),
    currency_code STRING,
    related_transaction_id STRING,
    product_type STRING,
    channel_session_id STRING,
    assigned_team_name STRING,
    assigned_analyst_id STRING,
    gdpr_data_subject_request_flag BOOLEAN NOT NULL,
    customer_consent_for_contact_flag BOOLEAN,
    contact_email_obfuscated STRING,
    contact_phone_obfuscated STRING,
    customer_satisfaction_rating INT,
    nps_score INT,
    follow_up_required_flag BOOLEAN NOT NULL,
    follow_up_due_date DATE,
    regulatory_reporting_flag BOOLEAN NOT NULL,
    data_quality_issue_flag BOOLEAN,
    created_timestamp TIMESTAMP NOT NULL,
    last_updated_timestamp TIMESTAMP NOT NULL,
    record_source_environment STRING NOT NULL,
    data_lineage_reference_id STRING NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_client_repair_tracke PRIMARY KEY (id)
);


