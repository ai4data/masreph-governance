# Empty Tables Report — All 8 Platforms

## Summary
| Platform | Total Tables | Tables with Data | Empty Tables | % Empty |
|---|---:|---:|---:|---:|
| SQL Server | 256 | 161 | 95 | 37.1% |
| PostgreSQL | 194 | 84 | 110 | 56.7% |
| MySQL | 39 | 13 | 26 | 66.7% |
| Snowflake | 34 | 11 | 23 | 67.6% |
| Oracle | 17 | 17 | 0 | 0.0% |
| MongoDB | 4 | 4 | 0 | 0.0% |
| Databricks | 33 | 12 | 21 | 63.6% |
| Fabric | 26 | 11 | 15 | 57.7% |
| **ALL** | **603** | **313** | **290** | **48.1%** |

## Empty Tables by Platform

### SQL Server
| Database | Table | Columns |
|---|---|---:|
| Masreph_accountlimittracker | tblCustomer | 10 |
| Masreph_accountlimittracker | tblLoanFacility | 10 |
| Masreph_accountlimittracker | tblLoanFacilitySnapshot | 25 |
| Masreph_accountnumber | tblFinanceAccountSnapshot | 44 |
| Masreph_accountnumber | tblProduct | 7 |
| Masreph_afadfinancestore | tblAuthorizedFinanceAgent | 48 |
| Masreph_appello | Customer | 11 |
| Masreph_appello | LoanContract | 9 |
| Masreph_appello | tblLoanAccount | 20 |
| Masreph_appello | tblLoanRiskProfile | 14 |
| Masreph_calypsox | tblFinanceRepoInsight | 35 |
| Masreph_calypsoxi | tblTradeFinanceInsight | 41 |
| Masreph_ccosm | tblLoanAccount | 29 |
| Masreph_ccosm | tblFinanceJourneyInsight | 27 |
| Masreph_compliancetransactionservice | tblCustomerComplianceProfile | 12 |
| Masreph_compliancetransactionservice | tblLeaseContract | 8 |
| Masreph_compliancetransactionservice | tblComplianceTransaction | 32 |
| Masreph_corepaymentoperations | tblSepaTransaction | 47 |
| Masreph_corepaymentoperations | tblCustomer | 8 |
| Masreph_corepaymentoperations | tblProduct | 5 |
| Masreph_creditdatafinance | tblLoanAccount | 29 |
| Masreph_creditdatafinance | tblLoanAccountSnapshot | 20 |
| Masreph_crossborderpaymentoperations | tblCustomer | 6 |
| Masreph_crossborderpaymentoperations | tblPayment | 46 |
| Masreph_dfmstore | tblFinanceBehaviouralInsight | 27 |
| Masreph_dfmstore | tblCoBorrower | 12 |
| Masreph_dfmstore | tblCoBorrowerRating | 40 |
| Masreph_financeadvisornetworksystem | tblClient | 14 |
| Masreph_financeadvisornetworksystem | tblMortgageConsent | 26 |
| Masreph_financeadvisornetworksystem | tblMortgageApplication | 25 |
| Masreph_financenetwork | TblClient | 23 |
| Masreph_financenetwork | TblClientRelationship | 27 |
| Masreph_financenetworkservice | tblClient | 21 |
| Masreph_financenetworkservice | tblRelationship | 31 |
| Masreph_financeprospectid | tblClient | 12 |
| Masreph_financeprospectid | tblClientWealthProfile | 29 |
| Masreph_financeprospectid | tblClientContactPreference | 15 |
| Masreph_financeprospectid | tblClientContactConsent | 5 |
| Masreph_financeprospectid | tblProspectLifecycle | 8 |
| Masreph_finfluxcredit | tblCollateral | 39 |
| Masreph_finfluxcredit | tblCollateralDocument | 4 |
| Masreph_finfluxcredit | tblCustomer | 8 |
| Masreph_finfluxcredit | tblLeaseContract | 32 |
| Masreph_finfluxcredit | tblLeasePaymentStatus | 10 |
| Masreph_finfluxcredit | tblLeaseRiskProfile | 14 |
| Masreph_finfluxcredit | tblCollateralValuation | 6 |
| Masreph_finfluxcredit | tblProduct | 6 |
| Masreph_finfluxcredit | tblCollateralRisk | 7 |
| Masreph_finfluxcredit | tblCreditAgreement | 36 |
| Masreph_finhub | tblClient | 12 |
| Masreph_insuredatafinancecatalog | Customer | 19 |
| Masreph_insuredatafinancecatalog | CustomerSegment | 5 |
| Masreph_insuredatafinancecatalog | tblCustomerConsent | 9 |
| Masreph_insuredatafinancecatalog | tblCustomerEngagement | 20 |
| Masreph_insuredatafinancecatalog | tblCustomerRiskProfitability | 10 |
| Masreph_masrephproductcontractregistry | tblCustomer | 9 |
| Masreph_masrephproductcontractregistry | tblFinancialProduct | 50 |
| Masreph_moderncorepayments | tblClientContactPreference | 10 |
| Masreph_mortgagefinancecalculator | tblMortgageCalculation | 26 |
| Masreph_paymenttracker | tblPaymentProgress | 32 |
| Masreph_realestate | tblMortgageApplicant | 19 |
| Masreph_realestate | tblMortgageApplication | 31 |
| Masreph_realestate | AssetPledge | 16 |
| Masreph_realestate | tblAssetValuation | 15 |
| Masreph_realestate | tblCollateralInsurance | 6 |
| Masreph_realestatesqlserver | tblMortgageApplicant | 22 |
| Masreph_realestatesqlserver | tblMortgageApplication | 25 |
| Masreph_riskwatchfinance | TblCustomer | 6 |
| Masreph_riskwatchfinance | TblLoanApplication | 9 |
| Masreph_riskwatchfinance | TblLoan | 22 |
| Masreph_riskwatchfinance | TblLoanRiskAssessment | 16 |
| Masreph_riskwatchfinance | TblLoanCollateral | 5 |
| Masreph_riskwatchfinance | TblLoanStatus | 10 |
| Masreph_securefinance | TblClient | 32 |
| Masreph_securefinance | TblClientCommunication | 17 |
| Masreph_sepamandateverification | tblSepaPaymentRule | 52 |
| Masreph_streamlinepayments | tblFinanceAuthorization | 40 |
| Masreph_transactfinance | TblClientPersonaSnapshot | 26 |
| Masreph_transactfinance | tblClientLegalEntity | 16 |
| Masreph_transactfinance | tblCustomer | 19 |
| Masreph_transactfinance | tblDepositAccount | 15 |
| Masreph_transactfinance | WealthDepositInsightsSnapshot | 26 |
| Masreph_transactfinance | tblFinanceNetworkEdge | 21 |
| Masreph_transactfinance | tblCorporateCustomer | 12 |
| Masreph_transactfinance | tblLeasingProduct | 5 |
| Masreph_transactfinance | tblCorporateDeposit | 36 |
| Masreph_transactfinance | tblClientPersona | 18 |
| Masreph_transactfinance | tblClientPersonaRiskExposure | 9 |
| Masreph_transactfinance | tblClientPersonaContact | 10 |
| Masreph_transactfinance | tblClientPersonaAnalytics | 7 |
| Masreph_transactfinance | tblFinancePersona | 51 |
| Masreph_transactfinance | tblPropertyFinanceRecord | 15 |
| Masreph_transactfinance | tblFinanceAccount | 32 |
| Masreph_transactfinance | TblClientCore | 21 |
| Masreph_wenmasrephstore | tblClientFinanceStatementSnapshot | 38 |

