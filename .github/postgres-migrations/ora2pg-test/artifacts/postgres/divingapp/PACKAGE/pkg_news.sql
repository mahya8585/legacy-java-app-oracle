-- PostgreSQL DDL for divingapp.pkg_news (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Oracle source: DIVINGAPP/PACKAGE/PKG_NEWS.sql
-- Generated at: 2026-04-03

-- =========================================================
-- 最新ニュース取得
-- PUBLISHED かつ公開日が現在以前のニュースを返す
-- オプションでカテゴリフィルタ可能
-- Oracle: PROCEDURE GET_LATEST_NEWS with SYS_REFCURSOR OUT
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_news_get_latest_news(
    p_limit BIGINT DEFAULT 5,
    p_category VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    news_id BIGINT,
    title VARCHAR,
    content TEXT,
    category VARCHAR,
    publish_date TIMESTAMP,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit BIGINT := COALESCE(p_limit, 5);
BEGIN
    IF v_limit < 1 THEN
        v_limit := 5;
    END IF;

    RETURN QUERY
    SELECT n.news_id,
           n.title,
           n.content,
           n.category,
           n.publish_date,
           n.status,
           n.created_at,
           n.updated_at
      FROM divingapp.news n
     WHERE n.status = 'PUBLISHED'
       AND n.publish_date <= CURRENT_DATE
       AND (p_category IS NULL OR n.category = p_category)
     ORDER BY n.publish_date DESC, n.news_id DESC
     LIMIT v_limit;
END;
$$;

-- =========================================================
-- ニュース保存（登録・更新）
-- p_news_id が NULL の場合は新規登録（seq_news）
-- NULL でない場合は更新（存在チェック付き）
-- Oracle: PROCEDURE SAVE_NEWS with IN OUT p_news_id
-- =========================================================
CREATE OR REPLACE FUNCTION divingapp.pkg_news_save_news(
    p_news_id BIGINT,
    p_title VARCHAR,
    p_content TEXT,
    p_category VARCHAR,
    p_publish_date TIMESTAMP,
    p_status VARCHAR
)
RETURNS TABLE(
    o_news_id BIGINT,
    o_result_code BIGINT,
    o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
    v_new_news_id BIGINT;
BEGIN
    -- タイトル必須チェック
    IF p_title IS NULL OR length(btrim(p_title)) = 0 THEN
        o_news_id := p_news_id;
        o_result_code := -20601;
        o_result_msg  := 'タイトルは必須です';
        RETURN NEXT;
        RETURN;
    END IF;

    -- コンテンツ必須チェック
    IF p_content IS NULL THEN
        o_news_id := p_news_id;
        o_result_code := -20602;
        o_result_msg  := '本文は必須です';
        RETURN NEXT;
        RETURN;
    END IF;

    IF p_news_id IS NULL THEN
        -- ============================
        -- 新規登録
        -- ============================
        SELECT nextval('divingapp.seq_news') INTO v_new_news_id;

        INSERT INTO divingapp.news (
            news_id,
            title,
            content,
            category,
            publish_date,
            status,
            created_at,
            updated_at
        ) VALUES (
            v_new_news_id,
            btrim(p_title),
            p_content,
            p_category,
            COALESCE(p_publish_date, CURRENT_DATE),
            COALESCE(p_status, 'DRAFT'),
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

        o_news_id := v_new_news_id;
        o_result_code := 0;
        o_result_msg  := 'ニュースを登録しました';
        RETURN NEXT;
        RETURN;
    ELSE
        -- ============================
        -- 更新（存在チェック付き）
        -- ============================
        SELECT count(*)
          INTO v_count
          FROM divingapp.news n
         WHERE n.news_id = p_news_id;

        IF v_count = 0 THEN
            o_news_id := p_news_id;
            o_result_code := -20603;
            o_result_msg  := '指定されたニュースが見つかりません (NEWS_ID=' || p_news_id || ')';
            RETURN NEXT;
            RETURN;
        END IF;

        UPDATE divingapp.news n
           SET title        = btrim(p_title),
               content      = p_content,
               category     = p_category,
               publish_date = COALESCE(p_publish_date, n.publish_date),
               status       = COALESCE(p_status, n.status),
               updated_at   = CURRENT_TIMESTAMP
         WHERE n.news_id = p_news_id;

        o_news_id := p_news_id;
        o_result_code := 0;
        o_result_msg  := 'ニュースを更新しました';
        RETURN NEXT;
        RETURN;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_news_id := COALESCE(v_new_news_id, p_news_id);
        o_result_code := -20699;
        o_result_msg  := 'ニュース保存中にエラーが発生しました: ' || SQLERRM;
        RETURN NEXT;
        RETURN;
END;
$$;
