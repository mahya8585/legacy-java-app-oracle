-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_NEWS.sql
-- Generated at: 2026-04-03T15:26:04.647271

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_NEWS.sql
CREATE OR REPLACE FUNCTION divingapp.pkg_news_save_news(
    p_news_id_in BIGINT,
    p_title VARCHAR,
    p_content TEXT,
    p_category VARCHAR,
    p_publish_date TIMESTAMP,
    p_status VARCHAR
)
RETURNS TABLE (p_news_id BIGINT, o_result_code BIGINT, o_result_msg VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    p_news_id := p_news_id_in;

    -- タイトル必須チェック
    IF p_title IS NULL OR length(btrim(p_title)) = 0 THEN
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
        p_news_id := nextval('divingapp.seq_news');

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
            p_news_id,
            btrim(p_title),
            p_content,
            p_category,
            COALESCE(p_publish_date, date_trunc('day', CURRENT_TIMESTAMP)),
            COALESCE(p_status, 'DRAFT'),
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

        o_result_code := 0;
        o_result_msg  := 'ニュースを登録しました';
        RETURN;
    ELSE
        -- ============================
        -- 更新（存在チェック付き）
        -- ============================
        SELECT COUNT(*)
        INTO v_count
        FROM divingapp.news n
        WHERE n.news_id = p_news_id;

        IF v_count = 0 THEN
            o_result_code := -20603;
            o_result_msg  := '指定されたニュースが見つかりません (NEWS_ID=' || p_news_id || ')';
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

        o_result_code := 0;
        o_result_msg  := 'ニュースを更新しました';
        RETURN;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_result_code := -20699;
        o_result_msg  := 'ニュース保存中にエラーが発生しました: ' || SQLERRM;
        RETURN;
END;
$$;