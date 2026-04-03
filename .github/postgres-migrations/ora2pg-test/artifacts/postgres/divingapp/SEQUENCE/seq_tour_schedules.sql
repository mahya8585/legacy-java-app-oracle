-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_TOUR_SCHEDULES.sql
-- Generated at: 2026-04-03T15:26:05.019097

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_TOUR_SCHEDULES.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_tour_schedules
    INCREMENT BY 1
    START WITH 52
    MINVALUE 1
    NO CYCLE;