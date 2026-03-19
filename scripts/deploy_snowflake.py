#!/usr/bin/env python3
"""
Deploy Snowflake DDL and generate realistic sample data.
Creates: MASREPH_RISK_ANALYTICS database with schemas per source system.

Snowflake quality profile: 78-86% (analytics warehouse, 2 years old)
- Stale data (loaded daily, not real-time)
- Some records missing from failed batch loads
- Dimension tables with "Unknown" catch-all records
- Historical data with NULL dimension keys
"""

import os
import re
import json
import random
import string
import snowflake.connector
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "snowflake")
DB_NAME = "MASREPH_RISK_ANALYTICS"

SF_ACCOUNT = "ittrelv-xu20591"
SF_USER = "hzmarrou"
SF_PASSWORD = "os.getenv('SNOWFLAKE_PASSWORD')"
SF_WAREHOUSE = "COMPUTE_WH"

# Quality
Q_NULL = 0.04  # Higher nulls - warehouse data often has gaps
Q_STALE = 0.08  # 8% stale records (ETL lag)
Q_UNKNOWN_DIM = 0.05  # 5% of FK refs point to "Unknown" dimension record

# Data pools
FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Daan","Emma",
    "Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte","Ahmed","Fatima",
    "James","Sarah","Robert","Emily","Carlos","Isabella","Hans","Greta","Pedro","Ana"]
LAST_NAMES = ["van den Berg","de Jong","Jansen","de Vries","van Dijk","Bakker","Visser",
    "Smit","Meijer","de Boer","Muller","Schmidt","Schneider","Smith","Johnson",
    "Williams","Brown","Garcia","Martinez","Chen","Wang","Patel","Sharma","Dubois"]
