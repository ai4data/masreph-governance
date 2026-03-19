# Data Population Audit — All 8 Platforms

## Summary
| Platform | Total Tables | Tables with Data | Empty Tables | Total Rows | % Populated |
|---|---:|---:|---:|---:|---:|
| SQL Server | 0 | 0 | 0 | 0 | 0.0% |
| PostgreSQL | 194 | 194 | 0 | 28866 | 100.0% |
| MySQL | 39 | 39 | 0 | 11618 | 100.0% |
| Snowflake | 34 | 34 | 0 | 7132 | 100.0% |
| Oracle | 0 | 0 | 0 | 0 | 0.0% |
| MongoDB | 4 | 4 | 0 | 842 | 100.0% |
| Databricks | 0 | 0 | 0 | 0 | 0.0% |
| Fabric | 0 | 0 | 0 | 0 | 0.0% |
| **ALL** | **271** | **271** | **0** | **48458** | **100.0%** |

## Populated Tables (by platform)

### SQL Server
Connection/scan error: `[WinError 2] The system cannot find the file specified`

### PostgreSQL
| Schema | Table | Rows |
|---|---|---:|
| alvaria | clients | 246 |
| alvaria | dialogues | 226 |
| alvaria | finance_dialogues | 229 |
| alvaria | issues | 184 |
| alvaria | products | 241 |
| alvaria | relationship_managers | 160 |
| alvaria_crm | clients | 220 |
| alvaria_crm | dialogues | 442 |
| alvaria_crm | issues | 195 |
| alvaria_crm | products | 233 |
| connect | employees | 60 |
| connect | finance_learning_catalog_entries | 291 |
| connect | finance_learning_enrollments | 156 |
| connect | learning_paths | 171 |
| connect | learning_providers | 179 |
| connect | learning_resources | 1 |
| core_contact_repository | client_consents | 147 |
| core_contact_repository | client_contact_details | 198 |
| core_contact_repository | client_contact_preferences | 35 |
| core_contact_repository | client_digital_profiles | 182 |
| core_contact_repository | client_engagement_metrics | 127 |
| core_contact_repository | client_leasing_summaries | 136 |
| core_contact_repository | client_marketing_consents | 148 |
| core_contact_repository | client_personas | 330 |
| core_contact_repository | client_professional_profiles | 105 |
| core_contact_repository | client_risk_and_value_metrics | 167 |
| core_contact_repository | client_risk_profiles | 142 |
| core_contact_repository | clients | 120 |
| core_contact_repository | corporate_client_insights | 221 |
| core_contact_repository | corporate_finance_relationships | 60 |
| core_contact_repository | customer_financial_metrics | 87 |
| core_contact_repository | customer_note_tags | 135 |
| core_contact_repository | customer_segments | 273 |
| core_contact_repository | customers | 111 |
| core_contact_repository | finance_persona_data | 169 |
| core_contact_repository | finance_personas | 302 |
| core_contact_repository | financial_partners | 54 |
| core_contact_repository | industry_sectors | 1 |
| core_contact_repository | personal_finance_profiles | 94 |
| core_contact_repository | relationship_managers | 167 |
| core_contact_repository | relationship_product_portfolios | 147 |
| customer_care | client_mobility_snapshots | 188 |
| customer_care | clients | 232 |
| customer_care | corporate_finance_records_archive | 124 |
| customer_care | finance_record_archive | 90 |
| customer_care | private_finance_clients | 331 |
| customer_care | relationship_managers | 168 |
| customer_care | wealth_record_archive_dataset | 106 |
| global_credit_store | asset_types | 42 |
| global_credit_store | branches | 117 |
| global_credit_store | countries | 163 |
| global_credit_store | currencies | 70 |
| global_credit_store | industries | 105 |
| global_credit_store | lease_statuses | 42 |
| global_credit_store | leases | 144 |
| global_credit_store | lessee_customers | 157 |
| global_credit_store | masreph_entities | 65 |
| global_credit_store | origination_channels | 36 |
| global_credit_store | payment_frequencies | 585 |
| global_credit_store | portfolio_segments | 29 |
| global_credit_store | products | 133 |
| global_credit_store | salespersons | 267 |
| global_credit_store | source_systems | 151 |
| microsoft_dynamics_365 | branches | 188 |
| microsoft_dynamics_365 | client_consents | 153 |
| microsoft_dynamics_365 | client_engagement_metrics | 114 |
| microsoft_dynamics_365 | client_financial_profiles | 176 |
| microsoft_dynamics_365 | client_insight_finance_dataset | 143 |
| microsoft_dynamics_365 | client_insights | 232 |
| microsoft_dynamics_365 | client_segments | 24 |
| microsoft_dynamics_365 | client_tags | 260 |
| microsoft_dynamics_365 | clients | 263 |
| microsoft_dynamics_365 | customer_segments | 135 |
| microsoft_dynamics_365 | finance_crm_clients | 249 |
| microsoft_dynamics_365 | finance_crm_insights | 100 |
| microsoft_dynamics_365 | households | 128 |
| microsoft_dynamics_365 | income_bands | 175 |
| microsoft_dynamics_365 | property_loan_accounts | 232 |
| microsoft_dynamics_365 | relationship_managers | 188 |
| microsoft_dynamics_365 | risk_ratings | 100 |
| microsoft_dynamics_365_crm | client_segments | 125 |
| microsoft_dynamics_365_crm | clients | 292 |
| microsoft_dynamics_365_crm | industry_sectors | 182 |
| microsoft_dynamics_365_crm | relationship_managers | 53 |
| none | client_segments | 256 |
| none | retail_client_analytics | 109 |
| none | retail_client_complaint_stats | 91 |
| none | retail_client_consents | 99 |
| none | retail_client_contact_stats | 140 |
| none | retail_client_financials | 131 |
| none | retail_client_marketing_preferences | 38 |
| none | retail_client_risk_kyc | 152 |
| none | retail_clients | 250 |
| postgresql_global_credit_store | agreement_statuses | 4 |
| postgresql_global_credit_store | agreement_types | 4 |
| postgresql_global_credit_store | amortization_types | 4 |
| postgresql_global_credit_store | asia_pac_regions | 125 |
| postgresql_global_credit_store | asset_categories | 189 |
| postgresql_global_credit_store | asset_types | 16 |
| postgresql_global_credit_store | booking_branches | 150 |
| postgresql_global_credit_store | booking_entities | 69 |
| postgresql_global_credit_store | borrowers | 54 |
| postgresql_global_credit_store | branches | 181 |
| postgresql_global_credit_store | channels | 31 |
| postgresql_global_credit_store | collateral_asset_charges | 111 |
| postgresql_global_credit_store | collateral_assets | 97 |
| postgresql_global_credit_store | collateral_exposures | 93 |
| postgresql_global_credit_store | collateral_types | 49 |
| postgresql_global_credit_store | collateral_valuations | 183 |
| postgresql_global_credit_store | collaterals | 53 |
| postgresql_global_credit_store | counterparties | 104 |
| postgresql_global_credit_store | counterparty_regions | 83 |
| postgresql_global_credit_store | countries | 15 |
| postgresql_global_credit_store | credit_exposure_snapshots | 119 |
| postgresql_global_credit_store | credit_finance_agreements | 59 |
| postgresql_global_credit_store | credit_finance_offerings | 182 |
| postgresql_global_credit_store | credit_risk_grades | 9 |
| postgresql_global_credit_store | credit_risk_rating_early_warning_indicators | 137 |
| postgresql_global_credit_store | credit_risk_ratings | 153 |
| postgresql_global_credit_store | creditshield_finance_records | 77 |
| postgresql_global_credit_store | currencies | 198 |
| postgresql_global_credit_store | customer_segments | 218 |
| postgresql_global_credit_store | customers | 497 |
| postgresql_global_credit_store | data_privacy_classifications | 151 |
| postgresql_global_credit_store | data_source_systems | 79 |
| postgresql_global_credit_store | days_past_due_buckets | 89 |
| postgresql_global_credit_store | eba_default_statuses | 20 |
| postgresql_global_credit_store | exposure_groups | 138 |
| postgresql_global_credit_store | external_rating_agencies | 72 |
| postgresql_global_credit_store | facilities | 192 |
| postgresql_global_credit_store | industry_sectors | 80 |
| postgresql_global_credit_store | interest_rate_types | 21 |
| postgresql_global_credit_store | lease_contracts | 198 |
| postgresql_global_credit_store | lease_products | 100 |
| postgresql_global_credit_store | leased_assets | 111 |
| postgresql_global_credit_store | leases | 93 |
| postgresql_global_credit_store | leasing_contracts | 117 |
| postgresql_global_credit_store | leasing_credit_exposures | 111 |
| postgresql_global_credit_store | leasing_products | 170 |
| postgresql_global_credit_store | lessee_customers | 370 |
| postgresql_global_credit_store | lessor_legal_entities | 70 |
| postgresql_global_credit_store | operational_risk_events | 341 |
| postgresql_global_credit_store | origination_officers | 91 |
| postgresql_global_credit_store | payment_frequencies | 497 |
| postgresql_global_credit_store | portfolio_segments | 17 |
| postgresql_global_credit_store | pricing_strategies | 90 |
| postgresql_global_credit_store | product_families | 236 |
| postgresql_global_credit_store | product_types | 26 |
| postgresql_global_credit_store | rating_models | 63 |
| postgresql_global_credit_store | reference_rates | 50 |
| postgresql_global_credit_store | regulatory_portfolios | 69 |
| postgresql_global_credit_store | regulatory_product_categories | 262 |
| postgresql_global_credit_store | risk_finance_data_set | 165 |
| postgresql_global_credit_store | risk_finance_records | 165 |
| postgresql_global_credit_store | risk_grades | 9 |
| postgresql_global_credit_store | sales_channels | 50 |
| postgresql_global_credit_store | source_systems | 115 |
| profile_app | creditrisk_finance_dataset | 152 |
| profile_app | finance_profile_consents | 79 |
| profile_app | finance_profile_financials | 81 |
| profile_app | finance_profile_relationship_metrics | 148 |
| profile_app | finance_profile_risk_metrics | 114 |
| profile_app | finance_profiles | 437 |
| salesforce_customer_insights | accounts | 418 |
| salesforce_customer_insights | call_center_agents | 174 |
| salesforce_customer_insights | client_churn_and_offers | 107 |
| salesforce_customer_insights | client_consents | 144 |
| salesforce_customer_insights | client_contact_preferences | 30 |
| salesforce_customer_insights | client_crm_states | 119 |
| salesforce_customer_insights | client_cross_sell_insights | 140 |
| salesforce_customer_insights | client_financial_summaries | 118 |
| salesforce_customer_insights | client_kyc_risk_assessments | 116 |
| salesforce_customer_insights | client_mobility_engagements | 128 |
| salesforce_customer_insights | client_segments | 19 |
| salesforce_customer_insights | clients | 192 |
| salesforce_customer_insights | corporate_groups | 145 |
| salesforce_customer_insights | finance_activity_logs | 348 |
| salesforce_customer_insights | finance_reviews | 134 |
| salesforce_customer_insights | households | 154 |
| salesforce_customer_insights | industries | 130 |
| salesforce_customer_insights | interactions | 189 |
| salesforce_customer_insights | lead_analytics | 88 |
| salesforce_customer_insights | lead_engagement_metrics | 84 |
| salesforce_customer_insights | leads | 120 |
| salesforce_customer_insights | marketing_campaigns | 91 |
| salesforce_customer_insights | mobility_contracts | 207 |
| salesforce_customer_insights | persons | 50 |
| salesforce_customer_insights | relationship_managers | 154 |
| salesforce_customer_insights | transactions | 785 |
| salesforce_customer_insights | vehicles | 199 |
| sf_crm_a | clearing_firm_clients | 191 |
| sf_crm_a | clearing_firm_data_insights | 114 |
| sf_crm_a | relationship_managers | 155 |
| sf_crm_a | third_settlement_parties | 105 |

