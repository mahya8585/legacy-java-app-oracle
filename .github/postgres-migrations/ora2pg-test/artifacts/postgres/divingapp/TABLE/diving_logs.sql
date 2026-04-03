-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/DIVING_LOGS.sql
-- Generated at: 2026-04-03T15:26:04.284536

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/DIVING_LOGS.sql
CREATE TABLE IF NOT EXISTS divingapp.diving_logs (
	log_id BIGINT NOT NULL,
	customer_id BIGINT NOT NULL,
	site_id BIGINT,
	reservation_id BIGINT,
	dive_date TIMESTAMP NOT NULL,
	max_depth NUMERIC(5,1),
	dive_time BIGINT,
	water_temp NUMERIC(4,1),
	visibility NUMERIC(4,1),
	weather VARCHAR(50),
	buddy VARCHAR(100),
	notes TEXT,
	created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT pk_diving_logs PRIMARY KEY (log_id),
	CONSTRAINT fk_dl_customer FOREIGN KEY (customer_id) REFERENCES divingapp.customers (customer_id),
	CONSTRAINT fk_dl_site FOREIGN KEY (site_id) REFERENCES divingapp.dive_sites (site_id),
	CONSTRAINT fk_dl_reservation FOREIGN KEY (reservation_id) REFERENCES divingapp.reservations (reservation_id)
);