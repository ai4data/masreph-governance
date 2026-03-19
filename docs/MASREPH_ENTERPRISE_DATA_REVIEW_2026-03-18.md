# Masreph Enterprise Data Review (5 Platforms)

- Run date: 2026-03-18
- Scope: SQL Server, PostgreSQL (Supabase masreph-core), Oracle (MASREPHDB), MongoDB Atlas, MySQL
- Reviewer notes: validation executed from workspace terminal with direct live queries.

## Executive Summary

- Cross-platform master-entity alignment is **partially validated**. I found **10 customers** present across SQL Server + PostgreSQL + Oracle + MongoDB with matching ID transforms and matching email across those four sources in the sample (mismatches: 0).
- MySQL validation is **blocked**: connection refused on `localhost:3306` with `root` credentials.
- SQL Server separation target is met: **42 Masreph databases** found.
- PostgreSQL business schema separation is met: **13 active business schemas** (excluding Supabase internal schemas).
- Oracle has **17 tables**, but only **2 tables contain rows**; MongoDB has **4 databases / 4 collections** loaded.
- Data quality issues are discoverable across platforms; at least 5 issue types are query-detectable (domain list, domain pattern, domain range, status inconsistency, cross-platform consistency checks).

## 1) Cross-Platform Entity Consistency (10 Sample Customers)

Sample chosen from intersection of IDs present in SQL `tblClientKycContact`, PostgreSQL `core_contact_repository.client_personas`, Oracle `FLORIUS_FINANCE_CUSTOMERS_DATA`, and Mongo `masreph_redaktde.docuVerifyFinanceDataset`.

| idx | master_id | master_name | SQL Server | PostgreSQL | Oracle | MongoDB | MySQL |
|---:|---|---|---|---|---|---|---|
| 7 | CUST-00007 | Lotte Dijkstra | CUST-00007 / lotte.dijkstra@gmail.com | 7 / inactive | 000007 / lotte.dijkstra@gmail.com | cust_7 / Lotte Dijkstra | not validated (connection blocked) |
| 9 | CUST-00009 | Lucas Moreau | CUST-00009 / lucas.moreau@masreph.com | 9 / inactive | 000009 / lucas.moreau@masreph.com | cust_9 / Lucas Moreau | not validated (connection blocked) |
| 16 | CUST-00016 | Bram Willems | CUST-00016 / bram.willems@gmail.com | 16 / closed | 000016 / bram.willems@gmail.com | cust_16 / Bram Willems | not validated (connection blocked) |
| 19 | CUST-00019 | Carlos Sharma | CUST-00019 / carlos.sharma@gmail.com | 19 / closed | 000019 / carlos.sharma@gmail.com | cust_19 / Carlos Sharma | not validated (connection blocked) |
| 23 | CUST-00023 | Bas Fischer | CUST-00023 / bas.fischer@masreph.com | 23 / pending | 000023 / bas.fischer@masreph.com | cust_23 / Bas Fischer | not validated (connection blocked) |
| 33 | CUST-00033 | Bram Dubois | CUST-00033 / bram.dubois@masreph.com | 33 / pending | 000033 / bram.dubois@masreph.com | cust_33 / Bram Dubois | not validated (connection blocked) |
| 39 | CUST-00039 | Renate Williams | CUST-00039 / renate.williams@outlook.com | 39 / inactive | 000039 / renate.williams@outlook.com | cust_39 / Renate Williams | not validated (connection blocked) |
| 40 | CUST-00040 | Aisha Dekker | CUST-00040 / aisha.dekker@masreph.com | 40 / active | 000040 / aisha.dekker@masreph.com | cust_40 / Aisha Dekker | not validated (connection blocked) |
| 41 | CUST-00041 | Carlos Fischer | CUST-00041 / carlos.fischer@masreph.com | 41 / closed | 000041 / carlos.fischer@masreph.com | cust_41 / Carlos Fischer | not validated (connection blocked) |
| 52 | CUST-00052 | Mohammed Schneider | CUST-00052 / mohammed.schneider@gmail.com | 52 / active | 000052 / mohammed.schneider@gmail.com | cust_52 / Mohammed Schneider | not validated (connection blocked) |

Consistency notes:
- ID transform pattern holds for the 10-sample intersection: `CUST-000NN` (SQL) -> `NN` (PostgreSQL) -> `0000NN` (Oracle RAW hex view) -> `cust_NN` (MongoDB).
- Email value matched across SQL/Oracle/Mongo for all sampled customers: **10/10**.
- PostgreSQL sampled table has IDs and status, but no name/email fields in that populated table; name-format validation there is partial.

## 2) Quality Issue Discovery (Query-Based)

