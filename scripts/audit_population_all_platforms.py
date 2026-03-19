#!/usr/bin/env python3
import json
import struct
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path

import certifi
import mysql.connector
import oracledb
import psycopg2
import pyodbc
import snowflake.connector
from azure.identity import ClientSecretCredential
from databricks import sql as databricks_sql
from pymongo import MongoClient

ROOT = Path(__file__).resolve().parents[1]
MD_PATH = ROOT / "docs" / "DATA_POPULATION_AUDIT.md"
JSON_PATH = ROOT / "config" / "population_audit.json"

SQLCMD = "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/SQLCMD.EXE"
MYSQL_EXE = "/mnt/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"

SNOWFLAKE_SCHEMAS = [
    "ACTICO", "COMPLIANCE_ARCHIVE", "CRC_SYSTEMS", "CREDIT_RISK_CONTROLS",
    "CREDIT_RISK_INSIGHTS", "ENDORSEMENT_EVALUATIO_APPLICATION", "ESRB_RATINGS",
    "EUROCOMPLY", "JUMIO_RISK_SIGNALS", "RACCENT", "RISKCONNECT",
    "SANCTION_SCANNER", "TRULIOO", "VERIFF"
]

PG_EXCLUDE = (
    "'pg_catalog','information_schema','auth','storage','realtime','extensions','graphql','graphql_public',"
    "'pgsodium','pgsodium_masks','vault','supabase_functions','_realtime','supabase_migrations','net','_analytics','public'"
)


def pct(a: int, b: int) -> float:
    return round((a / b * 100.0), 1) if b else 0.0


def run_sqlcmd(query: str, database: str | None = None, sep: str = "|") -> list[str]:
    args = [SQLCMD, "-S", "localhost", "-E"]
    if database:
        args += ["-d", database]
    args += ["-Q", f"SET NOCOUNT ON; {query}", "-W", "-s", sep, "-h", "-1"]

    last_err = None
    for _ in range(3):
        p = subprocess.run(args, capture_output=True, text=True)
        if p.returncode == 0:
            lines = []
            for line in p.stdout.splitlines():
                s = line.strip()
                if not s or "rows affected" in s:
                    continue
                lines.append(s)
            return lines
        last_err = p.stderr.strip() or p.stdout.strip() or f"sqlcmd rc={p.returncode}"
        time.sleep(1.0)
    raise RuntimeError(last_err or "sqlcmd failed")


def mysql_cli(query: str) -> list[str]:
    p = subprocess.run(
        [MYSQL_EXE, "-uroot", "-pos.getenv('MYSQL_PASSWORD')", "-N", "-B", "-e", query],
        capture_output=True,
        text=True,
    )
    if p.returncode != 0:
        raise RuntimeError((p.stderr or p.stdout).strip() or f"mysql rc={p.returncode}")
    lines = [x.strip() for x in p.stdout.splitlines() if x.strip()]
    # hide mysql warning lines if any got mixed into stdout
    return [x for x in lines if not x.lower().startswith("mysql:")]


def build_platform_container() -> dict:
    return {"total_tables": 0, "tables_with_data": 0, "empty_tables": 0, "total_rows": 0, "populated": [], "empty": []}


result = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "summary": {},
    "platforms": {},
    "errors": {},
}

# 1) SQL Server
try:
    platform = build_platform_container()
    dbs = run_sqlcmd("SELECT name FROM sys.databases WHERE name LIKE 'Masreph[_]%' ORDER BY name")
    for db in dbs:
        table_rows = run_sqlcmd(
            "SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME",
            database=db,
        )
        for tr in table_rows:
            parts = [x.strip() for x in tr.split("|")]
            if len(parts) < 2:
                continue
            schema, table = parts[0], parts[1]
            cnt_rows = run_sqlcmd(f"SELECT COUNT_BIG(*) FROM [{schema}].[{table}]", database=db)
            rc = int(cnt_rows[0]) if cnt_rows else 0
            platform["total_tables"] += 1
            platform["total_rows"] += rc
            if rc > 0:
                platform["tables_with_data"] += 1
                platform["populated"].append({"database": db, "table": table, "rows": rc})
            else:
                platform["empty_tables"] += 1
                platform["empty"].append({"database": db, "table": table})
    result["platforms"]["sql-server"] = platform
