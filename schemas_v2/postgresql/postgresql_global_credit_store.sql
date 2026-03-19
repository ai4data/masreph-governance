-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: postgresql_global_credit_store
-- Generated: 2026-03-18T12:17:47.427396
-- Datasets: 17
-- ============================================

-- Dataset: GDS15620
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Customer master data for counterparties involved in leasing agreements, including legal identity and
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customers (
    customer_party_id VARCHAR(255) NOT NULL,
    customer_legal_name VARCHAR(255) NOT NULL,
    customer_registration_number VARCHAR(255),
    customer_country_of_incorporation VARCHAR(255) NOT NULL,
    customer_industry_sector VARCHAR(255),
    consent_to_marketing_ind BOOLEAN NOT NULL,
    personal_data_processing_basis VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (customer_party_id)
);

-- Leasing contract master records capturing contractual exposure, credit risk metrics, delinquency sta
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leasing_contracts (
    leasing_contract_id VARCHAR(255) NOT NULL,
    customer_party_id VARCHAR(255) NOT NULL,
    loan_currency VARCHAR(255) NOT NULL,
    loan_outstanding_balance NUMERIC(18,4) NOT NULL,
    credit_risk_rating VARCHAR(255),
    probability_of_default_12m NUMERIC(18,4),
    loss_given_default_percentage NUMERIC(18,4),
    exposure_at_default_amount NUMERIC(18,4),
    last_credit_review_date DATE,
    next_credit_review_date DATE,
    days_past_due INTEGER NOT NULL,
    non_performing_flag BOOLEAN NOT NULL,
    recovery_strategy_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leasing_contracts PRIMARY KEY (leasing_contract_id)
);

-- Master data for collateral assets pledged under leasing arrangements, including type, description, l
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_assets (
    collateral_asset_id VARCHAR(255) NOT NULL,
    collateral_asset_type VARCHAR(255) NOT NULL,
    collateral_asset_description VARCHAR(255),
    collateral_location_country VARCHAR(255),
    collateral_location_postcode VARCHAR(255),
    collateral_insurance_expiry_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_assets PRIMARY KEY (collateral_asset_id)
);

-- Registry and internal charge identifiers associated with collateral assets, one row per charge.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_asset_charges (
    collateral_asset_charge_id BIGINT NOT NULL,
    collateral_asset_id VARCHAR(255) NOT NULL,
    collateral_charge_identifier VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_asset_cha PRIMARY KEY (collateral_asset_charge_id)
);

-- Collateral-level CreditShield finance records linking leasing contracts to collateral assets, includ
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.creditshield_finance_records (
    creditshield_record_id VARCHAR(255) NOT NULL,
    leasing_contract_id VARCHAR(255) NOT NULL,
    collateral_asset_id VARCHAR(255) NOT NULL,
    collateral_valuation_amount NUMERIC(18,4) NOT NULL,
    collateral_valuation_currency VARCHAR(255) NOT NULL,
    collateral_valuation_date DATE NOT NULL,
    collateral_forced_sale_value NUMERIC(18,4),
    loan_to_value_ratio NUMERIC(18,4) NOT NULL,
    collateral_haircut_percentage NUMERIC(18,4),
    security_perfection_status VARCHAR(255) NOT NULL,
    security_ranking VARCHAR(255),
    data_source_system VARCHAR(255) NOT NULL,
    record_effective_timestamp TIMESTAMPTZ NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_creditshield_finance PRIMARY KEY (creditshield_record_id)
);

ALTER TABLE postgresql_global_credit_store.leasing_contracts ADD CONSTRAINT FK_leasing_contracts_customer_
    FOREIGN KEY (customer_party_id) REFERENCES postgresql_global_credit_store.customers (customer_party_id);

ALTER TABLE postgresql_global_credit_store.collateral_asset_charges ADD CONSTRAINT FK_collateral_asset_charges_co
    FOREIGN KEY (collateral_asset_id) REFERENCES postgresql_global_credit_store.collateral_assets (collateral_asset_id);

ALTER TABLE postgresql_global_credit_store.creditshield_finance_records ADD CONSTRAINT FK_creditshield_finance_record
    FOREIGN KEY (leasing_contract_id) REFERENCES postgresql_global_credit_store.leasing_contracts (leasing_contract_id);

ALTER TABLE postgresql_global_credit_store.creditshield_finance_records ADD CONSTRAINT FK_creditshield_finance_record
    FOREIGN KEY (collateral_asset_id) REFERENCES postgresql_global_credit_store.collateral_assets (collateral_asset_id);


-- Dataset: GDS16114
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Commercial borrowers / corporate customers that own credit finance agreements.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.borrowers (
    borrower_id UUID NOT NULL,
    parent_customer_code VARCHAR(18) NOT NULL,
    borrower_legal_name VARCHAR(255) NOT NULL,
    borrower_tax_id VARCHAR(20),
    borrower_country_code VARCHAR(2) NOT NULL,
    borrower_industry_code VARCHAR(6),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_borrowers PRIMARY KEY (borrower_id)
);

-- Upstream origination or servicing platforms from which credit finance agreements originate.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.source_systems (
    source_system_id UUID NOT NULL,
    source_system_code VARCHAR(32) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_source_systems PRIMARY KEY (source_system_id)
);

-- Relationship managers or credit officers responsible for originating agreements.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.origination_officers (
    origination_officer_id UUID NOT NULL,
    origination_officer_code VARCHAR(16) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_origination_officers PRIMARY KEY (origination_officer_id)
);

-- Internal branches or booking centers where credit finance agreements are recorded.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.booking_branches (
    booking_branch_id UUID NOT NULL,
    booking_branch_code VARCHAR(10) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_booking_branches PRIMARY KEY (booking_branch_id)
);

-- Core credit finance agreements, including contractual terms, status, risk, and performance metrics.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_agreements (
    credit_finance_agreement_id UUID NOT NULL,
    agreement_id UUID NOT NULL,
    agreement_number VARCHAR(20) NOT NULL,
    borrower_id UUID NOT NULL,
    source_system_id UUID NOT NULL,
    origination_officer_id UUID,
    booking_branch_id UUID NOT NULL,
    credit_product_type VARCHAR(20) NOT NULL,
    credit_facility_type VARCHAR(80),
    currency_code VARCHAR(3) NOT NULL,
    agreement_start_date DATE NOT NULL,
    agreement_maturity_date DATE NOT NULL,
    first_disbursement_date DATE,
    last_renewal_date DATE,
    agreement_status VARCHAR(20) NOT NULL,
    credit_limit_amount NUMERIC(18,2) NOT NULL,
    outstanding_principal_amount NUMERIC(18,2) NOT NULL,
    undrawn_amount NUMERIC(18,2) NOT NULL,
    interest_rate_type VARCHAR(20) NOT NULL,
    nominal_interest_rate NUMERIC(7,4),
    interest_rate_index VARCHAR(40),
    interest_rate_spread_bps INTEGER,
    payment_frequency VARCHAR(20) NOT NULL,
    days_past_due INTEGER NOT NULL,
    non_accrual_flag BOOLEAN NOT NULL,
    internal_risk_rating INTEGER,
    probability_of_default NUMERIC(6,4),
    collateral_coverage_ratio NUMERIC(8,4),
    sector_exposure_limit_utilization NUMERIC(6,2),
    annual_fee_amount NUMERIC(18,2),
    ytd_interest_income_amount NUMERIC(18,2),
    ytd_fee_income_amount NUMERIC(18,2),
    prepayment_penalty_flag BOOLEAN NOT NULL,
    covenant_breach_flag BOOLEAN NOT NULL,
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    performance_segment VARCHAR(50),
    agreement_last_review_timestamp TIMESTAMPTZ,
    regulatory_reporting_category VARCHAR(60),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_finance_agree PRIMARY KEY (credit_finance_agreement_id)
);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_b
    FOREIGN KEY (borrower_id) REFERENCES postgresql_global_credit_store.borrowers (borrower_id);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_s
    FOREIGN KEY (source_system_id) REFERENCES postgresql_global_credit_store.source_systems (source_system_id);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_o
    FOREIGN KEY (origination_officer_id) REFERENCES postgresql_global_credit_store.origination_officers (origination_officer_id);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_b
    FOREIGN KEY (booking_branch_id) REFERENCES postgresql_global_credit_store.booking_branches (booking_branch_id);


-- Dataset: GDS20820
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Lessee (borrower) master data, including industry, legal form, and country of residence, used to agg
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.lessee_customers (
    lessee_customer_id VARCHAR(255) NOT NULL,
    borrower_industry_code_nace VARCHAR(255),
    borrower_legal_form VARCHAR(255),
    borrower_country_of_residence VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lessee_customers PRIMARY KEY (lessee_customer_id)
);

-- Legal entities or branches where lease contracts are booked, used for regional and entity-level risk
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.booking_branches (
    booking_branch_id INTEGER NOT NULL,
    booking_branch_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_booking_branches PRIMARY KEY (booking_branch_id)
);

