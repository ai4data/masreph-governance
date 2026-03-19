# Masreph — Enterprise Data Governance
## From Data Chaos to Data Confidence

---

## Slide 1: The Company

### Masreph Financial Services Group

**Founded:** 1987 | **HQ:** Netherlands | **Employees:** 8,000+

A global financial services and leasing conglomerate serving clients across **Europe, Asia-Pacific, and the Americas**.

**Five business lines:**
- Leasing (600 datasets)
- Commercial Finance (502 datasets)
- Mobility Solutions (289 datasets)
- Consumer Finance (255 datasets)
- Innovation & Technology (223 datasets)

**Serving:** 500+ corporate clients, thousands of individual customers, operating in 15 countries.

---

## Slide 2: The Challenge

### 30 Years of Growth = Data Everywhere

Through organic growth, acquisitions, and digital transformation, Masreph accumulated:

| What | How Much |
|---|---|
| Database platforms | **8** (SQL Server, PostgreSQL, MySQL, Snowflake, Databricks, Fabric, Oracle, MongoDB) |
| Known datasets | **2,009** |
| Data elements (columns) | **55,955** |
| Source systems | **200+** |
| Data domains | **9** |
| Data owners | **100+** |

> *"We know our data exists. We don't know where it all is, who owns it, whether it's correct, or if it's compliant."*
>
> — CDO, Masreph Group

---

## Slide 3: The Data Landscape

### 8 Platforms, One Enterprise

```
┌─────────────────────────────────────────────────────┐
│                  MASREPH DATA LANDSCAPE              │
│                                                      │
│  SQL Server ─── Core Banking (15+ years, legacy)     │
│  Oracle ─────── Legacy ERP (20+ years, contracts)    │
│  PostgreSQL ─── Modern CRM & Customer Management     │
│  MySQL ──────── Digital Channels & Web Apps           │
│  Snowflake ──── Risk & Compliance Analytics          │
│  Databricks ─── Data Lake & ML Models                │
│  Fabric ─────── Corporate BI & Reporting             │
│  MongoDB ────── API Layer & Event Streams            │
│                                                      │
│  Same customer "Jan de Vries" exists in 5+ systems   │
│  with 5 different ID formats and name spellings      │
└─────────────────────────────────────────────────────┘
```

Each platform grew independently. Different teams, different conventions, different quality standards. **No single view of the truth.**

---

## Slide 4: The Customer Problem

### One Customer, Five Systems

| Platform | Customer ID | Name | Email |
|---|---|---|---|
| SQL Server | CUST-00042 | Jan De Vries | jan.devries@gmail.com |
| PostgreSQL | 42 | jan de vries | jan.devries@gmail.com |
| Snowflake | C000042 | JAN DE VRIES | jan.devries@gmail.com |
| Oracle | 00042 | DE VRIES, JAN | jan.devries@gmail.com |
| MongoDB | cust_42 | {firstName: "Jan"} | jan.devries@gmail.com |

**Five IDs. Three name formats. One person.**

When the GDPR officer asks *"Where is all data for customer Jan de Vries?"* — nobody can answer in under a week.

---

## Slide 5: The Quality Problem

### Data Quality Varies by Platform Age

| Platform | Age | Quality Score | Typical Issues |
|---|---|---|---|
| Oracle | 20+ years | 60-75% | Legacy codes, placeholder values, heavy NULLs |
| SQL Server | 15+ years | 72-82% | Inconsistent statuses, trailing whitespace |
| Snowflake | 2 years | 78-86% | Stale data, batch load gaps |
| PostgreSQL | 5 years | 88-94% | Minor encoding issues |
| Databricks | 1 year | 65-78% | Schema drift, mixed formats (raw landing) |

