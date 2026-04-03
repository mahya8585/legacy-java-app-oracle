-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_CUSTOMERS_STATUS.sql
-- Generated at: 2026-04-03T15:26:03.976555

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_CUSTOMERS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_customers_status ON divingapp.customers (status);