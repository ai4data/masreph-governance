-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: memverge
-- Generated: 2026-03-18T12:18:16.835940
-- Datasets: 1
-- ============================================

-- Dataset: GDS17152
CREATE SCHEMA IF NOT EXISTS memverge;

-- This it dataset supports innovation & technology operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS memverge.privclientfindata (
    id INT NOT NULL,
    client_id STRING NOT NULL,
    client_global_id STRING NOT NULL,
    portfolio_id STRING NOT NULL,
    account_iban STRING,
    country_code STRING NOT NULL,
    residency_status STRING NOT NULL,
    risk_profile_code STRING NOT NULL,
    risk_profile_last_review_date DATE,
    portfolio_currency_code STRING NOT NULL,
    portfolio_investable_assets_amt DECIMAL(18,2) NOT NULL,
    portfolio_liabilities_amt DECIMAL(18,2),
    portfolio_net_worth_amt DECIMAL(18,2) NOT NULL,
    portfolio_leverage_ratio DECIMAL(8,4),
    portfolio_creation_date DATE NOT NULL,
    portfolio_status_code STRING NOT NULL,
    portfolio_status_effective_ts TIMESTAMP NOT NULL,
    investment_strategy_desc STRING,
    advisory_mandate_flag BOOLEAN NOT NULL,
    execution_only_flag BOOLEAN NOT NULL,
    kyc_completed_flag BOOLEAN NOT NULL,
    kyc_last_review_date DATE,
    tax_residency_country_code STRING,
    tax_compliance_status_code STRING NOT NULL,
    client_segment_code STRING NOT NULL,
    client_onboarding_channel_code STRING,
    primary_relationship_manager_id STRING,
    last_contact_ts TIMESTAMP,
    data_source_system_code STRING NOT NULL,
    data_ingestion_ts TIMESTAMP NOT NULL,
    record_effective_date DATE NOT NULL,
    record_expiry_date DATE,
    is_record_current_flag BOOLEAN NOT NULL,
    total_invested_amount_12m DECIMAL(18,2),
    realized_pnl_12m_amt DECIMAL(18,2),
    unrealized_pnl_amt DECIMAL(18,2),
    avg_portfolio_volatility_30d DECIMAL(6,4),
    highest_drawdown_12m_pct DECIMAL(6,4),
    esg_preference_level_code STRING,
    restricted_instrument_list ARRAY<STRING>,
    client_language_preference_code STRING,
    digital_channel_opt_in_flag BOOLEAN NOT NULL,
    streaming_data_subscription_flag BOOLEAN NOT NULL,
    last_streaming_heartbeat_ts TIMESTAMP,
    aml_risk_score INT,
    aml_risk_rating_code STRING,
    gdp_compliance_flag BOOLEAN NOT NULL,
    data_quality_score_pct DECIMAL(5,2),
    data_lineage_metadata MAP<STRING, STRING>,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_privclientfindata PRIMARY KEY (id)
);