-- Leasing product types such as finance lease or operating lease, used for portfolio segmentation and 
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.product_types (
    product_type_id INTEGER NOT NULL,
    product_type_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_product_types PRIMARY KEY (product_type_id)
);

-- Source operational or risk systems from which leasing credit exposure records are sourced, used for 
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.source_systems (
    source_system_id INTEGER NOT NULL,
    source_system_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_source_systems PRIMARY KEY (source_system_id)
);

-- Leasing credit exposure contracts and their associated risk metrics, cash-flow terms, collateral inf
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leasing_credit_exposures (
    dataset_loan_id VARCHAR(255) NOT NULL,
    lessee_customer_id VARCHAR(255) NOT NULL,
    external_contract_reference VARCHAR(255),
    country_of_risk_code VARCHAR(255) NOT NULL,
    booking_branch_id INTEGER NOT NULL,
    product_type_id INTEGER NOT NULL,
    asset_category VARCHAR(255) NOT NULL,
    asset_description VARCHAR(255),
    asset_residual_value NUMERIC(18,4),
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    first_payment_date DATE,
    contract_status_code VARCHAR(255) NOT NULL,
    days_past_due INTEGER NOT NULL,
    current_principal_outstanding NUMERIC(18,4) NOT NULL,
    interest_rate_nominal NUMERIC(18,4) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    installment_amount NUMERIC(18,4) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    original_principal_amount NUMERIC(18,4) NOT NULL,
    original_tenor_months INTEGER NOT NULL,
    collateral_type_code VARCHAR(255),
    collateral_valuation_amount NUMERIC(18,4),
    collateral_valuation_date DATE,
    probability_of_default_12m NUMERIC(18,4),
    loss_given_default NUMERIC(18,4),
    exposure_at_default NUMERIC(18,4),
    internal_rating_grade VARCHAR(255),
    rating_model_version VARCHAR(255),
    default_indicator BOOLEAN NOT NULL,
    default_date DATE,
    restructuring_flag BOOLEAN NOT NULL,
    forbearance_flag BOOLEAN NOT NULL,
    write_off_amount NUMERIC(18,4),
    impairment_stage_ifrs9 VARCHAR(255) NOT NULL,
    expected_credit_loss_12m NUMERIC(18,4),
    lifetime_expected_credit_loss NUMERIC(18,4),
    gdp_compliance_flag BOOLEAN NOT NULL,
    data_record_timestamp TIMESTAMPTZ NOT NULL,
    source_system_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leasing_credit_expos PRIMARY KEY (dataset_loan_id)
);

ALTER TABLE postgresql_global_credit_store.leasing_credit_exposures ADD CONSTRAINT FK_leasing_credit_exposures_le
    FOREIGN KEY (lessee_customer_id) REFERENCES postgresql_global_credit_store.lessee_customers (lessee_customer_id);

ALTER TABLE postgresql_global_credit_store.leasing_credit_exposures ADD CONSTRAINT FK_leasing_credit_exposures_bo
    FOREIGN KEY (booking_branch_id) REFERENCES postgresql_global_credit_store.booking_branches (booking_branch_id);

ALTER TABLE postgresql_global_credit_store.leasing_credit_exposures ADD CONSTRAINT FK_leasing_credit_exposures_pr
    FOREIGN KEY (product_type_id) REFERENCES postgresql_global_credit_store.product_types (product_type_id);

ALTER TABLE postgresql_global_credit_store.leasing_credit_exposures ADD CONSTRAINT FK_leasing_credit_exposures_so
    FOREIGN KEY (source_system_id) REFERENCES postgresql_global_credit_store.source_systems (source_system_id);


-- Dataset: GDS26363
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Customers/obligors associated with leasing contracts and collateral.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customers (
    id UUID NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    customer_type VARCHAR(255) NOT NULL,
    customer_legal_name VARCHAR(255) NOT NULL,
    customer_country_code VARCHAR(255) NOT NULL,
    customer_industry_nace_code VARCHAR(255),
    aml_kyc_risk_rating VARCHAR(255),
    consent_to_process_personal_data_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (id)
);

-- Physical collateral assets pledged under leasing contracts.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collaterals (
    id UUID NOT NULL,
    collateral_id VARCHAR(255) NOT NULL,
    collateral_type VARCHAR(255) NOT NULL,
    asset_description VARCHAR(255),
    asset_serial_number VARCHAR(255),
    asset_manufacturer_name VARCHAR(255),
    asset_model_name VARCHAR(255),
    asset_production_year INTEGER,
    asset_location_country_code VARCHAR(255),
    asset_location_postal_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collaterals PRIMARY KEY (id)
);

-- Leasing agreements under which collateral assets are pledged.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leasing_contracts (
    id UUID NOT NULL,
    leasing_contract_id VARCHAR(255) NOT NULL,
    customer_id UUID NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_maturity_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leasing_contracts PRIMARY KEY (id)
);

-- Valuation information for collateral assets, including market and forced-sale values.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_valuations (
    id UUID NOT NULL,
    collateral_asset_id UUID NOT NULL,
    collateral_currency_code VARCHAR(255) NOT NULL,
    collateral_valuation_amount NUMERIC(18,4) NOT NULL,
    collateral_forced_sale_value NUMERIC(18,4),
    valuation_effective_date DATE NOT NULL,
    valuation_method_code VARCHAR(255) NOT NULL,
    valuation_provider_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_valuation PRIMARY KEY (id)
);

-- Exposure records linking collateral assets to leasing contracts with associated risk metrics, lifecy
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_exposures (
    dataset_record_id VARCHAR(255) NOT NULL,
    leasing_contract_id UUID NOT NULL,
    collateral_asset_id UUID NOT NULL,
    collateral_valuation_id UUID NOT NULL,
    ltv_ratio_current NUMERIC(18,4),
    ltv_ratio_at_origination NUMERIC(18,4),
    exposure_at_default_amount NUMERIC(18,4),
    probability_of_default_pct NUMERIC(18,4),
    loss_given_default_pct NUMERIC(18,4),
    collateral_haircut_pct NUMERIC(18,4),
    collateral_status_code VARCHAR(255) NOT NULL,
    repossession_flag BOOLEAN NOT NULL,
    repossession_date DATE,
    impairment_indicator BOOLEAN NOT NULL,
    impairment_recognition_date DATE,
    recovery_strategy_code VARCHAR(255),
    expected_recovery_rate_pct NUMERIC(18,4),
    expected_recovery_timeline_months INTEGER,
    last_credit_review_timestamp TIMESTAMPTZ,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_update_timestamp TIMESTAMPTZ NOT NULL,
    data_lineage_reference_id VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_exposures PRIMARY KEY (dataset_record_id)
);

ALTER TABLE postgresql_global_credit_store.leasing_contracts ADD CONSTRAINT FK_leasing_contracts_customer_
    FOREIGN KEY (customer_id) REFERENCES postgresql_global_credit_store.customers (id);

ALTER TABLE postgresql_global_credit_store.collateral_valuations ADD CONSTRAINT FK_collateral_valuations_colla
    FOREIGN KEY (collateral_asset_id) REFERENCES postgresql_global_credit_store.collaterals (id);

ALTER TABLE postgresql_global_credit_store.collateral_exposures ADD CONSTRAINT FK_collateral_exposures_leasin
    FOREIGN KEY (leasing_contract_id) REFERENCES postgresql_global_credit_store.leasing_contracts (id);

ALTER TABLE postgresql_global_credit_store.collateral_exposures ADD CONSTRAINT FK_collateral_exposures_collat
    FOREIGN KEY (collateral_asset_id) REFERENCES postgresql_global_credit_store.collaterals (id);

ALTER TABLE postgresql_global_credit_store.collateral_exposures ADD CONSTRAINT FK_collateral_exposures_collat
    FOREIGN KEY (collateral_valuation_id) REFERENCES postgresql_global_credit_store.collateral_valuations (id);


-- Dataset: GDS32724
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Leasing customers with internal identifiers and risk-relevant attributes
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customers (
    customer_id BIGINT NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    customer_segment_id BIGINT NOT NULL,
    counterparty_region_id BIGINT NOT NULL,
    industry_sector_id BIGINT,
    customer_risk_country_iso2 VARCHAR(255) NOT NULL,
    consent_to_process_personal_data_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);

-- Reference data for customer risk-relevant segments
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customer_segments (
    customer_segment_id BIGINT NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_segments PRIMARY KEY (customer_segment_id)
);

-- Reference data for geographical regions of counterparties
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.counterparty_regions (
    counterparty_region_id BIGINT NOT NULL,
    counterparty_region VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_counterparty_regions PRIMARY KEY (counterparty_region_id)
);

-- Reference data for leased asset type classifications
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.asset_types (
    asset_type_id BIGINT NOT NULL,
    asset_type_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_asset_types PRIMARY KEY (asset_type_id)
);

-- Reference data for ISO currency codes
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.currencies (
    currency_id BIGINT NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_currencies PRIMARY KEY (currency_id)
);

