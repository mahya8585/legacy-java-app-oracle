-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
-- Generated at: 2026-04-03T15:26:04.265123

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_sites(
    p_area VARCHAR DEFAULT NULL,
    p_difficulty VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    site_id BIGINT,
    site_name VARCHAR,
    area VARCHAR,
    description VARCHAR,
    max_depth BIGINT,
    water_temperature_min BIGINT,
    water_temperature_max BIGINT,
    difficulty VARCHAR,
    marine_life VARCHAR,
    access_info VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT ds.site_id,
           ds.site_name,
           ds.area,
           ds.description,
           ds.max_depth,
           ds.water_temperature_min,
           ds.water_temperature_max,
           ds.difficulty,
           ds.marine_life,
           ds.access_info,
           ds.created_at,
           ds.updated_at
      FROM divingapp.dive_sites ds
     WHERE ds.status = 'ACTIVE'
       AND (p_area IS NULL OR ds.area = p_area)
       AND (p_difficulty IS NULL OR ds.difficulty = p_difficulty)
     ORDER BY ds.area, ds.site_name;
END;
$$;