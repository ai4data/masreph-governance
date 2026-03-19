#!/usr/bin/env python3
"""
Generate DDL schemas for all datasets, distributed across 8 database platforms.

Uses Azure OpenAI to intelligently split datasets into normalized tables,
with platform-aware splitting strategies:
- SQL Server/Oracle: legacy-style, wider tables, moderate normalization
- PostgreSQL/MySQL: well-normalized, clean conventions
- Snowflake/Fabric: star schema (fact/dimension pattern)
- Databricks: medallion architecture (bronze/silver/gold)
- MongoDB: document embedding (no splitting, nested structures)
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

# ─── LOGGING ────────────────────────────────────────────────────────────────

LOG_DIR = os.path.join(os.path.dirname(__file__), "..", "logs")
os.makedirs(LOG_DIR, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler(os.path.join(LOG_DIR, "schema_generation.log"), mode="w"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger(__name__)
logging.getLogger("httpx").setLevel(logging.WARNING)
logging.getLogger("openai").setLevel(logging.WARNING)
logging.getLogger("httpcore").setLevel(logging.WARNING)

# ─── CONFIG ─────────────────────────────────────────────────────────────────

AZURE_ENDPOINT = os.getenv("AZURE_OPENAI_ENDPOINT")
AZURE_API_KEY = os.getenv("AZURE_OPENAI_API_KEY")
AZURE_API_VERSION = os.getenv("AZURE_OPENAI_API_VERSION", "2025-01-01-preview")
AZURE_DEPLOYMENT = os.getenv("AZURE_OPENAI_DEPLOYMENT_NAME", "gpt-5.1")

MAX_CONCURRENT = 10
MAX_RETRIES = 2

BASE_DIR = os.path.join(os.path.dirname(__file__), "..")
CONFIG_DIR = os.path.join(BASE_DIR, "config")
SCHEMAS_DIR = os.path.join(BASE_DIR, "schemas")
ENHANCED_DATA_DIR = "C:/Users/Hicham/OneDrive/python/learning/dm-db/enhanced-data"

# Load configs
with open(os.path.join(CONFIG_DIR, "platform_assignment.json"), "r") as f:
    PLATFORM_ASSIGNMENTS = json.load(f)

with open(os.path.join(CONFIG_DIR, "type_mapping.json"), "r") as f:
    TYPE_MAPPINGS = json.load(f)

with open(os.path.join(CONFIG_DIR, "naming_conventions.json"), "r") as f:
    NAMING_CONVENTIONS = json.load(f)


# ─── SPLITTING STRATEGY PER PLATFORM ────────────────────────────────────────

SPLITTING_STRATEGIES = {
    "sql-server": {
        "min_elements_to_split": 12,
        "style": "legacy_normalized",
        "description": (
            "This is a legacy SQL Server enterprise system (15+ years old). "
            "Apply moderate normalization - split into entities when clear boundaries exist, "
            "but don't over-normalize. Some wide tables are OK for legacy systems. "
            "Include audit columns (CreatedDate, ModifiedDate, CreatedBy) on main tables. "
            "Use PascalCase for all identifiers. Some tables may have 'tbl' prefix for legacy feel."
        ),
    },
    "postgresql": {
        "min_elements_to_split": 10,
        "style": "well_normalized",
        "description": (
            "This is a modern PostgreSQL application database. "
            "Apply thorough normalization (3NF). Extract distinct entities into separate tables. "
            "Separate lookup/reference data from transactional data. "
            "Use snake_case for all identifiers. Add created_at and updated_at columns."
        ),
    },
    "mysql": {
        "min_elements_to_split": 10,
        "style": "well_normalized",
        "description": (
            "This is a web/digital application MySQL database. "
            "Apply clean normalization. Keep tables simple and focused. "
            "Use snake_case for all identifiers. Add created_at column."
        ),
    },
    "snowflake": {
        "min_elements_to_split": 8,
        "style": "star_schema",
        "description": (
            "This is a Snowflake analytics warehouse using star schema design. "
            "Split into FACT tables (measurable events/transactions with foreign keys to dimensions) "
            "and DIM tables (descriptive attributes - customer, product, date, status). "
            "Prefix fact tables with FACT_ and dimension tables with DIM_. "
            "Use UPPERCASE_SNAKE_CASE for all identifiers. "
            "Dimension tables have surrogate keys ({DIM_NAME}_KEY). "
            "Fact tables reference dimensions via _KEY columns."
        ),
    },
    "databricks": {
        "min_elements_to_split": 15,
        "style": "medallion",
        "description": (
            "This is a Databricks lakehouse using medallion architecture. "
            "Design tables for the SILVER layer (cleaned, typed, moderately normalized). "
            "Keep tables relatively wide - columnar storage handles it well. "
            "Only split when there are clearly distinct entities. "
            "Use snake_case for all identifiers. "
            "Add _loaded_at and _source_file metadata columns."
        ),
    },
    "fabric": {
        "min_elements_to_split": 8,
        "style": "star_schema",
        "description": (
            "This is a Microsoft Fabric lakehouse used for corporate BI and reporting. "
            "Split into Fact tables (measurable events with foreign keys) "
            "and Dim tables (descriptive dimensions - employee, department, account). "
            "Prefix: Fact for fact tables, Dim for dimension tables. "
            "Use PascalCase for all identifiers. "
            "Dimension tables have surrogate keys ({DimName}Key). "
            "Fact tables reference dimensions via Key columns."
        ),
    },
    "oracle": {
        "min_elements_to_split": 12,
        "style": "legacy_abbreviated",
        "description": (
            "This is a legacy Oracle ERP database (20+ years old). "
            "Apply moderate normalization. Use heavily abbreviated UPPERCASE names "
            "(max 30 characters per identifier). Common abbreviations: "
            "MSTR=Master, DTL=Detail, HDR=Header, TXN=Transaction, CNTRCT=Contract, "
            "CUST=Customer, ACCT=Account, AMT=Amount, DT=Date, CD=Code, NM=Name, "
            "NBR=Number, STAT=Status, ADDR=Address, DESC_TX=Description. "
            "Include SYS_CR_DT (system create date) and SYS_UPD_DT (system update date) audit columns."
        ),
    },
    "mongodb": {
        "min_elements_to_split": 999,  # Never split - embed instead
        "style": "document_embedding",
        "description": (
            "This is a MongoDB document store. DO NOT split into multiple collections. "
            "Instead, design a SINGLE document structure with nested objects and arrays "
            "where a relational DB would use joins. Group related fields into nested objects "
            "(e.g., personalInfo: {firstName, lastName, email}, address: {street, city, zip}). "
            "Use camelCase for all field names. Include _id as the primary identifier. "
            "Design for read patterns - embed data that's read together."
        ),
    },
}


# ─── PROMPT BUILDER ─────────────────────────────────────────────────────────

def build_splitting_prompt(dataset, data_elements, platform, strategy):
    """Build the prompt for AI-powered table splitting."""

    naming = NAMING_CONVENTIONS[platform]
    type_map = TYPE_MAPPINGS[platform]

    # Format data elements for the prompt
    elements_desc = []
    for elem in data_elements:
        sample = elem.get("sampleValues", [])
        sample_str = ", ".join(str(s) for s in sample[:3]) if sample else "N/A"
        elements_desc.append(
            f"  - {elem['name']} ({elem.get('dataType', 'string')}, "
            f"format: {elem.get('format', 'N/A')}, "
            f"nullable: {elem.get('nullable', False)}): "
            f"{elem.get('description', 'No description')} "
            f"[samples: {sample_str}]"
        )
    elements_text = "\n".join(elements_desc)

    # Available data types for this platform
    available_types = "\n".join(f"  - {generic} -> {native}" for generic, native in type_map.items() if generic != "format_overrides")

    prompt = f"""You are a senior database architect designing schemas for a real enterprise system.

