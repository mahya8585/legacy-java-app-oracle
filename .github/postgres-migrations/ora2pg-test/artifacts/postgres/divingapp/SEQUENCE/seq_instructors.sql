-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_INSTRUCTORS.sql
-- Generated at: 2026-04-03T15:26:05.034275

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_INSTRUCTORS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_instructors
    INCREMENT BY 1
    START WITH 11
    MINVALUE 1
    NO CYCLE;