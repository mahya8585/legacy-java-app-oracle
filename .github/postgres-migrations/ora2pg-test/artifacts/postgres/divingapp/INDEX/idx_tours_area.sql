-- PostgreSQL DDL for divingapp.idx_tours_area (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_AREA.sql
-- Generated at: 2026-04-03T15:26:02.022271

CREATE INDEX IF NOT EXISTS idx_tours_area ON divingapp.tours (area);