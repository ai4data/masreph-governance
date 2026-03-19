#!/usr/bin/env python3
"""
Deploy Microsoft Fabric Lakehouse tables and generate data.
Lakehouse: MasrephCorporateBI
Uses medallion architecture: Bronze, Silver, Gold schemas.

Fabric quality profile: 82-90% (corporate BI, 6 months old)
"""

import os
import re
import json
import random
import string
import struct
import pyodbc
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from azure.identity import ClientSecretCredential
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "fabric")

# Fabric connection
FABRIC_SERVER = "bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com"
FABRIC_DB = "MasrephCorporateBI_WH"
TENANT_ID = "os.getenv('FABRIC_TENANT_ID')"
CLIENT_ID = "os.getenv('FABRIC_CLIENT_ID')"
CLIENT_SECRET = "os.getenv('FABRIC_CLIENT_SECRET')"

# Quality
Q_NULL = 0.03
Q_STALE = 0.04

# Data pools
FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Daan","Emma",
    "Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte","Ahmed","Fatima",
    "James","Sarah","Robert","Emily","Carlos","Isabella","Hans","Greta","Pedro","Ana"]
LAST_NAMES = ["Van den Berg","De Jong","Jansen","De Vries","Van Dijk","Bakker","Visser",
    "Smit","Meijer","De Boer","Muller","Schmidt","Schneider","Smith","Johnson",
    "Williams","Brown","Garcia","Martinez","Chen","Wang","Patel","Sharma","Dubois"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["Active","Inactive","Pending","Suspended","Closed"]
RISK_LEVELS = ["Low","Medium","High","Critical"]
CHANNELS = ["WebPortal","MobileApp","Branch","Phone","Email","API"]
INDUSTRIES = ["Financial Services","Manufacturing","Retail","Healthcare","Technology","Real Estate"]
DEPARTMENTS = ["Sales","Finance","Risk Management","Operations","IT","Legal","Compliance","HR"]
CUSTOMER_SEGMENTS = ["MassMarket","Affluent","HighNetWorth","SME","MidCorporate"]
PRODUCT_TYPES = ["AutoLease","EquipmentLease","Mortgage","PersonalLoan","BusinessLoan"]
PRODUCT_NAMES = ["Masreph Auto Lease Plus","Masreph Fleet Pro","Masreph Home Finance Direct",
    "Masreph Business Credit 360","Masreph Savings Smart","Masreph Equipment Lease Flex"]
REGIONS = ["EMEA","APAC","Americas","Nordics"]
BUSINESS_LINES = ["Leasing","Commercial Finance","Consumer Finance","Mobility Solutions","Innovation"]


def get_connection():
    cred = ClientSecretCredential(TENANT_ID, CLIENT_ID, CLIENT_SECRET)
    token = cred.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    conn = pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={FABRIC_SERVER};DATABASE={FABRIC_DB};",
        attrs_before={1256: token_struct},
        autocommit=True,
    )
    return conn


# ─── PHASE 1: DEPLOY TABLES FROM DDL ────────────────────────────────────────

def deploy_ddl():
    logger.info("=== Phase 1: Deploying Fabric DDL ===")
    conn = get_connection()
    cur = conn.cursor()

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
                continue  # Fabric Lakehouse uses dbo
            elif "CREATE TABLE" in upper:
                # Redirect schema to dbo, remove IF NOT EXISTS (Fabric doesn't support it)
                modified = re.sub(r'\[(\w+)\]\.\[', '[dbo].[', stmt)
                modified = modified.replace("CREATE TABLE IF NOT EXISTS", "CREATE TABLE")
                modified = modified.replace("IF NOT EXISTS ", "")
                # Remove CONSTRAINT lines (Fabric Lakehouse has limited constraint support)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+[^)]+\)', '', modified)

                try:
                    cur.execute(modified)
                    created += 1
                except Exception as e:
                    err = str(e)
                    if "already exists" in err.lower() or "already an object" in err.lower():
                        pass
                    elif created < 2:
                        logger.warning(f"    {fname}: {err[:100]}")

        total_created += created
        if created > 0:
            logger.info(f"  {fname}: {created} tables")

    # Verify
    cur.execute("SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE'")
    actual = cur.fetchone()[0]

    conn.close()
    logger.info(f"\nPhase 1 complete: {total_created} created, {actual} total tables")
    return actual


# ─── PHASE 2: GENERATE DATA ─────────────────────────────────────────────────

