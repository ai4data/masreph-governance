# Governance Scenarios — Complete Framework

## 4 Pillars of Data Governance

The simulated Masreph enterprise must demonstrate governance across 4 pillars, each with concrete scenarios that Purview and OpenMetadata can address.

---

## Pillar 1: Data Discovery & Cataloging

The foundation — finding, understanding, and trusting data across the enterprise.

| # | Scenario | What Data Must Exist | Tool Feature |
|---|---|---|---|
| 1 | Multi-platform discovery | 600-800 tables across 8 platforms | Purview: Data Map / OM: Ingestion |
| 2 | Cross-system entity search | Customer 142 in 5+ platforms | Purview: Search / OM: Search |
| 3 | Data owner lookup | Metadata links datasets to stewards | Purview: Contacts / OM: Ownership |
| 4 | PII detection & classification | Emails, IBANs, phones across platforms | Purview: Classification / OM: Tags |
| 5 | Data quality mismatch | Same balance, different values per platform | Purview: Quality / OM: Quality Tests |
| 6 | Lineage trace | Timestamps showing data flow source→warehouse | Purview: Lineage / OM: Lineage |
| 7 | Impact analysis | customer_id referenced in 12+ tables | Purview: Impact / OM: Lineage |
| 8 | GDPR right to erasure | Customer 142 PII in 5 platforms | Purview: Classification + Search |
| 9 | Domain governance view | "Client" domain spans 5 platforms | Purview: Domains / OM: Domains |
| 10 | Reference data inconsistency | "NL" vs "NLD" vs "Netherlands" | Quality rules / Glossary |

---

## Pillar 2: Business Glossary & Semantic Layer

The meaning layer — ensuring everyone speaks the same language about data.

| # | Scenario | What Must Exist | How to Demo |
|---|---|---|---|
| 11 | Business term consistency | Central glossary with ~100 terms, some with multiple definitions per domain | Show "Revenue" defined differently in Finance vs Leasing domain |
| 12 | KPI definition traceability | Business KPI → calculation logic → physical columns | "Net Interest Margin" → SQL formula → `interest_income` column in Snowflake |
| 13 | Synonym & duplicate detection | Synonym groups mapped in glossary | "Customer" = "Client" = "Counterparty" = "Borrower" — 4 terms, 1 concept |
| 14 | Business term ownership gaps | Some terms have stewards, some don't | Dashboard showing 70% of terms have owners, 30% orphaned |
| 15 | Policy-to-term linkage | Regulatory policies linked to glossary terms | GDPR → "Personal Data" term → linked to "Email", "Phone", "IBAN" terms |
| 16 | Concept-to-data model alignment | Logical concept → physical tables across platforms | "Customer" concept → `CUST_MSTR` (Oracle), `clients` (PostgreSQL), `DIM_CUSTOMER` (Snowflake) |
| 17 | Hierarchical concept modeling | Parent-child term hierarchies | "Financial Product" → "Lease" → "Auto Lease" → "Green Auto Lease" |
| 18 | Concept drift over time | Versioned definitions with change history | "Default" changed from 90-day to 60-day definition in 2024 |
| 19 | Cross-domain concept alignment | Same concept, different domain definitions | "Exposure" in Risk domain (credit exposure) vs Finance domain (accounting exposure) |

### Glossary Structure Required

```
Business Glossary
├── Client Domain Terms
│   ├── Customer (preferred) — synonyms: Client, Counterparty, Borrower
│   ├── KYC Status — related: Onboarding, Compliance
│   ├── Customer Segment — values: Mass Market, Affluent, HNW, SME, Corporate
│   ├── Relationship Manager — related: Account Manager, Advisor
│   └── Churn Risk — KPI: formula links to physical columns
│
├── Product Domain Terms
│   ├── Financial Product (parent)
│   │   ├── Lease (child)
│   │   │   ├── Auto Lease
│   │   │   ├── Equipment Lease
│   │   │   └── Green Lease (new 2024)
│   │   ├── Loan
│   │   │   ├── Mortgage
│   │   │   ├── Personal Loan
│   │   │   └── Business Loan
│   │   └── Credit Card
│   ├── Interest Rate — domain-specific: nominal vs effective vs APR
│   ├── Outstanding Balance — calculation differs by domain
│   └── Contract Status — values differ per source system
│
├── Risk Domain Terms
│   ├── Default — definition changed 2024 (90 days → 60 days)
│   ├── Probability of Default (PD) — KPI with formula
│   ├── Loss Given Default (LGD) — KPI with formula
│   ├── Exposure at Default (EAD) — KPI with formula
│   ├── Risk Band — values: AAA through D
│   └── PEP (Politically Exposed Person) — regulatory term
│
├── Finance Domain Terms
│   ├── Revenue — different definition per business line
│   ├── Net Interest Margin — KPI: (interest income - interest expense) / assets
│   ├── Provision — regulatory vs accounting definition
│   └── Cost-to-Income Ratio — KPI with formula
│
├── Compliance Domain Terms
│   ├── Personal Data (GDPR) — linked to PII classification
│   ├── Data Subject — linked to Customer concept
│   ├── Legal Basis — values: consent, legitimate interest, contract, etc.
│   ├── Retention Period — per data category
│   └── Right to Erasure — process term
│
└── Cross-Domain Terms
    ├── Country — reference data, format varies by platform
    ├── Currency — reference data, ISO 4217
    ├── Amount — means different things in different contexts
    └── Date — business date vs system date vs settlement date
```

