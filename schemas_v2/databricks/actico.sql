-- ============================================
-- Platform: DATABRICKS
-- Schema/Source: actico
-- Generated: 2026-03-18T12:18:16.832943
-- Datasets: 6
-- ============================================

-- Dataset: GDS14479
CREATE SCHEMA IF NOT EXISTS actico;

-- This finance dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE IF NOT EXISTS actico.financepro_provision_insights (
    id INT NOT NULL,
    dataset_record_id STRING NOT NULL,
    masreph_customer_id STRING NOT NULL,
    customer_full_name STRING NOT NULL,
    customer_tax_id STRING,
    customer_marketing_consent_flag BOOLEAN NOT NULL,
    lease_contract_id STRING NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    reporting_period_start_date DATE NOT NULL,
    reporting_period_end_date DATE NOT NULL,
    asset_cost_amount DECIMAL(15,2) NOT NULL,
    lease_provision_amount DECIMAL(15,2) NOT NULL,
    lease_expected_loss_rate DECIMAL(5,4),
    lease_profitability_margin_pct DECIMAL(6,3),
    currency_code STRING NOT NULL,
    contract_status_code STRING NOT NULL,
    country_of_risk_code STRING NOT NULL,
    budgeted_provision_amount DECIMAL(15,2),
    last_etl_load_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_financepro_provision PRIMARY KEY (id)
);


-- Dataset: GDS17102
CREATE SCHEMA IF NOT EXISTS actico;

-- This finance dataset supports mobility solutions operations. Key applications include data analysis,
CREATE TABLE IF NOT EXISTS actico.financeprovision_insights (
    id INT NOT NULL,
    provision_record_id STRING NOT NULL,
    masreph_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    loan_account_number STRING NOT NULL,
    iban_primary_disbursement_account STRING,
    vehicle_vin STRING,
    customer_country_of_residence STRING NOT NULL,
    customer_residential_status STRING,
    currency_code STRING NOT NULL,
    product_type_code STRING NOT NULL,
    mobility_solution_category STRING,
    origination_date DATE NOT NULL,
    first_repayment_date DATE,
    maturity_date DATE,
    origination_timestamp TIMESTAMP NOT NULL,
    last_status_update_timestamp TIMESTAMP,
    principal_amount DECIMAL(18,2) NOT NULL,
    outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    accrued_interest_amount DECIMAL(18,2),
    annual_percentage_rate DECIMAL(5,3) NOT NULL,
    term_months INT NOT NULL,
    payment_frequency_code STRING NOT NULL,
    monthly_installment_amount DECIMAL(18,2),
    late_fee_accrued_amount DECIMAL(18,2),
    loan_status_code STRING NOT NULL,
    days_past_due INT NOT NULL,
    write_off_flag BOOLEAN NOT NULL,
    write_off_date DATE,
    profitability_margin_percentage DECIMAL(6,3),
    expected_credit_loss_amount DECIMAL(18,2),
    cost_center_code STRING,
    reporting_segment_code STRING,
    marketing_consent_flag BOOLEAN NOT NULL,
    data_processing_consent_flag BOOLEAN NOT NULL,
    customer_risk_rating STRING,
    ltv_ratio_percentage DECIMAL(6,3),
    collateral_estimated_value_amount DECIMAL(18,2),
    record_effective_date DATE NOT NULL,
    record_archived_flag BOOLEAN NOT NULL,
    applicable_data_tags ARRAY<STRING> NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_financeprovision_ins PRIMARY KEY (id)
);


-- Dataset: GDS25371
CREATE SCHEMA IF NOT EXISTS actico;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS actico.credit_risk_finance_dataset (
    id INT NOT NULL,
    dataset_record_id STRING NOT NULL,
    masreph_customer_id STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    application_id STRING,
    borrower_full_name STRING NOT NULL,
    borrower_date_of_birth DATE NOT NULL,
    borrower_country_of_residence STRING NOT NULL,
    borrower_address_structured MAP<STRING, STRING>,
    borrower_segment STRING NOT NULL,
    borrower_industry_code STRING,
    borrower_annual_income DECIMAL(15,2),
    borrower_employment_status STRING,
    customer_marketing_consent_flag BOOLEAN NOT NULL,
    customer_data_processing_consent_flag BOOLEAN NOT NULL,
    loan_currency_code STRING NOT NULL,
    lease_principal_amount DECIMAL(18,2) NOT NULL,
    lease_term_months INT NOT NULL,
    lease_interest_rate DECIMAL(7,4) NOT NULL,
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    payment_frequency_code STRING NOT NULL,
    origination_channel STRING,
    collateral_type STRING,
    collateral_estimated_value DECIMAL(18,2),
    credit_score_internal INT,
    credit_score_external INT,
    probability_of_default_12m DECIMAL(6,4),
    loss_given_default_percent DECIMAL(5,2),
    exposure_at_default DECIMAL(18,2),
    prior_delinquency_history_dpd ARRAY<STRING>,
    days_past_due_current INT NOT NULL,
    current_delinquency_status STRING NOT NULL,
    default_flag BOOLEAN NOT NULL,
    default_date DATE,
    restructuring_flag BOOLEAN NOT NULL,
    write_off_amount DECIMAL(18,2),
    record_effective_timestamp TIMESTAMP NOT NULL,
    record_end_timestamp TIMESTAMP,
    data_source_system STRING NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_credit_risk_finance_ PRIMARY KEY (id)
);