**335 data quality issues** discovered across the enterprise:
- 34 functional dependency violations (same ID, different name)
- 28 pattern violations (malformed IBANs, phone numbers)
- 16 multi-column errors (IBAN country doesn't match customer country)
- 9 duplicate records
- 19 orphaned references
- And 229 more...

---

## Slide 6: What the CDO Needs

### Five Questions That Keep the CDO Awake

1. **"Where is our customer data?"** → It's in 5+ platforms. Which is the source of truth?

2. **"Are we GDPR compliant?"** → PII is scattered across 8 platforms. Some classified, some not.

3. **"What's our data quality?"** → Oracle is 65%. PostgreSQL is 92%. Nobody sees the full picture.

4. **"What breaks if we change this column?"** → Changing `customer_id` format affects 12+ downstream tables.

5. **"Who owns this data?"** → 100+ data owners across 9 domains. 30% of terms have no steward assigned.

---

## Slide 7: The Governance Vision

### From Chaos to Confidence: 4 Layers

```
Layer 4: Domains & Collections    ← WHO owns and accesses
Layer 3: Data Products & Mesh     ← HOW data is consumed
Layer 2: Business Glossary        ← WHAT data means
Layer 1: Physical Data & Catalog  ← WHERE data lives
```

Each layer builds on the one below. Together, they answer every governance question.

---

## Slide 8: Layer 1 — The Data Catalog

### Every Asset, Every Platform, One View

**2,009 datasets** cataloged across 8 platforms with:
- Full column-level metadata (55,955 data elements)
- Business descriptions and sample values
- Quality scores and completeness metrics
- Owner and steward assignments
- Classification labels (PII, Confidential, Internal, Public)
- Lifecycle status (Active, Retired, Pending)

**328 datasets** deployed as physical tables — queryable, measurable, governed.

**1,681 datasets** cataloged as metadata — documented, owned, ready for materialization.

---

## Slide 9: Layer 2 — The Business Glossary

### Speaking the Same Language

**100+ business terms** organized by domain:

```
Customer Management:
  ├── Customer (synonyms: Client, Counterparty, Borrower)
  ├── KYC Status → linked to Compliance policies
  ├── Customer Segment → mass_market, affluent, HNW, SME
  └── Churn Risk → KPI: formula links to physical columns

Products & Contracts:
  ├── Financial Product → Lease → Auto Lease, Equipment Lease
  ├── Interest Rate → different definition per domain
  └── Contract Status → varies by source system

Risk & Compliance:
  ├── Default → definition changed from 90-day to 60-day in 2024
  ├── PD, LGD, EAD → KPIs with calculation formulas
  └── PEP → regulatory term linked to screening systems
```

**Why it matters:** "Revenue" means different things in Leasing vs Consumer Finance. Without a glossary, reports disagree and nobody knows which is right.

---

## Slide 10: Layer 3 — Data Products

### Data as a Product with SLAs

| Data Product | Domain | Source Systems | SLA | Consumers |
|---|---|---|---|---|
| Customer 360 | Customer Mgmt | PG + SQL Server + Snowflake | Daily by 06:00 | Marketing, Risk, Sales |
| Credit Risk Score | Risk & Compliance | Snowflake + SQL Server | Real-time | Lending, Compliance |
| Product Catalog | Products | SQL Server + Oracle | On change | All business lines |
| Leasing Portfolio | Products | SQL Server + Oracle + Snowflake | Daily by 08:00 | Finance, Risk |
| KYC Screening | Risk & Compliance | Snowflake + MongoDB | Real-time | Compliance, Onboarding |
| Employee Directory | People & Org | Fabric + SQL Server | Weekly | HR, Management |

Each product has:
- A **clear owner** accountable for quality
- **Defined SLAs** that can be monitored
- **Data contracts** between producers and consumers
- **Lifecycle management** (draft → active → deprecated → retired)

---

## Slide 11: Layer 4 — Domains & Collections

### Business Ownership Meets Access Control

**7 Governance Domains** (what the data is about):

| Domain | Datasets | Owner |
|---|---|---|
| Products & Contracts | 614 | Head of Product |
| Customer Management | 466 | Head of CRM |
| Risk & Compliance | 388 | Chief Risk Officer |
| Collateral & Assets | 170 | Head of Collateral Mgmt |
| People & Organization | 165 | CHRO |
| Technology & Data | 149 | CTO |
| Finance & Reporting | 57 | CFO |

**10 Collections** (who can access what):

| Collection | Datasets | Access |
|---|---|---|
| Leasing BL | 600 | Leasing team: full access |
| Commercial Finance BL | 502 | Commercial team: full access |
| Consumer Finance BL | 255 | Consumer team: full access |
| Corporate / Risk Office | 39 | Risk analysts: read access to risk data |
| Corporate / Finance Office | 80 | Finance controllers: reporting data |

**The principle:** Domains organize by business topic. Collections control who sees what. A dataset belongs to one domain AND one collection.

---

## Slide 12: The Customer Types

### Not Just People — Entities Too

Masreph serves three types of customers:

| Type | Count | Key Attributes | Products |
|---|---|---|---|
| **Individuals** | 350 | Name, DOB, gender, IBAN, income | Auto lease, mortgage, personal loan, credit card |
| **Legal Entities** | 120 | Company name, LEI, KVK, industry, UBOs | Equipment lease, business loan, trade finance |
| **Sole Proprietors** | 30 | Person name + trade name, KVK | Business loan, auto lease |

Each customer appears across multiple platforms with **platform-specific ID formats** — creating the cross-system governance challenge that tools must solve.

---

## Slide 13: Data Quality as a First-Class Citizen

### 11 Quality Rule Types, All Discoverable

| Rule Type | What It Catches | Planted Issues |
|---|---|---|
| Functional Dependency | Same customer ID, different name | 34 |
| Domain List | Gender = "Male" instead of "M" | 17 |
| Domain Pattern | Truncated IBANs, malformed phones | 28 |
| Domain Range | Negative income, age = 200 | 12 |
| No Nulls | NULL in mandatory fields | 22 |
| Conditional FD | Sanctioned entity with AAA risk rating | 3 |
| **Multi-Column** | **IBAN country ≠ customer country** | **16** |
| Unique Key | Duplicate customer IDs | 9 |
| Referential | Orphaned references | 19 |
| Date Logic | End date before start date | 4 |
| Name & Address | City and street fields swapped | 9 |

**Multi-column quality issues** are the hardest to detect — most tools miss them. Our data has 16 planted multi-column violations that require checking two or more columns together.

---

## Slide 14: Cross-Platform Data Flow

### Lineage from Source to Report

```
SQL Server (Source of Truth)
  Customer CUST-00042 created 2023-01-15
       │
       ▼
PostgreSQL (CRM Replication)
  customer_id = 42, synced 2023-01-16
       │
       ▼
Snowflake (Risk Analytics)
  CUSTOMER_KEY = C000042, loaded 2023-01-17
  Balance: EUR 15,200 (rounded during ETL)
       │
       ▼
Fabric (Corporate Reporting)
  CustomerId = CUST-00042, loaded 2023-01-18
  Balance: EUR 14,980 (different calculation logic)
```

**The balance differs at each hop.** SQL Server: 15,234.50 → Snowflake: 15,200 → Fabric: 14,980. Each system has a valid reason. Governance tools must trace this lineage and explain the differences.

---

## Slide 15: The 28 Governance Scenarios

### What We Can Demonstrate

**Pillar 1: Discovery & Cataloging (10 scenarios)**
- Multi-platform discovery across 8 engines
- Cross-system customer search
- PII auto-classification
- Impact analysis for column changes

**Pillar 2: Business Glossary (9 scenarios)**
- Term consistency across domains
- KPI traceability from business definition to SQL
- Synonym detection and concept alignment
- Concept drift over time (definition changes)

**Pillar 3: Data Products (5 scenarios)**
- Product catalog with SLA monitoring
- Dependency mapping between products
- Lifecycle management (draft → active → deprecated)

**Pillar 4: Domains & Collections (4 scenarios)**
- Domain hierarchy navigation
- Collection-based RBAC
- Cross-domain data sharing agreements
- Domain-level quality dashboards

---

## Slide 16: The Knowledge Graph

### Everything Connected

```
2,009 Dataset nodes
55,955 Data Element nodes
7 Domain nodes
33 Sub-domain nodes
200+ Source System nodes
8 Platform nodes
10+ Data Product nodes
100+ Person nodes (owners, stewards)
500 Shared Entity nodes (customers across platforms)

Connected by relationships:
  Dataset → BELONGS_TO → Domain
  Dataset → DEPLOYED_ON → Platform
  Dataset → OWNED_BY → Person
  DataElement → SAME_ENTITY_AS → DataElement (cross-platform)
  DataProduct → CONSUMES → Dataset
  Domain → OVERSEEN_BY → Person
```

The knowledge graph connects **metadata, physical data, governance rules, and lineage** into one queryable structure. Ask any question — the graph has the answer.

---

## Slide 17: Implementation — Microsoft Purview

### Enterprise-Grade Governance on Azure

We are implementing Masreph's governance architecture in **Microsoft Purview**:

**What Purview provides:**
- **Data Map:** Auto-discovery of all 8 platforms via native connectors
- **Unified Catalog:** 2,009 datasets searchable in one place
- **Domains:** 7 governance domains mapped from our metadata
- **Collections:** 10 collections with Azure AD-based RBAC
- **Glossary:** 100+ business terms with hierarchies and synonyms
- **Classifications:** Auto-detect PII across all platforms
- **Lineage:** Cross-system data flow visualization
- **Data Products:** Register and monitor data products with SLAs

**How we automate it:**
- **PVW CLI** — our custom CLI tool with 96% Purview API coverage
- Bulk import glossary terms, domains, data products via CSV
- Programmatic lineage creation from metadata
- Everything version-controlled and repeatable

---

## Slide 18: Implementation — OpenMetadata

### Open-Source Alternative, Full Capability

In parallel, we implement the same governance in **OpenMetadata**:

**What OpenMetadata provides:**
- **Ingestion pipelines:** Connect all 8 platforms via 50+ connectors
- **Domains & Teams:** Same 7 domains, team-based access control
- **Glossary:** Full glossary with categories, reviewers, tags
- **Data Products:** Native support with SLAs and lifecycle states
- **Quality:** Built-in profiling and test suites
- **Lineage:** Plugin-based lineage with column-level tracking

**How we automate it:**
- **Python SDK** — `openmetadata-ingestion` library
- Full API coverage for all governance operations
- Same source of truth (data_marketplace DB) drives both tools

**The value:** Side-by-side comparison shows strengths of each tool against the same realistic enterprise. Vendor-neutral evaluation.

---

## Slide 19: Why This Matters

### The Business Case for Data Governance

| Without Governance | With Governance |
|---|---|
| "Where is customer data?" → 1 week to answer | 1 click in the catalog |
| GDPR right-to-erasure → manual search across 8 systems | Automated PII discovery across all platforms |
| "Is this report correct?" → nobody knows | Traceable lineage from source to report |
| Data quality issues discovered in production | Quality rules catch issues before they reach consumers |
| New analyst onboarding: 3 months to understand the landscape | Self-service discovery with business context |
| Regulatory audit: panic mode | Compliance evidence always ready |

**ROI:** Faster decisions, lower compliance risk, higher data trust, reduced operational cost.

---

## Slide 20: What We Built

### A Realistic, Reusable Governance Platform

| Component | Scale |
|---|---|
| Database platforms | 8 (SQL Server, PostgreSQL, MySQL, Snowflake, Databricks, Fabric, Oracle, MongoDB) |
| Datasets cataloged | 2,009 |
| Datasets deployed with data | 328 |
| Tables across platforms | 692 |
| Shared customers | 500 (350 individuals + 120 entities + 30 sole proprietors) |
| Data quality issues | 335 (11 rule types) |
| Governance domains | 7 |
| Collections | 10 |
| Governance scenarios | 28 |
| Business glossary terms | 100+ (designed) |
| Data products | 8-10 (designed) |

**All driven by metadata.** The `data_marketplace` database is the single source of truth. Everything else — domains, collections, quality issues, data products — is derived from it.

**Fully programmable.** PVW CLI for Purview, Python SDK for OpenMetadata. No manual clicking. Version-controlled. Repeatable.

---

## Slide 21: Next Steps

### From Demo to Production

1. **Connect Purview** to all 8 platforms → run Level 1+2 scans (discovery + classification)
2. **Deploy OpenMetadata** → run ingestion pipelines for all 8 platforms
3. **Import glossary** → 100+ terms via PVW CLI and OM SDK
4. **Configure domains & collections** → push from data_marketplace via API
5. **Register data products** → with SLAs and dependency mapping
6. **Build knowledge graph** → connect all nodes for advanced querying
7. **Record demo** → 28 governance scenarios, side-by-side Purview vs OpenMetadata
8. **Publish** → content, training, consulting pipeline

> *"The goal is not to scan 8 databases. The goal is to answer every governance question a CDO has — in seconds, not weeks."*

---

## Contact

**Masreph Enterprise Data Governance**
Built with Azure OpenAI, Python, and 8 database platforms.
Governed with Microsoft Purview and OpenMetadata.

*Metadata-driven. API-first. Vendor-neutral.*
