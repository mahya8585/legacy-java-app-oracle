-- PostgreSQL DDL for divingapp.idx_ts_status (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TS_STATUS.sql
-- Generated at: 2026-04-03T15:26:02.050136

CREATE INDEX IF NOT EXISTS idx_ts_status ON divingapp.tour_schedules (status);