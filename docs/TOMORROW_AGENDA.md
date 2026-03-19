# Tomorrow's Agenda — Day 1

## Morning: Setup & Assignment

### 1. Review the plan (15 min)
- Read through `PROJECT_PLAN.md` and `ENTERPRISE_STORY.md`
- Adjust anything — platform distribution, naming, story details
- Decide: start with all 8 platforms or pilot with 2-3 first?

### 2. Set up repo structure (15 min)
- Create folder structure (schemas/, data/, scripts/, config/)
- Set up .gitignore, requirements.txt, .env.example
- Push initial commit

### 3. Build the platform assignment script (1-2 hours)
- `scripts/assign_platforms.py`
- Reads all 2,009 datasets from Supabase (or enhanced JSON files)
- Applies rules to assign each dataset to one of 8 platforms:
  - Rule 1: Source system name mapping (e.g., "RealEstate SQL server" → SQL Server)
  - Rule 2: Domain-based fallback (Risk management → Snowflake)
  - Rule 3: Business line fallback (Innovation & Technology → MySQL)
  - Rule 4: Lifecycle-based (Retired → Databricks)
- Output: `config/platform_assignment.json`
- Verify distribution matches target percentages
- Store assignment in Supabase as new column or table

### 4. Create type mapping config (30 min)
- `config/type_mapping.json`
- Maps generic types (string, integer, decimal, etc.) to native types per platform
- Handles edge cases (array → JSONB in PG, VARIANT in Snowflake, etc.)

## Afternoon: Schema Generation (Pilot)

### 5. Build the schema generator (2-3 hours)
- `scripts/generate_schemas.py`
- Takes a platform name → generates DDL for all datasets assigned to that platform
- Uses naming conventions per platform (PascalCase for SQL Server, snake_case for PG, etc.)
- Groups datasets into schemas based on source system or domain
- Maps data element types to platform-native types
- Generates PKs, NOT NULL constraints, indexes

### 6. AI-powered table splitting (1-2 hours)
- For datasets with >15 data elements, call Azure OpenAI to:
  - Analyze if the dataset should be multiple tables
  - Group elements into logical tables
  - Define PKs and FKs between split tables
- For datasets with <=15 elements: 1 dataset = 1 table

### 7. Pilot: SQL Server schemas (1 hour)
- Generate DDL for the ~550 SQL Server datasets
- Review a handful manually for realism
- If we have SQL Server locally, deploy and test

## End of Day: Check-in

### 8. Review what we have
- Platform assignment complete and validated
- Schema generation working for at least 1 platform
- Identify blockers for Day 2

---

## Decision Points for Tomorrow

These are choices to make before we start coding:

1. **Naming the schemas within each platform:**
   - Option A: One schema per source system (e.g., `TransactFinance`, `FinfluxCredit`)
   - Option B: One schema per domain (e.g., `Product`, `Client`, `RiskManagement`)
   - Option C: Mix — some per source system, some per domain (most realistic)

2. **Table splitting scope:**
   - Option A: All datasets with >15 elements get AI splitting
   - Option B: Only pilot a few, keep most as 1:1
   - Option C: Skip splitting entirely, keep it simple

3. **Sample data timing:**
   - Option A: Generate schemas first for ALL platforms, then data
   - Option B: Do schemas + data for one platform at a time (end-to-end pilot)

4. **Which platform accounts to set up tomorrow:**
   - Must have: SQL Server (local), PostgreSQL (Supabase — done)
   - Nice to have: MongoDB Atlas, Oracle Cloud Free Tier
   - Can wait: Snowflake, Databricks, Fabric (trials — start when schemas are ready)