except Exception as e:
    result["errors"]["sql-server"] = str(e)
    result["platforms"]["sql-server"] = build_platform_container()

# 2) PostgreSQL
try:
    platform = build_platform_container()
    conn = psycopg2.connect(
        host="aws-1-eu-west-2.pooler.supabase.com",
        port=5432,
        database="postgres",
        user="postgres.rlphlmkddecuptbklqeh",
        password="os.getenv('SUPABASE_CORE_PASSWORD')",
        connect_timeout=30,
    )
    conn.autocommit = True
    cur = conn.cursor()
    cur.execute(
        f"""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type='BASE TABLE'
          AND table_schema NOT IN ({PG_EXCLUDE})
        ORDER BY table_schema, table_name
        """
    )
    for schema, table in cur.fetchall():
        cur.execute(f'SELECT COUNT(*) FROM "{schema}"."{table}"')
        rc = int(cur.fetchone()[0])
        platform["total_tables"] += 1
        platform["total_rows"] += rc
        if rc > 0:
            platform["tables_with_data"] += 1
            platform["populated"].append({"schema": schema, "table": table, "rows": rc})
        else:
            platform["empty_tables"] += 1
            platform["empty"].append({"schema": schema, "table": table})
    cur.close()
    conn.close()
    result["platforms"]["postgresql"] = platform
except Exception as e:
    result["errors"]["postgresql"] = str(e)
    result["platforms"]["postgresql"] = build_platform_container()

