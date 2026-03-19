# Masreph Enterprise Data — Complete Regeneration Guide

## Purpose

This document explains how to regenerate ALL data across 8 database platforms from scratch. Follow these steps in order. Each step depends on the previous one.

---

## Prerequisites

### Software
- Python 3.11+ (`C:\Users\Hicham\AppData\Local\Programs\Python\Python311\python.exe`)
- Required packages: `psycopg2-binary`, `mysql-connector-python`, `pyodbc`, `snowflake-connector-python`, `oracledb`, `pymongo`, `certifi`, `databricks-sql-connector`, `azure-identity`, `openai`, `python-dotenv`, `tqdm`

### Platform Access
| Platform | Connection | Credentials |
|---|---|---|
| SQL Server | localhost, Windows Auth | ODBC Driver 17 |
| PostgreSQL | aws-1-eu-west-2.pooler.supabase.com:5432 | postgres.rlphlmkddecuptbklqeh / <SUPABASE_PASSWORD> |
| MySQL | localhost:3306 | root / <MYSQL_PASSWORD> |
| Snowflake | ittrelv-xu20591 | hzmarrou / <SNOWFLAKE_PASSWORD> / COMPUTE_WH |
| Oracle | masrephdb_low (wallet) | ADMIN / <ORACLE_PASSWORD> |
| MongoDB | masrephapi.c2lbreb.mongodb.net | hzmarrou / <MONGODB_PASSWORD> |
| Databricks | adb-7405617014831513.13.azuredatabricks.net | /sql/1.0/warehouses/b3bee97b5042372c / <DATABRICKS_TOKEN> |
| Fabric | bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com | Service Principal (see .env) |
| Azure OpenAI | deepmig.cognitiveservices.azure.com | See .env for API key |

### Key Directories
```
C:\Users\Hicham\OneDrive\python\projects\masreph\          ← Main repo
C:\Users\Hicham\OneDrive\python\learning\dm-db\            ← Data marketplace + enhanced JSONs
C:\Users\Hicham\OneDrive\python\learning\dm-db\enhanced-data\  ← 2,009 enhanced JSON files
```

---

## Step-by-Step Regeneration

### Step 1: Generate Master Entities (5 seconds)

**Script:** `scripts/generate_master_entities.py`
**Output:** `config/master_entities.json`

```bash
python scripts/generate_master_entities.py
```

**What it does:**
- Generates 500 customers (350 individuals + 120 legal entities + 30 sole proprietors)
- 100 financial products with codes and interest rates
- 300 contracts linking customers to products
- 50 employees across departments
- 30 branches across 15 countries
- Platform-specific ID/name variations per customer
- 335 planted quality issues (FD violations, domain errors, multi-column issues)

**Output file:** `config/master_entities.json` (~1.7 MB)

**Note:** Run this FIRST. All subsequent data generation depends on this file.

---

### Step 2: Select Datasets (5 seconds)

**Script:** `scripts/select_datasets.py`
**Output:** `config/selected_datasets.json`
**Depends on:** Local PostgreSQL `data_marketplace` database + `config/platform_assignment.json`

```bash
python scripts/select_datasets.py
```

**What it does:**
- Queries all 2,009 datasets from `data_marketplace` database
- Scores each dataset based on governance scenario coverage (customer elements, PII, financial data, risk elements, compliance elements)
- Selects ~328 datasets distributed across 8 platforms
- Groups by source system (= schema/database names)

**Output file:** `config/selected_datasets.json`

**Note:** Only needed if you want to change WHICH datasets are deployed. If reusing the same selection, skip this step.

---

### Step 3: Generate DDL Schemas (25-30 minutes)

**Script:** `scripts/generate_schemas_v2.py`
**Output:** `schemas_v2/{platform}/*.sql` (and `.json` for MongoDB)
**Depends on:** `config/selected_datasets.json`, `config/type_mapping.json`, `config/naming_conventions.json`, enhanced JSON files, Azure OpenAI API

