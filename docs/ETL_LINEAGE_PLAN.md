# ETL & Lineage Plan — Realistic Data Pipelines in Fabric

## Vision

Build two real ETL pipelines that extract data from source platforms, transform through bronze → silver → gold layers in Fabric, and produce traceable column-level lineage visible in Purview and OpenMetadata.

---

## Pipeline 1: Customer 360 (Cross-System Customer Integration)

### Business Story

> The CDO wants a single view of every Masreph customer. Customer data is scattered across CRM (PostgreSQL), KYC verification (MongoDB), and legacy finance (Oracle). Each system has different IDs, name formats, and quality levels. The Customer 360 pipeline merges them into one trusted golden record.

### Source Systems

| Source | Platform | Table | What It Contains | Quality |
|---|---|---|---|---|
| CRM Profiles | PostgreSQL | `core_contact_repository.client_personas` | Customer demographics, segment, risk band, relationship dates | 90% |
| CRM Contacts | PostgreSQL | `core_contact_repository.client_contact_preferences` | Email, phone, channel preferences, GDPR consent | 88% |
| KYC Verification | MongoDB | `masreph_redaktasr.docuVerifyFinanceDataset` | Identity verification, document status, screening results | 75% |
| Legacy Finance | Oracle | `FLORIUS_FINANCE_CUSTOMERS_DATA` | Account balances, product holdings, tenure, legacy codes | 65% |

### Why These Sources

- **PostgreSQL**: Modern CRM — clean data, snake_case, proper types. The "trusted" source for names and contact info.
- **MongoDB**: API layer — semi-structured, camelCase, some schema drift. Has KYC data that doesn't exist elsewhere.
- **Oracle**: Legacy ERP — abbreviated UPPERCASE names, placeholder values ("N/A", "???"), worst quality. Has financial history that CRM doesn't have.
- **Cross-system join**: Same customer exists in all three with different IDs (`142` in PG, `cust_142` in Mongo, `00142` in Oracle).

### Bronze Layer (Raw Landing)

Extract as-is from source systems into Fabric Warehouse bronze schema.

| Bronze Table | Source | Extraction | Columns |
|---|---|---|---|
| `bronze.raw_crm_profiles` | PostgreSQL `client_personas` | Full extract, all columns as original types | client_persona_uuid, masreph_client_id, first_name, last_name, country_code, segment, risk_band, date_of_birth, age, gender, employment_status, annual_income_eur, relationship_start_date, ... |
| `bronze.raw_crm_contacts` | PostgreSQL `client_contact_preferences` | Full extract | preferred_contact_channel, email_address, phone, language_preference, marketing_opt_in_email_flag, gdpr_consent_version, ... |
| `bronze.raw_kyc_verification` | MongoDB `docuVerifyFinanceDataset` | Flatten nested JSON, all fields as VARCHAR | customerId, verificationStatus, documentType, screeningResult, riskScore, lastVerifiedDate, ... |
| `bronze.raw_legacy_finance` | Oracle `FLORIUS_FINANCE_CUSTOMERS_DATA` | Full extract, keep Oracle types | CUST_ID, CUST_NM, ACCT_BAL_EUR, PROD_HOLD_CNT, TENURE_YRS, CUST_STAT_CD, LIFECYCLE_STATUS, ... |

**Bronze rules:**
- No transformation
- Add metadata: `_source_system`, `_extracted_at`, `_batch_id`
- Keep original column names and types
- Quality: as-is from source (65-90%)

### Silver Layer (Cleaned & Standardized)

Transform bronze data into clean, typed, standardized tables.

| Silver Table | Source Bronze | Transformations Applied |
|---|---|---|
| `silver.cleaned_crm_profiles` | `bronze.raw_crm_profiles` | Cast types, standardize country codes (all → ISO 3166-1 alpha-2), validate age range (18-120), NULL handling for optional fields, deduplicate on masreph_client_id |
| `silver.cleaned_crm_contacts` | `bronze.raw_crm_contacts` | Validate email format (regex), standardize phone format (+XX XXXXXXXXX), resolve boolean types, hash email for analytics copy |
| `silver.cleaned_kyc` | `bronze.raw_kyc_verification` | Parse dates from strings, normalize verification status (VERIFIED/UNVERIFIED/PENDING/EXPIRED), map MongoDB camelCase to snake_case, extract nested fields |
| `silver.cleaned_legacy_finance` | `bronze.raw_legacy_finance` | Decode Oracle legacy codes (ACTV→active, INACTV→inactive), convert abbreviated column names (CUST_NM→customer_name, ACCT_BAL_EUR→account_balance_eur), replace placeholders (N/A→NULL, ???→NULL, CHANGE_ME→NULL), standardize customer_id format |

