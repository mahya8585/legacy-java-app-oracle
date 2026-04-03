-- PostgreSQL DDL for divingapp.idx_reservations_status (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RESERVATIONS_STATUS.sql
-- Generated at: 2026-04-03T15:26:02.049126

CREATE INDEX IF NOT EXISTS idx_reservations_status ON divingapp.reservations (status);