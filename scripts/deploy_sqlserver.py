#!/usr/bin/env python3
"""
Deploy SQL Server DDL and generate realistic sample data.
Creates one DATABASE per source system (DDL file).
Uses Windows Authentication on localhost.

SQL Server quality profile: 72-82% (legacy core banking, 15+ years old)
- 5-8% NULLs in non-required fields
- Inconsistent status codes across tables
- Default/placeholder values ("N/A", "TBD", "UNKNOWN")
- Some trailing whitespace in text fields
- Mixed date formats in VARCHAR date columns
- Legacy codes nobody documents
"""

import os
import re
import json
import random
import string
import pyodbc
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "sql-server")
DB_PREFIX = "Masreph_"
CONN_STR = "DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;Trusted_Connection=yes;"

# Quality - legacy system, worse than modern apps
Q_NULL = 0.06  # 6% NULLs
Q_STALE = 0.08  # 8% stale records
Q_ENCODING = 0.02
Q_PLACEHOLDER = 0.03  # 3% placeholder values ("N/A", "TBD")
Q_WHITESPACE = 0.04  # 4% trailing whitespace

# Data pools - PascalCase for SQL Server
FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Daan","Emma",
    "Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte","Ahmed","Fatima",
    "James","Sarah","Robert","Emily","Carlos","Isabella","Hans","Greta","Pedro","Ana",
    "Raj","Priya","Wei","Mei","Yuki","Mohammed","Aisha","Jean","Marie","Klaus"]
LAST_NAMES = ["Van den Berg","De Jong","Jansen","De Vries","Van Dijk","Bakker","Visser",
    "Smit","Meijer","De Boer","Muller","Schmidt","Schneider","Fischer","Weber",
    "Smith","Johnson","Williams","Brown","Jones","Garcia","Martinez","Rodriguez",
    "Chen","Wang","Li","Patel","Sharma","Kumar","Dubois","Moreau"]
DIACRITICS = ["M\u00fcller","Bj\u00f6rk","Ren\u00e9e","Fran\u00e7ois","Jos\u00e9","S\u00f8ren"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["Active","Inactive","Pending","Suspended","Closed"]
# Legacy inconsistency: some tables use different status values
STATUSES_LEGACY = ["ACTIVE","A","1","active","Active","ACT"]
RISK_LEVELS = ["Low","Medium","High","Critical"]
RISK_BANDS = ["AAA","AA","A","BBB","BB","B","CCC","CC","C","D"]
CHANNELS = ["WebPortal","MobileApp","Branch","Phone","Email","API","Chatbot"]
INDUSTRIES = ["Financial Services","Manufacturing","Retail","Healthcare","Technology","Real Estate","Automotive","Energy"]
DEPARTMENTS = ["Sales","Finance","Risk Management","Operations","IT","Legal","Compliance","HR"]
CITIES = ["Amsterdam","Rotterdam","Berlin","Munich","Paris","London","New York","Singapore","Tokyo"]
PRODUCT_NAMES = ["Masreph Auto Lease Plus","Masreph Fleet Pro","Masreph Home Finance Direct",
    "Masreph Business Credit 360","Masreph Savings Smart","Masreph Equipment Lease Flex"]
PRODUCT_TYPES = ["AutoLease","EquipmentLease","Mortgage","PersonalLoan","BusinessLoan","CreditCard"]
LANGUAGES = ["NL","EN","DE","FR","ES","IT","PT","JA"]
GENDER_CODES = ["M","F","X"]
MARITAL = ["Single","Married","Divorced","Widowed"]
EMPLOYMENT = ["Employed","SelfEmployed","Unemployed","Retired","Student"]
CUSTOMER_SEGMENTS = ["MassMarket","Affluent","HighNetWorth","SME","MidCorporate","Institutional"]
PLACEHOLDER_VALUES = ["N/A","TBD","UNKNOWN","---","(not set)","?","PENDING"]


def get_connection(database=None):
    cs = CONN_STR
    if database:
        cs += f"DATABASE={database};"
    return pyodbc.connect(cs, autocommit=True)


# ─── PHASE 1: DEPLOY DDL ────────────────────────────────────────────────────

def deploy_all():
    logger.info("=== Phase 1: Deploying SQL Server DDL (one DB per source system) ===")
    conn = get_connection()
    cur = conn.cursor()

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    db_stats = {}

    for filepath in sql_files:
        fname = filepath.stem
        db_name = DB_PREFIX + fname

        # Create database
        try:
            cur.execute(f"IF NOT EXISTS (SELECT name FROM sys.databases WHERE name='{db_name}') CREATE DATABASE [{db_name}]")
        except Exception as e:
            logger.warning(f"  Cannot create {db_name}: {str(e)[:80]}")
            continue

        # Read DDL
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        # Switch to the new database
        try:
            cur.execute(f"USE [{db_name}]")
        except Exception:
            continue

        # Remove comments and split
        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)

        # Split on semicolons or GO statements
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        created = errors = 0
        fk_stmts = []

        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt:
                continue
            stmt_upper = stmt.upper()

            # Skip schema creation (we use dbo) and IF NOT EXISTS checks
            if "CREATE SCHEMA" in stmt_upper or "EXEC(" in stmt_upper:
                continue

            try:
                if "CREATE TABLE" in stmt_upper:
                    # Replace schema references with dbo
                    modified = re.sub(r'\[(\w+)\]\.\[', '[dbo].[', stmt)
                    cur.execute(modified + ";")
                    created += 1
                elif "ALTER TABLE" in stmt_upper and "FOREIGN KEY" in stmt_upper:
                    modified = re.sub(r'\[(\w+)\]\.\[', '[dbo].[', stmt)
                    fk_stmts.append(modified + ";")
            except pyodbc.ProgrammingError as e:
                err_msg = str(e)
                if "already an object" in err_msg:
                    pass
                else:
                    errors += 1
                    if errors <= 2:
                        logger.warning(f"    {db_name}: {err_msg[:80]}")
            except Exception as e:
                errors += 1

        # Add FKs
        fk_ok = 0
        for stmt in fk_stmts:
            try:
                cur.execute(stmt)
                fk_ok += 1
            except Exception:
                pass

        db_stats[db_name] = {"tables": created, "fks": fk_ok, "file": fname}
        if created > 0:
            logger.info(f"  {db_name}: {created} tables, {fk_ok} FKs")

    conn.close()
    total = sum(s["tables"] for s in db_stats.values())
    logger.info(f"\nPhase 1 complete: {len(db_stats)} databases, {total} tables")
    return db_stats


