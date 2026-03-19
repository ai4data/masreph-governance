#!/usr/bin/env python3
"""
Generate data for all 8 platforms using shared master entities.
Same 500 customers appear across platforms with platform-specific formats.

Key: Column name matching determines which master entity data to use.
"""

import os
import json
import random
import string
import re
import logging
from datetime import datetime, date, timedelta
try:
    from dotenv import load_dotenv
except Exception:
    def load_dotenv(*args, **kwargs):
        return False

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")

# Load master entities
with open(os.path.join(BASE_DIR, "config", "master_entities.json")) as f:
    MASTER = json.load(f)

CUSTOMERS = MASTER["customers"]
PRODUCTS = MASTER["products"]
CONTRACTS = MASTER["contracts"]
EMPLOYEES = MASTER["employees"]
COUNTRIES_REF = MASTER["countries"]
CURRENCIES_REF = MASTER["currencies"]

# Platform connection configs
PLATFORMS = {
    "sql-server": {"type": "pyodbc", "conn": "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;Trusted_Connection=yes;"},
    "postgresql": {"type": "psycopg2", "host": "aws-1-eu-west-2.pooler.supabase.com", "port": 5432, "database": "postgres", "user": "postgres.rlphlmkddecuptbklqeh", "password": "os.getenv('SUPABASE_CORE_PASSWORD')"},
    "mysql": {"type": "mysql", "host": "localhost", "port": 3306, "user": "root", "password": "os.getenv('MYSQL_PASSWORD')"},
    "snowflake": {"type": "snowflake", "account": "ittrelv-xu20591", "user": "hzmarrou", "password": "os.getenv('SNOWFLAKE_PASSWORD')", "warehouse": "COMPUTE_WH", "database": "MASREPH_RISK_ANALYTICS"},
    "oracle": {"type": "oracledb", "user": "ADMIN", "password": "os.getenv('ORACLE_PASSWORD')", "dsn": "masrephdb_low"},
    "mongodb": {"type": "pymongo", "uri": "mongodb+srv://hzmarrou:{pwd}@masrephapi.c2lbreb.mongodb.net/"},
    "databricks": {"type": "databricks", "host": "adb-7405617014831513.13.azuredatabricks.net", "http_path": "/sql/1.0/warehouses/b3bee97b5042372c", "token": "os.getenv('DATABRICKS_TOKEN')"},
    "fabric": {"type": "fabric", "server": "bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com", "database": "MasrephCorporateBI_WH"},
}


# ─── COLUMN-TO-ENTITY MAPPING ───────────────────────────────────────────────

