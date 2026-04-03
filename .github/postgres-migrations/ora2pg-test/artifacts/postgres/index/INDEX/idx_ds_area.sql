-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_DS_AREA.sql
-- Generated at: 2026-04-03T15:26:03.551424

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_DS_AREA.sql
CREATE INDEX IF NOT EXISTS idx_ds_area ON divingapp.dive_sites (area);