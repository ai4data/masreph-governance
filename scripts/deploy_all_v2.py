#!/usr/bin/env python3
"""
Deploy DDL v2 to all 8 platforms from schemas_v2/ directory.
Then generate data using master_entities.json for shared cross-platform entities.
"""

import os
import re
import json
import sys
import logging
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")
SCHEMAS_DIR = os.path.join(BASE_DIR, "schemas_v2")


def parse_ddl(filepath):
    """Parse a DDL file into individual statements."""
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()
    lines = [l for l in content.split("\n") if not l.strip().startswith("--")]
    cleaned = "\n".join(lines)
    stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

    schema_stmts = []
    table_stmts = []
    fk_stmts = []

    for stmt in stmts:
        stmt = stmt.strip()
        if not stmt:
            continue
        upper = stmt.upper()
        if "CREATE SCHEMA" in upper or "EXEC(" in upper:
            schema_stmts.append(stmt + ";")
        elif "CREATE TABLE" in upper:
            table_stmts.append(stmt + ";")
        elif "ALTER TABLE" in upper and "FOREIGN KEY" in upper:
            fk_stmts.append(stmt + ";")

    return schema_stmts, table_stmts, fk_stmts


# ─── PLATFORM DEPLOYERS ─────────────────────────────────────────────────────

def deploy_sqlserver():
    import pyodbc
    logger.info("\n=== SQL Server ===")
    conn = pyodbc.connect("DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;Trusted_Connection=yes;", autocommit=True)
    cur = conn.cursor()

    ddl_dir = os.path.join(SCHEMAS_DIR, "sql-server")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        db_name = f"Masreph_{filepath.stem}"
        cur.execute(f"IF NOT EXISTS (SELECT name FROM sys.databases WHERE name='{db_name}') CREATE DATABASE [{db_name}]")
        cur.execute(f"USE [{db_name}]")

        schema_stmts, table_stmts, fk_stmts = parse_ddl(filepath)
        created = 0
        for stmt in table_stmts:
            # Replace schema refs with dbo
            modified = re.sub(r'\[(\w+)\]\.\[', '[dbo].[', stmt)
            try:
                cur.execute(modified)
                created += 1
            except Exception as e:
                if "already" not in str(e).lower():
                    pass

        for stmt in fk_stmts:
            modified = re.sub(r'\[(\w+)\]\.\[', '[dbo].[', stmt)
            try:
                cur.execute(modified)
            except:
                pass

        total += created
        if created > 0:
            logger.info(f"  {db_name}: {created} tables")

    conn.close()
    logger.info(f"  SQL Server total: {total} tables")
    return total


def deploy_postgresql():
    import psycopg2
    logger.info("\n=== PostgreSQL ===")
    conn = psycopg2.connect(host="aws-1-eu-west-2.pooler.supabase.com", port=5432, database="postgres",
        user="postgres.rlphlmkddecuptbklqeh", password="os.getenv('SUPABASE_CORE_PASSWORD')", connect_timeout=15)
    cur = conn.cursor()

    ddl_dir = os.path.join(SCHEMAS_DIR, "postgresql")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        schema_stmts, table_stmts, fk_stmts = parse_ddl(filepath)

        for stmt in schema_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
            except:
                conn.rollback()

        created = 0
        for stmt in table_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
                created += 1
            except:
                conn.rollback()

        for stmt in fk_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
            except:
                conn.rollback()

        total += created
        if created > 0:
            logger.info(f"  {filepath.stem}: {created} tables")

    conn.close()
    logger.info(f"  PostgreSQL total: {total} tables")
    return total