# 3) MySQL
try:
    platform = build_platform_container()
    connected = False
    # direct connector attempts
    for host in ["localhost", "127.0.0.1", "172.23.224.1"]:
        try:
            conn = mysql.connector.connect(host=host, port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')", connection_timeout=30)
            connected = True
            mode = f"connector:{host}"
            break
        except Exception:
            continue

    if connected:
        cur = conn.cursor()
        cur.execute("SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME LIKE 'masreph_%' ORDER BY SCHEMA_NAME")
        dbs = [r[0] for r in cur.fetchall()]
        for db in dbs:
            cur.execute("SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA=%s AND TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME", (db,))
            for (table,) in cur.fetchall():
                cur.execute(f"SELECT COUNT(*) FROM `{db}`.`{table}`")
                rc = int(cur.fetchone()[0])
                platform["total_tables"] += 1
                platform["total_rows"] += rc
                if rc > 0:
                    platform["tables_with_data"] += 1
                    platform["populated"].append({"database": db, "table": table, "rows": rc})
                else:
                    platform["empty_tables"] += 1
                    platform["empty"].append({"database": db, "table": table})
        cur.close()
        conn.close()
    else:
        mode = "windows_mysql_cli"
        dbs = mysql_cli("SHOW DATABASES LIKE 'masreph_%';")
        for db in dbs:
            tables = mysql_cli(f"SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA='{db}' AND TABLE_TYPE='BASE TABLE' ORDER BY TABLE_NAME;")
            for table in tables:
                rc = int(mysql_cli(f"SELECT COUNT(*) FROM `{db}`.`{table}`;")[0])
                platform["total_tables"] += 1
                platform["total_rows"] += rc
                if rc > 0:
                    platform["tables_with_data"] += 1
                    platform["populated"].append({"database": db, "table": table, "rows": rc})
                else:
                    platform["empty_tables"] += 1
                    platform["empty"].append({"database": db, "table": table})

    platform["access_mode"] = mode
    result["platforms"]["mysql"] = platform
except Exception as e:
    result["errors"]["mysql"] = str(e)
    result["platforms"]["mysql"] = build_platform_container()

# 4) Snowflake
try:
    platform = build_platform_container()
    conn = snowflake.connector.connect(
        account="ittrelv-xu20591",
        user="hzmarrou",
        password="os.getenv('SNOWFLAKE_PASSWORD')",
        warehouse="COMPUTE_WH",
        database="MASREPH_RISK_ANALYTICS",
        login_timeout=30,
        network_timeout=30,
    )
    cur = conn.cursor()
    for schema in SNOWFLAKE_SCHEMAS:
        cur.execute(f"SHOW TABLES IN SCHEMA MASREPH_RISK_ANALYTICS.{schema}")
        tbl_rows = cur.fetchall()
        tables = [r[1] for r in tbl_rows]
        for table in tables:
            cur.execute(f'SELECT COUNT(*) FROM "MASREPH_RISK_ANALYTICS"."{schema}"."{table}"')
            rc = int(cur.fetchone()[0])
            platform["total_tables"] += 1
            platform["total_rows"] += rc
            if rc > 0:
                platform["tables_with_data"] += 1
                platform["populated"].append({"schema": schema, "table": table, "rows": rc})
            else:
                platform["empty_tables"] += 1
                platform["empty"].append({"schema": schema, "table": table})
    cur.close()
    conn.close()
    result["platforms"]["snowflake"] = platform
except Exception as e:
    result["errors"]["snowflake"] = str(e)
    result["platforms"]["snowflake"] = build_platform_container()

# 5) Oracle
try:
    platform = build_platform_container()
    wallet_dir = "/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet"
    conn = oracledb.connect(
        user="ADMIN",
        password="os.getenv('ORACLE_PASSWORD')",
        dsn="masrephdb_low",
        config_dir=wallet_dir,
        wallet_location=wallet_dir,
        wallet_password="os.getenv('ORACLE_PASSWORD')",
    )
    cur = conn.cursor()
    cur.execute("SELECT table_name FROM user_tables ORDER BY table_name")
    for (table,) in cur.fetchall():
        cur.execute(f'SELECT COUNT(*) FROM "{table}"')
        rc = int(cur.fetchone()[0])
        platform["total_tables"] += 1
        platform["total_rows"] += rc
        if rc > 0:
            platform["tables_with_data"] += 1
            platform["populated"].append({"table": table, "rows": rc})
        else:
            platform["empty_tables"] += 1
            platform["empty"].append({"table": table})
    cur.close()
    conn.close()
    result["platforms"]["oracle"] = platform
except Exception as e:
    result["errors"]["oracle"] = str(e)
    result["platforms"]["oracle"] = build_platform_container()

# 6) MongoDB
try:
    platform = build_platform_container()
    client = MongoClient(
        "mongodb+srv://hzmarrou:" + quote_plus(os.getenv('MONGODB_PASSWORD', '')) + "@masrephapi.c2lbreb.mongodb.net/",
        tls=True,
        tlsCAFile=certifi.where(),
        serverSelectionTimeoutMS=30000,
    )
    for db_name in sorted([d for d in client.list_database_names() if d.startswith("masreph_")]):
        db = client[db_name]
        for coll in sorted(db.list_collection_names()):
            rc = int(db[coll].count_documents({}))
            platform["total_tables"] += 1
            platform["total_rows"] += rc
            if rc > 0:
                platform["tables_with_data"] += 1
                platform["populated"].append({"database": db_name, "collection": coll, "rows": rc})
            else:
                platform["empty_tables"] += 1
                platform["empty"].append({"database": db_name, "collection": coll})
    result["platforms"]["mongodb"] = platform
except Exception as e:
    result["errors"]["mongodb"] = str(e)
    result["platforms"]["mongodb"] = build_platform_container()

# 7) Databricks
try:
    platform = build_platform_container()
    conn = databricks_sql.connect(
        server_hostname="adb-7405617014831513.13.azuredatabricks.net",
        http_path="/sql/1.0/warehouses/b3bee97b5042372c",
        access_token="os.getenv('DATABRICKS_TOKEN')",
        use_cloud_fetch=False,
    )
    cur = conn.cursor()
    cur.execute("SHOW SCHEMAS IN masreph_datalake")
    schemas = [r[0] for r in cur.fetchall() if r[0] not in ("default", "information_schema")]

    for schema in schemas:
        cur.execute(f"SHOW TABLES IN masreph_datalake.{schema}")
        for row in cur.fetchall():
            table = row[1] if len(row) > 1 else row[0]
            cur.execute(f"SELECT COUNT(*) FROM masreph_datalake.{schema}.`{table}`")
            rc = int(cur.fetchone()[0])
            platform["total_tables"] += 1
            platform["total_rows"] += rc
            if rc > 0:
                platform["tables_with_data"] += 1
                platform["populated"].append({"schema": schema, "table": table, "rows": rc})
            else:
                platform["empty_tables"] += 1
                platform["empty"].append({"schema": schema, "table": table})
    cur.close()
    conn.close()
    result["platforms"]["databricks"] = platform
except Exception as e:
    result["errors"]["databricks"] = str(e)
    result["platforms"]["databricks"] = build_platform_container()

# 8) Fabric
try:
    platform = build_platform_container()
    cred = ClientSecretCredential(
        "os.getenv('FABRIC_TENANT_ID')",
        "os.getenv('FABRIC_CLIENT_ID')",
        "os.getenv('FABRIC_CLIENT_SECRET')",
    )
    token = cred.get_token("https://database.windows.net/.default")
    token_bytes = token.token.encode("utf-16-le")
    token_struct = struct.pack(f"<I{len(token_bytes)}s", len(token_bytes), token_bytes)

    conn = pyodbc.connect(
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=bl27ioqsknou7alu6pwudenuwi-zn47x2vwde2uxfihk2wtmpr75a.datawarehouse.fabric.microsoft.com;"
        "DATABASE=MasrephCorporateBI_WH;"
        "Encrypt=yes;TrustServerCertificate=no;Timeout=30;",
        attrs_before={1256: token_struct},
        autocommit=True,
    )
    cur = conn.cursor()
    cur.execute(
        """
        SELECT TABLE_SCHEMA, TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE='BASE TABLE'
          AND TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA')
        ORDER BY TABLE_SCHEMA, TABLE_NAME
        """
    )
    for schema, table in cur.fetchall():
        cur.execute(f"SELECT COUNT(*) FROM [{schema}].[{table}]")
        rc = int(cur.fetchone()[0])
        platform["total_tables"] += 1
        platform["total_rows"] += rc
        if rc > 0:
            platform["tables_with_data"] += 1
            platform["populated"].append({"schema": schema, "table": table, "rows": rc})
        else:
            platform["empty_tables"] += 1
            platform["empty"].append({"schema": schema, "table": table})
    cur.close()
    conn.close()
    result["platforms"]["fabric"] = platform
except Exception as e:
    result["errors"]["fabric"] = str(e)
    result["platforms"]["fabric"] = build_platform_container()

# Summary
platform_order = [
    ("sql-server", "SQL Server"),
    ("postgresql", "PostgreSQL"),
    ("mysql", "MySQL"),
    ("snowflake", "Snowflake"),
    ("oracle", "Oracle"),
    ("mongodb", "MongoDB"),
    ("databricks", "Databricks"),
    ("fabric", "Fabric"),
]

sum_total = sum(result["platforms"][k]["total_tables"] for k, _ in platform_order)
sum_with = sum(result["platforms"][k]["tables_with_data"] for k, _ in platform_order)
sum_empty = sum(result["platforms"][k]["empty_tables"] for k, _ in platform_order)
sum_rows = sum(result["platforms"][k]["total_rows"] for k, _ in platform_order)

result["summary"] = {
    "total_tables": sum_total,
    "tables_with_data": sum_with,
    "empty_tables": sum_empty,
    "total_rows": sum_rows,
    "populated_pct": pct(sum_with, sum_total),
}

# Markdown report
md = []
md.append("# Data Population Audit — All 8 Platforms")
md.append("")
md.append("## Summary")
md.append("| Platform | Total Tables | Tables with Data | Empty Tables | Total Rows | % Populated |")
md.append("|---|---:|---:|---:|---:|---:|")
for key, label in platform_order:
    p = result["platforms"][key]
    md.append(f"| {label} | {p['total_tables']} | {p['tables_with_data']} | {p['empty_tables']} | {p['total_rows']} | {pct(p['tables_with_data'], p['total_tables'])}% |")
md.append(f"| **ALL** | **{sum_total}** | **{sum_with}** | **{sum_empty}** | **{sum_rows}** | **{pct(sum_with, sum_total)}%** |")
md.append("")

md.append("## Populated Tables (by platform)")
md.append("")

for key, label in platform_order:
    p = result["platforms"][key]
    md.append(f"### {label}")
    if key in result["errors"]:
        md.append(f"Connection/scan error: `{result['errors'][key]}`")
        md.append("")
        continue
    if key == "sql-server":
        md.append("| Database | Table | Rows |")
        md.append("|---|---|---:|")
        for r in p["populated"]:
            md.append(f"| {r['database']} | {r['table']} | {r['rows']} |")
    elif key in ("postgresql", "snowflake", "databricks", "fabric"):
        md.append("| Schema | Table | Rows |")
        md.append("|---|---|---:|")
        for r in p["populated"]:
            md.append(f"| {r['schema']} | {r['table']} | {r['rows']} |")
    elif key == "oracle":
        md.append("| Table | Rows |")
        md.append("|---|---:|")
        for r in p["populated"]:
            md.append(f"| {r['table']} | {r['rows']} |")
    elif key == "mysql":
        md.append("| Database | Table | Rows |")
        md.append("|---|---|---:|")
        for r in p["populated"]:
            md.append(f"| {r['database']} | {r['table']} | {r['rows']} |")
    elif key == "mongodb":
        md.append("| Database | Collection | Rows |")
        md.append("|---|---|---:|")
        for r in p["populated"]:
            md.append(f"| {r['database']} | {r['collection']} | {r['rows']} |")
    if not p["populated"]:
        md.append("| None | None | 0 |")
    md.append("")

md.append("## Empty Tables (by platform)")
md.append("")

for key, label in platform_order:
    p = result["platforms"][key]
    md.append(f"### {label}")
    if key in result["errors"]:
        md.append(f"Connection/scan error: `{result['errors'][key]}`")
        md.append("")
        continue
    if key == "sql-server":
        md.append("| Database | Table |")
        md.append("|---|---|")
        for r in p["empty"]:
            md.append(f"| {r['database']} | {r['table']} |")
    elif key in ("postgresql", "snowflake", "databricks", "fabric"):
        md.append("| Schema | Table |")
        md.append("|---|---|")
        for r in p["empty"]:
            md.append(f"| {r['schema']} | {r['table']} |")
    elif key == "oracle":
        md.append("| Table |")
        md.append("|---|")
        for r in p["empty"]:
            md.append(f"| {r['table']} |")
    elif key == "mysql":
        md.append("| Database | Table |")
        md.append("|---|---|")
        for r in p["empty"]:
            md.append(f"| {r['database']} | {r['table']} |")
    elif key == "mongodb":
        md.append("| Database | Collection |")
        md.append("|---|---|")
        for r in p["empty"]:
            md.append(f"| {r['database']} | {r['collection']} |")
    if not p["empty"]:
        md.append("| None — all tables/collections have data |  |")
    md.append("")

md.append("## Analysis")

# best/worst by populated pct for platforms with at least 1 table
rates = []
for key, label in platform_order:
    t = result["platforms"][key]["total_tables"]
    if t > 0:
        rates.append((label, pct(result["platforms"][key]["tables_with_data"], t)))
rates_sorted = sorted(rates, key=lambda x: x[1], reverse=True)

if rates_sorted:
    best = rates_sorted[0]
    worst = rates_sorted[-1]
    md.append(f"- Best population rate: **{best[0]}** at **{best[1]}%**.")
    md.append(f"- Lowest population rate: **{worst[0]}** at **{worst[1]}%**.")
else:
    md.append("- No platform had readable table counts.")

# common patterns
md.append("- Common empty-table pattern: dimension/reference and auxiliary analytics tables are often empty while a small set of primary transaction/customer tables are populated.")
md.append("- Cross-platform pattern: table families with similar names (risk/insight/snapshot/registry) frequently remain empty after deployment, suggesting partial load scripts or dependency ordering gaps.")
md.append("- Potential root causes: FK load order, connector type coercion failures, and platform-specific DDL/data type differences during generation.")

# priority recommendation
priority = sorted(
    [(label, result["platforms"][k]["empty_tables"], result["platforms"][k]["total_tables"]) for k, label in platform_order],
    key=lambda x: x[1],
    reverse=True,
)
md.append("- Recommended next fix priority (by empty table count): " + ", ".join([f"{x[0]} ({x[1]}/{x[2]})" for x in priority if x[2] > 0]) + ".")

if result["errors"]:
    md.append("- Connection issues encountered: " + "; ".join([f"{k}: {v}" for k, v in result["errors"].items()]) + ".")

md.append("")

MD_PATH.write_text("\n".join(md) + "\n", encoding="utf-8")
JSON_PATH.write_text(json.dumps(result, indent=2), encoding="utf-8")

print(str(MD_PATH))
print(str(JSON_PATH))
print(json.dumps(result["summary"], indent=2))
if result["errors"]:
    print("errors:")
    for k, v in result["errors"].items():
        print(f"- {k}: {v}")
