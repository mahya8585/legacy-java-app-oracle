-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_OPTIONS_MASTER.sql
-- Generated at: 2026-04-03T15:26:05.009960

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_OPTIONS_MASTER.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_options_master
    INCREMENT BY 1
    START WITH 10
    MINVALUE 1
    NO CYCLE;