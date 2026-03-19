#!/usr/bin/env python3
"""
Map all 2,009 datasets to governance domains and collections (Option C).
Updates the data_marketplace database with new governance columns.
Outputs config/governance_mapping.json for Purview/OpenMetadata integration.
"""

import os
import json
import psycopg2
import logging
from collections import defaultdict

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ─── DOMAIN MAPPING (Option C: Business-oriented) ───────────────────────────

# data_domain → governance_domain
DOMAIN_MAP = {
    "Client": "Customer Management",
    "Customer": "Customer Management",
    "Product": "Products & Contracts",
    "Risk management": "Risk & Compliance",
    "Collateral": "Collateral & Assets",
    "Finance": "Finance & Reporting",
    "Employee": "People & Organization",
    "Partner": "People & Organization",
    "IT": "Technology & Data",
}

# data_subdomain → governance_subdomain
SUBDOMAIN_MAP = {
    # Customer Management
    "CRM": "Customer Relationship",
    "Entity": "Customer Onboarding",
    "Retail": "Customer Analytics",
    "Contact Details": "Customer Relationship",
    "Personal": "Customer Analytics",
    "Account": "Customer Onboarding",

    # Products & Contracts
    "Financial": "Financial Products",
    "Lease": "Leasing Products",
    "Loans": "Lending Products",
    "Laons": "Lending Products",  # typo in metadata
    "Payments": "Payment Products",
    "Payment Schedule": "Payment Products",
    "Cash": "Payment Products",
    "Savings": "Savings & Deposits",
    "Trade Finance": "Trade Finance",
    "Investements": "Investment Products",
    "Asset Allocation": "Investment Products",
    "Global Markets": "Trading & Treasury",
    "Settlement": "Payment Products",

    # Risk & Compliance
    "Non-financial": "Operational Risk",
    "Counterparty": "Credit Risk",

    # Collateral & Assets
    "Real Estate": "Real Estate",
    "Maintenance and Insurance": "Asset Insurance",

    # Finance & Reporting
    "Reference data": "Reference Data",
    "Location data": "Reference Data",
    "Structure": "Organizational Structure",

    # People & Organization
    "Organisations": "Organizational Structure",
    "Roles and Responsibilities": "HR & Workforce",
    "Employee Information": "HR & Workforce",
    "Pensions": "HR & Workforce",
    "Insurances": "Insurance Operations",

    # Technology & Data
    "Data": "Data Engineering",
    "Apps & APIs": "Digital Channels",
    "apps": "Digital Channels",
}

# business_line → governance_collection
COLLECTION_MAP = {
    "Leasing": "Leasing BL",
    "Commercial Finance": "Commercial Finance BL",
    "Mobility Solutions": "Mobility Solutions BL",
    "Consumer Finance": "Consumer Finance BL",
    "Innovation & Technology": "Innovation & Technology",
    "Finance office": "Corporate Functions / Finance Office",
    "Risk Management": "Corporate Functions / Risk Office",
    "Risk management": "Corporate Functions / Risk Office",
    "Human Resource office": "Corporate Functions / HR Office",
    "Legal and Compliance office": "Corporate Functions / Legal & Compliance",
    "Environmental Social Governance": "Corporate Functions / ESG",
}

# business_entity → governance_sub_collection
SUB_COLLECTION_MAP = {
    "Masreph": "Masreph Group",
    "Europe": "Europe",
    "AsiaPac": "Asia Pacific",
    "Corporate": "Corporate",
    "Centralized RDM": "Shared Services",
    "Asset-Based Lending": "Asset-Based Lending",
    "America": "Americas",
    "Americas": "Americas",
    "Masreph Nederland": "Netherlands",
    "Mortgage Lending": "Mortgage Lending",
    "Vehicle Leasing": "Vehicle Leasing",
    "Mobility Infrastructure Financing": "Mobility Infrastructure",
    "Personal Loans": "Personal Loans",
    "Customer portfolio management": "Customer Portfolio",
    "Third settlement party": "Third Party Settlement",
    "Wen Masreph": "Wen Masreph",
    "Property Finance": "Property Finance",
    "Insurance": "Insurance",
    "Personal Loans MY": "Personal Loans MY",
    "Call center": "Call Center",
    "Advisory & consultancy": "Advisory",
    "Customer relationship management": "CRM Operations",
    "Household finance": "Household Finance",
    "Credit Cards": "Credit Cards",
    "Import export financing": "Trade Finance",
    "Life Insurance": "Life Insurance",
    "ORIC": "ORIC",
    "Cash reserve": "Cash Reserve",
    "Customer Screening": "Customer Screening",
}


