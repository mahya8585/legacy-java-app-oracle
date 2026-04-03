-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RO_RESERVATION.sql
CREATE INDEX IF NOT EXISTS idx_ro_reservation ON divingapp.reservation_options (reservation_id);