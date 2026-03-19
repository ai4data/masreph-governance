# The Masreph Enterprise Story

## Company Profile

**Masreph** is a mid-large European financial services and leasing conglomerate headquartered in the Netherlands. Founded in 1987 as a vehicle leasing company, it has grown through acquisitions and organic expansion into a diversified financial services group.

## Global Presence

| Region | Entity | Focus |
|---|---|---|
| Netherlands | Masreph Nederland | HQ, core operations |
| Europe | Masreph Europe | Commercial finance, leasing |
| Asia-Pacific | Masreph AsiaPac | Consumer finance, mobility |
| Americas | Masreph Americas | Asset-based lending |
| Corporate | Masreph Corporate | Shared services, risk, HR |

## Business Lines

| Business Line | Datasets | Description |
|---|---|---|
| Leasing | 600 | Vehicle leasing, equipment leasing, fleet management |
| Commercial Finance | 502 | Trade finance, lending, treasury operations |
| Mobility Solutions | 289 | Mobility infrastructure, vehicle services, EV financing |
| Consumer Finance | 255 | Personal loans, savings, credit cards, mortgages |
| Innovation & Technology | 223 | Digital platforms, APIs, data engineering |
| Finance Office | 80 | Corporate finance, accounting, reporting |
| Risk Management | 37 | Enterprise risk, credit risk, operational risk |
| Human Resources | 17 | Workforce management, talent, payroll |

## Technology History

### Era 1: The Oracle Foundation (1995-2010)
Masreph's first enterprise system was **Oracle**. Lease contract management, insurance processing, and the original ERP all ran on Oracle databases. Some acquired subsidiaries still run on Oracle today — nobody wants to touch the legacy lease contract system that processes 40,000 active contracts.

**What remains on Oracle today:** Legacy ERP modules, insurance systems, lease contract management for 3 subsidiaries, product registry.

### Era 2: The SQL Server Backbone (2010-2020)
As Masreph grew, they standardized on **Microsoft SQL Server** for core banking operations. Transaction processing, payment systems, credit management, and the entire lending platform migrated to SQL Server. This is still the heart of the company — every payment, every transaction, every credit decision flows through SQL Server.

**What runs on SQL Server today:** TransactFinance (core transactions), Finflux-Credit (credit processing), payment operations (SEPA, SWIFT, cross-border), trade finance, real estate finance, Calypso (treasury), ATM transactions.

### Era 3: Digital Transformation (2020-2023)
The "Digital Masreph" initiative modernized customer-facing systems. New applications were built on **PostgreSQL** — the CRM platform, customer data management, master data management. Meanwhile, lightweight web and mobile applications used **MySQL** for simplicity.

**What runs on PostgreSQL today:** Customer insights (Salesforce integration), Microsoft Dynamics 365 data, contact repository, InfoSphere MDM, customer care platform.

**What runs on MySQL today:** Web portals, mobile app backends, email analytics, chatbot services, digital payment tokens, internal tools.

### Era 4: Cloud Analytics (2023-2024)
The Risk & Compliance team, under regulatory pressure, moved first to the cloud. They chose **Snowflake** for their analytics warehouse — sanction screening, identity verification, compliance monitoring, risk scoring. This was a team-level decision, not an enterprise standard.

**What runs on Snowflake today:** Sanction Scanner analytics, RiskConnect dashboards, Veriff identity verification, Trulioo KYC, ACTICO rules engine outputs, compliance reporting, risk models.

### Era 5: The Data Lake (2024-2025)
Data Engineering adopted **Databricks** for the data lakehouse strategy. Raw data ingestion from all source systems, ML model training (credit scoring, fraud detection), and the data science team's feature store all live here. Historical and retired datasets are archived in Databricks as Delta tables.

**What runs on Databricks today:** Raw data landing zone, ML feature stores, credit scoring models, event streams, archived datasets, data science experiments, collateral valuation models.

### Era 6: Corporate Mandate (2025-present)
Corporate IT mandated **Microsoft Fabric** as the enterprise analytics and BI standard. The Finance Office, HR, and corporate reporting moved to Fabric. This created the classic enterprise tension: Risk uses Snowflake, Corporate uses Fabric, Data Engineering uses Databricks. The CDO's job is to govern all of it.

**What runs on Fabric today:** Finance office reporting, HR analytics, employee data, corporate dashboards, the "official" BI layer, Dataedo governance catalog.

### The API Layer (2023-present)
Quietly, the API and microservices architecture grew a **MongoDB** layer. Event-driven systems, API logs, interaction analytics, and semi-structured data from digital services are stored in MongoDB Atlas.

**What runs on MongoDB today:** API interaction logs, customer chatbot conversations, digital finance messages, event streams, retail analytics, app telemetry.

## The Current Challenge

Masreph has:
- **8 database platforms** across on-premises and cloud
- **2,009 datasets** that the CDO knows about (probably more undiscovered)
- **55,955 data elements** (columns) with varying quality
- **~200 source systems** built or acquired over 30 years
- No unified governance, no single data catalog, no consistent access policies

The CDO has been given a mandate: **"Make our data landscape governable."**

This is where Purview and OpenMetadata come in.

## Data Domains

| Domain | Datasets | Description | Primary Platforms |
|---|---|---|---|
| Product | 614 | Financial products, contracts, services | SQL Server, Oracle |
| Client | 465 | Customer data, KYC, contacts | PostgreSQL, SQL Server, Snowflake |
| Risk Management | 388 | Compliance, screening, risk scores | Snowflake, Databricks |
| Collateral | 170 | Assets, guarantees, valuations | SQL Server, Databricks |
| IT | 149 | Systems, APIs, digital platforms | MySQL, MongoDB |
| Partner | 148 | Third parties, vendors, agents | PostgreSQL, Snowflake |
| Finance | 57 | Accounting, financial control, reporting | Fabric, SQL Server |
| Employee | 17 | HR, workforce, talent | Fabric |

## Key Governance Scenarios

### Scenario 1: "Where is our customer data?"
Customer data exists in PostgreSQL (CRM), SQL Server (transactions), Snowflake (risk screening), MongoDB (chatbot logs), and Fabric (reporting). The CDO needs one view.

### Scenario 2: "Who can access what?"
The Leasing business line has 600 datasets. Regional teams should only see their region's data. Stewards need edit access. Business users need read-only. How do you enforce this across 8 platforms?

### Scenario 3: "Are we GDPR compliant?"
PII is scattered across all platforms. Some datasets have `data_classification: Restricted`. Some have GDPR legal basis documented. The DPO needs to verify compliance across the entire landscape.

### Scenario 4: "What breaks if we change this?"
The SQL Server `customer_id` format is changing from 8 digits to 12. What downstream systems (Snowflake, Fabric, Databricks) are affected? Lineage tells you.

### Scenario 5: "Is our data any good?"
Quality scores vary by platform. Legacy Oracle tables have 60% completeness. Modern PostgreSQL has 95%. The CDO needs a quality dashboard across all 8 platforms.