```bash
python scripts/generate_schemas_v2.py
```

**What it does:**
- Reads the 328 selected datasets from enhanced JSON files
- For SQL Server, PostgreSQL, MySQL, Oracle: calls Azure OpenAI to split datasets into normalized tables (AI splitting)
- For Snowflake, Databricks, Fabric: generates 1:1 bronze/raw tables (no splitting)
- For MongoDB: generates document schemas (no splitting)
- Applies platform-specific naming conventions (PascalCase, snake_case, UPPERCASE, abbreviated, camelCase)
- Outputs DDL files grouped by source system

**Output files:** `schemas_v2/{platform}/{source_system}.sql` (or `.json`)

**Cost:** ~190 Azure OpenAI API calls (gpt-5.1 with reasoning_effort=medium)

**Note:** This is the most expensive step (API costs + time). If the DDL files already exist in `schemas_v2/` and you don't need to change table structures, SKIP this step.

---

### Step 4: Deploy DDL to All 8 Platforms (5-10 minutes)

**Script:** `scripts/deploy_all_v2.py`
**Depends on:** `schemas_v2/` DDL files, all platform connections active

```bash
python scripts/deploy_all_v2.py
```

**What it does:**
- Connects to each platform
- Creates databases/schemas per source system
- Executes CREATE TABLE statements from DDL files
- Adds FK constraints where possible
- Platform-specific adaptations:
  - SQL Server: one database per source system, dbo schema
  - PostgreSQL: one schema per source system
  - MySQL: one database per source system
  - Snowflake: one schema per source system in MASREPH_RISK_ANALYTICS database
  - Databricks: one schema per source system in masreph_datalake catalog
  - Fabric: one schema per source system in MasrephCorporateBI_WH warehouse
  - Oracle: all tables in ADMIN schema (free tier limitation)
  - MongoDB: collections created during data insert

**IMPORTANT:** Before running, you may need to:
- Drop existing Masreph databases/schemas on each platform
- Ensure all platforms are running (Snowflake warehouse active, Databricks warehouse active, Fabric warehouse awake)
- Ensure Databricks storage account firewall allows access

**Cleanup commands (if needed):**
```python
# SQL Server
"SELECT name FROM sys.databases WHERE name LIKE 'Masreph_%'" → DROP each

# PostgreSQL
"SELECT schemaname FROM pg_tables WHERE schemaname NOT IN (...) GROUP BY schemaname" → DROP SCHEMA CASCADE

# MySQL
"SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME LIKE 'masreph_%'" → DROP DATABASE

# Snowflake
DROP DATABASE IF EXISTS MASREPH_RISK_ANALYTICS; CREATE DATABASE MASREPH_RISK_ANALYTICS;

# Databricks
SHOW SCHEMAS IN masreph_datalake → DROP SCHEMA CASCADE each

# Fabric
Drop all schemas and tables via INFORMATION_SCHEMA queries

# Oracle
SELECT table_name FROM user_tables → DROP TABLE CASCADE CONSTRAINTS

# MongoDB
client.drop_database(db_name) for each masreph_* database
```

---

### Step 5: Generate Data with Shared Entities (30-60 minutes)

**Script:** `scripts/generate_data_v2.py`
**Depends on:** `config/master_entities.json`, all platforms with DDL deployed

```bash
python scripts/generate_data_v2.py
```

**What it does:**
- Reads master entities (500 customers, 100 products, 300 contracts)
- Connects to each platform and reads actual table structures
- For each table:
  - Matches column names to master entity fields using `classify_column()`
  - Generates rows using master entity data with platform-specific ID/name formats
  - Fills non-entity columns with contextually appropriate generic values
  - Applies `coerce_value()` to match exact database column types
- Row counts per table: 15-50 (reference), 100-300 (entity), 200-500 (customer), 400-800 (transaction)