def deploy_mysql():
    import mysql.connector
    logger.info("\n=== MySQL ===")
    conn = mysql.connector.connect(host="localhost", port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')")
    cur = conn.cursor()

    ddl_dir = os.path.join(SCHEMAS_DIR, "mysql")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        db_name = f"masreph_{filepath.stem}"
        cur.execute(f"CREATE DATABASE IF NOT EXISTS `{db_name}` CHARACTER SET utf8mb4")
        cur.execute(f"USE `{db_name}`")
        conn.commit()

        schema_stmts, table_stmts, fk_stmts = parse_ddl(filepath)
        created = 0
        for stmt in table_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
                created += 1
            except:
                pass

        for stmt in fk_stmts:
            try:
                cur.execute(stmt)
                conn.commit()
            except:
                pass

        total += created
        if created > 0:
            logger.info(f"  {db_name}: {created} tables")

    conn.close()
    logger.info(f"  MySQL total: {total} tables")
    return total


def deploy_snowflake():
    import snowflake.connector
    logger.info("\n=== Snowflake ===")
    conn = snowflake.connector.connect(account="ittrelv-xu20591", user="hzmarrou",
        password="os.getenv('SNOWFLAKE_PASSWORD')", warehouse="COMPUTE_WH")
    cur = conn.cursor()

    # Drop and recreate database
    cur.execute("CREATE DATABASE IF NOT EXISTS MASREPH_RISK_ANALYTICS")
    cur.execute("USE DATABASE MASREPH_RISK_ANALYTICS")
    cur.execute("USE WAREHOUSE COMPUTE_WH")

    ddl_dir = os.path.join(SCHEMAS_DIR, "snowflake")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        schema_stmts, table_stmts, fk_stmts = parse_ddl(filepath)

        for stmt in schema_stmts:
            try:
                cur.execute(stmt)
            except:
                pass

        created = 0
        for stmt in table_stmts:
            try:
                cur.execute(stmt)
                created += 1
            except:
                pass

        total += created
        if created > 0:
            logger.info(f"  {filepath.stem}: {created} tables")

    conn.close()
    logger.info(f"  Snowflake total: {total} tables")
    return total


def deploy_databricks():
    from databricks import sql
    logger.info("\n=== Databricks ===")
    conn = sql.connect(server_hostname="adb-7405617014831513.13.azuredatabricks.net",
        http_path="/sql/1.0/warehouses/b3bee97b5042372c",
        access_token="os.getenv('DATABRICKS_TOKEN')")
    cur = conn.cursor()
    cur.execute("USE CATALOG masreph_datalake")

    ddl_dir = os.path.join(SCHEMAS_DIR, "databricks")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        schema_name = filepath.stem
        try:
            cur.execute(f"CREATE SCHEMA IF NOT EXISTS masreph_datalake.{schema_name}")
        except:
            pass

        _, table_stmts, _ = parse_ddl(filepath)
        created = 0
        for stmt in table_stmts:
            # Redirect any schema reference to catalog.schema
            modified = re.sub(r'CREATE TABLE IF NOT EXISTS\s+(\S+)\.', f'CREATE TABLE IF NOT EXISTS masreph_datalake.{schema_name}.', stmt)
            # Also handle case where schema already matches
            if f'masreph_datalake.{schema_name}.' not in modified:
                modified = re.sub(r'CREATE TABLE IF NOT EXISTS\s+', f'CREATE TABLE IF NOT EXISTS masreph_datalake.{schema_name}.', modified)
            modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
            try:
                cur.execute(modified)
                created += 1
            except Exception as e:
                if "already exists" not in str(e).lower():
                    if created < 2:
                        logger.warning(f"    DBX {schema_name}: {str(e)[:80]}")

        total += created
        if created > 0:
            logger.info(f"  {schema_name}: {created} tables")

    conn.close()
    logger.info(f"  Databricks total: {total} tables")
    return total


def deploy_fabric():
    import pyodbc
    import struct
    from azure.identity import ClientSecretCredential
    logger.info("\n=== Fabric ===")

    cred = ClientSecretCredential("os.getenv('FABRIC_TENANT_ID')",
        "os.getenv('FABRIC_CLIENT_ID')", "os.getenv('FABRIC_CLIENT_SECRET')")
    token = cred.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)
    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};SERVER=bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com;DATABASE=MasrephCorporateBI_WH;",
        attrs_before={1256: token_struct}, autocommit=True)
    cur = conn.cursor()

    ddl_dir = os.path.join(SCHEMAS_DIR, "fabric")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        schema_name = filepath.stem
        try:
            cur.execute(f"CREATE SCHEMA [{schema_name}]")
        except:
            pass

        _, table_stmts, _ = parse_ddl(filepath)
        created = 0
        for stmt in table_stmts:
            # Redirect [AnySchema].[Table] to [our_schema].[Table]
            modified = re.sub(r'\[\w+\]\.\[', f'[{schema_name}].[', stmt)
            # Remove IF NOT EXISTS (Fabric doesn't support it)
            modified = modified.replace("CREATE TABLE IF NOT EXISTS", "CREATE TABLE")
            modified = modified.replace("IF NOT EXISTS ", "")
            # Remove constraints
            modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+PRIMARY KEY\s*\([^)]+\)', '', modified)
            modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+[^)]+\)', '', modified)
            # If no schema prefix, add it
            if f'[{schema_name}].' not in modified:
                modified = modified.replace("CREATE TABLE ", f"CREATE TABLE [{schema_name}].")
            # Fabric type fixes
            modified = modified.replace("UNIQUEIDENTIFIER", "VARCHAR(36)")
            modified = modified.replace("DATETIME2 ", "DATETIME2(6) ")
            modified = modified.replace("DATETIME2,", "DATETIME2(6),")
            modified = modified.replace("DATETIME2\n", "DATETIME2(6)\n")
            try:
                cur.execute(modified)
                created += 1
            except Exception as e:
                err = str(e)
                if "already" not in err.lower() and created < 2:
                    logger.warning(f"    Fabric {schema_name}: {err[:100]}")

        total += created
        if created > 0:
            logger.info(f"  {schema_name}: {created} tables")

    conn.close()
    logger.info(f"  Fabric total: {total} tables")
    return total


