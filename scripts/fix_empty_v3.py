#!/usr/bin/env python3
"""
Fix empty tables using schema_results_v2.json metadata.
Each column's original_element + data_type tells us exactly what value to generate.
No more guessing from column names.
"""

import os
import sys
import json
import random
import string
import re
import uuid
import logging
from collections import defaultdict, deque
from datetime import datetime, date, timedelta
try:
    from dotenv import load_dotenv
except Exception:
    def load_dotenv(*args, **kwargs):
        return False

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))
sys.path.insert(0, os.path.dirname(__file__))
from generate_data_v2 import CUSTOMERS, PRODUCTS, CONTRACTS, classify_column, get_entity_value

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")

# Load schema results — the source of truth for column types
with open(os.path.join(BASE_DIR, "config", "schema_results_v2.json")) as f:
    SCHEMA_RESULTS = json.load(f)


def parse_type(data_type):
    """Parse a data type string like 'DECIMAL(18,2)' into base, precision, scale."""
    m = re.match(r'(\w+)\((\d+),?(\d*)\)', data_type or "")
    if m:
        base = normalize_base_type(m.group(1).upper())
        prec = int(m.group(2))
        scale = int(m.group(3)) if m.group(3) else 0
        return base, prec, scale
    m2 = re.match(r'(\w+)\((\d+)\)', data_type or "")
    if m2:
        return normalize_base_type(m2.group(1).upper()), int(m2.group(2)), 0
    return normalize_base_type((data_type or "VARCHAR").upper().split("(")[0].strip()), None, None


def normalize_base_type(base_type):
    b = (base_type or "").upper().strip()
    mapping = {
        "BOOL": "BOOLEAN",
        "BOOLEAN": "BOOLEAN",
        "INT4": "INTEGER",
        "INT8": "BIGINT",
        "INT2": "SMALLINT",
        "SERIAL4": "SERIAL",
        "SERIAL8": "BIGSERIAL",
        "FLOAT8": "DOUBLE",
        "FLOAT4": "FLOAT",
        "DOUBLE PRECISION": "DOUBLE",
        "DEC": "DECIMAL",
        "BPCHAR": "CHAR",
        "CHARACTER VARYING": "VARCHAR",
        "CHARACTER": "CHAR",
        "TIMESTAMP WITHOUT TIME ZONE": "TIMESTAMP",
        "TIMESTAMP WITH TIME ZONE": "TIMESTAMPTZ",
        "DATETIME2": "DATETIME",
    }
    return mapping.get(b, b)


def build_type_string(base_type, char_len=None, num_prec=None, num_scale=None):
    b = normalize_base_type(base_type)
    if b in ("DECIMAL", "NUMERIC", "NUMBER", "FLOAT", "DOUBLE", "MONEY"):
        if num_prec is not None:
            s = num_scale if num_scale is not None else 0
            return f"{b}({int(num_prec)},{int(s)})"
    if b in ("VARCHAR", "CHAR", "NVARCHAR", "NCHAR") and char_len and int(char_len) > 0:
        return f"{b}({int(char_len)})"
    return b


def make_col_meta(name, data_type, nullable=True, is_primary_key=False, original_element=None):
    return {
        "name": name,
        "data_type": data_type,
        "nullable": bool(nullable),
        "is_primary_key": bool(is_primary_key),
        "original_element": original_element or name,
    }


def split_top_level(text, sep=","):
    parts = []
    cur = []
    depth = 0
    for ch in text:
        if ch == "<":
            depth += 1
        elif ch == ">":
            depth = max(0, depth - 1)
        if ch == sep and depth == 0:
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    if cur:
        parts.append("".join(cur).strip())
    return parts


def databricks_default_literal(dtype):
    t = (dtype or "").strip()
    tl = t.lower()
    if tl.startswith("map<") and tl.endswith(">"):
        inner = t[t.find("<") + 1 : -1]
        kv = split_top_level(inner)
        if len(kv) == 2:
            return f"map({databricks_default_literal(kv[0])}, {databricks_default_literal(kv[1])})"
        return "map('k','v')"
    if tl.startswith("array<") and tl.endswith(">"):
        inner = t[t.find("<") + 1 : -1]
        return f"array({databricks_default_literal(inner)})"
    if tl.startswith("struct<") and tl.endswith(">"):
        inner = t[t.find("<") + 1 : -1]
        fields = split_top_level(inner)
        parts = []
        for f in fields:
            if ":" in f:
                n, ft = f.split(":", 1)
                parts.append(f"'{n.strip()}'")
                parts.append(databricks_default_literal(ft.strip()))
        return "named_struct(" + ", ".join(parts) + ")" if parts else "named_struct('k','v')"
    if "decimal" in tl or "double" in tl or "float" in tl:
        return "1.0"
    if "bigint" in tl or "int" in tl or "smallint" in tl or "tinyint" in tl:
        return "1"
    if "boolean" in tl:
        return "true"
    if "date" in tl and "timestamp" not in tl:
        return "'2024-01-01'"
    if "timestamp" in tl:
        return "'2024-01-01 00:00:00'"
    if "binary" in tl:
        return "unhex('00')"
    return "'val_1'"


def is_semi_structured_type(dtype):
    base_type, _, _ = parse_type(dtype or "")
    return base_type in ("VARIANT", "OBJECT", "ARRAY", "JSON", "JSONB")


def to_json_text_for_snowflake(val):
    """Convert Python values to valid JSON text for PARSE_JSON(%s)."""
    if val is None:
        return "null"
    if isinstance(val, (dict, list, bool, int, float)):
        return json.dumps(val, ensure_ascii=False)
    if isinstance(val, (datetime, date)):
        return json.dumps(str(val), ensure_ascii=False)
    if isinstance(val, bytes):
        return json.dumps(val.hex(), ensure_ascii=False)
    if isinstance(val, str):
        s = val.strip()
        if not s:
            return json.dumps("", ensure_ascii=False)
        try:
            # Already valid JSON object/array/scalar text.
            json.loads(s)
            return s
        except Exception:
            return json.dumps(val, ensure_ascii=False)
    return json.dumps(str(val), ensure_ascii=False)


def is_uuid_type(base_type, full_type=""):
    t = f"{base_type} {full_type}".upper()
    return "UUID" in t or "UNIQUEIDENTIFIER" in t


def is_int_type(base_type, scale):
    return base_type in ("INT", "INTEGER", "BIGINT", "SMALLINT", "MEDIUMINT", "TINYINT", "SERIAL", "BIGSERIAL") or (
        base_type == "NUMBER" and (scale is None or scale == 0)
    )