**Silver transformation details:**

```sql
-- Example: Country code standardization
CASE
    WHEN country_code = 'NLD' THEN 'NL'    -- Oracle format
    WHEN country_code = 'Netherlands' THEN 'NL'  -- MongoDB format
    WHEN LENGTH(country_code) = 2 THEN country_code  -- Already ISO
    ELSE 'UNKNOWN'
END AS country_code_iso2

-- Example: Email hashing for GDPR
SHA256(LOWER(TRIM(email_address))) AS email_hash,
email_address AS email_raw  -- kept in silver, removed in gold

-- Example: Legacy code decoding
CASE status_code
    WHEN 'ACTV' THEN 'active'
    WHEN 'A' THEN 'active'
    WHEN '1' THEN 'active'
    WHEN 'INACTV' THEN 'inactive'
    WHEN 'I' THEN 'inactive'
    ELSE 'unknown'
END AS status_standardized
```

**Silver rules:**
- Properly typed columns (no more "everything is VARCHAR")
- Standardized codes and formats
- Deduplicated within each source
- Quality rules applied (invalid → NULL with flag)
- Add `_cleaned_at`, `_quality_score`, `_validation_flags`
- Quality: 85-92%

### Gold Layer (Integrated Customer 360)

Merge silver tables into a single customer record.

| Gold Table | Source Silver Tables | Integration Logic |
|---|---|---|
| `gold.customer_360` | All 4 silver tables | Match on customer_id across sources, resolve conflicts, merge attributes |

**Integration logic:**

```sql
-- Customer matching
-- PG: masreph_client_id = 142
-- Mongo: customerId = 'cust_142' → extract 142
-- Oracle: CUST_ID = '00142' → extract 142
-- All map to master_customer_id = 142

-- Conflict resolution rules:
-- Name: PostgreSQL CRM wins (most recently updated)
-- Email: PostgreSQL CRM wins
-- Balance: Oracle wins (source of truth for finance)
-- KYC Status: MongoDB wins (real-time verification)
-- Risk Band: Take the WORST rating across sources (conservative)
-- Country: PostgreSQL wins, fallback to Oracle

-- Gold columns:
master_customer_id,
customer_name,            -- from PG (preferred) or Oracle (fallback)
email_hash,               -- hashed, no raw PII in gold
phone_masked,             -- last 4 digits only
country_code,             -- standardized ISO
customer_segment,         -- from PG CRM
risk_band,                -- worst across sources
kyc_status,               -- from MongoDB
kyc_last_verified,        -- from MongoDB
account_balance_eur,      -- from Oracle
total_products,           -- from Oracle
relationship_start_date,  -- earliest across sources
lifetime_value_eur,       -- calculated
churn_probability,        -- from PG analytics
gdpr_consent_status,      -- from PG CRM
_sources,                 -- JSON: which sources contributed
_last_integrated_at,
_integration_confidence   -- % of fields successfully merged
```

**Gold rules:**
- No raw PII (email hashed, phone masked)
- Conflict resolution documented per column
- Source attribution (`_sources` column)
- Integration confidence score
- Quality: 95%+

### Lineage This Creates

```
PostgreSQL.core_contact_repository.client_personas
    │
    ├── client_persona_uuid ─────→ bronze.raw_crm_profiles.client_persona_uuid ─────→ silver.cleaned_crm_profiles.client_persona_uuid
    ├── masreph_client_id ───────→ bronze.raw_crm_profiles.masreph_client_id ────────→ silver.cleaned_crm_profiles.masreph_client_id ──→ gold.customer_360.master_customer_id
    ├── email_address ───────────→ bronze.raw_crm_contacts.email_address ────────────→ silver.cleaned_crm_contacts.email_hash ─────────→ gold.customer_360.email_hash
    └── country_code ────────────→ bronze.raw_crm_profiles.country_code ─────────────→ silver.cleaned_crm_profiles.country_code_iso2 ──→ gold.customer_360.country_code

MongoDB.masreph_redaktasr.docuVerifyFinanceDataset
    │
    ├── customerId ──────────────→ bronze.raw_kyc_verification.customer_id ──────────→ silver.cleaned_kyc.customer_id ─────────────────→ gold.customer_360.master_customer_id
    └── verificationStatus ──────→ bronze.raw_kyc_verification.verification_status ──→ silver.cleaned_kyc.kyc_status ──────────────────→ gold.customer_360.kyc_status

Oracle.FLORIUS_FINANCE_CUSTOMERS_DATA
    │
    ├── CUST_ID ─────────────────→ bronze.raw_legacy_finance.cust_id ────────────────→ silver.cleaned_legacy_finance.customer_id ───────→ gold.customer_360.master_customer_id
    └── ACCT_BAL_EUR ────────────→ bronze.raw_legacy_finance.acct_bal_eur ───────────→ silver.cleaned_legacy_finance.account_balance_eur → gold.customer_360.account_balance_eur
```