### PostgreSQL
| Schema | Table | Columns |
|---|---|---:|
| alvaria | dialogues | 39 |
| alvaria | finance_dialogues | 43 |
| alvaria_crm | dialogues | 40 |
| connect | employees | 9 |
| connect | finance_learning_catalog_entries | 10 |
| connect | finance_learning_enrollments | 12 |
| connect | learning_resources | 26 |
| core_contact_repository | client_consents | 6 |
| core_contact_repository | client_contact_details | 6 |
| core_contact_repository | client_contact_preferences | 13 |
| core_contact_repository | client_digital_profiles | 6 |
| core_contact_repository | client_engagement_metrics | 9 |
| core_contact_repository | client_leasing_summaries | 9 |
| core_contact_repository | client_marketing_consents | 7 |
| core_contact_repository | client_professional_profiles | 5 |
| core_contact_repository | client_risk_and_value_metrics | 13 |
| core_contact_repository | client_risk_profiles | 6 |
| core_contact_repository | clients | 48 |
| core_contact_repository | corporate_client_insights | 40 |
| core_contact_repository | corporate_finance_relationships | 20 |
| core_contact_repository | customer_financial_metrics | 15 |
| core_contact_repository | customer_note_tags | 5 |
| core_contact_repository | customer_segments | 5 |
| core_contact_repository | customers | 24 |
| core_contact_repository | finance_persona_data | 42 |
| core_contact_repository | personal_finance_profiles | 28 |
| customer_care | client_mobility_snapshots | 32 |
| customer_care | corporate_finance_records_archive | 52 |
| customer_care | finance_record_archive | 46 |
| customer_care | wealth_record_archive_dataset | 48 |
| global_credit_store | industries | 4 |
| global_credit_store | lease_statuses | 4 |
| global_credit_store | leases | 46 |
| global_credit_store | lessee_customers | 7 |
| global_credit_store | products | 5 |
| microsoft_dynamics_365 | branches | 5 |
| microsoft_dynamics_365 | client_consents | 5 |
| microsoft_dynamics_365 | client_engagement_metrics | 6 |
| microsoft_dynamics_365 | client_financial_profiles | 11 |
| microsoft_dynamics_365 | client_insight_finance_dataset | 52 |
| microsoft_dynamics_365 | client_insights | 16 |
| microsoft_dynamics_365 | client_tags | 5 |
| microsoft_dynamics_365 | clients | 19 |
| microsoft_dynamics_365 | customer_segments | 5 |
| microsoft_dynamics_365 | finance_crm_clients | 37 |
| microsoft_dynamics_365 | finance_crm_insights | 36 |
| microsoft_dynamics_365 | income_bands | 4 |
| microsoft_dynamics_365 | property_loan_accounts | 15 |
| microsoft_dynamics_365 | relationship_managers | 5 |
| microsoft_dynamics_365 | risk_ratings | 4 |
| microsoft_dynamics_365_crm | client_segments | 5 |
| microsoft_dynamics_365_crm | clients | 31 |
| microsoft_dynamics_365_crm | industry_sectors | 5 |
| none | client_segments | 5 |
| none | retail_client_analytics | 8 |
| none | retail_client_complaint_stats | 6 |
| none | retail_client_consents | 8 |
| none | retail_client_contact_stats | 7 |
| none | retail_client_financials | 11 |
| none | retail_client_marketing_preferences | 7 |
| none | retail_client_risk_kyc | 6 |
| none | retail_clients | 19 |
| postgresql_global_credit_store | booking_branches | 4 |
| postgresql_global_credit_store | borrowers | 8 |
| postgresql_global_credit_store | collateral_asset_charges | 5 |
| postgresql_global_credit_store | collateral_exposures | 25 |
| postgresql_global_credit_store | collateral_valuations | 10 |
| postgresql_global_credit_store | collaterals | 12 |
| postgresql_global_credit_store | credit_exposure_snapshots | 34 |
| postgresql_global_credit_store | credit_finance_agreements | 40 |
| postgresql_global_credit_store | credit_finance_offerings | 42 |
| postgresql_global_credit_store | credit_risk_rating_early_warning_indicators | 5 |
| postgresql_global_credit_store | credit_risk_ratings | 28 |
| postgresql_global_credit_store | creditshield_finance_records | 16 |
| postgresql_global_credit_store | customer_segments | 4 |
| postgresql_global_credit_store | facilities | 10 |
| postgresql_global_credit_store | industry_sectors | 4 |
| postgresql_global_credit_store | lease_contracts | 13 |
| postgresql_global_credit_store | leased_assets | 7 |
| postgresql_global_credit_store | leases | 35 |
| postgresql_global_credit_store | leasing_contracts | 15 |
| postgresql_global_credit_store | leasing_credit_exposures | 43 |
| postgresql_global_credit_store | operational_risk_events | 6 |
| postgresql_global_credit_store | origination_officers | 4 |
| postgresql_global_credit_store | product_types | 4 |
| postgresql_global_credit_store | risk_finance_data_set | 49 |
| postgresql_global_credit_store | risk_finance_records | 25 |
| postgresql_global_credit_store | source_systems | 4 |
| profile_app | creditrisk_finance_dataset | 44 |
| profile_app | finance_profile_consents | 7 |
| profile_app | finance_profile_financials | 13 |
| profile_app | finance_profile_relationship_metrics | 8 |
| profile_app | finance_profile_risk_metrics | 8 |
| salesforce_customer_insights | client_churn_and_offers | 7 |
| salesforce_customer_insights | client_consents | 6 |
| salesforce_customer_insights | client_contact_preferences | 9 |
| salesforce_customer_insights | client_crm_states | 13 |
| salesforce_customer_insights | client_cross_sell_insights | 8 |
| salesforce_customer_insights | client_financial_summaries | 13 |
| salesforce_customer_insights | client_kyc_risk_assessments | 7 |
| salesforce_customer_insights | client_mobility_engagements | 8 |
| salesforce_customer_insights | clients | 18 |
| salesforce_customer_insights | finance_activity_logs | 39 |
| salesforce_customer_insights | industries | 4 |
| salesforce_customer_insights | lead_analytics | 14 |
| salesforce_customer_insights | lead_engagement_metrics | 6 |
| salesforce_customer_insights | leads | 28 |
| salesforce_customer_insights | persons | 13 |
| sf_crm_a | clearing_firm_clients | 46 |
| sf_crm_a | clearing_firm_data_insights | 44 |

