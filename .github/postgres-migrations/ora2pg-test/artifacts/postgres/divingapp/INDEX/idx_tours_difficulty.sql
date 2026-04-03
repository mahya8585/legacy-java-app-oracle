-- PostgreSQL DDL for divingapp.idx_tours_difficulty (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_DIFFICULTY.sql
-- Generated at: 2026-04-03T15:26:02.023741

CREATE INDEX IF NOT EXISTS idx_tours_difficulty ON divingapp.tours (difficulty);