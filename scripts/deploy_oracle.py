#!/usr/bin/env python3
"""
Deploy Oracle Autonomous DB tables and generate data.
Database: MASREPHDB (Oracle Cloud Free Tier)
Uses schemas per source system (Oracle users).

Oracle quality profile: 60-75% (legacy ERP, 20+ years old)
- 8-12% NULLs
- Default/placeholder values ("XXXX", "???", "CHANGE_ME")
- Legacy codes nobody documents
- Amounts in different currencies without indicator
- Archived records mixed with active
"""

import os
import re
import json
import random
import string
import oracledb
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "oracle")
WALLET_DIR = os.path.join(os.path.dirname(__file__), "..", "config", "oracle_wallet")

ORA_USER = "ADMIN"
ORA_PASSWORD = "os.getenv('ORACLE_PASSWORD')"
ORA_DSN = "masrephdb_low"
ORA_WALLET_PASSWORD = "os.getenv('ORACLE_PASSWORD')"

# Quality - worst quality, legacy system
Q_NULL = 0.10
Q_PLACEHOLDER = 0.05
Q_STALE = 0.10
Q_LEGACY_CODE = 0.04

# Data pools - UPPERCASE for Oracle
FIRST_NAMES = ["JAN","PIETER","MARIA","SOPHIE","LARS","ANNA","THOMAS","EVA","DAAN","EMMA",
    "BRAM","LISA","LUCAS","JULIA","SVEN","NINA","MARK","LOTTE","AHMED","FATIMA",
    "JAMES","SARAH","ROBERT","EMILY","CARLOS","ISABELLA","HANS","GRETA","PEDRO","ANA"]