### MySQL
| Database | Table | Rows |
|---|---|---:|
| masreph_american_office_systems | advice_cost_process_data | 563 |
| masreph_digital_payment_tokens | digital_payment_tokens_dataset | 412 |
| masreph_docuverify | docuverify_finance_dataset | 248 |
| masreph_duocircle | client_email_feedback_dataset | 846 |
| masreph_email_analytics | finance_email_analytics | 147 |
| masreph_epos_now | cashflow_at_schiphol_finance_dataset | 461 |
| masreph_it_data_analysis | it_investment | 161 |
| masreph_it_digital | service | 168 |
| masreph_it_digital | service_owner | 102 |
| masreph_marketing_dwh | finance_segmentation_insights | 508 |
| masreph_masreph_email_analytics | email_analytics_record | 2 |
| masreph_masreph_web_mobile_message_store | client | 3 |
| masreph_masreph_web_mobile_message_store | secure_message_analytic | 200 |
| masreph_masreph_web_mobile_message_store | secure_message_thread | 195 |
| masreph_microacquire | trade_finance_collateral_dataset | 200 |
| masreph_microacquire_digital | collateral | 313 |
| masreph_microacquire_digital | trade_finance_collateral | 151 |
| masreph_ms_office | finance_call_insights | 604 |
| masreph_none | lease_contract | 148 |
| masreph_none | settlement_event | 696 |
| masreph_none | source_system | 195 |
| masreph_none | third_settlement_party | 113 |
| masreph_pandadoc | bundle_finance_data | 98 |
| masreph_pandadoc_digital | bundle_finance_product | 304 |
| masreph_processmaker | commercial_finance_forms | 457 |
| masreph_processmaker | consumer_finance_forms_dataset | 308 |
| masreph_sendgrid | finance_email_analytics | 149 |
| masreph_startsida | customer_finance_data | 709 |
| masreph_startsida | customer_info_finance | 517 |
| masreph_unknown | it_data_analysis_dataset | 182 |
| masreph_wati | digital_finance_messages | 420 |
| masreph_wati | secure_finance_messages | 72 |
| masreph_wati_digital | digital_finance_message | 237 |
| masreph_web_mobile_message_store | finance_message_data | 159 |
| masreph_web_mobile_message_store | secure_message_analytics | 362 |
| masreph_whispe | agent | 147 |
| masreph_whispe | call_interaction | 129 |
| masreph_whispe | customer | 403 |
| masreph_whispe_speech_recognition | call_insight_finance_dataset | 529 |

