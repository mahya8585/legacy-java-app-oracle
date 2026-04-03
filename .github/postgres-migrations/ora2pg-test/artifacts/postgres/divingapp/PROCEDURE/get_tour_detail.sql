-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:04.309815

CREATE OR REPLACE PROCEDURE divingapp.get_tour_detail(
    IN p_tour_id NUMERIC,
    INOUT o_tour refcursor,
    INOUT o_sites refcursor,
    INOUT o_instructors refcursor,
    INOUT o_schedules refcursor
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
BEGIN
    -- ツアー存在チェック
    SELECT COUNT(*)
      INTO v_count
      FROM divingapp.tours
     WHERE tour_id = p_tour_id
       AND status <> 'DELETED';

    IF v_count = 0 THEN
        RAISE EXCEPTION '指定されたツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
    END IF;

    -- ツアー基本情報
    IF o_tour IS NULL THEN
        o_tour := 'get_tour_detail_tour_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_tour FOR
        SELECT t.tour_id,
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
               t.updated_at
          FROM divingapp.tours t
         WHERE t.tour_id = p_tour_id;

    -- 関連ダイブサイト
    IF o_sites IS NULL THEN
        o_sites := 'get_tour_detail_sites_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_sites FOR
        SELECT ds.site_id,
               ds.site_name,
               ds.area,
               ds.max_depth,
               ds.difficulty,
               ds.marine_life,
               tds.dive_order
          FROM divingapp.tour_dive_sites tds
          JOIN divingapp.dive_sites ds ON tds.site_id = ds.site_id
         WHERE tds.tour_id = p_tour_id
           AND ds.status = 'ACTIVE'
         ORDER BY tds.dive_order;

    -- 担当インストラクター
    IF o_instructors IS NULL THEN
        o_instructors := 'get_tour_detail_instructors_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_instructors FOR
        SELECT i.instructor_id,
               i.last_name,
               i.first_name,
               i.certification,
               i.experience_years,
               i.specialty,
               i.photo_url,
               ti.role
          FROM divingapp.tour_instructors ti
          JOIN divingapp.instructors i ON ti.instructor_id = i.instructor_id
         WHERE ti.tour_id = p_tour_id
           AND i.status = 'ACTIVE'
         ORDER BY ti.role, i.last_name;

    -- 今後のスケジュール（未来日のみ、日付順）
    IF o_schedules IS NULL THEN
        o_schedules := 'get_tour_detail_schedules_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_schedules FOR
        SELECT ts.schedule_id,
               ts.tour_date,
               ts.start_time,
               ts.remaining_seats,
               ts.status
          FROM divingapp.tour_schedules ts
         WHERE ts.tour_id = p_tour_id
           AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
           AND ts.status IN ('OPEN', 'FULL')
         ORDER BY ts.tour_date ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー詳細取得中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;