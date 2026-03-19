#!/usr/bin/env python3
"""
Generate master entity pool for cross-platform distribution.

Output: config/master_entities.json

Entities:
- 500 Customers (350 individuals + 120 legal entities + 30 sole proprietors)
- 100 Products (financial products)
- 300 Contracts (linking customers to products)
- 50 Employees (staff)
- 15 Countries (reference data with intentional format variations)
- 6 Currencies (reference data)
- 30 Branches/Offices

Quality issues pre-planted:
- Functional dependency violations (same ID, different name across rows)
- Balance rounding differences across platforms
- Country code format mismatches
- Status code inconsistencies in legacy systems
- Stale emails
"""

import os
import json
import random
import string
from datetime import date, timedelta

OUTPUT_PATH = os.path.join(os.path.dirname(__file__), "..", "config", "master_entities.json")

# ─── SOURCE DATA ─────────────────────────────────────────────────────────────

FIRST_NAMES_M = ["Jan","Pieter","Lars","Thomas","Michiel","Daan","Bram","Lucas",
    "Sven","Mark","Ahmed","Mohammed","Wei","Raj","Arjun","James",
    "Robert","Carlos","Jean","Hans","Klaus","Pedro","Ivan","Erik",
    "Bas","Joost","Willem","Maarten","Dirk","Stefan"]
FIRST_NAMES_F = ["Maria","Sophie","Anna","Eva","Fleur","Emma","Lisa","Julia",
    "Nina","Lotte","Fatima","Aisha","Mei","Yuki","Priya","Deepa",
    "Sarah","Emily","Isabella","Marie","Greta","Heidi","Ana","Olga",
    "Ingrid","Anneke","Petra","Maaike","Hilde","Renate"]
FIRST_NAMES = FIRST_NAMES_M + FIRST_NAMES_F

LAST_NAMES = [
    "van den Berg","de Jong","Jansen","de Vries","van Dijk","Bakker","Visser",
    "Smit","Meijer","de Boer","Muller","Schmidt","Schneider","Fischer","Weber",
    "Smith","Johnson","Williams","Brown","Jones","Garcia","Martinez","Rodriguez",
    "Lopez","Hernandez","Chen","Wang","Li","Zhang","Liu","Patel","Sharma",
    "Kumar","Singh","Gupta","Dubois","Moreau","Laurent","Simon","Martin",
    "van der Linden","Hendriks","Dekker","Dijkstra","Brouwer","van Leeuwen",
    "Willems","Bos","van der Meer","Vermeer",
]

# Company names for legal entities
COMPANY_PREFIXES = ["Masreph","Euro","Global","Nordic","Atlas","Meridian","Apex","Vanguard",
    "Sterling","Quantum","Nexus","Pinnacle","Horizon","Summit","Catalyst"]
COMPANY_ACTIVITIES = ["Automotive","Logistics","Manufacturing","Engineering","Solutions",
    "Trading","Properties","Capital","Investments","Holdings","Technologies",
    "Services","Industries","Ventures","Partners"]
COMPANY_SUFFIXES = ["B.V.","N.V.","GmbH","Ltd","Inc","S.A.","AG","Pty Ltd","S.r.l.","A/S"]

COUNTRIES = {
    "NL": {"name": "Netherlands", "iso3": "NLD", "oracle": "NL", "mongo": "Netherlands", "cities": ["Amsterdam","Rotterdam","The Hague","Utrecht","Eindhoven","Groningen"]},
    "DE": {"name": "Germany", "iso3": "DEU", "oracle": "DE", "mongo": "Germany", "cities": ["Berlin","Munich","Frankfurt","Hamburg","Cologne","Stuttgart"]},
    "FR": {"name": "France", "iso3": "FRA", "oracle": "FR", "mongo": "France", "cities": ["Paris","Lyon","Marseille","Toulouse","Nice"]},
    "GB": {"name": "United Kingdom", "iso3": "GBR", "oracle": "GB", "mongo": "United Kingdom", "cities": ["London","Manchester","Birmingham","Edinburgh","Bristol"]},
    "US": {"name": "United States", "iso3": "USA", "oracle": "US", "mongo": "United States", "cities": ["New York","Los Angeles","Chicago","Houston","San Francisco"]},
    "BE": {"name": "Belgium", "iso3": "BEL", "oracle": "BE", "mongo": "Belgium", "cities": ["Brussels","Antwerp","Ghent","Bruges"]},
    "CH": {"name": "Switzerland", "iso3": "CHE", "oracle": "CH", "mongo": "Switzerland", "cities": ["Zurich","Geneva","Basel","Bern"]},
    "AT": {"name": "Austria", "iso3": "AUT", "oracle": "AT", "mongo": "Austria", "cities": ["Vienna","Salzburg","Innsbruck"]},
    "ES": {"name": "Spain", "iso3": "ESP", "oracle": "ES", "mongo": "Spain", "cities": ["Madrid","Barcelona","Valencia"]},
    "IT": {"name": "Italy", "iso3": "ITA", "oracle": "IT", "mongo": "Italy", "cities": ["Milan","Rome","Turin"]},
    "JP": {"name": "Japan", "iso3": "JPN", "oracle": "JP", "mongo": "Japan", "cities": ["Tokyo","Osaka","Yokohama"]},
    "SG": {"name": "Singapore", "iso3": "SGP", "oracle": "SG", "mongo": "Singapore", "cities": ["Singapore"]},
    "AU": {"name": "Australia", "iso3": "AUS", "oracle": "AU", "mongo": "Australia", "cities": ["Sydney","Melbourne","Brisbane"]},
    "SE": {"name": "Sweden", "iso3": "SWE", "oracle": "SE", "mongo": "Sweden", "cities": ["Stockholm","Gothenburg","Malmo"]},
    "DK": {"name": "Denmark", "iso3": "DNK", "oracle": "DK", "mongo": "Denmark", "cities": ["Copenhagen","Aarhus"]},
}

