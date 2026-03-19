#!/usr/bin/env python3
"""
Fix all empty tables across all platforms.
Uses the Oracle-style approach: read actual column metadata (type, precision)
and generate strictly type-safe values.
"""

import os
import sys
import json
import random
import string
import re
import logging
from datetime import datetime, date, timedelta
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))
sys.path.insert(0, os.path.dirname(__file__))
from generate_data_v2 import CUSTOMERS, PRODUCTS, CONTRACTS, classify_column, get_entity_value, determine_rows

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)


def safe_value(col_name, col_type, precision=None, scale=None, max_len=None, platform=""):
    """Generate a strictly type-safe value based on actual column metadata."""
    n = col_name.lower()
    t = (col_type or "").upper()

    # Try master entity mapping first
    ft = classify_column(col_name)
    if ft:
        customer = random.choice(CUSTOMERS)
        product = random.choice(PRODUCTS)
        contract = random.choice(CONTRACTS)
        val = get_entity_value(ft, customer, product, contract, platform)
        # Coerce to correct type
        if val is not None:
            if "INT" in t or (t == "NUMBER" and (scale is None or scale == 0)):
                try: return int(val) if not isinstance(val, bool) else (1 if val else 0)
                except: pass
            if "CHAR" in t or "TEXT" in t or "STRING" in t or "VARCHAR" in t or "CLOB" in t:
                s = str(val)
                if max_len and max_len > 0: s = s[:max_len]
                return s
            if "DATE" in t or "TIME" in t or "TIMESTAMP" in t:
                if isinstance(val, str):
                    try: return datetime.fromisoformat(val) if "T" in val else datetime.fromisoformat(val + "T00:00:00")
                    except: return datetime(2023, 1, 1)
                return val
            if "DECIMAL" in t or "NUMERIC" in t or "NUMBER" in t or "FLOAT" in t or "DOUBLE" in t:
                try:
                    fval = float(val)
                    if precision and scale:
                        max_v = 10 ** (precision - scale) - 1
                        fval = min(fval, max_v)
                    return round(fval, scale or 2)
                except: pass
            if "BIT" in t or "BOOL" in t or "TINYINT" in t:
                if isinstance(val, bool): return 1 if val else 0
                return val
            return val

    # ── Type-safe generic generation ──

    # Boolean / BIT
    if "BIT" in t or (t == "TINYINT" and max_len == 1) or "BOOL" in t:
        return random.choice([0, 1]) if "INT" in t or "BIT" in t else random.choice([True, False])

    # Integer
    if t in ("INT", "INTEGER", "BIGINT", "SMALLINT", "MEDIUMINT") or (t == "NUMBER" and (scale is None or scale == 0)):
        max_v = 999999
        if precision:
            if precision == 1: return random.choice([0, 1])
            max_v = min(10 ** precision - 1, 999999)
        if "count" in n or "num" in n or "qty" in n: return random.randint(0, min(max_v, 999))
        if "age" in n: return random.randint(18, 78)
        if "year" in n: return random.randint(2019, 2026)
        if "score" in n or "rating" in n: return random.randint(0, min(max_v, 100))
        if "days" in n: return random.randint(0, 365)
        if "duration" in n or "month" in n: return random.randint(1, 120)
        if "household" in n: return random.randint(1, 6)
        return random.randint(1, min(max_v, 9999))

    # Decimal / Float / Number with scale
    if "DECIMAL" in t or "NUMERIC" in t or "FLOAT" in t or "DOUBLE" in t or "MONEY" in t or (t == "NUMBER" and scale and scale > 0):
        p = precision or 18
        s = scale or 2
        max_v = min(10 ** (p - s) - 1, 999999)
        if any(k in n for k in ["amount", "balance", "value", "revenue", "cost", "fee", "payment", "principal", "exposure"]):
            return round(random.uniform(100, min(max_v, 500000)), min(s, 2))
        if any(k in n for k in ["rate", "interest", "margin", "spread"]):
            return round(random.uniform(0.5, min(max_v, 15)), min(s, 4))
        if any(k in n for k in ["pct", "percent", "ratio", "weight"]):
            return round(random.uniform(0, min(max_v, 100)), min(s, 2))
        if "score" in n: return round(random.uniform(0, min(max_v, 100)), min(s, 2))
        return round(random.uniform(0, min(max_v, 9999)), min(s, 2))

    # Date
    if t == "DATE" or (t == "DATE" and "TIME" not in t):
        return date(2023, 1, 1) + timedelta(days=random.randint(0, 1000))

    # Timestamp / Datetime
    if "TIMESTAMP" in t or "DATETIME" in t or "TIME" in t:
        return datetime(2023, 1, 1) + timedelta(days=random.randint(0, 1000), hours=random.randint(0, 23))

    # RAW (Oracle UUID)
    if "RAW" in t:
        return bytes(random.getrandbits(8) for _ in range(16))

    # CLOB / TEXT
    if "CLOB" in t or "LONG" in t:
        return "Standard financial record"

    # VARIANT (Snowflake JSON)
    if "VARIANT" in t:
        return json.dumps({"key": f"val_{random.randint(100, 999)}"})

    # String / VARCHAR / CHAR / NVARCHAR / STRING
    if "CHAR" in t or "TEXT" in t or "STRING" in t:
        ml = min(max_len or 255, 255)
        if "email" in n: return f"user{random.randint(1,999)}@masreph.com"[:ml]
        if "phone" in n or "mobile" in n: return f"+31 {random.randint(600000000,699999999)}"[:ml]
        if "country" in n: return random.choice(["NL","DE","FR","GB","US"])[:ml]
        if "currency" in n: return random.choice(["EUR","USD","GBP","CHF"])[:ml]
        if "gender" in n: return random.choice(["M","F","X"])[:ml]
        if "status" in n: return random.choice(["active","inactive","pending","closed"])[:ml]
        if "segment" in n: return random.choice(["mass_market","affluent","high_net_worth","sme"])[:ml]
        if "channel" in n: return random.choice(["web","mobile","branch","phone","email"])[:ml]
        if "risk" in n and ("band" in n or "rating" in n or "level" in n): return random.choice(["low","medium","high"])[:ml]
        if "type" in n: return random.choice(["standard","premium","basic"])[:ml]
        if "name" in n or "nm" in n:
            fn = random.choice(["Jan","Maria","Thomas","Sophie","Lars","Emma"])
            ln = random.choice(["de Jong","Bakker","Schmidt","Smith","Chen"])
            return f"{fn} {ln}"[:ml]
        if "id" in n or "code" in n or "ref" in n:
            return f"{''.join(random.choices(string.ascii_uppercase, k=3))}{random.randint(1000,9999)}"[:ml]
        if any(k in n for k in ["desc", "comment", "note", "remark", "summary"]):
            return "Standard financial record"[:ml]
        if "iban" in n: return f"NL{random.randint(10,99)}MASREPH{random.randint(1000000000,9999999999)}"[:ml]
        return f"val_{random.randint(100,9999)}"[:ml]

    # Fallback
    return f"v{random.randint(100,999)}"


