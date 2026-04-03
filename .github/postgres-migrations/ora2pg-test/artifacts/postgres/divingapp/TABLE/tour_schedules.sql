-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/TOUR_SCHEDULES.sql
-- Generated at: 2026-04-03T15:26:03.976555

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_SCHEDULES.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_schedules (
    schedule_id BIGINT NOT NULL,
    tour_id BIGINT NOT NULL,
    tour_date TIMESTAMP NOT NULL,
    start_time VARCHAR(5),
    remaining_seats BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN' NOT NULL,
    version BIGINT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_ts_status CHECK (status IN ('OPEN', 'FULL', 'CLOSED', 'CANCELLED')),
    CONSTRAINT pk_tour_schedules PRIMARY KEY (schedule_id),
    CONSTRAINT fk_ts_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id)
);