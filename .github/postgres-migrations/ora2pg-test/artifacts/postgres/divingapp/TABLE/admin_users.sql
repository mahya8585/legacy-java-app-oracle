-- PostgreSQL DDL for divingapp.admin_users (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/ADMIN_USERS.sql
-- Generated at: 2026-04-03T15:26:04.654460

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/ADMIN_USERS.sql
CREATE TABLE IF NOT EXISTS divingapp.admin_users (
    admin_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    password_hash BYTEA NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'ADMIN',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at TIMESTAMP(6),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_admin_users PRIMARY KEY (admin_id),
    CONSTRAINT uk_admin_users_username UNIQUE (username)
);