DIACRITICS = ["M\u00fcller","Bj\u00f6rk","Ren\u00e9e","Fran\u00e7ois","Jos\u00e9","S\u00f8ren"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["ACTIVE","INACTIVE","PENDING","SUSPENDED","CLOSED"]
RISK_LEVELS = ["LOW","MEDIUM","HIGH","CRITICAL"]
RISK_BANDS = ["AAA","AA","A","BBB","BB","B","CCC","CC","C","D"]
CHANNELS = ["WEB_PORTAL","MOBILE_APP","BRANCH","PHONE","EMAIL","API","CHATBOT"]
INDUSTRIES = ["FINANCIAL_SERVICES","MANUFACTURING","RETAIL","HEALTHCARE","TECHNOLOGY","REAL_ESTATE","AUTOMOTIVE"]
DEPARTMENTS = ["SALES","FINANCE","RISK_MANAGEMENT","OPERATIONS","IT","LEGAL","COMPLIANCE","HR"]
CITIES = ["AMSTERDAM","ROTTERDAM","BERLIN","MUNICH","PARIS","LONDON","NEW_YORK","SINGAPORE","TOKYO"]
SCREENING_RESULTS = ["CLEAR","POTENTIAL_MATCH","CONFIRMED_MATCH","FALSE_POSITIVE","PENDING_REVIEW"]
VERIFICATION_STATUSES = ["VERIFIED","UNVERIFIED","EXPIRED","PENDING","REJECTED"]
COMPLIANCE_STATUSES = ["COMPLIANT","NON_COMPLIANT","UNDER_REVIEW","REMEDIATION_REQUIRED"]
CUSTOMER_SEGMENTS = ["MASS_MARKET","AFFLUENT","HIGH_NET_WORTH","SME","MID_CORPORATE","INSTITUTIONAL"]
PRODUCT_TYPES = ["AUTO_LEASE","EQUIPMENT_LEASE","MORTGAGE","PERSONAL_LOAN","BUSINESS_LOAN","CREDIT_CARD"]
LANGUAGES = ["NL","EN","DE","FR","ES","IT","PT","JA"]
PRODUCT_NAMES = ["MASREPH AUTO LEASE PLUS","MASREPH FLEET PRO","MASREPH HOME FINANCE",
    "MASREPH BUSINESS CREDIT 360","MASREPH SAVINGS SMART","MASREPH EQUIPMENT LEASE FLEX"]


def get_connection(database=None):
    params = {"account": SF_ACCOUNT, "user": SF_USER, "password": SF_PASSWORD, "warehouse": SF_WAREHOUSE}
    if database:
        params["database"] = database
    return snowflake.connector.connect(**params)


# ─── PHASE 1: DEPLOY DDL ────────────────────────────────────────────────────

def deploy_ddl():
    logger.info("=== Phase 1: Deploying Snowflake DDL ===")
    conn = get_connection()
    cur = conn.cursor()

    cur.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
    cur.execute(f"USE DATABASE {DB_NAME}")
    cur.execute(f"USE WAREHOUSE {SF_WAREHOUSE}")
    logger.info(f"Created database: {DB_NAME}")

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    total_created = 0
    total_errors = 0
    all_fk_stmts = []

    for filepath in sql_files:
        fname = filepath.stem
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        created = errors = 0
        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt:
                continue
            stmt_upper = stmt.upper()

            try:
                if "CREATE SCHEMA" in stmt_upper:
                    cur.execute(stmt + ";")
                elif "CREATE TABLE" in stmt_upper:
                    cur.execute(stmt + ";")
                    created += 1
                elif "ALTER TABLE" in stmt_upper and "FOREIGN KEY" in stmt_upper:
                    all_fk_stmts.append(stmt + ";")
                elif "CREATE INDEX" in stmt_upper:
                    pass  # Snowflake doesn't support explicit indexes
            except Exception as e:
                err_msg = str(e)
                if "already exists" in err_msg.lower():
                    pass
                else:
                    errors += 1
                    if errors <= 2:
                        logger.warning(f"    {fname}: {err_msg[:80]}")

        total_created += created
        total_errors += errors
        if created > 0:
            logger.info(f"  {fname}: {created} tables")

    # FKs - Snowflake supports them but doesn't enforce them (informational only)
    fk_ok = 0
    for stmt in all_fk_stmts:
        try:
            cur.execute(stmt)
            fk_ok += 1
        except Exception:
            pass

    logger.info(f"\nPhase 1 complete: {total_created} tables, {fk_ok} FKs (informational)")

    # Verify
    cur.execute(f"SELECT TABLE_SCHEMA, COUNT(*) FROM {DB_NAME}.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' GROUP BY TABLE_SCHEMA ORDER BY COUNT(*) DESC")
    logger.info("\n=== Schemas ===")
    total_tables = 0
    for r in cur.fetchall():
        logger.info(f"  {r[0]}: {r[1]} tables")
        total_tables += r[1]
    logger.info(f"  TOTAL: {total_tables} tables")

    conn.close()
    return total_tables


# ─── PHASE 2: GENERATE DATA ─────────────────────────────────────────────────

def determine_row_count(table_name, columns, fk_count):
    name = table_name.upper()
    if name.startswith("DIM_") or any(k in name for k in ["STATUS","TYPE","CATEGORY","CHANNEL",
            "SEGMENT","GRADE","REGION","CURRENCY","COUNTRY","FREQUENCY","DIRECTION",
            "PRIORITY","SEVERITY","OUTCOME","RATING"]):
        return random.randint(15, 50)
    if name.startswith("FACT_") or any(k in name for k in ["TRANSACTION","EVENT","LOG",
            "HISTORY","AUDIT","ACTIVITY","SCREENING","VERIFICATION","ASSESSMENT","SCORE"]):
        return random.randint(500, 1000)
    if name.startswith("STG_"):
        return random.randint(200, 500)
    if any(k in name for k in ["METRIC","ANALYTICS","INSIGHT","PERFORMANCE","SNAPSHOT","REPORT"]):
        return random.randint(300, 700)
    if any(k in name for k in ["CUSTOMER","CLIENT","CONTACT","PERSON","ACCOUNT","PARTNER","PROSPECT"]):
        return random.randint(200, 500)
    if any(k in name for k in ["PRODUCT","SERVICE","PLAN","OFFER","CONTRACT","AGREEMENT"]):
        return random.randint(100, 300)
    if fk_count >= 2:
        return random.randint(300, 800)
    if len(columns) <= 5:
        return random.randint(20, 60)
    return random.randint(100, 300)


def generate_value(col, row_idx, fk_ids, pk_cols):
    name = col["name"].upper()
    dtype = col["type"].upper()
    nullable = col["nullable"]

    if nullable and name not in [p.upper() for p in pk_cols] and random.random() < Q_NULL:
        return None
    if name.lower() in fk_ids and fk_ids[name.lower()]:
        return random.choice(fk_ids[name.lower()])

    # PK
    if name in [p.upper() for p in pk_cols]:
        if "NUMBER" in dtype or "INT" in dtype:
            return row_idx + 1
        if "VARCHAR" in dtype:
            return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
        return row_idx + 1

    # BOOLEAN
    if dtype == "BOOLEAN":
        if "ACTIVE" in name or "ENABLED" in name: return random.random() < 0.85
        if "CONSENT" in name: return random.random() < 0.70
        if "FLAG" in name and ("RISK" in name or "FRAUD" in name or "PEP" in name or "SANCTION" in name):
            return random.random() < 0.03
        if "MATCH" in name: return random.random() < 0.15
        return random.choice([True, False])

    # NUMBER (integer or decimal)
    if "NUMBER" in dtype:
        # Parse precision/scale from type like NUMBER(18,0) or NUMBER(18,4)
        m = re.match(r'NUMBER\((\d+),(\d+)\)', dtype)
        if m:
            prec, sc = int(m.group(1)), int(m.group(2))
        else:
            prec, sc = 18, 0

        if sc == 0:  # Integer
            if "AGE" in name: return random.randint(18, 78)
            if "YEAR" in name: return random.randint(2019, 2026)
            if "MONTH" in name: return random.randint(1, 12)
            if "QUARTER" in name: return random.randint(1, 4)
            if "HOUSEHOLD" in name: return random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0]
            if "SCORE" in name or "RATING" in name:
                if "CREDIT" in name: return random.randint(300, 850)
                if "NPS" in name: return random.randint(-100, 100)
                return random.randint(0, 100)
            if "COUNT" in name or "QUANTITY" in name or "NUM" in name: return random.randint(0, 1000)
            if "DURATION" in name: return random.randint(1, 120)
            if "KEY" in name: return row_idx + 1
            return random.randint(1, 99999)
        else:  # Decimal
            mx = min(10**(prec-sc)-1, 9999999)
            if any(k in name for k in ["AMOUNT","BALANCE","TOTAL","PRICE","VALUE","REVENUE","COST","FEE","PAYMENT","INCOME","EXPOSURE"]):
                return round(random.uniform(500, min(mx, 2000000)), min(sc, 2))
            if any(k in name for k in ["RATE","INTEREST","MARGIN","SPREAD"]):
                return round(random.uniform(0.5, 15.0), min(sc, 4))
            if any(k in name for k in ["PERCENTAGE","PCT","RATIO","PROBABILITY"]):
                return round(random.uniform(0, min(mx, 100)), min(sc, 2))
            if "SCORE" in name: return round(random.uniform(0, min(mx, 100)), min(sc, 2))
            return round(random.uniform(0, min(mx, 99999)), min(sc, 2))

    # DATE
    if dtype == "DATE":
        if "BIRTH" in name: return date(2026-random.randint(18,78), random.randint(1,12), random.randint(1,28))
        if "START" in name or "EFFECTIVE" in name: return date(2022,1,1)+timedelta(days=random.randint(0,1000))
        if "END" in name or "EXPIR" in name: return date(2025,1,1)+timedelta(days=random.randint(0,1500))
        if "SCREENING" in name or "VERIFICATION" in name: return date(2024,1,1)+timedelta(days=random.randint(0,700))
        if "LOADED" in name or "ETL" in name:
            # Quality: stale load dates
            if random.random() < Q_STALE:
                return date(2025,1,1)+timedelta(days=random.randint(-365, -30))
            return date(2026,3,1)+timedelta(days=random.randint(-30, 0))
        return date(2023,1,1)+timedelta(days=random.randint(0,1100))

    # TIMESTAMP
    if "TIMESTAMP" in dtype:
        base = datetime(2023,1,1)
        ts = base + timedelta(days=random.randint(0,1100), hours=random.randint(0,23), minutes=random.randint(0,59))
        if ("CREATED" in name or "LOADED" in name) and random.random() < Q_STALE:
            ts = datetime(2024,6,1) + timedelta(days=random.randint(-365, 0))
        return ts

    # VARIANT (JSON-like)
    if dtype == "VARIANT":
        if "TAG" in name: return json.dumps(random.sample(["FINANCE","RISK","COMPLIANCE","AML","KYC"],k=random.randint(1,3)))
        if "CONFIG" in name: return json.dumps({"THRESHOLD": round(random.uniform(0.5,0.99),2), "MODEL_VERSION": f"v{random.randint(1,3)}.{random.randint(0,9)}"})
        if "METADATA" in name: return json.dumps({"SOURCE": random.choice(["SANCTION_SCANNER","ACTICO","VERIFF"]), "BATCH_ID": random.randint(1000,9999)})
        return json.dumps({"KEY": f"VALUE_{random.randint(1,999)}"})

    # VARCHAR
    if "VARCHAR" in dtype or "TEXT" in dtype or "STRING" in dtype:
        return _gen_sf_text(name)

    return f"VAL_{row_idx}"


