-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RA_DETECTED.sql
-- Generated at: 2026-04-03T15:26:03.976555

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RA_DETECTED.sql
CREATE INDEX IF NOT EXISTS idx_ra_detected ON divingapp.report_alerts (detected_at, status);