DATASET CONTEXT:
- Name: {dataset.get('name', 'Unknown')}
- Description: {dataset.get('description', 'No description')[:300]}
- Domain: {dataset.get('dataDomain', 'Unknown')}
- Sub-domain: {dataset.get('dataSubDomain', 'Unknown')}
- Business Line: {dataset.get('businessLine', 'Unknown')}
- Source System: {dataset.get('sourceSysName', 'Unknown')}
- Number of Data Elements: {len(data_elements)}

DATA ELEMENTS:
{elements_text}

TARGET PLATFORM: {platform.upper()}
PLATFORM CONVENTIONS:
- Schema naming: {naming['schema_style']}
- Table naming: {naming['table_style']}
- Column naming: {naming['column_style']}
- PK pattern: {naming['pk_pattern']}
- FK pattern: {naming['fk_pattern']}
- Example: {naming['example_schema']}.{naming['example_table']} ({', '.join(naming['example_columns'][:3])})

SPLITTING STRATEGY:
{strategy['description']}

AVAILABLE DATA TYPES:
{available_types}

INSTRUCTIONS:
1. Analyze the data elements and identify distinct business entities
2. Design the table structure following the splitting strategy above
3. Assign each original data element to the appropriate table
4. Add primary key columns (auto-generated IDs) for each table
5. Add foreign key columns to link related tables
6. Apply the platform's naming conventions to ALL identifiers (schema, table, column names)
7. Map each data element to the correct platform-native data type

