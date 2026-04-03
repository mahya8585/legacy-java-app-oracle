-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:04.308307

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_TOUR.sql
CREATE OR REPLACE PROCEDURE divingapp.search_tours(
    IN p_area VARCHAR,
    IN p_difficulty VARCHAR,
    IN p_date_from TIMESTAMP,
    IN p_date_to TIMESTAMP,
    IN p_price_min NUMERIC,
    IN p_price_max NUMERIC,
    IN p_duration_days NUMERIC,
    IN p_keyword VARCHAR,
    IN p_page NUMERIC,
    IN p_page_size NUMERIC,
    INOUT o_tours refcursor,
    OUT o_total_count NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset NUMERIC;
    v_page NUMERIC;
    v_page_size NUMERIC;
BEGIN
    v_page := COALESCE(p_page, 1);
    v_page_size := COALESCE(p_page_size, 10);
    v_offset := (v_page - 1) * v_page_size;

    -- 総件数取得
    SELECT COUNT(DISTINCT t.tour_id)
      INTO o_total_count
      FROM divingapp.tours t
      LEFT JOIN divingapp.tour_schedules ts ON t.tour_id = ts.tour_id
     WHERE t.status = 'ACTIVE'
       AND (p_area IS NULL OR t.area LIKE '%' || p_area || '%')
       AND (p_difficulty IS NULL OR t.difficulty = p_difficulty)
       AND (p_duration_days IS NULL OR t.duration_days = p_duration_days)
       AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
       AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
       AND (p_price_min IS NULL OR t.base_price >= p_price_min)
       AND (p_price_max IS NULL OR t.base_price <= p_price_max)
       AND (
            p_keyword IS NULL
            OR UPPER(t.tour_name) LIKE '%' || UPPER(p_keyword) || '%'
            OR POSITION(UPPER(p_keyword) IN UPPER(COALESCE(t.description::text, ''))) > 0
       );

    -- ページネーション付きツアー一覧
    IF o_tours IS NULL THEN
        o_tours := 'search_tours_' || pg_backend_pid() || '_' || txid_current();
    END IF;

    OPEN o_tours FOR
        SELECT *
          FROM (
            SELECT DISTINCT
                   t.tour_id,
                   t.tour_name,
                   t.description,
                   t.area,
                   t.difficulty,
                   t.max_participants,
                   t.base_price,
                   t.duration_days,
                   t.min_dive_count,
                   t.featured_flag,
                   t.status,
                   t.created_at,
                   ROW_NUMBER() OVER (ORDER BY t.created_at DESC) AS rn
              FROM divingapp.tours t
              LEFT JOIN divingapp.tour_schedules ts ON t.tour_id = ts.tour_id
             WHERE t.status = 'ACTIVE'
               AND (p_area IS NULL OR t.area LIKE '%' || p_area || '%')
               AND (p_difficulty IS NULL OR t.difficulty = p_difficulty)
               AND (p_duration_days IS NULL OR t.duration_days = p_duration_days)
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
               AND (p_price_min IS NULL OR t.base_price >= p_price_min)
               AND (p_price_max IS NULL OR t.base_price <= p_price_max)
               AND (
                    p_keyword IS NULL
                    OR UPPER(t.tour_name) LIKE '%' || UPPER(p_keyword) || '%'
                    OR POSITION(UPPER(p_keyword) IN UPPER(COALESCE(t.description::text, ''))) > 0
               )
          ) s
         WHERE s.rn > v_offset
           AND s.rn <= v_offset + v_page_size;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー検索中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;