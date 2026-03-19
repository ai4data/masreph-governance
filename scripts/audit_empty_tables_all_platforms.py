#!/usr/bin/env python3
import json
import re
import struct
import subprocess
import time
import tempfile
from datetime import datetime, timezone
from typing import Dict, List, Any

import certifi
import mysql.connector
import oracledb
import psycopg2
import pyodbc
import snowflake.connector
from azure.identity import ClientSecretCredential
from databricks import sql as databricks_sql
from pymongo import MongoClient

ROOT = "/mnt/c/Users/Hicham/OneDrive/python/projects/masreph"
MD_PATH = f"{ROOT}/docs/EMPTY_TABLES_REPORT.md"
JSON_PATH = f"{ROOT}/config/empty_tables.json"

SQLCMD = "/mnt/c/Program Files/Microsoft SQL Server/Client SDK/ODBC/170/Tools/Binn/SQLCMD.EXE"

SNOWFLAKE_SCHEMAS = [
    "ACTICO", "COMPLIANCE_ARCHIVE", "CRC_SYSTEMS", "CREDIT_RISK_CONTROLS",
    "CREDIT_RISK_INSIGHTS", "ENDORSEMENT_EVALUATIO_APPLICATION", "ESRB_RATINGS",
    "EUROCOMPLY", "JUMIO_RISK_SIGNALS", "RACCENT", "RISKCONNECT",
    "SANCTION_SCANNER", "TRULIOO", "VERIFF"
]

result = {
    "generated_at": datetime.now(timezone.utc).isoformat(),
    "summary": {},
    "platforms": {},
    "errors": {}
}


def pct(empty: int, total: int) -> float:
    return round((empty / total * 100.0), 1) if total else 0.0


def sqlcmd_query(query: str, database: str = None, sep: str = "|") -> List[str]:
    args = [SQLCMD, "-S", "localhost", "-E"]
    if database:
        args += ["-d", database]
    args += ["-Q", f"SET NOCOUNT ON; {query}", "-W", "-s", sep, "-h", "-1"]
    last_err = None
    for _ in range(3):
        proc = subprocess.run(args, capture_output=True, text=True)
        if proc.returncode == 0:
            break
        last_err = proc.stderr.strip() or proc.stdout.strip() or f"sqlcmd rc={proc.returncode}"
        time.sleep(1.0)
    else:
        raise RuntimeError(last_err or "sqlcmd failed")
    lines = []
    for line in proc.stdout.splitlines():
        s = line.strip()
        if not s or "rows affected" in s:
            continue
        lines.append(s)
    return lines


# 1) SQL Server
try:
    sql_platform = {"total": 0, "empty": 0, "tables": []}
    tsql = """SET NOCOUNT ON;
DECLARE @sql nvarchar(max) = N'';
SELECT @sql = @sql + N'
SELECT ''' + REPLACE(name,'''','''''') + N''' AS db_name,
       t.TABLE_NAME,
       ISNULL(r.row_count,0) AS row_count,
       ISNULL(c.col_count,0) AS col_count
FROM [' + name + N'].INFORMATION_SCHEMA.TABLES t
LEFT JOIN (
    SELECT t2.name AS table_name, SUM(p.rows) AS row_count
    FROM [' + name + N'].sys.tables t2
    JOIN [' + name + N'].sys.partitions p
      ON p.object_id = t2.object_id
     AND p.index_id IN (0,1)
    GROUP BY t2.name
) r ON r.table_name = t.TABLE_NAME
LEFT JOIN (
    SELECT TABLE_NAME, COUNT(*) AS col_count
    FROM [' + name + N'].INFORMATION_SCHEMA.COLUMNS
    GROUP BY TABLE_NAME
) c ON c.TABLE_NAME = t.TABLE_NAME
WHERE t.TABLE_TYPE=''BASE TABLE''
UNION ALL
'
FROM sys.databases
WHERE name LIKE 'Masreph[_]%'
ORDER BY name;
IF LEN(@sql) > 10
BEGIN
    SET @sql = LEFT(@sql, LEN(@sql) - LEN(N'UNION ALL' + CHAR(10)));
    EXEC sp_executesql @sql;
END
"""
    with tempfile.NamedTemporaryFile("w", suffix=".sql", delete=False) as tf:
        tf.write(tsql)
        tf_path = tf.name
    win_path = subprocess.run(["wslpath", "-w", tf_path], capture_output=True, text=True, check=True).stdout.strip()
    proc = subprocess.run([SQLCMD, "-S", "localhost", "-E", "-i", win_path, "-W", "-s", "|", "-h", "-1"], capture_output=True, text=True)
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or proc.stdout.strip() or f"sqlcmd rc={proc.returncode}")
    for line in proc.stdout.splitlines():
        s = line.strip()
        if not s or "rows affected" in s:
            continue
        parts = [p.strip() for p in s.split("|")]
        if len(parts) < 4:
            continue
        db, table, row_count, col_count = parts[0], parts[1], int(parts[2]), int(parts[3])
        sql_platform["total"] += 1
        if row_count == 0:
            sql_platform["empty"] += 1
            sql_platform["tables"].append({"database": db, "table": table, "columns": col_count})
    result["platforms"]["sql-server"] = sql_platform