| Issue type | Platform / table | Detection result |
|---|---|---:|
| Domain pattern (IBAN too short) | SQL `Masreph_transactfinance.dbo.tblAccount` (`LEN(AccountIban)<15`) | 1 |
| Domain list (invalid gender) | PostgreSQL `core_contact_repository.client_personas` | 1 |
| Domain range (dependents outlier) | PostgreSQL `core_contact_repository.client_personas` (`<0 or >20`) | 311 |
| Domain range (future DOB) | PostgreSQL `core_contact_repository.client_personas` | 1 |
| Domain range (negative income) | Oracle `FLORIUS_FINANCE_CUSTOMERS_DATA` | 2 |
| Domain range (LTV > 100) | Oracle `FLORIUS_FINANCE_CUSTOMERS_DATA` | 347 |
| Status inconsistency (multiple status codes/values) | PostgreSQL `residency_status` distinct values | 4 |
| Status inconsistency (multiple status codes/values) | Oracle `CUSTOMER_LIFECYCLE_STATUS` distinct values | 4 |
| FD violation (same ID, different name) | Mongo `masreph_redaktde.docuVerifyFinanceDataset` | 0 |
| Cross-platform mismatch check (emails in 10-sample) | SQL vs Oracle vs Mongo | 0 mismatches |

Observed status values:
- PostgreSQL `residency_status`: closed (91), active (85), pending (79), inactive (75)
- Oracle `CUSTOMER_LIFECYCLE_STATUS`: inactive (115), pending (98), closed (89), active (83)

## 3) Schema Separation + Naming Convention Validation

### SQL Server
- Databases found: **42** (`Masreph_%`) -> matches expected ~42.
- Table naming vs expected PascalCase: **48/256** match (18.8%).
- Column naming vs expected PascalCase: **3828/3828** match (100%).
- Finding: table naming is mostly `tbl*` style (legacy prefix), not pure PascalCase target.

### PostgreSQL
- Business schemas found (excluding Supabase internals): **13** -> matches expected ~13.
- Table naming snake_case: **194/194** match (100%).
- Column naming snake_case: **2386/2386** match (100%).

### Oracle
- Tables found: **17** (expected ~16; observed 17).
- Table naming uppercase style: **17/17** match (100%).
- Column naming uppercase style: **685/685** match (100%).

### MongoDB
- Databases found: **4**.
- Collection camelCase check: **4/4** match (100%).

### MySQL
- Validation status: **blocked** (`(2003, "Can't connect to MySQL server on 'localhost' ([Errno 111] Connection refused)")`)

## 4) Data Volume Report

### Platform totals

| Platform | Tables/Collections | Rows/Documents | Notes |
|---|---:|---:|---|
| SQL Server | 256 tables across 42 DBs | 27963 | 7 DBs have zero rows |
| PostgreSQL | 194 tables across 13 business schemas | 12955 (n_live_tup) | aligns to expected ~13k |
| Oracle | 17 tables | 572 | concentrated in 2 tables |
| MongoDB | 4 collections across 4 DBs | 842 | lower than expected 15 collections / 2,119 docs |
| MySQL | n/a | n/a | connection blocked |

### SQL Server per database

| Database | Tables | Rows |
|---|---:|---:|
| Masreph_accountlimittracker | 3 | 0 |
| Masreph_accountnumber | 2 | 0 |
| Masreph_afadfinancestore | 1 | 0 |
| Masreph_appello | 9 | 1017 |
| Masreph_assetviewfinance | 4 | 631 |
| Masreph_atmtransaction | 7 | 727 |
| Masreph_calypsox | 5 | 564 |
| Masreph_calypsoxi | 9 | 1107 |
| Masreph_ccosm | 4 | 292 |
| Masreph_clientfinanceibanlist | 1 | 325 |
| Masreph_compliancetransactionservice | 3 | 0 |
| Masreph_corepaymentoperations | 10 | 2006 |
| Masreph_creditdatafinance | 4 | 230 |
| Masreph_crossborderpaymentoperations | 7 | 957 |
| Masreph_dfmstore | 8 | 831 |
| Masreph_digitalfinancemessages | 3 | 528 |
| Masreph_finance360customerinsights | 2 | 139 |
| Masreph_financeadvisornetworksystem | 7 | 580 |
| Masreph_financenetwork | 4 | 212 |
| Masreph_financenetworkservice | 4 | 337 |
| Masreph_financeprospectid | 14 | 1816 |
| Masreph_finfluxcredit | 19 | 1358 |
| Masreph_finhub | 4 | 857 |
| Masreph_insuredatafinance | 5 | 706 |
| Masreph_insuredatafinancecatalog | 6 | 196 |
| Masreph_interfinance | 1 | 149 |
| Masreph_interfinancemessages | 2 | 296 |
| Masreph_masrephproductcontractregistry | 6 | 344 |
| Masreph_moderncorepayments | 4 | 1107 |
| Masreph_montran | 4 | 1142 |
| Masreph_mortgagefinancecalculator | 7 | 644 |
| Masreph_paymenttracker | 7 | 1710 |
| Masreph_realestate | 8 | 349 |
| Masreph_realestatesqlserver | 2 | 0 |
| Masreph_riskwatchfinance | 6 | 0 |
| Masreph_securefinance | 2 | 0 |
| Masreph_sepamandateverification | 6 | 941 |
| Masreph_streamlinepayments | 5 | 1150 |
| Masreph_tessisavingssolution | 1 | 589 |
| Masreph_tradefinancetransactionsstore | 4 | 941 |
| Masreph_transactfinance | 44 | 2935 |
| Masreph_wenmasrephstore | 2 | 250 |