Return a JSON object with this exact structure:
{{
  "schema_name": "the schema/database name following platform conventions",
  "tables": [
    {{
      "name": "table_name_in_platform_convention",
      "description": "what this table represents",
      "table_type": "entity|fact|dimension|reference|document",
      "columns": [
        {{
          "name": "column_name_in_platform_convention",
          "original_element": "original_data_element_name or null if generated (PK/FK/audit)",
          "data_type": "platform_native_type",
          "nullable": false,
          "is_primary_key": true,
          "is_foreign_key": false,
          "references": null
        }}
      ]
    }}
  ],
  "relationships": [
    {{
      "from_table": "child_table",
      "from_column": "fk_column",
      "to_table": "parent_table",
      "to_column": "pk_column"
    }}
  ]
}}

IMPORTANT:
- Every original data element MUST appear in exactly one table
- Each table must have a primary key
- Use platform-native data types (not generic types)
- Schema name should be derived from the source system name, following platform conventions
- Return ONLY valid JSON, no markdown, no explanation"""

    return prompt


def build_simple_schema(dataset, data_elements, platform):
    """Build a simple 1:1 schema without AI (for small datasets)."""
    naming = NAMING_CONVENTIONS[platform]
    type_map = TYPE_MAPPINGS[platform]
    strategy = SPLITTING_STRATEGIES[platform]

    # Derive schema name from source system
    source_sys = dataset.get("sourceSysName", "default")
    schema_name = convert_name(source_sys, platform, "schema")
    table_name = convert_name(dataset.get("name", "unknown"), platform, "table")

    # Build columns
    columns = []

    # Add PK
    pk_name = convert_name("id", platform, "column")
    pk_type = type_map.get("integer", "INT")
    if platform == "mongodb":
        pk_name = "_id"
        pk_type = "objectId"
    columns.append({
        "name": pk_name,
        "original_element": None,
        "data_type": pk_type,
        "nullable": False,
        "is_primary_key": True,
        "is_foreign_key": False,
        "references": None,
    })

    # Map data elements
    for elem in data_elements:
        col_name = convert_name(elem["name"], platform, "column")
        data_type = resolve_type(elem.get("dataType", "string"), elem.get("format"), type_map)
        columns.append({
            "name": col_name,
            "original_element": elem["name"],
            "data_type": data_type,
            "nullable": elem.get("nullable", False),
            "is_primary_key": False,
            "is_foreign_key": False,
            "references": None,
        })

    # Add audit columns based on platform
    audit_cols = get_audit_columns(platform, type_map)
    columns.extend(audit_cols)

    return {
        "schema_name": schema_name,
        "tables": [{
            "name": table_name,
            "description": dataset.get("description", "")[:200],
            "table_type": "entity",
            "columns": columns,
        }],
        "relationships": [],
    }


# ─── NAMING CONVERTERS ──────────────────────────────────────────────────────

def to_pascal_case(s):
    """Convert string to PascalCase."""
    s = re.sub(r'[^a-zA-Z0-9\s_-]', '', s)
    words = re.split(r'[\s_-]+', s)
    return ''.join(w.capitalize() for w in words if w)


def to_snake_case(s):
    """Convert string to snake_case."""
    s = re.sub(r'[^a-zA-Z0-9\s_-]', '', s)
    s = re.sub(r'[\s-]+', '_', s)
    s = re.sub(r'([A-Z]+)([A-Z][a-z])', r'\1_\2', s)
    s = re.sub(r'([a-z\d])([A-Z])', r'\1_\2', s)
    return s.lower().strip('_')


def to_upper_snake(s):
    """Convert string to UPPER_SNAKE_CASE."""
    return to_snake_case(s).upper()


def to_camel_case(s):
    """Convert string to camelCase."""
    pascal = to_pascal_case(s)
    return pascal[0].lower() + pascal[1:] if pascal else s


def to_oracle_abbrev(s):
    """Convert string to abbreviated UPPERCASE Oracle style."""
    abbreviations = {
        "customer": "CUST", "transaction": "TXN", "contract": "CNTRCT",
        "account": "ACCT", "payment": "PYMT", "amount": "AMT",
        "date": "DT", "code": "CD", "name": "NM", "number": "NBR",
        "status": "STAT", "address": "ADDR", "description": "DESC_TX",
        "identifier": "ID", "master": "MSTR", "detail": "DTL",
        "header": "HDR", "finance": "FIN", "management": "MGMT",
        "insurance": "INS", "operations": "OPS", "system": "SYS",
        "product": "PROD", "organization": "ORG", "employee": "EMP",
        "department": "DEPT", "collateral": "COLL", "instrument": "INSTR",
        "portfolio": "PRTFL", "investment": "INVST", "mortgage": "MRTG",
        "property": "PROP", "valuation": "VAL", "assessment": "ASMT",
        "compliance": "COMPL", "verification": "VERIF", "reference": "REF",
        "category": "CAT", "classification": "CLASS", "document": "DOC",
        "service": "SVC", "type": "TYP", "indicator": "IND",
        "percentage": "PCT", "timestamp": "TS", "created": "CR",
        "updated": "UPD", "modified": "MOD", "active": "ACTV",
        "effective": "EFF", "expiration": "EXP",
    }
    snake = to_snake_case(s)
    parts = snake.split("_")
    abbreviated = []
    for part in parts:
        abbreviated.append(abbreviations.get(part, part.upper()[:6]))
    result = "_".join(abbreviated)
    return result[:30]  # Oracle 30-char limit


def convert_name(name, platform, identifier_type="table"):
    """Convert a name to the platform's naming convention."""
    if not name:
        return "unknown"

    if platform == "sql-server":
        return to_pascal_case(name)
    elif platform == "postgresql":
        return to_snake_case(name)
    elif platform == "mysql":
        return to_snake_case(name)
    elif platform == "snowflake":
        return to_upper_snake(name)
    elif platform == "databricks":
        return to_snake_case(name)
    elif platform == "fabric":
        return to_pascal_case(name)
    elif platform == "oracle":
        return to_oracle_abbrev(name)
    elif platform == "mongodb":
        if identifier_type == "schema":
            return to_camel_case(name)
        return to_camel_case(name) + ("s" if identifier_type == "table" else "")
    return name