except Exception as e:
    result["errors"]["sql-server"] = str(e)
    result["platforms"]["sql-server"] = {"total": 0, "empty": 0, "tables": []}


# 2) PostgreSQL
try:
    pg_platform = {"total": 0, "empty": 0, "tables": []}
    pg = psycopg2.connect(
        host="aws-1-eu-west-2.pooler.supabase.com", port=5432, database="postgres",
        user="postgres.rlphlmkddecuptbklqeh", password="os.getenv('SUPABASE_CORE_PASSWORD')", connect_timeout=15
    )
    pg.autocommit = True
    cur = pg.cursor()
    exclude = (
        "'pg_catalog','information_schema','auth','storage','realtime','extensions','graphql',"
        "'graphql_public','pgsodium','pgsodium_masks','vault','supabase_functions','_realtime',"
        "'supabase_migrations','net','_analytics','public'"
    )
    cur.execute(
        f"""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type='BASE TABLE'
          AND table_schema NOT IN ({exclude})
        ORDER BY table_schema, table_name
        """
    )
    tables = cur.fetchall()

    col_map = {}
    cur.execute(
        f"""
        SELECT table_schema, table_name, COUNT(*)
        FROM information_schema.columns
        WHERE table_schema NOT IN ({exclude})
        GROUP BY table_schema, table_name
        """
    )
    for s, t, c in cur.fetchall():
        col_map[(s, t)] = int(c)

    for schema, table in tables:
        cur.execute(f'SELECT COUNT(*) FROM "{schema}"."{table}"')
        rc = int(cur.fetchone()[0])
        pg_platform["total"] += 1
        if rc == 0:
            pg_platform["empty"] += 1
            pg_platform["tables"].append({"schema": schema, "table": table, "columns": col_map.get((schema, table), 0)})

    cur.close()
    pg.close()
    result["platforms"]["postgresql"] = pg_platform
except Exception as e:
    result["errors"]["postgresql"] = str(e)
    result["platforms"]["postgresql"] = {"total": 0, "empty": 0, "tables": []}