### Snowflake
| Schema | Table | Rows |
|---|---|---:|
| ACTICO | CREDIT_RISK_DATASET | 116 |
| ACTICO | CREDIT_RISK_FINANCE_DATASET | 183 |
| ACTICO | FINANCEPROVISION_INSIGHTS | 191 |
| ACTICO | FINANCE_DEFAULT_INSIGHTS | 135 |
| ACTICO | PROVISION_FINANCE_DATASET | 186 |
| ACTICO | RISKWATCH_FINANCE_DATASET | 80 |
| ACTICO | RISK_WATCH_FINANCE_DATASET | 347 |
| COMPLIANCE_ARCHIVE | CLIENT_FILE_ARCHIVE | 222 |
| CRC_SYSTEMS | FINANCE_PORTFOLIO_CONTRACTS | 169 |
| CREDIT_RISK_CONTROLS | CREDIT_PAYMENT_AGREEMENTS_DATASET | 487 |
| CREDIT_RISK_INSIGHTS | CREDIT_RISK_INSIGHTS_DATASET | 167 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDITRISK_ANALYTICS_DATASET | 162 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDITRISK_FINANCE_DATASET | 72 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDIT_RISK_ANALYTICS_DATASET | 185 |
| ESRB_RATINGS | FINANCE_ACTIVITY_TARIFFS | 1300 |
| ESRB_RATINGS | MASREPH_FINANCE_PORTFOLIO | 242 |
| ESRB_RATINGS | QUOTAFLEX_FINANCE_DATASET | 136 |
| ESRB_RATINGS | QUOTAFLEX_FINANCE_TERMS | 155 |
| EUROCOMPLY | EUROCOMPLY_FINANCE_FILTER | 111 |
| EUROCOMPLY | EUROWIRE_COMPLIANCE_DATA | 81 |
| EUROCOMPLY | EUROWIRE_COMPLIANCE_DATASET | 173 |
| JUMIO_RISK_SIGNALS | CREDIT_RISK_INSIGHTS_DATASET | 107 |
| RACCENT | FINANCE_CONTACT_INFORMATION_DATASET | 185 |
| RACCENT | FORBEARANCE_FINANCE_DATA_SET | 132 |
| RACCENT | PARTNER_FINANCE_DISTRIBUTION_DATA | 172 |
| RISKCONNECT | RISKCONNECT_FINANCE_DATASET | 61 |
| SANCTION_SCANNER | FINANCE_ENTITY_RISK_ANALYSIS | 51 |
| SANCTION_SCANNER | FINANCE_RISK_INSIGHTS | 142 |
| SANCTION_SCANNER | RISKFLOW_FINANCE_DATASET | 160 |
| TRULIOO | FINANCE_CRIME_DETECTION_DATASET | 135 |
| TRULIOO | FINANCE_WATCH_HK | 117 |
| TRULIOO | SINGAPORE_FINANCIAL_CRIME_DATASET | 109 |
| VERIFF | GLOBAL_CLIENT_COMPLIANCE_DATA | 602 |
| VERIFF | GLOBAL_CLIENT_SCREENING_DATA | 259 |