def resolve_type(generic_type, format_hint, type_map):
    """Resolve a generic data type + format to a platform-native type."""
    format_overrides = type_map.get("format_overrides", {})

    # Check format overrides first
    if format_hint:
        fmt_lower = format_hint.lower().strip()
        for key, native_type in format_overrides.items():
            if key in fmt_lower:
                return native_type

        # Check for decimal precision in format
        decimal_match = re.match(r'decimal\((\d+),(\d+)\)', fmt_lower)
        if decimal_match:
            p, s = decimal_match.groups()
            base = type_map.get("decimal", "DECIMAL(18,4)")
            return re.sub(r'\(\d+,\d+\)', f'({p},{s})', base)

    # Fall back to generic type mapping
    return type_map.get(generic_type, type_map.get("string", "VARCHAR(255)"))


def get_audit_columns(platform, type_map):
    """Return audit columns appropriate for the platform."""
    ts_type = type_map.get("timestamp", "TIMESTAMP")

    if platform == "sql-server":
        return [
            {"name": "CreatedDate", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
            {"name": "ModifiedDate", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    elif platform == "postgresql":
        return [
            {"name": "created_at", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
            {"name": "updated_at", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    elif platform == "mysql":
        return [
            {"name": "created_at", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    elif platform == "oracle":
        return [
            {"name": "SYS_CR_DT", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
            {"name": "SYS_UPD_DT", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    elif platform == "databricks":
        return [
            {"name": "_loaded_at", "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
            {"name": "_source_file", "original_element": None, "data_type": type_map.get("string", "STRING"), "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    elif platform in ("snowflake", "fabric"):
        ts_col = "LOADED_AT" if platform == "snowflake" else "LoadedAt"
        return [
            {"name": ts_col, "original_element": None, "data_type": ts_type, "nullable": True, "is_primary_key": False, "is_foreign_key": False, "references": None},
        ]
    return []


# ─── DDL GENERATORS ─────────────────────────────────────────────────────────

def generate_ddl(schema_result, platform):
    """Generate DDL from the schema result JSON."""
    if platform == "mongodb":
        return generate_mongodb_schema(schema_result)

    ddl_lines = []
    schema_name = schema_result.get("schema_name", "dbo")

    # Schema creation (platform-specific)
    if platform in ("sql-server", "postgresql", "oracle"):
        ddl_lines.append(f"-- Schema: {schema_name}")
        if platform == "sql-server":
            ddl_lines.append(f"IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = '{schema_name}')")
            ddl_lines.append(f"    EXEC('CREATE SCHEMA [{schema_name}]');")
        elif platform == "postgresql":
            ddl_lines.append(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
        elif platform == "oracle":
            ddl_lines.append(f"-- CREATE USER {schema_name} IDENTIFIED BY password;")
            ddl_lines.append(f"-- GRANT CONNECT, RESOURCE TO {schema_name};")
        ddl_lines.append("")

    if platform == "snowflake":
        ddl_lines.append(f"-- Schema: {schema_name}")
        ddl_lines.append(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
        ddl_lines.append("")

    if platform == "databricks":
        ddl_lines.append(f"-- Schema: {schema_name}")
        ddl_lines.append(f"CREATE SCHEMA IF NOT EXISTS {schema_name};")
        ddl_lines.append("")

    # Tables
    for table in schema_result.get("tables", []):
        table_name = table["name"]
        full_name = get_full_table_name(schema_name, table_name, platform)

        ddl_lines.append(f"-- {table.get('description', '')[:100]}")

        if platform == "sql-server":
            ddl_lines.append(f"CREATE TABLE {full_name} (")
        elif platform == "oracle":
            ddl_lines.append(f"CREATE TABLE {full_name} (")
        elif platform == "snowflake":
            ddl_lines.append(f"CREATE TABLE IF NOT EXISTS {full_name} (")
        elif platform == "databricks":
            ddl_lines.append(f"CREATE TABLE IF NOT EXISTS {full_name} (")
        elif platform == "fabric":
            ddl_lines.append(f"CREATE TABLE {full_name} (")
        else:
            ddl_lines.append(f"CREATE TABLE IF NOT EXISTS {full_name} (")

        # Columns
        col_defs = []
        pk_cols = []
        for col in table.get("columns", []):
            col_name = col["name"]
            data_type = col["data_type"]
            nullable = col.get("nullable", True)
            is_pk = col.get("is_primary_key", False)

            # Build column definition
            parts = [f"    {quote_identifier(col_name, platform)} {data_type}"]
            if not nullable:
                parts.append("NOT NULL")
            col_defs.append(" ".join(parts))

            if is_pk:
                pk_cols.append(col_name)

        ddl_lines.append(",\n".join(col_defs))

        # Primary key constraint
        if pk_cols:
            pk_names = ", ".join(quote_identifier(c, platform) for c in pk_cols)
            constraint_name = f"PK_{table_name}"[:30]
            if platform == "oracle":
                constraint_name = constraint_name.upper()
            ddl_lines.append(f"    ,CONSTRAINT {constraint_name} PRIMARY KEY ({pk_names})")

        ddl_lines.append(");")
        ddl_lines.append("")

    # Foreign keys (separate ALTER statements)
    for rel in schema_result.get("relationships", []):
        from_table = get_full_table_name(schema_name, rel["from_table"], platform)
        to_table = get_full_table_name(schema_name, rel["to_table"], platform)
        from_col = quote_identifier(rel["from_column"], platform)
        to_col = quote_identifier(rel["to_column"], platform)
        fk_name = f"FK_{rel['from_table']}_{rel['from_column']}"[:30]
        if platform == "oracle":
            fk_name = fk_name.upper()

        ddl_lines.append(f"ALTER TABLE {from_table} ADD CONSTRAINT {fk_name}")
        ddl_lines.append(f"    FOREIGN KEY ({from_col}) REFERENCES {to_table} ({to_col});")
        ddl_lines.append("")

    return "\n".join(ddl_lines)


def generate_mongodb_schema(schema_result):
    """Generate MongoDB JSON Schema validator."""
    tables = schema_result.get("tables", [])
    if not tables:
        return "{}"

    # For MongoDB, we generate a JSON Schema validator for the collection
    table = tables[0]  # MongoDB = single collection
    properties = {}
    required = []

    for col in table.get("columns", []):
        if col["name"] == "_id":
            continue
        bson_type = col["data_type"]
        if bson_type not in ("string", "int", "double", "bool", "date", "array", "object", "objectId"):
            bson_type = "string"
        prop = {"bsonType": bson_type}
        if col.get("description"):
            prop["description"] = col.get("description", "")
        properties[col["name"]] = prop
        if not col.get("nullable", True):
            required.append(col["name"])

    schema = {
        "collection": table["name"],
        "database": schema_result.get("schema_name", "masrephApi"),
        "description": table.get("description", ""),
        "validator": {
            "$jsonSchema": {
                "bsonType": "object",
                "required": required,
                "properties": properties,
            }
        },
    }
    return json.dumps(schema, indent=2)


def get_full_table_name(schema_name, table_name, platform):
    """Get the fully qualified table name for a platform."""
    if platform == "mysql":
        return f"`{table_name}`"
    elif platform == "sql-server":
        return f"[{schema_name}].[{table_name}]"
    elif platform == "oracle":
        return f"{schema_name}.{table_name}"
    elif platform == "snowflake":
        return f"{schema_name}.{table_name}"
    elif platform == "databricks":
        return f"{schema_name}.{table_name}"
    elif platform == "fabric":
        return f"[{schema_name}].[{table_name}]"
    elif platform == "postgresql":
        return f"{schema_name}.{table_name}"
    return f"{schema_name}.{table_name}"


def quote_identifier(name, platform):
    """Quote an identifier if needed."""
    if platform == "sql-server" or platform == "fabric":
        return f"[{name}]"
    elif platform == "mysql":
        return f"`{name}`"
    elif platform == "oracle" or platform == "snowflake":
        return name  # Already uppercase, no quoting needed
    return name


# ─── ASYNC AI SPLITTING ─────────────────────────────────────────────────────

async def split_dataset_with_ai(client, semaphore, dataset, data_elements, platform, pbar):
    """Use Azure OpenAI to split a dataset into normalized tables."""
    strategy = SPLITTING_STRATEGIES[platform]

    async with semaphore:
        prompt = build_splitting_prompt(dataset, data_elements, platform, strategy)

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

                # Clean response - remove markdown code blocks if present
                content = content.strip()
                if content.startswith("```"):
                    content = re.sub(r'^```(?:json)?\s*\n?', '', content)
                    content = re.sub(r'\n?```\s*$', '', content)

                result = json.loads(content)

                # Validate basic structure
                if "tables" not in result or not result["tables"]:
                    logger.warning(f"No tables in response for {dataset['id']} (attempt {attempt+1})")
                    continue

                num_tables = len(result.get("tables", []))
                logger.info(f"  OK {dataset['id']} -> {num_tables} tables ({platform})")
                pbar.update(1)
                return dataset["id"], result

            except json.JSONDecodeError as e:
                logger.warning(f"JSON parse error for {dataset['id']} (attempt {attempt+1}): {e}")
            except Exception as e:
                logger.error(f"API error for {dataset['id']} (attempt {attempt+1}): {e}")

        # All retries failed - fall back to simple schema
        logger.warning(f"All retries failed for {dataset['id']}, using simple schema")
        pbar.update(1)
        return dataset["id"], build_simple_schema(dataset, data_elements, platform)


# ─── MAIN ────────────────────────────────────────────────────────────────────

async def process_platform(client, platform, datasets_with_elements, pbar):
    """Process all datasets for a single platform."""
    semaphore = asyncio.Semaphore(MAX_CONCURRENT)
    strategy = SPLITTING_STRATEGIES[platform]
    min_split = strategy["min_elements_to_split"]

    tasks = []
    simple_results = []

    for ds_id, (dataset, elements) in datasets_with_elements.items():
        if len(elements) >= min_split and platform != "mongodb":
            # Needs AI splitting
            tasks.append(split_dataset_with_ai(client, semaphore, dataset, elements, platform, pbar))
        else:
            # Simple 1:1 mapping
            result = build_simple_schema(dataset, elements, platform)
            simple_results.append((ds_id, result))
            pbar.update(1)

    # Run AI splitting concurrently
    ai_results = await asyncio.gather(*tasks, return_exceptions=True)

    # Combine results
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
    """Write DDL files for a completed platform."""
    platform_dir = os.path.join(SCHEMAS_DIR, platform)
    os.makedirs(platform_dir, exist_ok=True)

    schema_groups = {}
    for ds_id, schema in schemas.items():
        schema_name = schema.get("schema_name", "default")
        if schema_name not in schema_groups:
            schema_groups[schema_name] = []
        schema_groups[schema_name].append((ds_id, schema))

    for schema_name, group in schema_groups.items():
        safe_name = re.sub(r'[^a-zA-Z0-9_]', '_', schema_name).lower()
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
                f.write(f"-- Schema: {schema_name}\n")
                f.write(f"-- Generated: {datetime.now().isoformat()}\n")
                f.write(f"-- Datasets: {len(group)}\n")
                f.write(f"-- ============================================\n\n")
                for ds_id, schema in group:
                    f.write(f"-- Dataset: {ds_id}\n")
                    ddl = generate_ddl(schema, platform)
                    f.write(ddl)
                    f.write("\n\n")

        logger.info(f"  Wrote {platform}/{safe_name}.{ext} - {len(group)} datasets")

    platform_tables = sum(len(s.get("tables", [])) for s in schemas.values())
    logger.info(f"  {platform}: {len(schemas)} datasets -> {platform_tables} tables")


async def main():
    logger.info("=== Schema Generation Started ===")

    # Load enhanced JSON files
    logger.info(f"Loading datasets from {ENHANCED_DATA_DIR}")
    enhanced_dir = Path(ENHANCED_DATA_DIR)
    files = sorted(enhanced_dir.glob("enhanced_*.json"))
    logger.info(f"Found {len(files)} enhanced JSON files")

    # Group datasets by platform
    platform_datasets = {p: {} for p in SPLITTING_STRATEGIES}

    for filepath in files:
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                dataset = json.load(f)
            ds_id = dataset.get("id")
            if not ds_id or ds_id not in PLATFORM_ASSIGNMENTS:
                continue
            elements = dataset.get("dataElements", [])
            if not elements:
                continue
            platform = PLATFORM_ASSIGNMENTS[ds_id]["platform"]
            platform_datasets[platform][ds_id] = (dataset, elements)
        except Exception as e:
            logger.error(f"Error loading {filepath.name}: {e}")

    # Report distribution
    for platform, datasets in platform_datasets.items():
        logger.info(f"  {platform:15s}: {len(datasets):4d} datasets")

    total = sum(len(d) for d in platform_datasets.values())
    logger.info(f"  {'TOTAL':15s}: {total:4d} datasets")

    # Count how many need AI splitting
    ai_count = 0
    for platform, datasets in platform_datasets.items():
        min_split = SPLITTING_STRATEGIES[platform]["min_elements_to_split"]
        for ds_id, (dataset, elements) in datasets.items():
            if len(elements) >= min_split and platform != "mongodb":
                ai_count += 1
    logger.info(f"\n  Datasets needing AI splitting: {ai_count}")
    logger.info(f"  Datasets with simple 1:1 mapping: {total - ai_count}")

    # Initialize Azure OpenAI client
    client = AsyncAzureOpenAI(
        azure_endpoint=AZURE_ENDPOINT,
        api_key=AZURE_API_KEY,
        api_version=AZURE_API_VERSION,
    )

    # Process each platform and write DDL incrementally
    all_schemas = {}
    with tqdm(total=total, desc="Generating schemas") as pbar:
        for platform in platform_datasets:
            if not platform_datasets[platform]:
                continue
            logger.info(f"\nProcessing {platform} ({len(platform_datasets[platform])} datasets)...")
            results = await process_platform(client, platform, platform_datasets[platform], pbar)
            all_schemas[platform] = results

            # Write DDL immediately after each platform completes
            write_platform_ddl(platform, results)

    # Write DDL files summary
    logger.info("\n=== DDL Files Written ===")

    # Write combined schema results JSON for reference
    results_path = os.path.join(CONFIG_DIR, "schema_results.json")
    with open(results_path, "w", encoding="utf-8") as f:
        json.dump(all_schemas, f, indent=2, default=str)
    logger.info(f"\nWrote schema results to {results_path}")

    # Summary stats
    total_tables = 0
    for platform, schemas in all_schemas.items():
        platform_tables = sum(len(s.get("tables", [])) for s in schemas.values())
        total_tables += platform_tables
        logger.info(f"  {platform:15s}: {len(schemas):4d} datasets -> {platform_tables:5d} tables")

    logger.info(f"\n  TOTAL: {total} datasets -> {total_tables} tables across 8 platforms")
    logger.info("=== Schema Generation Complete ===")


if __name__ == "__main__":
    asyncio.run(main())
