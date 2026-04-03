-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_DIVE_SITES.sql
-- Generated at: 2026-04-03T15:26:05.019097

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_DIVE_SITES.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_dive_sites
    INCREMENT BY 1
    MINVALUE 1
    START WITH 31
    NO CYCLE;