# 3) MySQL
try:
    my_platform = {"total": 0, "empty": 0, "tables": []}
    mysql_hosts = ["localhost", "127.0.0.1", "172.23.224.1"]
    my = None
    last_mysql_err = None
    for h in mysql_hosts:
        try:
            my = mysql.connector.connect(host=h, port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')")
            my_platform["host_used"] = h
            break
        except Exception as ex:
            last_mysql_err = ex
    if my is not None:
        c = my.cursor()
        c.execute("SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME LIKE 'masreph_%' ORDER BY SCHEMA_NAME")
        dbs = [r[0] for r in c.fetchall()]
        for db in dbs:
            c.execute(
                """
                SELECT TABLE_NAME, IFNULL(TABLE_ROWS,0)
                FROM information_schema.tables
                WHERE TABLE_SCHEMA=%s AND TABLE_TYPE='BASE TABLE'
                ORDER BY TABLE_NAME
                """,
                (db,)
            )
            tables = c.fetchall()
            c.execute(
                """
                SELECT TABLE_NAME, COUNT(*)
                FROM information_schema.columns
                WHERE TABLE_SCHEMA=%s
                GROUP BY TABLE_NAME
                """,
                (db,)
            )
            col_map = {t: int(cnt) for t, cnt in c.fetchall()}
            for table, rows_est in tables:
                rc = int(rows_est) if rows_est is not None else 0
                my_platform["total"] += 1
                if rc == 0:
                    my_platform["empty"] += 1
                    my_platform["tables"].append({"database": db, "table": table, "columns": col_map.get(table, 0)})
        c.close()
        my.close()
    else:
        # Fallback: run Windows mysql.exe locally; root@localhost may deny WSL host IP but allow local CLI.
        mysql_exe = "/mnt/c/Program Files/MySQL/MySQL Server 8.0/bin/mysql.exe"
        my_platform["host_used"] = "windows_mysql_cli"
        q = (
            "SELECT t.TABLE_SCHEMA, t.TABLE_NAME, IFNULL(t.TABLE_ROWS,0) AS row_count, COUNT(c.COLUMN_NAME) AS col_count "
            "FROM information_schema.tables t "
            "LEFT JOIN information_schema.columns c ON c.TABLE_SCHEMA=t.TABLE_SCHEMA AND c.TABLE_NAME=t.TABLE_NAME "
            "WHERE t.TABLE_SCHEMA LIKE 'masreph_%' AND t.TABLE_TYPE='BASE TABLE' "
            "GROUP BY t.TABLE_SCHEMA, t.TABLE_NAME, t.TABLE_ROWS "
            "ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME"
        )
        proc = subprocess.run(
            [mysql_exe, "-uroot", "-pos.getenv('MYSQL_PASSWORD')", "-N", "-B", "-e", q],
            capture_output=True,
            text=True,
        )
        if proc.returncode != 0:
            raise RuntimeError((proc.stderr or proc.stdout).strip() or "mysql.exe fallback failed")
        for line in proc.stdout.splitlines():
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) < 4:
                continue
            db, table, row_count, col_count = parts[0], parts[1], int(parts[2]), int(parts[3])
            my_platform["total"] += 1
            if row_count == 0:
                my_platform["empty"] += 1
                my_platform["tables"].append({"database": db, "table": table, "columns": col_count})
    result["platforms"]["mysql"] = my_platform
except Exception as e:
    result["errors"]["mysql"] = str(e)
    result["platforms"]["mysql"] = {"total": 0, "empty": 0, "tables": []}


# 4) Snowflake
try:
    sf_platform = {"total": 0, "empty": 0, "tables": []}
    sf = snowflake.connector.connect(
        account="ittrelv-xu20591", user="hzmarrou", password="os.getenv('SNOWFLAKE_PASSWORD')",
        warehouse="COMPUTE_WH", database="MASREPH_RISK_ANALYTICS"
    )
    c = sf.cursor()
    for schema in SNOWFLAKE_SCHEMAS:
        c.execute(f"SHOW TABLES IN SCHEMA MASREPH_RISK_ANALYTICS.{schema}")
        tbl_rows = c.fetchall()
        tables = [r[1] for r in tbl_rows]  # name column

        c.execute(
            f"""
            SELECT TABLE_NAME, COUNT(*)
            FROM MASREPH_RISK_ANALYTICS.INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA = '{schema}'
            GROUP BY TABLE_NAME
            """
        )
        col_map = {t: int(cnt) for t, cnt in c.fetchall()}

        for table in tables:
            c.execute(f'SELECT COUNT(*) FROM "MASREPH_RISK_ANALYTICS"."{schema}"."{table}"')
            rc = int(c.fetchone()[0])
            sf_platform["total"] += 1
            if rc == 0:
                sf_platform["empty"] += 1
                sf_platform["tables"].append({"schema": schema, "table": table, "columns": col_map.get(table, 0)})
    c.close()
    sf.close()
    result["platforms"]["snowflake"] = sf_platform
except Exception as e:
    result["errors"]["snowflake"] = str(e)
    result["platforms"]["snowflake"] = {"total": 0, "empty": 0, "tables": []}


