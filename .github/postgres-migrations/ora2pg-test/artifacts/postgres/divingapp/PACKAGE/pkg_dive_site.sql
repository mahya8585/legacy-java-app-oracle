-- PostgreSQL DDL for divingapp.pkg_dive_site (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
-- Generated at: 2026-04-03

-- =========================================================================
-- ダイブサイト一覧（エリア・難易度フィルター付き）
-- Oracle: PROCEDURE GET_DIVE_SITES with SYS_REFCURSOR OUT
-- =========================================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_dive_site_get_dive_sites(
    p_area VARCHAR DEFAULT NULL,
    p_difficulty VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    site_id BIGINT,
    site_name VARCHAR,
    area VARCHAR,
    description TEXT,
    max_depth NUMERIC,
    water_temperature_min NUMERIC,
    water_temperature_max NUMERIC,
    difficulty VARCHAR,
    marine_life TEXT,
    access_info TEXT,
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

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'ダイブサイト一覧取得中にエラーが発生しました: ' || SQLERRM;
END;
$$;

-- =========================================================================
-- ダイブサイト詳細取得
-- Oracle: PROCEDURE GET_DIVE_SITE_DETAIL (o_site OUT SYS_REFCURSOR)
-- PostgreSQL: Split into separate function for site details
-- =========================================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_dive_site_get_dive_site_detail(
    p_site_id BIGINT
)
RETURNS TABLE(
    site_id BIGINT,
    site_name VARCHAR,
    area VARCHAR,
    description TEXT,
    max_depth NUMERIC,
    water_temperature_min NUMERIC,
    water_temperature_max NUMERIC,
    difficulty VARCHAR,
    marine_life TEXT,
    access_info TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    -- サイト存在チェック
    SELECT count(*) INTO v_count
      FROM divingapp.dive_sites ds
     WHERE ds.site_id = p_site_id
       AND ds.status = 'ACTIVE';

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定されたダイブサイトが見つかりません。SITE_ID=' || p_site_id;
    END IF;

    -- サイト詳細
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

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'ダイブサイト詳細取得中にエラーが発生しました: ' || SQLERRM;
END;
$$;

-- =========================================================================
-- ダイブサイト関連ツアー取得
-- Oracle: PROCEDURE GET_DIVE_SITE_DETAIL (o_related_tours OUT SYS_REFCURSOR)
-- PostgreSQL: Split into separate function for related tours
-- =========================================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_dive_site_get_related_tours(
    p_site_id BIGINT
)
RETURNS TABLE(
    tour_id BIGINT,
    tour_name VARCHAR,
    area VARCHAR,
    difficulty VARCHAR,
    base_price NUMERIC,
    duration_days BIGINT,
    min_dive_count BIGINT,
    featured_flag VARCHAR,
    dive_order BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    -- サイト存在チェック
    SELECT count(*) INTO v_count
      FROM divingapp.dive_sites ds
     WHERE ds.site_id = p_site_id
       AND ds.status = 'ACTIVE';

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定されたダイブサイトが見つかりません。SITE_ID=' || p_site_id;
    END IF;

    -- 関連アクティブツアー（TOUR_DIVE_SITES経由）
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
      JOIN divingapp.tours t ON tds.tour_id = t.tour_id
     WHERE tds.site_id = p_site_id
       AND t.status = 'ACTIVE'
     ORDER BY t.tour_name;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'ダイブサイト関連ツアー取得中にエラーが発生しました: ' || SQLERRM;
END;
$$;
