#!/usr/bin/env python3
"""
Deploy MongoDB Atlas with one database per source system.
Cluster: MasrephAPI (Atlas M0 Free)

Architecture:
  masreph_redakt_asr      (database - 13 collections)
  masreph_redakt_tm       (database - 5 collections)
  masreph_mobility        (database - 4 collections)
  masreph_mdp_sourcing    (database - 3 collections)
  ... etc

MongoDB quality profile: 70-82% (API layer, 2 years old)
- Schema drift between documents
- Mixed types for same field
- Some documents missing fields
- Nested objects with inconsistent keys
"""

import os
import json
import random
import string
import logging
from datetime import datetime, date, timedelta
from pathlib import Path
from pymongo import MongoClient
from urllib.parse import quote_plus
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

SCHEMAS_DIR = os.path.join(os.path.dirname(__file__), "..", "schemas", "mongodb")

MONGO_USER = "hzmarrou"
MONGO_PASSWORD = "os.getenv('MONGODB_PASSWORD')"
MONGO_CLUSTER = "masrephapi.c2lbreb.mongodb.net"
DB_PREFIX = "masreph_"

Q_NULL = 0.05
Q_SCHEMA_DRIFT = 0.08  # 8% of docs have missing/extra fields
Q_MIXED_TYPE = 0.04  # 4% of numeric fields stored as strings

FIRST_NAMES = ["Jan","Pieter","Maria","Sophie","Lars","Anna","Thomas","Eva","Daan","Emma",
    "Bram","Lisa","Lucas","Julia","Sven","Nina","Mark","Lotte","Ahmed","Fatima",
    "James","Sarah","Robert","Emily","Carlos","Isabella","Hans","Greta","Pedro","Ana"]
LAST_NAMES = ["van den Berg","de Jong","Jansen","de Vries","van Dijk","Bakker","Visser",
    "Smit","Meijer","de Boer","Muller","Schmidt","Schneider","Smith","Johnson",
    "Williams","Brown","Garcia","Martinez","Chen","Wang","Patel","Sharma","Dubois"]
COUNTRIES = ["NL","DE","FR","GB","US","BE","CH","AT","ES","IT","JP","SG","AU"]
CURRENCIES = ["EUR","USD","GBP","CHF","JPY","SGD"]
STATUSES = ["active","inactive","pending","suspended","closed"]
RISK_LEVELS = ["low","medium","high","critical"]
CHANNELS = ["webPortal","mobileApp","branch","phone","email","api","chatbot"]
SEGMENTS = ["massMarket","affluent","highNetWorth","sme","midCorporate"]


def get_client():
    password = quote_plus(MONGO_PASSWORD)
    uri = f"mongodb+srv://{MONGO_USER}:{password}@{MONGO_CLUSTER}/?appName=MasrephAPI"
    import certifi
    return MongoClient(uri, tlsAllowInvalidCertificates=True, tls=True, tlsCAFile=certifi.where(),
                       serverSelectionTimeoutMS=30000)


def gen_document(fields, row_idx):
    """Generate a MongoDB document with quality issues."""
    doc = {}

    for field_name, field_type in fields:
        name = field_name.lower()

        # Quality: skip some fields for schema drift
        if random.random() < Q_SCHEMA_DRIFT and "id" not in name:
            continue

        # Quality: random nulls
        if random.random() < Q_NULL and "id" not in name:
            doc[field_name] = None
            continue

        val = gen_mongo_value(name, field_type, row_idx)

        # Quality: mixed types (store number as string sometimes)
        if Q_MIXED_TYPE > random.random() and isinstance(val, (int, float)):
            val = str(val)

        doc[field_name] = val

    # Quality: occasionally add unexpected fields (schema drift)
    if random.random() < Q_SCHEMA_DRIFT:
        doc["_legacyField"] = f"legacy_{random.randint(100,999)}"
    if random.random() < Q_SCHEMA_DRIFT:
        doc["_importBatchId"] = random.randint(1000, 9999)

    return doc


