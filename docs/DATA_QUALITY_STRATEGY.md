# Data Quality Strategy — Realistic Enterprise Imperfections

## Philosophy

A perfect, clean database is a dead giveaway that data is fake. Real enterprise data has layers of quality issues that accumulate over years. The goal is to introduce controlled imperfections that:

1. Look realistic to anyone who has worked with enterprise data
2. Are discoverable by governance tools (Purview, OpenMetadata)
3. Create meaningful data quality scores (not 100%, not 0%)
4. Vary by platform age and type (legacy = messier, modern = cleaner)

---

## Quality Profile Per Platform

### SQL Server (Legacy Core — 15+ years old)
**Overall quality target: 72-82%**

Schema-level issues:
- Overly permissive NULLable columns (fields that should be NOT NULL but aren't)
- Some tables missing foreign key constraints (rely on application-level joins)
- Inconsistent naming within same schema (some PascalCase, some with underscores — result of different developers over the years)
- VARCHAR(MAX) or NVARCHAR(2000) for columns that should be constrained
- A few tables with no primary key (legacy staging tables nobody cleaned up)
- Redundant indexes, missing useful indexes

Data-level issues:
- 5-8% NULL values in non-required fields
- Inconsistent status codes: "Active", "ACTIVE", "active", "A", "1" across different tables
- Default/placeholder values: "N/A", "TBD", "UNKNOWN", "0000-00-00", "-1"
- Trailing whitespace in text fields ("John Smith   ")
- Duplicate records in transaction tables (2-3% duplication rate)
- Orphaned foreign keys (references to deleted customers/products)
- Mixed date formats in VARCHAR date columns ("2025-01-15" vs "01/15/2025" vs "15-Jan-2025")
- Legacy codes nobody documents (status_code = "XQ7" — what does that mean?)
- Truncated data where someone changed VARCHAR(50) to VARCHAR(30)
- Some amount fields stored as VARCHAR instead of DECIMAL (legacy import)

### PostgreSQL (Modern Apps — 5 years old)
**Overall quality target: 88-94%**

Schema-level issues:
- Well-structured, mostly clean
- Occasional missing index on a frequently filtered column
- A few TEXT columns that should be constrained VARCHAR

Data-level issues:
- 1-3% NULL values (modern apps validate better)
- Consistent formatting within tables
- Some stale records (customer email changed but old one still in CRM)
- Minor timezone inconsistencies (some UTC, some local time)
- Occasional encoding issues in names with diacritics (Muller vs Mueller vs Muller)

### MySQL (Digital — 3 years old)
**Overall quality target: 85-92%**

Schema-level issues:
- Simple, clean schemas
- Some missing foreign keys (web apps often skip DB-level constraints)

Data-level issues:
- 2-4% NULL values
- Session/event data with occasional gaps
- Bot traffic mixed with real user data
- Some user-generated content with HTML entities not properly decoded
- Timestamps in different timezones (server-local vs UTC)

### Snowflake (Analytics — 2 years old)
**Overall quality target: 78-86%**

Schema-level issues:
- Well-designed star schema
- Some staging tables left behind from failed ETL runs

Data-level issues:
- Stale data: warehouse is 1-24 hours behind source systems
- Some records missing from failed batch loads (gaps in date ranges)
- Aggregation errors: SUM doesn't match source because of ETL filtering
- Dimension tables with "Unknown" or "Not Specified" catch-all records
- Some fact tables with negative values where they shouldn't be (reversal entries not filtered)
- Historical data with NULL dimension keys (loaded before dimension existed)

### Databricks (Data Lake — 1 year old)
**Overall quality target: 65-78%**

Schema-level issues:
- Some schema drift (column added in source but not yet in Delta table)
- Mixed precision for decimal columns
- Some tables partitioned inefficiently

Data-level issues:
- Raw layer has most quality issues (intentional — it's the landing zone)
- Duplicate records from reprocessing (idempotency not always guaranteed)
- Schema evolution: older records have NULL for columns added later
- Mixed formats: some dates as strings, some as date types
- Large text fields with encoding issues
- Some archived/retired datasets with outdated business logic
- Partial loads visible in _loaded_at timestamps (gaps)

### Microsoft Fabric (Corporate BI — 6 months old)
**Overall quality target: 82-90%**

Schema-level issues:
- Well-designed for reporting
- Some dimension tables are incomplete (new platform, not all data migrated yet)

Data-level issues:
- Some reporting periods have incomplete data (migration was recent)
- Dimension values don't perfectly match source systems
- Some measures show 0 instead of NULL for missing periods
- Rounding differences vs source systems (DECIMAL precision mismatch)
- A few KPIs calculated differently than in Snowflake (intentional disagreement between teams)

### Oracle (Legacy ERP — 20+ years old)
**Overall quality target: 60-75%**

Schema-level issues:
- Heavily abbreviated names that are hard to understand
- Some tables have 40+ columns (denormalized legacy design)
- Missing or outdated comments on columns
- Some constraints disabled for "performance" and never re-enabled
- Character set issues (some data in WE8MSWIN1252, some in AL32UTF8)

Data-level issues:
- 8-12% NULL values
- Many default values that were never updated ("XXXX", "???", "CHANGE_ME")
- Insurance contracts with impossible dates (end_date before start_date in 0.5% of records)
- Legacy customer IDs in multiple formats (some numeric, some alphanumeric)
- Amounts in different currencies without consistent currency indicator
- Archived records mixed with active records (no soft-delete flag on some tables)
- Some CLOB columns with corrupted XML from old import jobs

### MongoDB (API Layer — 2 years old)
**Overall quality target: 70-82%**

Schema-level issues:
- Documents vary in shape (some have fields others don't)
- No enforced schema validation on older collections
- Nested arrays with inconsistent depth

Data-level issues:
- Schema drift: documents from 2024 have different fields than 2025
- Some documents missing required fields (inserted before validation was added)
- Mixed types for same field (age as string "25" vs number 25)
- Nested objects with inconsistent key names (firstName vs first_name in different documents)
- Large documents (>1MB) from uncontrolled array growth
- Stale embedded data (customer name updated in CRM but not in embedded copy)
- Null vs missing field (some use null, some omit the field entirely)

---

## Cross-System Quality Issues

These are the most valuable for governance demos — they show why centralized governance matters.

### Entity Inconsistency
The same customer appears across systems with differences:

| System | Customer ID | Name | Email |
|---|---|---|---|
| SQL Server | CUST-00142 | John Smith | j.smith@company.com |
| PostgreSQL | 142 | John A. Smith | john.smith@company.com |
| Snowflake | C000142 | JOHN SMITH | J.SMITH@COMPANY.COM |
| Oracle | 00142 | SMITH, JOHN | jsmith@company.com |
| MongoDB | {"customerId": "cust_142"} | {"firstName": "John", "lastName": "Smith"} | john.smith@company.com |

### Reference Data Drift
- Country codes: some systems use ISO 3166 ("NL"), others use full names ("Netherlands"), others use legacy codes ("NED")
- Currency: "EUR" vs "Euro" vs "978" (ISO numeric)
- Status values: "Active"/"Inactive" vs "A"/"I" vs 1/0 vs true/false
- Date formats: ISO 8601 in new systems, locale-dependent in legacy

### Timeliness Gaps
- Source (SQL Server) updated at 14:00
- Warehouse (Snowflake) loaded at 02:00 next day (12-hour lag)
- BI (Fabric) refreshed weekly on Monday
- Data lake (Databricks) has 3 versions: bronze (raw, hourly), silver (cleaned, daily), gold (aggregated, weekly)

### Completeness Gaps
- Customer 12345 exists in SQL Server (finance) and PostgreSQL (CRM) but NOT in Snowflake (risk screening was bypassed)
- Product XYZ exists in Oracle (ERP) but was never cataloged in the data marketplace
- Employee records in Fabric but missing from Databricks feature store

### Accuracy Conflicts
- Customer balance in SQL Server: EUR 15,234.50
- Same customer in Snowflake report: EUR 15,200.00 (rounded during ETL)
- Same customer in Fabric dashboard: EUR 14,980.00 (uses different calculation logic)

---

## Quality Metrics Integration

Each dataset in the data marketplace already has quality metrics:
- qualityScore, completeness, accuracy, timeliness

These should CORRELATE with the actual quality of the generated data:
- A dataset with qualityScore=95 should have very few NULLs, consistent formats
- A dataset with qualityScore=68 should have visible quality issues
- The platform-level quality targets above should influence individual dataset scores

---

## What This Enables for Governance Demos

1. **Data Quality Rules**: Define rules like "customer_email must match regex", "amount > 0", "date is valid" — and show them catching real issues
2. **Quality Dashboards**: Aggregate quality scores by domain, platform, business line — see patterns
3. **Root Cause Analysis**: "Why is Collateral domain quality low?" -> "Because Oracle legacy system has 12% NULLs"
4. **Quality Trend**: Show how quality improved after migration from Oracle to PostgreSQL
5. **Cross-System Reconciliation**: "Customer count in CRM vs Finance — why do they differ by 3%?"
6. **Data Profiling**: Run profiling tools, discover actual distributions, find outliers
7. **Remediation Workflow**: Flag issues, assign to data stewards, track resolution

---

## Implementation Approach

### Phase 1 (Schema generation — current)
- Schema-level issues are partially captured in the AI splitting prompt
- Platform-specific conventions already encode some quality patterns (Oracle abbreviations, legacy SQL Server naming)

### Phase 2 (Sample data generation — next)
- Generate base data that is mostly correct
- Apply platform-specific quality degradation:
  - Introduce NULLs at platform-appropriate rates
  - Add format inconsistencies based on platform age
  - Create cross-system entity mismatches
  - Plant discoverable quality issues (invalid dates, wrong formats, duplicates)
- Track which issues were introduced (so we can validate governance tools find them)

### Phase 3 (Quality metadata update)
- Update dataset quality metrics in the data marketplace to reflect actual generated quality
- Ensure qualityScore correlates with real data quality
- Document known quality issues per dataset for demo scripts
