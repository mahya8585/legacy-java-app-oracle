-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/TOURS.sql
-- Generated at: 2026-04-03T15:26:03.543057

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOURS.sql
CREATE TABLE IF NOT EXISTS divingapp.tours (
    tour_id BIGINT NOT NULL,
    tour_name VARCHAR(200) NOT NULL,
    description TEXT,
    area VARCHAR(100) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    max_participants BIGINT NOT NULL,
    base_price BIGINT NOT NULL,
    duration_days BIGINT DEFAULT 1 NOT NULL,
    min_dive_count BIGINT DEFAULT 0,
    featured_flag CHAR(1) DEFAULT 'N' NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_tours_difficulty CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    CONSTRAINT ck_tours_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'DELETED')),
    CONSTRAINT ck_tours_featured CHECK (featured_flag IN ('Y', 'N')),
    CONSTRAINT pk_tours PRIMARY KEY (tour_id)
);