def gen_mongo_value(name, field_type, row_idx):
    ftype = field_type.lower() if field_type else "string"

    if ftype == "date":
        return datetime(2023,1,1) + timedelta(days=random.randint(0,1100), hours=random.randint(0,23))
    if ftype in ("int", "number"):
        if "age" in name: return random.randint(18, 78)
        if "count" in name or "num" in name: return random.randint(0, 1000)
        if "score" in name: return random.randint(0, 100)
        return random.randint(1, 9999)
    if ftype == "double":
        if any(k in name for k in ["amount","balance","value","revenue","cost","fee"]):
            return round(random.uniform(500, 2000000), 2)
        if any(k in name for k in ["rate","margin","pct","ratio"]):
            return round(random.uniform(0, 100), 4)
        if "score" in name: return round(random.uniform(0, 100), 2)
        return round(random.uniform(0, 99999), 2)
    if ftype == "bool":
        if "active" in name: return random.random() < 0.85
        if "consent" in name: return random.random() < 0.70
        if "flag" in name and "risk" in name: return random.random() < 0.03
        return random.choice([True, False])
    if ftype == "array":
        return random.sample(["finance","risk","compliance","retail","premium","vip","leasing"], k=random.randint(1,4))
    if ftype == "object":
        if "address" in name:
            return {"street": f"{random.randint(1,500)} Keizersgracht", "city": random.choice(["Amsterdam","Rotterdam","Berlin"]), "country": random.choice(COUNTRIES), "postalCode": f"{random.randint(1000,9999)}AB"}
        if "meta" in name:
            return {"source": random.choice(["api","webhook","batch"]), "version": f"{random.randint(1,3)}.{random.randint(0,9)}"}
        return {"key": f"value_{random.randint(1,999)}"}

    # String
    if "name" in name and "file" not in name:
        fn = random.choice(FIRST_NAMES)
        ln = random.choice(LAST_NAMES)
        if "first" in name: return fn
        if "last" in name: return ln
        return f"{fn} {ln}"
    if "email" in name:
        return f"{random.choice(FIRST_NAMES).lower()}.{random.choice(LAST_NAMES).lower().replace(' ','')}@masreph.com"
    if "phone" in name:
        return f"+{random.choice(['31','49','33','44','1'])} {random.randint(600000000,699999999)}"
    if "country" in name: return random.choice(COUNTRIES)
    if "currency" in name: return random.choice(CURRENCIES)
    if "status" in name: return random.choice(STATUSES)
    if "risk" in name and ("level" in name or "rating" in name): return random.choice(RISK_LEVELS)
    if "channel" in name: return random.choice(CHANNELS)
    if "segment" in name: return random.choice(SEGMENTS)
    if "type" in name: return random.choice(["standard","premium","basic","enterprise"])
    if name.endswith("id") or "identifier" in name:
        return f"{''.join(random.choices(string.ascii_lowercase + string.digits, k=24))}"
    if any(k in name for k in ["description","comment","note","summary","content","text"]):
        return random.choice(["API interaction log entry", "Webhook event payload", "Customer profile update", "Risk assessment result"])
    return f"val_{random.randint(1000,9999)}"


def determine_rows(collection_name):
    name = collection_name.lower()
    if any(k in name for k in ["event","log","interaction","message","session","transaction"]):
        return random.randint(500, 1000)
    if any(k in name for k in ["customer","client","profile","user","contact"]):
        return random.randint(200, 500)
    if any(k in name for k in ["config","setting","type","status","category"]):
        return random.randint(15, 50)
    return random.randint(100, 300)


def main():
    logger.info("=== MongoDB: One Database Per Source System ===")

    json_files = sorted(Path(SCHEMAS_DIR).glob("*.json"))
    logger.info(f"Found {len(json_files)} schema files")

    try:
        client = get_client()
        # Test connection
        client.admin.command('ping')
        logger.info("Connected to MongoDB Atlas!")
    except Exception as e:
        logger.error(f"Cannot connect to MongoDB: {e}")
        logger.info("Skipping MongoDB deployment due to connection issues")
        return

    grand_total = 0

    for filepath in json_files:
        fname = filepath.stem
        db_name = DB_PREFIX + fname

        with open(filepath, "r", encoding="utf-8") as f:
            schemas = json.load(f)

        if not schemas:
            continue

        db = client[db_name]

        # Drop existing collections
        for coll_name in db.list_collection_names():
            db[coll_name].drop()

        db_total = 0
        for schema in schemas:
            if isinstance(schema, dict) and "error" not in schema:
                coll_name = schema.get("collection", f"collection_{random.randint(1000,9999)}")
                validator = schema.get("validator", {})
                props = validator.get("$jsonSchema", {}).get("properties", {})

                # Extract field info
                fields = []
                for field_name, field_info in props.items():
                    field_type = field_info.get("bsonType", "string")
                    fields.append((field_name, field_type))

                if not fields:
                    continue

                num_rows = determine_rows(coll_name)

                # Generate documents
                docs = [gen_document(fields, i) for i in range(num_rows)]

                # Insert
                try:
                    coll = db[coll_name]
                    coll.insert_many(docs)
                    db_total += len(docs)
                except Exception as e:
                    logger.warning(f"  Error inserting {db_name}.{coll_name}: {str(e)[:80]}")

        if db_total > 0:
            grand_total += db_total
            logger.info(f"  {db_name}: {len(schemas)} collections, {db_total} rows")

    client.close()
    logger.info(f"\n=== DONE: {grand_total} total documents ===")


if __name__ == "__main__":
    main()