def topological_sort(nodes, dependencies):
    """
    Kahn topological sort.
    dependencies: child -> set(parent)
    """
    deps = {n: set(dependencies.get(n, set())) for n in nodes}
    reverse = defaultdict(set)
    for child, parents in deps.items():
        for p in parents:
            reverse[p].add(child)

    q = deque(sorted([n for n in nodes if not deps[n]]))
    ordered = []
    while q:
        n = q.popleft()
        ordered.append(n)
        for child in sorted(reverse.get(n, set())):
            deps[child].discard(n)
            if not deps[child]:
                q.append(child)

    if len(ordered) < len(nodes):
        remaining = sorted([n for n in nodes if n not in set(ordered)])
        ordered.extend(remaining)
    return ordered


def get_pk_offset(cur, table_ref, col_name, platform):
    """Find a safe PK start offset so we don't collide with existing rows."""
    try:
        if platform == "postgresql":
            cur.execute(f"SELECT MAX({col_name}) FROM {table_ref}")
        elif platform == "mysql":
            cur.execute(f"SELECT MAX(`{col_name}`) FROM {table_ref}")
        elif platform == "sql-server":
            cur.execute(f"SELECT MAX([{col_name}]) FROM {table_ref}")
        else:
            return 0
        mx = cur.fetchone()[0]
        if mx is None:
            return 0
        if isinstance(mx, (int, float)):
            return int(mx)
        m = re.search(r'(\d+)$', str(mx))
        return int(m.group(1)) if m else 0
    except Exception:
        return 0


def fetch_distinct_values(cur, table_ref, col_name, platform, limit=2000):
    """Read FK candidate values from parent tables."""
    try:
        if platform == "postgresql":
            sql = f"SELECT DISTINCT {col_name} FROM {table_ref} WHERE {col_name} IS NOT NULL LIMIT {limit}"
        elif platform == "snowflake":
            sql = f'SELECT DISTINCT "{col_name}" FROM {table_ref} WHERE "{col_name}" IS NOT NULL LIMIT {limit}'
        elif platform == "mysql":
            sql = f"SELECT DISTINCT `{col_name}` FROM {table_ref} WHERE `{col_name}` IS NOT NULL LIMIT {limit}"
        elif platform == "sql-server":
            sql = f"SELECT DISTINCT TOP {limit} [{col_name}] FROM {table_ref} WHERE [{col_name}] IS NOT NULL"
        else:
            return []
        cur.execute(sql)
        return [r[0] for r in cur.fetchall() if r and r[0] is not None]
    except Exception:
        return []


def gen_value_from_metadata(col_meta, platform, row_idx, context=None):
    """Generate a value using the schema_results column metadata."""
    context = context or {}
    col_name = col_meta["name"]
    data_type = col_meta.get("data_type", "VARCHAR(255)")
    original = col_meta.get("original_element")
    nullable = col_meta.get("nullable", True)
    is_pk = col_meta.get("is_primary_key", False)

    base_type, prec, scale = parse_type(data_type)

    # PostgreSQL BOOLEAN needs Python bool, not int
    if base_type in ("BOOLEAN",) and platform in ("postgresql", "databricks", "snowflake"):
        val = _gen_val_inner(col_meta, platform, row_idx, base_type, prec, scale, context)
        if isinstance(val, (int, float)):
            return bool(val)
        return val if isinstance(val, bool) else random.choice([True, False])

    return _gen_val_inner(col_meta, platform, row_idx, base_type, prec, scale, context)


def _gen_val_inner(col_meta, platform, row_idx, base_type, prec, scale, context):
    col_name = col_meta["name"]
    data_type = col_meta.get("data_type", "VARCHAR(255)")
    original = col_meta.get("original_element")
    nullable = col_meta.get("nullable", True)
    is_pk = col_meta.get("is_primary_key", False)
    col_key = col_name.lower()

    # FK columns: use actual parent IDs when available
    fk_values = context.get("fk_values", {})
    if col_key in fk_values and fk_values[col_key]:
        return coerce_to_type(random.choice(fk_values[col_key]), base_type, prec, scale, data_type)
    if col_key in context.get("nullable_fk_columns", set()):
        return None

    # PK columns
    if is_pk:
        offset = context.get("pk_offsets", {}).get(col_key, 0)
        idx = row_idx + 1 + max(offset, 0)
        if is_int_type(base_type, scale):
            return idx
        if is_uuid_type(base_type, data_type):
            return str(uuid.uuid4())
        if "CHAR" in base_type or base_type == "STRING":
            return f"PK{idx:06d}"
        if base_type == "DATE":
            return date(2023, 1, 1) + timedelta(days=idx % 1000)
        if base_type in ("TIMESTAMP", "DATETIME", "DATETIME2", "TIMESTAMPTZ", "TIMESTAMP_NTZ"):
            return datetime(2023, 1, 1) + timedelta(days=idx % 1000, hours=idx % 24)
        return gen_from_type(col_name, base_type, prec, scale, data_type, platform)

    # Try master entity mapping using original_element name
    if original:
        ft = classify_column(original)
        if ft:
            customer = CUSTOMERS[row_idx % len(CUSTOMERS)]
            product = PRODUCTS[row_idx % len(PRODUCTS)]
            contract = CONTRACTS[row_idx % len(CONTRACTS)]
            val = get_entity_value(ft, customer, product, contract, platform)
            if val is not None:
                return coerce_to_type(val, base_type, prec, scale, data_type)

    # FK columns (generated, not original)
    if original is None and not is_pk:
        n = col_name.lower()
        if n.endswith("_id") or n.endswith("id"):
            if is_uuid_type(base_type, data_type):
                return str(uuid.uuid4())
            if is_int_type(base_type, scale):
                return random.randint(1, 500)
            return f"REF{random.randint(10000,99999)}"

    # Generate based on data_type
    return gen_from_type(col_name, base_type, prec, scale, data_type, platform)


