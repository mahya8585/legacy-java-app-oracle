-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_DL_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:04.347196

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_DL_CUSTOMER.sql
CREATE INDEX IF NOT EXISTS idx_dl_customer ON divingapp.diving_logs (customer_id);