#!/usr/bin/env python3
"""
Generate realistic sample data with quality issues for PostgreSQL schemas.
Reads actual table structures from pg_catalog to avoid column mismatches.

Row budget per TABLE (not per schema):
- Reference/lookup tables: 15-50 rows
- Dimension/entity tables: 100-300 rows
- Transaction/event tables: 500-1000 rows

Quality profile: 88-94% (modern app, 5 years old)
"""

import os
import json
import random
import string
import uuid as uuid_mod
import psycopg2
from psycopg2.extras import execute_batch
import logging
from datetime import datetime, date, timedelta, timezone
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ─── QUALITY SETTINGS ────────────────────────────────────────────────────────

QUALITY_NULL_RATE = 0.02
QUALITY_STALE_RATE = 0.05
QUALITY_ENCODING_RATE = 0.03
QUALITY_TIMEZONE_ISSUE_RATE = 0.04

# ─── REALISTIC DATA POOLS ───────────────────────────────────────────────────

FIRST_NAMES_M = ["Jan", "Pieter", "Lars", "Thomas", "Michiel", "Daan", "Bram", "Lucas",
    "Sven", "Mark", "Ahmed", "Mohammed", "Wei", "Raj", "Arjun", "James",
    "Robert", "Carlos", "Jean", "Hans", "Klaus", "Pedro", "Ivan"]
FIRST_NAMES_F = ["Maria", "Sophie", "Anna", "Eva", "Fleur", "Emma", "Lisa", "Julia",
    "Nina", "Lotte", "Fatima", "Aisha", "Mei", "Yuki", "Priya", "Deepa",
    "Sarah", "Emily", "Isabella", "Marie", "Greta", "Heidi", "Ana", "Olga"]
FIRST_NAMES = FIRST_NAMES_M + FIRST_NAMES_F

LAST_NAMES = [
    "van den Berg", "de Jong", "Jansen", "de Vries", "van Dijk", "Bakker", "Visser",
    "Smit", "Meijer", "de Boer", "Muller", "Schmidt", "Schneider", "Fischer", "Weber",
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Martinez", "Rodriguez",
    "Lopez", "Hernandez", "Chen", "Wang", "Li", "Zhang", "Liu", "Patel", "Sharma",
    "Kumar", "Singh", "Gupta", "Dubois", "Moreau", "Laurent", "Simon", "Martin",
]
DIACRITICS_FIRST = ["Rene", "Francois", "Jose", "Soren", "Laszlo", "Bjorn", "Nuria"]
DIACRITICS_LAST = ["Muller", "Mueller", "Muller", "Bjork", "Bjork", "Renee", "Francois"]
DIACRITICS_CORRECT = ["Ren\u00e9", "Fran\u00e7ois", "Jos\u00e9", "S\u00f8ren", "L\u00e1szl\u00f3", "Bj\u00f6rn", "N\u00faria"]
DIACRITICS_LAST_CORRECT = ["M\u00fcller", "M\u00fcller", "M\u00fcller", "Bj\u00f6rk", "Bj\u00f6rk", "Ren\u00e9e", "Fran\u00e7ois"]

COUNTRIES_EU = ["NL", "DE", "FR", "GB", "BE", "CH", "AT", "ES", "IT", "LU", "IE", "PT", "DK", "SE", "NO", "FI", "PL"]
COUNTRIES_APAC = ["JP", "SG", "AU", "HK", "MY", "IN", "KR", "TH"]
COUNTRIES_US = ["US", "CA", "BR", "MX"]
COUNTRIES = COUNTRIES_EU + COUNTRIES_APAC + COUNTRIES_US

CURRENCIES = ["EUR", "USD", "GBP", "CHF", "JPY", "SGD", "AUD", "SEK", "NOK", "DKK"]
GENDER_CODES = ["M", "F", "X"]
MARITAL_STATUSES = ["single", "married", "divorced", "widowed", "registered_partnership"]
EMPLOYMENT_STATUSES = ["employed", "self_employed", "unemployed", "retired", "student"]
OCCUPATION_CATEGORIES = ["finance_professional", "management", "engineering", "healthcare", "education",
    "legal", "sales", "administration", "public_sector", "agriculture", "construction", "IT"]