def coerce_to_type(val, base_type, prec, scale, full_type):
    """Coerce a master entity value to the exact database type."""
    # UUID types
    if is_uuid_type(base_type, full_type):
        try:
            return str(uuid.UUID(str(val)))
        except Exception:
            return str(uuid.uuid4())

    # String types
    if "CHAR" in base_type or base_type in ("TEXT", "STRING", "CLOB", "NTEXT"):
        s = str(val) if not isinstance(val, dict) else json.dumps(val)
        if prec: s = s[:prec]
        return s

    # Integer types
    if base_type in ("INT", "INTEGER", "BIGINT", "SMALLINT", "MEDIUMINT", "TINYINT") or (base_type == "NUMBER" and (scale is None or scale == 0)):
        if isinstance(val, bool): return 1 if val else 0
        try:
            v = int(float(val))
            if prec: v = min(v, 10**prec - 1)
            return v
        except: return random.randint(1, 9999)

    # Decimal types
    if base_type in ("DECIMAL", "NUMERIC", "FLOAT", "DOUBLE", "MONEY") or (base_type == "NUMBER" and scale and scale > 0):
        try:
            v = float(val)
            if prec and scale:
                max_v = 10 ** (prec - scale) - 1
                v = min(abs(v), max_v) * (1 if v >= 0 else -1)
            return round(v, scale or 2)
        except: return round(random.uniform(0, 999), scale or 2)

    # Boolean / BIT
    if base_type in ("BIT", "BOOLEAN", "BOOL") or (base_type == "TINYINT" and prec == 1):
        if isinstance(val, bool): return 1 if val else 0
        return random.choice([0, 1])

    # Date
    if base_type == "DATE":
        if isinstance(val, (date, datetime)): return val if isinstance(val, date) else val.date()
        if isinstance(val, str):
            try: return date.fromisoformat(val[:10])
            except: return date(2023, 1, 1)
        return date(2023, 1, 1)

    # Timestamp / Datetime
    if base_type in ("TIMESTAMP", "DATETIME", "DATETIME2", "TIMESTAMPTZ", "TIMESTAMP_NTZ"):
        if isinstance(val, datetime): return val
        if isinstance(val, date): return datetime(val.year, val.month, val.day)
        if isinstance(val, str):
            try: return datetime.fromisoformat(val) if "T" in val else datetime.fromisoformat(val + "T00:00:00")
            except: return datetime(2023, 1, 1)
        return datetime(2023, 1, 1)

    # RAW
    if base_type == "RAW":
        return bytes(random.getrandbits(8) for _ in range(16))

    # Snowflake/JSON semi-structured types
    if base_type in ("VARIANT", "OBJECT", "ARRAY", "JSON", "JSONB"):
        if isinstance(val, (dict, list)):
            return val
        if isinstance(val, str):
            try:
                parsed = json.loads(val)
                if isinstance(parsed, (dict, list)):
                    return parsed
            except Exception:
                pass
        if base_type == "ARRAY":
            return [str(val)]
        return {"key": str(val)}

    return str(val)[:255]


def gen_from_type(col_name, base_type, prec, scale, full_type, platform):
    """Generate a value purely from the database type."""
    n = col_name.lower()

    # UUID / uniqueidentifier
    if is_uuid_type(base_type, full_type):
        return str(uuid.uuid4())

    # Boolean
    if base_type in ("BIT", "BOOLEAN", "BOOL") or (base_type == "TINYINT" and prec == 1) or (base_type == "NUMBER" and prec == 1):
        return random.choice([0, 1])

    # Integer
    if base_type in ("INT", "INTEGER", "BIGINT", "SMALLINT", "MEDIUMINT", "TINYINT", "SERIAL", "BIGSERIAL") or (base_type == "NUMBER" and (scale is None or scale == 0)):
        max_v = min(10 ** (prec or 9) - 1, 999999)
        return random.randint(1, max_v)

    # Decimal
    if base_type in ("DECIMAL", "NUMERIC", "FLOAT", "DOUBLE", "MONEY") or (base_type == "NUMBER" and scale and scale > 0):
        p = prec or 18
        s = scale or 2
        max_v = min(10 ** (p - s) - 1, 999999)
        return round(random.uniform(0, max_v), min(s, 4))

    # Date
    if base_type == "DATE":
        return date(2023, 1, 1) + timedelta(days=random.randint(0, 1000))

    # Timestamp
    if base_type in ("TIMESTAMP", "DATETIME", "DATETIME2", "TIMESTAMPTZ", "TIMESTAMP_NTZ"):
        return datetime(2023, 1, 1) + timedelta(days=random.randint(0, 1000), hours=random.randint(0, 23))

    # RAW
    if base_type == "RAW":
        return bytes(random.getrandbits(8) for _ in range(16))

    # Snowflake/JSON semi-structured types
    if base_type in ("VARIANT", "OBJECT", "ARRAY", "JSON", "JSONB"):
        if base_type == "ARRAY":
            return [f"val_{random.randint(1,999)}"]
        return {"key": f"val_{random.randint(1,999)}"}

    # CLOB
    if base_type in ("CLOB", "NCLOB", "LONG"):
        return "Standard financial record"

    # String / VARCHAR / NVARCHAR / CHAR / TEXT / STRING
    ml = prec or 255
    if ml < 0 or ml > 4000: ml = 255
    if "email" in n: return f"u{random.randint(1,999)}@masreph.com"[:ml]
    if "phone" in n or "mobile" in n: return f"+31 6{random.randint(10000000,99999999)}"[:ml]
    if "country" in n: return random.choice(["NL","DE","FR","GB","US"])[:ml]
    if "currency" in n: return random.choice(["EUR","USD","GBP"])[:ml]
    if "status" in n: return random.choice(["active","inactive","pending"])[:ml]
    if "name" in n or "nm" in n: return f"{random.choice(['Jan','Maria','Thomas','Sophie'])} {random.choice(['de Jong','Bakker','Schmidt'])}"[:ml]
    if "gender" in n: return random.choice(["M","F","X"])[:ml]
    if "iban" in n: return f"NL{random.randint(10,99)}MASREPH{random.randint(1000000000,9999999999)}"[:ml]
    if "id" in n or "code" in n or "ref" in n or "key" in n:
        return f"{''.join(random.choices(string.ascii_uppercase, k=3))}{random.randint(1000,9999)}"[:ml]
    if any(k in n for k in ["desc", "comment", "note", "summary", "remark"]):
        return "Standard financial record"[:ml]
    return f"val_{random.randint(100,9999)}"[:ml]


def determine_rows(table_name):
    name = table_name.lower()
    if any(k in name for k in ["dim", "status", "type", "category", "ref", "lookup"]): return random.randint(20, 50)
    if any(k in name for k in ["fact", "transaction", "event", "log", "history", "payment"]): return random.randint(200, 500)
    if any(k in name for k in ["customer", "client", "contact", "account"]): return random.randint(100, 300)
    return random.randint(50, 200)


# ─── BUILD TABLE INDEX from schema_results ──────────────────────────────────

def build_table_index():
    """Build a lookup: (platform, schema, table) -> column metadata list."""
    index = {}
    for platform, datasets in SCHEMA_RESULTS.items():
        for ds_id, data in datasets.items():
            schema = data.get("schema_name", "").lower()
            for table in data.get("tables", []):
                # Store by (platform, schema, table) AND (platform, table) for fallback
                key_full = (platform, schema, table["name"].lower())
                key_short = (platform, table["name"].lower())
                index[key_full] = table.get("columns", [])
                # Only use short key if not already taken (avoids collisions)
                if key_short not in index:
                    index[key_short] = table.get("columns", [])
    return index

TABLE_INDEX = build_table_index()
logger.info(f"Table index: {len(TABLE_INDEX)} entries across all platforms")


def find_columns(platform, table_name, schema_name=None):
    """Find column metadata for a table from schema_results."""
    # Try full match first
    if schema_name:
        key_full = (platform, schema_name.lower(), table_name.lower())
        if key_full in TABLE_INDEX:
            return TABLE_INDEX[key_full]
    # Try short match
    key_short = (platform, table_name.lower())
    if key_short in TABLE_INDEX:
        return TABLE_INDEX[key_short]
    return None