---

## Pillar 3: Data Products & Data Mesh

The operational layer — treating data as a product with ownership, quality guarantees, and lifecycle.

| # | Scenario | What Must Exist | How to Demo |
|---|---|---|---|
| 20 | Data product catalog | Registry with 8-10 products, descriptions, owners, SLAs, consumers | Browse product catalog, see dependencies |
| 21 | SLA monitoring | Defined freshness/quality SLAs, actual metrics to compare | "Customer 360 should refresh daily" — show it's 2 days stale |
| 22 | Dependency mapping | Product-level lineage showing which products feed into others | Customer 360 depends on CRM data + Core Banking data |
| 23 | Lifecycle management | Products in different states: active, deprecated, draft | Show "Legacy Credit Score v1" deprecated, "Credit Score v2" active |
| 24 | Access governance | RBAC on data products, consumption audit trail | Risk team can access Risk products, Marketing cannot |

### Data Product Registry Required

| Product | Owner | Domain | State | SLA | Source Datasets | Consumers | Platforms |
|---|---|---|---|---|---|---|---|
| Customer 360 | CRM Lead | Client | Active | Daily by 06:00 | 8 datasets | Marketing, Risk, Sales | PG, SQL Server, Snowflake |
| Credit Risk Score | Risk Lead | Risk | Active | Real-time | 5 datasets | Lending, Compliance | Snowflake, SQL Server |
| Product Catalog | Product Lead | Product | Active | On change | 4 datasets | All business lines | SQL Server, Oracle |
| Leasing Portfolio | Finance Lead | Product | Active | Daily by 08:00 | 6 datasets | Finance, Risk | SQL Server, Oracle, Snowflake |
| KYC/AML Screening | Compliance Lead | Risk | Active | Real-time | 4 datasets | Compliance, Onboarding | Snowflake, MongoDB |
| Employee Directory | HR Lead | Employee | Active | Weekly | 3 datasets | HR, Management | Fabric, SQL Server |
| Payment Transactions | Operations Lead | Product | Active | Hourly | 5 datasets | Finance, Audit | SQL Server, MySQL |
| Partner Registry | Procurement Lead | Partner | Active | Monthly | 3 datasets | Procurement, Legal | PostgreSQL, Oracle |
| Legacy Credit Score | Risk Lead (old) | Risk | Deprecated | N/A | 3 datasets | None (migrated) | SQL Server |
| ESG Risk Dashboard | ESG Lead | Risk | Draft | TBD | 2 datasets | Board, Compliance | Databricks |

### Data Contracts Required

| Contract | Producer → Consumer | Terms | Violation to Plant |
|---|---|---|---|
| Customer ID Standard | Core Banking → All | Format CUST-XXXXX, unique, not null | 2% missing in Snowflake (ETL gap) |
| Credit Score Delivery | Risk Engine → Lending | Daily by 06:00, range 0-100 | Delivered at 09:00 (3h late), some scores = -1 |
| Product Code Standard | Product Registry → All | 3-letter + 4-digit, immutable | Oracle has old format (2-letter), MySQL has lowercase |
| PII Handling | CRM → Analytics | Emails hashed, consent verified | Databricks bronze has unhashed emails (raw landing) |
| Payment Reconciliation | Core Banking → Reporting | Max 24h delay, EUR amounts, GL-reconciled | Fabric shows 48h delay, rounding differences |

---

## Pillar 4: Domains & Collections Architecture

The organizational layer — how governance maps to the enterprise structure.