CREDIT_RISK_BANDS = ["AAA", "AA", "A", "BBB", "BB", "B", "CCC", "CC", "C", "D"]
KYC_RISK_RATINGS = ["low", "medium", "high", "very_high"]
RISK_LEVELS = ["low", "medium", "high", "critical"]
SENTIMENT_LABELS = ["very_positive", "positive", "neutral", "negative", "very_negative"]
STATUSES = ["active", "inactive", "pending", "suspended", "closed"]
STATUSES_ACCOUNT = ["open", "closed", "frozen", "dormant", "pending_closure"]
STATUSES_CONTRACT = ["active", "terminated", "expired", "pending_activation", "in_default"]
STATUSES_RESOLUTION = ["open", "in_progress", "resolved", "escalated", "closed"]
CHANNELS = ["web_portal", "mobile_app", "branch", "phone", "email", "api", "chatbot", "video_call"]
PRODUCT_TYPES = ["auto_lease", "equipment_lease", "mortgage", "personal_loan", "business_loan",
    "credit_card", "savings_account", "investment_fund", "insurance", "trade_finance"]
PRODUCT_SUBTYPES = ["standard", "premium", "flex", "green", "fixed_rate", "variable_rate"]
INDUSTRIES = ["Financial Services", "Manufacturing", "Retail", "Healthcare", "Technology",
    "Real Estate", "Automotive", "Energy", "Transportation", "Telecommunications",
    "Agriculture", "Construction", "Hospitality", "Media", "Education", "Pharma"]
DEPARTMENTS = ["Sales", "Finance", "Risk Management", "Operations", "IT", "Legal",
    "Compliance", "HR", "Marketing", "Customer Service", "Treasury", "Audit"]
LANGUAGES = ["nl", "en", "de", "fr", "es", "it", "pt", "ja", "zh", "ar"]
CONTACT_TIME_WINDOWS = ["morning", "afternoon", "evening", "business_hours_only", "anytime"]
GDPR_CONSENT_VERSIONS = ["v1.0", "v1.1", "v2.0", "v2.1", "v3.0"]
RELATIONSHIP_STAGES = ["prospect", "onboarding", "active", "at_risk", "churned", "win_back"]
CUSTOMER_SEGMENTS = ["mass_market", "affluent", "high_net_worth", "ultra_high_net_worth",
    "sme", "mid_corporate", "large_corporate", "institutional"]
LEASING_SEGMENTS = ["retail_auto", "fleet", "equipment", "real_estate", "mobility_solutions"]
FEEDBACK_CATEGORIES = ["product_quality", "service_speed", "digital_experience", "pricing",
    "staff_knowledge", "complaint", "suggestion", "compliment"]
PROFITABILITY_BANDS = ["high_value", "profitable", "marginal", "loss_making", "strategic"]

CITIES_BY_COUNTRY = {
    "NL": ["Amsterdam", "Rotterdam", "The Hague", "Utrecht", "Eindhoven", "Groningen"],
    "DE": ["Berlin", "Munich", "Frankfurt", "Hamburg", "Cologne", "Stuttgart", "Dusseldorf"],
    "FR": ["Paris", "Lyon", "Marseille", "Toulouse", "Nice", "Strasbourg"],
    "GB": ["London", "Manchester", "Birmingham", "Edinburgh", "Bristol", "Leeds"],
    "US": ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "San Francisco"],
    "BE": ["Brussels", "Antwerp", "Ghent", "Bruges"],
    "CH": ["Zurich", "Geneva", "Basel", "Bern"],
    "SG": ["Singapore"],
    "JP": ["Tokyo", "Osaka", "Yokohama"],
}
STREETS = ["Keizersgracht", "Herengracht", "Prinsengracht", "Damrak", "Main Street",
    "Friedrichstrasse", "Rue de Rivoli", "Oxford Street", "Broadway", "Bahnhofstrasse",
    "Via Roma", "Gran Via", "Orchard Road", "Ginza", "George Street"]

PRODUCT_NAMES = [
    "Masreph Auto Lease Plus", "Masreph Fleet Pro", "Masreph Home Finance Direct",
    "Masreph Business Credit 360", "Masreph Savings Smart", "Masreph Investment Direct",
    "Masreph Equipment Lease Flex", "Masreph Green Mobility Lease", "Masreph Trade Finance Express",
    "Masreph Personal Loan Standard", "Masreph Premium Mortgage", "Masreph SME Credit Line",
    "Masreph Corporate Bond Fund", "Masreph Insurance Plus", "Masreph Treasury Services",
]
BRANCH_NAMES = [
    "Amsterdam Central", "Rotterdam South", "Frankfurt Main", "London City",
    "Paris La Defense", "Brussels EU Quarter", "Zurich Bahnhofstrasse",
    "Singapore Marina Bay", "New York Midtown", "Tokyo Marunouchi",
]


# ─── CONNECTION ──────────────────────────────────────────────────────────────