# ─── PHASE 2: GENERATE DATA ─────────────────────────────────────────────────

def determine_row_count(table_name, col_count, fk_count):
    name = table_name.lower()
    if any(k in name for k in ["status","type","category","config","setting","lookup","channel",
            "segment","grade","region","currency","country","frequency","direction","priority"]):
        return random.randint(15, 50)
    if any(k in name for k in ["transaction","event","log","history","audit","activity",
            "interaction","message","session","payment","transfer","entry","record"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["metric","analytics","insight","score","performance","snapshot"]):
        return random.randint(300, 700)
    if any(k in name for k in ["customer","client","contact","person","account","user","member",
            "employee","partner","prospect","lead","persona"]):
        return random.randint(200, 500)
    if any(k in name for k in ["product","service","plan","offer","contract","agreement",
            "loan","mortgage","lease","portfolio"]):
        return random.randint(100, 300)
    if fk_count >= 2:
        return random.randint(300, 800)
    if col_count <= 5:
        return random.randint(20, 60)
    return random.randint(100, 300)


def generate_value(col_name, col_type, col_size, nullable, is_pk, row_idx, fk_ids):
    name = col_name.lower()
    dtype = col_type.upper()

    if nullable and not is_pk and random.random() < Q_NULL:
        return None
    if name in fk_ids and fk_ids[name]:
        return random.choice(fk_ids[name])
    if is_pk:
        if "INT" in dtype: return row_idx + 1
        if "UNIQUEIDENTIFIER" in dtype: return str(os.urandom(16).hex())
        return row_idx + 1

    # BIT (boolean)
    if "BIT" in dtype:
        if "active" in name or "enabled" in name: return 1 if random.random() < 0.85 else 0
        if "consent" in name or "opt" in name: return 1 if random.random() < 0.70 else 0
        if "flag" in name and ("risk" in name or "fraud" in name): return 1 if random.random() < 0.03 else 0
        if "archived" in name or "deleted" in name: return 1 if random.random() < 0.10 else 0
        return random.choice([0, 1])

    # INT
    if "INT" in dtype and "BIG" not in dtype:
        if "age" in name: return random.randint(18, 78)
        if "household" in name: return random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0]
        if "year" in name: return random.randint(2019, 2026)
        if "score" in name or "rating" in name:
            if "credit" in name: return random.randint(300, 850)
            if "nps" in name: return random.randint(-100, 100)
            return random.randint(0, 100)
        if "count" in name or "quantity" in name or "num" in name: return random.randint(0, 1000)
        if "duration" in name: return random.randint(1, 120)
        return random.randint(1, 9999)

    if "BIGINT" in dtype:
        return random.randint(1, 999999)

    # DECIMAL / MONEY
    if "DECIMAL" in dtype or "NUMERIC" in dtype or "MONEY" in dtype or "FLOAT" in dtype:
        if any(k in name for k in ["amount","balance","total","price","value","revenue","cost","fee","payment","income","principal"]):
            return round(random.uniform(500, 2000000), 2)
        if any(k in name for k in ["rate","interest","margin"]):
            return round(random.uniform(0.5, 15.0), 4)
        if any(k in name for k in ["percentage","pct","ratio"]):
            return round(random.uniform(0, 100), 2)
        if "score" in name: return round(random.uniform(0, 100), 2)
        return round(random.uniform(0, 99999), 2)

    # DATE
    if dtype == "DATE":
        if "birth" in name: return date(2026-random.randint(18,78), random.randint(1,12), random.randint(1,28))
        if "start" in name or "open" in name or "effective" in name:
            return date(2022,1,1)+timedelta(days=random.randint(0,1000))
        if "end" in name or "expir" in name or "maturity" in name:
            return date(2025,1,1)+timedelta(days=random.randint(0,1500))
        if "due" in name: return date(2026,1,1)+timedelta(days=random.randint(0,365))
        return date(2023,1,1)+timedelta(days=random.randint(0,1100))

    # DATETIME / DATETIME2
    if "DATETIME" in dtype:
        base = datetime(2023,1,1)
        ts = base + timedelta(days=random.randint(0,1100), hours=random.randint(0,23), minutes=random.randint(0,59))
        if ("created" in name or "start" in name) and random.random() < Q_STALE:
            ts = datetime(2018,1,1) + timedelta(days=random.randint(0,730))  # Older stale for legacy
        return ts

    # UNIQUEIDENTIFIER
    if "UNIQUEIDENTIFIER" in dtype:
        return str(os.urandom(16).hex())

    # NVARCHAR / VARCHAR / NCHAR
    if "CHAR" in dtype or "TEXT" in dtype:
        max_len = col_size if col_size and col_size > 0 else 255
        if max_len > 4000: max_len = 255  # MAX
        return _gen_ss_text(name, max_len)

    return f"Val_{row_idx}"


