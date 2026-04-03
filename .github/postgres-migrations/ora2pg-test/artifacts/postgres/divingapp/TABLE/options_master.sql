-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/OPTIONS_MASTER.sql
-- Generated at: 2026-04-03T15:26:03.270742

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/OPTIONS_MASTER.sql
CREATE TABLE IF NOT EXISTS divingapp.options_master (
    option_id BIGINT NOT NULL,
    option_name VARCHAR(200) NOT NULL,
    option_category VARCHAR(50) NOT NULL,
    unit_price BIGINT NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_om_category CHECK (option_category IN ('RENTAL', 'TRANSPORT', 'PHOTO', 'INSURANCE', 'OTHER')),
    CONSTRAINT pk_options_master PRIMARY KEY (option_id)
);