-- Dataset: GDS25875
CREATE SCHEMA IF NOT EXISTS actico;

-- This finance dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE IF NOT EXISTS actico.financeprovision_insights (
    id INT NOT NULL,
    provision_record_id STRING NOT NULL,
    lease_contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_legal_name STRING NOT NULL,
    customer_tax_identifier STRING,
    country_code STRING NOT NULL,
    business_segment STRING,
    product_type STRING NOT NULL,
    asset_category STRING,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    booking_date DATE NOT NULL,
    reporting_period DATE NOT NULL,
    currency_code STRING NOT NULL,
    original_lease_amount DECIMAL(18,2) NOT NULL,
    outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    accrued_interest_amount DECIMAL(18,2),
    expected_credit_loss_amount DECIMAL(18,2) NOT NULL,
    impairment_stage STRING NOT NULL,
    probability_of_default DECIMAL(6,4) NOT NULL,
    loss_given_default DECIMAL(5,4) NOT NULL,
    exposure_at_default DECIMAL(18,2) NOT NULL,
    days_past_due INT NOT NULL,
    contract_status STRING NOT NULL,
    restructuring_flag BOOLEAN NOT NULL,
    restructuring_date DATE,
    write_off_amount DECIMAL(18,2),
    collateral_type STRING,
    collateral_valuation_amount DECIMAL(18,2),
    effective_interest_rate DECIMAL(7,4) NOT NULL,
    marketing_consent_flag BOOLEAN NOT NULL,
    data_archived_flag BOOLEAN NOT NULL,
    sensitive_data_flag BOOLEAN NOT NULL,
    profitability_segment_code STRING,
    net_interest_income_period DECIMAL(18,2),
    operating_expense_allocated DECIMAL(18,2),
    budgeted_provision_amount DECIMAL(18,2),
    provision_release_amount DECIMAL(18,2),
    provision_charge_amount DECIMAL(18,2),
    region_reporting_hub STRING,
    record_creation_timestamp TIMESTAMP NOT NULL,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    data_quality_issues ARRAY<STRING>,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_financeprovision_ins PRIMARY KEY (id)
);


-- Dataset: GDS38790
CREATE SCHEMA IF NOT EXISTS actico;

-- This finance dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE IF NOT EXISTS actico.financeprovision_insights (
    id INT NOT NULL,
    lease_contract_id STRING NOT NULL,
    customer_hashed_id STRING NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE,
    reporting_period_month STRING NOT NULL,
    lease_outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    impairment_provision_amount DECIMAL(18,2) NOT NULL,
    expected_credit_loss_rate DECIMAL(5,4),
    provisioning_stage_code STRING NOT NULL,
    customer_risk_rating STRING,
    contract_currency_code STRING NOT NULL,
    marketing_consent_flag BOOLEAN NOT NULL,
    last_status_update_timestamp TIMESTAMP,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_financeprovision_ins PRIMARY KEY (id)
);


-- Dataset: GDS87048
CREATE SCHEMA IF NOT EXISTS actico;

-- This finance dataset supports leasing operations. Key applications include data analysis, reporting,
CREATE TABLE IF NOT EXISTS actico.financeprovision_insights (
    id INT NOT NULL,
    contract_id STRING NOT NULL,
    customer_internal_id STRING NOT NULL,
    customer_region_code STRING NOT NULL,
    customer_marketing_consent_flag BOOLEAN NOT NULL,
    product_type STRING NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_maturity_date DATE,
    currency_code STRING NOT NULL,
    original_principal_amount DECIMAL(18,2) NOT NULL,
    outstanding_principal_amount DECIMAL(18,2) NOT NULL,
    effective_interest_rate DECIMAL(7,4) NOT NULL,
    lease_term_months INT NOT NULL,
    provision_stage_code STRING NOT NULL,
    expected_credit_loss_amount DECIMAL(18,2) NOT NULL,
    contract_status_code STRING NOT NULL,
    monthly_lease_payment_amount DECIMAL(18,2) NOT NULL,
    portfolio_profitability_margin_pct DECIMAL(6,3),
    last_payment_date DATE,
    record_last_updated_timestamp TIMESTAMP NOT NULL,
    _loaded_at TIMESTAMP,
    _source_file STRING
    ,CONSTRAINT PK_financeprovision_ins PRIMARY KEY (id)
);


