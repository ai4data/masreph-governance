#!/usr/bin/env python3
"""
Deploy Fabric Warehouse with one schema per source system.
Warehouse: MasrephCorporateBI_WH

Architecture:
  MasrephCorporateBI_WH.dataedo_crdm
  MasrephCorporateBI_WH.finance_reporting
  MasrephCorporateBI_WH.sharepoint
  MasrephCorporateBI_WH.hr_workforce
  ... etc
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
FABRIC_SERVER = "bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com"
FABRIC_DB = "MasrephCorporateBI_WH"
TENANT_ID = "os.getenv('FABRIC_TENANT_ID')"
CLIENT_ID = "os.getenv('FABRIC_CLIENT_ID')"
CLIENT_SECRET = "os.getenv('FABRIC_CLIENT_SECRET')"

Q_NULL = 0.03

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
SEGMENTS = ["MassMarket","Affluent","HighNetWorth","SME","MidCorporate"]
DEPARTMENTS = ["Sales","Finance","Risk Management","Operations","IT","Legal","Compliance","HR"]
PRODUCT_NAMES = ["Masreph Auto Lease Plus","Masreph Fleet Pro","Masreph Home Finance Direct",
    "Masreph Business Credit 360","Masreph Savings Smart"]
REGIONS = ["EMEA","APAC","Americas","Nordics"]
BUSINESS_LINES = ["Leasing","Commercial Finance","Consumer Finance","Mobility Solutions"]


def get_connection():
    cred = ClientSecretCredential(TENANT_ID, CLIENT_ID, CLIENT_SECRET)
    token = cred.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    return pyodbc.connect(
        f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={FABRIC_SERVER};DATABASE={FABRIC_DB};",
        attrs_before={1256: token_struct}, autocommit=True,
    )


def gen_value(col_name, col_type, col_size, nullable, is_pk, row_idx):
    name = col_name.lower()
    dtype = (col_type or "VARCHAR").upper()
    ml = min(col_size or 255, 255)

    if nullable and not is_pk and random.random() < Q_NULL: return None
    if is_pk and ("INT" in dtype): return row_idx + 1

    if "BIT" in dtype:
        if "active" in name: return 1 if random.random() < 0.85 else 0
        if "consent" in name: return 1 if random.random() < 0.70 else 0
        return random.choice([0, 1])
    if "INT" in dtype and "BIG" not in dtype:
        if "age" in name: return random.randint(18, 78)
        if "household" in name: return random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0]
        if "year" in name: return random.randint(2019, 2026)
        if "score" in name or "rating" in name: return random.randint(0, 100)
        if "count" in name or "quantity" in name: return random.randint(0, 1000)
        return random.randint(1, 9999)
    if "BIGINT" in dtype: return random.randint(1, 999999)
    if "DECIMAL" in dtype or "FLOAT" in dtype:
        if any(k in name for k in ["amount","balance","total","price","value","revenue","cost","fee","salary"]):
            return round(random.uniform(500, 2000000), 2)
        if any(k in name for k in ["rate","interest","margin"]):
            return round(random.uniform(0.5, 15.0), 4)
        if any(k in name for k in ["percentage","pct","ratio"]):
            return round(random.uniform(0, 100), 2)
        if "score" in name: return round(random.uniform(0, 100), 2)
        return round(random.uniform(0, 99999), 2)
    if dtype == "DATE":
        if "birth" in name: return date(2026-random.randint(18,78), random.randint(1,12), random.randint(1,28))
        if "report" in name or "month" in name: return date(2025, random.randint(1,12), 1)
        return date(2023,1,1)+timedelta(days=random.randint(0,1100))
    if "DATETIME" in dtype:
        return datetime(2023,1,1) + timedelta(days=random.randint(0,1100), hours=random.randint(0,23))
    if "UNIQUE" in dtype:
        import uuid; return str(uuid.uuid4())
    if "CHAR" in dtype or "TEXT" in dtype:
        if any(k in name for k in ["firstname","givenname"]): return random.choice(FIRST_NAMES)[:ml]
        if any(k in name for k in ["lastname","surname"]): return random.choice(LAST_NAMES)[:ml]
        if any(k in name for k in ["fullname","customername","clientname","contactname","employeename","companyname","entityname","managername"]):
            return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
        if "name" in name and "file" not in name and "table" not in name:
            if any(k in name for k in ["product","service","plan","branch"]): return random.choice(PRODUCT_NAMES)[:ml]
            return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
        if "email" in name: return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"[:ml]
        if "phone" in name: return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"[:ml]
        if "gender" in name: return random.choices(["M","F","X"], weights=[48,48,4])[0]
        if "country" in name: return random.choice(COUNTRIES)[:ml]
        if "currency" in name: return random.choice(CURRENCIES)[:ml]
        if "status" in name or "state" in name: return random.choice(STATUSES)[:ml]
        if "risk" in name and any(k in name for k in ["level","rating","band"]): return random.choice(RISK_LEVELS)[:ml]
        if "segment" in name: return random.choice(SEGMENTS)[:ml]
        if "channel" in name: return random.choice(CHANNELS)[:ml]
        if "department" in name or "dept" in name: return random.choice(DEPARTMENTS)[:ml]
        if "region" in name: return random.choice(REGIONS)[:ml]
        if "businessline" in name: return random.choice(BUSINESS_LINES)[:ml]
        if "type" in name: return random.choice(["Standard","Premium","Basic","Enterprise"])[:ml]
        if any(k in name for k in ["description","comment","note","summary"]): return "Corporate BI reporting metric"[:ml]
        if "code" in name: return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"[:ml]
        if name.endswith("id") or "identifier" in name: return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"[:ml]
        if "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"[:ml]
        return f"Masreph_{random.randint(1000,9999)}"[:ml]
    return f"Val_{row_idx}"


def determine_rows(table_name):
    name = table_name.lower()
    if name.startswith("dim") or any(k in name for k in ["status","type","category","channel","segment","priority"]):
        return random.randint(15, 50)
    if name.startswith("fact") or any(k in name for k in ["transaction","event","log","history","activity","record"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["metric","analytics","insight","score","performance","snapshot","report"]):
        return random.randint(300, 700)
    if any(k in name for k in ["customer","client","contact","account","employee","partner"]):
        return random.randint(200, 500)
    if any(k in name for k in ["product","service","contract","agreement"]): return random.randint(100, 300)
    return random.randint(50, 200)


def main():
    logger.info("=== Fabric: Schema per Source System ===")
    conn = get_connection()
    cur = conn.cursor()

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    # Phase 1: Create schemas and tables
    logger.info("\n=== Phase 1: Deploy ===")
    total_tables = 0

    for filepath in sql_files:
        schema_name = filepath.stem  # e.g., "dataedocrdm", "financereporting"

        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        # Create schema
        try:
            cur.execute(f"CREATE SCHEMA [{schema_name}]")
        except: pass  # Already exists

        created = 0
        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt: continue
            upper = stmt.upper()

            if "CREATE SCHEMA" in upper: continue
            if "CREATE TABLE" in upper:
                # Redirect to our schema
                modified = re.sub(r'\[(\w+)\]\.\[', f'[{schema_name}].[', stmt)
                modified = modified.replace("CREATE TABLE IF NOT EXISTS", "CREATE TABLE")
                modified = modified.replace("IF NOT EXISTS ", "")
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+[^)]+\)', '', modified)
                # Fix INT precision issues for Fabric
                modified = re.sub(r'\bINT\b(?!\s*\))', 'INT', modified)
                modified = modified.replace('DATETIME2', 'DATETIME2')

                try:
                    cur.execute(modified)
                    created += 1
                except Exception as e:
                    err = str(e)
                    if "already" in err.lower(): pass

        if created > 0:
            total_tables += created
            logger.info(f"  {schema_name}: {created} tables")

    logger.info(f"\nPhase 1 complete: {total_tables} tables")

    # Phase 2: Generate data
    logger.info("\n=== Phase 2: Generate data ===")
    conn2 = get_connection()
    cur2 = conn2.cursor()

    cur2.execute("SELECT DISTINCT TABLE_SCHEMA FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA') ORDER BY TABLE_SCHEMA")
    schemas = [r[0] for r in cur2.fetchall()]
    logger.info(f"Found {len(schemas)} schemas")

    grand_total = 0
    for schema in schemas:
        cur2.execute(f"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='{schema}' AND TABLE_TYPE='BASE TABLE'")
        tables = [r[0] for r in cur2.fetchall()]
        if not tables: continue

        schema_total = 0
        for table in tables:
            cur2.execute(f"""
                SELECT c.COLUMN_NAME, c.DATA_TYPE, c.CHARACTER_MAXIMUM_LENGTH, c.IS_NULLABLE, 0 as IS_PK
                FROM INFORMATION_SCHEMA.COLUMNS c
                WHERE c.TABLE_SCHEMA='{schema}' AND c.TABLE_NAME='{table}'
                ORDER BY c.ORDINAL_POSITION
            """)
            columns = [{"name":r[0],"type":r[1],"size":r[2],"nullable":r[3]=="YES","is_pk":r[4]==1} for r in cur2.fetchall()]
            if not columns: continue

            num_rows = determine_rows(table)
            col_list = ", ".join(f"[{c['name']}]" for c in columns)
            placeholders = ", ".join(["?"] * len(columns))
            insert_sql = f"INSERT INTO [{schema}].[{table}] ({col_list}) VALUES ({placeholders})"

            inserted = 0
            batch_size = 100
            for bs in range(0, num_rows, batch_size):
                be = min(bs + batch_size, num_rows)
                rows = [tuple(gen_value(c["name"],c["type"],c["size"],c["nullable"],c["is_pk"],i) for c in columns) for i in range(bs,be)]
                try:
                    cur2.executemany(insert_sql, rows)
                    inserted += len(rows)
                except:
                    for row in rows:
                        try:
                            cur2.execute(insert_sql, row)
                            inserted += 1
                        except: pass

            schema_total += inserted

        grand_total += schema_total
        logger.info(f"  {schema}: {len(tables)} tables, {schema_total} rows")

    conn2.close()
    logger.info(f"\n=== DONE: {total_tables} tables, {grand_total} rows ===")


if __name__ == "__main__":
    main()
