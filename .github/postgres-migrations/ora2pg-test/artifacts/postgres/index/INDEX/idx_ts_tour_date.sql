-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TS_TOUR_DATE.sql
-- Generated at: 2026-04-03T15:26:04.071913

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TS_TOUR_DATE.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_date ON divingapp.tour_schedules (tour_date);