-- Legal entities acting as booking units for leases
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.booking_entities (
    booking_entity_id BIGINT NOT NULL,
    booking_entity_legal_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_booking_entities PRIMARY KEY (booking_entity_id)
);

-- Reference data for interest rate type classifications
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.interest_rate_types (
    interest_rate_type_id BIGINT NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_interest_rate_types PRIMARY KEY (interest_rate_type_id)
);

-- Reference data for lease payment frequency codes
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.payment_frequencies (
    payment_frequency_id BIGINT NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_payment_frequencies PRIMARY KEY (payment_frequency_id)
);

-- Reference data for customer industry sector classifications
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.industry_sectors (
    industry_sector_id BIGINT NOT NULL,
    industry_sector_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_industry_sectors PRIMARY KEY (industry_sector_id)
);

-- Reference data for regulatory reporting portfolio classifications
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.regulatory_portfolios (
    regulatory_portfolio_id BIGINT NOT NULL,
    regulatory_reporting_portfolio VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_regulatory_portfolio PRIMARY KEY (regulatory_portfolio_id)
);

-- Reference data for EBA default status codes
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.eba_default_statuses (
    eba_default_status_id BIGINT NOT NULL,
    eba_default_status_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_eba_default_statuses PRIMARY KEY (eba_default_status_id)
);

-- Core lease contracts with associated risk, financial and status attributes
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leases (
    lease_id BIGINT NOT NULL,
    lease_contract_id VARCHAR(255) NOT NULL,
    customer_id BIGINT NOT NULL,
    booking_entity_id BIGINT NOT NULL,
    currency_id BIGINT NOT NULL,
    interest_rate_type_id BIGINT NOT NULL,
    payment_frequency_id BIGINT NOT NULL,
    regulatory_portfolio_id BIGINT NOT NULL,
    eba_default_status_id BIGINT NOT NULL,
    exposure_at_default NUMERIC(18,4) NOT NULL,
    loss_given_default_pct NUMERIC(18,4) NOT NULL,
    probability_of_default_12m_pct NUMERIC(18,4) NOT NULL,
    credit_risk_rating_internal VARCHAR(255),
    credit_risk_rating_external VARCHAR(255),
    days_past_due INTEGER NOT NULL,
    non_performing_exposure_flag BOOLEAN NOT NULL,
    restructuring_flag BOOLEAN NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE NOT NULL,
    first_payment_due_date DATE NOT NULL,
    interest_rate_nominal NUMERIC(18,4) NOT NULL,
    outstanding_principal_amount NUMERIC(18,4) NOT NULL,
    country_of_risk VARCHAR(255) NOT NULL,
    ifrs9_stage INTEGER NOT NULL,
    default_date DATE,
    write_off_date DATE,
    impairment_amount NUMERIC(18,4) NOT NULL,
    provisioning_amount NUMERIC(18,4) NOT NULL,
    limit_amount NUMERIC(18,4) NOT NULL,
    utilized_limit_amount NUMERIC(18,4) NOT NULL,
    last_status_update_timestamp TIMESTAMPTZ NOT NULL,
    record_source_system VARCHAR(255) NOT NULL,
    data_quality_score JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leases PRIMARY KEY (lease_id)
);

-- Assets associated with lease contracts, including type and market value
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leased_assets (
    leased_asset_id BIGINT NOT NULL,
    lease_id BIGINT NOT NULL,
    asset_type_id BIGINT NOT NULL,
    asset_description VARCHAR(255),
    market_value_of_leased_asset NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leased_assets PRIMARY KEY (leased_asset_id)
);

-- Reference data for collateral type classifications
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_types (
    collateral_type_id BIGINT NOT NULL,
    collateral_type_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_types PRIMARY KEY (collateral_type_id)
);

-- Primary collateral details linked to lease contracts
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collaterals (
    collateral_id BIGINT NOT NULL,
    lease_id BIGINT NOT NULL,
    collateral_type_id BIGINT,
    collateral_valuation_amount NUMERIC(18,4),
    collateral_valuation_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collaterals PRIMARY KEY (collateral_id)
);

-- Operational risk event indicators and classifications per lease
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.operational_risk_events (
    operational_risk_event_id BIGINT NOT NULL,
    lease_id BIGINT NOT NULL,
    operational_risk_event_flag BOOLEAN NOT NULL,
    operational_risk_event_type JSONB,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_operational_risk_eve PRIMARY KEY (operational_risk_event_id)
);

ALTER TABLE postgresql_global_credit_store.customers ADD CONSTRAINT FK_customers_customer_segment_
    FOREIGN KEY (customer_segment_id) REFERENCES postgresql_global_credit_store.customer_segments (customer_segment_id);

ALTER TABLE postgresql_global_credit_store.customers ADD CONSTRAINT FK_customers_counterparty_regi
    FOREIGN KEY (counterparty_region_id) REFERENCES postgresql_global_credit_store.counterparty_regions (counterparty_region_id);

