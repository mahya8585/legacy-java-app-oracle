-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/RESERVATIONS.sql
-- Generated at: 2026-04-03T15:26:04.018028

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/RESERVATIONS.sql
CREATE TABLE IF NOT EXISTS divingapp.reservations (
    reservation_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    schedule_id BIGINT NOT NULL,
    num_participants BIGINT NOT NULL,
    total_price BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    cancel_reason VARCHAR(500),
    refund_amount BIGINT DEFAULT 0,
    notes VARCHAR(1000),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_res_status CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')),
    CONSTRAINT pk_reservations PRIMARY KEY (reservation_id),
    CONSTRAINT fk_res_customer FOREIGN KEY (customer_id)
        REFERENCES divingapp.customers (customer_id),
    CONSTRAINT fk_res_schedule FOREIGN KEY (schedule_id)
        REFERENCES divingapp.tour_schedules (schedule_id)
);