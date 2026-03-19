#!/usr/bin/env python3
"""
Select ~300 datasets from the 2,009 in the metadata catalog.
Selection is driven by governance scenarios, not random.

Output: config/selected_datasets.json
"""

import os
import json
import psycopg2
import logging
from collections import defaultdict
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# Load platform assignments
with open(os.path.join(os.path.dirname(__file__), "..", "config", "platform_assignment.json")) as f:
    PLATFORM_ASSIGNMENTS = json.load(f)


def get_connection():
    return psycopg2.connect(host="localhost", port=5432, database="data_marketplace",
                            user="postgres", password="os.getenv('LOCAL_PG_PASSWORD')")


def score_dataset(ds_id, elements, domain, source_sys, lifecycle, maturity, num_elements):
    """Score a dataset for selection priority. Higher = better candidate."""
    score = 0

    # Element richness
    element_names = [e["name"].lower() for e in elements]

    # Cross-entity elements (most valuable for governance scenarios)
    customer_elements = sum(1 for n in element_names if "customer" in n or "client" in n or "borrower" in n or "lessee" in n)
    product_elements = sum(1 for n in element_names if "product" in n)
    contract_elements = sum(1 for n in element_names if "contract" in n or "lease" in n or "agreement" in n or "loan" in n)
    financial_elements = sum(1 for n in element_names if "amount" in n or "balance" in n or "revenue" in n or "exposure" in n or "principal" in n)
    pii_elements = sum(1 for n in element_names if "email" in n or "phone" in n or "iban" in n or "birth" in n or "gender" in n or "address" in n)
    risk_elements = sum(1 for n in element_names if "risk" in n or "score" in n or "rating" in n or "default" in n or "delinquen" in n)
    compliance_elements = sum(1 for n in element_names if "gdpr" in n or "consent" in n or "kyc" in n or "sanction" in n or "pep" in n)

    # Scenario support scores
    if customer_elements > 0: score += 10  # Cross-system search (#2), GDPR (#8)
    if customer_elements > 3: score += 10  # Rich customer dataset
    if pii_elements > 0: score += 15  # PII detection (#4), GDPR (#8)
    if pii_elements > 2: score += 10  # Multiple PII fields
    if financial_elements > 0: score += 8  # Quality mismatch (#5)
    if financial_elements > 3: score += 8  # Rich financial dataset
    if risk_elements > 0: score += 8  # Risk scenarios
    if compliance_elements > 0: score += 12  # Compliance scenarios (#8, #15)
    if contract_elements > 0: score += 6  # Lineage (#6)
    if product_elements > 0: score += 5  # Product catalog scenarios

    # Multiple entity types (cross-domain linking)
    entity_types = sum([
        1 if customer_elements > 0 else 0,
        1 if product_elements > 0 else 0,
        1 if contract_elements > 0 else 0,
        1 if financial_elements > 0 else 0,
    ])
    if entity_types >= 3: score += 20  # Multi-entity datasets are gold
    if entity_types >= 2: score += 10

    # Element count (more columns = more realistic table)
    if num_elements >= 30: score += 5
    if num_elements >= 40: score += 5

    # Metadata completeness
    if lifecycle == "Active": score += 5
    if maturity == "Prepared for distribution": score += 5

    # Domain bonuses (underrepresented domains need boosting)
    domain_bonus = {
        "Employee": 20,  # Very few, need all of them
        "Finance": 15,   # Few, need more
        "Customer": 15,  # Very few
        "Collateral": 8,
        "IT": 5,
        "Partner": 5,
    }
    score += domain_bonus.get(domain, 0)

    return score, {
        "customer": customer_elements,
        "product": product_elements,
        "contract": contract_elements,
        "financial": financial_elements,
        "pii": pii_elements,
        "risk": risk_elements,
        "compliance": compliance_elements,
        "entity_types": entity_types,
    }


