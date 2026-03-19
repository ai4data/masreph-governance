#!/usr/bin/env python3
"""
Generate DDL schemas for the 328 selected datasets only.

Platform strategies:
- SQL Server, PostgreSQL, MySQL, Oracle: normal splitting (normalize entities)
- Snowflake, Databricks, Fabric: BRONZE ONLY (wide tables, minimal splitting)
- MongoDB: document embedding (no splitting)

Output: schemas_v2/{platform}/{source_system}.sql (or .json for MongoDB)
"""

import os
import json
import asyncio
import logging
import re
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
from openai import AsyncAzureOpenAI
from tqdm import tqdm

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

LOG_DIR = os.path.join(os.path.dirname(__file__), "..", "logs")
os.makedirs(LOG_DIR, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(LOG_DIR, "schema_generation_v2.log"), mode="w"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger(__name__)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("openai").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)

AZURE_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_API_KEY = os.getenv("AZURE_OPENAI_API_KEY")
AZURE_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2025-01-01-preview")
AZURE_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-5.1")

MAX_CONCURRENT = 10
MAX_RETRIES = 2

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")
CONFIG_DIR = os.path.join(BASE_DIR, "config")
SCHEMAS_DIR = os.path.join(BASE_DIR, "schemas_v2")
ENHANCED_DATA_DIR = "C:/Users/Hicham/OneDrive/python/learning/dm-db/enhanced-data"

with open(os.path.join(CONFIG_DIR, "selected_datasets.json"), "r") as f:
    SELECTED = json.load(f)
    SELECTED_IDS = {d["id"] for d in SELECTED["datasets"]}
    SELECTED_MAP = {d["id"]: d for d in SELECTED["datasets"]}

with open(os.path.join(CONFIG_DIR, "type_mapping.json"), "r") as f:
    TYPE_MAPPINGS = json.load(f)

with open(os.path.join(CONFIG_DIR, "naming_conventions.json"), "r") as f:
    NAMING_CONVENTIONS = json.load(f)

# ─── SPLITTING STRATEGIES ────────────────────────────────────────────────────

STRATEGIES = {
    "sql-server": {
        "min_elements_to_split": 12,
        "is_bronze": False,
        "prompt_extra": (
            "This is a legacy SQL Server enterprise system (15+ years old). "
            "Apply moderate normalization - split into entities when clear boundaries exist. "
            "Include audit columns (CreatedDate, ModifiedDate) on main tables. "
            "Use PascalCase for all identifiers."
        ),
    },
    "postgresql": {
        "min_elements_to_split": 10,
        "is_bronze": False,
        "prompt_extra": (
            "This is a modern PostgreSQL application database. "
            "Apply thorough normalization (3NF). Extract distinct entities. "
            "Use snake_case for all identifiers. Add created_at and updated_at columns."
        ),
    },
    "mysql": {
        "min_elements_to_split": 10,
        "is_bronze": False,
        "prompt_extra": (
            "This is a web/digital MySQL database. Clean normalization. "
            "Use snake_case. Add created_at column."
        ),
    },
    "oracle": {
        "min_elements_to_split": 12,
        "is_bronze": False,
        "prompt_extra": (
            "This is a legacy Oracle ERP (20+ years old). "
            "Abbreviated UPPERCASE names (max 30 chars). "
            "MSTR=Master, DTL=Detail, TXN=Transaction, CUST=Customer, ACCT=Account, "
            "AMT=Amount, DT=Date, CD=Code, NM=Name, STAT=Status. "
            "Include SYS_CR_DT and SYS_UPD_DT audit columns."
        ),
    },
    "snowflake": {
        "min_elements_to_split": 999,  # No splitting - bronze/raw
        "is_bronze": True,
        "prompt_extra": (
            "This is a Snowflake RAW/BRONZE landing zone. "
            "DO NOT split into multiple tables. Keep ONE wide table per dataset. "
            "Use UPPERCASE_SNAKE_CASE for all identifiers. "
            "Add _LOADED_AT TIMESTAMP_NTZ and _SOURCE_SYSTEM VARCHAR(255) metadata columns. "
            "This is raw data as received from source systems."
        ),
    },
    "databricks": {
        "min_elements_to_split": 999,  # No splitting - bronze
        "is_bronze": True,
        "prompt_extra": (
            "This is a Databricks BRONZE landing zone (raw data lake). "
            "DO NOT split into multiple tables. Keep ONE wide table per dataset. "
            "Use snake_case for all identifiers. "
            "Add _loaded_at TIMESTAMP and _source_file STRING metadata columns. "
            "This is raw ingested data with minimal transformation."
        ),
    },
    "fabric": {
        "min_elements_to_split": 999,  # No splitting - bronze
        "is_bronze": True,
        "prompt_extra": (
            "This is a Microsoft Fabric BRONZE landing zone (raw corporate data). "
            "DO NOT split into multiple tables. Keep ONE wide table per dataset. "
            "Use PascalCase for all identifiers. "
            "Add LoadedAt DATETIME2 and SourceSystem VARCHAR(255) metadata columns. "
            "This is raw data landing for corporate BI."
        ),
    },
    "mongodb": {
        "min_elements_to_split": 999,  # No splitting - embed
        "is_bronze": False,
        "prompt_extra": (
            "This is a MongoDB document store. "
            "Design a SINGLE document with nested objects and arrays. "
            "Use camelCase. Include _id. Embed related data."
        ),
    },
}