def _gen_ss_text(name, ml):
    # Quality: occasional placeholder values (legacy system)
    if random.random() < Q_PLACEHOLDER and "id" not in name and "key" not in name:
        return random.choice(PLACEHOLDER_VALUES)

    val = _gen_ss_text_inner(name, ml)

    # Quality: trailing whitespace
    if random.random() < Q_WHITESPACE and val and len(val) < ml - 3:
        val = val + "   "

    return val[:ml] if val else val


def _gen_ss_text_inner(name, ml):
    # Names (PascalCase for SQL Server)
    if any(k in name for k in ["firstname","givenname"]):
        n = random.choice(FIRST_NAMES)
        if random.random() < Q_ENCODING: n = random.choice(DIACRITICS)
        return n
    if any(k in name for k in ["lastname","surname","familyname"]):
        n = random.choice(LAST_NAMES)
        if random.random() < Q_ENCODING: n = random.choice(DIACRITICS)
        return n
    if any(k in name for k in ["fullname","customername","clientname","contactname","companyname",
            "entityname","advisorname","managername","lesseename","borrowername"]):
        fn = random.choice(FIRST_NAMES)
        if random.random() < Q_ENCODING: fn = random.choice(DIACRITICS)
        return f"{fn} {random.choice(LAST_NAMES)}"
    if "name" in name and not any(k in name for k in ["file","table","column","schema","db"]):
        if any(k in name for k in ["product","service","plan","branch","campaign"]):
            return random.choice(PRODUCT_NAMES)
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"
    # Email
    if "email" in name:
        fn = random.choice(FIRST_NAMES).lower()
        ln = random.choice(LAST_NAMES).lower().replace(" ","")
        return f"{fn}.{ln}@{random.choice(['masreph.com','masreph.nl','gmail.com','outlook.com'])}"
    # Phone
    if "phone" in name or "mobile" in name:
        return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"
    # Gender
    if "gender" in name: return random.choices(GENDER_CODES, weights=[48,48,4])[0]
    # Marital
    if "marital" in name: return random.choice(MARITAL)
    # Employment
    if "employment" in name: return random.choice(EMPLOYMENT)
    # Country
    if "country" in name: return random.choice(COUNTRIES)
    # City
    if "city" in name: return random.choice(CITIES)
    # Address
    if "address" in name or "street" in name:
        return f"{random.randint(1,500)} {random.choice(['Keizersgracht','Herengracht','Main Street','Friedrichstrasse','Oxford Street'])}"
    # Postal
    if "postal" in name or "zip" in name: return f"{random.randint(1000,9999)}{random.choice(['AB','CD','EF'])}"
    # Currency
    if "currency" in name: return random.choice(CURRENCIES)
    # Language
    if "language" in name or "locale" in name: return random.choice(LANGUAGES)
    # Status - legacy inconsistency
    if "status" in name or "state" in name:
        if random.random() < 0.15:  # 15% legacy format
            return random.choice(STATUSES_LEGACY)
        return random.choice(STATUSES)
    # Risk
    if "risk" in name and any(k in name for k in ["level","rating","category","band","grade"]):
        return random.choice(RISK_LEVELS)
    if "creditrating" in name or "riskband" in name: return random.choice(RISK_BANDS)
    # Segment
    if "segment" in name: return random.choice(CUSTOMER_SEGMENTS)
    # Channel
    if "channel" in name or ("source" in name and "system" not in name): return random.choice(CHANNELS)
    # Industry
    if "industry" in name or "sector" in name: return random.choice(INDUSTRIES)
    # Department
    if "department" in name or "dept" in name: return random.choice(DEPARTMENTS)
    # Product
    if "producttype" in name: return random.choice(PRODUCT_TYPES)
    if "subtype" in name: return random.choice(["Standard","Premium","Flex","Green","FixedRate"])
    # Type
    if "type" in name: return random.choice(["Standard","Premium","Basic","Enterprise","Custom"])
    # Description
    if any(k in name for k in ["description","desc","comment","note","remark","summary","reason"]):
        return random.choice([
            "Standard financial product for European market segment",
            "Legacy core banking transaction record",
            "Customer credit facility - periodic review required",
            "Leasing contract amendment - approved by RM",
            "Payment processing record - batch settlement",
            "Trade finance instrument - letter of credit",
        ])
    # Code
    if "code" in name:
        if "country" in name: return random.choice(COUNTRIES)
        if "currency" in name: return random.choice(CURRENCIES)
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"
    # ID-like
    if name.endswith("id") or "identifier" in name or "ref" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"
    # Version
    if "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"
    # Generic
    return f"Masreph_{random.randint(1000,9999)}"