---

## Pipeline 2: Credit Risk Exposure (Analytics Aggregation)

### Business Story

> The CRO needs a daily view of credit risk exposure across the entire portfolio. Transaction data lives in SQL Server (core banking), risk scores are in Snowflake (risk analytics), and contract details are in SQL Server (lending). The pipeline aggregates them into a risk exposure dashboard in Fabric.

### Source Systems

| Source | Platform | Table | What It Contains | Quality |
|---|---|---|---|---|
| Core Transactions | SQL Server | `Masreph_transactfinance.dbo.tblFinanceAccount` | Account balances, product type, status | 78% |
| Client Profiles | SQL Server | `Masreph_transactfinance.dbo.tblCustomer` | Customer info linked to accounts | 80% |
| Loan Contracts | SQL Server | `Masreph_finfluxcredit.dbo.tblLeaseContract` | Contract terms, amounts, dates | 75% |
| Risk Scores | Snowflake | `ACTICO.CREDIT_RISK_DATASET` | Risk ratings, PD, LGD, screening results | 82% |

### Why These Sources

- **SQL Server (two databases)**: Shows lineage WITHIN SQL Server across databases — common in enterprises where core banking has multiple databases.
- **Snowflake**: Shows cross-platform lineage — risk scores calculated in the analytics warehouse feed back into reporting.
- **Different quality levels**: SQL Server has legacy quality issues, Snowflake has stale data (daily batch load).

### Bronze Layer

| Bronze Table | Source | Notes |
|---|---|---|
| `bronze.raw_finance_accounts` | SQL Server `tblFinanceAccount` | Account-level data |
| `bronze.raw_finance_customers` | SQL Server `tblCustomer` | Customer data from core banking |
| `bronze.raw_lease_contracts` | SQL Server `tblLeaseContract` | Contract terms |
| `bronze.raw_risk_scores` | Snowflake `CREDIT_RISK_DATASET` | Risk analytics output |

### Silver Layer

| Silver Table | Transformations |
|---|---|
| `silver.cleaned_accounts` | Standardize status codes, validate amounts (> 0), add currency normalization |
| `silver.cleaned_contracts` | Validate date ranges (start < end), calculate remaining term, flag defaults |
| `silver.cleaned_risk_scores` | Validate PD range (0-1), LGD range (0-1), flag stale scores (> 30 days old) |

**Key transformation — Staleness detection:**
```sql
-- Flag stale risk scores (Snowflake loads daily, sometimes misses)
CASE
    WHEN DATEDIFF(day, score_date, CURRENT_DATE) > 30 THEN 'STALE'
    WHEN DATEDIFF(day, score_date, CURRENT_DATE) > 7 THEN 'AGING'
    ELSE 'FRESH'
END AS data_freshness
```

### Gold Layer

| Gold Table | Integration Logic |
|---|---|
| `gold.credit_risk_exposure` | Join accounts + contracts + risk scores on customer_id, aggregate by product type, region, risk band |

**Gold columns:**
```
report_date,
customer_id,
customer_name,
region,
product_type,
contract_count,
total_exposure_eur,           -- sum of outstanding balances
weighted_avg_pd,              -- weighted by exposure
weighted_avg_lgd,
expected_loss_eur,            -- exposure * PD * LGD
risk_band,
days_past_due_max,
is_default_flag,
data_freshness_score,         -- % of inputs that are FRESH
_sources,
_aggregated_at
```

### Lineage This Creates

```
SQL Server (Masreph_transactfinance)
    tblFinanceAccount.AccountBalance ──→ bronze.raw_finance_accounts ──→ silver.cleaned_accounts ─┐
    tblCustomer.CustomerId ────────────→ bronze.raw_finance_customers ──→ (joined in silver) ─────┤
                                                                                                   ├──→ gold.credit_risk_exposure
SQL Server (Masreph_finfluxcredit)                                                                 │
    tblLeaseContract.ContractAmount ───→ bronze.raw_lease_contracts ──→ silver.cleaned_contracts ──┤
                                                                                                   │
Snowflake (MASREPH_RISK_ANALYTICS)                                                                 │
    ACTICO.CREDIT_RISK_DATASET.PD ─────→ bronze.raw_risk_scores ────→ silver.cleaned_risk_scores ──┘
```