def _gen_sf_text(name):
    # Names (UPPERCASE for Snowflake)
    if any(k in name for k in ["FIRST_NAME","FIRSTNAME","GIVEN_NAME"]):
        n = random.choice(FIRST_NAMES).upper()
        if random.random() < 0.03: n = random.choice(DIACRITICS).upper()
        return n
    if any(k in name for k in ["LAST_NAME","LASTNAME","SURNAME","FAMILY"]):
        return random.choice(LAST_NAMES).upper()
    if any(k in name for k in ["FULL_NAME","CUSTOMER_NAME","CLIENT_NAME","ENTITY_NAME"]):
        return f"{random.choice(FIRST_NAMES).upper()} {random.choice(LAST_NAMES).upper()}"
    if "NAME" in name and not any(k in name for k in ["FILE","TABLE","COLUMN","SCHEMA"]):
        if any(k in name for k in ["PRODUCT","SERVICE","CAMPAIGN"]): return random.choice(PRODUCT_NAMES)
        return f"{random.choice(FIRST_NAMES).upper()} {random.choice(LAST_NAMES).upper()}"
    # Email
    if "EMAIL" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"
    # Phone
    if "PHONE" in name or "MOBILE" in name:
        return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"
    # Country
    if "COUNTRY" in name: return random.choice(COUNTRIES)
    if "CITY" in name: return random.choice(CITIES)
    if "CURRENCY" in name: return random.choice(CURRENCIES)
    if "LANGUAGE" in name: return random.choice(LANGUAGES)
    # Gender
    if "GENDER" in name: return random.choices(GENDER_CODES, weights=[48,48,4])[0]
    # Screening/compliance specific
    if "SCREENING_RESULT" in name or "MATCH_STATUS" in name: return random.choice(SCREENING_RESULTS)
    if "VERIFICATION_STATUS" in name: return random.choice(VERIFICATION_STATUSES)
    if "COMPLIANCE_STATUS" in name: return random.choice(COMPLIANCE_STATUSES)
    # Risk
    if "RISK" in name and any(k in name for k in ["LEVEL","RATING","CATEGORY","BAND","GRADE"]):
        return random.choice(RISK_LEVELS)
    if "RISK_BAND" in name or "CREDIT_RATING" in name: return random.choice(RISK_BANDS)
    # Status
    if "STATUS" in name or "STATE" in name: return random.choice(STATUSES)
    # Segment
    if "SEGMENT" in name: return random.choice(CUSTOMER_SEGMENTS)
    # Channel
    if "CHANNEL" in name or ("SOURCE" in name and "SYSTEM" not in name): return random.choice(CHANNELS)
    # Industry
    if "INDUSTRY" in name or "SECTOR" in name: return random.choice(INDUSTRIES)
    # Department
    if "DEPARTMENT" in name: return random.choice(DEPARTMENTS)
    # Product
    if "PRODUCT_TYPE" in name: return random.choice(PRODUCT_TYPES)
    if "PRODUCT" in name and "CODE" in name: return f"PRD-{random.randint(1000,9999)}"
    # Description
    if any(k in name for k in ["DESCRIPTION","DESC","COMMENT","NOTE","REASON","SUMMARY"]):
        return random.choice([
            "AUTOMATED RISK SCREENING - STANDARD PROCEDURE",
            "COMPLIANCE CHECK TRIGGERED BY TRANSACTION THRESHOLD",
            "PERIODIC KYC REVIEW - REGULATORY REQUIREMENT",
            "SANCTION LIST SCREENING - BATCH PROCESS",
            "IDENTITY VERIFICATION - CUSTOMER ONBOARDING",
        ])
    # Code
    if "CODE" in name:
        if "COUNTRY" in name: return random.choice(COUNTRIES)
        if "CURRENCY" in name: return random.choice(CURRENCIES)
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"
    # ID-like
    if name.endswith("_ID") or "IDENTIFIER" in name or "REF" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
    # Type
    if "TYPE" in name: return random.choice(["STANDARD","PREMIUM","BASIC","ENTERPRISE","CUSTOM"])
    # Generic
    return f"MASREPH_{random.randint(1000,9999)}"