CURRENCIES = {
    "EUR": {"name": "Euro", "symbol": "\u20ac", "numeric": "978"},
    "USD": {"name": "US Dollar", "symbol": "$", "numeric": "840"},
    "GBP": {"name": "British Pound", "symbol": "\u00a3", "numeric": "826"},
    "CHF": {"name": "Swiss Franc", "symbol": "CHF", "numeric": "756"},
    "JPY": {"name": "Japanese Yen", "symbol": "\u00a5", "numeric": "392"},
    "SGD": {"name": "Singapore Dollar", "symbol": "S$", "numeric": "702"},
}

SEGMENTS_INDIVIDUAL = ["mass_market","affluent","high_net_worth","ultra_high_net_worth"]
SEGMENTS_ENTITY = ["sme","mid_corporate","large_corporate","institutional"]
RISK_BANDS = ["AAA","AA","A","BBB","BB","B","CCC","CC","C","D"]
GENDERS = ["M","F","X"]
MARITAL = ["single","married","divorced","widowed","registered_partnership"]
EMPLOYMENT = ["employed","self_employed","unemployed","retired","student"]
CHANNELS = ["web_portal","mobile_app","branch","phone","email","api"]
GDPR_CONSENT = ["granted","withdrawn","pending","not_requested"]
INDUSTRIES = ["Financial Services","Manufacturing","Retail","Healthcare","Technology",
    "Real Estate","Automotive","Energy","Transportation","Agriculture",
    "Construction","Hospitality","Media","Education","Pharma"]
LEGAL_FORMS = ["private_limited","public_limited","partnership","sole_proprietorship",
    "cooperative","foundation","holding"]

PRODUCT_TYPES = [
    {"code": "AL", "name": "Auto Lease", "category": "Leasing", "business_line": "Leasing", "customer_type": "both"},
    {"code": "EL", "name": "Equipment Lease", "category": "Leasing", "business_line": "Leasing", "customer_type": "entity"},
    {"code": "GL", "name": "Green Lease", "category": "Leasing", "business_line": "Leasing", "customer_type": "both"},
    {"code": "FL", "name": "Fleet Lease", "category": "Leasing", "business_line": "Leasing", "customer_type": "entity"},
    {"code": "MT", "name": "Mortgage", "category": "Lending", "business_line": "Consumer Finance", "customer_type": "individual"},
    {"code": "PL", "name": "Personal Loan", "category": "Lending", "business_line": "Consumer Finance", "customer_type": "individual"},
    {"code": "BL", "name": "Business Loan", "category": "Lending", "business_line": "Commercial Finance", "customer_type": "entity"},
    {"code": "CC", "name": "Credit Card", "category": "Cards", "business_line": "Consumer Finance", "customer_type": "individual"},
    {"code": "SA", "name": "Savings Account", "category": "Deposits", "business_line": "Consumer Finance", "customer_type": "individual"},
    {"code": "TF", "name": "Trade Finance", "category": "Trade", "business_line": "Commercial Finance", "customer_type": "entity"},
]

CONTRACT_STATUSES = ["active","terminated","expired","pending_activation","in_default","restructured"]
DEPARTMENTS = ["Sales","Finance","Risk Management","Operations","IT","Legal","Compliance","HR","Marketing","Treasury","Audit","Data Engineering"]
REGIONS = ["EMEA","APAC","Americas","Nordics"]
BUSINESS_LINES = ["Leasing","Commercial Finance","Consumer Finance","Mobility Solutions","Innovation & Technology"]
BRANCHES = [
    "Amsterdam Central","Rotterdam South","Frankfurt Main","London City",
    "Paris La Defense","Brussels EU Quarter","Zurich Bahnhofstrasse",
    "Singapore Marina Bay","New York Midtown","Tokyo Marunouchi",
    "Berlin Mitte","Munich Maximilianstrasse","Madrid Gran Via",
    "Milan Duomo","Vienna Ring","Stockholm Stureplan",
    "Copenhagen Stroget","Sydney Martin Place","Melbourne Collins Street",
    "Eindhoven Strijp","Utrecht Centraal","The Hague Binnenhof",
    "Antwerp Diamond District","Geneva Rue du Rhone","Barcelona Diagonal",
    "Hamburg HafenCity","Cologne Dom","Dubai DIFC",
    "Hong Kong Central","Seoul Gangnam",
]


