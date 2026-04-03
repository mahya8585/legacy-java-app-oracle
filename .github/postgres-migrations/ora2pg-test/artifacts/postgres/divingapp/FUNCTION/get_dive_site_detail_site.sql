-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
-- Generated at: 2026-04-03T15:26:04.265123

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_site_detail_site(
    p_site_id BIGINT
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
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM divingapp.dive_sites ds
     WHERE ds.site_id = p_site_id
       AND ds.status = 'ACTIVE';

    IF v_count = 0 THEN
        RAISE EXCEPTION '指定されたダイブサイトが見つかりません。SITE_ID=%', p_site_id
            USING ERRCODE = 'P0001';
    END IF;

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
     WHERE ds.site_id = p_site_id;
END;
$$;