### MySQL
| Database | Table | Columns |
|---|---|---:|
| masreph_american_office_systems | advice_cost_process_data | 27 |
| masreph_docuverify | docuverify_finance_dataset | 35 |
| masreph_duocircle | client_email_feedback_dataset | 21 |
| masreph_email_analytics | finance_email_analytics | 41 |
| masreph_epos_now | cashflow_at_schiphol_finance_dataset | 44 |
| masreph_it_digital | service | 44 |
| masreph_marketing_dwh | finance_segmentation_insights | 35 |
| masreph_masreph_email_analytics | email_analytics_record | 45 |
| masreph_masreph_web_mobile_message_store | client | 13 |
| masreph_masreph_web_mobile_message_store | secure_message_analytic | 32 |
| masreph_microacquire | trade_finance_collateral_dataset | 49 |
| masreph_microacquire_digital | collateral | 48 |
| masreph_ms_office | finance_call_insights | 46 |
| masreph_none | settlement_event | 20 |
| masreph_pandadoc | bundle_finance_data | 48 |
| masreph_pandadoc_digital | bundle_finance_product | 23 |
| masreph_processmaker | commercial_finance_forms | 38 |
| masreph_processmaker | consumer_finance_forms_dataset | 18 |
| masreph_sendgrid | finance_email_analytics | 32 |
| masreph_startsida | customer_finance_data | 31 |
| masreph_startsida | customer_info_finance | 40 |
| masreph_wati | digital_finance_messages | 14 |
| masreph_wati_digital | digital_finance_message | 13 |
| masreph_web_mobile_message_store | secure_message_analytics | 49 |
| masreph_whispe | call_interaction | 16 |
| masreph_whispe_speech_recognition | call_insight_finance_dataset | 26 |