def build_pg_fk_map(cur, schema, tables):
    table_set = {t for t in tables}
    cur.execute(
        """
        SELECT
            kcu.table_name AS child_table,
            kcu.column_name AS child_column,
            ccu.table_schema AS parent_schema,
            ccu.table_name AS parent_table,
            ccu.column_name AS parent_column
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage ccu
          ON ccu.constraint_name = tc.constraint_name AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_schema = %s
        """,
        (schema,),
    )
    fk_map = defaultdict(list)
    deps = defaultdict(set)
    for child_t, child_c, parent_s, parent_t, parent_c in cur.fetchall():
        fk_map[child_t].append((child_c, parent_s, parent_t, parent_c))
        if child_t in table_set and parent_t in table_set and parent_s == schema:
            deps[child_t].add(parent_t)
    return fk_map, deps


def build_mysql_fk_map(cur, db, tables):
    table_set = {t for t in tables}
    cur.execute(
        """
        SELECT
            TABLE_NAME,
            COLUMN_NAME,
            REFERENCED_TABLE_SCHEMA,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA=%s AND REFERENCED_TABLE_NAME IS NOT NULL
        """,
        (db,),
    )
    fk_map = defaultdict(list)
    deps = defaultdict(set)
    for child_t, child_c, parent_s, parent_t, parent_c in cur.fetchall():
        fk_map[child_t].append((child_c, parent_s, parent_t, parent_c))
        if child_t in table_set and parent_t in table_set and parent_s == db:
            deps[child_t].add(parent_t)
    return fk_map, deps


def build_sqlserver_fk_map(cur, tables):
    table_set = {t for t in tables}
    cur.execute(
        """
        SELECT
            KCU1.TABLE_SCHEMA AS child_schema,
            KCU1.TABLE_NAME AS child_table,
            KCU1.COLUMN_NAME AS child_column,
            KCU2.TABLE_SCHEMA AS parent_schema,
            KCU2.TABLE_NAME AS parent_table,
            KCU2.COLUMN_NAME AS parent_column
        FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU1
          ON KCU1.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG
         AND KCU1.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
         AND KCU1.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KCU2
          ON KCU2.CONSTRAINT_CATALOG = RC.UNIQUE_CONSTRAINT_CATALOG
         AND KCU2.CONSTRAINT_SCHEMA = RC.UNIQUE_CONSTRAINT_SCHEMA
         AND KCU2.CONSTRAINT_NAME = RC.UNIQUE_CONSTRAINT_NAME
         AND KCU2.ORDINAL_POSITION = KCU1.ORDINAL_POSITION
        """
    )
    fk_map = defaultdict(list)
    deps = defaultdict(set)
    for child_s, child_t, child_c, parent_s, parent_t, parent_c in cur.fetchall():
        child_key = f"{child_s}.{child_t}"
        parent_key = f"{parent_s}.{parent_t}"
        fk_map[child_key].append((child_c, parent_s, parent_t, parent_c))
        if child_key in table_set and parent_key in table_set:
            deps[child_key].add(parent_key)
    return fk_map, deps


def build_snowflake_fk_map(cur, schema, tables):
    table_set = {t for t in tables}
    cur.execute(
        f"""
        SELECT
            child_kcu.TABLE_NAME AS child_table,
            child_kcu.COLUMN_NAME AS child_column,
            parent_kcu.TABLE_SCHEMA AS parent_schema,
            parent_kcu.TABLE_NAME AS parent_table,
            parent_kcu.COLUMN_NAME AS parent_column
        FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE child_kcu
          ON child_kcu.CONSTRAINT_NAME = rc.CONSTRAINT_NAME
         AND child_kcu.CONSTRAINT_SCHEMA = rc.CONSTRAINT_SCHEMA
        JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE parent_kcu
          ON parent_kcu.CONSTRAINT_NAME = rc.UNIQUE_CONSTRAINT_NAME
         AND parent_kcu.CONSTRAINT_SCHEMA = rc.UNIQUE_CONSTRAINT_SCHEMA
         AND parent_kcu.ORDINAL_POSITION = child_kcu.ORDINAL_POSITION
        WHERE child_kcu.TABLE_SCHEMA = '{schema}'
        """
    )
    fk_map = defaultdict(list)
    deps = defaultdict(set)
    for child_t, child_c, parent_s, parent_t, parent_c in cur.fetchall():
        fk_map[child_t].append((child_c, parent_s, parent_t, parent_c))
        if child_t in table_set and parent_t in table_set and parent_s == schema:
            deps[child_t].add(parent_t)
    return fk_map, deps


# ─── PLATFORM FIXERS ────────────────────────────────────────────────────────

