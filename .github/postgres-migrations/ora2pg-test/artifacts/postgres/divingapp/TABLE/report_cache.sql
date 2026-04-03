-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/REPORT_CACHE.sql
-- Generated at: 2026-04-03T15:26:03.279064

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/REPORT_CACHE.sql
CREATE TABLE IF NOT EXISTS divingapp.report_cache (
    cache_id BIGINT NOT NULL,
    report_key VARCHAR(100) NOT NULL,
    section VARCHAR(50) NOT NULL,
    report_date TIMESTAMP,
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC(15,2),
    dimension1 VARCHAR(200),
    dimension2 VARCHAR(200),
    dimension3 VARCHAR(200),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_report_cache PRIMARY KEY (cache_id)
);