### Snowflake
| Schema | Table | Columns |
|---|---|---:|
| ACTICO | CREDIT_RISK_DATASET | 9 |
| ACTICO | FINANCEPROVISION_INSIGHTS | 45 |
| ACTICO | FINANCE_DEFAULT_INSIGHTS | 49 |
| ACTICO | RISKWATCH_FINANCE_DATASET | 53 |
| COMPLIANCE_ARCHIVE | CLIENT_FILE_ARCHIVE | 29 |
| CRC_SYSTEMS | FINANCE_PORTFOLIO_CONTRACTS | 52 |
| CREDIT_RISK_CONTROLS | CREDIT_PAYMENT_AGREEMENTS_DATASET | 55 |
| CREDIT_RISK_INSIGHTS | CREDIT_RISK_INSIGHTS_DATASET | 47 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDITRISK_ANALYTICS_DATASET | 37 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDITRISK_FINANCE_DATASET | 38 |
| ENDORSEMENT_EVALUATIO_APPLICATION | CREDIT_RISK_ANALYTICS_DATASET | 9 |
| ESRB_RATINGS | QUOTAFLEX_FINANCE_DATASET | 49 |
| ESRB_RATINGS | QUOTAFLEX_FINANCE_TERMS | 31 |
| EUROCOMPLY | EUROCOMPLY_FINANCE_FILTER | 53 |
| EUROCOMPLY | EUROWIRE_COMPLIANCE_DATA | 51 |
| JUMIO_RISK_SIGNALS | CREDIT_RISK_INSIGHTS_DATASET | 47 |
| RACCENT | FINANCE_CONTACT_INFORMATION_DATASET | 41 |
| RACCENT | FORBEARANCE_FINANCE_DATA_SET | 40 |
| RACCENT | PARTNER_FINANCE_DISTRIBUTION_DATA | 54 |
| RISKCONNECT | RISKCONNECT_FINANCE_DATASET | 45 |
| SANCTION_SCANNER | FINANCE_ENTITY_RISK_ANALYSIS | 9 |
| SANCTION_SCANNER | RISKFLOW_FINANCE_DATASET | 49 |
| TRULIOO | SINGAPORE_FINANCIAL_CRIME_DATASET | 58 |

