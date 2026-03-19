#!/usr/bin/env python3
"""
Deploy PostgreSQL DDL schemas to masreph-core Supabase instance.

Phase 1: Create schemas and tables (skip FK constraints)
Phase 2: Add FK constraints after all tables exist
"""

import os
import re
import psycopg2
import logging
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "postgresql")


def get_connection():
    return psycopg2.connect(
        host=os.getenv("MASREPH_PG_HOST"),
        port=int(os.getenv("MASREPH_PG_PORT", 5432)),
        database=os.getenv("MASREPH_PG_NAME"),
        user=os.getenv("MASREPH_PG_USER"),
        password=os.getenv("MASREPH_PG_PASSWORD"),
        connect_timeout=15,
    )


def extract_statements(sql_content):
    """Extract individual SQL statements from a DDL file."""
    schema_stmts = []
    table_stmts = []
    fk_stmts = []
    index_stmts = []

    # Remove comment-only lines but keep inline comments
    lines = sql_content.split("\n")
    cleaned_lines = []
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("--"):
            continue
        cleaned_lines.append(line)

    cleaned = "\n".join(cleaned_lines)

    # Split by semicolon (handles both ;\n and ); patterns)
    # Use regex to split on semicolons that are followed by whitespace/newline/EOF
    raw_stmts = re.split(r';(?:\s*\n|\s*$)', cleaned)

    for stmt in raw_stmts:
        stmt = stmt.strip()
        if not stmt:
            continue

        stmt_upper = stmt.upper()
        if "CREATE SCHEMA" in stmt_upper:
            schema_stmts.append(stmt + ";")
        elif "CREATE TABLE" in stmt_upper:
            table_stmts.append(stmt + ";")
        elif "ALTER TABLE" in stmt_upper and "FOREIGN KEY" in stmt_upper:
            fk_stmts.append(stmt + ";")
        elif "CREATE INDEX" in stmt_upper:
            index_stmts.append(stmt + ";")

    return schema_stmts, table_stmts, fk_stmts, index_stmts


def deploy_file(conn, filepath):
    """Deploy a single DDL file."""
    filename = os.path.basename(filepath)
    logger.info(f"  Processing {filename}...")

    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    schema_stmts, table_stmts, fk_stmts, index_stmts = extract_statements(content)

    cur = conn.cursor()
    created = 0
    skipped = 0
    errors = 0

    # Phase 1: Create schemas
    for stmt in schema_stmts:
        try:
            cur.execute(stmt)
            conn.commit()
        except psycopg2.errors.DuplicateSchema:
            conn.rollback()
        except Exception as e:
            conn.rollback()
            # Schema might already exist
            pass

    # Phase 2: Create tables
    for stmt in table_stmts:
        try:
            cur.execute(stmt)
            conn.commit()
            created += 1
        except psycopg2.errors.DuplicateTable:
            conn.rollback()
            skipped += 1
        except Exception as e:
            conn.rollback()
            errors += 1
            # Log first few errors per file
            if errors <= 3:
                # Extract table name for logging
                match = re.search(r'CREATE TABLE\s+(?:IF NOT EXISTS\s+)?(\S+)', stmt, re.IGNORECASE)
                tname = match.group(1) if match else "unknown"
                logger.warning(f"    Error creating {tname}: {str(e)[:100]}")

    logger.info(f"    Created: {created}, Skipped: {skipped}, Errors: {errors}")
    return created, skipped, errors, fk_stmts


def main():
    logger.info("=== Deploying PostgreSQL Schemas to masreph-core ===")

    conn = get_connection()
    logger.info("Connected to masreph-core")

    # Get all SQL files
    sql_files = sorted(Path(SCHEMAS_DIR).glob("*.sql"))
    logger.info(f"Found {len(sql_files)} DDL files")

    total_created = 0
    total_skipped = 0
    total_errors = 0
    all_fk_stmts = []

    # Phase 1: Deploy schemas and tables
    logger.info("\n--- Phase 1: Creating schemas and tables ---")
    for filepath in sql_files:
        created, skipped, errors, fk_stmts = deploy_file(conn, filepath)
        total_created += created
        total_skipped += skipped
        total_errors += errors
        all_fk_stmts.extend(fk_stmts)

    logger.info(f"\nPhase 1 complete: {total_created} tables created, {total_skipped} skipped, {total_errors} errors")

    # Phase 2: Add FK constraints
    logger.info(f"\n--- Phase 2: Adding {len(all_fk_stmts)} FK constraints ---")
    fk_ok = 0
    fk_err = 0
    cur = conn.cursor()
    for stmt in all_fk_stmts:
        try:
            cur.execute(stmt)
            conn.commit()
            fk_ok += 1
        except Exception as e:
            conn.rollback()
            fk_err += 1

    logger.info(f"Phase 2 complete: {fk_ok} FKs added, {fk_err} failed")

    # Verify
    cur = conn.cursor()
    cur.execute("""
        SELECT schemaname, COUNT(*) as table_count
        FROM pg_tables
        WHERE schemaname NOT IN ('pg_catalog', 'information_schema', 'auth', 'storage',
                                  'realtime', 'extensions', 'graphql', 'graphql_public',
                                  'pgsodium', 'pgsodium_masks', 'vault', 'supabase_functions',
                                  '_realtime', 'supabase_migrations', 'net', '_analytics')
        GROUP BY schemaname
        ORDER BY table_count DESC
    """)
    logger.info("\n=== Deployed Schemas ===")
    total = 0
    for row in cur.fetchall():
        logger.info(f"  {row[0]}: {row[1]} tables")
        total += row[1]
    logger.info(f"  TOTAL: {total} tables")

    conn.close()
    logger.info("\n=== Deployment Complete ===")


if __name__ == "__main__":
    main()
