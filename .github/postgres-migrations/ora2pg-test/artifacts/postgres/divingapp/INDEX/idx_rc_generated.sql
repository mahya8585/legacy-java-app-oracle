-- PostgreSQL DDL for divingapp.idx_rc_generated (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RC_GENERATED.sql
-- Generated at: 2026-04-03T15:26:01.983311

CREATE INDEX IF NOT EXISTS idx_rc_generated ON divingapp.report_cache (generated_at);