### Oracle
| Table | Columns |
|---|---:|
| None — all tables have data |  |

### MongoDB
| Database | Collection | Fields |
|---|---|---:|
| None — all collections have data |  |  |

### Databricks
| Schema | Table | Columns |
|---|---|---:|
| actico | credit_risk_finance_dataset | 42 |
| actico | financeprovision_insights | 43 |
| afad_finance_store | authorized_finance_agents_dataset | 45 |
| compliance_transaction_service | compliance_transaction_filter_dataset | 50 |
| core_contact_repository | finance_persona_data | 51 |
| credit_finance_service | credit_risk_ratings_dataset_ | 50 |
| dataedo_crdm | finance_segmentation_table | 42 |
| esrb_ratings | quotaflex_finance_terms | 41 |
| eventstream | finance360_customer_journey | 52 |
| famal_cc_ai | credit_finance_onboarding_dataset | 39 |
| ids_ii | non_contact_finance_registry | 45 |
| memverge | privclientfindata | 51 |
| microsoft_dynamics_365 | finance_crm_insights | 44 |
| mosaic_tech | finance_exposure_data | 45 |
| salesforce_customer_insights | finance_review_tracker | 52 |
| salesforce_customer_insights | propensity_cube_leads_dataset_ | 39 |
| salesforce_customer_insights | revmax_finance_dataset | 44 |
| salesforce_customer_insights | revtrack_finance_data | 53 |
| salesforce_customer_insights | trade_finance_crm_data | 52 |
| trulioo_nl | finance_crime_detection_dataset | 53 |
| unknown | finance_data_analysis_dataset | 47 |

### Fabric
| Schema | Table | Columns |
|---|---|---:|
| beyondtrust | SecureFinanceAccessDatasetSFAD | 23 |
| bluedolphin | FinanceCapModelData | 50 |
| bmc | LegalFinanceArchiveDataset | 47 |
| dataedocrdm | FeeFinanceClassificationDataset | 51 |
| dataedocrdm | FeeFinanceDataset | 46 |
| dataedocrdm | FinanceRelationshipCategories | 43 |
| dataedocrdm | FinanceRollupOverview | 38 |
| dataedocrdm | InterestMappingDataset | 52 |
| dataedocrdm | LiquidityFinanceContractsDataset | 41 |
| dataedocrdm | RateClassificationDataset | 48 |
| hoc | RiskFinanceInsightsDataset | 29 |
| hrworkforcestore | MasrephWorkforceInsights | 50 |
| qualys | RiskclassificationdataABL | 53 |
| talentpool | NLFinanceTalentPool | 49 |
| talentpool | NetherlandsFinancePersonnelData | 30 |

