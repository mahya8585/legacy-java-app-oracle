-- PostgreSQL DDL for divingapp.tour_instructors (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/TOUR_INSTRUCTORS.sql
-- Generated at: 2026-04-03T15:26:03.783738

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_INSTRUCTORS.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_instructors (
    tour_id BIGINT NOT NULL,
    instructor_id BIGINT NOT NULL,
    role VARCHAR(50) DEFAULT 'GUIDE',
    CONSTRAINT pk_tour_instructors PRIMARY KEY (tour_id, instructor_id),
    CONSTRAINT fk_ti_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id),
    CONSTRAINT fk_ti_instructor FOREIGN KEY (instructor_id)
        REFERENCES divingapp.instructors (instructor_id)
);