# ─── PLATFORM FIXERS ────────────────────────────────────────────────────────

def fix_sqlserver():
    import pyodbc
    logger.info("\n=== Fixing SQL Server Empty Tables ===")
    conn = pyodbc.connect("DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;Trusted_Connection=yes;", autocommit=True)
    cur = conn.cursor()

    cur.execute("SELECT name FROM sys.databases WHERE name LIKE 'Masreph_%' ORDER BY name")
    dbs = [r[0] for r in cur.fetchall()]
    fixed = 0

    for db in dbs:
        cur.execute(f"USE [{db}]")
        cur.execute("""
            SELECT t.name FROM sys.tables t
            LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
            GROUP BY t.name HAVING ISNULL(SUM(p.rows),0) = 0
        """)
        empty_tables = [r[0] for r in cur.fetchall()]
        if not empty_tables: continue

        for table in empty_tables:
            cur.execute(f"""
                SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
                FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION
            """)
            columns = cur.fetchall()

            num_rows = determine_rows(table)
            inserted = 0
            for i in range(num_rows):
                row = [safe_value(c[0], c[1], c[3], c[4], c[2], "sql-server") for c in columns]
                col_list = ", ".join(f"[{c[0]}]" for c in columns)
                placeholders = ", ".join(["?"] * len(columns))
                try:
                    cur.execute(f"INSERT INTO [{table}] ({col_list}) VALUES ({placeholders})", row)
                    inserted += 1
                except: pass

            if inserted > 0:
                fixed += 1
                logger.info(f"  {db}.{table}: {inserted} rows")

    conn.close()
    logger.info(f"  SQL Server: {fixed} tables fixed")
    return fixed


