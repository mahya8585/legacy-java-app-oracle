-- PostgreSQL DDL for divingapp.idx_news_publish (INDEX)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: separate_index
-- Oracle source: DIVINGAPP/INDEX/IDX_NEWS_PUBLISH.sql
-- Generated at: 2026-04-03T15:26:02.118252

CREATE INDEX IF NOT EXISTS idx_news_publish ON divingapp.news (publish_date, status);