**Platform order:** SQL Server → MySQL → PostgreSQL → Oracle → MongoDB → Snowflake
**Note:** Databricks and Fabric are NOT included in this script. Run them separately.

**Known issues:**
- Some tables will remain empty due to FK constraint violations
- Oracle may have precision overflow on some numeric columns
- Cloud platforms (Snowflake) are slow due to network latency

---

### Step 6: Fix Empty Tables (30-60 minutes)

**Script:** `scripts/fix_empty_v3.py`
**Depends on:** `config/schema_results_v2.json`, all platforms with initial data loaded

```bash
python scripts/fix_empty_v3.py
```

**What it does:**
- Uses `schema_results_v2.json` to know the exact column metadata (original_element + data_type) for every column
- Reads FK relationships from each database to determine parent-child dependencies
- **Topological sorts** tables so parents are populated before children
- Fetches actual parent IDs and uses them for FK columns
- Generates type-safe values using column precision metadata
- Handles platform-specific type quirks:
  - PostgreSQL: Python `bool` for BOOLEAN columns, `uuid.uuid4()` for UUID columns
  - Snowflake: `PARSE_JSON()` for VARIANT columns
  - Databricks: `MAP()`, `ARRAY()`, `STRUCT()` literals for complex types
  - Oracle: precision-capped NUMBER values

**Platform order:** SQL Server → MySQL → PostgreSQL → Snowflake → Databricks → Fabric

**This is the critical fix script.** The initial `generate_data_v2.py` leaves ~40-50% of tables empty. This script brings it to ~95%+ populated.

---

### Step 7: Map Governance Domains & Collections (30 seconds)

**Script:** `scripts/map_governance.py`
**Depends on:** Local `data_marketplace` database

```bash
python scripts/map_governance.py
```

**What it does:**
- Reads all 2,009 datasets from local `data_marketplace` database
- Maps `data_domain` → governance domain (7 Option C domains)
- Maps `data_subdomain` → governance subdomain
- Maps `business_line` → governance collection
- Maps `business_entity` → governance sub-collection
- Adds 4 new columns to `datasets` table: `governance_domain`, `governance_subdomain`, `governance_collection`, `governance_sub_collection`
- Updates both local PostgreSQL and Supabase (dmp-masreph)
- Exports `config/governance_mapping.json`

---

### Step 8: Audit & Verify (2-5 minutes)

**Script:** `scripts/audit_population_all_platforms.py`
**Output:** `docs/DATA_POPULATION_AUDIT.md`, `config/population_audit.json`

```bash
python scripts/audit_population_all_platforms.py
```

**What it does:**
- Connects to all 8 platforms
- Counts tables and rows per schema/database
- Identifies remaining empty tables
- Produces markdown report and JSON data

---

## Quick Regeneration (if DDL already exists)

If you only need to regenerate DATA (not schemas), run steps 1, 5, 6, 7, 8:

```bash
# 1. Regenerate master entities
python scripts/generate_master_entities.py

# 2. Clean existing data (run cleanup commands from Step 4, but only DELETE/TRUNCATE, not DROP)

# 3. Generate data
python scripts/generate_data_v2.py

# 4. Fix empty tables
python scripts/fix_empty_v3.py

# 5. Map governance
python scripts/map_governance.py

# 6. Audit
python scripts/audit_population_all_platforms.py
```

---

## Full Regeneration (everything from scratch)

Run ALL steps 1-8 in order. Total time: ~2-3 hours (mostly Azure OpenAI calls and cloud platform inserts).

```bash
python scripts/generate_master_entities.py          # Step 1: 5 sec
python scripts/select_datasets.py                   # Step 2: 5 sec
python scripts/generate_schemas_v2.py               # Step 3: 25-30 min
python scripts/deploy_all_v2.py                     # Step 4: 5-10 min
python scripts/generate_data_v2.py                  # Step 5: 30-60 min
python scripts/fix_empty_v3.py                      # Step 6: 30-60 min
python scripts/map_governance.py                    # Step 7: 30 sec
python scripts/audit_population_all_platforms.py     # Step 8: 2-5 min
```

