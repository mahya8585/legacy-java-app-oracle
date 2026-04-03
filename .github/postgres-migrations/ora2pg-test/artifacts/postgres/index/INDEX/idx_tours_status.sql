-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_STATUS.sql
-- Generated at: 2026-04-03T15:26:03.997764

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_tours_status ON divingapp.tours (status);