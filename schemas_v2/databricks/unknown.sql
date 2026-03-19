-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: unknown
-- Generated: 2026-03-18T12:18:16.852610
-- Datasets: 1
-- ============================================

-- Dataset: GDS94758
CREATE SCHEMA IF NOT EXISTS unknown;

-- This finance dataset supports finance office operations. Key applications include data analysis, rep
CREATE TABLE IF NOT EXISTS unknown.finance_data_analysis_dataset (
    id INT NOT NULL,
    dataset_record_id STRING NOT NULL,
    source_system_code STRING NOT NULL,
    ledger_account_number STRING NOT NULL,
    ledger_account_name STRING NOT NULL,
    cost_center_code STRING,
    cost_center_name STRING,
    fiscal_year INT NOT NULL,
    fiscal_period INT NOT NULL,
    posting_date DATE NOT NULL,
    document_date DATE,
    accounting_document_number STRING NOT NULL,
    document_line_number INT NOT NULL,
    company_code STRING NOT NULL,
    business_unit_code STRING,
    currency_code STRING NOT NULL,
    exchange_rate_to_group DECIMAL(18,8),
    amount_transaction_currency DECIMAL(18,2) NOT NULL,
    amount_group_currency DECIMAL(18,2),
    amount_local_currency DECIMAL(18,2),
    debit_credit_indicator STRING NOT NULL,
    gl_account_type STRING NOT NULL,
    financial_statement_item STRING,
    budget_version_code STRING,
    budget_amount DECIMAL(18,2),
    forecast_amount DECIMAL(18,2),
    actual_amount DECIMAL(18,2),
    variance_amount DECIMAL(18,2),
    variance_percentage DECIMAL(9,4),
    profitability_segment_code STRING,
    product_segment_code STRING,
    customer_segment_code STRING,
    posting_status STRING NOT NULL,
    reversal_indicator BOOLEAN NOT NULL,
    archived_flag BOOLEAN NOT NULL,
    data_quality_score DECIMAL(5,2),
    load_timestamp TIMESTAMP NOT NULL,
    source_file_name STRING,
    created_by_user STRING,
    reporting_tag_list ARRAY<STRING>,
    approval_timestamp TIMESTAMP,
    analytical_attributes MAP<STRING, STRING>,
    gdp_compliance_flag BOOLEAN NOT NULL,
    internal_order_number STRING,
    accrual_indicator BOOLEAN,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_finance_data_analysi PRIMARY KEY (id)
);


