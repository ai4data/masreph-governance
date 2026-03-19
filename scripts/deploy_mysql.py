#!/usr/bin/env python3
"""
Deploy MySQL DDL schemas and generate realistic sample data.
Creates one DATABASE per source system (DDL file) — MySQL's equivalent of schemas.

MySQL quality profile: 85-92% (digital apps, 3 years old)
"""

import os
import re
import json
import random
import string
import mysql.connector
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "mysql")
DB_PREFIX = "masreph_"  # All databases prefixed with masreph_

MYSQL_HOST = "localhost"
MYSQL_PORT = 3306
MYSQL_USER = "root"
MYSQL_PASSWORD = "os.getenv('MYSQL_PASSWORD')"

# Quality settings
Q_NULL = 0.03
Q_STALE = 0.04
Q_ENCODING = 0.02

# Data pools
FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Michiel","Fleur",
    "Daan","Emma","Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte",
    "Ahmed","Fatima","James","Sarah","Robert","Emily","Carlos","Isabella","Jean","Marie",
    "Hans","Greta","Klaus","Pedro","Ana","Raj","Priya","Wei","Mei","Yuki"]
LAST_NAMES = ["van den Berg","de Jong","Jansen","de Vries","van Dijk","Bakker","Visser",
    "Smit","Meijer","de Boer","Muller","Schmidt","Schneider","Fischer","Weber",
    "Smith","Johnson","Williams","Brown","Jones","Garcia","Martinez","Rodriguez",
    "Chen","Wang","Li","Patel","Sharma","Kumar","Dubois","Moreau"]
