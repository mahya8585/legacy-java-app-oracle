-- PostgreSQL DDL for divingapp.customers (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/CUSTOMERS.sql
-- Generated at: 2026-04-03T15:26:03.490255

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/CUSTOMERS.sql
CREATE TABLE IF NOT EXISTS divingapp.customers (
    customer_id BIGINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash BYTEA NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name_kana VARCHAR(100),
    first_name_kana VARCHAR(100),
    phone VARCHAR(20),
    birth_date DATE,
    license_level VARCHAR(100),
    dive_count BIGINT DEFAULT 0,
    emergency_contact VARCHAR(200),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uk_customers_email UNIQUE (email)
);