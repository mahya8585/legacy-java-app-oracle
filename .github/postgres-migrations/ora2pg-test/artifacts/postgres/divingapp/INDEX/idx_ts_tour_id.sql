-- PostgreSQL DDL for divingapp.idx_ts_tour_id (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TS_TOUR_ID.sql
-- Generated at: 2026-04-03T15:26:02.034188

CREATE INDEX IF NOT EXISTS idx_ts_tour_id ON divingapp.tour_schedules (tour_id);