#!/usr/bin/env python3
"""
Deploy Databricks with one schema per source system + gold schema.
Catalog: masreph_datalake (Unity Catalog)

Architecture:
  masreph_datalake.mosaic_tech       (source system schema)
  masreph_datalake.dataedo_crdm      (source system schema)
  masreph_datalake.infosphere_mdm    (source system schema)
  masreph_datalake.gold              (aggregated business tables)
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
SEGMENTS = ["mass_market","affluent","high_net_worth","sme","mid_corporate"]
PRODUCT_TYPES = ["auto_lease","equipment_lease","mortgage","personal_loan","business_loan"]


def get_connection():
    return sql.connect(server_hostname=DBX_HOST, http_path=DBX_HTTP_PATH, access_token=DBX_TOKEN)


def escape_val(v):
    if v is None: return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return str(v)
    if isinstance(v, (datetime, date)): return f"'{v}'"
    s = str(v).replace("'", "''").replace("\\", "\\\\")
    return f"'{s}'"


def gen_value(col_name, col_type, row_idx):
    name = col_name.lower()
    dtype = (col_type or "STRING").upper()

    if random.random() < 0.03 and "id" not in name: return None

    if "TIMESTAMP" in dtype:
        return datetime(2023,1,1) + timedelta(days=random.randint(0,1100), hours=random.randint(0,23))
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
    if dtype in ("INT","BIGINT"):
        if "age" in name: return random.randint(18, 78)
        if "count" in name or "num" in name: return random.randint(0, 1000)
        if "score" in name: return random.randint(0, 100)
        if "year" in name: return random.randint(2019, 2026)
        return random.randint(1, 9999)
    if dtype == "BOOLEAN": return random.choice([True, False])

    # STRING
    if "name" in name and "file" not in name:
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
    if "email" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"
    if "country" in name: return random.choice(COUNTRIES)
    if "currency" in name: return random.choice(CURRENCIES)
    if "segment" in name: return random.choice(SEGMENTS)
    if "channel" in name: return random.choice(CHANNELS)
    if "status" in name: return random.choice(STATUSES)
    if "risk" in name and ("band" in name or "level" in name or "rating" in name):
        return random.choice(RISK_LEVELS)
    if "product" in name and "type" in name: return random.choice(PRODUCT_TYPES)
    if "region" in name: return random.choice(["EMEA","APAC","Americas","Nordics"])
    if "business_line" in name: return random.choice(["Leasing","Commercial Finance","Consumer Finance"])
    if "department" in name: return random.choice(["Sales","Finance","Risk","IT","HR","Operations"])
    if "entity" in name: return random.choice(["Masreph","Masreph Europe","Masreph AsiaPac"])
    if "consent" in name: return random.choice(["granted","withdrawn","pending"])
    if "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"
    if "source" in name: return random.choice(["TransactFinance","Salesforce","Mosaic Tech","ACTICO"])
    if name.endswith("_id") or "identifier" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
    if "type" in name: return random.choice(["standard","premium","basic","enterprise"])
    if any(k in name for k in ["description","comment","note","summary"]):
        return "Standard financial product record"
    if "code" in name: return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"
    return f"val_{random.randint(1000,9999)}"


def determine_rows(table_name):
    name = table_name.lower()
    if any(k in name for k in ["dim_","status","type","category","ref_","channel","segment"]):
        return random.randint(15, 50)
    if any(k in name for k in ["fact_","raw_","event","transaction","log","history"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["customer","client","account","360"]):
        return random.randint(200, 500)
    return random.randint(50, 200)


def main():
    logger.info(f"=== Databricks: Schema per Source System in {CATALOG} ===")
    conn = get_connection()
    cur = conn.cursor()
    cur.execute(f"USE CATALOG {CATALOG}")

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    # Phase 1: Create schemas and tables
    logger.info("\n=== Phase 1: Deploy schemas and tables ===")
    total_tables = 0

    for filepath in sql_files:
        fname = filepath.stem
        # Clean schema name: remove prefixes like "silver_"
        schema_name = fname.replace("silver_", "").replace("silver", "").strip("_")
        if not schema_name:
            schema_name = "general"

        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        # Create schema
        try:
            cur.execute(f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.{schema_name}")
        except Exception:
            pass

        created = 0
        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt: continue
            upper = stmt.upper()

            if "CREATE SCHEMA" in upper: continue
            if "CREATE TABLE" in upper:
                # Redirect to our schema
                modified = re.sub(r'CREATE TABLE IF NOT EXISTS\s+\S+\.', f'CREATE TABLE IF NOT EXISTS {CATALOG}.{schema_name}.', stmt)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', modified)
                try:
                    cur.execute(modified)
                    created += 1
                except Exception:
                    pass

        if created > 0:
            total_tables += created
            logger.info(f"  {schema_name}: {created} tables")

    # Create gold schema
    cur.execute(f"CREATE SCHEMA IF NOT EXISTS {CATALOG}.gold")
    gold_ddls = [
        f"CREATE TABLE IF NOT EXISTS {CATALOG}.gold.customer_360 (customer_id STRING, masreph_client_id STRING, customer_name STRING, country_code STRING, segment STRING, relationship_start_date DATE, total_products INT, total_outstanding_balance DECIMAL(18,2), average_credit_score INT, risk_band STRING, churn_probability DECIMAL(5,4), lifetime_value_eur DECIMAL(18,2), last_interaction_date DATE, preferred_channel STRING, gdpr_consent_status STRING, _aggregated_at TIMESTAMP)",
        f"CREATE TABLE IF NOT EXISTS {CATALOG}.gold.portfolio_performance_daily (report_date DATE, business_line STRING, region STRING, product_type STRING, active_contracts INT, total_exposure_eur DECIMAL(18,2), avg_interest_rate DECIMAL(5,4), delinquency_rate_pct DECIMAL(5,2), new_originations INT, net_interest_margin_pct DECIMAL(5,4), _aggregated_at TIMESTAMP)",
        f"CREATE TABLE IF NOT EXISTS {CATALOG}.gold.risk_scoring_features (customer_id STRING, scoring_date DATE, pd_12m DECIMAL(8,6), lgd_pct DECIMAL(5,2), ead_eur DECIMAL(18,2), expected_loss_eur DECIMAL(18,2), days_past_due INT, number_of_products INT, digital_engagement_score INT, model_version STRING, _scored_at TIMESTAMP)",
        f"CREATE TABLE IF NOT EXISTS {CATALOG}.gold.compliance_dashboard (report_date DATE, entity STRING, region STRING, total_screenings INT, matches_found INT, false_positives INT, confirmed_hits INT, avg_resolution_time_hours DECIMAL(8,2), kyc_completion_rate_pct DECIMAL(5,2), _aggregated_at TIMESTAMP)",
        f"CREATE TABLE IF NOT EXISTS {CATALOG}.gold.data_quality_scorecard (assessment_date DATE, source_system STRING, domain STRING, table_name STRING, total_records INT, completeness_pct DECIMAL(5,2), accuracy_pct DECIMAL(5,2), overall_quality_score DECIMAL(5,2), issues_found INT, _aggregated_at TIMESTAMP)",
    ]
    gold_count = 0
    for ddl in gold_ddls:
        try:
            cur.execute(ddl)
            gold_count += 1
        except: pass
    logger.info(f"  gold: {gold_count} tables")
    total_tables += gold_count

    logger.info(f"\nPhase 1 complete: {total_tables} tables")

    # Phase 2: Generate data
    logger.info("\n=== Phase 2: Generate data ===")
    cur.execute(f"SHOW SCHEMAS IN {CATALOG}")
    schemas = [r[0] for r in cur.fetchall() if r[0] not in ('default','information_schema')]

    grand_total = 0
    for schema in schemas:
        cur.execute(f"SHOW TABLES IN {CATALOG}.{schema}")
        tables = [r[1] for r in cur.fetchall()]
        if not tables: continue

        schema_total = 0
        for table in tables:
            try:
                cur.execute(f"DESCRIBE TABLE {CATALOG}.{schema}.{table}")
                columns = [(r[0], r[1]) for r in cur.fetchall() if not r[0].startswith("#")]
            except: continue

            num_rows = determine_rows(table) if schema != "gold" else random.randint(100, 365)

            # Insert in batches
            batch_size = 50
            inserted = 0
            for bs in range(0, num_rows, batch_size):
                be = min(bs + batch_size, num_rows)
                values_list = []
                for i in range(bs, be):
                    row_vals = [escape_val(gen_value(c[0], c[1], i)) for c in columns]
                    values_list.append(f"({', '.join(row_vals)})")

                try:
                    cur.execute(f"INSERT INTO {CATALOG}.{schema}.{table} VALUES {', '.join(values_list)}")
                    inserted += be - bs
                except:
                    for vals in values_list:
                        try:
                            cur.execute(f"INSERT INTO {CATALOG}.{schema}.{table} VALUES {vals}")
                            inserted += 1
                        except: pass

            schema_total += inserted

        grand_total += schema_total
        logger.info(f"  {schema}: {len(tables)} tables, {schema_total} rows")

    conn.close()
    logger.info(f"\n=== DONE: {total_tables} tables, {grand_total} rows ===")


if __name__ == "__main__":
    main()
