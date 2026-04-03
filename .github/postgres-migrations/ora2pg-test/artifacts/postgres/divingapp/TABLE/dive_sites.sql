-- PostgreSQL DDL for divingapp.dive_sites (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/DIVE_SITES.sql
-- Generated at: 2026-04-03T15:26:03.215153

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/DIVE_SITES.sql
CREATE TABLE IF NOT EXISTS divingapp.dive_sites (
    site_id BIGINT NOT NULL,
    site_name VARCHAR(200) NOT NULL,
    area VARCHAR(100) NOT NULL,
    description TEXT,
    max_depth NUMERIC(5,1),
    water_temperature_min NUMERIC(4,1),
    water_temperature_max NUMERIC(4,1),
    difficulty VARCHAR(20),
    marine_life VARCHAR(1000),
    access_info VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_ds_difficulty CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    CONSTRAINT pk_dive_sites PRIMARY KEY (site_id)
);