def generate_data_for_db(db_name):
    conn = get_connection(db_name)
    cur = conn.cursor()

    # Get tables
    cur.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")
    tables = [r[0] for r in cur.fetchall()]

    if not tables:
        conn.close()
        return 0

    # Truncate all
    for t in tables:
        try:
            cur.execute(f"DELETE FROM [{t}]")
        except Exception:
            pass

    # Get metadata
    table_meta = []
    for t in tables:
        cur.execute(f"""
            SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.IS_NULLABLE,
                   CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END as IS_PK
            FROM INFORMATION_SCHEMA.COLUMNS c
            LEFT JOIN (
                SELECT ku.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku ON tc.CONSTRAINT_NAME=ku.CONSTRAINT_NAME
                WHERE tc.TABLE_NAME='{t}' AND tc.CONSTRAINT_TYPE='PRIMARY KEY'
            ) pk ON c.COLUMN_NAME=pk.COLUMN_NAME
            WHERE c.TABLE_NAME='{t}'
            ORDER BY c.ORDINAL_POSITION
        """)
        columns = [{"name":r[0],"type":r[1],"size":r[2],"nullable":r[3]=="YES","is_pk":r[4]==1} for r in cur.fetchall()]

        # Get FK info
        cur.execute(f"""
            SELECT ccu.COLUMN_NAME, kcu2.TABLE_NAME, kcu2.COLUMN_NAME
            FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ccu ON rc.CONSTRAINT_NAME=ccu.CONSTRAINT_NAME
            JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu2 ON rc.UNIQUE_CONSTRAINT_NAME=kcu2.CONSTRAINT_NAME
            WHERE ccu.TABLE_NAME='{t}'
        """)
        fk_info = {}
        for r in cur.fetchall():
            fk_info[r[0].lower()] = (r[1], r[2])

        fk_count = len(fk_info)
        num_rows = determine_row_count(t, len(columns), fk_count)

        table_meta.append({"name":t, "columns":columns, "fk_info":fk_info,
            "num_rows":num_rows, "num_fks":fk_count})

    # Sort parents first
    table_meta.sort(key=lambda x: x["num_fks"])

    db_total = 0
    for tm in table_meta:
        # Get FK parent IDs
        fk_ids = {}
        for col_name, (ref_table, ref_col) in tm["fk_info"].items():
            try:
                cur.execute(f"SELECT TOP 500 [{ref_col}] FROM [{ref_table}]")
                ids = [r[0] for r in cur.fetchall()]
                fk_ids[col_name] = ids if ids else None
            except Exception:
                fk_ids[col_name] = None

        # Skip identity/auto-increment columns
        insertable = [c for c in tm["columns"] if "identity" not in (c.get("extra","") or "").lower()]

        # Check for identity columns
        identity_cols = set()
        try:
            cur.execute(f"SELECT name FROM sys.identity_columns WHERE object_id=OBJECT_ID('{tm['name']}')")
            identity_cols = {r[0] for r in cur.fetchall()}
        except Exception:
            pass

        insertable = [c for c in tm["columns"] if c["name"] not in identity_cols]
        if not insertable:
            continue

        col_list = ", ".join(f"[{c['name']}]" for c in insertable)
        placeholders = ", ".join(["?"] * len(insertable))
        insert_sql = f"INSERT INTO [{tm['name']}] ({col_list}) VALUES ({placeholders})"

        rows = []
        for i in range(tm["num_rows"]):
            row = tuple(
                generate_value(c["name"], c["type"], c["size"], c["nullable"], c["is_pk"], i, fk_ids)
                for c in insertable
            )
            rows.append(row)

        # Insert in small batches to avoid segfaults
        batch_size = 100
        for batch_start in range(0, len(rows), batch_size):
            batch = rows[batch_start:batch_start+batch_size]
            try:
                cur.executemany(insert_sql, batch)
                db_total += len(batch)
            except Exception:
                for row in batch:
                    try:
                        cur.execute(insert_sql, row)
                        db_total += 1
                    except Exception:
                        pass

    conn.close()
    return db_total