def gen_iban(country_code):
    bank = "".join(random.choices(string.ascii_uppercase, k=4))
    account = "".join(random.choices(string.digits, k=10))
    return f"{country_code}{random.randint(10,99)}{bank}0{account}"


def gen_phone(country_code):
    prefixes = {"NL":"+31","DE":"+49","FR":"+33","GB":"+44","US":"+1","BE":"+32",
        "CH":"+41","JP":"+81","SG":"+65","AU":"+61","SE":"+46","DK":"+45",
        "AT":"+43","ES":"+34","IT":"+39"}
    return f"{prefixes.get(country_code, '+31')} {random.randint(600000000, 699999999)}"


def gen_kvk():
    """Generate Dutch KVK (Chamber of Commerce) number."""
    return "".join(random.choices(string.digits, k=8))


def gen_lei():
    """Generate LEI (Legal Entity Identifier) — 20 chars."""
    return "".join(random.choices(string.ascii_uppercase + string.digits, k=20))


def gen_company_name(country):
    prefix = random.choice(COMPANY_PREFIXES)
    activity = random.choice(COMPANY_ACTIVITIES)
    suffix_map = {"NL": "B.V.", "DE": "GmbH", "FR": "S.A.", "GB": "Ltd", "US": "Inc",
        "BE": "N.V.", "CH": "AG", "AU": "Pty Ltd", "IT": "S.r.l.", "DK": "A/S",
        "SE": "AB", "AT": "GmbH", "ES": "S.L.", "JP": "K.K.", "SG": "Pte Ltd"}
    suffix = suffix_map.get(country, random.choice(COMPANY_SUFFIXES))
    return f"{prefix} {activity} {suffix}"


def make_platform_ids(index, prefix, customer_type):
    """Generate platform-specific IDs."""
    if customer_type == "individual":
        tag = "CUST"
    elif customer_type == "entity":
        tag = "ENT"
    else:
        tag = "SP"

    master_id = f"{tag}-{index:05d}"
    return {
        "master_id": master_id,
        "sql_server": master_id,
        "postgresql": index,
        "snowflake": f"{tag[0]}{index:06d}",
        "oracle": f"{index:05d}",
        "mongodb": f"{tag.lower()}_{index}",
        "mysql": index,
        "fabric": master_id,
        "databricks": f"{tag.lower()}_{index}",
    }