ALTER TABLE postgresql_global_credit_store.customers ADD CONSTRAINT FK_customers_industry_sector_i
    FOREIGN KEY (industry_sector_id) REFERENCES postgresql_global_credit_store.industry_sectors (industry_sector_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_customer_id
    FOREIGN KEY (customer_id) REFERENCES postgresql_global_credit_store.customers (customer_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_booking_entity_id
    FOREIGN KEY (booking_entity_id) REFERENCES postgresql_global_credit_store.booking_entities (booking_entity_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_currency_id
    FOREIGN KEY (currency_id) REFERENCES postgresql_global_credit_store.currencies (currency_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_interest_rate_type_i
    FOREIGN KEY (interest_rate_type_id) REFERENCES postgresql_global_credit_store.interest_rate_types (interest_rate_type_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_payment_frequency_id
    FOREIGN KEY (payment_frequency_id) REFERENCES postgresql_global_credit_store.payment_frequencies (payment_frequency_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_regulatory_portfolio
    FOREIGN KEY (regulatory_portfolio_id) REFERENCES postgresql_global_credit_store.regulatory_portfolios (regulatory_portfolio_id);

ALTER TABLE postgresql_global_credit_store.leases ADD CONSTRAINT FK_leases_eba_default_status_i
    FOREIGN KEY (eba_default_status_id) REFERENCES postgresql_global_credit_store.eba_default_statuses (eba_default_status_id);

ALTER TABLE postgresql_global_credit_store.leased_assets ADD CONSTRAINT FK_leased_assets_lease_id
    FOREIGN KEY (lease_id) REFERENCES postgresql_global_credit_store.leases (lease_id);

ALTER TABLE postgresql_global_credit_store.leased_assets ADD CONSTRAINT FK_leased_assets_asset_type_id
    FOREIGN KEY (asset_type_id) REFERENCES postgresql_global_credit_store.asset_types (asset_type_id);

ALTER TABLE postgresql_global_credit_store.collaterals ADD CONSTRAINT FK_collaterals_lease_id
    FOREIGN KEY (lease_id) REFERENCES postgresql_global_credit_store.leases (lease_id);

ALTER TABLE postgresql_global_credit_store.collaterals ADD CONSTRAINT FK_collaterals_collateral_type
    FOREIGN KEY (collateral_type_id) REFERENCES postgresql_global_credit_store.collateral_types (collateral_type_id);

ALTER TABLE postgresql_global_credit_store.operational_risk_events ADD CONSTRAINT FK_operational_risk_events_lea
    FOREIGN KEY (lease_id) REFERENCES postgresql_global_credit_store.leases (lease_id);


-- Dataset: GDS49165
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Master data for lessee/borrower customers associated with lease contracts and credit risk exposures.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.borrowers (
    id BIGSERIAL NOT NULL,
    borrower_customer_id VARCHAR(255) NOT NULL,
    borrower_name VARCHAR(255) NOT NULL,
    borrower_country_code VARCHAR(255) NOT NULL,
    borrower_risk_segment VARCHAR(255) NOT NULL,
    industry_sector_code VARCHAR(255),
    exposure_group_id BIGINT,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_borrowers PRIMARY KEY (id)
);

-- Economic group or related-party clusters used for group-level credit exposure aggregation and concen
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.exposure_groups (
    id BIGSERIAL NOT NULL,
    group_exposure_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_exposure_groups PRIMARY KEY (id)
);

-- Reference data for leasing product types such as finance leases, operating leases, and sale-and-leas
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.leasing_products (
    id BIGSERIAL NOT NULL,
    product_type_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leasing_products PRIMARY KEY (id)
);

-- Reference data describing categories of underlying leased assets used as collateral in credit risk a
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.asset_types (
    id BIGSERIAL NOT NULL,
    asset_type_description VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_asset_types PRIMARY KEY (id)
);

-- Reference data for ISO 4217 currencies used in lease contracts and exposure amounts.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.currencies (
    id BIGSERIAL NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_currencies PRIMARY KEY (id)
);

-- Reference data for Asia Pacific regional market clusters such as Greater China, ASEAN, and ANZ.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.asia_pac_regions (
    id BIGSERIAL NOT NULL,
    asia_pac_region_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_asia_pac_regions PRIMARY KEY (id)
);

-- Reference data for originating operational and risk systems supplying credit risk rating records.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.source_systems (
    id BIGSERIAL NOT NULL,
    data_source_system_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_source_systems PRIMARY KEY (id)
);

-- Reference data for internal credit rating model versions used to generate risk scores and grades.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.rating_models (
    id BIGSERIAL NOT NULL,
    rating_model_version VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_rating_models PRIMARY KEY (id)
);

-- Reference data for external credit rating agencies used to source public credit ratings.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.external_rating_agencies (
    id BIGSERIAL NOT NULL,
    external_rating_agency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_external_rating_agen PRIMARY KEY (id)
);

-- Master data for lease contracts that give rise to credit exposures assessed in the credit risk ratin
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.lease_contracts (
    id BIGSERIAL NOT NULL,
    lease_contract_id VARCHAR(255) NOT NULL,
    borrower_id BIGINT NOT NULL,
    product_type_id BIGINT NOT NULL,
    asset_type_id BIGINT,
    currency_id BIGINT NOT NULL,
    asia_pac_region_id BIGINT,
    contract_start_date DATE NOT NULL,
    contract_maturity_date DATE NOT NULL,
    effective_interest_rate NUMERIC(18,4),
    restructuring_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lease_contracts PRIMARY KEY (id)
);

-- Fact table capturing credit risk rating assessments and exposure metrics for lease contracts over ti
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_risk_ratings (
    credit_risk_record_id VARCHAR(255) NOT NULL,
    lease_contract_internal_id BIGINT NOT NULL,
    rating_model_id BIGINT,
    external_rating_agency_id BIGINT,
    data_source_system_id BIGINT NOT NULL,
    outstanding_principal_amount NUMERIC(18,4) NOT NULL,
    total_commitment_amount NUMERIC(18,4),
    collateral_value_current NUMERIC(18,4),
    loan_to_value_ratio NUMERIC(18,4),
    internal_rating_grade VARCHAR(255) NOT NULL,
    internal_rating_score NUMERIC(18,4) NOT NULL,
    probability_of_default_12m NUMERIC(18,4) NOT NULL,
    loss_given_default_percentage NUMERIC(18,4),
    exposure_at_default_amount NUMERIC(18,4),
    days_past_due INTEGER NOT NULL,
    default_status_flag BOOLEAN NOT NULL,
    nonperforming_exposure_flag BOOLEAN NOT NULL,
    ifrs9_stage_code VARCHAR(255),
    rating_assessment_date DATE NOT NULL,
    next_review_due_date DATE,
    external_rating_grade VARCHAR(255),
    rating_override_flag BOOLEAN NOT NULL,
    rating_override_reason VARCHAR(255),
    macroeconomic_scenario_impacts JSONB,
    data_quality_status_code VARCHAR(255) NOT NULL,
    record_ingestion_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_risk_ratings PRIMARY KEY (credit_risk_record_id)
);

-- Junction table listing early warning indicators associated with each credit risk rating record.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_risk_rating_early_warning_indicators (
    id BIGSERIAL NOT NULL,
    credit_risk_record_id VARCHAR(255) NOT NULL,
    early_warning_indicator_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_risk_rating_e PRIMARY KEY (id)
);

ALTER TABLE postgresql_global_credit_store.borrowers ADD CONSTRAINT FK_borrowers_exposure_group_id
    FOREIGN KEY (exposure_group_id) REFERENCES postgresql_global_credit_store.exposure_groups (id);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_borrower_id
    FOREIGN KEY (borrower_id) REFERENCES postgresql_global_credit_store.borrowers (id);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_product_typ
    FOREIGN KEY (product_type_id) REFERENCES postgresql_global_credit_store.leasing_products (id);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_asset_type_
    FOREIGN KEY (asset_type_id) REFERENCES postgresql_global_credit_store.asset_types (id);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_currency_id
    FOREIGN KEY (currency_id) REFERENCES postgresql_global_credit_store.currencies (id);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_asia_pac_re
    FOREIGN KEY (asia_pac_region_id) REFERENCES postgresql_global_credit_store.asia_pac_regions (id);

ALTER TABLE postgresql_global_credit_store.credit_risk_ratings ADD CONSTRAINT FK_credit_risk_ratings_lease_c
    FOREIGN KEY (lease_contract_internal_id) REFERENCES postgresql_global_credit_store.lease_contracts (id);

ALTER TABLE postgresql_global_credit_store.credit_risk_ratings ADD CONSTRAINT FK_credit_risk_ratings_rating_
    FOREIGN KEY (rating_model_id) REFERENCES postgresql_global_credit_store.rating_models (id);

ALTER TABLE postgresql_global_credit_store.credit_risk_ratings ADD CONSTRAINT FK_credit_risk_ratings_externa
    FOREIGN KEY (external_rating_agency_id) REFERENCES postgresql_global_credit_store.external_rating_agencies (id);

ALTER TABLE postgresql_global_credit_store.credit_risk_ratings ADD CONSTRAINT FK_credit_risk_ratings_data_so
    FOREIGN KEY (data_source_system_id) REFERENCES postgresql_global_credit_store.source_systems (id);

ALTER TABLE postgresql_global_credit_store.credit_risk_rating_early_warning_indicators ADD CONSTRAINT FK_credit_risk_rating_early_wa
    FOREIGN KEY (credit_risk_record_id) REFERENCES postgresql_global_credit_store.credit_risk_ratings (credit_risk_record_id);


-- Dataset: GDS50533
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Core fact table storing credit finance / lease agreements and their contractual, risk, pricing, and 
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_agreements (
    agreement_id VARCHAR(255) NOT NULL,
    agreement_number VARCHAR(255) NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    borrower_residency_country VARCHAR(255) NOT NULL,
    agreement_type_code VARCHAR(255) NOT NULL,
    product_family_code VARCHAR(255) NOT NULL,
    asset_category_code VARCHAR(255),
    currency_code VARCHAR(255) NOT NULL,
    principal_amount NUMERIC(18,4) NOT NULL,
    outstanding_principal_amount NUMERIC(18,4) NOT NULL,
    interest_rate_nominal NUMERIC(18,4) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    reference_rate_code VARCHAR(255),
    spread_margin_bps INTEGER,
    agreement_start_date DATE NOT NULL,
    agreement_end_date DATE NOT NULL,
    first_payment_date DATE,
    payment_frequency_code VARCHAR(255) NOT NULL,
    installment_amount_scheduled NUMERIC(18,4),
    residual_value_guaranteed NUMERIC(18,4),
    agreement_status_code VARCHAR(255) NOT NULL,
    non_performing_flag BOOLEAN NOT NULL,
    days_past_due_bucket VARCHAR(255) NOT NULL,
    collateral_type_code VARCHAR(255),
    collateral_value_current NUMERIC(18,4),
    loan_to_value_percent NUMERIC(18,4),
    effective_annual_rate_percent NUMERIC(18,4),
    upfront_fee_amount NUMERIC(18,4),
    prepayment_allowed_flag BOOLEAN NOT NULL,
    prepayment_penalty_percent NUMERIC(18,4),
    sales_channel_code VARCHAR(255) NOT NULL,
    originating_branch_id VARCHAR(255),
    portfolio_segment_code VARCHAR(255) NOT NULL,
    credit_risk_grade VARCHAR(255),
    expected_loss_percent NUMERIC(18,4),
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    customer_consent_marketing_flag BOOLEAN NOT NULL,
    last_status_change_timestamp TIMESTAMPTZ NOT NULL,
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_update_timestamp TIMESTAMPTZ NOT NULL,
    data_privacy_classification VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_finance_agree PRIMARY KEY (agreement_id)
);

-- Reference table listing strategic customer segments (e.g., retail, SME, corporate).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customer_segments (
    customer_segment_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_segments PRIMARY KEY (customer_segment_code)
);

-- Reference table listing agreement types (e.g., operating lease, finance lease, revolving credit).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.agreement_types (
    agreement_type_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_agreement_types PRIMARY KEY (agreement_type_code)
);

-- Reference table listing high-level product family codes grouping similar leasing offerings.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.product_families (
    product_family_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_product_families PRIMARY KEY (product_family_code)
);

-- Reference table listing asset category codes for underlying leased assets.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.asset_categories (
    asset_category_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_asset_categories PRIMARY KEY (asset_category_code)
);

-- Reference table of ISO-4217 currency codes.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.currencies (
    currency_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_currencies PRIMARY KEY (currency_code)
);

-- Reference table for interest rate types (fixed, variable, mixed).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.interest_rate_types (
    interest_rate_type_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_interest_rate_types PRIMARY KEY (interest_rate_type_code)
);

-- Reference table listing market reference rates (e.g., Euribor, €STR).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.reference_rates (
    reference_rate_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_reference_rates PRIMARY KEY (reference_rate_code)
);

-- Reference table listing allowed payment frequency codes.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.payment_frequencies (
    payment_frequency_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_payment_frequencies PRIMARY KEY (payment_frequency_code)
);

-- Reference table listing lifecycle statuses for agreements.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.agreement_statuses (
    agreement_status_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_agreement_statuses PRIMARY KEY (agreement_status_code)
);

-- Reference table listing standardized days-past-due buckets for delinquency.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.days_past_due_buckets (
    days_past_due_bucket_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_days_past_due_bucket PRIMARY KEY (days_past_due_bucket_code)
);

-- Reference table listing collateral types securing agreements.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_types (
    collateral_type_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_types PRIMARY KEY (collateral_type_code)
);

-- Reference table listing acquisition channels (e.g., branch, dealer, online).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.sales_channels (
    sales_channel_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_sales_channels PRIMARY KEY (sales_channel_code)
);

-- Reference table listing internal portfolio segment or strategy buckets.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.portfolio_segments (
    portfolio_segment_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_portfolio_segments PRIMARY KEY (portfolio_segment_code)
);

-- Reference table listing internal credit risk rating grades.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_risk_grades (
    credit_risk_grade_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_risk_grades PRIMARY KEY (credit_risk_grade_code)
);

-- Reference table listing data privacy classification levels.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.data_privacy_classifications (
    data_privacy_classification_code VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_data_privacy_classif PRIMARY KEY (data_privacy_classification_code)
);

-- Reference table of ISO-3166-1 alpha-2 country codes.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.countries (
    country_code VARCHAR(255) NOT NULL,
    country_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_countries PRIMARY KEY (country_code)
);

-- Reference table of originating branches or booking centers.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.branches (
    branch_id VARCHAR(255) NOT NULL,
    branch_name VARCHAR(255),
    country_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_branches PRIMARY KEY (branch_id)
);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_c
    FOREIGN KEY (customer_segment_code) REFERENCES postgresql_global_credit_store.customer_segments (customer_segment_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_a
    FOREIGN KEY (agreement_type_code) REFERENCES postgresql_global_credit_store.agreement_types (agreement_type_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_p
    FOREIGN KEY (product_family_code) REFERENCES postgresql_global_credit_store.product_families (product_family_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_a
    FOREIGN KEY (asset_category_code) REFERENCES postgresql_global_credit_store.asset_categories (asset_category_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_c
    FOREIGN KEY (currency_code) REFERENCES postgresql_global_credit_store.currencies (currency_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_i
    FOREIGN KEY (interest_rate_type) REFERENCES postgresql_global_credit_store.interest_rate_types (interest_rate_type_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_r
    FOREIGN KEY (reference_rate_code) REFERENCES postgresql_global_credit_store.reference_rates (reference_rate_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_p
    FOREIGN KEY (payment_frequency_code) REFERENCES postgresql_global_credit_store.payment_frequencies (payment_frequency_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_a
    FOREIGN KEY (agreement_status_code) REFERENCES postgresql_global_credit_store.agreement_statuses (agreement_status_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_d
    FOREIGN KEY (days_past_due_bucket) REFERENCES postgresql_global_credit_store.days_past_due_buckets (days_past_due_bucket_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_c
    FOREIGN KEY (collateral_type_code) REFERENCES postgresql_global_credit_store.collateral_types (collateral_type_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_s
    FOREIGN KEY (sales_channel_code) REFERENCES postgresql_global_credit_store.sales_channels (sales_channel_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_p
    FOREIGN KEY (portfolio_segment_code) REFERENCES postgresql_global_credit_store.portfolio_segments (portfolio_segment_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_c
    FOREIGN KEY (credit_risk_grade) REFERENCES postgresql_global_credit_store.credit_risk_grades (credit_risk_grade_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_d
    FOREIGN KEY (data_privacy_classification) REFERENCES postgresql_global_credit_store.data_privacy_classifications (data_privacy_classification_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_b
    FOREIGN KEY (borrower_residency_country) REFERENCES postgresql_global_credit_store.countries (country_code);

ALTER TABLE postgresql_global_credit_store.branches ADD CONSTRAINT FK_branches_country_code
    FOREIGN KEY (country_code) REFERENCES postgresql_global_credit_store.countries (country_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_agreements ADD CONSTRAINT FK_credit_finance_agreements_o
    FOREIGN KEY (originating_branch_id) REFERENCES postgresql_global_credit_store.branches (branch_id);


-- Dataset: GDS55901
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Master data for leasing credit products, including internal product code, commercial name, and high-
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.lease_products (
    product_code VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_category VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lease_products PRIMARY KEY (product_code)
);

-- Legal entities acting as lessors for leasing products, used for consolidation and profitability anal
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.lessor_legal_entities (
    lessor_legal_entity_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lessor_legal_entitie PRIMARY KEY (lessor_legal_entity_id)
);

-- Reference table for ISO country codes representing jurisdictions where leasing products are offered.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.countries (
    country_iso_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_countries PRIMARY KEY (country_iso_code)
);

-- Reference table for ISO currency codes used for lease disbursement and repayment.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.currencies (
    currency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_currencies PRIMARY KEY (currency_code)
);

-- Reference table describing types of interest rate mechanisms (e.g., fixed, variable, indexed).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.interest_rate_types (
    interest_rate_type VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_interest_rate_types PRIMARY KEY (interest_rate_type)
);

-- Reference table describing amortization structures for leases (e.g., annuity, linear, balloon).
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.amortization_types (
    amortization_type VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_amortization_types PRIMARY KEY (amortization_type)
);

-- Reference table for target customer segments addressed by leasing products.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customer_segments (
    target_customer_segment VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customer_segments PRIMARY KEY (target_customer_segment)
);

-- Reference table for acquisition and sales channels through which leasing products are distributed.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.channels (
    channel_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_channels PRIMARY KEY (channel_code)
);

-- Reference table for internal risk classifications assigned to products.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.risk_grades (
    risk_grade VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_risk_grades PRIMARY KEY (risk_grade)
);

-- Reference table for regulatory classifications of leasing products.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.regulatory_product_categories (
    regulatory_product_category VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_regulatory_product_c PRIMARY KEY (regulatory_product_category)
);

-- Reference table describing primary collateral types associated with leasing products.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_types (
    collateral_type VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_types PRIMARY KEY (collateral_type)
);

-- Reference table for internal portfolio segment codes to which products are assigned.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.portfolio_segments (
    portfolio_segment_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_portfolio_segments PRIMARY KEY (portfolio_segment_code)
);

-- Reference table for pricing strategy codes applied to leasing products.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.pricing_strategies (
    pricing_strategy_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_pricing_strategies PRIMARY KEY (pricing_strategy_code)
);

-- Reference table for originating source systems providing product data.
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.data_source_systems (
    data_source_system VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_data_source_systems PRIMARY KEY (data_source_system)
);

-- Detailed definition of credit finance offerings for leasing, including pricing, eligibility, risk me
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_offerings (
    offering_id VARCHAR(255) NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    lessor_legal_entity_id VARCHAR(255) NOT NULL,
    country_iso_code VARCHAR(255) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    amortization_type VARCHAR(255) NOT NULL,
    target_customer_segment VARCHAR(255) NOT NULL,
    channel_code VARCHAR(255),
    risk_grade VARCHAR(255),
    regulatory_product_category VARCHAR(255),
    collateral_type VARCHAR(255),
    portfolio_segment_code VARCHAR(255) NOT NULL,
    pricing_strategy_code VARCHAR(255),
    data_source_system VARCHAR(255) NOT NULL,
    lease_term_months INTEGER NOT NULL,
    interest_rate_annual NUMERIC(18,4) NOT NULL,
    minimum_financed_amount NUMERIC(18,4) NOT NULL,
    maximum_financed_amount NUMERIC(18,4),
    residual_value_percentage NUMERIC(18,4),
    upfront_fee_amount NUMERIC(18,4),
    upfront_fee_percentage NUMERIC(18,4),
    early_termination_fee_amount NUMERIC(18,4),
    eligibility_min_credit_score INTEGER,
    eligibility_max_ltv_ratio NUMERIC(18,4),
    eligibility_min_customer_tenure_months INTEGER,
    offer_start_date DATE NOT NULL,
    offer_end_date DATE,
    is_offer_active BOOLEAN NOT NULL,
    collateral_required_flag BOOLEAN NOT NULL,
    max_arrears_tolerance_days INTEGER,
    expected_loss_rate NUMERIC(18,4),
    average_realized_yield NUMERIC(18,4),
    new_business_volume_ytd NUMERIC(18,4),
    outstanding_principal_eop NUMERIC(18,4),
    npl_ratio_percentage NUMERIC(18,4),
    product_roi_percentage NUMERIC(18,4),
    cross_sell_recommendation_score NUMERIC(18,4),
    last_updated_timestamp TIMESTAMPTZ NOT NULL,
    gdpr_personal_data_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_finance_offer PRIMARY KEY (offering_id)
);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_pr
    FOREIGN KEY (product_code) REFERENCES postgresql_global_credit_store.lease_products (product_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_le
    FOREIGN KEY (lessor_legal_entity_id) REFERENCES postgresql_global_credit_store.lessor_legal_entities (lessor_legal_entity_id);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_co
    FOREIGN KEY (country_iso_code) REFERENCES postgresql_global_credit_store.countries (country_iso_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_cu
    FOREIGN KEY (currency_code) REFERENCES postgresql_global_credit_store.currencies (currency_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_in
    FOREIGN KEY (interest_rate_type) REFERENCES postgresql_global_credit_store.interest_rate_types (interest_rate_type);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_am
    FOREIGN KEY (amortization_type) REFERENCES postgresql_global_credit_store.amortization_types (amortization_type);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_ta
    FOREIGN KEY (target_customer_segment) REFERENCES postgresql_global_credit_store.customer_segments (target_customer_segment);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_ch
    FOREIGN KEY (channel_code) REFERENCES postgresql_global_credit_store.channels (channel_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_ri
    FOREIGN KEY (risk_grade) REFERENCES postgresql_global_credit_store.risk_grades (risk_grade);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_re
    FOREIGN KEY (regulatory_product_category) REFERENCES postgresql_global_credit_store.regulatory_product_categories (regulatory_product_category);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_co
    FOREIGN KEY (collateral_type) REFERENCES postgresql_global_credit_store.collateral_types (collateral_type);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_po
    FOREIGN KEY (portfolio_segment_code) REFERENCES postgresql_global_credit_store.portfolio_segments (portfolio_segment_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_pr
    FOREIGN KEY (pricing_strategy_code) REFERENCES postgresql_global_credit_store.pricing_strategies (pricing_strategy_code);

ALTER TABLE postgresql_global_credit_store.credit_finance_offerings ADD CONSTRAINT FK_credit_finance_offerings_da
    FOREIGN KEY (data_source_system) REFERENCES postgresql_global_credit_store.data_source_systems (data_source_system);


-- Dataset: GDS60937
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Customer legal entities (obligors) providing or owning collateral, with associated sector and financ
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customers (
    customer_id BIGSERIAL NOT NULL,
    customer_legal_entity_id VARCHAR(255) NOT NULL,
    sector_industry_code_nace VARCHAR(255),
    financial_statements_available_flag BOOLEAN NOT NULL,
    latest_revenue_amount NUMERIC(18,4),
    latest_ebitda_amount NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);

-- Core collateral assets pledged to commercial finance facilities, including legal, ownership, locatio
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collaterals (
    collateral_pk BIGSERIAL NOT NULL,
    collateral_id VARCHAR(255) NOT NULL,
    facility_id VARCHAR(255) NOT NULL,
    customer_id BIGINT NOT NULL,
    collateral_type_code VARCHAR(255) NOT NULL,
    collateral_description VARCHAR(255),
    jurisdiction_country_code VARCHAR(255) NOT NULL,
    collateral_currency_code VARCHAR(255) NOT NULL,
    collateral_status_code VARCHAR(255) NOT NULL,
    collateral_pledge_start_date DATE NOT NULL,
    collateral_pledge_end_date DATE,
    owner_name VARCHAR(255) NOT NULL,
    owner_lei_code VARCHAR(255),
    owner_tax_identifier VARCHAR(255),
    asset_location_address VARCHAR(255),
    asset_postal_code VARCHAR(255),
    asset_geolocation JSONB,
    charge_rank INTEGER NOT NULL,
    charge_registration_id VARCHAR(255),
    charge_registration_date DATE,
    governing_law_code VARCHAR(255),
    enforcement_status_flag BOOLEAN NOT NULL,
    recovery_strategy_code VARCHAR(255),
    last_recovery_action_date DATE,
    data_source_system_code VARCHAR(255) NOT NULL,
    record_creation_timestamp TIMESTAMPTZ NOT NULL,
    record_last_update_timestamp TIMESTAMPTZ NOT NULL,
    pii_data_minimised_flag BOOLEAN NOT NULL,
    gdpr_processing_legal_basis_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collaterals PRIMARY KEY (collateral_pk)
);

-- Point-in-time valuations and credit risk metrics for collateral assets, used for loan-to-value monit
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.collateral_valuations (
    collateral_valuation_id BIGSERIAL NOT NULL,
    collateral_pk BIGINT NOT NULL,
    valuation_effective_date DATE NOT NULL,
    valuation_timestamp TIMESTAMPTZ NOT NULL,
    market_value_amount NUMERIC(18,4) NOT NULL,
    forced_sale_value_amount NUMERIC(18,4),
    lending_value_amount NUMERIC(18,4),
    haircut_percentage NUMERIC(18,4) NOT NULL,
    loan_to_value_ratio NUMERIC(18,4) NOT NULL,
    exposure_at_default_amount NUMERIC(18,4),
    probability_of_default_pct NUMERIC(18,4),
    loss_given_default_pct NUMERIC(18,4),
    risk_rating_internal VARCHAR(255),
    risk_rating_external_agency VARCHAR(255),
    collateral_status_code_snapshot VARCHAR(255),
    days_past_due INTEGER,
    valuation_methodology_code VARCHAR(255) NOT NULL,
    valuation_firm_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_collateral_valuation PRIMARY KEY (collateral_valuation_id)
);

ALTER TABLE postgresql_global_credit_store.collaterals ADD CONSTRAINT FK_collaterals_customer_id
    FOREIGN KEY (customer_id) REFERENCES postgresql_global_credit_store.customers (customer_id);

ALTER TABLE postgresql_global_credit_store.collateral_valuations ADD CONSTRAINT FK_collateral_valuations_colla
    FOREIGN KEY (collateral_pk) REFERENCES postgresql_global_credit_store.collaterals (collateral_pk);


-- Dataset: GDS68320
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Customers and counterparties involved in lease contracts, including legal identity, residence, regul
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.customers (
    customer_id UUID NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    customer_legal_name VARCHAR(255) NOT NULL,
    customer_birth_date DATE,
    customer_country_of_residence VARCHAR(255) NOT NULL,
    customer_risk_segment VARCHAR(255),
    regulatory_customer_type VARCHAR(255),
    gdpr_consent_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_customers PRIMARY KEY (customer_id)
);

-- Lease contracts linking customers to leased assets, including contractual terms, asset information, 
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.lease_contracts (
    lease_id UUID NOT NULL,
    lease_contract_id VARCHAR(255) NOT NULL,
    customer_id UUID NOT NULL,
    asset_type_code VARCHAR(255) NOT NULL,
    asset_description VARCHAR(255),
    asset_residual_value_amount NUMERIC(18,4),
    lease_start_date DATE NOT NULL,
    lease_end_date DATE NOT NULL,
    interest_rate_effective_annual NUMERIC(18,4) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    country_of_risk VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lease_contracts PRIMARY KEY (lease_id)
);

-- Point-in-time risk and finance measurements for lease exposures, including credit, market, and opera
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.risk_finance_records (
    risk_finance_record_id VARCHAR(255) NOT NULL,
    lease_id UUID NOT NULL,
    days_past_due INTEGER NOT NULL,
    current_outstanding_principal_amount NUMERIC(18,4) NOT NULL,
    credit_rating_internal VARCHAR(255),
    credit_rating_external_agency VARCHAR(255),
    probability_of_default_12m NUMERIC(18,4),
    loss_given_default_percent NUMERIC(18,4),
    exposure_at_default_amount NUMERIC(18,4),
    collateral_coverage_ratio NUMERIC(18,4),
    default_status_flag BOOLEAN NOT NULL,
    default_date DATE,
    impairment_stage_ifrs9 VARCHAR(255) NOT NULL,
    expected_credit_loss_12m_amount NUMERIC(18,4),
    expected_credit_loss_lifetime_amount NUMERIC(18,4),
    write_off_amount NUMERIC(18,4),
    market_risk_sensitivity_irbpv01 NUMERIC(18,4),
    operational_risk_event_flag BOOLEAN NOT NULL,
    operational_risk_event_type VARCHAR(255),
    last_payment_date DATE,
    last_payment_amount NUMERIC(18,4),
    data_record_source_system VARCHAR(255) NOT NULL,
    record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_risk_finance_records PRIMARY KEY (risk_finance_record_id)
);

ALTER TABLE postgresql_global_credit_store.lease_contracts ADD CONSTRAINT FK_lease_contracts_customer_id
    FOREIGN KEY (customer_id) REFERENCES postgresql_global_credit_store.customers (customer_id);

ALTER TABLE postgresql_global_credit_store.risk_finance_records ADD CONSTRAINT FK_risk_finance_records_lease_
    FOREIGN KEY (lease_id) REFERENCES postgresql_global_credit_store.lease_contracts (lease_id);


-- Dataset: GDS70348
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- Commercial and corporate banking customers (obligors) that have one or more credit facilities and as
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.counterparties (
    counterparty_id VARCHAR(255) NOT NULL,
    legal_entity_name VARCHAR(255) NOT NULL,
    customer_type VARCHAR(255) NOT NULL,
    country_of_risk_code VARCHAR(255) NOT NULL,
    industry_sector_code VARCHAR(255),
    eu_gdpr_restricted_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_counterparties PRIMARY KEY (counterparty_id)
);

-- Credit facilities or loan agreements granted to counterparties, capturing relatively stable contract
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.facilities (
    facility_id VARCHAR(255) NOT NULL,
    counterparty_id VARCHAR(255) NOT NULL,
    interest_rate_basis_points INTEGER NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    origination_date DATE NOT NULL,
    contractual_maturity_date DATE NOT NULL,
    limit_amount_eur NUMERIC(18,4) NOT NULL,
    collateral_type_primary VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_facilities PRIMARY KEY (facility_id)
);

-- Point-in-time snapshot records of credit risk exposure at facility level, including ratings, impairm
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_exposure_snapshots (
    credit_exposure_id VARCHAR(255) NOT NULL,
    facility_id VARCHAR(255) NOT NULL,
    counterparty_id VARCHAR(255) NOT NULL,
    internal_rating_grade VARCHAR(255) NOT NULL,
    internal_rating_model_version VARCHAR(255),
    external_rating_agency VARCHAR(255),
    external_rating_grade VARCHAR(255),
    probability_of_default_12m NUMERIC(18,4) NOT NULL,
    probability_of_default_lifetime NUMERIC(18,4),
    loss_given_default_percent NUMERIC(18,4) NOT NULL,
    exposure_at_default_eur NUMERIC(18,4) NOT NULL,
    credit_conversion_factor_percent NUMERIC(18,4),
    outstanding_amount_eur NUMERIC(18,4) NOT NULL,
    undrawn_commitment_eur NUMERIC(18,4),
    days_past_due INTEGER NOT NULL,
    non_performing_loan_flag BOOLEAN NOT NULL,
    default_event_date DATE,
    restructuring_flag BOOLEAN NOT NULL,
    forbearance_flag BOOLEAN NOT NULL,
    collateral_value_eur NUMERIC(18,4),
    collateral_valuation_date DATE,
    guarantee_coverage_percent NUMERIC(18,4),
    covenant_breach_indicators JSONB,
    covenant_breach_details JSONB,
    ifrs9_impairment_stage VARCHAR(255) NOT NULL,
    impairment_provision_eur NUMERIC(18,4) NOT NULL,
    watchlist_flag BOOLEAN NOT NULL,
    credit_risk_portfolio_segment VARCHAR(255) NOT NULL,
    reporting_date DATE NOT NULL,
    snapshot_timestamp_utc TIMESTAMPTZ NOT NULL,
    data_source_system VARCHAR(255) NOT NULL,
    record_active_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_credit_exposure_snap PRIMARY KEY (credit_exposure_id)
);

ALTER TABLE postgresql_global_credit_store.facilities ADD CONSTRAINT FK_facilities_counterparty_id
    FOREIGN KEY (counterparty_id) REFERENCES postgresql_global_credit_store.counterparties (counterparty_id);

ALTER TABLE postgresql_global_credit_store.credit_exposure_snapshots ADD CONSTRAINT FK_credit_exposure_snapshots_c
    FOREIGN KEY (counterparty_id) REFERENCES postgresql_global_credit_store.counterparties (counterparty_id);

ALTER TABLE postgresql_global_credit_store.credit_exposure_snapshots ADD CONSTRAINT FK_credit_exposure_snapshots_f
    FOREIGN KEY (facility_id) REFERENCES postgresql_global_credit_store.facilities (facility_id);


-- Dataset: GDS76668
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This collateral dataset supports leasing operations. Key applications include asset valuation, risk 
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.creditshield_finance_data (
    id INTEGER NOT NULL,
    creditshield_contract_id VARCHAR(255) NOT NULL,
    lessee_customer_id VARCHAR(255) NOT NULL,
    external_reference_number VARCHAR(255),
    asset_collateral_id VARCHAR(255) NOT NULL,
    asset_category_code VARCHAR(255) NOT NULL,
    asset_description VARCHAR(255),
    asset_country_code VARCHAR(255) NOT NULL,
    asset_registered_address JSONB,
    asset_valuation_currency VARCHAR(255) NOT NULL,
    latest_valuation_amount NUMERIC(18,2) NOT NULL,
    valuation_effective_date DATE NOT NULL,
    valuation_method_code VARCHAR(255) NOT NULL,
    loan_outstanding_principal NUMERIC(18,2) NOT NULL,
    loan_to_value_ratio NUMERIC(5,2) NOT NULL,
    collateral_risk_rating VARCHAR(255),
    collateral_risk_rating_date DATE,
    collateral_status_code VARCHAR(255) NOT NULL,
    recovery_strategy_code VARCHAR(255),
    expected_recovery_rate NUMERIC(5,2),
    default_indicator BOOLEAN NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_maturity_date DATE NOT NULL,
    lessee_marketing_consent_flag BOOLEAN NOT NULL,
    lessee_country_of_residence VARCHAR(255) NOT NULL,
    lessee_industry_sector_code VARCHAR(255),
    lessee_credit_score_internal INTEGER,
    last_status_update_timestamp TIMESTAMPTZ NOT NULL,
    collateral_location_coordinates VARCHAR(255),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_creditshield_finance PRIMARY KEY (id)
);


-- Dataset: GDS78526
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This product dataset supports leasing operations. Key applications include product performance analy
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_agreement_dataset (
    id INTEGER NOT NULL,
    agreement_id VARCHAR(255) NOT NULL,
    agreement_external_reference VARCHAR(255),
    agreement_type_code VARCHAR(255) NOT NULL,
    agreement_status_code VARCHAR(255) NOT NULL,
    agreement_version_number INTEGER NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    product_segment VARCHAR(255) NOT NULL,
    portfolio_code VARCHAR(255) NOT NULL,
    booking_entity_code VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    customer_type VARCHAR(255) NOT NULL,
    customer_residency_country VARCHAR(255) NOT NULL,
    customer_industry_code VARCHAR(255),
    credit_rating_internal VARCHAR(255),
    agreement_currency VARCHAR(255) NOT NULL,
    principal_amount NUMERIC(15,2) NOT NULL,
    outstanding_principal_amount NUMERIC(15,2) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    nominal_interest_rate NUMERIC(7,4) NOT NULL,
    effective_interest_rate NUMERIC(7,4),
    origination_date DATE NOT NULL,
    activation_date DATE,
    maturity_date DATE NOT NULL,
    tenor_months INTEGER NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    scheduled_installment_amount NUMERIC(15,2) NOT NULL,
    total_expected_interest_income NUMERIC(17,2),
    total_fee_amount NUMERIC(15,2),
    collateral_type_code VARCHAR(255),
    collateral_estimated_value NUMERIC(15,2),
    loan_to_value_ratio NUMERIC(6,2),
    days_past_due INTEGER NOT NULL,
    default_status_flag BOOLEAN NOT NULL,
    ifrs9_stage_code VARCHAR(255),
    probability_of_default_12m NUMERIC(6,4),
    agreement_channel_code VARCHAR(255) NOT NULL,
    cross_sell_indicator BOOLEAN NOT NULL,
    linked_product_ids JSONB,
    agreement_creation_timestamp TIMESTAMPTZ NOT NULL,
    last_status_update_timestamp TIMESTAMPTZ,
    agreement_geography JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_credit_finance_agree PRIMARY KEY (id)
);


-- Dataset: GDS87132
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This product dataset supports mobility solutions operations. Key applications include product perfor
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_agreement_dataset (
    id INTEGER NOT NULL,
    agreement_id VARCHAR(255) NOT NULL,
    customer_id VARCHAR(255) NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    agreement_status VARCHAR(255) NOT NULL,
    agreement_signed_date DATE NOT NULL,
    agreement_start_date DATE NOT NULL,
    agreement_end_date DATE,
    mobility_asset_type VARCHAR(255) NOT NULL,
    mobility_asset_brand VARCHAR(255),
    mobility_asset_value_amount NUMERIC(15,2) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    principal_amount NUMERIC(15,2) NOT NULL,
    current_outstanding_principal NUMERIC(15,2) NOT NULL,
    annual_percentage_rate NUMERIC(5,2) NOT NULL,
    nominal_interest_rate NUMERIC(5,3) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    tenor_months INTEGER NOT NULL,
    installment_frequency VARCHAR(255) NOT NULL,
    scheduled_installment_amount NUMERIC(15,2) NOT NULL,
    first_disbursement_date DATE,
    disbursement_channel VARCHAR(255) NOT NULL,
    originating_partner_id VARCHAR(255),
    country_of_agreement VARCHAR(255) NOT NULL,
    borrower_residence_country VARCHAR(255),
    customer_age_at_origination INTEGER,
    customer_risk_grade VARCHAR(255),
    loan_to_value_ratio NUMERIC(5,2),
    days_past_due INTEGER NOT NULL,
    non_performing_flag BOOLEAN NOT NULL,
    charge_off_amount NUMERIC(15,2),
    prepayment_flag BOOLEAN NOT NULL,
    total_interest_expected_amount NUMERIC(15,2),
    total_interest_accrued_amount NUMERIC(15,2) NOT NULL,
    origination_channel VARCHAR(255) NOT NULL,
    cross_sell_eligibility_flag BOOLEAN NOT NULL,
    agreement_creation_timestamp TIMESTAMPTZ NOT NULL,
    last_status_update_timestamp TIMESTAMPTZ NOT NULL,
    gdpr_consent_flag BOOLEAN NOT NULL,
    delinquency_bucket VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_credit_finance_agree PRIMARY KEY (id)
);


-- Dataset: GDS88255
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This product dataset supports commercial finance operations. Key applications include product perfor
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_agreement_dataset (
    id INTEGER NOT NULL,
    agreement_id VARCHAR(255) NOT NULL,
    facility_id VARCHAR(255) NOT NULL,
    borrower_customer_id VARCHAR(255) NOT NULL,
    borrower_legal_name VARCHAR(255) NOT NULL,
    agreement_type VARCHAR(255) NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    agreement_status VARCHAR(255) NOT NULL,
    booking_branch_code VARCHAR(255) NOT NULL,
    region_code VARCHAR(255) NOT NULL,
    country_of_risk VARCHAR(255) NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    origination_date DATE NOT NULL,
    effective_date DATE,
    maturity_date DATE NOT NULL,
    original_principal_amount NUMERIC(18,2) NOT NULL,
    current_outstanding_balance NUMERIC(18,2) NOT NULL,
    undrawn_committed_amount NUMERIC(18,2) NOT NULL,
    interest_rate_type VARCHAR(255) NOT NULL,
    base_rate_index VARCHAR(255),
    interest_rate_spread_bps INTEGER,
    all_in_interest_rate NUMERIC(7,4),
    pricing_grid_tier VARCHAR(255),
    collateralized_flag BOOLEAN NOT NULL,
    primary_collateral_type VARCHAR(255),
    loan_to_value_ratio NUMERIC(6,2),
    internal_risk_rating VARCHAR(255),
    external_rating_agency VARCHAR(255),
    probability_of_default_1y NUMERIC(7,5),
    expected_loss_amount NUMERIC(18,2),
    days_past_due INTEGER NOT NULL,
    non_accrual_flag BOOLEAN NOT NULL,
    restructuring_flag BOOLEAN NOT NULL,
    restructuring_date DATE,
    sector_code VARCHAR(255) NOT NULL,
    relationship_manager_id VARCHAR(255),
    cross_sell_score NUMERIC(5,4),
    annualized_interest_income NUMERIC(18,2),
    annualized_fee_income NUMERIC(18,2),
    expected_yield_on_rwa NUMERIC(7,4),
    agreement_source_system VARCHAR(255) NOT NULL,
    last_activity_timestamp TIMESTAMPTZ NOT NULL,
    data_record_timestamp TIMESTAMPTZ NOT NULL,
    risk_rating_history JSONB,
    pricing_grid_structure JSONB,
    gdpr_pii_flag BOOLEAN NOT NULL,
    customer_segment_code VARCHAR(255) NOT NULL,
    covenant_breach_flag BOOLEAN NOT NULL,
    origination_channel VARCHAR(255),
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_credit_finance_agree PRIMARY KEY (id)
);


-- Dataset: GDS88615
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This product dataset supports leasing operations. Key applications include product performance analy
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.credit_finance_offerings_dataset (
    id INTEGER NOT NULL,
    product_id VARCHAR(255) NOT NULL,
    offer_id VARCHAR(255) NOT NULL,
    leasing_institution_id VARCHAR(255) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_type VARCHAR(255) NOT NULL,
    product_family VARCHAR(255),
    country_code VARCHAR(255) NOT NULL,
    region_code VARCHAR(255),
    currency_code VARCHAR(255) NOT NULL,
    lease_term_months INTEGER NOT NULL,
    minimum_finance_amount NUMERIC(15,2) NOT NULL,
    maximum_finance_amount NUMERIC(15,2) NOT NULL,
    standard_interest_rate_annual NUMERIC(5,3) NOT NULL,
    promotional_interest_rate_annual NUMERIC(5,3),
    interest_rate_type VARCHAR(255) NOT NULL,
    repayment_frequency VARCHAR(255) NOT NULL,
    upfront_fee_amount NUMERIC(15,2),
    ongoing_fee_annual_amount NUMERIC(15,2),
    residual_value_percentage NUMERIC(5,2),
    maximum_loan_to_value_ratio NUMERIC(5,2) NOT NULL,
    minimum_customer_credit_score INTEGER,
    eligible_customer_segments JSONB,
    eligibility_criteria_description VARCHAR(255),
    early_settlement_allowed_flag BOOLEAN NOT NULL,
    early_settlement_fee_percentage NUMERIC(5,2),
    balloon_payment_allowed_flag BOOLEAN NOT NULL,
    balloon_payment_percentage NUMERIC(5,2),
    collateral_required_flag BOOLEAN NOT NULL,
    accepted_collateral_types JSONB,
    product_status VARCHAR(255) NOT NULL,
    product_effective_start_date DATE NOT NULL,
    product_effective_end_date DATE,
    last_pricing_update_timestamp TIMESTAMPTZ NOT NULL,
    regulatory_compliance_flags JSONB,
    kyc_required_flag BOOLEAN NOT NULL,
    aml_risk_rating VARCHAR(255),
    base_rate_index VARCHAR(255),
    base_rate_spread_percentage NUMERIC(5,3),
    expected_loss_rate_percentage NUMERIC(6,4),
    projected_yield_percentage NUMERIC(6,3),
    portfolio_allocation_limit_amount NUMERIC(18,2),
    average_approval_time_days NUMERIC(5,2),
    average_default_rate_percentage NUMERIC(6,3),
    cross_sell_recommendation_score NUMERIC(4,3),
    channel_availability JSONB,
    marketing_campaign_id VARCHAR(255),
    gdpr_personal_data_flag BOOLEAN NOT NULL,
    last_modified_timestamp TIMESTAMPTZ NOT NULL,
    data_source_system_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_credit_finance_offer PRIMARY KEY (id)
);


-- Dataset: GDS99152
CREATE SCHEMA IF NOT EXISTS postgresql_global_credit_store;

-- This risk management dataset supports leasing operations. Key applications include data analysis, re
CREATE TABLE IF NOT EXISTS postgresql_global_credit_store.risk_finance_data_set (
    id INTEGER NOT NULL,
    lease_contract_id VARCHAR(255) NOT NULL,
    customer_internal_id VARCHAR(255) NOT NULL,
    customer_segment_code VARCHAR(255),
    country_code VARCHAR(255) NOT NULL,
    booking_entity_code VARCHAR(255) NOT NULL,
    asset_type_code VARCHAR(255) NOT NULL,
    asset_description VARCHAR(255),
    currency_code VARCHAR(255) NOT NULL,
    contract_start_date DATE NOT NULL,
    contract_end_date DATE,
    first_payment_date DATE,
    contract_signed_timestamp TIMESTAMPTZ,
    contract_status_code VARCHAR(255) NOT NULL,
    days_past_due INTEGER NOT NULL,
    current_principal_outstanding NUMERIC(18,2) NOT NULL,
    current_accrued_interest NUMERIC(18,2),
    interest_rate_percent NUMERIC(7,4) NOT NULL,
    interest_rate_type_code VARCHAR(255) NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    original_financed_amount NUMERIC(18,2) NOT NULL,
    residual_value_amount NUMERIC(18,2),
    lease_term_months INTEGER NOT NULL,
    credit_risk_rating_internal VARCHAR(255),
    credit_risk_rating_external VARCHAR(255),
    probability_of_default_12m NUMERIC(7,4),
    loss_given_default_percent NUMERIC(6,3),
    exposure_at_default_amount NUMERIC(18,2),
    expected_credit_loss_12m_amount NUMERIC(18,2),
    expected_credit_loss_lifetime_amount NUMERIC(18,2),
    collateral_type_code VARCHAR(255),
    collateral_valuation_amount NUMERIC(18,2),
    collateral_valuation_date DATE,
    counterparty_industry_code VARCHAR(255),
    country_risk_score NUMERIC(5,2),
    operational_risk_event_flag BOOLEAN NOT NULL,
    operational_risk_event_type VARCHAR(255),
    market_value_of_asset_amount NUMERIC(18,2),
    last_payment_received_date DATE,
    last_payment_amount NUMERIC(18,2),
    non_performing_flag BOOLEAN NOT NULL,
    restructuring_flag BOOLEAN NOT NULL,
    write_off_amount NUMERIC(18,2) NOT NULL,
    impairment_stage_code VARCHAR(255) NOT NULL,
    data_record_last_updated_timestamp TIMESTAMPTZ NOT NULL,
    source_system_code VARCHAR(255) NOT NULL,
    consent_to_use_data_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_risk_finance_data_se PRIMARY KEY (id)
);