def determine_row_count(table_name, col_count, fk_count):
    name = table_name.lower()
    if name.startswith("dim") or any(k in name for k in ["status","type","category","channel",
            "segment","grade","region","currency","country","frequency","priority"]):
        return random.randint(15, 50)
    if name.startswith("fact") or any(k in name for k in ["transaction","event","log","history",
            "audit","activity","interaction","message","session","payment","record"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["metric","analytics","insight","score","performance","snapshot","report"]):
        return random.randint(300, 700)
    if any(k in name for k in ["customer","client","contact","account","employee","partner","prospect"]):
        return random.randint(200, 500)
    if any(k in name for k in ["product","service","plan","offer","contract","agreement"]):
        return random.randint(100, 300)
    if fk_count >= 2: return random.randint(300, 800)
    if col_count <= 5: return random.randint(20, 60)
    return random.randint(100, 300)


def generate_value(col_name, col_type, col_size, nullable, is_pk, row_idx):
    name = col_name.lower()
    dtype = col_type.upper() if col_type else "VARCHAR"

    if nullable and not is_pk and random.random() < Q_NULL:
        return None
    if is_pk and ("INT" in dtype or "BIGINT" in dtype):
        return row_idx + 1

    # BIT
    if "BIT" in dtype:
        if "active" in name or "enabled" in name: return 1 if random.random() < 0.85 else 0
        if "consent" in name: return 1 if random.random() < 0.70 else 0
        if "flag" in name and "risk" in name: return 1 if random.random() < 0.03 else 0
        return random.choice([0, 1])

    # INT
    if "INT" in dtype and "BIG" not in dtype:
        if "age" in name: return random.randint(18, 78)
        if "household" in name: return random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0]
        if "year" in name: return random.randint(2019, 2026)
        if "score" in name or "rating" in name: return random.randint(0, 100)
        if "count" in name or "quantity" in name: return random.randint(0, 1000)
        if "duration" in name: return random.randint(1, 120)
        return random.randint(1, 9999)

    if "BIGINT" in dtype: return random.randint(1, 999999)

    # DECIMAL / FLOAT
    if "DECIMAL" in dtype or "FLOAT" in dtype or "MONEY" in dtype:
        if any(k in name for k in ["amount","balance","total","price","value","revenue","cost","fee","salary"]):
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
        if "start" in name: return date(2022,1,1)+timedelta(days=random.randint(0,1000))
        if "end" in name or "expir" in name: return date(2025,1,1)+timedelta(days=random.randint(0,1500))
        if "report" in name or "month" in name: return date(2025, random.randint(1,12), 1)
        return date(2023,1,1)+timedelta(days=random.randint(0,1100))

    # DATETIME2
    if "DATETIME" in dtype:
        base = datetime(2023,1,1)
        ts = base + timedelta(days=random.randint(0,1100), hours=random.randint(0,23))
        if ("created" in name or "loaded" in name) and random.random() < Q_STALE:
            ts = datetime(2025,1,1) + timedelta(days=random.randint(-180, 0))
        return ts

    # UNIQUEIDENTIFIER
    if "UNIQUE" in dtype:
        import uuid
        return str(uuid.uuid4())

    # VARCHAR / NVARCHAR / TEXT
    if "CHAR" in dtype or "TEXT" in dtype:
        ml = min(col_size or 255, 255)
        return _gen_fabric_text(name, ml)

    return f"Val_{row_idx}"


