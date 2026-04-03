-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_DL_CUSTOMER.sql
CREATE INDEX IF NOT EXISTS idx_dl_customer ON divingapp.diving_logs (customer_id);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RESERVATIONS_CUSTOMER.sql
CREATE INDEX IF NOT EXISTS idx_reservations_customer ON divingapp.reservations (customer_id);