---

## File Dependency Graph

```
enhanced-data/*.json (2,009 files)
       │
       ├── select_datasets.py → config/selected_datasets.json
       │                              │
       │                              ├── generate_schemas_v2.py → schemas_v2/{platform}/*.sql
       │                              │                                    │
       │                              │                                    ├── deploy_all_v2.py → 8 platforms with DDL
       │                              │                                    │
       │                              │                                    └── config/schema_results_v2.json
       │                              │                                              │
       │                              │                                              └── fix_empty_v3.py → fills remaining empty tables
       │                              │
       │                              └── generate_master_entities.py → config/master_entities.json
       │                                                                       │
       │                                                                       └── generate_data_v2.py → data across 8 platforms
       │
       └── map_governance.py → config/governance_mapping.json + DB updates

data_marketplace DB (local PostgreSQL)
       │
       ├── select_datasets.py (reads datasets + elements)
       ├── map_governance.py (reads + updates datasets)
       └── platform_assignment.json (reads assignments)
```

---

## Config Files Reference

| File | Created By | Used By | Purpose |
|---|---|---|---|
| `config/master_entities.json` | generate_master_entities.py | generate_data_v2.py, fix_empty_v3.py | 500 customers, 100 products, 300 contracts |
| `config/selected_datasets.json` | select_datasets.py | generate_schemas_v2.py | 328 datasets selected for deployment |
| `config/platform_assignment.json` | assign_platforms.py | select_datasets.py | All 2,009 datasets → platform mapping |
| `config/schema_results_v2.json` | generate_schemas_v2.py | fix_empty_v3.py | AI-generated table structures (column metadata) |
| `config/type_mapping.json` | manual | generate_schemas_v2.py | Generic → platform-native type mapping |
| `config/naming_conventions.json` | manual | generate_schemas_v2.py | Per-platform naming rules |
| `config/governance_mapping.json` | map_governance.py | Purview/OM integration | 2,009 datasets → domains + collections |
| `config/oracle_wallet/` | Oracle Cloud | deploy_all_v2.py, generate_data_v2.py, fix_empty_v3.py | Oracle connection wallet |

---

## Troubleshooting

### Snowflake: "Connecting to GLOBAL Snowflake domain" hangs
- Check if COMPUTE_WH warehouse is active in Snowflake UI
- Resume it if suspended

### Databricks: "Azure storage request is not authorized"
- Go to Azure Portal → Storage Accounts → masrephdatalake → Networking
- Set to "Enabled from all networks"

### Fabric: "database was not found"
- Check if MasrephCorporateBI_WH warehouse exists in Fabric workspace
- The warehouse may have been deleted — recreate it
- Ensure masreph-fabric-app service principal has Admin role

### Oracle: "ORA-01438: value larger than specified precision"
- The fix_empty_v3.py handles this with precision-aware generation
- If still failing, check column precision with: `SELECT column_name, data_precision, data_scale FROM user_tab_columns`

### MongoDB: SSL handshake error
- Check Network Access in Atlas → ensure 0.0.0.0/0 is whitelisted
- Use certifi: `MongoClient(uri, tls=True, tlsCAFile=certifi.where())`

### PostgreSQL: "server closed the connection unexpectedly"
- Supabase free tier drops idle connections
- The fix script handles this with connection-per-operation pattern
- If persistent, reduce batch sizes

### MySQL: empty tables (table name mismatch)
- Schema_results table names don't match deployed MySQL table names
- MySQL got simple 1:1 tables without AI splitting, so names differ
- Fix: read actual deployed table names and match by similarity, or regenerate DDL for MySQL specifically