# ─── PROMPT BUILDER ──────────────────────────────────────────────────────────

def build_prompt(dataset, data_elements, platform):
    strategy = STRATEGIES[platform]
    naming = NAMING_CONVENTIONS[platform]
    type_map = TYPE_MAPPINGS[platform]

    elements_desc = []
    for elem in data_elements:
        sample = elem.get("sampleValues", [])
        sample_str = ", ".join(str(s) for s in sample[:3]) if sample else "N/A"
        elements_desc.append(
            f"  - {elem['name']} ({elem.get('dataType', 'string')}, "
            f"format: {elem.get('format', 'N/A')}, "
            f"nullable: {elem.get('nullable', False)}): "
            f"{elem.get('description', '')} "
            f"[samples: {sample_str}]"
        )

    available_types = "\n".join(f"  - {g} -> {n}" for g, n in type_map.items() if g != "format_overrides")

    prompt = f"""You are a senior database architect designing schemas for a real enterprise system.

DATASET: {dataset.get('name', 'Unknown')}
Description: {dataset.get('description', '')[:300]}
Domain: {dataset.get('dataDomain', 'Unknown')}
Sub-domain: {dataset.get('dataSubDomain', 'Unknown')}
Source System: {dataset.get('sourceSysName', 'Unknown')}

DATA ELEMENTS ({len(data_elements)}):
{chr(10).join(elements_desc)}

PLATFORM: {platform.upper()}
{strategy['prompt_extra']}

NAMING: {naming['table_style']}, columns: {naming['column_style']}
Example: {naming.get('example_schema','')}.{naming.get('example_table','')}

DATA TYPES:
{available_types}

Return JSON:
{{
  "schema_name": "schema name following platform conventions",
  "tables": [
    {{
      "name": "table_name",
      "description": "what this table represents",
      "columns": [
        {{
          "name": "column_name",
          "original_element": "original element name or null if generated",
          "data_type": "platform native type",
          "nullable": false,
          "is_primary_key": true
        }}
      ]
    }}
  ],
  "relationships": []
}}

RULES:
- Every original data element MUST appear in exactly one table
- Each table must have a primary key
- Use platform-native data types
- Schema name from source system name
- Return ONLY valid JSON"""

    return prompt