def generate_data():
    logger.info("\n=== Phase 2: Generating Snowflake Data ===")
    conn = get_connection(DB_NAME)
    cur = conn.cursor()
    cur.execute(f"USE WAREHOUSE {SF_WAREHOUSE}")

    # Get all schemas
    cur.execute(f"SELECT SCHEMA_NAME FROM {DB_NAME}.INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME NOT IN ('INFORMATION_SCHEMA','PUBLIC')")
    schemas = [r[0] for r in cur.fetchall()]
    logger.info(f"Found {len(schemas)} schemas")

    grand_total = 0
    for schema in schemas:
        # Get tables in schema
        cur.execute(f"""
            SELECT TABLE_NAME FROM {DB_NAME}.INFORMATION_SCHEMA.TABLES
            WHERE TABLE_SCHEMA='{schema}' AND TABLE_TYPE='BASE TABLE'
        """)
        tables = [r[0] for r in cur.fetchall()]
        if not tables:
            continue

        schema_total = 0
        # Get metadata per table
        table_meta = []
        for table in tables:
            cur.execute(f"""
                SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
                FROM {DB_NAME}.INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA='{schema}' AND TABLE_NAME='{table}'
                ORDER BY ORDINAL_POSITION
            """)
            columns = [{"name":r[0], "type":r[1], "nullable":r[2]=="YES"} for r in cur.fetchall()]

            # Simple FK detection from column names ending in _KEY or _ID that match DIM_ tables
            fk_count = sum(1 for c in columns if c["name"].endswith("_KEY") and c["name"] != table.replace("FACT_","").replace("DIM_","") + "_KEY")

            pk_cols = [columns[0]["name"]] if columns else []  # Assume first column is PK

            table_meta.append({
                "name": table, "columns": columns, "pk_cols": pk_cols,
                "fk_count": fk_count,
                "num_rows": determine_row_count(table, columns, fk_count),
                "is_dim": table.startswith("DIM_") or len(columns) <= 6,
            })

        # Sort: DIM tables first, then FACT
        table_meta.sort(key=lambda t: (0 if t["is_dim"] else 1, t["fk_count"]))

        # Build FK ID lookup: for _KEY columns, find matching DIM_ table PKs
        dim_ids = {}
        for tm in table_meta:
            if tm["is_dim"] and tm["columns"]:
                pk = tm["columns"][0]["name"]
                dim_ids[pk] = None  # Will be filled after insert

        for tm in table_meta:
            fk_ids = {}
            for col in tm["columns"]:
                cname = col["name"].lower()
                # Look for matching dim table IDs
                if cname.endswith("_key") and cname.upper() in dim_ids and dim_ids[cname.upper()]:
                    fk_ids[cname] = dim_ids[cname.upper()]
                elif cname.endswith("_id"):
                    # Try to find parent table
                    for other_tm in table_meta:
                        if other_tm["columns"] and other_tm["columns"][0]["name"].lower() == cname:
                            ids = dim_ids.get(other_tm["columns"][0]["name"])
                            if ids:
                                fk_ids[cname] = ids
                            break

            # Generate rows
            if not tm["columns"]:
                continue

            col_names = [c["name"] for c in tm["columns"]]
            placeholders = ", ".join(["%s"] * len(tm["columns"]))
            insert_sql = f"INSERT INTO {schema}.{tm['name']} ({', '.join(col_names)}) VALUES ({placeholders})"

            rows = []
            for i in range(tm["num_rows"]):
                rows.append(tuple(generate_value(c, i, fk_ids, tm["pk_cols"]) for c in tm["columns"]))

            try:
                cur.executemany(insert_sql, rows)
                schema_total += len(rows)

                # Store PK values for FK resolution
                pk_name = tm["columns"][0]["name"]
                if pk_name in dim_ids:
                    dim_ids[pk_name] = [r[0] for r in rows]
            except Exception as e:
                # Try individual inserts
                ok = 0
                for row in rows:
                    try:
                        cur.execute(insert_sql, row)
                        ok += 1
                    except Exception:
                        pass
                schema_total += ok
                if ok > 0 and tm["columns"][0]["name"] in dim_ids:
                    dim_ids[tm["columns"][0]["name"]] = list(range(1, ok+1))

        logger.info(f"  {schema}: {len(tables)} tables, {schema_total} rows")
        grand_total += schema_total

    conn.close()
    logger.info(f"\n=== Snowflake Data Complete: {grand_total} total rows ===")
    return grand_total


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== Snowflake: MASREPH_RISK_ANALYTICS ===")
    table_count = deploy_ddl()
    total_rows = generate_data()
    logger.info(f"\n=== DONE: {table_count} tables, {total_rows} rows in {DB_NAME} ===")


if __name__ == "__main__":
    main()