def get_governance_domain(data_domain):
    return DOMAIN_MAP.get(data_domain, "Technology & Data")


def get_governance_subdomain(data_domain, data_subdomain):
    if data_subdomain and data_subdomain in SUBDOMAIN_MAP:
        return SUBDOMAIN_MAP[data_subdomain]

    # Fallback based on domain
    defaults = {
        "Customer Management": "Customer Analytics",
        "Products & Contracts": "Financial Products",
        "Risk & Compliance": "Risk Analytics",
        "Collateral & Assets": "Asset Management",
        "Finance & Reporting": "Financial Reporting",
        "People & Organization": "Organizational Management",
        "Technology & Data": "Digital Channels",
    }
    gov_domain = get_governance_domain(data_domain)
    return defaults.get(gov_domain, "General")


def get_governance_collection(business_line):
    if business_line and business_line in COLLECTION_MAP:
        return COLLECTION_MAP[business_line]
    return "Shared Services"


def get_governance_sub_collection(business_entity):
    if business_entity and business_entity in SUB_COLLECTION_MAP:
        return SUB_COLLECTION_MAP[business_entity]
    if business_entity:
        return business_entity
    return "Masreph Group"


def main():
    logger.info("=== Mapping Governance Domains & Collections ===")

    # Connect to local data_marketplace
    conn = psycopg2.connect(host="localhost", port=5432, database="data_marketplace",
        user="postgres", password="os.getenv('LOCAL_PG_PASSWORD')")
    cur = conn.cursor()

    # Add governance columns if not exist
    for col in ["governance_domain", "governance_subdomain", "governance_collection", "governance_sub_collection"]:
        try:
            cur.execute(f"ALTER TABLE datasets ADD COLUMN {col} VARCHAR(100)")
            conn.commit()
            logger.info(f"  Added column: {col}")
        except:
            conn.rollback()

    # Fetch all datasets
    cur.execute("""
        SELECT id, name, data_domain, data_subdomain, business_line, business_entity
        FROM datasets ORDER BY id
    """)
    datasets = cur.fetchall()
    logger.info(f"  Found {len(datasets)} datasets")

    # Map and update
    domain_counts = defaultdict(int)
    subdomain_counts = defaultdict(int)
    collection_counts = defaultdict(int)

    for ds in datasets:
        ds_id, name, data_domain, data_subdomain, business_line, business_entity = ds

        gov_domain = get_governance_domain(data_domain)
        gov_subdomain = get_governance_subdomain(data_domain, data_subdomain)
        gov_collection = get_governance_collection(business_line)
        gov_sub_collection = get_governance_sub_collection(business_entity)

        cur.execute("""
            UPDATE datasets SET
                governance_domain = %s,
                governance_subdomain = %s,
                governance_collection = %s,
                governance_sub_collection = %s
            WHERE id = %s
        """, (gov_domain, gov_subdomain, gov_collection, gov_sub_collection, ds_id))

        domain_counts[gov_domain] += 1
        subdomain_counts[f"{gov_domain} / {gov_subdomain}"] += 1
        collection_counts[gov_collection] += 1

    conn.commit()
    logger.info(f"  Updated {len(datasets)} datasets")

    # Report
    logger.info("\n=== Governance Domains ===")
    for domain in sorted(domain_counts, key=domain_counts.get, reverse=True):
        logger.info(f"  {domain:30s}: {domain_counts[domain]} datasets")

    logger.info("\n=== Top Sub-domains ===")
    for sd in sorted(subdomain_counts, key=subdomain_counts.get, reverse=True)[:20]:
        logger.info(f"  {sd:50s}: {subdomain_counts[sd]}")

    logger.info("\n=== Collections ===")
    for coll in sorted(collection_counts, key=collection_counts.get, reverse=True):
        logger.info(f"  {coll:40s}: {collection_counts[coll]}")

    # Export governance mapping JSON
    cur.execute("""
        SELECT id, name, data_domain, data_subdomain, business_line, business_entity,
               governance_domain, governance_subdomain, governance_collection, governance_sub_collection,
               source_sys_name, data_classification, maturity, data_lifecycle
        FROM datasets ORDER BY governance_domain, governance_subdomain, id
    """)
    rows = cur.fetchall()
    cols = [desc[0] for desc in cur.description]

    mapping = {
        "total_datasets": len(rows),
        "domains": {},
        "collections": {},
        "datasets": [],
    }

    for row in rows:
        d = dict(zip(cols, row))
        mapping["datasets"].append(d)

        # Build domain structure
        dom = d["governance_domain"]
        sub = d["governance_subdomain"]
        if dom not in mapping["domains"]:
            mapping["domains"][dom] = {"subdomains": {}, "dataset_count": 0}
        mapping["domains"][dom]["dataset_count"] += 1
        if sub not in mapping["domains"][dom]["subdomains"]:
            mapping["domains"][dom]["subdomains"][sub] = 0
        mapping["domains"][dom]["subdomains"][sub] += 1

        # Build collection structure
        coll = d["governance_collection"]
        sub_coll = d["governance_sub_collection"]
        if coll not in mapping["collections"]:
            mapping["collections"][coll] = {"sub_collections": {}, "dataset_count": 0}
        mapping["collections"][coll]["dataset_count"] += 1
        if sub_coll not in mapping["collections"][coll]["sub_collections"]:
            mapping["collections"][coll]["sub_collections"][sub_coll] = 0
        mapping["collections"][coll]["sub_collections"][sub_coll] += 1

    output_path = os.path.join(os.path.dirname(__file__), "..", "config", "governance_mapping.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(mapping, f, indent=2, default=str)

    logger.info(f"\n  Saved governance mapping to {output_path}")

    # Also update Supabase (dmp-masreph)
    logger.info("\n=== Updating Supabase (dmp-masreph) ===")
    try:
        supa = psycopg2.connect(
            host="aws-1-eu-central-1.pooler.supabase.com", port=5432, database="postgres",
            user="postgres.ciuaictczdttuxytzhto", password="os.getenv('SUPABASE_CORE_PASSWORD')", connect_timeout=15)
        supa_cur = supa.cursor()

        for col in ["governance_domain", "governance_subdomain", "governance_collection", "governance_sub_collection"]:
            try:
                supa_cur.execute(f"ALTER TABLE datasets ADD COLUMN {col} VARCHAR(100)")
                supa.commit()
            except:
                supa.rollback()

        # Batch update
        cur.execute("SELECT id, governance_domain, governance_subdomain, governance_collection, governance_sub_collection FROM datasets")
        updates = cur.fetchall()

        for u in updates:
            supa_cur.execute("""
                UPDATE datasets SET
                    governance_domain = %s, governance_subdomain = %s,
                    governance_collection = %s, governance_sub_collection = %s
                WHERE id = %s
            """, (u[1], u[2], u[3], u[4], u[0]))

        supa.commit()
        logger.info(f"  Updated {len(updates)} datasets in Supabase")
        supa.close()
    except Exception as e:
        logger.error(f"  Supabase update failed: {e}")

    conn.close()
    logger.info("\n=== Governance Mapping Complete ===")


if __name__ == "__main__":
    main()
