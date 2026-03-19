#!/usr/bin/env python3
"""
Deploy Databricks medallion architecture and generate data.
Catalog: masreph_datalake (Unity Catalog)
Schemas: bronze, silver, gold

Bronze: raw landing tables (all STRING, messy, 65-70% quality)
Silver: cleaned normalized tables (from DDL files, 85-90% quality)
Gold: aggregated business tables (star schema, 95%+ quality)
"""

import os
import re
import json
import random
import string
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from databricks import sql
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "databricks")
CATALOG = "masreph_datalake"

DBX_HOST = "adb-7405617014831513.13.azuredatabricks.net"
DBX_HTTP_PATH = "/sql/1.0/warehouses/b3bee97b5042372c"
DBX_TOKEN = "os.getenv('DATABRICKS_TOKEN')"

# Data pools
FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Daan","Emma",
    "Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte","Ahmed","Fatima",
    "James","Sarah","Robert","Emily","Carlos","Isabella","Hans","Greta","Pedro","Ana"]
LAST_NAMES = ["van den Berg","de Jong","Jansen","de Vries","van Dijk","Bakker","Visser",
    "Smit","Meijer","de Boer","Muller","Schmidt","Schneider","Smith","Johnson",
    "Williams","Brown","Garcia","Martinez","Chen","Wang","Patel","Sharma","Dubois"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["active","inactive","pending","suspended","closed"]
RISK_LEVELS = ["low","medium","high","critical"]
CHANNELS = ["web_portal","mobile_app","branch","phone","email","api"]
CUSTOMER_SEGMENTS = ["mass_market","affluent","high_net_worth","sme","mid_corporate"]
PRODUCT_TYPES = ["auto_lease","equipment_lease","mortgage","personal_loan","business_loan"]
LANGUAGES = ["nl","en","de","fr","es"]


def get_connection():
    return sql.connect(server_hostname=DBX_HOST, http_path=DBX_HTTP_PATH, access_token=DBX_TOKEN)


def exec_sql(cur, stmt):
    """Execute SQL, return True on success."""
    try:
        cur.execute(stmt)
        return True
    except Exception as e:
        return False


# ─── PHASE 1: DEPLOY SILVER TABLES FROM DDL ─────────────────────────────────

def deploy_silver():
    logger.info("=== Deploying Silver Layer ===")
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(f"USE CATALOG {CATALOG}")

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    total_created = 0
    for filepath in sql_files:
        fname = filepath.stem
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        created = 0
        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt:
                continue
            upper = stmt.upper()

            if "CREATE SCHEMA" in upper:
                continue
            elif "CREATE TABLE" in upper:
                # Redirect to silver schema
                modified = re.sub(r'CREATE TABLE IF NOT EXISTS\s+\S+\.', f'CREATE TABLE IF NOT EXISTS {CATALOG}.silver.', stmt)
                # Remove constraints
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', modified)
                if exec_sql(cur, modified):
                    created += 1

        total_created += created
        if created > 0:
            logger.info(f"  silver from {fname}: {created} tables")

    conn.close()
    logger.info(f"Silver: {total_created} tables")
    return total_created


# ─── PHASE 2: DEPLOY GOLD TABLES ────────────────────────────────────────────

def deploy_gold():
    logger.info("\n=== Deploying Gold Layer ===")
    conn = get_connection()
    cur = conn.cursor()

    gold_ddls = [
        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.customer_360 (
            customer_id STRING, masreph_client_id STRING, customer_name STRING,
            country_code STRING, segment STRING, relationship_start_date DATE,
            total_products INT, total_outstanding_balance DECIMAL(18,2),
            average_credit_score INT, risk_band STRING, churn_probability DECIMAL(5,4),
            lifetime_value_eur DECIMAL(18,2), last_interaction_date DATE,
            preferred_channel STRING, gdpr_consent_status STRING,
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.portfolio_performance_daily (
            report_date DATE, business_line STRING, region STRING, product_type STRING,
            active_contracts INT, total_exposure_eur DECIMAL(18,2),
            avg_interest_rate DECIMAL(5,4), delinquency_rate_pct DECIMAL(5,2),
            new_originations INT, new_origination_value_eur DECIMAL(18,2),
            prepayment_rate_pct DECIMAL(5,2), net_interest_margin_pct DECIMAL(5,4),
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.risk_scoring_features (
            customer_id STRING, scoring_date DATE, pd_12m DECIMAL(8,6),
            lgd_pct DECIMAL(5,2), ead_eur DECIMAL(18,2), expected_loss_eur DECIMAL(18,2),
            days_past_due INT, delinquency_count_12m INT, utilization_ratio DECIMAL(5,4),
            income_to_debt_ratio DECIMAL(5,4), employment_stability_years INT,
            number_of_products INT, digital_engagement_score INT,
            model_version STRING, _scored_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.compliance_dashboard (
            report_date DATE, entity STRING, region STRING,
            total_screenings INT, matches_found INT, false_positives INT,
            confirmed_hits INT, pending_reviews INT,
            avg_resolution_time_hours DECIMAL(8,2),
            kyc_completion_rate_pct DECIMAL(5,2), pep_exposure_count INT,
            sanctions_exposure_count INT, aml_alerts_count INT,
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.employee_headcount (
            report_month DATE, department STRING, region STRING,
            headcount INT, fte_count DECIMAL(8,2), new_hires INT,
            terminations INT, turnover_rate_pct DECIMAL(5,2),
            avg_tenure_years DECIMAL(5,1), avg_salary_eur DECIMAL(12,2),
            training_hours_total INT, engagement_score DECIMAL(3,1),
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.data_quality_scorecard (
            assessment_date DATE, source_system STRING, domain STRING,
            table_name STRING, total_records INT,
            completeness_pct DECIMAL(5,2), accuracy_pct DECIMAL(5,2),
            consistency_pct DECIMAL(5,2), timeliness_score DECIMAL(5,2),
            overall_quality_score DECIMAL(5,2), issues_found INT,
            critical_issues INT, last_profiled_at TIMESTAMP,
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.product_performance (
            report_month DATE, product_type STRING, business_line STRING,
            active_count INT, new_originations INT,
            total_balance_eur DECIMAL(18,2), revenue_eur DECIMAL(18,2),
            cost_of_funds_eur DECIMAL(18,2), net_margin_eur DECIMAL(18,2),
            avg_ticket_size_eur DECIMAL(18,2), avg_duration_months INT,
            early_termination_rate_pct DECIMAL(5,2),
            _aggregated_at TIMESTAMP)""",

        f"""CREATE TABLE IF NOT EXISTS {CATALOG}.gold.channel_analytics (
            report_date DATE, channel STRING, region STRING,
            total_interactions INT, unique_customers INT,
            avg_session_duration_minutes DECIMAL(8,2),
            conversion_rate_pct DECIMAL(5,2), satisfaction_score DECIMAL(3,1),
            digital_adoption_pct DECIMAL(5,2),
            _aggregated_at TIMESTAMP)""",
    ]

    created = 0
    for ddl in gold_ddls:
        if exec_sql(cur, ddl):
            created += 1

    conn.close()
    logger.info(f"Gold: {created} tables")
    return created


# ─── DATA GENERATION ─────────────────────────────────────────────────────────

def escape_val(v):
    """Escape a value for SQL INSERT."""
    if v is None:
        return "NULL"
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return str(v)
    if isinstance(v, (datetime, date)):
        return f"'{v}'"
    s = str(v).replace("'", "''").replace("\\", "\\\\")
    return f"'{s}'"


def gen_silver_value(col_name, col_type, row_idx):
    """Generate silver-quality value (85-90% quality)."""
    name = col_name.lower()
    dtype = (col_type or "STRING").upper()

    if random.random() < 0.03 and "id" not in name:
        return None

    if "TIMESTAMP" in dtype:
        base = datetime(2023,1,1)
        ts = base + timedelta(days=random.randint(0,1100), hours=random.randint(0,23))
        if ("loaded" in name or "created" in name) and random.random() < 0.05:
            ts = datetime(2019,1,1) + timedelta(days=random.randint(0,365))
        return ts
    if dtype == "DATE":
        if "birth" in name: return date(2026-random.randint(18,78), random.randint(1,12), random.randint(1,28))
        return date(2023,1,1) + timedelta(days=random.randint(0,1100))
    if "DECIMAL" in dtype or "DOUBLE" in dtype or "FLOAT" in dtype:
        if any(k in name for k in ["amount","balance","value","exposure","revenue","cost","salary","fee"]):
            return round(random.uniform(500, 2000000), 2)
        if any(k in name for k in ["rate","margin","ratio","pct","probability"]):
            return round(random.uniform(0, 100), 4)
        if "score" in name: return round(random.uniform(0, 100), 2)
        return round(random.uniform(0, 99999), 2)
    if dtype == "INT" or dtype == "BIGINT":
        if "age" in name: return random.randint(18, 78)
        if "count" in name or "num" in name: return random.randint(0, 1000)
        if "score" in name: return random.randint(0, 100)
        if "year" in name: return random.randint(2019, 2026)
        if "days" in name: return random.randint(0, 365)
        if "duration" in name or "month" in name: return random.randint(1, 120)
        return random.randint(1, 9999)
    if dtype == "BOOLEAN":
        return random.choice([True, False])

    # STRING
    if "name" in name and "file" not in name:
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
    if "email" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"
    if "country" in name: return random.choice(COUNTRIES)
    if "currency" in name: return random.choice(CURRENCIES)
    if "segment" in name: return random.choice(CUSTOMER_SEGMENTS)
    if "channel" in name: return random.choice(CHANNELS)
    if "status" in name: return random.choice(STATUSES)
    if "risk" in name and ("band" in name or "level" in name or "rating" in name):
        return random.choice(RISK_LEVELS)
    if "product" in name and "type" in name: return random.choice(PRODUCT_TYPES)
    if "region" in name: return random.choice(["EMEA","APAC","Americas","Nordics"])
    if "business_line" in name: return random.choice(["Leasing","Commercial Finance","Consumer Finance","Mobility Solutions"])
    if "department" in name: return random.choice(["Sales","Finance","Risk","IT","HR","Operations"])
    if "domain" in name: return random.choice(["Product","Client","Risk management","Collateral","Finance"])
    if "entity" in name: return random.choice(["Masreph","Masreph Europe","Masreph AsiaPac","Masreph Americas"])
    if "consent" in name: return random.choice(["granted","withdrawn","pending"])
    if "model_version" in name or "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"
    if "source" in name: return random.choice(["TransactFinance","Salesforce","Mosaic Tech","ACTICO","Veriff"])
    if name.endswith("_id") or "identifier" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
    if any(k in name for k in ["description","comment","note","summary"]):
        return random.choice(["Standard financial product","Customer credit facility review","Leasing contract amendment","Payment processing record"])
    if "code" in name: return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"
    if "type" in name: return random.choice(["standard","premium","basic","enterprise"])
    return f"val_{random.randint(1000,9999)}"


def gen_gold_value(col_name, col_type, row_idx):
    """Generate gold-quality value (95%+ quality)."""
    name = col_name.lower()
    dtype = (col_type or "STRING").upper()

    if random.random() < 0.005 and "id" not in name and "date" not in name:
        return None

    if "TIMESTAMP" in dtype:
        return datetime(2026, 3, 17, 8, 0) - timedelta(hours=random.randint(0, 720))
    if dtype == "DATE":
        if "month" in name: return date(2025, random.randint(1,12), 1)
        return date(2025,1,1) + timedelta(days=row_idx % 365)
    if "DECIMAL" in dtype or "DOUBLE" in dtype or "FLOAT" in dtype:
        if any(k in name for k in ["amount","balance","value","exposure","revenue","cost","salary","margin","fee"]):
            return round(random.uniform(10000, 5000000), 2)
        if any(k in name for k in ["rate","pct","ratio","probability"]):
            return round(random.uniform(0, 30), 2)
        if "score" in name: return round(random.uniform(60, 99), 1)
        return round(random.uniform(0, 99999), 2)
    if dtype == "INT" or dtype == "BIGINT":
        if "count" in name or "num" in name: return random.randint(10, 5000)
        if "score" in name: return random.randint(60, 100)
        if "days" in name: return random.randint(0, 90)
        if "year" in name: return random.randint(1, 25)
        if "hour" in name: return random.randint(1, 48)
        return random.randint(1, 9999)
    if dtype == "BOOLEAN":
        return random.choice([True, False])

    # STRING
    if "name" in name: return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
    if "country" in name: return random.choice(COUNTRIES)
    if "segment" in name: return random.choice(CUSTOMER_SEGMENTS)
    if "channel" in name: return random.choice(CHANNELS)
    if "status" in name: return random.choice(STATUSES)
    if "risk" in name: return random.choice(RISK_LEVELS)
    if "product" in name: return random.choice(PRODUCT_TYPES)
    if "region" in name: return random.choice(["EMEA","APAC","Americas","Nordics"])
    if "business_line" in name: return random.choice(["Leasing","Commercial Finance","Consumer Finance"])
    if "department" in name: return random.choice(["Sales","Finance","Risk","IT","HR","Operations"])
    if "entity" in name: return random.choice(["Masreph","Masreph Europe","Masreph AsiaPac"])
    if "domain" in name: return random.choice(["Product","Client","Risk management","Finance"])
    if "source" in name: return random.choice(["TransactFinance","Salesforce","Mosaic Tech","ACTICO"])
    if "consent" in name: return random.choice(["granted","pending"])
    if "version" in name: return f"v{random.randint(3,5)}.{random.randint(0,9)}"
    if name.endswith("_id"): return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
    if "type" in name: return random.choice(["standard","premium","enterprise"])
    return f"val_{random.randint(1000,9999)}"


def populate_layer(layer, gen_func, max_rows_default):
    """Populate all tables in a layer."""
    logger.info(f"\n=== Populating {layer} layer ===")
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(f"SHOW TABLES IN {CATALOG}.{layer}")
    tables = [row[1] for row in cur.fetchall()]
    logger.info(f"Found {len(tables)} tables in {layer}")

    total_rows = 0
    for table in tables:
        try:
            cur.execute(f"DESCRIBE TABLE {CATALOG}.{layer}.{table}")
            columns = [(row[0], row[1]) for row in cur.fetchall() if not row[0].startswith("#")]
        except Exception:
            continue

        # Determine row count
        tname = table.lower()
        if layer == "gold":
            num_rows = random.randint(100, 365)
        elif any(k in tname for k in ["dim_","status","type","category","ref_","channel","segment"]):
            num_rows = random.randint(15, 50)
        elif any(k in tname for k in ["fact_","raw_","event","transaction","log","history"]):
            num_rows = random.randint(500, 1000)
        elif any(k in tname for k in ["customer","client","account","360"]):
            num_rows = random.randint(200, 500)
        else:
            num_rows = random.randint(50, 200)

        # Insert in batches of 50
        inserted = 0
        batch_size = 50
        for batch_start in range(0, num_rows, batch_size):
            batch_end = min(batch_start + batch_size, num_rows)
            values_list = []
            for i in range(batch_start, batch_end):
                row_vals = [escape_val(gen_func(c[0], c[1], i)) for c in columns]
                values_list.append(f"({', '.join(row_vals)})")

            insert_sql = f"INSERT INTO {CATALOG}.{layer}.{table} VALUES {', '.join(values_list)}"
            try:
                cur.execute(insert_sql)
                inserted += batch_end - batch_start
            except Exception:
                # Try individual rows
                for vals in values_list:
                    try:
                        cur.execute(f"INSERT INTO {CATALOG}.{layer}.{table} VALUES {vals}")
                        inserted += 1
                    except Exception:
                        pass

        total_rows += inserted
        if inserted > 0 and (tables.index(table) % 20 == 0 or inserted > 200):
            logger.info(f"  {layer}.{table}: {inserted} rows")

    conn.close()
    logger.info(f"  {layer} total: {total_rows} rows")
    return total_rows


def main():
    logger.info(f"=== Databricks Medallion: {CATALOG} ===")

    # Phase 1: Deploy silver tables
    silver_tables = deploy_silver()

    # Phase 2: Deploy gold tables
    gold_tables = deploy_gold()

    # Phase 3: Populate gold (smallest, fastest)
    gold_rows = populate_layer("gold", gen_gold_value, 200)

    # Phase 4: Populate silver
    silver_rows = populate_layer("silver", gen_silver_value, 300)

    total = gold_rows + silver_rows
    logger.info(f"\n=== DONE: Silver={silver_tables}t, Gold={gold_tables}t | {total} total rows ===")
    logger.info("(Bronze layer tables can be added later for raw/messy data demo)")


if __name__ == "__main__":
    main()