DIACRITICS = ["M\u00fcller","Bj\u00f6rk","Ren\u00e9e","Fran\u00e7ois","Jos\u00e9","S\u00f8ren","L\u00e1szl\u00f3"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["active","inactive","pending","suspended","closed"]
RISK_LEVELS = ["low","medium","high","critical"]
CHANNELS = ["web_portal","mobile_app","branch","phone","email","api","chatbot"]
INDUSTRIES = ["Financial Services","Manufacturing","Retail","Healthcare","Technology","Real Estate","Automotive","Energy"]
DEPARTMENTS = ["Sales","Finance","Risk Management","Operations","IT","Legal","Compliance","HR"]
CITIES = ["Amsterdam","Rotterdam","Berlin","Munich","Paris","London","New York","Singapore","Tokyo"]
PRODUCT_NAMES = ["Masreph Auto Lease Plus","Masreph Fleet Pro","Masreph Home Finance Direct",
    "Masreph Business Credit 360","Masreph Savings Smart","Masreph Equipment Lease Flex"]
LANGUAGES = ["nl","en","de","fr","es","it","pt","ja"]
GENDER_CODES = ["M","F","X"]
MARITAL = ["single","married","divorced","widowed"]
EMPLOYMENT = ["employed","self_employed","unemployed","retired","student"]
CUSTOMER_SEGMENTS = ["mass_market","affluent","high_net_worth","sme","mid_corporate"]
SENTIMENT = ["very_positive","positive","neutral","negative","very_negative"]
FEEDBACK_CATS = ["product_quality","service_speed","digital_experience","pricing","complaint","suggestion"]
PRODUCT_TYPES = ["auto_lease","mortgage","personal_loan","credit_card","savings","equipment_lease"]
STREETS = ["Keizersgracht","Herengracht","Main Street","Friedrichstrasse","Rue de Rivoli","Oxford Street","Broadway"]


def get_connection(database=None):
    params = {"host": MYSQL_HOST, "port": MYSQL_PORT, "user": MYSQL_USER, "password": MYSQL_PASSWORD}
    if database:
        params["database"] = database
    return mysql.connector.connect(**params)


# ─── PHASE 1: DEPLOY ────────────────────────────────────────────────────────

def deploy_all():
    logger.info("=== Phase 1: Deploying MySQL (one DB per source system) ===")

    conn = get_connection()
    cur = conn.cursor()

    # Drop old single database if exists
    cur.execute("DROP DATABASE IF EXISTS masreph_digital")
    conn.commit()
    logger.info("Dropped old masreph_digital (if existed)")

    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    db_stats = {}

    for filepath in sql_files:
        fname = filepath.stem  # filename without .sql
        db_name = DB_PREFIX + fname

        # Create database
        cur.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        cur.execute(f"USE `{db_name}`")
        conn.commit()

        # Read and parse DDL
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
        cleaned = "\n".join(lines)
        raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

        created = 0
        fk_stmts = []

        for stmt in raw_stmts:
            stmt = stmt.strip()
            if not stmt:
                continue
            stmt_upper = stmt.upper()

            try:
                if "CREATE TABLE" in stmt_upper:
                    cur.execute(stmt + ";")
                    conn.commit()
                    created += 1
                elif "ALTER TABLE" in stmt_upper and "FOREIGN KEY" in stmt_upper:
                    fk_stmts.append(stmt + ";")
                elif "CREATE INDEX" in stmt_upper:
                    cur.execute(stmt + ";")
                    conn.commit()
            except mysql.connector.errors.ProgrammingError as e:
                if e.errno != 1050:  # Not "table already exists"
                    pass
            except Exception:
                pass

        # Add FKs
        fk_ok = 0
        for stmt in fk_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
                fk_ok += 1
            except Exception:
                pass

        db_stats[db_name] = {"tables": created, "fks": fk_ok, "file": fname}
        logger.info(f"  {db_name}: {created} tables, {fk_ok} FKs")

    conn.close()
    return db_stats


# ─── PHASE 2: GENERATE DATA ─────────────────────────────────────────────────

def determine_row_count(table_name, columns, fk_info):
    name = table_name.lower()
    if any(k in name for k in ["status","type","category","config","setting","lookup","channel",
            "segment","grade","region","currency","country","frequency","direction","priority",
            "severity","source_system","outcome"]):
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
    if len(fk_info) >= 2:
        return random.randint(300, 800)
    if len(columns) <= 5:
        return random.randint(20, 60)
    return random.randint(100, 300)


def generate_value(col, row_idx, fk_ids, pk_cols):
    name = col["name"].lower()
    dtype = col["data_type"].lower()
    nullable = col["nullable"]
    max_len = min(col["max_length"] or 255, 255)
    precision = col["precision"]
    scale = col["scale"]

    if nullable and name not in pk_cols and random.random() < Q_NULL:
        return None
    if name in fk_ids and fk_ids[name]:
        return random.choice(fk_ids[name])
    if name in pk_cols:
        if dtype in ("int","bigint","smallint","mediumint"): return row_idx + 1
        return row_idx + 1

    # Boolean
    if dtype == "tinyint":
        if "active" in name or "enabled" in name: return 1 if random.random() < 0.85 else 0
        if "consent" in name or "opt_in" in name: return 1 if random.random() < 0.70 else 0
        if "flag" in name and ("risk" in name or "fraud" in name): return 1 if random.random() < 0.03 else 0
        if "archived" in name or "deleted" in name: return 1 if random.random() < 0.10 else 0
        if "bounced" in name: return 1 if random.random() < 0.08 else 0
        return random.choice([0, 1])

    # Integer
    if dtype in ("int","bigint","smallint","mediumint"):
        if "age" in name: return random.randint(18, 78)
        if "household" in name: return random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0]
        if "year" in name: return random.randint(2019, 2026)
        if "score" in name or "rating" in name:
            if "nps" in name: return random.randint(-100, 100)
            if "csat" in name: return random.randint(1, 10)
            return random.randint(0, 100)
        if "count" in name or "quantity" in name or "num" in name: return random.randint(0, 1000)
        if "duration" in name: return random.randint(1, 120)
        return random.randint(1, 9999)

    # Decimal
    if dtype in ("decimal","numeric","float","double"):
        s = min(scale or 2, 4)
        mx = min(10**((precision or 18)-(scale or 2))-1, 9999999)
        if any(k in name for k in ["amount","balance","total","price","value","revenue","cost","fee","payment","income"]):
            return round(random.uniform(500, min(mx, 2000000)), min(s, 2))
        if any(k in name for k in ["rate","interest","margin"]):
            return round(random.uniform(0.5, 15.0), min(s, 4))
        if any(k in name for k in ["percentage","pct","ratio"]):
            return round(random.uniform(0, min(mx, 100)), min(s, 2))
        if "score" in name: return round(random.uniform(0, min(mx, 100)), min(s, 2))
        return round(random.uniform(0, min(mx, 99999)), min(s, 2))

    # Date
    if dtype == "date":
        if "birth" in name: return date(2026-random.randint(18,78), random.randint(1,12), random.randint(1,28))
        if "start" in name or "open" in name: return date(2022,1,1)+timedelta(days=random.randint(0,1000))
        if "end" in name or "expir" in name: return date(2025,1,1)+timedelta(days=random.randint(0,1500))
        if "due" in name: return date(2026,1,1)+timedelta(days=random.randint(0,365))
        return date(2023,1,1)+timedelta(days=random.randint(0,1100))

    # Datetime/timestamp
    if dtype in ("datetime","timestamp"):
        base = datetime(2023,1,1)
        ts = base + timedelta(days=random.randint(0,1100), hours=random.randint(0,23), minutes=random.randint(0,59))
        if ("created" in name or "start" in name) and random.random() < Q_STALE:
            ts = datetime(2019,1,1) + timedelta(days=random.randint(0,365))
        return ts

    # JSON
    if dtype == "json":
        if "tag" in name: return json.dumps(random.sample(["finance","risk","compliance","retail","premium"],k=random.randint(1,3)))
        if "config" in name or "setting" in name: return json.dumps({"language":random.choice(LANGUAGES),"notifications":True})
        if "address" in name: return json.dumps({"street":f"{random.randint(1,500)} {random.choice(STREETS)}","city":random.choice(CITIES)})
        if "metadata" in name: return json.dumps({"source":"web_app","version":f"{random.randint(1,3)}.{random.randint(0,9)}"})
        return json.dumps({"key":f"value_{random.randint(1,999)}"})

    # Text/varchar
    if dtype in ("varchar","char","text","mediumtext","longtext","tinytext"):
        return _gen_text(name, max_len)

    return f"val_{row_idx}"


