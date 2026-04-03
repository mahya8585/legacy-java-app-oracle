-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:04.311873

CREATE OR REPLACE PROCEDURE divingapp.get_featured_tours(
    IN p_limit NUMERIC,
    INOUT o_tours refcursor
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit NUMERIC;
BEGIN
    v_limit := COALESCE(p_limit, 6);

    IF o_tours IS NULL THEN
        o_tours := 'get_featured_tours_' || pg_backend_pid() || '_' || txid_current();
    END IF;

    OPEN o_tours FOR
        SELECT t.tour_id,
               t.tour_name,
               t.area,
               t.difficulty,
               t.base_price,
               t.duration_days,
               t.min_dive_count,
               t.created_at
          FROM divingapp.tours t
         WHERE t.featured_flag = 'Y'
           AND t.status = 'ACTIVE'
         ORDER BY t.created_at DESC
         LIMIT v_limit::int;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'おすすめツアー取得中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;