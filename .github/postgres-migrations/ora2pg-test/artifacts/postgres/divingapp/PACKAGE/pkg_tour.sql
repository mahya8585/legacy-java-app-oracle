-- PostgreSQL DDL for divingapp.pkg_tour (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: unknown_type
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:02.059897

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

CREATE OR REPLACE PROCEDURE divingapp.save_tour(
    INOUT p_tour_id NUMERIC,
    IN p_tour_name VARCHAR,
    IN p_description TEXT,
    IN p_area VARCHAR,
    IN p_difficulty VARCHAR,
    IN p_max_participants NUMERIC,
    IN p_base_price NUMERIC,
    IN p_duration_days NUMERIC,
    IN p_min_dive_count NUMERIC,
    IN p_featured_flag CHAR,
    OUT o_result_code NUMERIC,
    OUT o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
BEGIN
    -- 必須項目バリデーション
    IF p_tour_name IS NULL OR length(btrim(p_tour_name)) = 0 THEN
        RAISE EXCEPTION 'ツアー名は必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_area IS NULL OR length(btrim(p_area)) = 0 THEN
        RAISE EXCEPTION 'エリアは必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_difficulty IS NULL THEN
        RAISE EXCEPTION '難易度は必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_difficulty NOT IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') THEN
        RAISE EXCEPTION '難易度の値が不正です: %', p_difficulty USING ERRCODE = 'P0001';
    END IF;
    IF p_max_participants IS NULL OR p_max_participants <= 0 THEN
        RAISE EXCEPTION '最大参加人数は1以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;
    IF p_base_price IS NULL OR p_base_price < 0 THEN
        RAISE EXCEPTION '基本料金は0以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;
    IF p_duration_days IS NULL OR p_duration_days <= 0 THEN
        RAISE EXCEPTION '日数は1以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;

    IF p_tour_id IS NULL THEN
        -- 新規登録
        SELECT nextval('divingapp.seq_tours') INTO p_tour_id;

        INSERT INTO divingapp.tours (
            tour_id, tour_name, description, area, difficulty,
            max_participants, base_price, duration_days,
            min_dive_count, featured_flag, status,
            created_at, updated_at
        ) VALUES (
            p_tour_id, p_tour_name, p_description, p_area, p_difficulty,
            p_max_participants, p_base_price, p_duration_days,
            COALESCE(p_min_dive_count, 0), COALESCE(p_featured_flag, 'N'), 'ACTIVE',
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );

        o_result_code := 0;
        o_result_msg  := 'ツアーを登録しました。TOUR_ID=' || p_tour_id;
    ELSE
        -- 更新：存在チェック
        SELECT COUNT(*)
          INTO v_count
          FROM divingapp.tours
         WHERE tour_id = p_tour_id
           AND status <> 'DELETED';

        IF v_count = 0 THEN
            RAISE EXCEPTION '更新対象のツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
        END IF;

        UPDATE divingapp.tours
           SET tour_name        = p_tour_name,
               description      = p_description,
               area             = p_area,
               difficulty       = p_difficulty,
               max_participants = p_max_participants,
               base_price       = p_base_price,
               duration_days    = p_duration_days,
               min_dive_count   = COALESCE(p_min_dive_count, 0),
               featured_flag    = COALESCE(p_featured_flag, 'N'),
               updated_at       = CURRENT_TIMESTAMP
         WHERE tour_id = p_tour_id;

        o_result_code := 0;
        o_result_msg  := 'ツアーを更新しました。TOUR_ID=' || p_tour_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー保存中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;

CREATE OR REPLACE PROCEDURE divingapp.delete_tour(
    IN p_tour_id NUMERIC,
    OUT o_result_code NUMERIC,
    OUT o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
    v_future_res NUMERIC;
BEGIN
    -- ツアー存在チェック
    SELECT COUNT(*)
      INTO v_count
      FROM divingapp.tours
     WHERE tour_id = p_tour_id
       AND status <> 'DELETED';

    IF v_count = 0 THEN
        RAISE EXCEPTION '削除対象のツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
    END IF;

    -- 未来の確定済み予約があるかチェック
    SELECT COUNT(*)
      INTO v_future_res
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE ts.tour_id = p_tour_id
       AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
       AND r.status = 'CONFIRMED';

    IF v_future_res > 0 THEN
        RAISE EXCEPTION '確定済みの予約が%件存在するため削除できません。先に予約をキャンセルしてください。', v_future_res USING ERRCODE = 'P0001';
    END IF;

    -- 論理削除
    UPDATE divingapp.tours
       SET status     = 'DELETED',
           updated_at = CURRENT_TIMESTAMP
     WHERE tour_id = p_tour_id;

    o_result_code := 0;
    o_result_msg  := 'ツアーを削除しました。TOUR_ID=' || p_tour_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー削除中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;