def get_connection():
    return psycopg2.connect(
        host=os.getenv("MASREPH_PG_HOST"),
        port=int(os.getenv("MASREPH_PG_PORT", 5432)),
        database=os.getenv("MASREPH_PG_NAME"),
        user=os.getenv("MASREPH_PG_USER"),
        password=os.getenv("MASREPH_PG_PASSWORD"),
        connect_timeout=15,
    )


# ─── DATABASE INTROSPECTION ─────────────────────────────────────────────────

def get_schemas(conn):
    cur = conn.cursor()
    cur.execute("""
        SELECT DISTINCT schemaname FROM pg_tables
        WHERE schemaname NOT IN (
            'pg_catalog','information_schema','auth','storage','realtime','extensions',
            'graphql','graphql_public','pgsodium','pgsodium_masks','vault',
            'supabase_functions','_realtime','supabase_migrations','net','_analytics','public'
        ) ORDER BY schemaname
    """)
    return [r[0] for r in cur.fetchall()]


def get_tables(conn, schema):
    cur = conn.cursor()
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname=%s ORDER BY tablename", (schema,))
    return [r[0] for r in cur.fetchall()]


def get_columns(conn, schema, table):
    cur = conn.cursor()
    cur.execute("""
        SELECT column_name, data_type, is_nullable, column_default,
               character_maximum_length, numeric_precision, numeric_scale, udt_name
        FROM information_schema.columns
        WHERE table_schema=%s AND table_name=%s ORDER BY ordinal_position
    """, (schema, table))
    return [{"name": r[0], "data_type": r[1], "nullable": r[2]=="YES", "default": r[3],
             "max_length": r[4], "precision": r[5], "scale": r[6], "udt_name": r[7]} for r in cur.fetchall()]


def get_pk_columns(conn, schema, table):
    cur = conn.cursor()
    cur.execute("""
        SELECT a.attname FROM pg_index i
        JOIN pg_attribute a ON a.attrelid=i.indrelid AND a.attnum=ANY(i.indkey)
        JOIN pg_class c ON c.oid=i.indrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE i.indisprimary AND c.relname=%s AND n.nspname=%s
    """, (table, schema))
    return [r[0] for r in cur.fetchall()]


def get_fk_info(conn, schema, table):
    cur = conn.cursor()
    cur.execute("""
        SELECT kcu.column_name, ccu.table_schema, ccu.table_name, ccu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu ON tc.constraint_name=kcu.constraint_name AND tc.table_schema=kcu.table_schema
        JOIN information_schema.constraint_column_usage ccu ON ccu.constraint_name=tc.constraint_name AND ccu.table_schema=tc.table_schema
        WHERE tc.constraint_type='FOREIGN KEY' AND tc.table_schema=%s AND tc.table_name=%s
    """, (schema, table))
    return {r[0]: (r[1], r[2], r[3]) for r in cur.fetchall()}


def get_parent_ids(conn, ref_schema, ref_table, ref_column, limit=500):
    cur = conn.cursor()
    try:
        cur.execute(f"SELECT {ref_column} FROM {ref_schema}.{ref_table} LIMIT %s", (limit,))
        ids = [r[0] for r in cur.fetchall()]
        conn.commit()
        return ids if ids else None
    except Exception:
        conn.rollback()
        return None


def get_row_count(conn, schema, table):
    cur = conn.cursor()
    try:
        cur.execute(f"SELECT COUNT(*) FROM {schema}.{table}")
        c = cur.fetchone()[0]
        conn.commit()
        return c
    except Exception:
        conn.rollback()
        return 0


# ─── ROW COUNT STRATEGY ─────────────────────────────────────────────────────

