-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (TABLE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/TABLE/NEWS.sql
-- Generated at: 2026-04-03T15:26:04.640265

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/NEWS.sql
CREATE TABLE IF NOT EXISTS divingapp.news (
    news_id BIGINT NOT NULL,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50),
    publish_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'PUBLISHED' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_news_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT pk_news PRIMARY KEY (news_id)
);