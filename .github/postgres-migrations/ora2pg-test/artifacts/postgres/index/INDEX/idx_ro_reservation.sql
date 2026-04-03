-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RO_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.370630

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RO_RESERVATION.sql
CREATE INDEX IF NOT EXISTS idx_ro_reservation ON divingapp.reservation_options (reservation_id);