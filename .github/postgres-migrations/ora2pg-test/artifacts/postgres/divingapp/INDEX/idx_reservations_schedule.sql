-- PostgreSQL DDL for divingapp.idx_reservations_schedule (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RESERVATIONS_SCHEDULE.sql
-- Generated at: 2026-04-03T15:26:02.050136

CREATE INDEX IF NOT EXISTS idx_reservations_schedule ON divingapp.reservations (schedule_id);