LAST_NAMES = ["VAN DEN BERG","DE JONG","JANSEN","DE VRIES","VAN DIJK","BAKKER","VISSER",
    "SMIT","MEIJER","DE BOER","MULLER","SCHMIDT","SCHNEIDER","SMITH","JOHNSON",
    "WILLIAMS","BROWN","GARCIA","MARTINEZ","CHEN","WANG","PATEL","SHARMA","DUBOIS"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["ACTV","INACTV","PEND","SUSP","CLSD"]
STATUSES_LEGACY = ["A","I","P","S","C","1","0","Y","N","ACTIVE","INACTIVE"]
RISK_LEVELS = ["LOW","MED","HIGH","CRIT"]
PLACEHOLDER_VALUES = ["XXXX","???","N/A","TBD","UNKNOWN","CHANGE_ME","---","(NONE)","DEFAULT","PENDING"]
LEGACY_CODES = ["XQ7","MR3","ZZ9","AB1","QQ0","TT5","FF8","WW2","PP4","NN6"]
PRODUCT_TYPES = ["AUTO_LS","EQUIP_LS","MRTG","PERS_LN","BUS_LN","CRED_CD"]
INDUSTRIES = ["FIN_SVC","MFCTG","RETAIL","HLTHCR","TECH","RE","AUTO","ENRGY"]
DEPARTMENTS = ["SLS","FIN","RISK","OPS","IT","LEGAL","COMPL","HR"]
CHANNELS = ["BRNCH","PHONE","WEB","MAIL","FAX","AGENT"]


def get_connection():
    return oracledb.connect(
        user=ORA_USER, password=ORA_PASSWORD, dsn=ORA_DSN,
        config_dir=WALLET_DIR, wallet_location=WALLET_DIR,
        wallet_password=ORA_WALLET_PASSWORD,
    )


# ─── PHASE 1: DEPLOY DDL ────────────────────────────────────────────────────

def deploy_ddl():
    logger.info("=== Phase 1: Deploying Oracle DDL ===")
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

            if "CREATE USER" in upper or "GRANT " in upper:
                continue
            elif "CREATE TABLE" in upper:
                # Replace schema.table with just table (use ADMIN schema)
                modified = re.sub(r'(\w+)\.(\w+)', r'\2', stmt, count=1)
                # Fix: remove IF NOT EXISTS (Oracle doesn't support it)
                modified = modified.replace("IF NOT EXISTS ", "")
                # Remove unsupported constraint syntax
                modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', modified)

                try:
                    cur.execute(modified)
                    conn.commit()
                    created += 1
                except Exception as e:
                    err = str(e)
                    if "ORA-00955" in err:  # name already used
                        pass
                    elif created < 3:
                        logger.warning(f"    {fname}: {err[:80]}")

        total_created += created
        if created > 0:
            logger.info(f"  {fname}: {created} tables")

    # Verify
    cur.execute("SELECT COUNT(*) FROM user_tables")
    actual = cur.fetchone()[0]

    conn.close()
    logger.info(f"\nPhase 1 complete: {total_created} created, {actual} total tables")
    return actual


# ─── PHASE 2: GENERATE DATA ─────────────────────────────────────────────────

def determine_row_count(table_name, col_count):
    name = table_name.upper()
    if any(k in name for k in ["STAT","TYP","CAT","CONF","LKUP","REF","CHAN","SEG","GRAD","CNTRY","CURR","FREQ"]):
        return random.randint(15, 50)
    if any(k in name for k in ["TXN","EVNT","LOG","HIST","AUDIT","ACTV","PYMT","XFER","ENTRY","REC"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["MSTR","CNTRCT","AGMT","ACCT","PRTFL","INSTR","PROD"]):
        return random.randint(100, 300)
    if any(k in name for k in ["CUST","CLNT","EMP","PRTNR"]):
        return random.randint(200, 500)
    if col_count <= 5:
        return random.randint(20, 60)
    return random.randint(100, 300)


def generate_value(col_name, col_type, col_size, nullable, is_pk, row_idx):
    name = col_name.upper()
    dtype = col_type.upper() if col_type else "VARCHAR2"

    # Quality: high NULL rate for legacy
    if nullable and not is_pk and random.random() < Q_NULL:
        return None

    # Quality: placeholder values
    if not is_pk and "ID" not in name and random.random() < Q_PLACEHOLDER:
        if "CHAR" in dtype or "CLOB" in dtype:
            return random.choice(PLACEHOLDER_VALUES)

    if is_pk:
        return row_idx + 1

    # NUMBER (integer or decimal)
    if "NUMBER" in dtype:
        # Check if it's boolean (NUMBER(1))
        if col_size and col_size <= 1:
            if "ACTV" in name or "FLG" in name: return 1 if random.random() < 0.80 else 0
            if "PEP" in name or "SNCTN" in name: return 1 if random.random() < 0.03 else 0
            return random.choice([0, 1])

        # Integer-like
        if any(k in name for k in ["AGE","YRS"]):
            return random.randint(18, 78)
        if "YR" in name or "YEAR" in name:
            return random.randint(2005, 2026)
        if any(k in name for k in ["CNT","QTY","NBR","NUM"]):
            return random.randint(0, 1000)
        if "SCORE" in name or "RATING" in name:
            return random.randint(0, 100)

        # Decimal-like (amounts, rates)
        if any(k in name for k in ["AMT","BAL","TOT","PRC","VAL","REV","CST","FEE"]):
            return round(random.uniform(500, 2000000), 2)
        if any(k in name for k in ["RT","PCT","RATIO","MRGN"]):
            return round(random.uniform(0.5, 15.0), 4)

        return random.randint(1, 99999)

    # DATE
    if "DATE" in dtype or "TIMESTAMP" in dtype:
        if "BIRTH" in name or "DOB" in name:
            return datetime(2026 - random.randint(18, 78), random.randint(1, 12), random.randint(1, 28))
        if "START" in name or "EFF" in name or "INCEP" in name:
            d = datetime(2015, 1, 1) + timedelta(days=random.randint(0, 3500))
            # Quality: very old stale dates for legacy
            if random.random() < Q_STALE:
                d = datetime(2005, 1, 1) + timedelta(days=random.randint(0, 1000))
            return d
        if "END" in name or "EXP" in name or "MTRTY" in name:
            return datetime(2025, 1, 1) + timedelta(days=random.randint(0, 2000))
        if "CR" in name or "CREAT" in name:
            d = datetime(2020, 1, 1) + timedelta(days=random.randint(0, 2000))
            if random.random() < Q_STALE:
                d = datetime(2008, 1, 1) + timedelta(days=random.randint(0, 1500))
            return d
        if "UPD" in name or "MOD" in name:
            return datetime(2024, 1, 1) + timedelta(days=random.randint(0, 700))
        return datetime(2020, 1, 1) + timedelta(days=random.randint(0, 2000))

    # RAW (UUID)
    if "RAW" in dtype:
        return bytes.fromhex(os.urandom(16).hex())

    # CLOB
    if "CLOB" in dtype:
        return random.choice([
            "LEGACY ERP CONTRACT RECORD",
            "LEASE AGREEMENT - STANDARD TERMS",
            "INSURANCE POLICY ENDORSEMENT",
            "COLLATERAL VALUATION REPORT",
        ])

    # VARCHAR2 / CHAR
    if "CHAR" in dtype:
        ml = min(col_size or 255, 255)
        return _gen_oracle_text(name, ml)

    return str(row_idx)


def _gen_oracle_text(name, ml):
    # Quality: legacy codes
    if random.random() < Q_LEGACY_CODE and "ID" not in name and "NM" not in name:
        return random.choice(LEGACY_CODES)[:ml]

    # Names - UPPERCASE abbreviated Oracle style
    if any(k in name for k in ["CUST_NM","CLNT_NM","EMP_NM","PRTNR_NM","LEGAL_NM","ENT_NM","RM_NM","LESSEE_NM"]):
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
    if "NM" in name and "FILE" not in name and "TBL" not in name:
        if any(k in name for k in ["PROD","SVC","BRNCH"]):
            return random.choice(["MASREPH AUTO LS PLUS","MASREPH FLEET PRO","MASREPH HOME FIN","MASREPH BUS CREDIT","MASREPH EQUIP LS"])[:ml]
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
    if "EMAIL" in name:
        fn = random.choice(FIRST_NAMES).lower()
        ln = random.choice(LAST_NAMES).lower().replace(" ","")
        return f"{fn}.{ln}@masreph.com"[:ml]
    if "PHONE" in name or "TEL" in name:
        return f"+{random.choice(['31','49','33','44'])} {random.randint(600000000,699999999)}"[:ml]
    if "GNDR" in name or "GENDER" in name:
        return random.choices(["M","F","X"], weights=[48,48,4])[0]
    if "CNTRY" in name or "COUNTRY" in name:
        return random.choice(COUNTRIES)[:ml]
    if "CITY" in name:
        return random.choice(["AMSTERDAM","ROTTERDAM","BERLIN","LONDON","PARIS","ZURICH"])[:ml]
    if "CURR" in name and ("CD" in name or "CODE" in name):
        return random.choice(CURRENCIES)[:ml]
    if "LANG" in name:
        return random.choice(["NL","EN","DE","FR","ES"])[:ml]
    if "STAT" in name and ("CD" in name or "CODE" in name or name.endswith("_STAT")):
        if random.random() < 0.20:
            return random.choice(STATUSES_LEGACY)[:ml]
        return random.choice(STATUSES)[:ml]
    if "RISK" in name and any(k in name for k in ["LVL","RATING","CAT","BAND"]):
        return random.choice(RISK_LEVELS)[:ml]
    if "SEG" in name:
        return random.choice(["MASS","AFFL","HNW","SME","CORP"])[:ml]
    if "CHAN" in name:
        return random.choice(CHANNELS)[:ml]
    if "INDSTRY" in name or "INDUSTRY" in name or "SCTR" in name:
        return random.choice(INDUSTRIES)[:ml]
    if "DEPT" in name:
        return random.choice(DEPARTMENTS)[:ml]
    if "PROD" in name and "TYP" in name:
        return random.choice(PRODUCT_TYPES)[:ml]
    if "TYP" in name:
        return random.choice(["STD","PREM","BASIC","ENTPR","CSTM"])[:ml]
    if any(k in name for k in ["DESC","RMRK","NOTE","COMMENT","SUMRY"]):
        return random.choice([
            "LEGACY ERP RECORD",
            "LEASE CONTRACT AMENDMENT",
            "INSURANCE POLICY UPDATE",
            "COLLATERAL REVALUATION",
            "STANDARD PROCESSING",
        ])[:ml]
    if "CD" in name or "CODE" in name:
        if "CNTRY" in name: return random.choice(COUNTRIES)[:ml]
        if "CURR" in name: return random.choice(CURRENCIES)[:ml]
        return f"{''.join(random.choices(string.ascii_uppercase,k=2))}{random.randint(100,999)}"[:ml]
    if name.endswith("_ID") or "IDENTIFIER" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}{random.randint(10000,99999)}"[:ml]
    if "ADDR" in name:
        return f"{random.randint(1,500)} {''.join(random.choices(string.ascii_uppercase,k=8))}"[:ml]
    if "HASH" in name:
        return ''.join(random.choices(string.hexdigits.upper(),k=min(ml,32)))[:ml]
    return f"{''.join(random.choices(string.ascii_uppercase,k=3))}{random.randint(1000,9999)}"[:ml]


def generate_data():
    logger.info("\n=== Phase 2: Generating Oracle Data ===")
    conn = get_connection()
    cur = conn.cursor()

    # Get all tables
    cur.execute("SELECT table_name FROM user_tables ORDER BY table_name")
    tables = [r[0] for r in cur.fetchall()]
    logger.info(f"Found {len(tables)} tables")

    # Truncate all
    for t in tables:
        try:
            cur.execute(f"DELETE FROM {t}")
            conn.commit()
        except Exception:
            conn.rollback()

    grand_total = 0
    for table in tables:
        # Get columns
        cur.execute(f"""
            SELECT column_name, data_type, data_length, nullable
            FROM user_tab_columns
            WHERE table_name = :1
            ORDER BY column_id
        """, [table])
        columns = [{"name":r[0], "type":r[1], "size":r[2], "nullable":r[3]=="Y"} for r in cur.fetchall()]

        if not columns:
            continue

        # Check for PK
        cur.execute(f"""
            SELECT cols.column_name FROM all_constraints cons
            JOIN all_cons_columns cols ON cons.constraint_name = cols.constraint_name
            WHERE cons.table_name = :1 AND cons.constraint_type = 'P'
        """, [table])
        pk_cols = {r[0] for r in cur.fetchall()}

        num_rows = determine_row_count(table, len(columns))

        col_names = [c["name"] for c in columns]
        placeholders = ", ".join([f":{i+1}" for i in range(len(columns))])
        insert_sql = f"INSERT INTO {table} ({', '.join(col_names)}) VALUES ({placeholders})"

        rows = []
        for i in range(num_rows):
            row = tuple(
                generate_value(c["name"], c["type"], c["size"], c["nullable"], c["name"] in pk_cols, i)
                for c in columns
            )
            rows.append(row)

        # Insert in batches
        inserted = 0
        batch_size = 100
        for bs in range(0, len(rows), batch_size):
            batch = rows[bs:bs+batch_size]
            try:
                cur.executemany(insert_sql, batch)
                conn.commit()
                inserted += len(batch)
            except Exception:
                conn.rollback()
                for row in batch:
                    try:
                        cur.execute(insert_sql, row)
                        conn.commit()
                        inserted += 1
                    except Exception:
                        conn.rollback()

        grand_total += inserted
        if inserted > 0 and (tables.index(table) % 10 == 0 or inserted > 200):
            logger.info(f"  {table}: {inserted} rows")

    conn.close()
    logger.info(f"\n=== Oracle Data Complete: {grand_total} total rows ===")
    return grand_total


def main():
    logger.info("=== Oracle: MASREPHDB (Legacy ERP) ===")
    table_count = deploy_ddl()
    total_rows = generate_data()
    logger.info(f"\n=== DONE: {table_count} tables, {total_rows} rows ===")


if __name__ == "__main__":
    main()
