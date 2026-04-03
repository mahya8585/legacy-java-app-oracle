-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_TOURS.sql
-- Generated at: 2026-04-03T15:26:03.272647

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_TOURS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_tours
    INCREMENT BY 1
    MINVALUE 1
    START WITH 21
    NO CYCLE;