def select_datasets():
    conn = get_connection()
    cur = conn.cursor()

    # Fetch all datasets with their elements
    logger.info("Loading all datasets and elements...")
    cur.execute("""
        SELECT d.id, d.name, d.data_domain, d.data_subdomain, d.source_sys_name,
               d.business_line, d.business_entity, d.data_lifecycle, d.maturity,
               d.number_of_data_elements, d.data_classification
        FROM datasets d
        ORDER BY d.id
    """)
    datasets = {}
    for r in cur.fetchall():
        datasets[r[0]] = {
            "id": r[0], "name": r[1], "domain": r[2], "subdomain": r[3],
            "source_sys": r[4], "business_line": r[5], "business_entity": r[6],
            "lifecycle": r[7], "maturity": r[8], "num_elements": r[9],
            "classification": r[10],
        }

    # Fetch all elements
    cur.execute("SELECT dataset_id, name, data_type, nullable FROM data_elements ORDER BY dataset_id")
    elements_by_ds = defaultdict(list)
    for r in cur.fetchall():
        elements_by_ds[r[0]].append({"name": r[1], "type": r[2], "nullable": r[3]})

    logger.info(f"Loaded {len(datasets)} datasets, {sum(len(v) for v in elements_by_ds.values())} elements")

    # Score every dataset
    scored = []
    for ds_id, ds in datasets.items():
        elements = elements_by_ds.get(ds_id, [])
        platform = PLATFORM_ASSIGNMENTS.get(ds_id, {}).get("platform", "unknown")
        score, entity_counts = score_dataset(
            ds_id, elements, ds["domain"], ds["source_sys"],
            ds["lifecycle"], ds["maturity"], ds["num_elements"]
        )
        scored.append({
            **ds,
            "platform": platform,
            "score": score,
            "entities": entity_counts,
            "element_count": len(elements),
        })

    scored.sort(key=lambda x: x["score"], reverse=True)

    # Selection algorithm
    selected = []
    selected_ids = set()

    # Track coverage
    platform_counts = defaultdict(int)
    domain_counts = defaultdict(int)
    source_sys_counts = defaultdict(int)

    # Platform targets
    platform_targets = {
        "sql-server": 80, "postgresql": 50, "snowflake": 50,
        "mysql": 30, "databricks": 30, "fabric": 25,
        "oracle": 20, "mongodb": 15,
    }

    # Pass 1: Must-have datasets (highest scores, ensure platform coverage)
    logger.info("\nPass 1: Top-scored datasets per platform...")
    for platform, target in platform_targets.items():
        platform_candidates = [s for s in scored if s["platform"] == platform and s["id"] not in selected_ids]
        # Take top candidates for this platform
        take = min(target, len(platform_candidates))
        for candidate in platform_candidates[:take]:
            selected.append(candidate)
            selected_ids.add(candidate["id"])
            platform_counts[platform] += 1
            domain_counts[candidate["domain"]] += 1
            source_sys_counts[candidate["source_sys"]] += 1

    logger.info(f"After pass 1: {len(selected)} datasets selected")

    # Pass 2: Fill domain gaps
    logger.info("\nPass 2: Fill domain gaps...")
    domain_minimums = {
        "Client": 60, "Product": 60, "Risk management": 50,
        "Collateral": 25, "IT": 20, "Partner": 20,
        "Finance": 15, "Employee": 15, "Customer": 5,
    }
    for domain, minimum in domain_minimums.items():
        if domain_counts[domain] < minimum:
            gap = minimum - domain_counts[domain]
            candidates = [s for s in scored if s["domain"] == domain and s["id"] not in selected_ids]
            for candidate in candidates[:gap]:
                selected.append(candidate)
                selected_ids.add(candidate["id"])
                platform_counts[candidate["platform"]] += 1
                domain_counts[domain] += 1

    logger.info(f"After pass 2: {len(selected)} datasets selected")

    # Trim to ~300 if over
    if len(selected) > 320:
        # Remove lowest-scored datasets from over-represented platforms
        selected.sort(key=lambda x: x["score"])
        while len(selected) > 300:
            candidate = selected[0]
            platform = candidate["platform"]
            if platform_counts[platform] > platform_targets.get(platform, 20):
                selected.pop(0)
                platform_counts[platform] -= 1
                domain_counts[candidate["domain"]] -= 1
            else:
                break
        selected.sort(key=lambda x: x["score"], reverse=True)

    # Summary
    logger.info(f"\n=== SELECTION COMPLETE: {len(selected)} datasets ===")
    logger.info("\nBy platform:")
    for p in sorted(platform_counts, key=platform_counts.get, reverse=True):
        logger.info(f"  {p:15s}: {platform_counts[p]}")

    logger.info("\nBy domain:")
    for d in sorted(domain_counts, key=domain_counts.get, reverse=True):
        logger.info(f"  {d:20s}: {domain_counts[d]}")

    # Source systems used (this determines schema/database names)
    used_sources = defaultdict(lambda: defaultdict(list))
    for s in selected:
        used_sources[s["platform"]][s["source_sys"]].append(s["id"])

    logger.info("\nBy platform -> source system (= schema/database):")
    total_schemas = 0
    for platform in sorted(used_sources):
        sources = used_sources[platform]
        logger.info(f"\n  {platform} ({len(sources)} schemas/databases):")
        for src in sorted(sources, key=lambda x: len(sources[x]), reverse=True):
            logger.info(f"    {str(src or 'Unknown'):40s}: {len(sources[src])} datasets")
        total_schemas += len(sources)

    logger.info(f"\nTotal schemas/databases: {total_schemas}")

    # Entity coverage
    total_customer = sum(1 for s in selected if s["entities"]["customer"] > 0)
    total_pii = sum(1 for s in selected if s["entities"]["pii"] > 0)
    total_financial = sum(1 for s in selected if s["entities"]["financial"] > 0)
    total_risk = sum(1 for s in selected if s["entities"]["risk"] > 0)
    total_compliance = sum(1 for s in selected if s["entities"]["compliance"] > 0)
    total_multi = sum(1 for s in selected if s["entities"]["entity_types"] >= 3)

    logger.info(f"\nEntity coverage:")
    logger.info(f"  With customer elements:   {total_customer}")
    logger.info(f"  With PII elements:        {total_pii}")
    logger.info(f"  With financial elements:  {total_financial}")
    logger.info(f"  With risk elements:       {total_risk}")
    logger.info(f"  With compliance elements: {total_compliance}")
    logger.info(f"  Multi-entity (3+ types):  {total_multi}")

    # Save selection
    output = {
        "selection_criteria": "Governance-scenario-driven selection",
        "total_selected": len(selected),
        "total_available": len(datasets),
        "platform_distribution": dict(platform_counts),
        "domain_distribution": dict(domain_counts),
        "datasets": [
            {
                "id": s["id"],
                "name": s["name"],
                "domain": s["domain"],
                "subdomain": s["subdomain"],
                "source_sys": s["source_sys"],
                "platform": s["platform"],
                "business_line": s["business_line"],
                "business_entity": s["business_entity"],
                "classification": s["classification"],
                "element_count": s["element_count"],
                "score": s["score"],
                "entities": s["entities"],
            }
            for s in selected
        ],
        "platform_schemas": {
            platform: {
                src: ds_ids for src, ds_ids in sources.items()
            }
            for platform, sources in used_sources.items()
        },
    }

    output_path = os.path.join(os.path.dirname(__file__), "..", "config", "selected_datasets.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2)
    logger.info(f"\nSaved to {output_path}")

    conn.close()
    return output


if __name__ == "__main__":
    select_datasets()