def fix_sqlserver():
    import pyodbc
    logger.info("\n=== Fixing SQL Server ===")
    conn = pyodbc.connect("DRIVER={ODBC Driver 17 for SQL Server};SERVER=localhost;Trusted_Connection=yes;", autocommit=True)
    cur = conn.cursor()

    cur.execute("SELECT name FROM sys.databases WHERE name LIKE 'Masreph_%'")
    dbs = [r[0] for r in cur.fetchall()]
    fixed = 0

    for db in dbs:
        cur.execute(f"USE [{db}]")
        cur.execute("""
            SELECT s.name AS schema_name, t.name AS table_name
            FROM sys.tables t
            JOIN sys.schemas s ON t.schema_id = s.schema_id
            LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
            GROUP BY s.name, t.name HAVING ISNULL(SUM(p.rows),0) = 0
        """)
        empty_tables = [(r[0], r[1]) for r in cur.fetchall()]
        if not empty_tables:
            continue

        table_keys = [f"{s}.{t}" for s, t in empty_tables]
        fk_map, deps = build_sqlserver_fk_map(cur, table_keys)
        ordered_keys = topological_sort(table_keys, deps)

        for table_key in ordered_keys:
            schema_name, table = table_key.split(".", 1)
            cols_meta = find_columns("sql-server", table, db.replace("Masreph_", ""))

            cur.execute(
                """
                SELECT c.COLUMN_NAME, c.DATA_TYPE, c.COLUMN_DEFAULT, c.IS_NULLABLE,
                       c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE,
                       COLUMNPROPERTY(OBJECT_ID(QUOTENAME(c.TABLE_SCHEMA)+'.'+QUOTENAME(c.TABLE_NAME)), c.COLUMN_NAME, 'IsIdentity') AS is_identity
                FROM INFORMATION_SCHEMA.COLUMNS c
                WHERE c.TABLE_SCHEMA = ? AND c.TABLE_NAME = ?
                ORDER BY c.ORDINAL_POSITION
                """,
                (schema_name, table),
            )
            live_cols = cur.fetchall()
            if not live_cols:
                continue
            cur.execute(
                """
                SELECT kcu.COLUMN_NAME
                FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
                  ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
                 AND tc.TABLE_SCHEMA = kcu.TABLE_SCHEMA
                 AND tc.TABLE_NAME = kcu.TABLE_NAME
                WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
                  AND tc.TABLE_SCHEMA = ?
                  AND tc.TABLE_NAME = ?
                """,
                (schema_name, table),
            )
            pk_cols = {r[0] for r in cur.fetchall()}

            live_by_name = {}
            for r in live_cols:
                dtype = build_type_string(r[1], r[4], r[5], r[6])
                live_by_name[r[0]] = {
                    "data_type": dtype,
                    "default": r[2] or "",
                    "nullable": str(r[3]).upper() == "YES",
                    "identity": int(r[7] or 0),
                    "is_pk": r[0] in pk_cols,
                }

            # Merge schema metadata with live table metadata. Fall back to live-only columns.
            cols_meta = cols_meta or []
            by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
            for name, meta in live_by_name.items():
                if name in by_name:
                    cc = by_name[name]
                    cc["data_type"] = meta["data_type"]
                    cc["nullable"] = meta["nullable"]
                    cc["is_primary_key"] = bool(cc.get("is_primary_key", False) or meta["is_pk"])
                    by_name[name] = cc
                else:
                    by_name[name] = make_col_meta(name, meta["data_type"], meta["nullable"], meta["is_pk"], name)

            insertable = []
            for name, cc in by_name.items():
                meta = live_by_name.get(name)
                if not meta:
                    continue
                if meta["identity"] == 1:
                    continue
                insertable.append(cc)
            if not insertable:
                continue

            fk_values = {}
            missing_required_fks = []
            nullable_fk_columns = set()
            for child_col, parent_schema, parent_table, parent_col in fk_map.get(table_key, []):
                parent_ref = f"[{parent_schema}].[{parent_table}]"
                values = fetch_distinct_values(cur, parent_ref, parent_col, "sql-server")
                if values:
                    fk_values[child_col.lower()] = values
                else:
                    meta = live_by_name.get(child_col, {})
                    if meta.get("nullable", True):
                        nullable_fk_columns.add(child_col.lower())
                    else:
                        missing_required_fks.append(child_col)

            if missing_required_fks:
                logger.warning(
                    f"    {db}.{schema_name}.{table}: required FK parents missing for {', '.join(missing_required_fks)}; trying best-effort insert"
                )

            table_ref = f"[{schema_name}].[{table}]"
            pk_offsets = {}
            for c in insertable:
                if not c.get("is_primary_key"):
                    continue
                base_type, _, scale = parse_type(c.get("data_type", ""))
                if is_int_type(base_type, scale) or "CHAR" in base_type or base_type == "STRING":
                    pk_offsets[c["name"].lower()] = get_pk_offset(cur, table_ref, c["name"], "sql-server")

            context = {"fk_values": fk_values, "pk_offsets": pk_offsets, "nullable_fk_columns": nullable_fk_columns}
            num_rows = determine_rows(table)
            inserted = 0
            errors_logged = 0
            for i in range(num_rows):
                row = [gen_value_from_metadata(c, "sql-server", i, context) for c in insertable]
                col_list = ", ".join(f"[{c['name']}]" for c in insertable)
                placeholders = ", ".join(["?"] * len(insertable))
                try:
                    cur.execute(f"INSERT INTO [{schema_name}].[{table}] ({col_list}) VALUES ({placeholders})", row)
                    inserted += 1
                except Exception as e:
                    if errors_logged < 1:
                        logger.warning(f"    {db}.{schema_name}.{table}: {str(e)[:180]}")
                        errors_logged += 1

            if inserted > 0:
                fixed += 1
                logger.info(f"  {db}.{schema_name}.{table}: {inserted}/{num_rows} rows")

    conn.close()
    logger.info(f"  SQL Server: {fixed} tables fixed")
    return fixed


