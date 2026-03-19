-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: global_credit_store
-- Generated: 2026-03-18T12:17:47.444818
-- Datasets: 1
-- ============================================

-- Dataset: GDS36652
CREATE SCHEMA IF NOT EXISTS global_credit_store;

-- Lease contracts and their financial, risk, and operational attributes within the CreditFlow data set
CREATE TABLE IF NOT EXISTS global_credit_store.leases (
    lease_id INTEGER NOT NULL,
    lease_contract_id VARCHAR(255) NOT NULL,
    product_id INTEGER NOT NULL,
    lessee_customer_id INTEGER NOT NULL,
    origination_channel_id INTEGER,
    country_id INTEGER NOT NULL,
    currency_id INTEGER NOT NULL,
    origination_date DATE NOT NULL,
    first_disbursement_timestamp TIMESTAMPTZ,
    lease_term_months INTEGER NOT NULL,
    remaining_term_months INTEGER,
    lease_principal_amount NUMERIC(18,4) NOT NULL,
    current_outstanding_principal NUMERIC(18,4) NOT NULL,
    nominal_interest_rate NUMERIC(18,4) NOT NULL,
    effective_interest_rate NUMERIC(18,4),
    payment_frequency_id INTEGER NOT NULL,
    scheduled_payment_amount NUMERIC(18,4) NOT NULL,
    next_payment_due_date DATE,
    days_past_due INTEGER NOT NULL,
    arrears_amount NUMERIC(18,4) NOT NULL,
    lease_status_id INTEGER NOT NULL,
    default_indicator BOOLEAN NOT NULL,
    date_of_default DATE,
    recovery_rate_percentage NUMERIC(18,4),
    write_off_amount NUMERIC(18,4),
    asset_type_id INTEGER NOT NULL,
    asset_market_value NUMERIC(18,4),
    residual_value_guaranteed NUMERIC(18,4),
    portfolio_segment_id INTEGER,
    risk_rating_internal INTEGER,
    probability_of_default_12m NUMERIC(18,4),
    expected_loss_amount_lifetime NUMERIC(18,4),
    interest_income_accrued_month NUMERIC(18,4) NOT NULL,
    fee_income_recognized_month NUMERIC(18,4) NOT NULL,
    early_repayment_indicator BOOLEAN NOT NULL,
    early_repayment_date DATE,
    branch_id INTEGER,
    salesperson_id INTEGER,
    data_record_timestamp TIMESTAMPTZ NOT NULL,
    source_system_id INTEGER NOT NULL,
    data_quality_score NUMERIC(18,4) NOT NULL,
    contract_document_uuid VARCHAR(255),
    masreph_entity_id INTEGER NOT NULL,
    gdpr_personal_data_flag BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_leases PRIMARY KEY (lease_id)
);

-- Reference data for leasing products and their product families.
CREATE TABLE IF NOT EXISTS global_credit_store.products (
    product_id INTEGER NOT NULL,
    product_code VARCHAR(255) NOT NULL,
    product_family VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_products PRIMARY KEY (product_id)
);

-- Customer or corporate entities acting as lessees, including segmentation and cross-sell attributes.
CREATE TABLE IF NOT EXISTS global_credit_store.lessee_customers (
    lessee_customer_id INTEGER NOT NULL,
    lessee_customer_code VARCHAR(255) NOT NULL,
    lessee_segment VARCHAR(255),
    industry_id INTEGER,
    cross_sell_opportunity_score NUMERIC(18,4),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lessee_customers PRIMARY KEY (lessee_customer_id)
);

-- Industry reference data based on NACE-Rev2 classification.
CREATE TABLE IF NOT EXISTS global_credit_store.industries (
    industry_id INTEGER NOT NULL,
    industry_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_industries PRIMARY KEY (industry_id)
);

-- Reference data for lease origination channels such as branch, broker, or digital.
CREATE TABLE IF NOT EXISTS global_credit_store.origination_channels (
    origination_channel_id INTEGER NOT NULL,
    origination_channel_name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_origination_channels PRIMARY KEY (origination_channel_id)
);

-- Reference data for countries using ISO-3166-1 alpha-2 codes.
CREATE TABLE IF NOT EXISTS global_credit_store.countries (
    country_id INTEGER NOT NULL,
    country_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_countries PRIMARY KEY (country_id)
);

