-- PostgreSQL DDL for divingapp.idx_rc_key_section (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RC_KEY_SECTION.sql
-- Generated at: 2026-04-03T15:26:01.985893

CREATE INDEX IF NOT EXISTS idx_rc_key_section ON divingapp.report_cache (report_key, section);