def generate_individual(index):
    """Generate an individual customer."""
    gender = random.choices(GENDERS, weights=[48, 48, 4])[0]
    first = random.choice(FIRST_NAMES_M if gender == "M" else FIRST_NAMES_F if gender == "F" else FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    country = random.choices(list(COUNTRIES.keys()), weights=[20,15,10,10,8,5,5,3,3,3,3,3,3,3,3])[0]
    city = random.choice(COUNTRIES[country]["cities"])
    segment = random.choices(SEGMENTS_INDIVIDUAL, weights=[40,30,20,10])[0]
    risk = random.choices(RISK_BANDS, weights=[5,10,20,25,15,10,8,4,2,1])[0]
    age = random.randint(18, 78)
    dob = date(2026 - age, random.randint(1, 12), random.randint(1, 28))
    rel_start = date(2015, 1, 1) + timedelta(days=random.randint(0, 3650))
    income = round(random.uniform(25000, 300000), 2)
    email = f"{first.lower()}.{last.lower().replace(' ', '')}@{random.choice(['masreph.com','gmail.com','outlook.com'])}"
    phone = gen_phone(country)
    iban = gen_iban(country)

    ids = make_platform_ids(index, "CUST", "individual")

    # FD violation: 5% chance name appears differently in some rows
    fd_violation_name = None
    if random.random() < 0.05:
        fd_violation_name = random.choice([
            f"{first} {last}-{random.choice(LAST_NAMES)}",  # Married name
            f"{first[0]}. {last}",  # Abbreviated
            f"{first} {last.upper()}",  # Case difference
            f" {first} {last} ",  # Whitespace
        ])

    return {
        "customer_type": "individual",
        "master_id": ids["master_id"],
        "index": index,
        "first_name": first,
        "last_name": last,
        "full_name": f"{first} {last}",
        "gender": gender,
        "date_of_birth": dob.isoformat(),
        "age": age,
        "email": email,
        "phone": phone,
        "iban": iban,
        "country_code": country,
        "city": city,
        "postal_code": f"{random.randint(1000,9999)}{random.choice(['AB','CD','EF','GH','KL'])}",
        "segment": segment,
        "risk_band": risk,
        "marital_status": random.choice(MARITAL),
        "employment_status": random.choices(EMPLOYMENT, weights=[55,15,5,15,10])[0],
        "annual_income_eur": income,
        "net_worth_eur": round(income * random.uniform(2, 15), 2),
        "relationship_start_date": rel_start.isoformat(),
        "preferred_channel": random.choice(CHANNELS),
        "gdpr_consent": random.choices(GDPR_CONSENT, weights=[60,5,10,25])[0],
        "is_pep": random.random() < 0.03,
        "household_size": random.choices([1,2,3,4,5,6], weights=[15,25,25,20,10,5])[0],
        "platform_ids": ids,
        "platform_names": {
            "sql_server": f"{first} {last.title()}",
            "postgresql": f"{first.lower()} {last.lower()}",
            "snowflake": f"{first.upper()} {last.upper()}",
            "oracle": f"{last.upper()}, {first.upper()}",
            "mongodb": {"firstName": first, "lastName": last},
            "mysql": f"{first.lower()} {last.lower()}",
            "fabric": f"{first} {last.title()}",
            "databricks": f"{first.lower()} {last.lower()}",
        },
        "quality_issues": {
            # Functional Dependency: same ID, different name
            "fd_violation_name": fd_violation_name,
            # Domain List: invalid gender value
            "domain_list_gender": random.choice(["Male","Female","0","U","unknown"]) if random.random() < 0.03 else None,
            # Domain List: invalid segment value
            "domain_list_segment": random.choice(["VIP","GOLD","tier1","unknown"]) if random.random() < 0.02 else None,
            # Domain Pattern: malformed phone
            "domain_pattern_phone": random.choice(["0612345","tel:+31612345","N/A","---"]) if random.random() < 0.03 else None,
            # Domain Pattern: truncated/malformed IBAN
            "domain_pattern_iban": random.choice([iban[:12], "INVALID", iban.lower(), f" {iban} "]) if random.random() < 0.03 else None,
            # Domain Pattern: malformed email
            "domain_pattern_email": random.choice(["not_an_email","N/A",f"{first}@",""]) if random.random() < 0.02 else None,
            # Domain Range: impossible age
            "domain_range_age": random.choice([0, -1, 200, 999]) if random.random() < 0.01 else None,
            # Domain Range: negative income
            "domain_range_income": round(random.uniform(-50000, -1), 2) if random.random() < 0.01 else None,
            # No Nulls: NULL in mandatory field (customer_id should never be null but name could be)
            "no_nulls_mandatory": True if random.random() < 0.02 else False,  # Will insert NULL name
            # Unique Key: duplicate customer (same ID appears twice with different data)
            "unique_key_duplicate": True if random.random() < 0.01 else False,
            # Referential: orphan reference (points to non-existent branch)
            "referential_orphan_branch": f"BRN-{random.randint(900,999):03d}" if random.random() < 0.02 else None,
            # Name and Address: city in street field, street in city field
            "name_address_swap": True if random.random() < 0.02 else False,
            # Custom: future date of birth
            "custom_future_dob": date(2030, random.randint(1,12), random.randint(1,28)).isoformat() if random.random() < 0.005 else None,
            # Cross-platform: stale email
            "stale_email": f"{first.lower()}_old@masreph.com" if random.random() < 0.05 else None,
            # Cross-platform: country code format mismatch
            "wrong_country_in_snowflake": COUNTRIES[country]["iso3"] if random.random() < 0.03 else None,
            # Cross-platform: balance rounding
            "balance_rounding_offset": round(random.uniform(-50, 50), 2) if random.random() < 0.08 else 0,
        },
    }


def generate_legal_entity(index):
    """Generate a legal entity customer."""
    country = random.choices(list(COUNTRIES.keys()), weights=[20,15,10,10,8,5,5,3,3,3,3,3,3,3,3])[0]
    city = random.choice(COUNTRIES[country]["cities"])
    company_name = gen_company_name(country)
    segment = random.choices(SEGMENTS_ENTITY, weights=[40,30,20,10])[0]
    risk = random.choices(RISK_BANDS, weights=[5,10,20,25,15,10,8,4,2,1])[0]
    industry = random.choice(INDUSTRIES)
    incorporation_date = date(1990, 1, 1) + timedelta(days=random.randint(0, 12000))
    rel_start = date(2015, 1, 1) + timedelta(days=random.randint(0, 3650))
    annual_revenue = round(random.uniform(500000, 500000000), 2)
    employee_count = random.randint(5, 50000)
    lei = gen_lei()
    kvk = gen_kvk() if country == "NL" else None
    email = f"finance@{company_name.split()[0].lower()}.{country.lower()}"
    phone = gen_phone(country)
    iban = gen_iban(country)

    # Contact person (key contact at the entity)
    contact_first = random.choice(FIRST_NAMES)
    contact_last = random.choice(LAST_NAMES)

    ids = make_platform_ids(index, "ENT", "entity")

    # FD violation: company name appears differently
    fd_violation_name = None
    if random.random() < 0.08:
        parts = company_name.split()
        fd_violation_name = random.choice([
            " ".join(parts[:-1]),  # Missing suffix (B.V.)
            company_name.upper(),  # All caps
            f"{parts[0]} {parts[1]}",  # Truncated
            company_name.replace(".", ""),  # Missing dots in suffix
        ])

    return {
        "customer_type": "entity",
        "master_id": ids["master_id"],
        "index": index,
        "company_name": company_name,
        "legal_name": company_name,
        "trade_name": " ".join(company_name.split()[:-1]),
        "lei": lei,
        "kvk_number": kvk,
        "incorporation_date": incorporation_date.isoformat(),
        "incorporation_country": country,
        "legal_form": random.choice(LEGAL_FORMS),
        "industry": industry,
        "sbi_code": f"{random.randint(10,99)}.{random.randint(10,99)}",
        "annual_revenue_eur": annual_revenue,
        "employee_count": employee_count,
        "contact_person": f"{contact_first} {contact_last}",
        "contact_email": f"{contact_first.lower()}.{contact_last.lower().replace(' ','')}@{company_name.split()[0].lower()}.com",
        "email": email,
        "phone": phone,
        "iban": iban,
        "country_code": country,
        "city": city,
        "postal_code": f"{random.randint(1000,9999)}{random.choice(['AB','CD','EF'])}",
        "segment": segment,
        "risk_band": risk,
        "relationship_start_date": rel_start.isoformat(),
        "preferred_channel": random.choice(["branch","phone","email","api"]),
        "gdpr_consent": "granted",  # Entities always have consent (B2B)
        "is_pep": False,
        "is_sanctioned": random.random() < 0.01,
        "ultimate_beneficial_owners": [
            {"name": f"{random.choice(FIRST_NAMES)} {random.choice(LAST_NAMES)}", "share_pct": random.randint(25, 100)}
            for _ in range(random.randint(1, 3))
        ],
        "platform_ids": ids,
        "platform_names": {
            "sql_server": company_name,
            "postgresql": company_name.lower(),
            "snowflake": company_name.upper(),
            "oracle": company_name[:30].upper(),
            "mongodb": {"companyName": company_name, "tradeName": " ".join(company_name.split()[:-1])},
            "mysql": company_name.lower(),
            "fabric": company_name,
            "databricks": company_name.lower(),
        },
        "quality_issues": {
            # Functional Dependency: company name varies
            "fd_violation_name": fd_violation_name,
            # Domain List: invalid legal form
            "domain_list_legal_form": random.choice(["LLC","unknown","OTHER","---"]) if random.random() < 0.03 else None,
            # Domain Pattern: invalid LEI (wrong length or format)
            "domain_pattern_lei": random.choice([lei[:10], "INVALID_LEI", "N/A"]) if random.random() < 0.04 else None,
            # Domain Range: negative revenue
            "domain_range_revenue": round(random.uniform(-1000000, -1), 2) if random.random() < 0.01 else None,
            # Domain Range: impossible employee count
            "domain_range_employees": random.choice([0, -5, 999999]) if random.random() < 0.01 else None,
            # No Nulls: missing mandatory LEI
            "missing_lei_in_oracle": True if random.random() < 0.10 else False,
            # Unique Key: duplicate entity registration
            "unique_key_duplicate": True if random.random() < 0.01 else False,
            # Referential: orphan industry code
            "referential_orphan_industry": "UNKNOWN_INDUSTRY" if random.random() < 0.02 else None,
            # Conditional FD: sanctioned=true but risk_band=AAA (should be high risk)
            "conditional_fd_sanction_risk": True if random.random() < 0.02 else False,
            # Multi-column: incorporation_date > relationship_start_date (impossible)
            "multi_col_incorp_after_rel": True if random.random() < 0.02 else False,
            # Multi-column: country_code != IBAN country prefix
            "multi_col_country_iban_mismatch": True if random.random() < 0.03 else False,
            # Cross-platform
            "wrong_country_in_snowflake": COUNTRIES[country]["iso3"] if random.random() < 0.03 else None,
            "balance_rounding_offset": round(random.uniform(-500, 500), 2) if random.random() < 0.08 else 0,
            "stale_employee_count": random.randint(5, 50000) if random.random() < 0.06 else None,
        },
    }


def generate_sole_proprietor(index):
    """Generate a sole proprietor — person + business."""
    gender = random.choices(GENDERS, weights=[48, 48, 4])[0]
    first = random.choice(FIRST_NAMES_M if gender == "M" else FIRST_NAMES_F if gender == "F" else FIRST_NAMES)
    last = random.choice(LAST_NAMES)
    country = random.choices(list(COUNTRIES.keys())[:8], weights=[25,15,10,10,10,10,10,10])[0]
    city = random.choice(COUNTRIES[country]["cities"])
    trade_name = f"{first} {last} {random.choice(['Consulting','Services','Trading','Solutions','Finance'])}"
    kvk = gen_kvk() if country in ("NL","BE") else None
    age = random.randint(25, 65)
    dob = date(2026 - age, random.randint(1, 12), random.randint(1, 28))
    rel_start = date(2018, 1, 1) + timedelta(days=random.randint(0, 2500))
    income = round(random.uniform(30000, 200000), 2)
    email = f"{first.lower()}.{last.lower().replace(' ','')}@{trade_name.split()[-1].lower()}.com"
    phone = gen_phone(country)
    iban = gen_iban(country)

    ids = make_platform_ids(index, "SP", "sole_proprietor")

    return {
        "customer_type": "sole_proprietor",
        "master_id": ids["master_id"],
        "index": index,
        "first_name": first,
        "last_name": last,
        "full_name": f"{first} {last}",
        "trade_name": trade_name,
        "kvk_number": kvk,
        "gender": gender,
        "date_of_birth": dob.isoformat(),
        "age": age,
        "industry": random.choice(INDUSTRIES[:8]),
        "annual_revenue_eur": income,
        "email": email,
        "phone": phone,
        "iban": iban,
        "country_code": country,
        "city": city,
        "postal_code": f"{random.randint(1000,9999)}{random.choice(['AB','CD','EF'])}",
        "segment": "sme",
        "risk_band": random.choices(RISK_BANDS, weights=[3,8,15,25,20,12,10,4,2,1])[0],
        "relationship_start_date": rel_start.isoformat(),
        "preferred_channel": random.choice(CHANNELS),
        "gdpr_consent": random.choices(GDPR_CONSENT[:3], weights=[70,5,25])[0],
        "is_pep": random.random() < 0.02,
        "household_size": random.choices([1,2,3,4], weights=[30,35,25,10])[0],
        "platform_ids": ids,
        "platform_names": {
            "sql_server": f"{first} {last.title()} ({trade_name})",
            "postgresql": f"{first.lower()} {last.lower()}",
            "snowflake": f"{first.upper()} {last.upper()}",
            "oracle": f"{last.upper()}, {first.upper()}",
            "mongodb": {"firstName": first, "lastName": last, "tradeName": trade_name},
            "mysql": f"{first.lower()} {last.lower()}",
            "fabric": f"{first} {last.title()}",
            "databricks": f"{first.lower()} {last.lower()}",
        },
        "quality_issues": {
            "fd_violation_name": f"{trade_name}" if random.random() < 0.06 else None,  # Trade name used instead of person name
            "balance_rounding_offset": round(random.uniform(-30, 30), 2) if random.random() < 0.08 else 0,
        },
    }


def generate_customers():
    """Generate 500 customers: 350 individuals + 120 entities + 30 sole proprietors."""
    customers = []
    idx = 1

    # 350 individuals
    for _ in range(350):
        customers.append(generate_individual(idx))
        idx += 1

    # 120 legal entities
    for _ in range(120):
        customers.append(generate_legal_entity(idx))
        idx += 1

    # 30 sole proprietors
    for _ in range(30):
        customers.append(generate_sole_proprietor(idx))
        idx += 1

    return customers


def generate_products(n=100):
    """Generate 100 master product records."""
    products = []
    for i in range(n):
        ptype = random.choice(PRODUCT_TYPES)
        suffix = f"{random.randint(100,999)}"
        code = f"{ptype['code']}-{suffix}"
        variant = random.choice(["Plus","Pro","Standard","Flex","Direct","Premium","Green","Smart","Essential","Select"])
        name = f"Masreph {ptype['name']} {variant}"
        rate = round(random.uniform(1.5, 12.0), 4)
        currency = random.choices(list(CURRENCIES.keys()), weights=[50,20,10,10,5,5])[0]
        min_amount = random.choice([5000, 10000, 25000, 50000])
        max_amount = random.choice([100000, 500000, 1000000, 5000000])

        products.append({
            "master_id": f"PRD-{i+1:04d}",
            "index": i + 1,
            "code": code,
            "name": name,
            "type": ptype["name"],
            "category": ptype["category"],
            "business_line": ptype["business_line"],
            "customer_type_target": ptype["customer_type"],
            "interest_rate": rate,
            "currency": currency,
            "min_amount": min_amount,
            "max_amount": max_amount,
            "is_active": random.random() < 0.90,
            "launch_date": (date(2018, 1, 1) + timedelta(days=random.randint(0, 2500))).isoformat(),
            "platform_ids": {
                "sql_server": code,
                "postgresql": code.lower().replace("-", "_"),
                "snowflake": code.upper(),
                "oracle": code[:6].upper().replace("-", ""),
                "fabric": code,
                "databricks": code.lower().replace("-", "_"),
            },
            "platform_names": {
                "sql_server": name,
                "postgresql": name.lower(),
                "snowflake": name.upper(),
                "oracle": name[:30].upper(),
                "fabric": name,
                "databricks": name.lower(),
            },
            "quality_issues": {
                "fd_violation_rate": round(rate + random.uniform(-0.5, 0.5), 4) if random.random() < 0.05 else None,
                "oracle_truncated_name": name[:20].upper() if len(name) > 20 and random.random() < 0.3 else None,
                "mysql_different_code": code.lower() if random.random() < 0.1 else None,
            },
        })

    return products


def generate_contracts(n=300, customers=None, products=None):
    """Generate 300 contracts linking customers to products."""
    contracts = []
    for i in range(n):
        # Match customer type to product target
        eligible_products = [p for p in products if p["customer_type_target"] in ("both", "individual", "entity")]
        product = random.choice(eligible_products)

        if product["customer_type_target"] == "individual":
            eligible_customers = [c for c in customers if c["customer_type"] in ("individual", "sole_proprietor")]
        elif product["customer_type_target"] == "entity":
            eligible_customers = [c for c in customers if c["customer_type"] in ("entity", "sole_proprietor")]
        else:
            eligible_customers = customers

        customer = random.choice(eligible_customers)

        start = date(2020, 1, 1) + timedelta(days=random.randint(0, 2000))
        duration_months = random.choice([12, 24, 36, 48, 60, 84, 120])
        end = start + timedelta(days=duration_months * 30)
        amount = round(random.uniform(product["min_amount"], product["max_amount"]), 2)
        status = random.choices(CONTRACT_STATUSES, weights=[60, 10, 10, 5, 10, 5])[0]
        outstanding = round(amount * random.uniform(0.1, 0.9), 2) if status == "active" else 0
        contract_id = f"CNT-{i+1:05d}"

        contracts.append({
            "master_id": contract_id,
            "index": i + 1,
            "customer_master_id": customer["master_id"],
            "customer_type": customer["customer_type"],
            "product_master_id": product["master_id"],
            "customer_index": customer["index"],
            "product_index": product["index"],
            "start_date": start.isoformat(),
            "end_date": end.isoformat(),
            "duration_months": duration_months,
            "amount": amount,
            "currency": product["currency"],
            "interest_rate": product["interest_rate"],
            "status": status,
            "monthly_payment": round(amount / duration_months, 2),
            "outstanding_balance": outstanding,
            "platform_ids": {
                "sql_server": contract_id,
                "postgresql": i + 1,
                "snowflake": f"CNT{i+1:06d}",
                "oracle": f"{i+1:05d}",
            },
            "quality_issues": {
                # Functional Dependency: status inconsistency across rows
                "fd_violation_status": random.choice(["active","Active","ACTIVE"]) if status == "active" and random.random() < 0.04 else None,
                # Domain List: invalid status value
                "domain_list_status": random.choice(["OPEN","running","live","X"]) if random.random() < 0.02 else None,
                # Domain Range: negative amount
                "domain_range_amount": round(random.uniform(-100000, -1), 2) if random.random() < 0.01 else None,
                # Domain Range: interest rate > 100%
                "domain_range_rate": round(random.uniform(100, 999), 2) if random.random() < 0.005 else None,
                # Custom: end_date before start_date
                "custom_end_before_start": True if random.random() < 0.005 else False,
                # Custom: negative duration
                "custom_negative_duration": random.randint(-12, -1) if random.random() < 0.005 else None,
                # Conditional FD: status=active but outstanding_balance=0
                "conditional_fd_active_zero_balance": True if status == "active" and outstanding == 0 and random.random() < 0.03 else False,
                # Conditional FD: status=terminated but outstanding_balance > 0
                "conditional_fd_terminated_with_balance": True if status == "terminated" and random.random() < 0.05 else False,
                # Multi-column: monthly_payment * duration != amount (calculation error)
                "multi_col_payment_mismatch": True if random.random() < 0.03 else False,
                # Multi-column: currency mismatch between contract and product
                "multi_col_currency_mismatch": random.choice(["USD","GBP","CHF"]) if product["currency"] == "EUR" and random.random() < 0.02 else None,
                # Referential: orphan customer (points to non-existent customer)
                "referential_orphan_customer": f"CUST-{random.randint(900,999):05d}" if random.random() < 0.01 else None,
                # Referential: orphan product
                "referential_orphan_product": f"PRD-{random.randint(900,999):04d}" if random.random() < 0.01 else None,
                # Unique Key: duplicate contract ID
                "unique_key_duplicate": True if random.random() < 0.008 else False,
                # Cross-platform: balance rounding difference
                "balance_mismatch_snowflake": round(outstanding + random.uniform(-100, 100), 2) if status == "active" and random.random() < 0.10 else None,
                # Cross-platform: status code inconsistency in Oracle
                "status_inconsistency_oracle": random.choice(["A","ACTV","1"]) if status == "active" and random.random() < 0.15 else None,
            },
        })

    return contracts


def generate_employees(n=50):
    """Generate 50 master employee records."""
    employees = []
    title_map = {
        "Sales": "Relationship Manager", "Finance": "Financial Controller",
        "Risk Management": "Risk Analyst", "Operations": "Operations Manager",
        "IT": "Data Engineer", "Legal": "Legal Counsel", "Compliance": "Compliance Officer",
        "HR": "HR Business Partner", "Marketing": "Marketing Specialist",
        "Treasury": "Treasury Analyst", "Audit": "Internal Auditor",
        "Data Engineering": "Senior Data Engineer",
    }
    for i in range(n):
        gender = random.choices(GENDERS, weights=[48, 48, 4])[0]
        first = random.choice(FIRST_NAMES_M if gender == "M" else FIRST_NAMES_F if gender == "F" else FIRST_NAMES)
        last = random.choice(LAST_NAMES)
        dept = random.choice(DEPARTMENTS)

        employees.append({
            "master_id": f"EMP-{i+1:04d}",
            "index": i + 1,
            "first_name": first,
            "last_name": last,
            "full_name": f"{first} {last}",
            "email": f"{first.lower()}.{last.lower().replace(' ', '')}@masreph.com",
            "department": dept,
            "title": title_map.get(dept, "Specialist"),
            "region": random.choice(REGIONS),
            "hire_date": (date(2010, 1, 1) + timedelta(days=random.randint(0, 5000))).isoformat(),
            "is_active": random.random() < 0.92,
            "manager_index": random.randint(1, max(1, i)) if i > 5 else None,
            "platform_ids": {
                "sql_server": f"EMP-{i+1:04d}",
                "fabric": f"EMP-{i+1:04d}",
                "databricks": f"emp_{i+1}",
            },
        })

    return employees


def generate_branches():
    """Generate branch/office records."""
    branches = []
    branch_countries = {
        "Amsterdam": "NL", "Rotterdam": "NL", "Eindhoven": "NL", "Utrecht": "NL", "Hague": "NL",
        "Frankfurt": "DE", "Berlin": "DE", "Munich": "DE", "Hamburg": "DE", "Cologne": "DE",
        "Paris": "FR", "London": "GB", "Brussels": "BE", "Antwerp": "BE",
        "Zurich": "CH", "Geneva": "CH", "Singapore": "SG", "New York": "US",
        "Tokyo": "JP", "Sydney": "AU", "Melbourne": "AU",
        "Madrid": "ES", "Barcelona": "ES", "Milan": "IT", "Vienna": "AT",
        "Stockholm": "SE", "Copenhagen": "DK", "Dubai": "AE",
        "Hong Kong": "HK", "Seoul": "KR",
    }
    for i, name in enumerate(BRANCHES):
        country = "NL"
        for city_key, cc in branch_countries.items():
            if city_key in name:
                country = cc
                break

        branches.append({
            "master_id": f"BRN-{i+1:03d}",
            "index": i + 1,
            "name": name,
            "country_code": country,
            "region": "EMEA" if country in ["NL","DE","FR","GB","BE","CH","AT","ES","IT","SE","DK","AE"] else
                      "APAC" if country in ["JP","SG","AU","HK","KR"] else "Americas",
        })
    return branches


def main():
    print("=== Generating Master Entities ===")

    customers = generate_customers()
    individuals = [c for c in customers if c["customer_type"] == "individual"]
    entities = [c for c in customers if c["customer_type"] == "entity"]
    sole_props = [c for c in customers if c["customer_type"] == "sole_proprietor"]
    print(f"Customers: {len(customers)} ({len(individuals)} individuals, {len(entities)} entities, {len(sole_props)} sole proprietors)")

    products = generate_products(100)
    print(f"Products: {len(products)}")

    contracts = generate_contracts(300, customers, products)
    print(f"Contracts: {len(contracts)}")

    employees = generate_employees(50)
    print(f"Employees: {len(employees)}")

    branches = generate_branches()
    print(f"Branches: {len(branches)}")

    # Quality issue stats
    fd_name = sum(1 for c in customers if c["quality_issues"].get("fd_violation_name"))
    fd_rate = sum(1 for p in products if p["quality_issues"].get("fd_violation_rate"))
    fd_status = sum(1 for c in contracts if c["quality_issues"].get("fd_violation_status"))
    balance_mm = sum(1 for c in contracts if c["quality_issues"].get("balance_mismatch_snowflake"))
    impossible_dates = sum(1 for c in contracts if c["quality_issues"].get("end_before_start"))
    pep_count = sum(1 for c in customers if c.get("is_pep"))
    sanctioned = sum(1 for c in customers if c.get("is_sanctioned"))

    print(f"\nQuality issues planted:")
    print(f"  FD violations (name): {fd_name} customers")
    print(f"  FD violations (rate): {fd_rate} products")
    print(f"  FD violations (status): {fd_status} contracts")
    print(f"  Balance mismatches: {balance_mm} contracts")
    print(f"  Impossible dates: {impossible_dates} contracts")
    print(f"  PEP flagged: {pep_count}")
    print(f"  Sanctioned entities: {sanctioned}")

    # Countries
    country_dist = {}
    for c in customers:
        cc = c["country_code"]
        country_dist[cc] = country_dist.get(cc, 0) + 1
    print(f"\nCountry distribution:")
    for cc in sorted(country_dist, key=country_dist.get, reverse=True):
        print(f"  {cc}: {country_dist[cc]}")

    master = {
        "generated_at": date.today().isoformat(),
        "summary": {
            "customers_total": len(customers),
            "customers_individual": len(individuals),
            "customers_entity": len(entities),
            "customers_sole_proprietor": len(sole_props),
            "products": len(products),
            "contracts": len(contracts),
            "employees": len(employees),
            "branches": len(branches),
            "countries": len(COUNTRIES),
            "currencies": len(CURRENCIES),
        },
        "customers": customers,
        "products": products,
        "contracts": contracts,
        "employees": employees,
        "branches": branches,
        "countries": COUNTRIES,
        "currencies": CURRENCIES,
    }

    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        json.dump(master, f, indent=2, ensure_ascii=False)

    size_mb = os.path.getsize(OUTPUT_PATH) / 1024 / 1024
    print(f"\nSaved to {OUTPUT_PATH} ({size_mb:.1f} MB)")


if __name__ == "__main__":
    main()