def deploy_oracle():
    import oracledb
    logger.info("\n=== Oracle ===")
    wallet_dir = os.path.join(BASE_DIR, "config", "oracle_wallet")
    conn = oracledb.connect(user="ADMIN", password="os.getenv('ORACLE_PASSWORD')", dsn="masrephdb_low",
        config_dir=wallet_dir, wallet_location=wallet_dir, wallet_password="os.getenv('ORACLE_PASSWORD')")
    cur = conn.cursor()

    ddl_dir = os.path.join(SCHEMAS_DIR, "oracle")
    total = 0

    for filepath in sorted(Path(ddl_dir).glob("*.sql")):
        _, table_stmts, fk_stmts = parse_ddl(filepath)
        created = 0
        for stmt in table_stmts:
            # Remove schema prefix (SCHEMA.TABLE -> TABLE)
            modified = re.sub(r'CREATE TABLE\s+\w+\.', 'CREATE TABLE ', stmt)
            modified = modified.replace("IF NOT EXISTS ", "")
            modified = re.sub(r',\s*CONSTRAINT\s+\S+\s+FOREIGN KEY[^)]*\)\s*REFERENCES\s+\S+\s*\([^)]+\)', '', modified)
            # Oracle doesn't want trailing semicolons
            modified = modified.rstrip().rstrip(';')
            try:
                cur.execute(modified)
                conn.commit()
                created += 1
            except Exception as e:
                err = str(e)
                if "ORA-00955" not in err:
                    if created < 2:
                        logger.warning(f"    Oracle {filepath.stem}: {err[:80]}")

        total += created
        if created > 0:
            logger.info(f"  {filepath.stem}: {created} tables")

    conn.close()
    logger.info(f"  Oracle total: {total} tables")
    return total


def deploy_mongodb():
    logger.info("\n=== MongoDB ===")
    # MongoDB doesn't need DDL deployment - collections are created on first insert
    ddl_dir = os.path.join(SCHEMAS_DIR, "mongodb")
    files = list(Path(ddl_dir).glob("*.json"))
    total = sum(len(json.loads(open(f).read())) for f in files)
    logger.info(f"  MongoDB: {total} collections (will be created during data insert)")
    return total


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== Deploying DDL v2 to All 8 Platforms ===")

    results = {}

    # Local platforms first (fast)
    results["sql-server"] = deploy_sqlserver()
    results["mysql"] = deploy_mysql()

    # Cloud platforms
    results["postgresql"] = deploy_postgresql()
    results["snowflake"] = deploy_snowflake()
    results["oracle"] = deploy_oracle()
    results["databricks"] = deploy_databricks()
    results["fabric"] = deploy_fabric()
    results["mongodb"] = deploy_mongodb()

    # Summary
    logger.info("\n=== DEPLOYMENT COMPLETE ===")
    grand_total = 0
    for platform, count in results.items():
        logger.info(f"  {platform:15s}: {count} tables")
        grand_total += count
    logger.info(f"  {'TOTAL':15s}: {grand_total} tables")


if __name__ == "__main__":
    main()