def classify_column(col_name):
    """Determine what master entity data a column should use."""
    n = col_name.lower()

    # Customer fields
    if any(k in n for k in ["customer_id", "customerid", "client_id", "clientid", "cust_id", "custid", "borrower_id", "lessee_id", "masreph_client", "masreph_customer"]):
        return "customer_id"
    if any(k in n for k in ["customer_name", "customername", "client_name", "clientname", "full_name", "fullname", "cust_nm", "lessee_name", "borrower_name"]):
        return "customer_name"
    if "email" in n and "flag" not in n and "opt" not in n and "bounce" not in n:
        return "email"
    if ("phone" in n or "mobile" in n or "tel" in n) and "flag" not in n:
        return "phone"
    if "iban" in n:
        return "iban"
    if "gender" in n or "gndr" in n:
        return "gender"
    if ("date_of_birth" in n or "dob" in n or "birth" in n) and "place" not in n:
        return "dob"
    if n in ("age", "age_years") or n.endswith("_age"):
        return "age"
    if "country" in n and ("code" in n or "cd" in n or "iso" in n or n.endswith("country")):
        return "country_code"
    if "segment" in n and ("customer" in n or "client" in n or n == "segment"):
        return "segment"
    if "risk" in n and ("band" in n or "rating" in n or "grade" in n or "level" in n):
        return "risk_band"
    if "household" in n and "size" in n:
        return "household_size"
    if "marital" in n:
        return "marital_status"
    if "employment" in n and "status" in n:
        return "employment_status"
    if any(k in n for k in ["annual_income", "income_eur", "gross_income"]):
        return "income"
    if "net_worth" in n:
        return "net_worth"
    if "relationship_start" in n or "rel_start" in n:
        return "relationship_start"
    if "gdpr" in n and "consent" in n:
        return "gdpr_consent"
    if "pep" in n and "flag" not in n:
        return "is_pep"
    if "channel" in n and "prefer" in n:
        return "preferred_channel"

    # Product fields
    if any(k in n for k in ["product_code", "productcode", "prod_cd", "product_id", "productid"]):
        return "product_code"
    if any(k in n for k in ["product_name", "productname", "prod_nm"]):
        return "product_name"
    if any(k in n for k in ["product_type", "producttype", "prod_typ"]):
        return "product_type"
    if any(k in n for k in ["interest_rate", "interestrate", "int_rt"]) and "type" not in n:
        return "interest_rate"

    # Contract fields
    if any(k in n for k in ["contract_id", "contractid", "cntrct_id", "lease_contract", "agreement_id"]):
        return "contract_id"
    if "start_date" in n and ("contract" in n or "lease" in n or "agreement" in n or n == "start_date"):
        return "contract_start"
    if "end_date" in n and ("contract" in n or "lease" in n or "agreement" in n or n == "end_date"):
        return "contract_end"
    if any(k in n for k in ["outstanding_balance", "outstanding_amt", "balance_eur"]):
        return "outstanding_balance"
    if any(k in n for k in ["contract_status", "contractstatus", "cntrct_stat", "lease_status"]):
        return "contract_status"
    if "monthly_payment" in n or "installment" in n:
        return "monthly_payment"

    # Currency
    if "currency" in n and ("code" in n or "cd" in n or n.endswith("currency")):
        return "currency"

    # Company fields (for entity customers)
    if any(k in n for k in ["company_name", "companyname", "legal_name", "legalname", "entity_name", "trade_name"]):
        return "company_name"
    if "lei" in n:
        return "lei"
    if "kvk" in n or "chamber" in n:
        return "kvk"
    if "industry" in n or "sector" in n or "indstry" in n:
        return "industry"

    return None  # No match — generate generic value


