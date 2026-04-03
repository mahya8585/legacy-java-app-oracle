-- PostgreSQL DDL for divingapp.idx_dl_customer (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_DL_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:02.093816

CREATE INDEX IF NOT EXISTS idx_dl_customer ON divingapp.diving_logs (customer_id);