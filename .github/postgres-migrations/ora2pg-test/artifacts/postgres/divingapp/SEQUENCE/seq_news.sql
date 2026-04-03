-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_NEWS.sql
-- Generated at: 2026-04-03T15:26:04.638254

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_NEWS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_news
    INCREMENT BY 1
    START WITH 11
    MINVALUE 1
    NO CYCLE;