def generate_all(db_stats):
    logger.info("\n=== Phase 2: Generating SQL Server Data ===")
    grand_total = 0
    for db_name, stats in sorted(db_stats.items()):
        if stats["tables"] == 0:
            continue
        rows = generate_data_for_db(db_name)
        grand_total += rows
        logger.info(f"  {db_name}: {stats['tables']} tables, {rows} rows")

    logger.info(f"\n=== Total: {grand_total} rows across {len(db_stats)} databases ===")
    return grand_total


def main():
    logger.info("=== SQL Server: One Database Per Source System ===")

    # Check if DDL already deployed
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT name FROM sys.databases WHERE name LIKE 'Masreph_%' ORDER BY name")
    existing_dbs = [r[0] for r in cur.fetchall()]
    conn.close()

    if existing_dbs:
        logger.info(f"Found {len(existing_dbs)} existing Masreph databases - skipping DDL, generating data only")
        db_stats = {}
        for db_name in existing_dbs:
            c2 = get_connection(db_name)
            c2cur = c2.cursor()
            c2cur.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'")
            tcount = c2cur.fetchone()[0]
            c2.close()
            db_stats[db_name] = {"tables": tcount, "fks": 0, "file": db_name.replace(DB_PREFIX, "")}
        grand_total = generate_all(db_stats)
    else:
        db_stats = deploy_all()
        grand_total = generate_all(db_stats)

    logger.info(f"\n=== DONE: {len(db_stats)} databases, {grand_total} total rows ===")


if __name__ == "__main__":
    main()
