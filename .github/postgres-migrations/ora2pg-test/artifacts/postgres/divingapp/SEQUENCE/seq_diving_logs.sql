-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_DIVING_LOGS.sql
-- Generated at: 2026-04-03T15:26:03.261626

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_DIVING_LOGS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_diving_logs
    INCREMENT BY 1
    MINVALUE 1
    START WITH 1
    NO CYCLE;