# 5) Oracle
try:
    or_platform = {"total": 0, "empty": 0, "tables": []}
    wallet_dir = "/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet"
    ora = oracledb.connect(
        user="ADMIN", password="os.getenv('ORACLE_PASSWORD')", dsn="masrephdb_low",
        config_dir=wallet_dir, wallet_location=wallet_dir, wallet_password="os.getenv('ORACLE_PASSWORD')"
    )
    c = ora.cursor()
    c.execute("SELECT table_name FROM user_tables ORDER BY table_name")
    tables = [r[0] for r in c.fetchall()]
    c.execute("SELECT table_name, COUNT(*) FROM user_tab_columns GROUP BY table_name")
    col_map = {t: int(cnt) for t, cnt in c.fetchall()}
    for table in tables:
        c.execute(f'SELECT COUNT(*) FROM "{table}"')
        rc = int(c.fetchone()[0])
        or_platform["total"] += 1
        if rc == 0:
            or_platform["empty"] += 1
            or_platform["tables"].append({"table": table, "columns": col_map.get(table, 0)})
    c.close()
    ora.close()
    result["platforms"]["oracle"] = or_platform
except Exception as e:
    result["errors"]["oracle"] = str(e)
    result["platforms"]["oracle"] = {"total": 0, "empty": 0, "tables": []}


# 6) MongoDB
try:
    mg_platform = {"total": 0, "empty": 0, "tables": []}
    client = MongoClient(
        "mongodb+srv://hzmarrou:" + quote_plus(os.getenv('MONGODB_PASSWORD', '')) + "@masrephapi.c2lbreb.mongodb.net/",
        tls=True,
        tlsCAFile=certifi.where(),
    )
    dbs = sorted([d for d in client.list_database_names() if d.startswith("masreph_")])
    for db_name in dbs:
        db = client[db_name]
        for coll_name in sorted(db.list_collection_names()):
            rc = db[coll_name].count_documents({})
            mg_platform["total"] += 1
            if rc == 0:
                doc = db[coll_name].find_one()
                fields = len([k for k in doc.keys() if k != "_id"]) if doc else 0
                mg_platform["empty"] += 1
                mg_platform["tables"].append({"database": db_name, "collection": coll_name, "fields": fields})
    result["platforms"]["mongodb"] = mg_platform
except Exception as e:
    result["errors"]["mongodb"] = str(e)
    result["platforms"]["mongodb"] = {"total": 0, "empty": 0, "tables": []}


# 7) Databricks
try:
    dbx_platform = {"total": 0, "empty": 0, "tables": []}
    conn = databricks_sql.connect(
        server_hostname="adb-7405617014831513.13.azuredatabricks.net",
        http_path="/sql/1.0/warehouses/b3bee97b5042372c",
        access_token="os.getenv('DATABRICKS_TOKEN')",
    )
    c = conn.cursor()
    c.execute("SHOW SCHEMAS IN masreph_datalake")
    schemas = [r[0] for r in c.fetchall() if r[0] not in ("default", "information_schema")]

    col_map = {}
    c.execute(
        """
        SELECT table_schema, table_name, COUNT(*) AS col_count
        FROM masreph_datalake.information_schema.columns
        GROUP BY table_schema, table_name
        """
    )
    for s, t, cc in c.fetchall():
        col_map[(s, t)] = int(cc)

    for schema in schemas:
        c.execute(f"SHOW TABLES IN masreph_datalake.{schema}")
        tables = [r[1] for r in c.fetchall()]
        for table in tables:
            c.execute(f"SELECT COUNT(*) FROM masreph_datalake.{schema}.`{table}`")
            rc = int(c.fetchone()[0])
            dbx_platform["total"] += 1
            if rc == 0:
                dbx_platform["empty"] += 1
                dbx_platform["tables"].append({"schema": schema, "table": table, "columns": col_map.get((schema, table), 0)})

    c.close()
    conn.close()
    result["platforms"]["databricks"] = dbx_platform
except Exception as e:
    result["errors"]["databricks"] = str(e)
    result["platforms"]["databricks"] = {"total": 0, "empty": 0, "tables": []}


