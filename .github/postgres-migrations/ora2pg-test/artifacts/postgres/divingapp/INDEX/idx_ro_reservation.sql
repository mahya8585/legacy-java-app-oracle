-- PostgreSQL DDL for divingapp.idx_ro_reservation (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_RO_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:02.109602

CREATE INDEX IF NOT EXISTS idx_ro_reservation ON divingapp.reservation_options (reservation_id);