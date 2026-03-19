# Knowledge Graph & Data Governance Concepts

## The Big Picture

The 2,009 datasets are the foundation for a **semantic knowledge graph** that represents the entire Masreph enterprise. On top of this graph, we concretise governance concepts that are often abstract in theory but need to be tangible in demos.

## Governance Concepts to Concretise

### 1. Data Domains

Not just labels — real organizational boundaries with ownership and accountability.

| Domain | Domain Owner | Description | Deployed Datasets | Total Datasets |
|---|---|---|---|---|
| Client | Head of CRM | Everything about who our customers are | ~60 | 465 |
| Product | Head of Product | Financial products, services, contracts | ~60 | 614 |
| Risk Management | Chief Risk Officer | Risk scoring, compliance, screening | ~50 | 388 |
| Collateral | Head of Collateral Mgmt | Assets, guarantees, valuations | ~30 | 170 |
| IT | CTO | Systems, APIs, digital platforms | ~30 | 149 |
| Partner | Head of Partnerships | Third parties, vendors, agents | ~30 | 148 |
| Finance | CFO | Accounting, financial control, reporting | ~20 | 57 |
| Employee | CHRO | HR, workforce, talent | ~15 | 17 |

Each domain must have:
- A clear owner (from the metadata)
- Datasets spanning multiple platforms (not isolated to one)
- Data elements that overlap with other domains (cross-domain relationships)
- Quality metrics that differ by platform

### 2. Data Products

A **data product** is a curated, trustworthy, reusable dataset with a defined interface. We select datasets that can be grouped into data products:

| Data Product | Domain | Datasets Included | Consumers | SLA |
|---|---|---|---|---|
| Customer 360 | Client | Client profiles from PostgreSQL + SQL Server + Snowflake | Marketing, Risk, Sales | Daily refresh |
| Credit Risk Score | Risk | Risk ratings from Snowflake + SQL Server + Databricks | Lending, Compliance | Real-time |
| Product Catalog | Product | Product definitions from SQL Server + Oracle | All business lines | On change |
| Leasing Portfolio | Product | Contracts from SQL Server + Oracle + Snowflake | Finance, Risk | Daily |
| KYC/AML Screening | Risk | Screening results from Snowflake + MongoDB | Compliance, Onboarding | Real-time |
| Employee Directory | Employee | HR data from Fabric + SQL Server | HR, Management | Weekly |
| Payment Transactions | Product | Payment records from SQL Server + MySQL | Finance, Audit | Hourly |
| Partner Registry | Partner | Partner profiles from PostgreSQL + Oracle | Procurement, Legal | Monthly |

Each data product must:
- Combine data from multiple source datasets
- Have a clear owner (data product owner ≠ dataset owner)
- Have defined quality expectations (SLA)
- Have consumers who depend on it
- Be discoverable in Purview/OpenMetadata

### 3. Data Contracts

A **data contract** defines the agreement between a data producer and consumer. We create concrete contracts:

| Contract | Producer | Consumer | What's Guaranteed |
|---|---|---|---|
| Customer ID Format | SQL Server (Core Banking) | All downstream systems | Format: CUST-XXXXX, always populated, unique |
| Credit Score Delivery | Risk Engine (Snowflake) | Lending Platform (SQL Server) | Delivered daily by 06:00 UTC, score range 0-100, no NULLs |
| Product Code Standard | Product Registry (Oracle) | All platforms | ISO format, 3-letter prefix + 4 digits, immutable once assigned |
| PII Handling | CRM (PostgreSQL) | Analytics (Snowflake, Databricks) | Emails hashed before export, names pseudonymized, consent verified |
| Payment Data Freshness | Core Banking (SQL Server) | Reporting (Fabric) | Max 24h delay, amounts in EUR, reconciled with GL |

Each contract must:
- Reference specific data elements (columns) from our metadata
- Be verifiable (we can check: does the data actually meet the contract?)
- Be breakable (we plant violations to show what happens when contracts are broken)

### 4. Data Quality Rules

Not abstract scores — concrete, verifiable rules tied to data elements:

| Rule | Domain | Data Element | Platform | Expected | Planted Violation |
|---|---|---|---|---|---|
| Customer email format | Client | email_address | PostgreSQL | Valid email regex | 2% have "N/A" or blank |
| Credit score range | Risk | credit_score | Snowflake | 0-100 | 1% have -1 (missing marker) |
| Contract dates logical | Product | start_date, end_date | SQL Server | start < end | 0.5% have end before start |
| Country code ISO | All | country_code | All platforms | ISO 3166-1 alpha-2 | Oracle uses "NLD", MongoDB uses "Netherlands" |
| Amount non-negative | Finance | transaction_amount | SQL Server | >= 0 | 0.3% have negative (reversals) |
| IBAN format | Client | iban | PostgreSQL, SQL Server | Valid IBAN | 1% have truncated IBANs |

### 5. Data Lineage

Not just metadata lineage — data-level lineage traceable through shared entities:

```
Source of Truth (SQL Server)
  Customer CUST-00142 created 2023-01-15
    ↓
CRM Replication (PostgreSQL)
  customer_id=142 synced 2023-01-16
    ↓
Risk Screening (Snowflake)
  CUSTOMER_ID='C000142' loaded 2023-01-17, risk_score=72
    ↓
Data Lake Landing (Databricks bronze)
  customer_id='cust_142' ingested 2023-01-17
    ↓
Corporate Reporting (Fabric bronze)
  CustomerId='CUST-00142' loaded 2023-01-18, total_balance=EUR 15,234
```

