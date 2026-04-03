-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_NEWS_PUBLISH.sql
-- Generated at: 2026-04-03T15:26:04.643239

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_NEWS_PUBLISH.sql
CREATE INDEX IF NOT EXISTS idx_news_publish ON divingapp.news (publish_date, status);