def determine_row_count(table_name, columns, fk_info):
    name = table_name.lower()
    num_fks = len(fk_info)

    if any(k in name for k in ["status", "type", "category", "config", "setting", "lookup",
            "ref_", "channel", "segment", "grade", "region", "currency", "country",
            "delinquency", "occupancy", "compensation", "frequency", "direction",
            "priority", "severity", "source_system", "outcome_code"]):
        return random.randint(15, 50)
    if any(k in name for k in ["transaction", "event", "log", "history", "audit",
            "activity", "interaction", "message", "session", "payment", "transfer", "entry", "record"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["metric", "analytics", "insight", "score", "performance", "snapshot", "report"]):
        return random.randint(300, 700)
    if any(k in name for k in ["customer", "client", "contact", "person", "account",
            "user", "member", "employee", "partner", "prospect", "lead", "persona"]):
        return random.randint(200, 500)
    if any(k in name for k in ["product", "service", "plan", "offer", "contract",
            "agreement", "loan", "mortgage", "lease", "portfolio"]):
        return random.randint(100, 300)
    if num_fks >= 2:
        return random.randint(300, 800)
    if len(columns) <= 5:
        return random.randint(20, 60)
    return random.randint(100, 300)


# ─── CONTEXTUAL VALUE GENERATOR ─────────────────────────────────────────────

def generate_value(col, row_idx, fk_ids, pk_cols):
    """Generate a contextually accurate value based on column metadata."""
    name = col["name"].lower()
    udt = col["udt_name"].lower()
    nullable = col["nullable"]
    max_len = col["max_length"] or 255
    precision = col["precision"]
    scale = col["scale"]

    # Quality: random NULLs for nullable non-PK columns
    if nullable and name not in pk_cols and random.random() < QUALITY_NULL_RATE:
        return None

    # FK column: use actual parent ID
    if name in fk_ids and fk_ids[name]:
        return random.choice(fk_ids[name])

    # PK columns
    if name in pk_cols:
        if "int" in udt: return row_idx + 1
        if udt == "uuid": return str(uuid_mod.uuid4())
        return row_idx + 1

    # ── UUID
    if udt == "uuid":
        return str(uuid_mod.uuid4())

    # ── Boolean — contextual
    if udt == "bool":
        return _gen_bool(name)

    # ── Integer — contextual
    if udt in ("int4", "int8", "int2", "serial", "bigserial"):
        return _gen_integer(name)

    # ── Numeric/decimal — contextual
    if udt in ("numeric", "float4", "float8"):
        return _gen_numeric(name, precision, scale)

    # ── Date — contextual
    if udt == "date":
        return _gen_date(name)

    # ── Timestamp — contextual
    if "timestamp" in udt:
        return _gen_timestamp(name)

    # ── JSONB
    if udt == "jsonb":
        return _gen_jsonb(name)

    # ── Text / VARCHAR — contextual
    if udt in ("text", "varchar", "bpchar", "name"):
        return _gen_text(name, max_len)

    return f"val_{row_idx}"


# ─── BOOLEAN GENERATOR ──────────────────────────────────────────────────────

def _gen_bool(name):
    # Most flags should be biased realistically
    if "active" in name or "enabled" in name:
        return random.random() < 0.85  # 85% active
    if "consent" in name or "opt_in" in name:
        return random.random() < 0.70  # 70% opted in
    if "verified" in name or "validated" in name:
        return random.random() < 0.90
    if "default" in name or "delinquent" in name or "overdue" in name:
        return random.random() < 0.05  # 5% in default
    if "archived" in name or "deleted" in name or "deprecated" in name:
        return random.random() < 0.10
    if "flag" in name and ("risk" in name or "fraud" in name or "pep" in name or "sanction" in name):
        return random.random() < 0.03  # 3% flagged
    if "restriction" in name or "blocked" in name or "frozen" in name:
        return random.random() < 0.02
    if "bounced" in name:
        return random.random() < 0.08
    if "eligible" in name or "qualified" in name:
        return random.random() < 0.60
    if "penalty" in name:
        return random.random() < 0.15
    return random.choice([True, False])


# ─── INTEGER GENERATOR ──────────────────────────────────────────────────────

def _gen_integer(name):
    if "age" in name and ("year" in name or name == "age" or name.endswith("_age")):
        return random.randint(18, 78)
    if name == "age_years" or name == "age":
        return random.randint(18, 78)
    if "household_size" in name or "family_size" in name:
        return random.choices([1, 2, 3, 4, 5, 6, 7], weights=[15, 25, 25, 20, 10, 3, 2])[0]
    if "year" in name:
        return random.randint(2019, 2026)
    if "month" in name:
        return random.randint(1, 12)
    if "day" in name and "business" not in name:
        return random.randint(1, 28)
    if "quarter" in name:
        return random.randint(1, 4)
    if "score" in name or "rating" in name:
        if "credit" in name:
            return random.randint(300, 850)
        if "nps" in name:
            return random.randint(-100, 100)
        if "csat" in name:
            return random.randint(1, 10)
        if "satisfaction" in name:
            return random.randint(1, 5)
        return random.randint(0, 100)
    if "count" in name or "number" in name or "quantity" in name or "num_" in name:
        if "product" in name or "contract" in name or "holding" in name:
            return random.randint(0, 15)
        if "employee" in name or "staff" in name:
            return random.randint(1, 5000)
        if "login" in name or "visit" in name or "session" in name:
            return random.randint(0, 500)
        return random.randint(0, 1000)
    if "duration" in name:
        if "month" in name:
            return random.randint(1, 120)
        if "day" in name:
            return random.randint(1, 365)
        if "minute" in name or "min" in name:
            return random.randint(1, 180)
        return random.randint(1, 60)
    if "tenure" in name:
        return random.randint(0, 30)
    if "priority" in name or "level" in name or "tier" in name:
        return random.randint(1, 5)
    if "attempts" in name or "retries" in name:
        return random.randint(0, 5)
    return random.randint(1, 9999)


# ─── NUMERIC GENERATOR ──────────────────────────────────────────────────────

def _gen_numeric(name, precision, scale):
    s = min(scale or 2, 4)
    max_int_digits = (precision or 18) - (scale or 2)
    max_val = min(10 ** max_int_digits - 1, 9999999)

    if any(k in name for k in ["amount", "balance", "total", "price", "value",
            "revenue", "cost", "fee", "payment", "income", "exposure", "principal",
            "outstanding", "profit", "loss", "net_worth", "gross", "ticket_size"]):
        return round(random.uniform(500, min(max_val, 2000000)), min(s, 2))
    if any(k in name for k in ["rate", "interest", "margin", "spread", "yield"]):
        return round(random.uniform(0.5, 15.0), min(s, 4))
    if any(k in name for k in ["percentage", "pct", "ratio"]):
        return round(random.uniform(0, min(max_val, 100)), min(s, 2))
    if any(k in name for k in ["score", "index"]):
        if "credit" in name:
            return round(random.uniform(0, min(max_val, 100)), min(s, 2))
        if "churn" in name or "risk" in name:
            return round(random.uniform(0, 1), min(s, 4))
        if "profitability" in name or "usage" in name:
            return round(random.uniform(0, min(max_val, 100)), min(s, 2))
        return round(random.uniform(0, min(max_val, 100)), min(s, 2))
    if "tenure" in name:
        return round(random.uniform(0.5, 35.0), min(s, 1))
    if "latitude" in name:
        return round(random.uniform(35, 60), 6)
    if "longitude" in name:
        return round(random.uniform(-10, 140), 6)
    if "weight" in name or "factor" in name:
        return round(random.uniform(0, 1), min(s, 4))
    return round(random.uniform(0, min(max_val, 99999)), min(s, 2))


# ─── DATE GENERATOR ─────────────────────────────────────────────────────────

def _gen_date(name):
    if "birth" in name or "dob" in name:
        # Age 18-78
        age = random.randint(18, 78)
        return date(2026 - age, random.randint(1, 12), random.randint(1, 28))
    if "start" in name or "open" in name or "inception" in name or "effective" in name:
        return date(2022, 1, 1) + timedelta(days=random.randint(0, 1000))
    if "end" in name or "expir" in name or "maturity" in name or "close" in name or "termination" in name:
        return date(2025, 1, 1) + timedelta(days=random.randint(0, 1500))
    if "due" in name or "next" in name or "follow" in name or "schedule" in name:
        return date(2026, 1, 1) + timedelta(days=random.randint(0, 365))
    if "payment" in name or "repayment" in name:
        return date(2024, 1, 1) + timedelta(days=random.randint(0, 700))
    if "last" in name or "recent" in name:
        return date(2025, 6, 1) + timedelta(days=random.randint(-365, 0))
    # General date
    return date(2023, 1, 1) + timedelta(days=random.randint(0, 1100))


# ─── TIMESTAMP GENERATOR ────────────────────────────────────────────────────

def _gen_timestamp(name):
    base = datetime(2023, 1, 1, tzinfo=timezone.utc)
    ts = base + timedelta(days=random.randint(0, 1100), hours=random.randint(0, 23), minutes=random.randint(0, 59))

    if ("created" in name or "start" in name or "record_creation" in name) and random.random() < QUALITY_STALE_RATE:
        ts = datetime(2019, 1, 1, tzinfo=timezone.utc) + timedelta(days=random.randint(0, 365))
    if "last" in name or "updated" in name or "modified" in name:
        ts = datetime(2025, 1, 1, tzinfo=timezone.utc) + timedelta(days=random.randint(-180, 180), hours=random.randint(0, 23))
    if random.random() < QUALITY_TIMEZONE_ISSUE_RATE:
        ts = ts.replace(tzinfo=None)
    return ts


# ─── JSONB GENERATOR ────────────────────────────────────────────────────────

def _gen_jsonb(name):
    if "address" in name:
        country = random.choice(list(CITIES_BY_COUNTRY.keys()))
        city = random.choice(CITIES_BY_COUNTRY.get(country, ["Amsterdam"]))
        return json.dumps({"street": f"{random.randint(1,500)} {random.choice(STREETS)}", "city": city, "country": country, "postal_code": f"{random.randint(1000,9999)}AA"})
    if "tag" in name or "label" in name:
        return json.dumps(random.sample(["finance", "risk", "compliance", "retail", "premium", "vip", "leasing", "corporate", "green"], k=random.randint(1, 4)))
    if "config" in name or "setting" in name or "preference" in name:
        return json.dumps({"notifications_enabled": random.choice([True, False]), "language": random.choice(LANGUAGES), "theme": random.choice(["light", "dark", "system"])})
    if "metadata" in name or "meta" in name:
        return json.dumps({"source_system": random.choice(["crm", "core_banking", "mdm"]), "version": f"{random.randint(1,3)}.{random.randint(0,9)}", "imported_at": "2025-01-15T10:30:00Z"})
    if "audit" in name or "trail" in name:
        return json.dumps({"action": random.choice(["create", "update", "consent_given"]), "timestamp": "2025-03-01T14:22:00Z", "user": f"user_{random.randint(100,999)}"})
    if "feature" in name or "vector" in name:
        return json.dumps([round(random.uniform(-1, 1), 4) for _ in range(5)])
    if "cluster" in name or "model" in name:
        return json.dumps({"cluster_id": random.randint(1, 10), "confidence": round(random.uniform(0.5, 0.99), 3), "label": random.choice(["digital_native", "traditional", "high_value", "price_sensitive"])})
    if "complaint" in name or "summary" in name or "history" in name:
        return json.dumps({"total_complaints": random.randint(0, 5), "last_complaint_date": "2025-02-10", "resolved": random.choice([True, False])})
    return json.dumps({"key": f"value_{random.randint(1,999)}"})


# ─── TEXT GENERATOR ──────────────────────────────────────────────────────────

def _gen_text(name, max_len):
    val = _gen_text_inner(name, max_len)
    return val[:max_len] if val else val


def _gen_text_inner(name, max_len):
    # ── Person names
    if any(k in name for k in ["first_name", "firstname", "given_name"]):
        if random.random() < QUALITY_ENCODING_RATE:
            return random.choice(DIACRITICS_CORRECT)
        return random.choice(FIRST_NAMES)
    if any(k in name for k in ["last_name", "lastname", "surname", "family_name"]):
        if random.random() < QUALITY_ENCODING_RATE:
            return random.choice(DIACRITICS_LAST_CORRECT)
        return random.choice(LAST_NAMES)
    if any(k in name for k in ["full_name", "customer_name", "client_name", "contact_name",
            "company_name", "org_name", "legal_name", "entity_name", "advisor_name",
            "manager_name", "agent_name", "lessee_name", "borrower_name"]):
        fn = random.choice(FIRST_NAMES)
        ln = random.choice(LAST_NAMES)
        if random.random() < QUALITY_ENCODING_RATE:
            fn = random.choice(DIACRITICS_CORRECT)
        return f"{fn} {ln}"
    if "name" in name and not any(k in name for k in ["file", "table", "column", "schema", "db"]):
        if any(k in name for k in ["product", "service", "plan", "branch", "firm", "fund"]):
            return random.choice(PRODUCT_NAMES)
        if any(k in name for k in ["branch", "office", "location"]):
            return random.choice(BRANCH_NAMES)
        return f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}"

    # ── Email
    if "email" in name:
        fn = random.choice(FIRST_NAMES).lower().replace(" ", "")
        ln = random.choice(LAST_NAMES).lower().replace(" ", "").replace("'", "")
        domain = random.choice(["masreph.com", "masreph.nl", "masreph-finance.com", "gmail.com", "outlook.com"])
        sep = random.choice([".", "_", ""])
        return f"{fn}{sep}{ln}@{domain}"

    # ── Phone
    if "phone" in name or "mobile" in name or "tel" in name:
        prefix = random.choice(["+31", "+49", "+33", "+44", "+1", "+32", "+41", "+65"])
        return f"{prefix} {random.randint(600000000, 699999999)}"

    # ── Gender
    if "gender" in name:
        return random.choices(GENDER_CODES, weights=[48, 48, 4])[0]

    # ── Marital status
    if "marital" in name:
        return random.choices(MARITAL_STATUSES, weights=[25, 45, 15, 5, 10])[0]

    # ── Employment
    if "employment" in name:
        return random.choices(EMPLOYMENT_STATUSES, weights=[55, 15, 5, 15, 10])[0]

    # ── Occupation
    if "occupation" in name or "profession" in name:
        return random.choice(OCCUPATION_CATEGORIES)

    # ── Country
    if "country" in name:
        return random.choices(COUNTRIES, weights=[5]*len(COUNTRIES_EU) + [2]*len(COUNTRIES_APAC) + [2]*len(COUNTRIES_US))[0]

    # ── City
    if "city" in name or "town" in name:
        country = random.choice(list(CITIES_BY_COUNTRY.keys()))
        return random.choice(CITIES_BY_COUNTRY[country])

    # ── Address / street
    if "address" in name or "street" in name:
        return f"{random.randint(1, 500)} {random.choice(STREETS)}"

    # ── Postal code
    if "postal" in name or "zip" in name or "postcode" in name:
        return f"{random.randint(1000, 9999)}{random.choice(['AB', 'CD', 'EF', 'GH', 'KL', 'MN'])}"

    # ── Currency
    if "currency" in name:
        return random.choice(CURRENCIES)

    # ── Language
    if "language" in name or "locale" in name:
        return random.choice(LANGUAGES)

    # ── Statuses (contextual)
    if "resolution" in name and "status" in name:
        return random.choice(STATUSES_RESOLUTION)
    if "contract" in name and "status" in name:
        return random.choice(STATUSES_CONTRACT)
    if "account" in name and "status" in name:
        return random.choice(STATUSES_ACCOUNT)
    if "status" in name or "state" in name:
        return random.choice(STATUSES)

    # ── Risk / credit
    if "credit_risk" in name and "band" in name:
        return random.choice(CREDIT_RISK_BANDS)
    if "kyc" in name and "risk" in name:
        return random.choice(KYC_RISK_RATINGS)
    if "risk" in name and ("level" in name or "rating" in name or "category" in name or "band" in name or "grade" in name):
        return random.choice(RISK_LEVELS)

    # ── Sentiment
    if "sentiment" in name:
        return random.choice(SENTIMENT_LABELS)

    # ── Segments
    if "customer_segment" in name or "client_segment" in name:
        return random.choice(CUSTOMER_SEGMENTS)
    if "leasing" in name and "segment" in name:
        return random.choice(LEASING_SEGMENTS)
    if "segment" in name:
        return random.choice(CUSTOMER_SEGMENTS)

    # ── Relationship stage
    if "relationship" in name and "stage" in name:
        return random.choice(RELATIONSHIP_STAGES)

    # ── Channel / source
    if "channel" in name or ("source" in name and "system" not in name):
        return random.choice(CHANNELS)

    # ── Product type / subtype
    if "product_type" in name or "product_category" in name:
        return random.choice(PRODUCT_TYPES)
    if "subtype" in name or "sub_type" in name:
        return random.choice(PRODUCT_SUBTYPES)

    # ── Industry
    if "industry" in name or "sector" in name:
        return random.choice(INDUSTRIES)

    # ── Department
    if "department" in name or "dept" in name or "division" in name or "business_unit" in name:
        return random.choice(DEPARTMENTS)

    # ── Feedback
    if "feedback" in name and "category" in name:
        return random.choice(FEEDBACK_CATEGORIES)

    # ── Profitability
    if "profitability" in name and "band" in name:
        return random.choice(PROFITABILITY_BANDS)

    # ── GDPR consent
    if "gdpr" in name and "consent" in name and "version" in name:
        return random.choice(GDPR_CONSENT_VERSIONS)
    if "gdpr" in name and "consent" in name and "status" in name:
        return random.choice(["granted", "withdrawn", "pending"])
    if "consent" in name and ("scope" in name or "purpose" in name):
        return random.choice(["marketing", "data_processing", "analytics", "third_party_sharing", "profiling"])

    # ── Contact time window
    if "contact_time" in name or "time_window" in name:
        return random.choice(CONTACT_TIME_WINDOWS)

    # ── Description / text
    if any(k in name for k in ["description", "desc", "comment", "note", "remark", "summary", "reason", "text"]):
        return random.choice([
            "Standard financial product for European market segment",
            "Client relationship under periodic compliance review",
            "Leasing portfolio assessment for Q4 reporting cycle",
            "Automated risk scoring based on behavioral analytics",
            "Cross-sell opportunity identified for mobility solutions",
            "GDPR consent renewal required before next contact cycle",
            "Premium tier customer with multi-product relationship",
            "Annual review scheduled for credit facility extension",
        ])

    # ── Code fields
    if "code" in name or name.endswith("_cd"):
        if "country" in name:
            return random.choice(COUNTRIES)
        if "currency" in name:
            return random.choice(CURRENCIES)
        prefix = "".join(random.choices(string.ascii_uppercase, k=3))
        return f"{prefix}-{random.randint(1000, 9999)}"

    # ── Type fields
    if "type" in name:
        if "product" in name:
            return random.choice(PRODUCT_TYPES)
        if "account" in name:
            return random.choice(["checking", "savings", "investment", "loan", "credit"])
        return random.choice(["standard", "premium", "basic", "enterprise", "custom"])

    # ── ID-like strings
    if name.endswith("_id") or "identifier" in name or "ref" in name or "uuid" in name:
        prefix = "".join(random.choices(string.ascii_uppercase, k=3))
        return f"{prefix}-{random.randint(10000, 99999)}"

    # ── Label / category
    if "label" in name or "category" in name or "class" in name:
        return random.choice(["tier_1", "tier_2", "tier_3", "standard", "premium", "high_priority"])

    # ── Version
    if "version" in name:
        return f"v{random.randint(1,5)}.{random.randint(0,9)}"

    # ── Generic fallback
    return f"masreph_{random.randint(1000, 9999)}"


