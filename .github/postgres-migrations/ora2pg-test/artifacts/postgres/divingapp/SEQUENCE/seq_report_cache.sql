-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_REPORT_CACHE.sql
-- Generated at: 2026-04-03T15:26:03.301382

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_REPORT_CACHE.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_report_cache
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NO CYCLE;