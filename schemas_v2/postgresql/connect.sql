-- ============================================
-- Platform: POSTGRESQL
-- Schema/Source: connect
-- Generated: 2026-03-18T12:17:47.441813
-- Datasets: 1
-- ============================================

-- Dataset: GDS33045
CREATE SCHEMA IF NOT EXISTS connect;

-- Employee master data used to associate individuals with finance learning enrollments and related att
CREATE TABLE IF NOT EXISTS connect.employees (
    employee_global_id VARCHAR(255) NOT NULL,
    employee_id VARCHAR(255) NOT NULL,
    employee_department_code VARCHAR(255),
    employee_region_code VARCHAR(255),
    role_family_code VARCHAR(255),
    job_role_title VARCHAR(255),
    gdpr_consent_flag BOOLEAN,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_employees PRIMARY KEY (employee_global_id)
);

-- Catalog of internal and external learning providers for finance learning resources.
CREATE TABLE IF NOT EXISTS connect.learning_providers (
    id INTEGER NOT NULL,
    learning_provider_name VARCHAR(255),
    learning_provider_type VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_learning_providers PRIMARY KEY (id)
);

-- Structured learning paths or curricula grouping finance learning resources.
CREATE TABLE IF NOT EXISTS connect.learning_paths (
    id INTEGER NOT NULL,
    learning_path_id VARCHAR(255),
    learning_path_name VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_learning_paths PRIMARY KEY (id)
);

-- Finance learning resource definitions including content, modality, risk and product coverage, and qu
CREATE TABLE IF NOT EXISTS connect.learning_resources (
    learning_resource_id VARCHAR(255) NOT NULL,
    learning_resource_title VARCHAR(255) NOT NULL,
    learning_resource_type VARCHAR(255) NOT NULL,
    learning_resource_level VARCHAR(255),
    learning_resource_language_code VARCHAR(255) NOT NULL,
    learning_provider_id INTEGER,
    delivery_mode VARCHAR(255),
    estimated_completion_hours NUMERIC(18,4),
    cpe_credit_hours NUMERIC(18,4),
    regulatory_requirement_flag BOOLEAN NOT NULL,
    regulatory_body_name VARCHAR(255),
    risk_domain VARCHAR(255),
    product_domain VARCHAR(255),
    skill_tags JSONB,
    learning_objectives VARCHAR(255),
    prerequisite_resource_ids JSONB,
    assessment_required_flag BOOLEAN NOT NULL,
    content_last_reviewed_date DATE,
    content_version_number INTEGER NOT NULL,
    content_url VARCHAR(255),
    avg_satisfaction_rating NUMERIC(18,4),
    participant_feedback_count INTEGER,
    localization_available_languages JSONB,
    learning_path_ref_id INTEGER,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_learning_resources PRIMARY KEY (learning_resource_id)
);

-- Catalog entries tying learning resources to catalog lifecycle, activation status, and data lineage.
CREATE TABLE IF NOT EXISTS connect.finance_learning_catalog_entries (
    catalog_entry_id VARCHAR(255) NOT NULL,
    learning_resource_id_fk VARCHAR(255) NOT NULL,
    active_flag BOOLEAN NOT NULL,
    record_effective_date DATE NOT NULL,
    record_expiry_date DATE,
    created_timestamp TIMESTAMPTZ NOT NULL,
    updated_timestamp TIMESTAMPTZ,
    data_lineage_source_system JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_learning_cat PRIMARY KEY (catalog_entry_id)
);

-- Employee enrollments into finance learning catalog entries, including progress, completion outcomes,
CREATE TABLE IF NOT EXISTS connect.finance_learning_enrollments (
    enrollment_id VARCHAR(255) NOT NULL,
    catalog_entry_id_fk VARCHAR(255) NOT NULL,
    employee_global_id_fk VARCHAR(255) NOT NULL,
    enrollment_status VARCHAR(255) NOT NULL,
    enrollment_date DATE NOT NULL,
    completion_date DATE,
    completion_status VARCHAR(255) NOT NULL,
    completion_score_percentage NUMERIC(18,4),
    assessment_attempts_count INTEGER,
    last_assessment_date DATE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ
    ,CONSTRAINT PK_finance_learning_enr PRIMARY KEY (enrollment_id)
);

ALTER TABLE connect.learning_resources ADD CONSTRAINT FK_learning_resources_learning
    FOREIGN KEY (learning_provider_id) REFERENCES connect.learning_providers (id);

ALTER TABLE connect.learning_resources ADD CONSTRAINT FK_learning_resources_learning
    FOREIGN KEY (learning_path_ref_id) REFERENCES connect.learning_paths (id);

ALTER TABLE connect.finance_learning_catalog_entries ADD CONSTRAINT FK_finance_learning_catalog_en
    FOREIGN KEY (learning_resource_id_fk) REFERENCES connect.learning_resources (learning_resource_id);

ALTER TABLE connect.finance_learning_enrollments ADD CONSTRAINT FK_finance_learning_enrollment
    FOREIGN KEY (catalog_entry_id_fk) REFERENCES connect.finance_learning_catalog_entries (catalog_entry_id);

ALTER TABLE connect.finance_learning_enrollments ADD CONSTRAINT FK_finance_learning_enrollment
    FOREIGN KEY (employee_global_id_fk) REFERENCES connect.employees (employee_global_id);