Each hop has a timestamp, showing when data arrived. The quality degrades slightly at each hop (realistic ETL).

### 6. Data Classification

Concrete classification labels tied to data elements:

| Classification | Data Elements | Platforms | Action Required |
|---|---|---|---|
| PII - Direct Identifier | full_name, email, phone, iban | All | Encryption at rest, access control |
| PII - Indirect Identifier | date_of_birth, postal_code, gender | PG, SQL Server | Pseudonymization for analytics |
| Confidential | credit_score, income, net_worth | SQL Server, Snowflake | Role-based access only |
| Internal | product_code, contract_id, status | All | Standard access |
| Public | country_code, currency_code | All | No restrictions |

### 7. Access Policies (RBAC + ABAC)

Concrete policies based on domains and classifications:

| Policy | Who | Can Access | Condition |
|---|---|---|---|
| Client Domain Read | Client Data Stewards | All Client domain datasets | Any platform |
| Risk Domain Full | Risk Analysts | Risk Management datasets | Only Snowflake + SQL Server |
| PII Access | Compliance Team | PII-classified elements | With audit logging |
| Regional Scope | Europe Team | Datasets where business_entity='Europe' | Any domain |
| Product Read | All Employees | Product catalog datasets | Non-confidential only |

---

## Knowledge Graph Structure

### Nodes

| Node Type | Count | Source |
|---|---|---|
| Dataset | 2,009 | dmp-masreph catalog |
| DataElement | 55,955 | dmp-masreph catalog |
| Domain | 9 | Metadata field: data_domain |
| SubDomain | 33 | Metadata field: data_subdomain |
| SourceSystem | ~200 | Metadata field: source_sys_name |
| Platform | 8 | Platform assignment |
| BusinessLine | 10 | Metadata field: business_line |
| BusinessEntity | ~60 | Metadata field: business_entity |
| Person (Owner/Steward) | ~100 | Metadata fields: data_owner, data_steward |
| DataProduct | 8-10 | Defined above |
| DataContract | 5-8 | Defined above |
| QualityRule | ~20 | Defined above |
| Classification | 5 | Defined above |
| Table (Physical) | 600-800 | Deployed across 8 platforms |
| SharedEntity | ~970 | Master entity pool |

### Edges (Relationships)

| From | Relationship | To |
|---|---|---|
| Dataset | HAS_ELEMENT | DataElement |
| Dataset | BELONGS_TO_DOMAIN | Domain |
| Dataset | HAS_SUBDOMAIN | SubDomain |
| Dataset | SOURCED_FROM | SourceSystem |
| Dataset | DEPLOYED_ON | Platform |
| Dataset | OWNED_BY | Person |
| Dataset | STEWARDED_BY | Person |
| Dataset | PART_OF_BUSINESS_LINE | BusinessLine |
| Dataset | MANAGED_BY_ENTITY | BusinessEntity |
| Dataset | RELATED_TO | Dataset |
| Dataset | CONTRIBUTES_TO | DataProduct |
| Dataset | GOVERNED_BY | DataContract |
| Dataset | CLASSIFIED_AS | Classification |
| Dataset | MATERIALIZED_AS | Table (for the 300 deployed) |
| DataElement | SAME_ENTITY_AS | DataElement (cross-platform) |
| DataElement | HAS_QUALITY_RULE | QualityRule |
| DataElement | HAS_CLASSIFICATION | Classification |
| DataProduct | CONSUMES | Dataset (multiple) |
| DataProduct | OWNED_BY | Person |
| DataProduct | HAS_SLA | DataContract |
| SharedEntity | REPRESENTED_IN | Table (cross-platform) |
| SourceSystem | RUNS_ON | Platform |
| Domain | OVERSEEN_BY | Person (Domain Owner) |

---

## Dataset Selection Criteria (Revised)

The 300 datasets must be selected to enable ALL of the above concepts:

### Mandatory Selection Rules

1. **Data Product coverage:** Every data product must have at least 3 contributing datasets deployed across 2+ platforms

2. **Cross-platform entities:** At least 10 datasets per platform must contain shared entity elements (customer_id, product_code, etc.)

3. **Data contract participants:** Both producer and consumer datasets in each contract must be deployed

4. **Classification coverage:** At least 5 datasets per classification level must be deployed

5. **Quality rule targets:** Every quality rule must target at least one deployed dataset

6. **Domain representation:** Every domain must have datasets deployed on at least 2 different platforms

7. **Lineage chain:** At least 3 complete lineage chains (source → warehouse → report) must be traceable

### Selection Algorithm

```
1. Start with data product datasets (mandatory — ~80 datasets)
2. Add data contract producer/consumer datasets (~40 more)
3. Add datasets with shared entity elements per platform (~60 more)
4. Fill domain gaps (ensure 2+ platforms per domain) (~40 more)
5. Add datasets with PII elements for classification scenario (~30 more)
6. Add remaining to reach ~300, prioritizing:
   - Highest numberOfDataElements
   - Have dataOwner and dataSteward assigned
   - maturity = "Prepared for distribution"
   - data_lifecycle = "Active"
```

---

## Implementation Impact

This knowledge graph layer means:
- The 300 dataset selection is **not random** — it's driven by governance concepts
- The shared entity model supports **data lineage** and **data products**
- The data contracts are **verifiable** against actual deployed data
- The quality rules are **testable** — governance tools can find the planted violations
- The classification labels map to **actual PII** in the deployed tables

This transforms the demo from "look, we scanned 8 databases" to "look, we can answer every governance question a CDO has."
