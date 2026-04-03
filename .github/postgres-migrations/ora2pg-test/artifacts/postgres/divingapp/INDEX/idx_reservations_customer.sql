-- PostgreSQL DDL for divingapp.idx_reservations_customer (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RESERVATIONS_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:02.095952

CREATE INDEX IF NOT EXISTS idx_reservations_customer ON divingapp.reservations (customer_id);