### Oracle
Connection/scan error: `DPY-4026: file '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\tnsnames.ora' is missing or unreadable
[WinError 3] The system cannot find the path specified: '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\\tnsnames.ora'`

### MongoDB
| Database | Collection | Rows |
|---|---|---:|
| masreph_masrephappregistry | masrephAppRegistry | 188 |
| masreph_mdpglobalapi | mortgageFinanceProfile | 491 |
| masreph_redaktasr | docuVerifyFinanceDataset | 84 |
| masreph_redaktde | docuVerifyFinanceDataset | 79 |

### Databricks
Connection/scan error: `This Azure storage request is not authorized. The storage account's 'Firewalls and virtual networks' settings may be blocking access to storage services. Please verify your Azure storage credentials or firewall exception settings.`

### Fabric
Connection/scan error: `('IM002', '[IM002] [Microsoft][ODBC Driver Manager] Data source name not found and no default driver specified (0) (SQLDriverConnect)')`

## Empty Tables (by platform)

### SQL Server
Connection/scan error: `[WinError 2] The system cannot find the file specified`

### PostgreSQL
| Schema | Table |
|---|---|
| None — all tables/collections have data |  |

### MySQL
| Database | Table |
|---|---|
| None — all tables/collections have data |  |

### Snowflake
| Schema | Table |
|---|---|
| None — all tables/collections have data |  |

