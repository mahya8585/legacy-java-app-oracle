-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
-- Generated at: 2026-04-03T15:26:04.265123

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_site_detail_related_tours(
    p_site_id BIGINT
)
RETURNS TABLE (
    tour_id BIGINT,
    tour_name VARCHAR,
    area VARCHAR,
    difficulty VARCHAR,
    base_price BIGINT,
    duration_days BIGINT,
    min_dive_count BIGINT,
    featured_flag VARCHAR,
    dive_order BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.tour_id,
           t.tour_name,
           t.area,
           t.difficulty,
           t.base_price,
           t.duration_days,
           t.min_dive_count,
           t.featured_flag,
           tds.dive_order
      FROM divingapp.tour_dive_sites tds
      JOIN divingapp.tours t
        ON tds.tour_id = t.tour_id
     WHERE tds.site_id = p_site_id
       AND t.status = 'ACTIVE'
     ORDER BY t.tour_name;
END;
$$;