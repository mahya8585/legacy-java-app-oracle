-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/RESERVATION_OPTIONS.sql
-- Generated at: 2026-04-03T15:26:04.284536

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/RESERVATION_OPTIONS.sql
CREATE TABLE IF NOT EXISTS divingapp.reservation_options (
	res_option_id BIGINT NOT NULL,
	reservation_id BIGINT NOT NULL,
	option_id BIGINT NOT NULL,
	quantity BIGINT DEFAULT 1 NOT NULL,
	subtotal BIGINT NOT NULL,
	CONSTRAINT pk_reservation_options PRIMARY KEY (res_option_id),
	CONSTRAINT fk_ro_reservation FOREIGN KEY (reservation_id) REFERENCES divingapp.reservations (reservation_id),
	CONSTRAINT fk_ro_option FOREIGN KEY (option_id) REFERENCES divingapp.options_master (option_id)
);