def fix_postgresql():
    import psycopg2
    from psycopg2.extras import execute_batch
    logger.info("\n=== Fixing PostgreSQL ===")
    conn = psycopg2.connect(host="aws-1-eu-west-2.pooler.supabase.com", port=5432, database="postgres",
        user="postgres.rlphlmkddecuptbklqeh", password="os.getenv('SUPABASE_CORE_PASSWORD')", connect_timeout=15)
    cur = conn.cursor()

    cur.execute("""
        SELECT schemaname, relname FROM pg_stat_user_tables
        WHERE n_live_tup = 0 AND schemaname NOT IN
        ('pg_catalog','information_schema','auth','storage','realtime','extensions',
        'graphql','graphql_public','pgsodium','pgsodium_masks','vault','supabase_functions',
        '_realtime','supabase_migrations','net','_analytics','public')
    """)
    empty = [(r[0], r[1]) for r in cur.fetchall()]
    logger.info(f"  Found {len(empty)} empty tables")
    fixed = 0

    by_schema = defaultdict(list)
    for schema, table in empty:
        by_schema[schema].append(table)

    for schema, schema_tables in by_schema.items():
        fk_map, deps = build_pg_fk_map(cur, schema, schema_tables)
        ordered_tables = topological_sort(schema_tables, deps)

        for table in ordered_tables:
            cols_meta = find_columns("postgresql", table, schema)

            cur.execute(
                """
                SELECT
                    column_name,
                    data_type,
                    udt_name,
                    column_default,
                    is_nullable,
                    character_maximum_length,
                    numeric_precision,
                    numeric_scale
                FROM information_schema.columns
                WHERE table_schema=%s AND table_name=%s
                ORDER BY ordinal_position
                """,
                (schema, table),
            )
            live_cols = cur.fetchall()
            if not live_cols:
                continue
            live_by_name = {
                r[0]: {
                    "data_type": build_type_string(r[1] if r[1] != "USER-DEFINED" else r[2], r[5], r[6], r[7]),
                    "default": r[3] or "",
                    "nullable": (r[4] or "").upper() == "YES",
                }
                for r in live_cols
            }
            cur.execute(
                """
                SELECT kcu.column_name
                FROM information_schema.table_constraints tc
                JOIN information_schema.key_column_usage kcu
                  ON tc.constraint_name = kcu.constraint_name
                 AND tc.table_schema = kcu.table_schema
                 AND tc.table_name = kcu.table_name
                WHERE tc.constraint_type='PRIMARY KEY'
                  AND tc.table_schema=%s
                  AND tc.table_name=%s
                """,
                (schema, table),
            )
            pk_cols = {r[0] for r in cur.fetchall()}

            # Never insert DB-generated identity/serial columns.
            cols_meta = cols_meta or []
            by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
            for name, meta in live_by_name.items():
                if name in by_name:
                    cc = by_name[name]
                    cc["data_type"] = meta["data_type"]
                    cc["nullable"] = meta["nullable"]
                    cc["is_primary_key"] = bool(cc.get("is_primary_key", False) or name in pk_cols)
                    by_name[name] = cc
                else:
                    by_name[name] = make_col_meta(name, meta["data_type"], meta["nullable"], name in pk_cols, name)

            insertable = []
            for name, c in by_name.items():
                if name not in live_by_name:
                    continue
                default_expr = (live_by_name[name]["default"] or "").lower()
                is_generated = "nextval(" in default_expr or "generated" in default_expr
                if is_generated:
                    continue
                insertable.append(c)

            if not insertable:
                continue

            fk_values = {}
            missing_required_fks = []
            nullable_fk_columns = set()
            for child_col, parent_schema, parent_table, parent_col in fk_map.get(table, []):
                parent_ref = f"{parent_schema}.{parent_table}"
                values = fetch_distinct_values(cur, parent_ref, parent_col, "snowflake")
                if values:
                    fk_values[child_col.lower()] = values
                else:
                    meta = live_by_name.get(child_col, {})
                    if not meta.get("nullable", True):
                        missing_required_fks.append(child_col)
                    else:
                        nullable_fk_columns.add(child_col.lower())

            if missing_required_fks:
                logger.warning(f"    {schema}.{table}: skipping, required FK parents missing for {', '.join(missing_required_fks)}")
                continue

            table_ref = f"{schema}.{table}"
            pk_offsets = {}
            for c in insertable:
                if not c.get("is_primary_key"):
                    continue
                base_type, _, scale = parse_type(c.get("data_type", ""))
                if is_int_type(base_type, scale) or "CHAR" in base_type or base_type == "STRING":
                    pk_offsets[c["name"].lower()] = get_pk_offset(cur, table_ref, c["name"], "postgresql")

            context = {"fk_values": fk_values, "pk_offsets": pk_offsets, "nullable_fk_columns": nullable_fk_columns}
            num_rows = determine_rows(table)
            col_list = ", ".join(f'"{c["name"]}"' for c in insertable)
            placeholders = ", ".join(["%s"] * len(insertable))
            sql = f'INSERT INTO "{schema}"."{table}" ({col_list}) VALUES ({placeholders})'
            rows = [tuple(gen_value_from_metadata(c, "postgresql", i, context) for c in insertable) for i in range(num_rows)]

            inserted = 0
            try:
                execute_batch(cur, sql, rows, page_size=200)
                conn.commit()
                inserted = len(rows)
            except Exception as e:
                conn.rollback()
                errors_logged = 0
                for row in rows:
                    try:
                        cur.execute(sql, row)
                        conn.commit()
                        inserted += 1
                    except Exception as e_row:
                        try:
                            conn.rollback()
                        except Exception:
                            logger.warning(f"    {schema}.{table}: connection dropped during rollback; stopping PostgreSQL pass")
                            conn.close()
                            return fixed
                        if errors_logged < 1:
                            logger.warning(f"    {schema}.{table}: {str(e_row)[:120]}")
                            errors_logged += 1

            if inserted > 0:
                fixed += 1
                logger.info(f"  {schema}.{table}: {inserted}/{num_rows} rows")

    conn.close()
    logger.info(f"  PostgreSQL: {fixed} tables fixed")
    return fixed


def fix_mysql():
    import mysql.connector
    logger.info("\n=== Fixing MySQL ===")
    conn = mysql.connector.connect(host="localhost", port=3306, user="root", password="os.getenv('MYSQL_PASSWORD')")
    cur = conn.cursor()

    cur.execute("SELECT SCHEMA_NAME FROM information_schema.schemata WHERE SCHEMA_NAME LIKE 'masreph_%'")
    dbs = [r[0] for r in cur.fetchall()]
    empty = []
    for db in dbs:
        cur.execute(
            "SELECT TABLE_NAME FROM information_schema.tables WHERE TABLE_SCHEMA=%s AND TABLE_TYPE='BASE TABLE'",
            (db,),
        )
        tables = [r[0] for r in cur.fetchall()]
        for table in tables:
            try:
                cur.execute(f"SELECT COUNT(*) FROM `{db}`.`{table}`")
                if int(cur.fetchone()[0]) == 0:
                    empty.append((db, table))
            except Exception:
                continue
    logger.info(f"  Found {len(empty)} empty tables")
    fixed = 0

    by_db = defaultdict(list)
    for db, table in empty:
        by_db[db].append(table)

    for db, db_tables in by_db.items():
        cur.execute(f"USE `{db}`")
        fk_map, deps = build_mysql_fk_map(cur, db, db_tables)
        ordered_tables = topological_sort(db_tables, deps)

        for table in ordered_tables:
            cols_meta = find_columns("mysql", table, db.replace("masreph_", ""))

            cur.execute(
                """
                SELECT column_name, data_type, column_type, column_key, extra, is_nullable,
                       character_maximum_length, numeric_precision, numeric_scale
                FROM information_schema.columns
                WHERE table_schema=%s AND table_name=%s
                ORDER BY ordinal_position
                """,
                (db, table),
            )
            live_cols = cur.fetchall()
            if not live_cols:
                continue
            live_by_name = {
                r[0]: {
                    "data_type": build_type_string((r[2] or r[1] or ""), r[6], r[7], r[8]),
                    "column_key": (r[3] or ""),
                    "extra": (r[4] or ""),
                    "nullable": (r[5] or "").upper() == "YES",
                    "is_pk": (r[3] or "").upper() == "PRI",
                }
                for r in live_cols
            }

            # Skip auto-generated columns only (AUTO_INCREMENT).
            cols_meta = cols_meta or []
            by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
            for name, meta in live_by_name.items():
                if name in by_name:
                    cc = by_name[name]
                    cc["data_type"] = meta["data_type"]
                    cc["nullable"] = meta["nullable"]
                    cc["is_primary_key"] = bool(cc.get("is_primary_key", False) or meta["is_pk"])
                    by_name[name] = cc
                else:
                    by_name[name] = make_col_meta(name, meta["data_type"], meta["nullable"], meta["is_pk"], name)

            insertable = []
            for name, c in by_name.items():
                meta = live_by_name.get(name)
                if not meta:
                    continue
                if "auto_increment" in meta.get("extra", "").lower():
                    continue
                insertable.append(c)
            if not insertable:
                continue

            fk_values = {}
            for child_col, parent_schema, parent_table, parent_col in fk_map.get(table, []):
                parent_ref = f"`{parent_schema}`.`{parent_table}`"
                values = fetch_distinct_values(cur, parent_ref, parent_col, "mysql")
                if values:
                    fk_values[child_col.lower()] = values

            table_ref = f"`{table}`"
            pk_offsets = {}
            for c in insertable:
                if not c.get("is_primary_key"):
                    continue
                base_type, _, scale = parse_type(c.get("data_type", ""))
                if is_int_type(base_type, scale) or "CHAR" in base_type or base_type == "STRING":
                    pk_offsets[c["name"].lower()] = get_pk_offset(cur, table_ref, c["name"], "mysql")

            context = {"fk_values": fk_values, "pk_offsets": pk_offsets}
            num_rows = determine_rows(table)
            col_list = ", ".join(f"`{c['name']}`" for c in insertable)
            placeholders = ", ".join(["%s"] * len(insertable))
            sql = f"INSERT INTO `{table}` ({col_list}) VALUES ({placeholders})"
            rows = [tuple(gen_value_from_metadata(c, "mysql", i, context) for c in insertable) for i in range(num_rows)]

            try:
                cur.executemany(sql, rows)
                conn.commit()
                fixed += 1
                logger.info(f"  {db}.{table}: {len(rows)} rows")
            except Exception as e:
                conn.rollback()
                inserted = 0
                errors_logged = 0
                for row in rows:
                    try:
                        cur.execute(sql, row)
                        conn.commit()
                        inserted += 1
                    except Exception as e_row:
                        conn.rollback()
                        if errors_logged < 1:
                            logger.warning(f"    {db}.{table}: {str(e_row)[:120]}")
                            errors_logged += 1
                if inserted > 0:
                    fixed += 1
                    logger.info(f"  {db}.{table}: {inserted} rows (partial)")

    conn.close()
    logger.info(f"  MySQL: {fixed} tables fixed")
    return fixed