def build_simple_schema(dataset, data_elements, platform):
    """Build a simple 1:1 schema (for bronze / no-split platforms)."""
    naming = NAMING_CONVENTIONS[platform]
    type_map = TYPE_MAPPINGS[platform]

    source_sys = dataset.get("sourceSysName") or "unknown"
    ds_name = dataset.get("name") or "unknown"

    # Convert names to platform convention
    if platform == "snowflake":
        schema_name = re.sub(r'[^A-Z0-9_]', '_', source_sys.upper().replace(" ", "_").replace("-", "_"))
        table_name = re.sub(r'[^A-Z0-9_]', '_', ds_name.upper().replace(" ", "_"))
    elif platform == "databricks":
        schema_name = re.sub(r'[^a-z0-9_]', '_', source_sys.lower().replace(" ", "_").replace("-", "_"))
        table_name = re.sub(r'[^a-z0-9_]', '_', ds_name.lower().replace(" ", "_"))
    elif platform == "fabric":
        schema_name = re.sub(r'[^a-zA-Z0-9]', '', source_sys.replace(" ", ""))
        table_name = re.sub(r'[^a-zA-Z0-9]', '', ds_name.replace(" ", ""))
    elif platform == "oracle":
        schema_name = re.sub(r'[^A-Z0-9_]', '_', source_sys.upper().replace(" ", "_"))[:30]
        table_name = re.sub(r'[^A-Z0-9_]', '_', ds_name.upper().replace(" ", "_"))[:30]
    elif platform == "mongodb":
        schema_name = re.sub(r'[^a-zA-Z0-9]', '', source_sys).lower()
        table_name = re.sub(r'[^a-zA-Z0-9]', '', ds_name)
        table_name = table_name[0].lower() + table_name[1:] if table_name else "collection"
    elif platform == "sql-server":
        schema_name = re.sub(r'[^a-zA-Z0-9]', '', source_sys)
        table_name = re.sub(r'[^a-zA-Z0-9]', '', ds_name)
    else:  # postgresql, mysql
        schema_name = re.sub(r'[^a-z0-9_]', '_', source_sys.lower().replace(" ", "_").replace("-", "_"))
        table_name = re.sub(r'[^a-z0-9_]', '_', ds_name.lower().replace(" ", "_"))

    # Build columns
    columns = []
    # PK
    if platform == "mongodb":
        pass  # MongoDB uses _id automatically
    elif platform == "oracle":
        columns.append({"name": "ID", "original_element": None, "data_type": type_map.get("integer", "NUMBER(18,0)"), "nullable": False, "is_primary_key": True})
    elif platform == "snowflake":
        columns.append({"name": "ID", "original_element": None, "data_type": type_map.get("integer", "NUMBER(18,0)"), "nullable": False, "is_primary_key": True})
    elif platform == "fabric":
        columns.append({"name": "Id", "original_element": None, "data_type": "INT", "nullable": False, "is_primary_key": True})
    elif platform == "sql-server":
        columns.append({"name": "Id", "original_element": None, "data_type": "INT", "nullable": False, "is_primary_key": True})
    else:
        columns.append({"name": "id", "original_element": None, "data_type": type_map.get("integer", "INTEGER"), "nullable": False, "is_primary_key": True})

    # Map data elements
    for elem in data_elements:
        col_name = elem["name"]
        # Apply naming convention
        if platform == "snowflake":
            col_name = re.sub(r'[^A-Z0-9_]', '_', col_name.upper())
        elif platform == "oracle":
            # Abbreviate for Oracle
            col_name = col_name.upper()[:30]
        elif platform == "fabric" or platform == "sql-server":
            # PascalCase
            parts = re.split(r'[_\s-]+', col_name)
            col_name = ''.join(w.capitalize() for w in parts)
        elif platform == "mongodb":
            # camelCase
            parts = re.split(r'[_\s-]+', col_name)
            col_name = parts[0].lower() + ''.join(w.capitalize() for w in parts[1:])
        # postgresql, mysql, databricks: keep snake_case as-is

        data_type = resolve_type(elem.get("dataType", "string"), elem.get("format"), type_map)

        columns.append({
            "name": col_name,
            "original_element": elem["name"],
            "data_type": data_type,
            "nullable": elem.get("nullable", False),
            "is_primary_key": False,
        })

    # Add metadata columns for bronze platforms
    strategy = STRATEGIES[platform]
    if strategy["is_bronze"]:
        if platform == "snowflake":
            columns.append({"name": "_LOADED_AT", "original_element": None, "data_type": "TIMESTAMP_NTZ", "nullable": True, "is_primary_key": False})
            columns.append({"name": "_SOURCE_SYSTEM", "original_element": None, "data_type": "VARCHAR(255)", "nullable": True, "is_primary_key": False})
        elif platform == "databricks":
            columns.append({"name": "_loaded_at", "original_element": None, "data_type": "TIMESTAMP", "nullable": True, "is_primary_key": False})
            columns.append({"name": "_source_file", "original_element": None, "data_type": "STRING", "nullable": True, "is_primary_key": False})
        elif platform == "fabric":
            columns.append({"name": "LoadedAt", "original_element": None, "data_type": "DATETIME2", "nullable": True, "is_primary_key": False})
            columns.append({"name": "SourceSystem", "original_element": None, "data_type": "VARCHAR(255)", "nullable": True, "is_primary_key": False})
    else:
        # Audit columns for non-bronze
        if platform == "sql-server":
            columns.append({"name": "CreatedDate", "original_element": None, "data_type": "DATETIME2", "nullable": True, "is_primary_key": False})
            columns.append({"name": "ModifiedDate", "original_element": None, "data_type": "DATETIME2", "nullable": True, "is_primary_key": False})
        elif platform == "postgresql":
            columns.append({"name": "created_at", "original_element": None, "data_type": "TIMESTAMPTZ", "nullable": True, "is_primary_key": False})
            columns.append({"name": "updated_at", "original_element": None, "data_type": "TIMESTAMPTZ", "nullable": True, "is_primary_key": False})
        elif platform == "mysql":
            columns.append({"name": "created_at", "original_element": None, "data_type": "DATETIME", "nullable": True, "is_primary_key": False})
        elif platform == "oracle":
            columns.append({"name": "SYS_CR_DT", "original_element": None, "data_type": "TIMESTAMP", "nullable": True, "is_primary_key": False})
            columns.append({"name": "SYS_UPD_DT", "original_element": None, "data_type": "TIMESTAMP", "nullable": True, "is_primary_key": False})

    return {
        "schema_name": schema_name,
        "tables": [{
            "name": table_name,
            "description": dataset.get("description", "")[:200],
            "columns": columns,
        }],
        "relationships": [],
    }


