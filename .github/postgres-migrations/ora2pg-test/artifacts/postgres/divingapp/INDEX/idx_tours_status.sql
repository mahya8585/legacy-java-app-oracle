-- PostgreSQL DDL for divingapp.idx_tours_status (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_STATUS.sql
-- Generated at: 2026-04-03T15:26:02.028156

CREATE INDEX IF NOT EXISTS idx_tours_status ON divingapp.tours (status);