def get_entity_value(field_type, customer, product, contract, platform):
    """Get the value for a classified field from the appropriate entity."""
    p = platform

    if field_type == "customer_id":
        return customer["platform_ids"].get(p.replace("-", "_"), customer["master_id"])
    if field_type == "customer_name":
        names = customer["platform_names"].get(p.replace("-", "_"), customer.get("full_name", customer.get("company_name", "")))
        # Apply FD violation if flagged
        qi = customer.get("quality_issues", {})
        if qi.get("fd_violation_name") and random.random() < 0.3:
            return qi["fd_violation_name"]
        return names if isinstance(names, str) else json.dumps(names)
    if field_type == "email":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_pattern_email") and random.random() < 0.5:
            return qi["domain_pattern_email"]
        if qi.get("stale_email") and random.random() < 0.3:
            return qi["stale_email"]
        return customer.get("email", customer.get("contact_email", ""))
    if field_type == "phone":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_pattern_phone") and random.random() < 0.3:
            return qi["domain_pattern_phone"]
        return customer.get("phone", "")
    if field_type == "iban":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_pattern_iban") and random.random() < 0.3:
            return qi["domain_pattern_iban"]
        return customer.get("iban", "")
    if field_type == "gender":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_list_gender") and random.random() < 0.5:
            return qi["domain_list_gender"]
        return customer.get("gender", "M")
    if field_type == "dob":
        qi = customer.get("quality_issues", {})
        if qi.get("custom_future_dob"):
            return qi["custom_future_dob"]
        return customer.get("date_of_birth", "1990-01-01")
    if field_type == "age":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_range_age"):
            return qi["domain_range_age"]
        return customer.get("age", 35)
    if field_type == "country_code":
        qi = customer.get("quality_issues", {})
        cc = customer.get("country_code", "NL")
        if p == "snowflake" and qi.get("wrong_country_in_snowflake"):
            return qi["wrong_country_in_snowflake"]
        return cc
    if field_type == "segment":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_list_segment") and random.random() < 0.5:
            return qi["domain_list_segment"]
        return customer.get("segment", "mass_market")
    if field_type == "risk_band":
        return customer.get("risk_band", "BBB")
    if field_type == "household_size":
        return customer.get("household_size", 2)
    if field_type == "marital_status":
        return customer.get("marital_status", "single")
    if field_type == "employment_status":
        return customer.get("employment_status", "employed")
    if field_type == "income":
        qi = customer.get("quality_issues", {})
        if qi.get("domain_range_income"):
            return qi["domain_range_income"]
        val = customer.get("annual_income_eur", customer.get("annual_revenue_eur", 50000))
        return min(val, 999999) if p == "oracle" else val
    if field_type == "net_worth":
        val = customer.get("net_worth_eur", 100000)
        return min(val, 999999) if p == "oracle" else val
    if field_type == "relationship_start":
        return customer.get("relationship_start_date", "2020-01-01")
    if field_type == "gdpr_consent":
        return customer.get("gdpr_consent", "granted")
    if field_type == "is_pep":
        return customer.get("is_pep", False)
    if field_type == "preferred_channel":
        return customer.get("preferred_channel", "web_portal")

    # Product fields
    if field_type == "product_code":
        return product["platform_ids"].get(p.replace("-", "_"), product["code"])
    if field_type == "product_name":
        return product["platform_names"].get(p.replace("-", "_"), product["name"])
    if field_type == "product_type":
        return product.get("type", "Auto Lease")
    if field_type == "interest_rate":
        qi = product.get("quality_issues", {})
        if qi.get("fd_violation_rate") and random.random() < 0.3:
            return qi["fd_violation_rate"]
        return product.get("interest_rate", 5.0)

    # Contract fields
    if field_type == "contract_id":
        return contract["platform_ids"].get(p.replace("-", "_"), contract["master_id"])
    if field_type == "contract_start":
        return contract.get("start_date", "2023-01-01")
    if field_type == "contract_end":
        qi = contract.get("quality_issues", {})
        if qi.get("custom_end_before_start"):
            # Return a date before start
            start = contract.get("start_date", "2023-01-01")
            return (date.fromisoformat(start) - timedelta(days=random.randint(1, 365))).isoformat()
        return contract.get("end_date", "2028-01-01")
    if field_type == "outstanding_balance":
        qi = contract.get("quality_issues", {})
        bal = contract.get("outstanding_balance", 0)
        if p == "snowflake" and qi.get("balance_mismatch_snowflake"):
            return qi["balance_mismatch_snowflake"]
        offset = customer.get("quality_issues", {}).get("balance_rounding_offset", 0)
        return round(bal + offset, 2) if bal else 0
    if field_type == "contract_status":
        qi = contract.get("quality_issues", {})
        status = contract.get("status", "active")
        if qi.get("fd_violation_status") and random.random() < 0.3:
            return qi["fd_violation_status"]
        if p == "oracle" and qi.get("status_inconsistency_oracle"):
            return qi["status_inconsistency_oracle"]
        return status
    if field_type == "monthly_payment":
        return contract.get("monthly_payment", 500)

    # Company
    if field_type == "company_name":
        return customer.get("company_name", customer.get("trade_name", customer.get("full_name", "")))
    if field_type == "lei":
        return customer.get("lei", "")
    if field_type == "kvk":
        return customer.get("kvk_number", "")
    if field_type == "industry":
        return customer.get("industry", "Financial Services")
    if field_type == "currency":
        return random.choice(list(CURRENCIES_REF.keys()))

    return None


