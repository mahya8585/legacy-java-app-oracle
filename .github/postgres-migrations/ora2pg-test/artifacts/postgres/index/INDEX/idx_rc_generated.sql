-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RC_GENERATED.sql
-- Generated at: 2026-04-03T15:26:03.553433

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RC_GENERATED.sql
CREATE INDEX IF NOT EXISTS idx_rc_generated ON divingapp.report_cache (generated_at);