### Oracle
Connection/scan error: `DPY-4026: file '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\tnsnames.ora' is missing or unreadable
[WinError 3] The system cannot find the path specified: '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\\tnsnames.ora'`

### MongoDB
| Database | Collection |
|---|---|
| None — all tables/collections have data |  |

### Databricks
Connection/scan error: `This Azure storage request is not authorized. The storage account's 'Firewalls and virtual networks' settings may be blocking access to storage services. Please verify your Azure storage credentials or firewall exception settings.`

### Fabric
Connection/scan error: `('IM002', '[IM002] [Microsoft][ODBC Driver Manager] Data source name not found and no default driver specified (0) (SQLDriverConnect)')`

## Analysis
- Best population rate: **PostgreSQL** at **100.0%**.
- Lowest population rate: **MongoDB** at **100.0%**.
- Common empty-table pattern: dimension/reference and auxiliary analytics tables are often empty while a small set of primary transaction/customer tables are populated.
- Cross-platform pattern: table families with similar names (risk/insight/snapshot/registry) frequently remain empty after deployment, suggesting partial load scripts or dependency ordering gaps.
- Potential root causes: FK load order, connector type coercion failures, and platform-specific DDL/data type differences during generation.
- Recommended next fix priority (by empty table count): PostgreSQL (0/194), MySQL (0/39), Snowflake (0/34), MongoDB (0/4).
- Connection issues encountered: sql-server: [WinError 2] The system cannot find the file specified; oracle: DPY-4026: file '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\tnsnames.ora' is missing or unreadable
[WinError 3] The system cannot find the path specified: '/mnt/c/Users/Hicham/OneDrive/python/projects/masreph/config/oracle_wallet\\tnsnames.ora'; databricks: This Azure storage request is not authorized. The storage account's 'Firewalls and virtual networks' settings may be blocking access to storage services. Please verify your Azure storage credentials or firewall exception settings.; fabric: ('IM002', '[IM002] [Microsoft][ODBC Driver Manager] Data source name not found and no default driver specified (0) (SQLDriverConnect)').

