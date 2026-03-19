-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: sepa_mandate_verification
-- Generated: 2026-03-18T12:18:16.850602
-- Datasets: 1
-- ============================================

-- Dataset: GDS72336
CREATE SCHEMA IF NOT EXISTS sepa_mandate_verification;

-- This product dataset supports leasing operations. Key applications include product performance analy
CREATE TABLE IF NOT EXISTS sepa_mandate_verification.sepa_contract_validation_dataset (
    id INT NOT NULL,
    sepa_contract_id STRING NOT NULL,
    masreph_customer_id STRING NOT NULL,
    sepa_mandate_id STRING NOT NULL,
    iban_account_number STRING NOT NULL,
    debtor_bic STRING,
    mandate_signature_date DATE NOT NULL,
    mandate_validation_status STRING NOT NULL,
    mandate_validation_timestamp TIMESTAMP NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE,
    lease_product_code STRING NOT NULL,
    lease_asset_type STRING NOT NULL,
    contract_currency_code STRING NOT NULL,
    contract_gross_amount DECIMAL(15,2) NOT NULL,
    outstanding_principal_amount DECIMAL(15,2) NOT NULL,
    scheduled_installment_amount DECIMAL(15,2) NOT NULL,
    payment_frequency_code STRING NOT NULL,
    sepa_direct_debit_scheme STRING NOT NULL,
    creditor_identifier STRING NOT NULL,
    debtor_name STRING NOT NULL,
    debtor_country_code STRING NOT NULL,
    mandate_amendment_indicator BOOLEAN NOT NULL,
    first_collection_date DATE,
    last_collection_date DATE,
    successful_collection_count INT NOT NULL,
    failed_collection_count INT NOT NULL,
    last_return_reason_code STRING,
    portfolio_segment_code STRING NOT NULL,
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    gdpr_compliant_flag BOOLEAN NOT NULL,
    data_source_system_code STRING NOT NULL,
    record_effective_date DATE NOT NULL,
    record_end_date DATE,
    active_record_flag BOOLEAN NOT NULL,
    booking_branch_code STRING,
    internal_product_performance_score DECIMAL(5,2),
    forecasted_12m_revenue_amount DECIMAL(15,2),
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_sepa_contract_valida PRIMARY KEY (id)
);