---

## Implementation Plan

### Phase 1: Bronze Extraction (Python scripts)

```
scripts/etl_bronze_customer360.py    — Extract PG + Mongo + Oracle → Fabric bronze
scripts/etl_bronze_risk_exposure.py  — Extract SQL Server + Snowflake → Fabric bronze
```

- Read from source platforms using existing connectors
- Write to Fabric Warehouse `MasrephCorporateBI_WH` bronze schema
- Add metadata columns (`_source_system`, `_extracted_at`, `_batch_id`)

### Phase 2: Silver Transformation (Fabric Notebooks)

```
notebooks/transform_customer360_silver.sql      — Bronze → Silver transformations
notebooks/transform_risk_exposure_silver.sql    — Bronze → Silver transformations
```

- SQL transformations in Fabric Notebooks (auto-lineage in Purview)
- Apply quality rules, standardize codes, hash PII
- Could also use Fabric Dataflows Gen2

### Phase 3: Gold Integration (Fabric Notebooks)

```
notebooks/integrate_customer360_gold.sql        — Silver → Gold cross-source merge
notebooks/integrate_risk_exposure_gold.sql      — Silver → Gold aggregation
```

- Cross-source joins on customer_id
- Conflict resolution logic
- Aggregation and business calculations

### Phase 4: Lineage Verification

- Connect Purview to Fabric → auto-discovers notebook lineage
- Connect OpenMetadata to Fabric → ingestion pipeline discovers tables
- Verify column-level lineage from source to gold
- Create lineage screenshots for demos

---

## Schema Architecture in Fabric

```
MasrephCorporateBI_WH (Warehouse)
│
├── bronze (schema)
│   ├── raw_crm_profiles                -- Pipeline 1
│   ├── raw_crm_contacts                -- Pipeline 1
│   ├── raw_kyc_verification            -- Pipeline 1
│   ├── raw_legacy_finance              -- Pipeline 1
│   ├── raw_finance_accounts            -- Pipeline 2
│   ├── raw_finance_customers           -- Pipeline 2
│   ├── raw_lease_contracts             -- Pipeline 2
│   └── raw_risk_scores                 -- Pipeline 2
│
├── silver (schema)
│   ├── cleaned_crm_profiles            -- Pipeline 1
│   ├── cleaned_crm_contacts            -- Pipeline 1
│   ├── cleaned_kyc                     -- Pipeline 1
│   ├── cleaned_legacy_finance          -- Pipeline 1
│   ├── cleaned_accounts               -- Pipeline 2
│   ├── cleaned_contracts              -- Pipeline 2
│   └── cleaned_risk_scores            -- Pipeline 2
│
└── gold (schema)
    ├── customer_360                    -- Pipeline 1
    └── credit_risk_exposure           -- Pipeline 2
```

---

## What This Enables for Governance Demos

### Lineage Scenarios
1. **End-to-end column lineage**: "Where does `gold.customer_360.email_hash` come from?" → Trace back through silver (hashing) → bronze (raw) → PostgreSQL (source)
2. **Cross-platform lineage**: Data flows from 3 different platforms into one gold table
3. **Impact analysis**: "If Oracle changes CUST_ID format, what breaks?" → Trace forward through bronze → silver → gold
4. **Freshness tracking**: Risk scores in gold show `data_freshness_score` — demonstrating timeliness governance

### Quality Scenarios
5. **Quality improvement**: Run profiling at each layer — bronze 70%, silver 90%, gold 97%
6. **PII tracking**: Email exists as raw in bronze, hashed in silver, hashed in gold — GDPR traceable
7. **Transformation audit**: "How was this value calculated?" → SQL logic in notebooks is versioned

### Data Product Scenarios
8. **Customer 360 as a data product**: Has SLA (daily refresh), owner, consumers, quality contract
9. **Credit Risk Exposure as a data product**: Has SLA (daily by 08:00), consumed by Risk Office

---

## Decision Points

- [ ] Use Fabric Notebooks (SQL) or Dataflows Gen2 for silver/gold transformations?
- [ ] Create separate Fabric Lakehouse for bronze (raw files) vs Warehouse for silver/gold?
- [ ] Also replicate these pipelines in Databricks for comparison?
- [ ] How many customers to flow through (all 500 or subset)?
- [ ] Schedule pipelines for recurring runs (daily refresh simulation)?