def fix_snowflake():
    import snowflake.connector
    logger.info("\n=== Fixing Snowflake ===")

    v2_schemas = set()
    for f in os.listdir(os.path.join(BASE_DIR, "schemas_v2", "snowflake")):
        if f.endswith(".sql"): v2_schemas.add(f.replace(".sql", "").upper())

    conn = snowflake.connector.connect(account="ittrelv-xu20591", user="hzmarrou",
        password="os.getenv('SNOWFLAKE_PASSWORD')", warehouse="COMPUTE_WH", database="MASREPH_RISK_ANALYTICS")
    cur = conn.cursor()
    fixed = 0

    for schema in sorted(v2_schemas):
        cur.execute(f"SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='{schema}' AND TABLE_TYPE='BASE TABLE'")
        tables = [r[0] for r in cur.fetchall()]
        try:
            fk_map, deps = build_snowflake_fk_map(cur, schema, tables)
            ordered_tables = topological_sort(tables, deps)
        except Exception as e:
            logger.warning(f"    {schema}: FK metadata unavailable, using natural order ({str(e)[:120]})")
            fk_map, ordered_tables = defaultdict(list), tables

        for table in ordered_tables:
            cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
            if cur.fetchone()[0] > 0: continue

            cols_meta = find_columns("snowflake", table, schema)
            cur.execute(
                f"""
                SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE, IS_NULLABLE, COLUMN_DEFAULT
                FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA='{schema}' AND TABLE_NAME='{table}'
                ORDER BY ORDINAL_POSITION
                """
            )
            live_cols = cur.fetchall()
            if not live_cols:
                continue
            live_by_name = {
                r[0]: {
                    "data_type": build_type_string(r[1], r[2], r[3], r[4]),
                    "nullable": str(r[5]).upper() == "YES",
                    "default": r[6] or "",
                }
                for r in live_cols
            }

            cols_meta = cols_meta or []
            by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
            for name, meta in live_by_name.items():
                if name in by_name:
                    cc = by_name[name]
                    cc["data_type"] = meta["data_type"]
                    cc["nullable"] = meta["nullable"]
                    by_name[name] = cc
                else:
                    by_name[name] = make_col_meta(name, meta["data_type"], meta["nullable"], False, name)

            insertable = []
            for name, c in by_name.items():
                meta = live_by_name.get(name)
                if not meta:
                    continue
                default_expr = (meta["default"] or "").upper()
                if "AUTOINCREMENT" in default_expr or "IDENTITY" in default_expr:
                    continue
                insertable.append(c)
            if not insertable:
                continue

            fk_values = {}
            missing_required_fks = []
            nullable_fk_columns = set()
            for child_col, parent_schema, parent_table, parent_col in fk_map.get(table, []):
                parent_ref = f"{parent_schema}.{parent_table}"
                values = fetch_distinct_values(cur, parent_ref, parent_col, "postgresql")
                if values:
                    fk_values[child_col.lower()] = values
                else:
                    meta = live_by_name.get(child_col, {})
                    if meta.get("nullable", True):
                        nullable_fk_columns.add(child_col.lower())
                    else:
                        missing_required_fks.append(child_col)
            if missing_required_fks:
                logger.warning(
                    f"    {schema}.{table}: required FK parents missing for {', '.join(missing_required_fks)}; trying best-effort insert"
                )

            context = {"fk_values": fk_values, "nullable_fk_columns": nullable_fk_columns}
            num_rows = determine_rows(table)
            semi_cols = [is_semi_structured_type(c.get("data_type", "")) for c in insertable]
            rows = []
            for i in range(num_rows):
                row = []
                for c, is_semi in zip(insertable, semi_cols):
                    val = gen_value_from_metadata(c, "snowflake", i, context)
                    if is_semi:
                        row.append(to_json_text_for_snowflake(val))
                    else:
                        row.append(val)
                rows.append(tuple(row))
            col_list = ", ".join(f'"{c["name"]}"' for c in insertable)
            value_expr = ", ".join(["PARSE_JSON(%s)" if is_semi else "%s" for is_semi in semi_cols])
            sql = f"INSERT INTO {schema}.{table} ({col_list}) SELECT {value_expr}"

            try:
                cur.executemany(sql, rows)
                fixed += 1
                logger.info(f"  {schema}.{table}: {len(rows)} rows")
            except Exception as e:
                inserted = 0
                errors_logged = 0
                for row in rows:
                    try:
                        cur.execute(sql, row)
                        inserted += 1
                    except Exception as e_row:
                        if errors_logged < 1:
                            logger.warning(f"    {schema}.{table}: {str(e_row)[:180]}")
                            errors_logged += 1
                if inserted > 0:
                    fixed += 1
                    logger.info(f"  {schema}.{table}: {inserted} rows (partial)")

    conn.close()
    logger.info(f"  Snowflake: {fixed} tables fixed")
    return fixed