def gen_generic_value(col_name, col_type, platform):
    """Generate a generic value for unmatched columns."""
    n = col_name.lower()
    t = (col_type or "").upper()

    # Booleans
    if "BIT" in t or "BOOL" in t or "TINYINT" in t:
        return random.choice([True, False]) if "BOOL" in t else random.choice([0, 1])

    # Integers
    if "INT" in t or "NUMBER" in t and ("," not in t or ",0)" in t):
        if "count" in n or "num" in n: return random.randint(0, 500)
        if "score" in n: return random.randint(0, 100)
        if "year" in n: return random.randint(2019, 2026)
        if "duration" in n or "month" in n: return random.randint(1, 120)
        return random.randint(1, 9999)

    # Decimals
    if "DECIMAL" in t or "NUMERIC" in t or "FLOAT" in t or "DOUBLE" in t or "NUMBER" in t:
        # Parse precision from type like NUMBER(18,2) or DECIMAL(15,4)
        prec_match = re.match(r'(?:NUMBER|DECIMAL|NUMERIC)\((\d+),(\d+)\)', t)
        if prec_match:
            prec, scale = int(prec_match.group(1)), int(prec_match.group(2))
            max_val = min(10 ** (prec - scale) - 1, 9999999)
            if scale == 0:
                # Integer
                if "count" in n or "days" in n: return random.randint(0, min(max_val, 999))
                if n in ("is_in_default_exposure",) or prec == 1: return random.choice([0, 1])
                return random.randint(0, min(max_val, 99999))
            else:
                if any(k in n for k in ["amount", "balance", "value", "revenue", "cost", "fee", "payment", "principal"]):
                    return round(random.uniform(500, min(max_val, 999999)), min(scale, 2))
                if any(k in n for k in ["rate", "pct", "ratio", "margin", "weight", "percent"]):
                    return round(random.uniform(0, min(max_val, 100)), min(scale, 4))
                if "score" in n: return round(random.uniform(0, min(max_val, 100)), min(scale, 2))
                return round(random.uniform(0, min(max_val, 99999)), min(scale, 2))

        # No precision info — use defaults
        max_amt = 999999 if platform == "oracle" else 2000000
        if any(k in n for k in ["amount", "balance", "value", "revenue", "cost", "fee", "payment"]):
            return round(random.uniform(500, max_amt), 2)
        if any(k in n for k in ["rate", "pct", "ratio", "margin"]):
            return round(random.uniform(0, 30), 4)
        if "score" in n: return round(random.uniform(0, 100), 2)
        return round(random.uniform(0, min(99999, max_amt)), 2)

    # Dates — always return datetime for MongoDB compatibility
    if "DATE" in t and "TIME" not in t:
        d = date(2023, 1, 1) + timedelta(days=random.randint(0, 1100))
        if platform == "mongodb":
            return datetime(d.year, d.month, d.day)
        return d

    # Timestamps
    if "TIME" in t or "DATETIME" in t:
        return datetime(2023, 1, 1) + timedelta(days=random.randint(0, 1100), hours=random.randint(0, 23))

    # Strings
    if "CHAR" in t or "TEXT" in t or "STRING" in t or "CLOB" in t or "VARCHAR" in t:
        if "status" in n: return random.choice(["active", "inactive", "pending", "closed"])
        if "type" in n: return random.choice(["standard", "premium", "basic", "enterprise"])
        if "code" in n: return f"{''.join(random.choices(string.ascii_uppercase, k=3))}-{random.randint(1000, 9999)}"
        if any(k in n for k in ["description", "desc", "comment", "note"]):
            return "Standard financial record"
        if "region" in n: return random.choice(["EMEA", "APAC", "Americas", "Nordics"])
        if "department" in n: return random.choice(["Sales", "Finance", "Risk", "IT", "HR"])
        if n.endswith("_id") or "identifier" in n:
            return f"{''.join(random.choices(string.ascii_uppercase, k=3))}-{random.randint(10000, 99999)}"
        return f"val_{random.randint(1000, 9999)}"

    # RAW (Oracle UUID)
    if "RAW" in t:
        return bytes.fromhex(os.urandom(16).hex())

    return f"v_{random.randint(1, 9999)}"


