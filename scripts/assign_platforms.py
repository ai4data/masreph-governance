#!/usr/bin/env python3
"""
Assign each dataset to a target database platform based on source system,
domain, business line, and lifecycle metadata.

Output: config/platform_assignment.json
"""

import os
import json
import psycopg2
import logging
from pathlib import Path
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", ".env"))

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

# ─── ASSIGNMENT RULES ───────────────────────────────────────────────────────

# Rule 1: Source system → platform (highest priority)
# Based on what technology the source system realistically runs on
SOURCE_SYSTEM_MAP = {
    # SQL Server — core banking, transactions, payments, lending
    "TransactFinance": "sql-server",
    "Finflux-Credit": "sql-server",
    "Core payment operations": "sql-server",
    "SEPA Mandate Verification": "sql-server",
    "Calypso X": "sql-server",
    "Calypso XI": "sql-server",
    "Trade Finance Transactions store": "sql-server",
    "RealEstate SQL server": "sql-server",
    "Financial Transaction Manager": "sql-server",
    "Montran": "sql-server",
    "Standing order Limox": "sql-server",
    "Cross border payment operations": "sql-server",
    "Modern Core Payments": "sql-server",
    "Streamline Payments": "sql-server",
    "EBA Clearing": "sql-server",
    "ATM Transaction": "sql-server",
    "Transactions Service Device": "sql-server",
    "DFM store": "sql-server",
    "Guarantee store": "sql-server",
    "Tessi savings solution": "sql-server",
    "AFAD finance store": "sql-server",
    "Wen Masreph store": "sql-server",
    "Masreph Prodcut & Contract Registry": "sql-server",
    "Credit finance service": "sql-server",
    "Finance Network service": "sql-server",
    "Inter-finance messages system": "sql-server",
    "Compliance Transaction Service": "sql-server",
    "FinHub": "sql-server",
    "AssetView Finance": "sql-server",
    "FinanceProspectID": "sql-server",
    "Appello": "sql-server",
    "MXFIX": "sql-server",
    "Account Limit Tracker": "sql-server",
    "PaymentTracker": "sql-server",
    "Interest Finance": "sql-server",
    "Account Number": "sql-server",
    "Secure Finance": "sql-server",
    "CCOSM": "sql-server",
    "LCM Services": "sql-server",
    "Credit Analytics Hub": "sql-server",
    "Finance Advisor Network System": "sql-server",
    "Digital Finance Messages": "sql-server",
    "Savings": "sql-server",
    "Investment Income": "sql-server",
    "PortfolioPlus": "sql-server",
    "Financial Immediate Transaction Manager": "sql-server",
    "Nostro": "sql-server",
    "Payment Store": "sql-server",
    "Global Finance Rates": "sql-server",
    "Interest Product": "sql-server",
    "TSFC store": "sql-server",
    "Mortgage Finance Calculator": "sql-server",
    "InvestmentFlow": "sql-server",
    "T-Ransact": "sql-server",
    "Finance Instrument Data Set (FIDS)": "sql-server",
    "FinNavigator store": "sql-server",
    "Credit Data Finance": "sql-server",
    "Client Finance IBAN List": "sql-server",
    "Finance Call Records": "sql-server",
    "CurrencyXchanger": "sql-server",
    "Investement Store": "sql-server",
    "FinanceFlow Payment": "sql-server",
    "Golden Index Finance (GFI)": "sql-server",
    "CCStore": "sql-server",
    "Investment Service Fees": "sql-server",
    "Sprada": "sql-server",
    "SQL server": "sql-server",
    "Dispute": "sql-server",
    "Global Finance Incentives": "sql-server",
    "Credit swap": "sql-server",
    "Mortgage Rates": "sql-server",
    "Finance Tracker": "sql-server",
    "FinanceOps Master": "sql-server",
    "Delinquency Index store": "sql-server",
    "ECBPI": "sql-server",
    "InsureData Finance Catalog": "sql-server",
    "InsureData Finance": "sql-server",
    "InsureData Finance Hub": "sql-server",
    "Global Workforce Finance service": "sql-server",
    "Financial Information Repository": "sql-server",
    "Credit Score Application": "sql-server",
    "Contract Mortgage Management": "sql-server",
    "Finance360 Customer Insights": "sql-server",
    "Risk Finance Insight": "sql-server",
    "Non-Real Estate Collateral Data": "sql-server",
    "Mortgage risk finance sys": "sql-server",
    "Finance Recovery Insights store": "sql-server",
    "RiskWatch Finance": "sql-server",
    "Finance App Insights": "sql-server",
    "PFRA Systems": "sql-server",
    "SSFA": "sql-server",
    "Finance Case Profile": "sql-server",
    "FinanceScan": "sql-server",
    "FinanceScan Results Store": "sql-server",
    "Finance Onboarding App": "sql-server",
    "Finance Risk Events Dataset": "sql-server",
    "Fraud Finance Detection service": "sql-server",
    "FA Index services": "sql-server",
    "Credit MDP": "sql-server",

    # PostgreSQL — modern apps, CRM, customer, MDM
    "PostgreSQL Global Credit Store": "postgresql",
    "Salesforce-Customer Insights": "postgresql",
    "Microsoft Dynamics 365": "postgresql",
    "Core contact repository": "postgresql",
    "InfoSphere MDM": "postgresql",
    "Customer Care": "postgresql",
    "SF-CRM A": "postgresql",
    "SF-CRM SC": "postgresql",
    "SF-CRM": "postgresql",
    "CMI Sales": "postgresql",
    "CMI services": "postgresql",
    "CMI Orientation": "postgresql",
    "Profile app": "postgresql",
    "Finance Interactions System": "postgresql",
    "Connect": "postgresql",
    "Alvaria": "postgresql",
    "Contact services": "postgresql",
    "Interaction Insights": "postgresql",
    "Service Link": "postgresql",
    "Retail Interaction Analytics": "postgresql",
    "Customer ChatBot": "postgresql",
    "Retail Foot Traffic": "postgresql",
    "Finance Insight Surveys": "postgresql",

    # MySQL — digital, web, mobile, small apps
    "Web Mobile Message Store": "mysql",
    "Email Analytics": "mysql",
    "SendGrid": "mysql",
    "Digital Payment Tokens": "mysql",
    "Startsida": "mysql",
    "Epos Now": "mysql",
    "ADSL": "mysql",
    "MicroAcquire": "mysql",
    "WATI": "mysql",
    "PandaDoc": "mysql",
    "ProcessMaker": "mysql",
    "Zoho": "mysql",
    "DuoCircle": "mysql",
    "MS Office": "mysql",
    "Citrix ShareFile": "mysql",
    "DocuVerify": "mysql",
    "Whispe speech recognition": "mysql",
    "American Office Systems": "mysql",
    "Workflow Insights": "mysql",
    "marketing DWH": "mysql",

    # Snowflake — risk, compliance, screening, analytics
    "Sanction Scanner": "snowflake",
    "RiskConnect": "snowflake",
    "Veriff": "snowflake",
    "Trulioo": "snowflake",
    "Trulioo NL": "snowflake",
    "ACTICO": "snowflake",
    "Endorsement Evaluatio Application": "snowflake",
    "Refinitiv World-Check": "snowflake",
    "Jumio Risk Signals": "snowflake",
    "Credit Risk Controls": "snowflake",
    "Credit Risk Insights": "snowflake",
    "CRC Systems": "snowflake",
    "Domo GRC": "snowflake",
    "EuroComply": "snowflake",
    "Compliance Archive": "snowflake",
    "Eco-Finance Ratings": "snowflake",
    "ESRB ratings": "snowflake",
    "Asset Rating": "snowflake",
    "Sentinels": "snowflake",
    "SecurityScorecard": "snowflake",
    "RiskScan": "snowflake",
    "GFID": "snowflake",
    "Raccent": "snowflake",

    # Databricks — data lake, events, ML, archival
    "Mosaic Tech": "databricks",
    "EventStream": "databricks",
    "MemVerge": "databricks",
    "AlleVue": "databricks",
    "Card Management Events": "databricks",
    "IDS I": "databricks",
    "IDS II": "databricks",
    "IDS III": "databricks",
    "DDED": "databricks",
    "DSRD": "databricks",
    "Famal DW": "databricks",
    "Famal CC AI": "databricks",
    "PIOCO": "databricks",
    "MXEDR": "databricks",
    "MXINDEPENDENT": "databricks",
    "MXWORKLOAD": "databricks",
    "MXDQ": "databricks",
    "MXCO": "databricks",

    # Microsoft Fabric — corporate analytics, BI, governance
    "Dataedo CRDM": "fabric",
    "SharePoint": "fabric",
    "Sharepoint GPAA": "fabric",
    "Sharepoint GT": "fabric",
    "Confluence": "fabric",
    "BlueDolphin": "fabric",
    "HR workforce store": "fabric",
    "Talent Pool": "fabric",
    "Interflex": "fabric",
    "GlossBook": "fabric",
    "BMC": "fabric",
    "Azure DevOps": "fabric",
    "Okta": "fabric",
    "SailPoint Tech": "fabric",
    "Beyondtrust": "fabric",
    "Qualys": "fabric",
    "Prometheus": "fabric",
    "HOC": "fabric",

    # Oracle — legacy ERP, insurance, lease contracts
    "ECD Oracle": "oracle",
    "EPR Oracle": "oracle",
    "SAP Finance": "oracle",
    "Oracle": "oracle",
    "OmniConnect-Trade": "oracle",
    "Coupa SCM": "oracle",
    "Coupa P2P": "oracle",
    "NetSuite": "oracle",
    "Real Estate Management (REM)": "oracle",
    "RealEstate Store": "oracle",
    "Life insurance": "oracle",
    "Estate": "oracle",
    "Ship Protection": "oracle",
    "Peritam": "oracle",
    "Board of trade": "oracle",
    "CROR": "oracle",
    "ICNL": "oracle",
    "Tapix": "oracle",
    "Twikey": "oracle",
    "Solar": "oracle",
    "NamSys": "oracle",
    "GovPilot": "oracle",
    "Ironclad": "oracle",
    "Ironclad-digital": "oracle",
    "Corporate Registry Ownership": "oracle",
    "Personal Information Retrieval and Archival": "oracle",
    "Facilities Management": "oracle",

    # MongoDB — API, events, semi-structured
    "Redakt ASR": "mongodb",
    "Redakt TM": "mongodb",
    "Redakt DE": "mongodb",
    "App data hub": "mongodb",
    "Masreph app registry": "mongodb",
    "MDP Global Sourcing": "mongodb",
    "MDP Global Storage on-prem": "mongodb",
    "MDP Global API": "mongodb",
    "CDD API": "mongodb",
    "Data contracts app": "mongodb",
    "Mobility segments": "mongodb",
    "Block Relations": "mongodb",
    "Rundit": "mongodb",
}