def resolve_type(generic_type, format_hint, type_map):
    format_overrides = type_map.get("format_overrides", {})
    if format_hint:
        fmt_lower = format_hint.lower().strip()
        for key, native_type in format_overrides.items():
            if key in fmt_lower:
                return native_type
        decimal_match = re.match(r'decimal\((\d+),(\d+)\)', fmt_lower)
        if decimal_match:
            p, s = decimal_match.groups()
            base = type_map.get("decimal", "DECIMAL(18,4)")
            return re.sub(r'\(\d+,\d+\)', f'({p},{s})', base)
    return type_map.get(generic_type, type_map.get("string", "VARCHAR(255)"))


# ─── DDL GENERATORS ─────────────────────────────────────────────────────────

def generate_ddl(schema_result, platform):
    if platform == "mongodb":
        return generate_mongodb_schema(schema_result)

    ddl_lines = []
    schema_name = schema_result.get("schema_name", "dbo")

    # Schema creation
    if platform == "sql-server":
        ddl_lines.append(f"IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema_name}')")
        ddl_lines.append(f"    EXEC('CREATE SCHEMA [{schema_name}]');")
    elif platform in ("postgresql", "snowflake", "databricks"):
        ddl_lines.append(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
    elif platform == "oracle":
        ddl_lines.append(f"-- Schema: {schema_name}")
    ddl_lines.append("")

    for table in schema_result.get("tables", []):
        table_name = table["name"]
        if platform == "sql-server" or platform == "fabric":
            full_name = f"[{schema_name}].[{table_name}]"
        elif platform == "mysql":
            full_name = f"`{table_name}`"
        elif platform == "oracle":
            full_name = f"{schema_name}.{table_name}"
        else:
            full_name = f"{schema_name}.{table_name}"

        ddl_lines.append(f"-- {table.get('description', '')[:100]}")
        if platform in ("sql-server", "oracle", "fabric"):
            ddl_lines.append(f"CREATE TABLE {full_name} (")
        else:
            ddl_lines.append(f"CREATE TABLE IF NOT EXISTS {full_name} (")

        col_defs = []
        pk_cols = []
        for col in table.get("columns", []):
            parts = [f"    {col['name']} {col['data_type']}"]
            if not col.get("nullable", True):
                parts.append("NOT NULL")
            col_defs.append(" ".join(parts))
            if col.get("is_primary_key"):
                pk_cols.append(col["name"])

        ddl_lines.append(",\n".join(col_defs))
        if pk_cols:
            pk_names = ", ".join(pk_cols)
            ddl_lines.append(f"    ,CONSTRAINT PK_{table_name[:20]} PRIMARY KEY ({pk_names})")

        ddl_lines.append(");")
        ddl_lines.append("")

    # FK constraints
    for rel in schema_result.get("relationships", []):
        try:
            from_tbl = rel.get("from_table", rel.get("fromTable", ""))
            to_tbl = rel.get("to_table", rel.get("toTable", ""))
            from_col = rel.get("from_column", rel.get("fromColumn", ""))
            to_col = rel.get("to_column", rel.get("toColumn", ""))
            if not all([from_tbl, to_tbl, from_col, to_col]):
                continue
            if platform == "sql-server" or platform == "fabric":
                from_t = f"[{schema_name}].[{from_tbl}]"
                to_t = f"[{schema_name}].[{to_tbl}]"
            else:
                from_t = f"{schema_name}.{from_tbl}"
                to_t = f"{schema_name}.{to_tbl}"
            fk_name = f"FK_{from_tbl}_{from_col}"[:30]
            ddl_lines.append(f"ALTER TABLE {from_t} ADD CONSTRAINT {fk_name}")
            ddl_lines.append(f"    FOREIGN KEY ({from_col}) REFERENCES {to_t} ({to_col});")
            ddl_lines.append("")
        except Exception:
            continue

    return "\n".join(ddl_lines)


def generate_mongodb_schema(schema_result):
    tables = schema_result.get("tables", [])
    if not tables:
        return "{}"
    table = tables[0]
    properties = {}
    required = []
    for col in table.get("columns", []):
        if col["name"] == "_id":
            continue
        bson_type = col["data_type"]
        if bson_type not in ("string","int","double","bool","date","array","object","objectId"):
            bson_type = "string"
        properties[col["name"]] = {"bsonType": bson_type}
        if not col.get("nullable", True):
            required.append(col["name"])
    return json.dumps({
        "collection": table["name"],
        "database": schema_result.get("schema_name", "masrephApi"),
        "description": table.get("description", ""),
        "validator": {"$jsonSchema": {"bsonType": "object", "required": required, "properties": properties}},
    }, indent=2)


# ─── ASYNC AI SPLITTING ─────────────────────────────────────────────────────

async def split_with_ai(client, semaphore, dataset, data_elements, platform, pbar):
    async with semaphore:
        prompt = build_prompt(dataset, data_elements, platform)
        for attempt in range(MAX_RETRIES + 1):
            try:
                response = await client.chat.completions.create(
                    model=AZURE_DEPLOYMENT,
                    messages=[{"role": "user", "content": prompt}],
                    max_completion_tokens=16384,
                    extra_body={"reasoning_effort": "medium"},
                )
                content = response.choices[0].message.content
                if not content or not content.strip():
                    logger.warning(f"Empty response for {dataset['id']} (attempt {attempt+1})")
                    continue
                content = content.strip()
                if content.startswith("```"):
                    content = re.sub(r'^```(?:json)?\s*\n?', '', content)
                    content = re.sub(r'\n?```\s*$', '', content)
                result = json.loads(content)
                if "tables" not in result or not result["tables"]:
                    continue
                num_tables = len(result.get("tables", []))
                logger.info(f"  OK {dataset['id']} -> {num_tables} tables ({platform})")
                pbar.update(1)
                return dataset["id"], result
            except json.JSONDecodeError as e:
                logger.warning(f"JSON error {dataset['id']} (attempt {attempt+1}): {e}")
            except Exception as e:
                logger.error(f"API error {dataset['id']} (attempt {attempt+1}): {e}")

        logger.warning(f"All retries failed for {dataset['id']}, using simple schema")
        pbar.update(1)
        return dataset["id"], build_simple_schema(dataset, data_elements, platform)


async def process_platform(client, platform, datasets_with_elements, pbar):
    semaphore = asyncio.Semaphore(MAX_CONCURRENT)
    strategy = STRATEGIES[platform]
    min_split = strategy["min_elements_to_split"]

    tasks = []
    simple_results = []

    for ds_id, (dataset, elements) in datasets_with_elements.items():
        if len(elements) >= min_split and platform != "mongodb":
            tasks.append(split_with_ai(client, semaphore, dataset, elements, platform, pbar))
        else:
            result = build_simple_schema(dataset, elements, platform)
            simple_results.append((ds_id, result))
            pbar.update(1)

    ai_results = await asyncio.gather(*tasks, return_exceptions=True)

    all_results = {}
    for ds_id, result in simple_results:
        all_results[ds_id] = result
    for item in ai_results:
        if isinstance(item, Exception):
            logger.error(f"Task failed: {item}")
            continue
        ds_id, result = item
        all_results[ds_id] = result

    return all_results


def write_platform_ddl(platform, schemas):
    platform_dir = os.path.join(SCHEMAS_DIR, platform)
    os.makedirs(platform_dir, exist_ok=True)

    schema_groups = {}
    for ds_id, schema in schemas.items():
        schema_name = schema.get("schema_name", "default")
        if schema_name not in schema_groups:
            schema_groups[schema_name] = []
        schema_groups[schema_name].append((ds_id, schema))

    for schema_name, group in schema_groups.items():
        safe_name = re.sub(r'[^a-zA-Z0-9_]', '_', str(schema_name)).lower()
        ext = "json" if platform == "mongodb" else "sql"
        filepath = os.path.join(platform_dir, f"{safe_name}.{ext}")

        with open(filepath, "w", encoding="utf-8") as f:
            if platform == "mongodb":
                mongo_schemas = []
                for ds_id, schema in group:
                    ddl = generate_mongodb_schema(schema)
                    try:
                        mongo_schemas.append(json.loads(ddl))
                    except json.JSONDecodeError:
                        mongo_schemas.append({"error": f"Failed for {ds_id}"})
                json.dump(mongo_schemas, f, indent=2)
            else:
                f.write(f"-- ============================================\n")
                f.write(f"-- Platform: {platform.upper()}\n")
                f.write(f"-- Schema/Source: {schema_name}\n")
                f.write(f"-- Generated: {datetime.now().isoformat()}\n")
                f.write(f"-- Datasets: {len(group)}\n")
                f.write(f"-- ============================================\n\n")
                for ds_id, schema in group:
                    f.write(f"-- Dataset: {ds_id}\n")
                    ddl = generate_ddl(schema, platform)
                    f.write(ddl)
                    f.write("\n\n")

        logger.info(f"  Wrote {platform}/{safe_name}.{ext} - {len(group)} datasets")

    total_tables = sum(len(s.get("tables", [])) for s in schemas.values())
    logger.info(f"  {platform}: {len(schemas)} datasets -> {total_tables} tables")


# ─── MAIN ────────────────────────────────────────────────────────────────────

async def main():
    logger.info("=== Schema Generation V2 (328 selected datasets) ===")

    # Load enhanced JSONs for selected datasets only
    logger.info(f"Loading selected datasets from {ENHANCED_DATA_DIR}")
    enhanced_dir = Path(ENHANCED_DATA_DIR)

    platform_datasets = {p: {} for p in STRATEGIES}
    loaded = 0

    for filepath in sorted(enhanced_dir.glob("enhanced_*.json")):
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                dataset = json.load(f)
            ds_id = dataset.get("id")
            if ds_id not in SELECTED_IDS:
                continue
            elements = dataset.get("dataElements", [])
            if not elements:
                continue
            platform = SELECTED_MAP[ds_id]["platform"]
            platform_datasets[platform][ds_id] = (dataset, elements)
            loaded += 1
        except Exception as e:
            logger.error(f"Error loading {filepath.name}: {e}")

    logger.info(f"Loaded {loaded} selected datasets")
    for platform, datasets in platform_datasets.items():
        if datasets:
            logger.info(f"  {platform:15s}: {len(datasets):4d} datasets")

    # Count AI vs simple
    ai_count = 0
    simple_count = 0
    for platform, datasets in platform_datasets.items():
        min_split = STRATEGIES[platform]["min_elements_to_split"]
        for ds_id, (dataset, elements) in datasets.items():
            if len(elements) >= min_split and platform != "mongodb":
                ai_count += 1
            else:
                simple_count += 1

    logger.info(f"\n  AI splitting needed: {ai_count}")
    logger.info(f"  Simple (1:1 or bronze): {simple_count}")

    # Initialize client
    client = AsyncAzureOpenAI(
        azure_endpoint=AZURE_ENDPOINT,
        api_key=AZURE_API_KEY,
        api_version=AZURE_API_VERSION,
    )

    # Process each platform
    all_schemas = {}
    with tqdm(total=loaded, desc="Generating schemas") as pbar:
        for platform in platform_datasets:
            if not platform_datasets[platform]:
                continue
            logger.info(f"\nProcessing {platform} ({len(platform_datasets[platform])} datasets)...")
            results = await process_platform(client, platform, platform_datasets[platform], pbar)
            all_schemas[platform] = results
            write_platform_ddl(platform, results)

    # Save results
    results_path = os.path.join(CONFIG_DIR, "schema_results_v2.json")
    with open(results_path, "w", encoding="utf-8") as f:
        json.dump(all_schemas, f, indent=2, default=str)

    # Summary
    total_tables = 0
    for platform, schemas in all_schemas.items():
        pt = sum(len(s.get("tables", [])) for s in schemas.values())
        total_tables += pt
        logger.info(f"  {platform:15s}: {len(schemas):4d} datasets -> {pt:5d} tables")

    logger.info(f"\n  TOTAL: {loaded} datasets -> {total_tables} tables across {len(all_schemas)} platforms")
    logger.info("=== Schema Generation V2 Complete ===")


if __name__ == "__main__":
    asyncio.run(main())
