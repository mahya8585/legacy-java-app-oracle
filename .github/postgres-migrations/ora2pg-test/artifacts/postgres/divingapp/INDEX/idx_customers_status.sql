-- PostgreSQL DDL for divingapp.idx_customers_status (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_CUSTOMERS_STATUS.sql
-- Generated at: 2026-04-03T15:26:02.018835

CREATE INDEX IF NOT EXISTS idx_customers_status ON divingapp.customers (status);