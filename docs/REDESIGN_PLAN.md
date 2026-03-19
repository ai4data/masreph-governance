# Data Generation Redesign Plan v2

## Principle

Scale down, go deep. Quality over quantity. Metadata drives everything.

## What Stays
- **dmp-masreph** catalog: 2,009 datasets, 55,955 data elements (unchanged)
- Not every catalog dataset needs a deployed table (realistic)

## What Changes
- Select ~300 key datasets (not 2,009) for deployment
- ~600-800 tables (not 9,776)
- Shared entity model across all platforms
- 10 planted governance scenarios
- Cloud platforms (Databricks, Fabric, Snowflake): bronze layer only

---

## Selection: 300 Datasets

**By Domain:**
| Domain | Datasets | Why |
|---|---|---|
| Client | ~60 | Most cross-platform entity |
| Product | ~60 | Core business |
| Risk Management | ~50 | Compliance scenarios |
| Collateral | ~30 | Asset tracking |
| IT | ~30 | Digital/API layer |
| Partner | ~30 | Third parties |
| Finance | ~20 | Corporate reporting |
| Employee | ~15 | HR governance |
| Customer | ~5 | Consumer data |

**By Platform:**
| Platform | Datasets | ~Tables | Architecture |
|---|---|---|---|
| SQL Server | ~80 | 150-200 | 5-8 databases (core banking) |
| PostgreSQL | ~50 | 100-130 | 5-6 schemas (CRM, MDM) |
| Snowflake | ~50 | 80-120 | 1 DB, bronze schema only (raw landing) |
| MySQL | ~30 | 50-70 | 4-5 databases (digital) |
| Databricks | ~30 | 60-80 | 1 catalog, bronze schema only (raw landing) |
| Fabric | ~25 | 50-70 | 1 warehouse, bronze schema only (raw landing) |
| Oracle | ~20 | 40-60 | 1 DB, 3-4 schemas (legacy ERP) |
| MongoDB | ~15 | 15-30 | 3-4 databases (API layer) |
| **Total** | **~300** | **~600-800** | |

---

## Cloud Analytics Platforms: Bronze Only

**Databricks:**
```
masreph_datalake.bronze    (raw landing - all tables here)
```
No silver. No gold. Raw data as landed from source systems.

**Fabric:**
```
MasrephCorporateBI_WH.bronze    (raw landing)
```
No star schema. No curated layer. Raw corporate data landing.

**Snowflake:**
```
MASREPH_RISK_ANALYTICS.RAW    (raw landing)
```
No FACT_/DIM_ tables. Raw risk/compliance data as received.

Silver/gold/curated layers are a **separate future project** — and a great demo scenario (showing transformation from raw to governed).

---

## Shared Entity Model

Master entities generated first, then distributed across platforms:

| Entity | Count | Platforms |
|---|---|---|
| Customer | 500 | SQL Server, PostgreSQL, Snowflake, Fabric, MongoDB, Databricks |
| Product | 100 | SQL Server, Oracle, Snowflake, Fabric |
| Contract | 300 | SQL Server, Oracle, PostgreSQL |
| Employee | 50 | Fabric, SQL Server, Databricks |
| Country | 15 | All (with intentional format variations) |
| Currency | 6 | All (consistent) |

Each entity has platform-specific variations:
```
Customer "Jan de Vries":
  SQL Server:  CustomerId='CUST-00142', Name='Jan De Vries'
  PostgreSQL:  customer_id=142, full_name='jan de vries'
  Snowflake:   CUSTOMER_ID='C000142', CUSTOMER_NAME='JAN DE VRIES'
  Oracle:      CUST_ID='00142', CUST_NM='DE VRIES, JAN'
  MongoDB:     customerId:'cust_142', name:{firstName:'Jan', lastName:'de Vries'}
```

---

## 10 Governance Scenarios

| # | Scenario | What Data Must Exist |
|---|---|---|
| 1 | Multi-platform discovery | 600-800 tables across 8 platforms |
| 2 | Cross-system customer search | Customer 142 in 5+ platforms |
| 3 | Data owner lookup | Metadata links datasets to stewards |
| 4 | PII detection | Emails, IBANs, phones across platforms |
| 5 | Quality mismatch | Same balance, different values per platform |
| 6 | Lineage trace | Timestamps showing data flow source→warehouse |
| 7 | Impact analysis | customer_id referenced in 12+ tables |
| 8 | GDPR right to erasure | Customer 142 PII in 5 platforms |
| 9 | Domain governance view | "Client" domain spans 5 platforms |
| 10 | Reference data inconsistency | "NL" vs "NLD" vs "Netherlands" |

---

## Data Quality by Platform

| Platform | Quality | Character |
|---|---|---|
| SQL Server | 72-82% | Legacy placeholders, whitespace, mixed statuses |
| PostgreSQL | 88-94% | Clean, minor encoding/timezone issues |
| MySQL | 85-92% | Web app quality, some gaps |
| Snowflake | 78-86% | Stale data, batch load gaps (bronze = raw) |
| Databricks | 65-78% | Raw landing, schema drift, mixed formats (bronze) |
| Fabric | 75-85% | Raw corporate data, some incomplete (bronze) |
| Oracle | 60-75% | Worst quality, legacy codes, heavy NULLs |
| MongoDB | 70-82% | Schema drift, mixed types, nested inconsistency |

---

## Data Volume

- Reference tables: 15-50 rows
- Entity tables: 200-500 rows (shared entities)
- Transaction tables: 500-1,000 rows
- Total: ~100K-150K rows (manageable)

---

## Implementation Order

1. Select 300 datasets from the 2,009
2. Generate master entities with platform-specific variations
3. Generate DDL for the 300 selected datasets only
4. Deploy DDL to all 8 platforms
5. Generate and load data with shared entities + quality issues
6. Verify the 10 scenarios work
7. Document demo scripts

---

## Decision Points (Need Agreement)

- [ ] 300 dataset selection criteria — agree?
- [ ] Platform architecture (databases/schemas) — agree?
- [ ] Shared entity counts (500 customers, 100 products, etc.) — agree?
- [ ] The 10 scenarios — agree or modify?
- [ ] Oracle: can we create 3-4 users/schemas on Autonomous DB?
- [ ] Bronze-only for Databricks/Fabric/Snowflake — agree?
- [ ] Regenerate DDL for 300 datasets, or reuse subset of existing DDL?
