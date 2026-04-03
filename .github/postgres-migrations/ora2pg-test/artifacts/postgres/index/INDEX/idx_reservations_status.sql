-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RESERVATIONS_STATUS.sql
-- Generated at: 2026-04-03T15:26:04.284536

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RESERVATIONS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_reservations_status ON divingapp.reservations (status);