def fix_databricks():
    from databricks import sql as dbx_sql
    for name in [
        "databricks",
        "databricks.sql",
        "databricks.sql.client",
        "databricks.sql.thrift_backend",
        "urllib3",
        "thrift",
        "pyhive",
    ]:
        logging.getLogger(name).setLevel(logging.WARNING)
    logger.info("\n=== Fixing Databricks ===")
    conn = dbx_sql.connect(server_hostname="adb-7405617014831513.13.azuredatabricks.net",
        http_path="/sql/1.0/warehouses/b3bee97b5042372c",
        access_token="os.getenv('DATABRICKS_TOKEN')",
        use_cloud_fetch=False)
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

            cols_meta = find_columns("databricks", table, schema)
            try:
                cur.execute(f"DESCRIBE TABLE masreph_datalake.{schema}.{table}")
                desc_rows = cur.fetchall()
            except Exception:
                continue

            live_cols = []
            for r in desc_rows:
                col_name = str(r[0] or "").strip()
                col_type = str(r[1] or "").strip()
                if not col_name or col_name.startswith("#"):
                    continue
                live_cols.append((col_name, col_type))
            if not live_cols:
                continue

            cols_meta = cols_meta or []
            by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
            for col_name, col_type in live_cols:
                dtype = build_type_string(col_type)
                if col_name in by_name:
                    cc = by_name[col_name]
                    cc["data_type"] = dtype
                    by_name[col_name] = cc
                else:
                    by_name[col_name] = make_col_meta(col_name, dtype, True, False, col_name)
            insertable = [by_name[c] for c, _ in live_cols if c in by_name]
            if not insertable:
                continue

            num_rows = determine_rows(table)
            batch_size = 50
            inserted = 0
            col_list = ", ".join(f"`{c['name']}`" for c in insertable)
            errors_logged = 0

            for bs in range(0, num_rows, batch_size):
                be = min(bs + batch_size, num_rows)
                values_list = []
                for i in range(bs, be):
                    parts = []
                    for c in insertable:
                        val = gen_value_from_metadata(c, "databricks", i)
                        ctype = (c.get("data_type") or "").strip()
                        ctlow = ctype.lower()
                        if ctlow.startswith("map<") or ctlow.startswith("array<") or ctlow.startswith("struct<"):
                            parts.append(databricks_default_literal(ctype))
                            continue
                        if val is None: parts.append("NULL")
                        elif isinstance(val, bool): parts.append("true" if val else "false")
                        elif isinstance(val, (int, float)): parts.append(str(val))
                        elif isinstance(val, (datetime, date)): parts.append(f"'{val}'")
                        elif isinstance(val, bytes): parts.append(f"X'{val.hex()}'")
                        else: parts.append(f"'{str(val).replace(chr(39), chr(39)+chr(39))}'")
                    values_list.append(f"({','.join(parts)})")

                try:
                    cur.execute(f"INSERT INTO masreph_datalake.{schema}.{table} ({col_list}) VALUES {','.join(values_list)}")
                    inserted += be - bs
                except Exception as e:
                    for vals in values_list:
                        try:
                            cur.execute(f"INSERT INTO masreph_datalake.{schema}.{table} ({col_list}) VALUES {vals}")
                            inserted += 1
                        except Exception as e_row:
                            if errors_logged < 1:
                                logger.warning(f"    {schema}.{table}: {str(e_row)[:180]}")
                                errors_logged += 1

            if inserted > 0:
                fixed += 1
                logger.info(f"  {schema}.{table}: {inserted} rows")

    conn.close()
    logger.info(f"  Databricks: {fixed} tables fixed")
    return fixed


def fix_fabric():
    import pyodbc, struct
    from azure.identity import ClientSecretCredential
    logging.getLogger("azure").setLevel(logging.WARNING)
    logging.getLogger("azure.identity").setLevel(logging.WARNING)
    logging.getLogger("azure.core.pipeline.policies.http_logging_policy").setLevel(logging.WARNING)
    logger.info("\n=== Fixing Fabric ===")

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

    cur.execute("SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA NOT IN ('dbo','sys','INFORMATION_SCHEMA') AND TABLE_TYPE='BASE TABLE'")
    all_tables = cur.fetchall()

    for schema, table in all_tables:
        try:
            cur.execute(f"SELECT COUNT(*) FROM [{schema}].[{table}]")
            if cur.fetchone()[0] > 0: continue
        except: continue

        cols_meta = find_columns("fabric", table, schema)
        cur.execute(
            """
            SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH, NUMERIC_PRECISION, NUMERIC_SCALE,
                   COLUMNPROPERTY(OBJECT_ID(QUOTENAME(TABLE_SCHEMA)+'.'+QUOTENAME(TABLE_NAME)), COLUMN_NAME, 'IsIdentity') AS is_identity
            FROM INFORMATION_SCHEMA.COLUMNS
            WHERE TABLE_SCHEMA=? AND TABLE_NAME=?
            ORDER BY ORDINAL_POSITION
            """,
            (schema, table),
        )
        live_cols = cur.fetchall()
        if not live_cols:
            continue
        live_by_name = {
            r[0]: {
                "data_type": build_type_string(r[1], r[3], r[4], r[5]),
                "nullable": str(r[2]).upper() == "YES",
                "identity": int(r[6] or 0),
            }
            for r in live_cols
        }
        cols_meta = cols_meta or []
        by_name = {c["name"]: dict(c) for c in cols_meta if c.get("name")}
        for name, meta in live_by_name.items():
            if name in by_name:
                cc = by_name[name]
                cc["data_type"] = meta["data_type"]
                cc["nullable"] = meta["nullable"]
                by_name[name] = cc
            else:
                by_name[name] = make_col_meta(name, meta["data_type"], meta["nullable"], False, name)

        insertable = []
        for name, c in by_name.items():
            meta = live_by_name.get(name)
            if not meta:
                continue
            if meta.get("identity") == 1:
                continue
            insertable.append(c)
        if not insertable:
            continue

        num_rows = determine_rows(table)
        col_list = ", ".join(f"[{c['name']}]" for c in insertable)
        placeholders = ", ".join(["?"] * len(insertable))
        sql = f"INSERT INTO [{schema}].[{table}] ({col_list}) VALUES ({placeholders})"

        rows = [tuple(gen_value_from_metadata(c, "fabric", i) for c in insertable) for i in range(num_rows)]
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


def main():
    logger.info("=== Fix Empty Tables V3 (schema_results metadata) ===")
    logger.info(f"Table index has {len(TABLE_INDEX)} entries")

    results = {}
    fixers = [
        ("sql-server", fix_sqlserver),
        ("mysql", fix_mysql),
        ("postgresql", fix_postgresql),
        ("snowflake", fix_snowflake),
        ("databricks", fix_databricks),
        ("fabric", fix_fabric),
    ]
    selected = {x.strip().lower() for x in sys.argv[1:] if x.strip()}
    if selected:
        fixers = [(name, fn) for name, fn in fixers if name in selected]
        logger.info(f"Running selected fixers only: {', '.join(name for name, _ in fixers)}")

    for name, fn in fixers:
        try:
            results[name] = fn()
        except Exception as e:
            logger.error(f"  {name}: fixer failed: {str(e)[:180]}")
            results[name] = 0

    logger.info("\n=== FIX V3 COMPLETE ===")
    total = 0
    for platform, count in results.items():
        logger.info(f"  {platform:15s}: {count} tables fixed")
        total += count
    logger.info(f"  {'TOTAL':15s}: {total} tables fixed")


if __name__ == "__main__":
    main()