-- Reference data for currencies using ISO-4217 codes.
CREATE TABLE IF NOT EXISTS global_credit_store.currencies (
    currency_id INTEGER NOT NULL,
    currency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_currencies PRIMARY KEY (currency_id)
);

-- Reference data for lease payment frequency codes (e.g., monthly, quarterly).
CREATE TABLE IF NOT EXISTS global_credit_store.payment_frequencies (
    payment_frequency_id INTEGER NOT NULL,
    payment_frequency_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_payment_frequencies PRIMARY KEY (payment_frequency_id)
);

-- Reference data for lease lifecycle status codes (e.g., active, defaulted, matured).
CREATE TABLE IF NOT EXISTS global_credit_store.lease_statuses (
    lease_status_id INTEGER NOT NULL,
    lease_status_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_lease_statuses PRIMARY KEY (lease_status_id)
);

-- Reference data for underlying leased asset types.
CREATE TABLE IF NOT EXISTS global_credit_store.asset_types (
    asset_type_id INTEGER NOT NULL,
    asset_type_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_asset_types PRIMARY KEY (asset_type_id)
);

-- Reference data for internal portfolio segmentation codes.
CREATE TABLE IF NOT EXISTS global_credit_store.portfolio_segments (
    portfolio_segment_id INTEGER NOT NULL,
    portfolio_segment_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_portfolio_segments PRIMARY KEY (portfolio_segment_id)
);

-- Reference data for booking branches or units.
CREATE TABLE IF NOT EXISTS global_credit_store.branches (
    branch_id INTEGER NOT NULL,
    branch_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_branches PRIMARY KEY (branch_id)
);

-- Reference data for salespersons or relationship managers originating leases.
CREATE TABLE IF NOT EXISTS global_credit_store.salespersons (
    salesperson_id INTEGER NOT NULL,
    salesperson_code VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_salespersons PRIMARY KEY (salesperson_id)
);

-- Reference data for Masreph legal entities booking lease exposures.
CREATE TABLE IF NOT EXISTS global_credit_store.masreph_entities (
    masreph_entity_id INTEGER NOT NULL,
    masreph_entity_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_masreph_entities PRIMARY KEY (masreph_entity_id)
);

-- Reference data for operational source systems feeding lease data.
CREATE TABLE IF NOT EXISTS global_credit_store.source_systems (
    source_system_id INTEGER NOT NULL,
    source_system_code VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
    ,CONSTRAINT PK_source_systems PRIMARY KEY (source_system_id)
);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_product_id
    FOREIGN KEY (product_id) REFERENCES global_credit_store.products (product_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_lessee_customer_id
    FOREIGN KEY (lessee_customer_id) REFERENCES global_credit_store.lessee_customers (lessee_customer_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_origination_channel_
    FOREIGN KEY (origination_channel_id) REFERENCES global_credit_store.origination_channels (origination_channel_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_country_id
    FOREIGN KEY (country_id) REFERENCES global_credit_store.countries (country_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_currency_id
    FOREIGN KEY (currency_id) REFERENCES global_credit_store.currencies (currency_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_payment_frequency_id
    FOREIGN KEY (payment_frequency_id) REFERENCES global_credit_store.payment_frequencies (payment_frequency_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_lease_status_id
    FOREIGN KEY (lease_status_id) REFERENCES global_credit_store.lease_statuses (lease_status_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_asset_type_id
    FOREIGN KEY (asset_type_id) REFERENCES global_credit_store.asset_types (asset_type_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_portfolio_segment_id
    FOREIGN KEY (portfolio_segment_id) REFERENCES global_credit_store.portfolio_segments (portfolio_segment_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_branch_id
    FOREIGN KEY (branch_id) REFERENCES global_credit_store.branches (branch_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_salesperson_id
    FOREIGN KEY (salesperson_id) REFERENCES global_credit_store.salespersons (salesperson_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_masreph_entity_id
    FOREIGN KEY (masreph_entity_id) REFERENCES global_credit_store.masreph_entities (masreph_entity_id);

ALTER TABLE global_credit_store.leases ADD CONSTRAINT FK_leases_source_system_id
    FOREIGN KEY (source_system_id) REFERENCES global_credit_store.source_systems (source_system_id);

ALTER TABLE global_credit_store.lessee_customers ADD CONSTRAINT FK_lessee_customers_industry_i
    FOREIGN KEY (industry_id) REFERENCES global_credit_store.industries (industry_id);


