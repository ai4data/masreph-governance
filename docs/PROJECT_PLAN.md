# Masreph — Simulated Multi-Platform Data Landscape

## Vision

Build a realistic, pre-built simulated enterprise data environment distributed across 8 database platforms. The goal is to create a convincing enterprise data landscape that can be used to demonstrate data governance capabilities (Purview, OpenMetadata), support training, and potentially be commercialized.

**The fictional company:** **Masreph** — a global financial services / leasing conglomerate headquartered in the Netherlands, with operations across Europe, Asia-Pacific, and the Americas.

---

## What We Already Have (dm-db repo)

- **2,009 datasets** with rich metadata (domains, subdomains, business lines, source systems, owners, classifications, maturity, lifecycle, etc.)
- **55,955 data elements** with column-level detail (name, business name, description, data type, format, nullable, sample values)
- All stored in both local PostgreSQL and Supabase
- Enhanced JSON files for each dataset in `enhanced-data/`
- The data marketplace catalog schema (datasets, data_elements, owners, tags, use_cases, ratings, metrics, etc.)

---

## Architecture: The 8-Platform Enterprise

### Platform Distribution

| Platform | ~Datasets | % | Role in Masreph | Hosting |
|---|---|---|---|---|
| **SQL Server** | 550 | 27% | Legacy core banking backbone (15+ years). Transactions, payments, lending, leasing. | Local (Developer Edition, free) |
| **PostgreSQL** | 370 | 18% | Modern applications. CRM, customer management, MDM. | Supabase (free tier) |
| **MySQL** | 130 | 6% | Digital channels. Web portals, mobile backends, email, internal tools. | Local (Docker) or PlanetScale free |
| **Snowflake** | 300 | 15% | Risk & compliance analytics. Team-chosen 3 years ago. | Free 30-day trial |
| **Databricks** | 230 | 11% | Data lakehouse. ML models, advanced analytics, archived data. | Community Edition (free) |
| **Microsoft Fabric** | 200 | 10% | Corporate analytics. IT-mandated enterprise platform. Finance reporting, HR, BI. | Free 60-day trial |
| **Oracle** | 120 | 6% | Legacy ERP. Acquired subsidiaries, insurance, lease contracts. | Oracle XE (free) or Cloud Free Tier |
| **MongoDB** | 110 | 5% | API logs, events, semi-structured data. Digital services layer. | Atlas M0 (free forever) |

### The Enterprise Story

> Masreph started on **Oracle** — the original ERP for lease contract management and insurance, still running for some subsidiaries. Ten years ago, they migrated core banking to **SQL Server** — transactions, payments, credit. That's still the backbone today.
>
> Five years ago, the digital transformation started: new customer apps on **PostgreSQL**, web/mobile channels on **MySQL**. The risk team independently adopted **Snowflake** for compliance analytics. Last year, data engineering brought in **Databricks** for the data lake and ML models.
>
> Then corporate IT mandated **Microsoft Fabric** as the enterprise analytics standard — creating the classic tension with the Snowflake team. Meanwhile, the API and event-driven architecture quietly grew a **MongoDB** layer underneath.
>
> Now the CDO wants to govern all of it. Hence the data marketplace.

---

## Implementation Plan

### Phase 1: Foundation & Assignment (Day 1)

**Goal:** Assign each of the 2,009 datasets to a target platform and prepare the mapping.

#### Step 1.1 — Define Assignment Rules
Create a Python script that assigns each dataset to a platform based on:
- `source_sys_name` — primary driver (e.g., "RealEstate SQL server" → SQL Server)
- `data_domain` — secondary driver (e.g., Risk management → Snowflake)
- `business_line` — tertiary driver (e.g., Innovation & Technology → MySQL)
- `data_lifecycle` — Retired datasets → Databricks (data lake archive)
- `maturity` — Enterprise-controlled → SQL Server (core systems)

Rules should be deterministic and reproducible.

#### Step 1.2 — Create the Assignment Map
Output: A JSON/CSV file mapping each `dataset_id` → `target_platform`.
Store this in the database as a new column or table.

#### Step 1.3 — Validate Distribution
Verify the distribution percentages match the plan.
Check that no platform has orphaned domains (e.g., all Client data in one place).
Ensure cross-platform overlap exists (same domain appears on multiple platforms).

### Phase 2: Schema Generation (Day 1-2)

**Goal:** Convert dataset metadata + data elements into actual DDL (CREATE TABLE statements) for each platform.

#### Step 2.1 — Data Type Mapping
Create a mapping from our generic data types to each platform's native types:

| Generic | SQL Server | PostgreSQL | MySQL | Snowflake | Databricks | Oracle | MongoDB |
|---|---|---|---|---|---|---|---|
| string | NVARCHAR | VARCHAR | VARCHAR | VARCHAR | STRING | VARCHAR2 | String |
| integer | INT | INTEGER | INT | NUMBER | INT | NUMBER | Number |
| decimal | DECIMAL | NUMERIC | DECIMAL | NUMBER | DECIMAL | NUMBER | Number |
| boolean | BIT | BOOLEAN | TINYINT(1) | BOOLEAN | BOOLEAN | NUMBER(1) | Boolean |
| date | DATE | DATE | DATE | DATE | DATE | DATE | Date |
| timestamp | DATETIME2 | TIMESTAMP | DATETIME | TIMESTAMP_NTZ | TIMESTAMP | TIMESTAMP | Date |
| array | NVARCHAR(MAX) | JSONB | JSON | VARIANT | ARRAY | CLOB | Array |
| object | NVARCHAR(MAX) | JSONB | JSON | VARIANT | MAP | CLOB | Object |

#### Step 2.2 — Table Splitting (AI-Powered)
For datasets with many data elements (>15), use Azure OpenAI to decide if the dataset should be split into multiple tables:
- Input: dataset name, description, domain, all data elements
- Output: grouping of elements into logical tables with PKs and FKs
- Simpler datasets (<=15 elements): 1 dataset = 1 table

#### Step 2.3 — Schema Naming Conventions
Each platform should have its own naming style to feel realistic:
- **SQL Server:** PascalCase schemas, mixed naming (`dbo.CustomerTransactions`, `finance.tblPaymentHistory`)
- **PostgreSQL:** snake_case everything (`public.customer_insights`, `crm.contact_details`)
- **MySQL:** lowercase with underscores, no schemas (`customer_profiles`, `web_sessions`)
- **Snowflake:** UPPERCASE everything (`RAW.SANCTION_SCREENING`, `ANALYTICS.RISK_SCORES`)
- **Databricks:** snake_case catalog.schema.table (`bronze.raw_events`, `gold.customer_360`)
- **Oracle:** UPPERCASE, short names, legacy style (`MASREPH.CUST_MSTR`, `LEASE.CNTRCT_DTL`)
- **MongoDB:** camelCase collections (`customerProfiles`, `transactionEvents`)
- **Fabric:** PascalCase lakehouse tables (`FinanceReporting.EmployeeMetrics`)

#### Step 2.4 — Generate DDL Scripts
Output per platform:
- `sql-server/schemas/*.sql`
- `postgresql/schemas/*.sql`
- `mysql/schemas/*.sql`
- `snowflake/schemas/*.sql`
- `databricks/schemas/*.sql`
- `fabric/schemas/*.sql`
- `oracle/schemas/*.sql`
- `mongodb/collections/*.json` (JSON Schema validators)

### Phase 3: Cross-Platform Relationships (Day 2)

**Goal:** Create realistic cross-system entity references.

#### Step 3.1 — Identify Shared Entities
Use AI to identify entities that appear across platforms:
- `customer_id` in SQL Server, PostgreSQL, Snowflake (different column names)
- `product_code` in Oracle, SQL Server, Fabric
- `employee_id` in SQL Server, Fabric, Databricks
- etc.

#### Step 3.2 — Create Entity Mapping Document
A reference document showing how the same real-world entity is represented differently across platforms. This is gold for lineage demos.

#### Step 3.3 — Ensure Referential Consistency
When we generate sample data, the same customer that exists in SQL Server must also appear in Snowflake — with the same ID but potentially different attributes (stale data, format differences).

### Phase 4: Sample Data Generation (Day 2-3)

**Goal:** Populate tables with realistic, internally consistent sample data.

#### Step 4.1 — Data Volume Strategy
- Reference/lookup tables: 10-50 rows
- Transaction/fact tables: 500-2,000 rows
- Dimension tables: 100-500 rows
- Log/event tables (MongoDB): 1,000-5,000 documents
- Total estimated: ~200K-500K rows across all platforms

#### Step 4.2 — Seed Data from Sample Values
Each data element already has `sampleValues`. Use these as seeds:
- Expand 3 sample values into N realistic rows using Faker + AI
- Maintain internal consistency (FKs resolve, dates are chronological, amounts add up)

#### Step 4.3 — Introduce Realistic Imperfections
- Some NULL values where `nullable: true`
- Slightly different date formats between platforms
- Stale data in the warehouse (1 day behind source)
- A few duplicate records in legacy tables
- Inconsistent reference data between systems (country codes differ)