# ─── TABLE POPULATION ────────────────────────────────────────────────────────

def populate_table(conn, schema, table, columns, pk_cols, fk_info, num_rows):
    cur = conn.cursor()
    fk_ids = {}
    for col_name, (ref_schema, ref_table, ref_col) in fk_info.items():
        fk_ids[col_name] = get_parent_ids(conn, ref_schema, ref_table, ref_col)

    insertable = [c for c in columns if "nextval" not in str(c.get("default") or "")]
    if not insertable:
        return 0

    col_names = [c["name"] for c in insertable]
    placeholders = ", ".join(["%s"] * len(insertable))
    full_name = f"{schema}.{table}"
    insert_sql = f"INSERT INTO {full_name} ({', '.join(col_names)}) VALUES ({placeholders})"

    rows = []
    for i in range(num_rows):
        rows.append(tuple(generate_value(c, i, fk_ids, pk_cols) for c in insertable))

    try:
        execute_batch(cur, insert_sql, rows, page_size=200)
        conn.commit()
        return len(rows)
    except Exception:
        conn.rollback()
        ok = 0
        for row in rows:
            try:
                cur.execute(insert_sql, row)
                conn.commit()
                ok += 1
            except Exception:
                conn.rollback()
        return ok


# ─── MAIN ────────────────────────────────────────────────────────────────────