# Rule 2: Domain → default platform (fallback when source system not mapped)
DOMAIN_DEFAULT_MAP = {
    "Product": "sql-server",
    "Client": "postgresql",
    "Risk management": "snowflake",
    "Collateral": "sql-server",
    "IT": "mysql",
    "Partner": "postgresql",
    "Finance": "fabric",
    "Employee": "fabric",
    "Customer": "postgresql",
}

# Rule 3: Business line → platform (secondary fallback)
BUSINESS_LINE_MAP = {
    "Leasing": "sql-server",
    "Commercial Finance": "sql-server",
    "Mobility Solutions": "postgresql",
    "Consumer Finance": "postgresql",
    "Innovation & Technology": "mysql",
    "Finance office": "fabric",
    "Risk Management": "snowflake",
    "Human Resource office": "fabric",
    "Legal and Compliance office": "snowflake",
    "Environmental Social Governance": "snowflake",
}

# Rule 4: Override — retired datasets go to Databricks (data lake archive)
LIFECYCLE_OVERRIDE = {
    "Retired": "databricks",
}


def assign_platform(dataset):
    """Assign a dataset to a platform using the rule hierarchy."""
    source_sys = dataset.get("source_sys_name", "")
    domain = dataset.get("data_domain", "")
    business_line = dataset.get("business_line", "")
    lifecycle = dataset.get("data_lifecycle", "")

    # Rule 4: Lifecycle override (retired → Databricks)
    if lifecycle in LIFECYCLE_OVERRIDE:
        return LIFECYCLE_OVERRIDE[lifecycle], "lifecycle"

    # Rule 1: Source system (highest priority)
    if source_sys in SOURCE_SYSTEM_MAP:
        return SOURCE_SYSTEM_MAP[source_sys], "source_system"

    # Rule 2: Domain fallback
    if domain in DOMAIN_DEFAULT_MAP:
        return DOMAIN_DEFAULT_MAP[domain], "domain"

    # Rule 3: Business line fallback
    if business_line in BUSINESS_LINE_MAP:
        return BUSINESS_LINE_MAP[business_line], "business_line"

    # Default: SQL Server (legacy catch-all)
    return "sql-server", "default"