def _gen_text(name, ml):
    if any(k in name for k in ["first_name","firstname","given_name"]):
        n = random.choice(FIRST_NAMES)
        if random.random() < Q_ENCODING: n = random.choice(DIACRITICS)
        return n[:ml]
    if any(k in name for k in ["last_name","lastname","surname","family"]):
        n = random.choice(LAST_NAMES)
        if random.random() < Q_ENCODING: n = random.choice(DIACRITICS)
        return n[:ml]
    if any(k in name for k in ["full_name","customer_name","client_name","contact_name","company_name",
            "entity_name","advisor_name","manager_name","campaign_name","agent_name"]):
        fn = random.choice(FIRST_NAMES)
        if random.random() < Q_ENCODING: fn = random.choice(DIACRITICS)
        return f"{fn} {random.choice(LAST_NAMES)}"[:ml]
    if "name" in name and not any(k in name for k in ["file","table","column","schema","db"]):
        if any(k in name for k in ["product","service","plan","branch","campaign"]):
            return random.choice(PRODUCT_NAMES)[:ml]
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"[:ml]
    if "email" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@{random.choice(['masreph.com','masreph.nl','gmail.com'])}"[:ml]
    if "phone" in name or "mobile" in name:
        return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"[:ml]
    if "gender" in name: return random.choices(GENDER_CODES, weights=[48,48,4])[0]
    if "marital" in name: return random.choice(MARITAL)
    if "employment" in name: return random.choice(EMPLOYMENT)
    if "country" in name: return random.choice(COUNTRIES)[:ml]
    if "city" in name: return random.choice(CITIES)[:ml]
    if "address" in name or "street" in name: return f"{random.randint(1,500)} {random.choice(STREETS)}"[:ml]
    if "postal" in name or "zip" in name: return f"{random.randint(1000,9999)}{random.choice(['AB','CD','EF'])}"[:ml]
    if "currency" in name: return random.choice(CURRENCIES)[:ml]
    if "language" in name or "locale" in name: return random.choice(LANGUAGES)[:ml]
    if "status" in name or "state" in name: return random.choice(STATUSES)[:ml]
    if "risk" in name and any(k in name for k in ["level","rating","category","band","grade"]):
        return random.choice(RISK_LEVELS)[:ml]
    if "sentiment" in name: return random.choice(SENTIMENT)[:ml]
    if "segment" in name: return random.choice(CUSTOMER_SEGMENTS)[:ml]
    if "channel" in name or ("source" in name and "system" not in name): return random.choice(CHANNELS)[:ml]
    if "industry" in name or "sector" in name: return random.choice(INDUSTRIES)[:ml]
    if "department" in name or "dept" in name: return random.choice(DEPARTMENTS)[:ml]
    if "feedback" in name and "category" in name: return random.choice(FEEDBACK_CATS)[:ml]
    if "product_type" in name: return random.choice(PRODUCT_TYPES)[:ml]
    if "subtype" in name: return random.choice(["standard","premium","flex","green","fixed_rate"])[:ml]
    if "type" in name: return random.choice(["standard","premium","basic","enterprise","custom"])[:ml]
    if any(k in name for k in ["description","desc","comment","note","remark","summary","reason","text","content","body","subject"]):
        return random.choice([
            "Standard digital service for European market",
            "Customer interaction via web portal",
            "Automated notification for leasing operations",
            "Compliance check triggered by system event",
            "Cross-sell opportunity identified via analytics",
        ])[:ml]
    if "code" in name or name.endswith("_cd"):
        if "country" in name: return random.choice(COUNTRIES)
        if "currency" in name: return random.choice(CURRENCIES)
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(1000,9999)}"[:ml]
    if name.endswith("_id") or "identifier" in name or "ref" in name or "uuid" in name or "hash" in name:
        return f"{''.join(random.choices(string.ascii_uppercase,k=3))}-{random.randint(10000,99999)}"[:ml]
    if "url" in name or "link" in name:
        return f"https://masreph.com/{random.choice(['app','portal','docs'])}/{random.randint(1000,9999)}"[:ml]
    if "ip" in name:
        return f"{random.randint(10,200)}.{random.randint(0,255)}.{random.randint(0,255)}.{random.randint(1,254)}"[:ml]
    if "domain" in name: return random.choice(["masreph.com","masreph.nl","gmail.com"])[:ml]
    if "version" in name: return f"v{random.randint(1,5)}.{random.randint(0,9)}"[:ml]
    return f"masreph_{random.randint(1000,9999)}"[:ml]