def determine_rows(table_name):
    name = table_name.lower()
    if any(k in name for k in ["dim", "status", "type", "category", "ref", "lookup", "channel", "segment"]):
        return random.randint(15, 50)
    if any(k in name for k in ["fact", "transaction", "event", "log", "history", "payment", "activity", "record"]):
        return random.randint(400, 800)
    if any(k in name for k in ["customer", "client", "contact", "account", "person", "profile"]):
        return min(len(CUSTOMERS), random.randint(200, 500))
    if any(k in name for k in ["product", "service", "contract", "agreement", "loan", "lease"]):
        return random.randint(100, 300)
    return random.randint(50, 200)


# ─── PLATFORM-SPECIFIC DATA LOADERS ─────────────────────────────────────────

def load_sqlserver():
    import pyodbc
    logger.info("\n=== SQL Server Data Generation ===")
    conn = pyodbc.connect(PLATFORMS["sql-server"]["conn"], autocommit=True)
    cur = conn.cursor()

    cur.execute("SELECT name FROM sys.databases WHERE name LIKE 'Masreph_%' ORDER BY name")
    dbs = [r[0] for r in cur.fetchall()]
    grand_total = 0

    for db in dbs:
        cur.execute(f"USE [{db}]")
        cur.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'")
        tables = [r[0] for r in cur.fetchall()]
        db_total = 0

        for table in tables:
            cur.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION")
            columns = [(r[0], r[1]) for r in cur.fetchall()]
            if not columns: continue

            num_rows = determine_rows(table)
            inserted = insert_rows(cur, f"[{table}]", columns, num_rows, "sql-server", "[", "]", "?")
            db_total += inserted

        grand_total += db_total
        if db_total > 0:
            logger.info(f"  {db}: {len(tables)} tables, {db_total} rows")

    conn.close()
    return grand_total


def load_postgresql():
    import psycopg2
    logger.info("\n=== PostgreSQL Data Generation ===")
    cfg = PLATFORMS["postgresql"]
    conn = psycopg2.connect(host=cfg["host"], port=cfg["port"], database=cfg["database"],
        user=cfg["user"], password=cfg["password"], connect_timeout=15)
    cur = conn.cursor()

    cur.execute("""SELECT schemaname FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog','information_schema','auth','storage','realtime','extensions',
        'graphql','graphql_public','pgsodium','pgsodium_masks','vault','supabase_functions',
        '_realtime','supabase_migrations','net','_analytics','public')
        GROUP BY schemaname ORDER BY schemaname""")
    schemas = [r[0] for r in cur.fetchall()]
    grand_total = 0

    for schema in schemas:
        cur.execute(f"SELECT tablename FROM pg_tables WHERE schemaname='{schema}'")
        tables = [r[0] for r in cur.fetchall()]
        schema_total = 0

        for table in tables:
            cur.execute(f"SELECT column_name, udt_name FROM information_schema.columns WHERE table_schema='{schema}' AND table_name='{table}' ORDER BY ordinal_position")
            columns = [(r[0], r[1]) for r in cur.fetchall()]
            if not columns: continue

            # Skip serial columns
            cur.execute(f"SELECT column_name FROM information_schema.columns WHERE table_schema='{schema}' AND table_name='{table}' AND column_default LIKE 'nextval%'")
            serial_cols = {r[0] for r in cur.fetchall()}
            columns = [(n, t) for n, t in columns if n not in serial_cols]
            if not columns: continue

            num_rows = determine_rows(table)
            full_name = f"{schema}.{table}"
            inserted = insert_rows_pg(cur, conn, full_name, columns, num_rows, "postgresql")
            schema_total += inserted

        grand_total += schema_total
        if schema_total > 0:
            logger.info(f"  {schema}: {len(tables)} tables, {schema_total} rows")

    conn.close()
    return grand_total