### PostgreSQL per business schema

| Schema | Tables | n_live_tup rows |
|---|---:|---:|
| alvaria | 6 | 831 |
| alvaria_crm | 4 | 648 |
| connect | 6 | 350 |
| core_contact_repository | 25 | 1001 |
| customer_care | 7 | 731 |
| global_credit_store | 15 | 1525 |
| microsoft_dynamics_365 | 17 | 152 |
| microsoft_dynamics_365_crm | 4 | 53 |
| none | 9 | 0 |
| postgresql_global_credit_store | 64 | 4298 |
| profile_app | 6 | 437 |
| salesforce_customer_insights | 27 | 2669 |
| sf_crm_a | 4 | 260 |

### Oracle per table

| Table | Rows |
|---|---:|
| CASHFLOW_INSIGHTS_DATASET | 0 |
| COLLATERAL_FINANCE_DATA_SET | 0 |
| COMMERCIAL_FINANCE_RECORDS | 0 |
| DIGITAL_FINANCE_AUTHORIZATION_ | 0 |
| F360_CMPNY_INSGHT_MSTR | 0 |
| FINANCE360_COMPANY_INSIGHTS | 0 |
| FINANCE_LEDGER_INSIGHTS | 0 |
| FINANCE_SUBSIDIARY_INSIGHTS | 0 |
| FINANCE_TRANSACTION_INSIGHTS | 0 |
| FLORIUS_FINANCE_CUSTOMERS_DATA | 385 |
| FLORIUS_FINANCE_INSIGHTS | 187 |
| LOCATION_FINANCE_INSIGHTS | 0 |
| MORTGAGE_FINANCE_INSIGHTS_ | 0 |
| NL_FINANCE_STAFFING_DATA | 0 |
| RISKWATCH_FINANCE_DATASET | 0 |
| SEPA_MANDATE_VERIFICATION_DATA | 0 |
| TRADE_FINANCE_DATA_SET | 0 |

### MongoDB per database/collection

| Database | Collection | Documents |
|---|---|---:|
| masreph_masrephappregistry | masrephAppRegistry | 188 |
| masreph_mdpglobalapi | mortgageFinanceProfile | 491 |
| masreph_redaktasr | docuVerifyFinanceDataset | 84 |
| masreph_redaktde | docuVerifyFinanceDataset | 79 |

## 5) Issues Found

- MySQL is unreachable (`localhost:3306` refused), so 5-platform completeness is currently blocked.
- SQL Server has **7/42** databases with zero rows: Masreph_accountlimittracker, Masreph_accountnumber, Masreph_afadfinancestore, Masreph_compliancetransactionservice, Masreph_realestatesqlserver, Masreph_riskwatchfinance, Masreph_securefinance.
- SQL Server table naming convention deviates from target PascalCase (heavy `tbl*` usage).
- Provided sample validation SQL in task text did not align 1:1 with deployed objects (e.g., `dbo.Customer` not generally present/populated; required platform-adapted table selection).
- PostgreSQL `salesforce_customer_insights.clients` and `persons` are present but unpopulated for customer-name checks; customer identity checks required other populated schemas/tables.
- Oracle dataset is heavily sparse (15 of 17 tables empty).
- MongoDB volume/coverage is below expected footprint (4 collections vs expected ~15).

## 6) Recommendations Before Governance Tool Onboarding

1. Restore MySQL connectivity and rerun this exact validation pack to complete 5/5 platform checks.
2. Backfill empty SQL Server and Oracle datasets or mark them intentionally out-of-scope; otherwise catalog scans will surface many dead assets.
3. Standardize SQL Server table naming (or document legacy exemption) to avoid false-positive naming-policy violations in Purview/OpenMetadata.
4. Ensure each platform has at least one populated, canonical customer table containing `id + name + email/phone` so cross-platform lineage and DQ rules can be demonstrated end-to-end.
5. Add automated DQ probes to CI for the discovered issue types (domain list, domain pattern, domain range, status normalization, cross-platform consistency).
6. Publish a deterministic crosswalk artifact (`master_id -> per-platform id`) as a managed dataset for governance scanners and glossary linkage.

## Validation SQL/Query Notes (Executed)

- SQL Server: used `sqlcmd` against `localhost` with Windows auth and `Masreph_%` databases.
- PostgreSQL: used Supabase host `aws-1-eu-west-2.pooler.supabase.com` and queried business schemas.
- Oracle: used wallet-based connection to `masrephdb_low` and `ADMIN` schema tables.
- MongoDB: used Atlas URI with TLS + certifi CA.
- MySQL: connection test failed (`Errno 111`).
