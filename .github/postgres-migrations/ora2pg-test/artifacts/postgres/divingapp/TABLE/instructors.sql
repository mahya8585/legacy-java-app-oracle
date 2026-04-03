-- PostgreSQL DDL for divingapp.instructors (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/INSTRUCTORS.sql
-- Generated at: 2026-04-03T15:26:03.274068

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/INSTRUCTORS.sql
CREATE TABLE IF NOT EXISTS divingapp.instructors (
    instructor_id BIGINT NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    certification VARCHAR(200),
    experience_years BIGINT,
    specialty VARCHAR(200),
    profile TEXT,
    photo_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_instructors PRIMARY KEY (instructor_id)
);