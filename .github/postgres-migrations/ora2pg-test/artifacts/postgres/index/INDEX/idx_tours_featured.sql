-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_FEATURED.sql
-- Generated at: 2026-04-03T15:26:03.995249

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_FEATURED.sql
CREATE INDEX IF NOT EXISTS idx_tours_featured ON divingapp.tours (featured_flag);