
  CREATE OR REPLACE EDITIONABLE PACKAGE "DIVINGAPP"."PKG_DIVING_LOG" AS
    -- 顧客別ダイビングログ一覧
    PROCEDURE GET_CUSTOMER_LOGS(
        p_customer_id   IN  NUMBER,
        p_page          IN  NUMBER DEFAULT 1,
        p_page_size     IN  NUMBER DEFAULT 20,
        o_logs          OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );

    -- ダイビングログ登録・更新
    PROCEDURE SAVE_DIVING_LOG(
        p_log_id        IN OUT NUMBER,
        p_customer_id   IN  NUMBER,
        p_site_id       IN  NUMBER,
        p_reservation_id IN NUMBER DEFAULT NULL,
        p_dive_date     IN  DATE,
        p_max_depth     IN  NUMBER,
        p_dive_time     IN  NUMBER,
        p_water_temp    IN  NUMBER,
        p_visibility    IN  NUMBER,
        p_weather       IN  VARCHAR2,
        p_buddy         IN  VARCHAR2,
        p_notes         IN  CLOB,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );
END PKG_DIVING_LOG;
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DIVINGAPP"."PKG_DIVING_LOG" AS

    -- =========================================================
    -- 顧客別ダイビングログ一覧（ページネーション付き）
    -- ダイブサイト名を結合し、ダイブ日の降順で返す
    -- =========================================================
    PROCEDURE GET_CUSTOMER_LOGS(
        p_customer_id   IN  NUMBER,
        p_page          IN  NUMBER DEFAULT 1,
        p_page_size     IN  NUMBER DEFAULT 20,
        o_logs          OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    ) IS
        v_page      NUMBER := NVL(p_page, 1);
        v_page_size NUMBER := NVL(p_page_size, 20);
        v_offset    NUMBER;
    BEGIN
        -- 入力バリデーション
        IF p_customer_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20400, '顧客IDは必須です');
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
          INTO o_total_count
          FROM DIVING_LOGS
         WHERE CUSTOMER_ID = p_customer_id;

        -- ページネーション付きのログ取得
        OPEN o_logs FOR
            SELECT dl.LOG_ID,
                   dl.CUSTOMER_ID,
                   dl.SITE_ID,
                   ds.SITE_NAME,
                   ds.AREA AS SITE_AREA,
                   dl.RESERVATION_ID,
                   dl.DIVE_DATE,
                   dl.MAX_DEPTH,
                   dl.DIVE_TIME,
                   dl.WATER_TEMP,
                   dl.VISIBILITY,
                   dl.WEATHER,
                   dl.BUDDY,
                   dl.NOTES,
                   dl.CREATED_AT,
                   dl.UPDATED_AT
              FROM DIVING_LOGS dl
              LEFT JOIN DIVE_SITES ds
                ON ds.SITE_ID = dl.SITE_ID
             WHERE dl.CUSTOMER_ID = p_customer_id
             ORDER BY dl.DIVE_DATE DESC, dl.LOG_ID DESC
            OFFSET v_offset ROWS FETCH NEXT v_page_size ROWS ONLY;
    END GET_CUSTOMER_LOGS;

    -- =========================================================
    -- ダイビングログ登録・更新
    -- p_log_id が NULL の場合は新規登録（SEQ_DIVING_LOGS.NEXTVAL）
    -- NULL でない場合は更新（customer_id の一致を検証）
    -- =========================================================
    PROCEDURE SAVE_DIVING_LOG(
        p_log_id        IN OUT NUMBER,
        p_customer_id   IN  NUMBER,
        p_site_id       IN  NUMBER,
        p_reservation_id IN NUMBER DEFAULT NULL,
        p_dive_date     IN  DATE,
        p_max_depth     IN  NUMBER,
        p_dive_time     IN  NUMBER,
        p_water_temp    IN  NUMBER,
        p_visibility    IN  NUMBER,
        p_weather       IN  VARCHAR2,
        p_buddy         IN  VARCHAR2,
        p_notes         IN  CLOB,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    ) IS
        v_existing_customer_id NUMBER;
    BEGIN
        -- 必須項目チェック
        IF p_customer_id IS NULL THEN
            o_result_code := -20401;
            o_result_msg  := '顧客IDは必須です';
            RETURN;
        END IF;

        IF p_dive_date IS NULL THEN
            o_result_code := -20402;
            o_result_msg  := 'ダイブ日は必須です';
            RETURN;
        END IF;

        IF p_log_id IS NULL THEN
            -- ============================
            -- 新規登録
            -- ============================
            SELECT SEQ_DIVING_LOGS.NEXTVAL INTO p_log_id FROM DUAL;

            INSERT INTO DIVING_LOGS (
                LOG_ID,
                CUSTOMER_ID,
                SITE_ID,
                RESERVATION_ID,
                DIVE_DATE,
                MAX_DEPTH,
                DIVE_TIME,
                WATER_TEMP,
                VISIBILITY,
                WEATHER,
                BUDDY,
                NOTES,
                CREATED_AT,
                UPDATED_AT
            ) VALUES (
                p_log_id,
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
                SYSTIMESTAMP,
                SYSTIMESTAMP
            );

            o_result_code := 0;
            o_result_msg  := 'ダイビングログを登録しました';
        ELSE
            -- ============================
            -- 更新（所有者チェック付き）
            -- ============================
            BEGIN
                SELECT CUSTOMER_ID
                  INTO v_existing_customer_id
                  FROM DIVING_LOGS
                 WHERE LOG_ID = p_log_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    o_result_code := -20403;
                    o_result_msg  := '指定されたダイビングログが見つかりません (LOG_ID=' || p_log_id || ')';
                    RETURN;
            END;

            IF v_existing_customer_id != p_customer_id THEN
                o_result_code := -20404;
                o_result_msg  := '他の顧客のダイビングログは更新できません';
                RETURN;
            END IF;

            UPDATE DIVING_LOGS
               SET SITE_ID        = p_site_id,
                   RESERVATION_ID = p_reservation_id,
                   DIVE_DATE      = p_dive_date,
                   MAX_DEPTH      = p_max_depth,
                   DIVE_TIME      = p_dive_time,
                   WATER_TEMP     = p_water_temp,
                   VISIBILITY     = p_visibility,
                   WEATHER        = p_weather,
                   BUDDY          = p_buddy,
                   NOTES          = p_notes,
                   UPDATED_AT     = SYSTIMESTAMP
             WHERE LOG_ID = p_log_id;

            o_result_code := 0;
            o_result_msg  := 'ダイビングログを更新しました';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            o_result_code := -20499;
            o_result_msg  := 'ダイビングログ保存中にエラーが発生しました: ' || SQLERRM;
    END SAVE_DIVING_LOG;

END PKG_DIVING_LOG;