# 8) Microsoft Fabric
try:
    fb_platform = {"total": 0, "empty": 0, "tables": []}
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
        "DATABASE=MasrephCorporateBI_WH;",
        attrs_before={1256: token_struct},
        autocommit=True,
    )
    c = conn.cursor()
    c.execute(
        """
        SELECT TABLE_SCHEMA, TABLE_NAME
        FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_TYPE='BASE TABLE'
          AND TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA')
        ORDER BY TABLE_SCHEMA, TABLE_NAME
        """
    )
    tables = c.fetchall()

    c.execute(
        """
        SELECT TABLE_SCHEMA, TABLE_NAME, COUNT(*)
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA')
        GROUP BY TABLE_SCHEMA, TABLE_NAME
        """
    )
    col_map = {(s, t): int(cc) for s, t, cc in c.fetchall()}

    for schema, table in tables:
        c.execute(f"SELECT COUNT(*) FROM [{schema}].[{table}]")
        rc = int(c.fetchone()[0])
        fb_platform["total"] += 1
        if rc == 0:
            fb_platform["empty"] += 1
            fb_platform["tables"].append({"schema": schema, "table": table, "columns": col_map.get((schema, table), 0)})

    c.close()
    conn.close()
    result["platforms"]["fabric"] = fb_platform
except Exception as e:
    result["errors"]["fabric"] = str(e)
    result["platforms"]["fabric"] = {"total": 0, "empty": 0, "tables": []}


# Aggregate summary
total_tables = sum(v.get("total", 0) for v in result["platforms"].values())
empty_tables = sum(v.get("empty", 0) for v in result["platforms"].values())
with_data = total_tables - empty_tables
result["summary"] = {
    "total_tables": total_tables,
    "tables_with_data": with_data,
    "empty_tables": empty_tables,
    "empty_pct": pct(empty_tables, total_tables),
}


# Markdown output
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

md = []
md.append("# Empty Tables Report — All 8 Platforms")
md.append("")
md.append("## Summary")
md.append("| Platform | Total Tables | Tables with Data | Empty Tables | % Empty |")
md.append("|---|---:|---:|---:|---:|")
for key, label in platform_order:
    p = result["platforms"].get(key, {"total": 0, "empty": 0})
    t = p.get("total", 0)
    e = p.get("empty", 0)
    md.append(f"| {label} | {t} | {t-e} | {e} | {pct(e,t)}% |")
md.append(f"| **ALL** | **{total_tables}** | **{with_data}** | **{empty_tables}** | **{pct(empty_tables,total_tables)}%** |")
md.append("")

md.append("## Empty Tables by Platform")
md.append("")

for key, label in platform_order:
    md.append(f"### {label}")
    if key in result.get("errors", {}):
        md.append(f"Connection/scan error: `{result['errors'][key]}`")
        md.append("")
        continue

    tables = result["platforms"][key].get("tables", [])
    if key == "sql-server":
        md.append("| Database | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['database']} | {r['table']} | {r['columns']} |")
    elif key == "postgresql":
        md.append("| Schema | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['schema']} | {r['table']} | {r['columns']} |")
    elif key == "mysql":
        md.append("| Database | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['database']} | {r['table']} | {r['columns']} |")
    elif key == "snowflake":
        md.append("| Schema | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['schema']} | {r['table']} | {r['columns']} |")
    elif key == "oracle":
        md.append("| Table | Columns |")
        md.append("|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |")
        else:
            for r in tables:
                md.append(f"| {r['table']} | {r['columns']} |")
    elif key == "mongodb":
        md.append("| Database | Collection | Fields |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all collections have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['database']} | {r['collection']} | {r['fields']} |")
    elif key == "databricks":
        md.append("| Schema | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['schema']} | {r['table']} | {r['columns']} |")
    elif key == "fabric":
        md.append("| Schema | Table | Columns |")
        md.append("|---|---|---:|")
        if not tables:
            md.append("| None — all tables have data |  |  |")
        else:
            for r in tables:
                md.append(f"| {r['schema']} | {r['table']} | {r['columns']} |")
    md.append("")

with open(MD_PATH, "w", encoding="utf-8") as f:
    f.write("\n".join(md) + "\n")

with open(JSON_PATH, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2)

print(MD_PATH)
print(JSON_PATH)
print(json.dumps(result["summary"], indent=2))
if result["errors"]:
    print("errors:")
    for k, v in result["errors"].items():
        print(f"- {k}: {v}")