Reference: [Purview Best Practices — Domains & Collections](https://learn.microsoft.com/en-us/purview/data-gov-best-practices-domains-collections)

| # | Scenario | What Must Exist | How to Demo |
|---|---|---|---|
| 25 | Domain hierarchy | Domains → Sub-domains → Data Products → Datasets | Navigate domain tree in Purview/OM |
| 26 | Collection-based RBAC | Collections mirror org: Business Lines → Regions → Teams | Assign user to "Leasing Europe" → sees only their data |
| 27 | Domain-level quality dashboard | Quality scores roll up from datasets to domains | "Client domain: 82% quality" vs "Risk domain: 76% quality" |
| 28 | Cross-domain data sharing agreements | Formal contracts when data flows between domains | Client domain shares customer data with Risk domain — terms defined |

### Domain Architecture (Purview/OpenMetadata)

```
Masreph Enterprise (Root)
│
├── Domain: Client
│   ├── Sub-domain: CRM (PostgreSQL)
│   ├── Sub-domain: Customer Care (PostgreSQL)
│   ├── Sub-domain: KYC/AML (Snowflake)
│   ├── Data Products: Customer 360, KYC Screening
│   └── Quality: 82% avg, 465 datasets, 3 stewards
│
├── Domain: Product
│   ├── Sub-domain: Lending (SQL Server)
│   ├── Sub-domain: Leasing (SQL Server, Oracle)
│   ├── Sub-domain: Payments (SQL Server, MySQL)
│   ├── Data Products: Product Catalog, Leasing Portfolio, Payment Transactions
│   └── Quality: 78% avg, 614 datasets, 4 stewards
│
├── Domain: Risk Management
│   ├── Sub-domain: Credit Risk (Snowflake)
│   ├── Sub-domain: Compliance (Snowflake)
│   ├── Sub-domain: Screening (Snowflake, MongoDB)
│   ├── Data Products: Credit Risk Score, KYC Screening, ESG Dashboard
│   └── Quality: 76% avg, 388 datasets, 2 stewards
│
├── Domain: Collateral
│   ├── Sub-domain: Real Estate (SQL Server, Oracle)
│   ├── Sub-domain: Assets (SQL Server)
│   └── Quality: 71% avg, 170 datasets, 1 steward
│
├── Domain: IT
│   ├── Sub-domain: Digital (MySQL)
│   ├── Sub-domain: APIs (MongoDB)
│   ├── Sub-domain: Governance (Fabric)
│   └── Quality: 85% avg, 149 datasets, 2 stewards
│
├── Domain: Partner
│   ├── Sub-domain: Third Parties (PostgreSQL)
│   ├── Data Products: Partner Registry
│   └── Quality: 80% avg, 148 datasets, 1 steward
│
├── Domain: Finance
│   ├── Sub-domain: Reporting (Fabric)
│   ├── Sub-domain: Accounting (SQL Server)
│   ├── Data Products: (consumed from Product domain)
│   └── Quality: 88% avg, 57 datasets, 1 steward
│
└── Domain: Employee
    ├── Sub-domain: HR (Fabric)
    ├── Data Products: Employee Directory
    └── Quality: 90% avg, 17 datasets, 1 steward
```

### Collection Architecture (Purview)

```
Root Collection: Masreph
│
├── Collection: Corporate
│   ├── Finance Office
│   ├── Risk Management Office
│   ├── HR Office
│   └── Legal & Compliance
│
├── Collection: Business Lines
│   ├── Leasing
│   │   ├── Europe
│   │   ├── AsiaPac
│   │   └── Americas
│   ├── Commercial Finance
│   │   ├── Europe
│   │   └── Americas
│   ├── Consumer Finance
│   │   ├── Europe
│   │   └── AsiaPac
│   ├── Mobility Solutions
│   └── Innovation & Technology
│
└── Collection: Shared Services
    ├── Data Engineering (Databricks)
    ├── Data Analytics (Snowflake)
    ├── Corporate BI (Fabric)
    └── Digital Platforms (MySQL, MongoDB)
```

---

## Complete Scenario Count

| Pillar | Scenarios | Description |
|---|---|---|
| 1. Discovery & Cataloging | #1-10 | Finding, understanding, trusting data |
| 2. Business Glossary & Semantics | #11-19 | Meaning, consistency, concept management |
| 3. Data Products & Mesh | #20-24 | Operational data product management |
| 4. Domains & Collections | #25-28 | Organizational governance structure |
| **Total** | **28 scenarios** | |

---

## What This Means for Dataset Selection

The 300 datasets must now support all 28 scenarios. Additional selection criteria:

- Datasets must map to **glossary terms** (customer, product, risk score, etc.)
- Datasets must belong to **data products** (contributing sources)
- Datasets must participate in **data contracts** (producer or consumer)
- Datasets must span **domain boundaries** (cross-domain data flows)
- Datasets must have **terms with synonyms** across platforms (for semantic scenarios)
- Datasets must include **KPI source columns** (for traceability scenarios)

---

## What Needs to Be Built (Beyond Physical Data)

| Layer | What | Where |
|---|---|---|
| Physical Data | 600-800 tables, shared entities, quality issues | 8 database platforms |
| Business Glossary | ~100 terms, hierarchies, synonyms, policies | Purview Glossary / OM Glossary / Knowledge Graph |
| Data Products | 10 products, SLAs, dependencies, lifecycle | Purview / OM / Knowledge Graph |
| Data Contracts | 5 contracts with verifiable terms | Knowledge Graph + quality checks |
| Domain Structure | 9 domains, sub-domains, quality rollup | Purview Domains / OM Domains |
| Collection Structure | Org hierarchy, RBAC policies | Purview Collections / OM Teams |
| Knowledge Graph | All nodes and edges connecting everything | Neo4j / NetworkX / or embedded in OM/Purview |
