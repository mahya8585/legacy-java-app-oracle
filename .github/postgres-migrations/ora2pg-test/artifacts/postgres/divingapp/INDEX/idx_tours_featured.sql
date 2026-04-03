-- PostgreSQL DDL for divingapp.idx_tours_featured (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_TOURS_FEATURED.sql
-- Generated at: 2026-04-03T15:26:02.026477

CREATE INDEX IF NOT EXISTS idx_tours_featured ON divingapp.tours (featured_flag);