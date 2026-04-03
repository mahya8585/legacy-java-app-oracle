-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RC_KEY_SECTION.sql
-- Generated at: 2026-04-03T15:26:03.553433

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RC_KEY_SECTION.sql
CREATE INDEX IF NOT EXISTS idx_rc_key_section ON divingapp.report_cache (report_key, section);