def fix_postgresql():
    import psycopg2
    logger.info("\n=== Fixing PostgreSQL Empty Tables ===")
    conn = psycopg2.connect(host="aws-1-eu-west-2.pooler.supabase.com", port=5432, database="postgres",
        user="postgres.rlphlmkddecuptbklqeh", password="os.getenv('SUPABASE_CORE_PASSWORD')", connect_timeout=15)
    cur = conn.cursor()

    cur.execute("""
        SELECT schemaname, relname FROM pg_stat_user_tables
        WHERE n_live_tup = 0 AND schemaname NOT IN
        ('pg_catalog','information_schema','auth','storage','realtime','extensions',
        'graphql','graphql_public','pgsodium','pgsodium_masks','vault','supabase_functions',
        '_realtime','supabase_migrations','net','_analytics','public')
        ORDER BY schemaname, relname
    """)
    empty = cur.fetchall()
    logger.info(f"  Found {len(empty)} empty tables")
    fixed = 0

    for schema, table in empty:
        cur.execute(f"""
            SELECT column_name, udt_name, character_maximum_length, numeric_precision, numeric_scale, column_default
            FROM information_schema.columns
            WHERE table_schema='{schema}' AND table_name='{table}' ORDER BY ordinal_position
        """)
        columns = cur.fetchall()

        # Skip serial columns
        insertable = [(c[0], c[1], c[2], c[3], c[4]) for c in columns if "nextval" not in str(c[5] or "")]
        if not insertable: continue

        num_rows = determine_rows(table)
        col_list = ", ".join(c[0] for c in insertable)
        placeholders = ", ".join(["%s"] * len(insertable))
        sql = f"INSERT INTO {schema}.{table} ({col_list}) VALUES ({placeholders})"

        inserted = 0
        for i in range(num_rows):
            row = tuple(safe_value(c[0], c[1], c[3], c[4], c[2], "postgresql") for c in insertable)
            try:
                cur.execute(sql, row)
                conn.commit()
                inserted += 1
            except:
                conn.rollback()

        if inserted > 0:
            fixed += 1
            if fixed % 10 == 0:
                logger.info(f"  Progress: {fixed} tables fixed")

    conn.close()
    logger.info(f"  PostgreSQL: {fixed} tables fixed")
    return fixed


