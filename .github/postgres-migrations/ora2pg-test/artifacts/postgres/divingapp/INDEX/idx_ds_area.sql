-- PostgreSQL DDL for divingapp.idx_ds_area (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_DS_AREA.sql
-- Generated at: 2026-04-03T15:26:01.983311

CREATE INDEX IF NOT EXISTS idx_ds_area ON divingapp.dive_sites (area);