def _gen_fabric_text(name, ml):
    # Names - PascalCase for Fabric
    if any(k in name for k in ["firstname","givenname"]):
        return random.choice(FIRST_NAMES)[:ml]
    if any(k in name for k in ["lastname","surname","familyname"]):
        return random.choice(LAST_NAMES)[:ml]
    if any(k in name for k in ["fullname","customername","clientname","contactname","employeename",
            "companyname","entityname","managername"]):
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
    if "name" in name and not any(k in name for k in ["file","table","column"]):
        if any(k in name for k in ["product","service","plan","branch"]):
            return random.choice(PRODUCT_NAMES)[:ml]
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
    if "email" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"[:ml]
    if "phone" in name or "mobile" in name:
        return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"[:ml]
    if "gender" in name: return random.choices(["M","F","X"], weights=[48,48,4])[0]
    if "country" in name: return random.choice(COUNTRIES)[:ml]
    if "city" in name: return random.choice(["Amsterdam","Rotterdam","Berlin","London","Paris"])[:ml]
    if "currency" in name: return random.choice(CURRENCIES)[:ml]
    if "language" in name: return random.choice(["NL","EN","DE","FR","ES"])[:ml]
    if "status" in name or "state" in name: return random.choice(STATUSES)[:ml]
    if "risk" in name and any(k in name for k in ["level","rating","band","grade"]):
        return random.choice(RISK_LEVELS)[:ml]
    if "segment" in name: return random.choice(CUSTOMER_SEGMENTS)[:ml]
    if "channel" in name: return random.choice(CHANNELS)[:ml]
    if "industry" in name or "sector" in name: return random.choice(INDUSTRIES)[:ml]
    if "department" in name or "dept" in name: return random.choice(DEPARTMENTS)[:ml]
    if "region" in name: return random.choice(REGIONS)[:ml]
    if "businessline" in name or "business_line" in name: return random.choice(BUSINESS_LINES)[:ml]
    if "producttype" in name: return random.choice(PRODUCT_TYPES)[:ml]
    if "type" in name: return random.choice(["Standard","Premium","Basic","Enterprise"])[:ml]
    if any(k in name for k in ["description","desc","comment","note","summary"]):
        return random.choice([
            "Corporate BI reporting metric",
            "Monthly finance consolidation record",
            "HR workforce analytics data point",
            "Governance catalog entry",
            "Compliance dashboard indicator",
        ])[:ml]
    if "code" in name:
        if "country" in name: return random.choice(COUNTRIES)
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"[:ml]
    if name.endswith("id") or "identifier" in name or "ref" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"[:ml]
    if "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"[:ml]
    return f"Masreph_{random.randint(1000,9999)}"[:ml]


def generate_data():
    logger.info("\n=== Phase 2: Generating Fabric Data ===")
    conn = get_connection()
    cur = conn.cursor()

    # Get all tables
    cur.execute("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME")
    tables = [r[0] for r in cur.fetchall()]
    logger.info(f"Found {len(tables)} tables")

    grand_total = 0
    for table in tables:
        # Get columns
        cur.execute(f"""
            SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.IS_NULLABLE,
                   CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 1 ELSE 0 END
            FROM INFORMATION_SCHEMA.COLUMNS c
            LEFT JOIN (
                SELECT ku.COLUMN_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku ON tc.CONSTRAINT_NAME=ku.CONSTRAINT_NAME
                WHERE tc.TABLE_NAME='{table}' AND tc.CONSTRAINT_TYPE='PRIMARY KEY'
            ) pk ON c.COLUMN_NAME=pk.COLUMN_NAME
            WHERE c.TABLE_NAME='{table}'
            ORDER BY c.ORDINAL_POSITION
        """)
        columns = [{"name":r[0],"type":r[1],"size":r[2],"nullable":r[3]=="YES","is_pk":r[4]==1} for r in cur.fetchall()]

        if not columns:
            continue

        num_rows = determine_row_count(table, len(columns), 0)

        # Build and execute INSERTs in batches
        col_list = ", ".join(f"[{c['name']}]" for c in columns)
        placeholders = ", ".join(["?"] * len(columns))
        insert_sql = f"INSERT INTO [dbo].[{table}] ({col_list}) VALUES ({placeholders})"

        inserted = 0
        batch_size = 100
        for batch_start in range(0, num_rows, batch_size):
            batch_end = min(batch_start + batch_size, num_rows)
            rows = []
            for i in range(batch_start, batch_end):
                row = tuple(generate_value(c["name"], c["type"], c["size"], c["nullable"], c["is_pk"], i) for c in columns)
                rows.append(row)

            try:
                cur.executemany(insert_sql, rows)
                inserted += len(rows)
            except Exception:
                for row in rows:
                    try:
                        cur.execute(insert_sql, row)
                        inserted += 1
                    except Exception:
                        pass

        grand_total += inserted
        if inserted > 0 and (tables.index(table) % 10 == 0 or inserted > 200):
            logger.info(f"  {table}: {inserted} rows")

    conn.close()
    logger.info(f"\n=== Fabric Data Complete: {grand_total} total rows ===")
    return grand_total


def main():
    logger.info("=== Microsoft Fabric: MasrephCorporateBI ===")
    table_count = deploy_ddl()
    total_rows = generate_data()
    logger.info(f"\n=== DONE: {table_count} tables, {total_rows} rows ===")


if __name__ == "__main__":
    main()
