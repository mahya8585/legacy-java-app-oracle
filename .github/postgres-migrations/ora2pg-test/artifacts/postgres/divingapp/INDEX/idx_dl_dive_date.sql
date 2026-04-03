-- PostgreSQL DDL for divingapp.idx_dl_dive_date (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_DL_DIVE_DATE.sql
-- Generated at: 2026-04-03T15:26:02.104985

CREATE INDEX IF NOT EXISTS idx_dl_dive_date ON divingapp.diving_logs (dive_date);