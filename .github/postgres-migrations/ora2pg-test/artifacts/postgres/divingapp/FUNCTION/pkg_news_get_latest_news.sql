-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_NEWS.sql
-- Generated at: 2026-04-03T15:26:04.645258

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_NEWS.sql
CREATE OR REPLACE FUNCTION divingapp.pkg_news_get_latest_news(
    p_limit BIGINT DEFAULT 5,
    p_category VARCHAR DEFAULT NULL
)
RETURNS SETOF divingapp.news
LANGUAGE plpgsql
AS $$
BEGIN
    IF COALESCE(p_limit, 5) < 1 THEN
        p_limit := 5;
    END IF;

    RETURN QUERY
    SELECT n.*
    FROM divingapp.news n
    WHERE n.status = 'PUBLISHED'
      AND n.publish_date <= date_trunc('day', CURRENT_TIMESTAMP)
      AND (p_category IS NULL OR n.category = p_category)
    ORDER BY n.publish_date DESC, n.news_id DESC
    LIMIT p_limit;
END;
$$;