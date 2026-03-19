-- ============================================
-- Platform: MYSQL
-- Schema/Source: none
-- Generated: 2026-03-18T11:58:31.398728
-- Datasets: 1
-- ============================================

-- Dataset: GDS46419

-- Master data for leasing contracts associated with settlement events, including key contractual and r
CREATE TABLE IF NOT EXISTS `lease_contract` (
    id INT NOT NULL,
    leasing_contract_id VARCHAR(255) NOT NULL,
    lease_term_months INT,
    lease_asset_type VARCHAR(255),
    interest_rate DECIMAL(18,4),
    country_of_risk VARCHAR(255),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_lease_contract PRIMARY KEY (id)
);

-- Reference data for third settlement parties receiving or processing lease-related cash flows.
CREATE TABLE IF NOT EXISTS `third_settlement_party` (
    id INT NOT NULL,
    third_settlement_party_id VARCHAR(255) NOT NULL,
    third_settlement_party_name VARCHAR(255) NOT NULL,
    counterparty_iban VARCHAR(255),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_third_settlement_par PRIMARY KEY (id)
);

-- Upstream IT systems that originate settlement records for lineage and data quality analysis.
CREATE TABLE IF NOT EXISTS `source_system` (
    id INT NOT NULL,
    source_system_code VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_source_system PRIMARY KEY (id)
);

-- Fact table capturing individual leasing settlement events and their operational, financial, and tech
CREATE TABLE IF NOT EXISTS `settlement_event` (
    streaming_event_id VARCHAR(255) NOT NULL,
    lease_contract_pk INT NOT NULL,
    third_settlement_party_pk INT NOT NULL,
    source_system_pk INT NOT NULL,
    settlement_currency VARCHAR(255) NOT NULL,
    scheduled_settlement_date DATE NOT NULL,
    actual_settlement_timestamp DATETIME,
    settlement_amount DECIMAL(18,4) NOT NULL,
    settlement_status VARCHAR(255) NOT NULL,
    failure_reason_code VARCHAR(255),
    source_message_id VARCHAR(255) NOT NULL,
    streaming_partition_key VARCHAR(255) NOT NULL,
    streaming_offset INT NOT NULL,
    principal_outstanding_amount DECIMAL(18,4),
    gdpr_personal_data_flag TINYINT(1) NOT NULL,
    is_test_transaction TINYINT(1) NOT NULL,
    created_timestamp DATETIME NOT NULL,
    last_updated_timestamp DATETIME NOT NULL,
    data_quality_score DECIMAL(18,4),
    created_at DATETIME NOT NULL
    ,CONSTRAINT PK_settlement_event PRIMARY KEY (streaming_event_id)
);