def load_mysql():
    import mysql.connector
    logger.info("\n=== MySQL Data Generation ===")
    conn = mysql.connector.connect(host="localhost", port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')")
    cur = conn.cursor()

    cur.execute("SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME LIKE 'masreph_%'")
    dbs = [r[0] for r in cur.fetchall()]
    grand_total = 0

    for db in dbs:
        cur.execute(f"USE `{db}`")
        cur.execute(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db}'")
        tables = [r[0] for r in cur.fetchall()]
        db_total = 0

        for table in tables:
            cur.execute(f"SELECT column_name, data_type, extra FROM information_schema.columns WHERE table_schema='{db}' AND table_name='{table}' ORDER BY ordinal_position")
            all_cols = cur.fetchall()
            columns = [(r[0], r[1]) for r in all_cols if "auto_increment" not in (r[2] or "")]
            if not columns: continue

            num_rows = determine_rows(table)
            inserted = insert_rows_mysql(cur, conn, f"`{table}`", columns, num_rows, "mysql")
            db_total += inserted

        grand_total += db_total
        if db_total > 0:
            logger.info(f"  {db}: {len(tables)} tables, {db_total} rows")

    conn.close()
    return grand_total


def load_snowflake():
    import snowflake.connector
    logger.info("\n=== Snowflake Data Generation ===")
    cfg = PLATFORMS["snowflake"]
    conn = snowflake.connector.connect(account=cfg["account"], user=cfg["user"],
        password=cfg["password"], warehouse=cfg["warehouse"], database=cfg["database"])
    cur = conn.cursor()

    cur.execute("SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' AND TABLE_SCHEMA != 'INFORMATION_SCHEMA'")
    tables = cur.fetchall()
    grand_total = 0

    for schema, table in tables:
        cur.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='{schema}' AND TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION")
        columns = [(r[0], r[1]) for r in cur.fetchall()]
        if not columns: continue

        num_rows = determine_rows(table)
        full_name = f"{schema}.{table}"
        inserted = insert_rows_sf(cur, full_name, columns, num_rows, "snowflake")
        grand_total += inserted

    logger.info(f"  Snowflake: {len(tables)} tables, {grand_total} rows")
    conn.close()
    return grand_total


def load_oracle():
    import oracledb
    logger.info("\n=== Oracle Data Generation ===")
    wallet_dir = os.path.join(BASE_DIR, "config", "oracle_wallet")
    conn = oracledb.connect(user="ADMIN", password="os.getenv('ORACLE_PASSWORD')", dsn="masrephdb_low",
        config_dir=wallet_dir, wallet_location=wallet_dir, wallet_password="os.getenv('ORACLE_PASSWORD')")
    cur = conn.cursor()

    cur.execute("SELECT table_name FROM user_tables ORDER BY table_name")
    tables = [r[0] for r in cur.fetchall()]
    grand_total = 0

    for table in tables:
        cur.execute(f"SELECT column_name, data_type, data_precision, data_scale FROM user_tab_columns WHERE table_name='{table}' ORDER BY column_id")
        raw_cols = cur.fetchall()
        # Build type string with precision for NUMBER columns
        columns = []
        for r in raw_cols:
            col_name, dtype = r[0], r[1]
            if dtype == "NUMBER" and r[2] is not None:
                dtype = f"NUMBER({r[2]},{r[3] or 0})"
            columns.append((col_name, dtype))
        if not columns: continue

        num_rows = determine_rows(table)
        inserted = insert_rows_oracle(cur, conn, table, columns, num_rows, "oracle")
        grand_total += inserted

    logger.info(f"  Oracle: {len(tables)} tables, {grand_total} rows")
    conn.close()
    return grand_total


def load_mongodb():
    from pymongo import MongoClient
    from urllib.parse import quote_plus
    import certifi
    logger.info("\n=== MongoDB Data Generation ===")

    password = quote_plus("os.getenv('MONGODB_PASSWORD')")
    try:
        client = MongoClient(f"mongodb+srv://hzmarrou:{password}@masrephapi.c2lbreb.mongodb.net/",
            tls=True, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=15000)
        client.admin.command('ping')
        logger.info("  Connected to MongoDB Atlas")
    except Exception as e:
        logger.error(f"  MongoDB connection failed: {e}")
        return 0

    schemas_dir = os.path.join(BASE_DIR, "schemas_v2", "mongodb")
    grand_total = 0

    for filepath in sorted(os.listdir(schemas_dir)):
        if not filepath.endswith(".json"): continue
        db_name = f"masreph_{filepath.replace('.json', '')}"
        with open(os.path.join(schemas_dir, filepath)) as f:
            schemas = json.load(f)

        db = client[db_name]
        db_total = 0

        for schema in schemas:
            if not isinstance(schema, dict) or "error" in schema: continue
            coll_name = schema.get("collection", "collection")
            props = schema.get("validator", {}).get("$jsonSchema", {}).get("properties", {})
            fields = list(props.keys())

            if not fields:
                continue

            num_rows = determine_rows(coll_name)
            docs = []
            for i in range(num_rows):
                customer = random.choice(CUSTOMERS)
                product = random.choice(PRODUCTS)
                contract = random.choice(CONTRACTS)
                doc = {}
                for field in fields:
                    ft = classify_column(field)
                    if ft:
                        val = get_entity_value(ft, customer, product, contract, "mongodb")
                    else:
                        bson_type = props[field].get("bsonType", "string")
                        val = gen_generic_value(field, bson_type.upper(), "mongodb")
                    # Convert date to datetime for MongoDB
                    if isinstance(val, date) and not isinstance(val, datetime):
                        val = datetime(val.year, val.month, val.day)
                    doc[field] = val
                docs.append(doc)

            try:
                if db[coll_name].count_documents({}) > 0:
                    continue
                db[coll_name].insert_many(docs)
                db_total += len(docs)
            except Exception as e:
                logger.warning(f"  Error inserting {db_name}.{coll_name}: {str(e)[:80]}")

        grand_total += db_total
        if db_total > 0:
            logger.info(f"  {db_name}: {db_total} documents")

    client.close()
    return grand_total


# ─── INSERT HELPERS ──────────────────────────────────────────────────────────

def coerce_value(val, col_type, platform=""):
    """Coerce a value to the correct Python type for the database column."""
    if val is None:
        return None
    t = (col_type or "").upper()

    # MongoDB can't handle date objects, needs datetime
    if platform == "mongodb" and isinstance(val, date) and not isinstance(val, datetime):
        return datetime(val.year, val.month, val.day)

    # String dates -> date/datetime objects
    if isinstance(val, str):
        if "DATE" in t and "TIME" not in t:
            try:
                return date.fromisoformat(val[:10])
            except:
                return date(2023, 1, 1)
        if "TIME" in t or "DATETIME" in t or "TIMESTAMP" in t:
            try:
                return datetime.fromisoformat(val) if "T" in val else datetime.fromisoformat(val + "T00:00:00")
            except:
                return datetime(2023, 1, 1)

    # Booleans for databases that need int
    if isinstance(val, bool):
        if "BIT" in t or "TINYINT" in t or "NUMBER" in t or "INT" in t:
            return 1 if val else 0

    # Numbers stored as strings
    if isinstance(val, str) and ("NUMBER" in t or "INT" in t or "DECIMAL" in t or "NUMERIC" in t or "FLOAT" in t):
        try:
            if "." in val:
                return float(val)
            return int(val)
        except:
            return 0

    return val


def build_row(columns, platform, row_idx):
    """Build a single row of data using master entities."""
    customer = CUSTOMERS[row_idx % len(CUSTOMERS)]
    product = PRODUCTS[row_idx % len(PRODUCTS)]
    contract = CONTRACTS[row_idx % len(CONTRACTS)]

    row = []
    for col_name, col_type in columns:
        ft = classify_column(col_name)
        if ft:
            val = get_entity_value(ft, customer, product, contract, platform)
        else:
            val = gen_generic_value(col_name, col_type, platform)
        # Coerce to correct type
        val = coerce_value(val, col_type, platform)
        row.append(val)
    return tuple(row)


def insert_rows(cur, table_name, columns, num_rows, platform, q_open, q_close, placeholder):
    """Insert rows using parameterized queries (SQL Server)."""
    col_list = ", ".join(f"{q_open}{c[0]}{q_close}" for c in columns)
    placeholders = ", ".join([placeholder] * len(columns))
    sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    rows = [build_row(columns, platform, i) for i in range(num_rows)]
    inserted = 0
    batch_size = 100
    for bs in range(0, len(rows), batch_size):
        batch = rows[bs:bs + batch_size]
        try:
            cur.executemany(sql, batch)
            inserted += len(batch)
        except:
            for row in batch:
                try:
                    cur.execute(sql, row)
                    inserted += 1
                except:
                    pass
    return inserted


def insert_rows_pg(cur, conn, table_name, columns, num_rows, platform):
    """Insert rows for PostgreSQL."""
    from psycopg2.extras import execute_batch
    col_list = ", ".join(c[0] for c in columns)
    placeholders = ", ".join(["%s"] * len(columns))
    sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    rows = [build_row(columns, platform, i) for i in range(num_rows)]
    try:
        execute_batch(cur, sql, rows, page_size=200)
        conn.commit()
        return len(rows)
    except:
        conn.rollback()
        ok = 0
        for row in rows:
            try:
                cur.execute(sql, row)
                conn.commit()
                ok += 1
            except:
                conn.rollback()
        return ok


def insert_rows_mysql(cur, conn, table_name, columns, num_rows, platform):
    """Insert rows for MySQL."""
    col_list = ", ".join(f"`{c[0]}`" for c in columns)
    placeholders = ", ".join(["%s"] * len(columns))
    sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    rows = [build_row(columns, platform, i) for i in range(num_rows)]
    try:
        cur.executemany(sql, rows)
        conn.commit()
        return len(rows)
    except:
        conn.rollback()
        ok = 0
        for row in rows:
            try:
                cur.execute(sql, row)
                conn.commit()
                ok += 1
            except:
                conn.rollback()
        return ok


def insert_rows_sf(cur, table_name, columns, num_rows, platform):
    """Insert rows for Snowflake."""
    col_list = ", ".join(c[0] for c in columns)
    placeholders = ", ".join(["%s"] * len(columns))
    sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    rows = [build_row(columns, platform, i) for i in range(num_rows)]
    try:
        cur.executemany(sql, rows)
        return len(rows)
    except:
        ok = 0
        for row in rows:
            try:
                cur.execute(sql, row)
                ok += 1
            except:
                pass
        return ok


def insert_rows_oracle(cur, conn, table_name, columns, num_rows, platform):
    """Insert rows for Oracle."""
    col_list = ", ".join(c[0] for c in columns)
    placeholders = ", ".join([f":{i+1}" for i in range(len(columns))])
    sql = f"INSERT INTO {table_name} ({col_list}) VALUES ({placeholders})"

    rows = [build_row(columns, platform, i) for i in range(num_rows)]
    inserted = 0
    errors_logged = 0
    batch_size = 100
    for bs in range(0, len(rows), batch_size):
        batch = rows[bs:bs + batch_size]
        try:
            cur.executemany(sql, batch)
            conn.commit()
            inserted += len(batch)
        except Exception as e:
            conn.rollback()
            if errors_logged < 2:
                logger.warning(f"    Oracle batch error {table_name}: {str(e)[:100]}")
                errors_logged += 1
            for row in batch:
                try:
                    cur.execute(sql, row)
                    conn.commit()
                    inserted += 1
                except:
                    conn.rollback()
    return inserted


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== Data Generation V2 — Shared Master Entities ===")
    logger.info(f"Master: {len(CUSTOMERS)} customers, {len(PRODUCTS)} products, {len(CONTRACTS)} contracts")

    results = {}

    # Local platforms first (fast)
    results["sql-server"] = load_sqlserver()
    results["mysql"] = load_mysql()

    # Cloud platforms
    results["postgresql"] = load_postgresql()
    results["oracle"] = load_oracle()
    results["mongodb"] = load_mongodb()
    results["snowflake"] = load_snowflake()

    # Note: Databricks and Fabric are slow (cloud) — run separately if needed

    logger.info("\n=== DATA GENERATION COMPLETE ===")
    grand_total = 0
    for platform, count in results.items():
        logger.info(f"  {platform:15s}: {count:,} rows")
        grand_total += count
    logger.info(f"  {'TOTAL':15s}: {grand_total:,} rows")
    logger.info("\nNote: Databricks and Fabric not included (run separately for cloud platforms)")


if __name__ == "__main__":
    main()