def fix_mysql():
    import mysql.connector
    logger.info("\n=== Fixing MySQL Empty Tables ===")
    conn = mysql.connector.connect(host="localhost", port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')")
    cur = conn.cursor()

    cur.execute("SELECT TABLE_SCHEMA, TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA LIKE 'masreph_%' AND TABLE_ROWS = 0")
    empty = cur.fetchall()
    logger.info(f"  Found {len(empty)} empty tables")
    fixed = 0

    for db, table in empty:
        cur.execute(f"USE `{db}`")
        cur.execute(f"""
            SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE, EXTRA
            FROM information_schema.columns WHERE TABLE_SCHEMA='{db}' AND TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION
        """)
        columns = cur.fetchall()
        insertable = [(c[0], c[1], c[2], c[3], c[4]) for c in columns if "auto_increment" not in (c[5] or "")]
        if not insertable: continue

        num_rows = determine_rows(table)
        col_list = ", ".join(f"`{c[0]}`" for c in insertable)
        placeholders = ", ".join(["%s"] * len(insertable))
        sql = f"INSERT INTO `{table}` ({col_list}) VALUES ({placeholders})"

        rows = []
        for i in range(num_rows):
            rows.append(tuple(safe_value(c[0], c[1], c[3], c[4], c[2], "mysql") for c in insertable))

        try:
            cur.executemany(sql, rows)
            conn.commit()
            fixed += 1
            logger.info(f"  {db}.{table}: {len(rows)} rows")
        except:
            conn.rollback()
            inserted = 0
            for row in rows:
                try:
                    cur.execute(sql, row)
                    conn.commit()
                    inserted += 1
                except:
                    conn.rollback()
            if inserted > 0:
                fixed += 1
                logger.info(f"  {db}.{table}: {inserted} rows (partial)")

    conn.close()
    logger.info(f"  MySQL: {fixed} tables fixed")
    return fixed


def fix_snowflake():
    import snowflake.connector
    logger.info("\n=== Fixing Snowflake Empty Tables ===")

    v2_schemas = set()
    schemas_dir = os.path.join(os.path.dirname(__file__), "..", "schemas_v2", "snowflake")
    for f in os.listdir(schemas_dir):
        if f.endswith(".sql"):
            v2_schemas.add(f.replace(".sql", "").upper())

    conn = snowflake.connector.connect(account="ittrelv-xu20591", user="hzmarrou",
        password="os.getenv('SNOWFLAKE_PASSWORD')", warehouse="COMPUTE_WH", database="MASREPH_RISK_ANALYTICS")
    cur = conn.cursor()
    fixed = 0

    for schema in sorted(v2_schemas):
        cur.execute(f"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='{schema}' AND TABLE_TYPE='BASE TABLE'")
        tables = [r[0] for r in cur.fetchall()]

        for table in tables:
            cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
            if cur.fetchone()[0] > 0: continue

            cur.execute(f"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='{schema}' AND TABLE_NAME='{table}' ORDER BY ORDINAL_POSITION")
            columns = [(r[0], r[1]) for r in cur.fetchall()]
            if not columns: continue

            num_rows = determine_rows(table)
            rows = []
            for i in range(num_rows):
                rows.append(tuple(safe_value(c[0], c[1], platform="snowflake") for c in columns))

            col_list = ", ".join(c[0] for c in columns)
            placeholders = ", ".join(["%s"] * len(columns))
            sql = f"INSERT INTO {schema}.{table} ({col_list}) VALUES ({placeholders})"

            try:
                cur.executemany(sql, rows)
                fixed += 1
                logger.info(f"  {schema}.{table}: {len(rows)} rows")
            except:
                inserted = 0
                for row in rows:
                    try: cur.execute(sql, row); inserted += 1
                    except: pass
                if inserted > 0:
                    fixed += 1
                    logger.info(f"  {schema}.{table}: {inserted} rows (partial)")

    conn.close()
    logger.info(f"  Snowflake: {fixed} tables fixed")
    return fixed


def fix_databricks():
    from databricks import sql as dbx_sql
    logger.info("\n=== Fixing Databricks Empty Tables ===")
    conn = dbx_sql.connect(server_hostname="adb-7405617014831513.13.azuredatabricks.net",
        http_path="/sql/1.0/warehouses/b3bee97b5042372c",
        access_token="os.getenv('DATABRICKS_TOKEN')")
    cur = conn.cursor()
    cur.execute("SHOW SCHEMAS IN masreph_datalake")
    schemas = [r[0] for r in cur.fetchall() if r[0] not in ("default", "information_schema")]
    fixed = 0

    for schema in schemas:
        cur.execute(f"SHOW TABLES IN masreph_datalake.{schema}")
        tables = [r[1] for r in cur.fetchall()]

        for table in tables:
            try:
                cur.execute(f"SELECT COUNT(*) FROM masreph_datalake.{schema}.{table}")
                if cur.fetchone()[0] > 0: continue
            except: continue

            cur.execute(f"DESCRIBE TABLE masreph_datalake.{schema}.{table}")
            columns = [(r[0], r[1]) for r in cur.fetchall() if not r[0].startswith("#")]
            if not columns: continue

            num_rows = determine_rows(table)
            batch_size = 50
            inserted = 0

            for bs in range(0, num_rows, batch_size):
                be = min(bs + batch_size, num_rows)
                values_list = []
                for i in range(bs, be):
                    parts = []
                    for c_name, c_type in columns:
                        val = safe_value(c_name, c_type, platform="databricks")
                        if val is None: parts.append("NULL")
                        elif isinstance(val, bool): parts.append("true" if val else "false")
                        elif isinstance(val, (int, float)): parts.append(str(val))
                        elif isinstance(val, (datetime, date)): parts.append(f"'{val}'")
                        else: parts.append(f"'{str(val).replace(chr(39), chr(39)+chr(39))}'")
                    values_list.append(f"({','.join(parts)})")

                try:
                    cur.execute(f"INSERT INTO masreph_datalake.{schema}.{table} VALUES {','.join(values_list)}")
                    inserted += be - bs
                except:
                    for vals in values_list:
                        try:
                            cur.execute(f"INSERT INTO masreph_datalake.{schema}.{table} VALUES {vals}")
                            inserted += 1
                        except: pass

            if inserted > 0:
                fixed += 1
                logger.info(f"  {schema}.{table}: {inserted} rows")

    conn.close()
    logger.info(f"  Databricks: {fixed} tables fixed")
    return fixed


def fix_fabric():
    import pyodbc, struct
    from azure.identity import ClientSecretCredential
    logger.info("\n=== Fixing Fabric Empty Tables ===")

    cred = ClientSecretCredential("os.getenv('FABRIC_TENANT_ID')",
        "os.getenv('FABRIC_CLIENT_ID')", "os.getenv('FABRIC_CLIENT_SECRET')")
    token = cred.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};SERVER=bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com;DATABASE=MasrephCorporateBI_WH;",
        attrs_before={1256: token_struct}, autocommit=True)
    cur = conn.cursor()
    fixed = 0

    cur.execute("""
        SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA') AND TABLE_TYPE='BASE TABLE'
    """)
    all_tables = cur.fetchall()

    for schema, table in all_tables:
        try:
            cur.execute(f"SELECT COUNT(*) FROM [{schema}].[{table}]")
            if cur.fetchone()[0] > 0: continue
        except: continue

        cur.execute(f"""
            SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE
            FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='{schema}' AND TABLE_NAME='{table}'
            ORDER BY ORDINAL_POSITION
        """)
        columns = cur.fetchall()
        if not columns: continue

        num_rows = determine_rows(table)
        col_list = ", ".join(f"[{c[0]}]" for c in columns)
        placeholders = ", ".join(["?"] * len(columns))
        sql = f"INSERT INTO [{schema}].[{table}] ({col_list}) VALUES ({placeholders})"

        rows = []
        for i in range(num_rows):
            row = tuple(safe_value(c[0], c[1], c[3], c[4], c[2], "fabric") for c in columns)
            rows.append(row)

        inserted = 0
        for bs in range(0, len(rows), 100):
            batch = rows[bs:bs+100]
            try:
                cur.executemany(sql, batch)
                inserted += len(batch)
            except:
                for row in batch:
                    try: cur.execute(sql, row); inserted += 1
                    except: pass

        if inserted > 0:
            fixed += 1
            logger.info(f"  {schema}.{table}: {inserted} rows")

    conn.close()
    logger.info(f"  Fabric: {fixed} tables fixed")
    return fixed


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== Fixing Empty Tables Across All Platforms ===")

    results = {}
    results["sql-server"] = fix_sqlserver()
    results["mysql"] = fix_mysql()
    results["postgresql"] = fix_postgresql()
    results["snowflake"] = fix_snowflake()
    results["databricks"] = fix_databricks()
    results["fabric"] = fix_fabric()

    logger.info("\n=== FIX COMPLETE ===")
    for platform, count in results.items():
        logger.info(f"  {platform:15s}: {count} tables fixed")
    logger.info(f"  {'TOTAL':15s}: {sum(results.values())} tables fixed")


if __name__ == "__main__":
    main()
