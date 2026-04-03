-- PostgreSQL DDL for divingapp.idx_ra_severity (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RA_SEVERITY.sql
-- Generated at: 2026-04-03T15:26:02.020842

CREATE INDEX IF NOT EXISTS idx_ra_severity ON divingapp.report_alerts (severity, status);