def generate_data_for_db(db_name):
    conn = get_connection(db_name)
    cur = conn.cursor()

    # Get tables
    cur.execute(f"SELECT table_name FROM information_schema.tables WHERE table_schema='{db_name}'")
    tables = [r[0] for r in cur.fetchall()]

    if not tables:
        conn.close()
        return 0

    # Truncate
    cur.execute("SET FOREIGN_KEY_CHECKS=0")
    for t in tables:
        try: cur.execute(f"TRUNCATE TABLE `{t}`")
        except: pass
    cur.execute("SET FOREIGN_KEY_CHECKS=1")
    conn.commit()

    # Get metadata per table
    table_meta = []
    for t in tables:
        cur.execute(f"""
            SELECT column_name, data_type, is_nullable, column_default,
                   character_maximum_length, numeric_precision, numeric_scale, extra
            FROM information_schema.columns WHERE table_schema='{db_name}' AND table_name='{t}'
            ORDER BY ordinal_position
        """)
        columns = [{"name":r[0],"data_type":r[1],"nullable":r[2]=="YES","default":r[3],
                     "max_length":r[4],"precision":r[5],"scale":r[6],"extra":r[7] or ""} for r in cur.fetchall()]

        cur.execute(f"""
            SELECT column_name FROM information_schema.key_column_usage
            WHERE table_schema='{db_name}' AND table_name='{t}' AND constraint_name='PRIMARY'
        """)
        pk_cols = [r[0] for r in cur.fetchall()]

        cur.execute(f"""
            SELECT kcu.column_name, kcu.referenced_table_name, kcu.referenced_column_name
            FROM information_schema.key_column_usage kcu
            WHERE kcu.table_schema='{db_name}' AND kcu.table_name='{t}'
              AND kcu.referenced_table_name IS NOT NULL
        """)
        fk_info = {r[0]: (db_name, r[1], r[2]) for r in cur.fetchall()}

        table_meta.append({"name":t, "columns":columns, "pk_cols":pk_cols,
            "fk_info":fk_info, "num_rows":determine_row_count(t, columns, fk_info), "num_fks":len(fk_info)})

    # Sort parents first
    table_meta.sort(key=lambda x: x["num_fks"])

    db_total = 0
    for tm in table_meta:
        # Get FK parent IDs
        fk_ids = {}
        for col_name, (_, ref_table, ref_col) in tm["fk_info"].items():
            try:
                cur.execute(f"SELECT `{ref_col}` FROM `{ref_table}` LIMIT 500")
                ids = [r[0] for r in cur.fetchall()]
                fk_ids[col_name] = ids if ids else None
            except:
                fk_ids[col_name] = None

        insertable = [c for c in tm["columns"] if "auto_increment" not in c.get("extra","")]
        if not insertable:
            continue

        col_names = [f"`{c['name']}`" for c in insertable]
        placeholders = ", ".join(["%s"] * len(insertable))
        insert_sql = f"INSERT INTO `{tm['name']}` ({', '.join(col_names)}) VALUES ({placeholders})"

        rows = []
        for i in range(tm["num_rows"]):
            rows.append(tuple(generate_value(c, i, fk_ids, tm["pk_cols"]) for c in insertable))

        try:
            cur.executemany(insert_sql, rows)
            conn.commit()
            db_total += len(rows)
        except:
            conn.rollback()
            ok = 0
            for row in rows:
                try:
                    cur.execute(insert_sql, row)
                    conn.commit()
                    ok += 1
                except:
                    conn.rollback()
            db_total += ok

    conn.close()
    return db_total


def generate_all(db_stats):
    logger.info("\n=== Phase 2: Generating Data (per database) ===")

    grand_total = 0
    for db_name, stats in sorted(db_stats.items()):
        if stats["tables"] == 0:
            continue
        rows = generate_data_for_db(db_name)
        grand_total += rows
        logger.info(f"  {db_name}: {stats['tables']} tables, {rows} rows")

    logger.info(f"\n=== Total: {grand_total} rows across {len(db_stats)} databases ===")
    return grand_total


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== MySQL: One Database Per Source System ===")

    # Clean up old single DB
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("DROP DATABASE IF EXISTS masreph_digital")
    conn.commit()
    conn.close()

    # Deploy
    db_stats = deploy_all()

    # Generate data
    grand_total = generate_all(db_stats)

    logger.info(f"\n=== DONE: {len(db_stats)} databases, {grand_total} total rows ===")


if __name__ == "__main__":
    main()