#### Step 4.4 — Generate INSERT/COPY Scripts
- SQL INSERT statements per platform
- CSV files for bulk loading (Snowflake COPY, Databricks)
- JSON documents for MongoDB

### Phase 5: Platform Deployment (Day 3-4)

**Goal:** Deploy schemas and data to actual database instances.

#### Step 5.1 — Set Up Platforms
| Platform | Setup |
|---|---|
| SQL Server | Install Developer Edition locally (or use existing) |
| PostgreSQL | Already on Supabase |
| MySQL | Docker container locally |
| Snowflake | Create free trial account |
| Databricks | Community Edition signup |
| Fabric | Free trial via Microsoft account |
| Oracle | Oracle XE locally or Cloud Free Tier |
| MongoDB | Atlas M0 cluster (free) |

#### Step 5.2 — Deploy Schemas
Run DDL scripts against each platform. Verify table creation.

#### Step 5.3 — Load Sample Data
Bulk load data into each platform. Verify row counts.

#### Step 5.4 — Validate
- Query each platform independently
- Verify cross-platform entity references
- Spot-check data quality (intentional imperfections present)

### Phase 6: Governance Tool Integration (Day 4-5)

**Goal:** Connect Purview and OpenMetadata to the enterprise.

#### Step 6.1 — OpenMetadata Setup
- Deploy OpenMetadata (Docker)
- Configure ingestion connectors for all 8 platforms
- Run discovery scans
- Verify all 2,009 datasets discovered

#### Step 6.2 — Purview Setup
- Configure in Azure portal
- Register all 8 data sources
- Run scans
- Set up collections matching the organizational structure

#### Step 6.3 — Configure Governance
- Define domains (Product, Client, Risk Management, etc.)
- Set up RBAC (stewards per domain, regional access)
- Create data quality rules
- Configure classification (auto-detect PII)
- Build lineage views
- Set up data policies (access, lifecycle, compliance)

#### Step 6.4 — Side-by-Side Comparison
Document capabilities of each tool against this realistic enterprise.

---

## Repo Structure

```
masreph/
├── docs/
│   ├── PROJECT_PLAN.md              # This file
│   ├── ENTERPRISE_STORY.md          # The Masreph company narrative
│   └── ENTITY_MAPPING.md            # Cross-platform entity references
├── config/
│   ├── platform_assignment.json     # Dataset → platform mapping
│   ├── type_mapping.json            # Generic → platform-specific type mapping
│   └── naming_conventions.json      # Per-platform naming rules
├── scripts/
│   ├── assign_platforms.py          # Step 1: assign datasets to platforms
│   ├── generate_schemas.py          # Step 2: generate DDL per platform
│   ├── generate_sample_data.py      # Step 4: generate INSERT/CSV/JSON
│   └── deploy.py                    # Step 5: deploy to platforms
├── schemas/
│   ├── sql-server/
│   ├── postgresql/
│   ├── mysql/
│   ├── snowflake/
│   ├── databricks/
│   ├── fabric/
│   ├── oracle/
│   └── mongodb/
├── data/
│   ├── sql-server/
│   ├── postgresql/
│   ├── mysql/
│   ├── snowflake/
│   ├── databricks/
│   ├── fabric/
│   ├── oracle/
│   └── mongodb/
├── governance/
│   ├── openmetadata/
│   │   └── ingestion_configs/
│   └── purview/
│       └── scan_configs/
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

---

## Tomorrow's Agenda (Day 1)

1. **Review and finalize this plan** — adjust anything before we start
2. **Set up repo structure** — create folders, .gitignore, requirements.txt
3. **Build the assignment script** — map 2,009 datasets to 8 platforms
4. **Create type mapping config** — generic types → platform-native types
5. **Start schema generation** — begin with SQL Server (largest, ~550 datasets) as the pilot
6. **Test with one platform** — deploy a handful of SQL Server schemas to validate the approach

---

## Key Dependencies

- Access to `dm-db` repo (enhanced JSON files + Supabase connection)
- Azure OpenAI API (for table splitting and cross-platform relationship inference)
- Platform accounts (can be set up incrementally — start with what's available)

---

## Success Criteria

- All 2,009 datasets deployed as actual tables across 8 platforms
- ~200K-500K rows of realistic, internally consistent sample data
- Cross-platform entity references work (same customer in multiple systems)
- OpenMetadata discovers and catalogs everything
- Purview discovers and catalogs everything
- At least 3 governance scenarios fully demoed (RBAC, data quality, lineage)
