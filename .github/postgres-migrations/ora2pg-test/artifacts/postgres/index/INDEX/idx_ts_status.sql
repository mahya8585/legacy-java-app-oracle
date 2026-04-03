-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TS_STATUS.sql
-- Generated at: 2026-04-03T15:26:04.288384

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_ts_status ON divingapp.tour_schedules (status);