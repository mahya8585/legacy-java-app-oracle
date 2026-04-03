-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:04.313887

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