def main():
    logger.info("=== Generating PostgreSQL Data (contextually accurate, up to 1000 rows/table) ===")
    conn = get_connection()
    logger.info("Connected to masreph-core")

    schemas = get_schemas(conn)
    logger.info(f"Found {len(schemas)} schemas")

    # Truncate all existing data
    cur = conn.cursor()
    for schema in schemas:
        for table in get_tables(conn, schema):
            try:
                cur.execute(f"TRUNCATE TABLE {schema}.{table} CASCADE")
                conn.commit()
            except Exception:
                conn.rollback()
    logger.info("Truncated all existing data")

    grand_total = 0
    for schema in schemas:
        tables = get_tables(conn, schema)
        logger.info(f"\nSchema: {schema} ({len(tables)} tables)")

        table_meta = []
        for table in tables:
            columns = get_columns(conn, schema, table)
            pk_cols = get_pk_columns(conn, schema, table)
            fk_info = get_fk_info(conn, schema, table)
            table_meta.append({
                "name": table, "columns": columns, "pk_cols": pk_cols,
                "fk_info": fk_info, "num_rows": determine_row_count(table, columns, fk_info),
                "num_fks": len(fk_info),
            })

        # Process parents first
        table_meta.sort(key=lambda t: t["num_fks"])

        schema_total = 0
        for t in table_meta:
            inserted = populate_table(conn, schema, t["name"], t["columns"], t["pk_cols"], t["fk_info"], t["num_rows"])
            schema_total += inserted

        logger.info(f"  -> {schema}: {schema_total} rows")
        grand_total += schema_total

    # Verification
    cur = conn.cursor()
    cur.execute("""
        SELECT schemaname, SUM(n_live_tup), COUNT(*)
        FROM pg_stat_user_tables
        WHERE schemaname NOT IN ('pg_catalog','information_schema','auth','storage','realtime','extensions','public')
          AND n_live_tup > 0
        GROUP BY schemaname ORDER BY SUM(n_live_tup) DESC
    """)
    logger.info("\n=== Final Results ===")
    for r in cur.fetchall():
        logger.info(f"  {r[0]}: {r[1]} rows in {r[2]} tables")

    cur.execute("""
        SELECT COUNT(*) FROM pg_stat_user_tables
        WHERE schemaname NOT IN ('pg_catalog','information_schema','auth','storage','realtime','extensions','public')
          AND n_live_tup = 0
    """)
    empty = cur.fetchone()[0]
    logger.info(f"\n  Empty tables remaining: {empty}")

    conn.close()
    logger.info(f"\n=== Complete: {grand_total} total rows ===")


if __name__ == "__main__":
    main()
