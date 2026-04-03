-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (SEQUENCE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/SEQUENCE/SEQ_ADMIN_USERS.sql
-- Generated at: 2026-04-03T15:26:05.030257

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_ADMIN_USERS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_admin_users
    INCREMENT BY 1
    START WITH 2
    MINVALUE 1
    NO CYCLE;