def main():
    # Connect to catalog
    conn = psycopg2.connect(
        host=os.getenv("CATALOG_DB_HOST"),
        port=int(os.getenv("CATALOG_DB_PORT", 5432)),
        database=os.getenv("CATALOG_DB_NAME"),
        user=os.getenv("CATALOG_DB_USER"),
        password=os.getenv("CATALOG_DB_PASSWORD"),
        connect_timeout=15,
    )
    cur = conn.cursor()

    # Fetch all datasets
    cur.execute("""
        SELECT id, name, source_sys_name, data_domain, business_line, data_lifecycle
        FROM datasets
        ORDER BY id
    """)
    datasets = cur.fetchall()
    logger.info(f"Fetched {len(datasets)} datasets from catalog")

    # Assign platforms
    assignments = {}
    rule_stats = {}
    platform_stats = {}

    for row in datasets:
        dataset = {
            "id": row[0],
            "name": row[1],
            "source_sys_name": row[2],
            "data_domain": row[3],
            "business_line": row[4],
            "data_lifecycle": row[5],
        }
        platform, rule = assign_platform(dataset)
        assignments[dataset["id"]] = {
            "platform": platform,
            "rule": rule,
            "source_sys_name": dataset["source_sys_name"],
            "data_domain": dataset["data_domain"],
            "business_line": dataset["business_line"],
        }
        rule_stats[rule] = rule_stats.get(rule, 0) + 1
        platform_stats[platform] = platform_stats.get(platform, 0) + 1

    # Output assignment file
    config_dir = os.path.join(os.path.dirname(__file__), "..", "config")
    os.makedirs(config_dir, exist_ok=True)
    output_path = os.path.join(config_dir, "platform_assignment.json")
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(assignments, f, indent=2)
    logger.info(f"Wrote assignments to {output_path}")

    # Report
    logger.info("\n=== PLATFORM DISTRIBUTION ===")
    for platform in sorted(platform_stats, key=platform_stats.get, reverse=True):
        count = platform_stats[platform]
        pct = count / len(datasets) * 100
        logger.info(f"  {platform:15s}: {count:4d} ({pct:5.1f}%)")

    logger.info(f"\n=== RULE USAGE ===")
    for rule in sorted(rule_stats, key=rule_stats.get, reverse=True):
        logger.info(f"  {rule:15s}: {rule_stats[rule]:4d}")

    # Cross-check: domains per platform
    logger.info(f"\n=== DOMAINS PER PLATFORM ===")
    domain_per_platform = {}
    for ds_id, info in assignments.items():
        p = info["platform"]
        d = info["data_domain"]
        if p not in domain_per_platform:
            domain_per_platform[p] = set()
        if d:
            domain_per_platform[p].add(d)
    for platform in sorted(domain_per_platform):
        domains = sorted(domain_per_platform[platform])
        logger.info(f"  {platform}: {', '.join(domains)}")

    conn.close()


if __name__ == "__main__":
    main()
