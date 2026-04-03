-- PostgreSQL DDL for divingapp.pkg_diving_log (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: unknown_type
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVING_LOG.sql
-- Generated at: 2026-04-03T15:26:02.102976

-- =========================================================
-- 顧客別ダイビングログ一覧（ページネーション付き）
-- Oracle: PROCEDURE GET_CUSTOMER_LOGS with SYS_REFCURSOR OUT
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_diving_log_get_customer_logs(
    p_customer_id BIGINT,
    p_page BIGINT DEFAULT 1,
    p_page_size BIGINT DEFAULT 20
) RETURNS TABLE (
    log_id BIGINT,
    customer_id BIGINT,
    site_id BIGINT,
    site_name VARCHAR,
    site_area VARCHAR,
    reservation_id BIGINT,
    dive_date TIMESTAMP,
    max_depth NUMERIC,
    dive_time NUMERIC,
    water_temp NUMERIC,
    visibility NUMERIC,
    weather VARCHAR,
    buddy VARCHAR,
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_page BIGINT := COALESCE(p_page, 1);
    v_page_size BIGINT := COALESCE(p_page_size, 20);
    v_offset BIGINT;
    v_total_count BIGINT;
BEGIN
    -- 入力バリデーション
    IF p_customer_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客IDは必須です';
    END IF;

    IF v_page < 1 THEN
        v_page := 1;
    END IF;
    IF v_page_size < 1 OR v_page_size > 100 THEN
        v_page_size := 20;
    END IF;

    v_offset := (v_page - 1) * v_page_size;

    -- 総件数取得
    SELECT COUNT(*)
      INTO v_total_count
      FROM divingapp.diving_logs dl
     WHERE dl.customer_id = p_customer_id;

    RETURN QUERY
    SELECT dl.log_id,
           dl.customer_id,
           dl.site_id,
           ds.site_name,
           ds.area AS site_area,
           dl.reservation_id,
           dl.dive_date,
           dl.max_depth,
           dl.dive_time,
           dl.water_temp,
           dl.visibility,
           dl.weather,
           dl.buddy,
           dl.notes,
           dl.created_at,
           dl.updated_at,
           v_total_count AS total_count
      FROM divingapp.diving_logs dl
      LEFT JOIN divingapp.dive_sites ds
        ON ds.site_id = dl.site_id
     WHERE dl.customer_id = p_customer_id
     ORDER BY dl.dive_date DESC, dl.log_id DESC
     OFFSET v_offset LIMIT v_page_size;
END;
$$;

-- =========================================================
-- ダイビングログ登録・更新
-- Oracle: PROCEDURE SAVE_DIVING_LOG with IN OUT p_log_id
-- p_log_id が NULL の場合は新規登録、NULL でない場合は更新
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_diving_log_save_diving_log(
    p_log_id BIGINT,
    p_customer_id BIGINT,
    p_site_id BIGINT,
    p_reservation_id BIGINT DEFAULT NULL,
    p_dive_date TIMESTAMP,
    p_max_depth NUMERIC,
    p_dive_time NUMERIC,
    p_water_temp NUMERIC,
    p_visibility NUMERIC,
    p_weather VARCHAR,
    p_buddy VARCHAR,
    p_notes TEXT
)
RETURNS TABLE(
    o_log_id BIGINT,
    o_result_code BIGINT,
    o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_customer_id BIGINT;
    v_new_log_id BIGINT;
BEGIN
    -- 必須項目チェック
    IF p_customer_id IS NULL THEN
        o_log_id := p_log_id;
        o_result_code := -20401;
        o_result_msg  := '顧客IDは必須です';
        RETURN NEXT;
        RETURN;
    END IF;

    IF p_dive_date IS NULL THEN
        o_log_id := p_log_id;
        o_result_code := -20402;
        o_result_msg  := 'ダイブ日は必須です';
        RETURN NEXT;
        RETURN;
    END IF;

    IF p_log_id IS NULL THEN
        -- ============================
        -- 新規登録
        -- ============================
        SELECT nextval('divingapp.seq_diving_logs') INTO v_new_log_id;

        INSERT INTO divingapp.diving_logs (
            log_id,
            customer_id,
            site_id,
            reservation_id,
            dive_date,
            max_depth,
            dive_time,
            water_temp,
            visibility,
            weather,
            buddy,
            notes,
            created_at,
            updated_at
        ) VALUES (
            v_new_log_id,
            p_customer_id,
            p_site_id,
            p_reservation_id,
            p_dive_date,
            p_max_depth,
            p_dive_time,
            p_water_temp,
            p_visibility,
            p_weather,
            p_buddy,
            p_notes,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

        o_log_id := v_new_log_id;
        o_result_code := 0;
        o_result_msg  := 'ダイビングログを登録しました';
        RETURN NEXT;
        RETURN;
    ELSE
        -- ============================
        -- 更新（所有者チェック付き）
        -- ============================
        BEGIN
            SELECT dl.customer_id
              INTO STRICT v_existing_customer_id
              FROM divingapp.diving_logs dl
             WHERE dl.log_id = p_log_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                o_log_id := p_log_id;
                o_result_code := -20403;
                o_result_msg  := '指定されたダイビングログが見つかりません (LOG_ID=' || p_log_id || ')';
                RETURN NEXT;
                RETURN;
        END;

        IF v_existing_customer_id != p_customer_id THEN
            o_log_id := p_log_id;
            o_result_code := -20404;
            o_result_msg  := '他の顧客のダイビングログは更新できません';
            RETURN NEXT;
            RETURN;
        END IF;

        UPDATE divingapp.diving_logs dl
           SET site_id        = p_site_id,
               reservation_id = p_reservation_id,
               dive_date      = p_dive_date,
               max_depth      = p_max_depth,
               dive_time      = p_dive_time,
               water_temp     = p_water_temp,
               visibility     = p_visibility,
               weather        = p_weather,
               buddy          = p_buddy,
               notes          = p_notes,
               updated_at     = CURRENT_TIMESTAMP
         WHERE dl.log_id = p_log_id;

        o_log_id := p_log_id;
        o_result_code := 0;
        o_result_msg  := 'ダイビングログを更新しました';
        RETURN NEXT;
        RETURN;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_log_id := COALESCE(v_new_log_id, p_log_id);
        o_result_code := -20499;
        o_result_msg  := 'ダイビングログ保存中にエラーが発生しました: ' || SQLERRM;
        RETURN NEXT;
        RETURN;
END;
$$;