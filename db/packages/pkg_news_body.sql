CREATE OR REPLACE PACKAGE BODY PKG_NEWS AS

    -- =========================================================
    -- 最新ニュース取得
    -- PUBLISHED かつ公開日が現在以前のニュースを返す
    -- オプションでカテゴリフィルタ可能
    -- =========================================================
    PROCEDURE GET_LATEST_NEWS(
        p_limit         IN  NUMBER DEFAULT 5,
        p_category      IN  VARCHAR2 DEFAULT NULL,
        o_news          OUT SYS_REFCURSOR
    ) IS
        v_limit NUMBER := NVL(p_limit, 5);
    BEGIN
        IF v_limit < 1 THEN
            v_limit := 5;
        END IF;

        OPEN o_news FOR
            SELECT NEWS_ID,
                   TITLE,
                   CONTENT,
                   CATEGORY,
                   PUBLISH_DATE,
                   STATUS,
                   CREATED_AT,
                   UPDATED_AT
              FROM NEWS
             WHERE STATUS = 'PUBLISHED'
               AND PUBLISH_DATE <= TRUNC(SYSDATE)
               AND (p_category IS NULL OR CATEGORY = p_category)
             ORDER BY PUBLISH_DATE DESC, NEWS_ID DESC
             FETCH FIRST v_limit ROWS ONLY;
    END GET_LATEST_NEWS;

    -- =========================================================
    -- ニュース保存（登録・更新）
    -- p_news_id が NULL の場合は新規登録（SEQ_NEWS.NEXTVAL）
    -- NULL でない場合は更新
    -- =========================================================
    PROCEDURE SAVE_NEWS(
        p_news_id       IN OUT NUMBER,
        p_title         IN  VARCHAR2,
        p_content       IN  CLOB,
        p_category      IN  VARCHAR2,
        p_publish_date  IN  DATE,
        p_status        IN  VARCHAR2,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    ) IS
        v_count NUMBER;
    BEGIN
        -- タイトル必須チェック
        IF p_title IS NULL OR LENGTH(TRIM(p_title)) = 0 THEN
            o_result_code := -20601;
            o_result_msg  := 'タイトルは必須です';
            RETURN;
        END IF;

        -- コンテンツ必須チェック
        IF p_content IS NULL THEN
            o_result_code := -20602;
            o_result_msg  := '本文は必須です';
            RETURN;
        END IF;

        IF p_news_id IS NULL THEN
            -- ============================
            -- 新規登録
            -- ============================
            SELECT SEQ_NEWS.NEXTVAL INTO p_news_id FROM DUAL;

            INSERT INTO NEWS (
                NEWS_ID,
                TITLE,
                CONTENT,
                CATEGORY,
                PUBLISH_DATE,
                STATUS,
                CREATED_AT,
                UPDATED_AT
            ) VALUES (
                p_news_id,
                TRIM(p_title),
                p_content,
                p_category,
                NVL(p_publish_date, TRUNC(SYSDATE)),
                NVL(p_status, 'DRAFT'),
                SYSTIMESTAMP,
                SYSTIMESTAMP
            );

            o_result_code := 0;
            o_result_msg  := 'ニュースを登録しました';
        ELSE
            -- ============================
            -- 更新（存在チェック付き）
            -- ============================
            SELECT COUNT(*)
              INTO v_count
              FROM NEWS
             WHERE NEWS_ID = p_news_id;

            IF v_count = 0 THEN
                o_result_code := -20603;
                o_result_msg  := '指定されたニュースが見つかりません (NEWS_ID=' || p_news_id || ')';
                RETURN;
            END IF;

            UPDATE NEWS
               SET TITLE        = TRIM(p_title),
                   CONTENT      = p_content,
                   CATEGORY     = p_category,
                   PUBLISH_DATE = NVL(p_publish_date, PUBLISH_DATE),
                   STATUS       = NVL(p_status, STATUS),
                   UPDATED_AT   = SYSTIMESTAMP
             WHERE NEWS_ID = p_news_id;

            o_result_code := 0;
            o_result_msg  := 'ニュースを更新しました';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            o_result_code := -20699;
            o_result_msg  := 'ニュース保存中にエラーが発生しました: ' || SQLERRM;
    END SAVE_NEWS;

END PKG_NEWS;
/
