CREATE OR REPLACE PACKAGE BODY PKG_DIVE_SITE AS

    -- =========================================================================
    -- ダイブサイト一覧（エリア・難易度フィルター付き）
    -- =========================================================================
    PROCEDURE GET_DIVE_SITES(
        p_area          IN  VARCHAR2 DEFAULT NULL,
        p_difficulty    IN  VARCHAR2 DEFAULT NULL,
        o_sites         OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN o_sites FOR
            SELECT SITE_ID,
                   SITE_NAME,
                   AREA,
                   DESCRIPTION,
                   MAX_DEPTH,
                   WATER_TEMPERATURE_MIN,
                   WATER_TEMPERATURE_MAX,
                   DIFFICULTY,
                   MARINE_LIFE,
                   ACCESS_INFO,
                   CREATED_AT,
                   UPDATED_AT
              FROM DIVE_SITES
             WHERE STATUS = 'ACTIVE'
               AND (p_area IS NULL OR AREA = p_area)
               AND (p_difficulty IS NULL OR DIFFICULTY = p_difficulty)
             ORDER BY AREA, SITE_NAME;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20300, 'ダイブサイト一覧取得中にエラーが発生しました: ' || SQLERRM);
    END GET_DIVE_SITES;

    -- =========================================================================
    -- ダイブサイト詳細 + 関連アクティブツアー
    -- =========================================================================
    PROCEDURE GET_DIVE_SITE_DETAIL(
        p_site_id       IN  NUMBER,
        o_site          OUT SYS_REFCURSOR,
        o_related_tours OUT SYS_REFCURSOR
    ) IS
        v_count NUMBER;
    BEGIN
        -- サイト存在チェック
        SELECT COUNT(*) INTO v_count
          FROM DIVE_SITES
         WHERE SITE_ID = p_site_id
           AND STATUS = 'ACTIVE';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20310, '指定されたダイブサイトが見つかりません。SITE_ID=' || p_site_id);
        END IF;

        -- サイト詳細
        OPEN o_site FOR
            SELECT SITE_ID,
                   SITE_NAME,
                   AREA,
                   DESCRIPTION,
                   MAX_DEPTH,
                   WATER_TEMPERATURE_MIN,
                   WATER_TEMPERATURE_MAX,
                   DIFFICULTY,
                   MARINE_LIFE,
                   ACCESS_INFO,
                   CREATED_AT,
                   UPDATED_AT
              FROM DIVE_SITES
             WHERE SITE_ID = p_site_id;

        -- 関連アクティブツアー（TOUR_DIVE_SITES経由）
        OPEN o_related_tours FOR
            SELECT t.TOUR_ID,
                   t.TOUR_NAME,
                   t.AREA,
                   t.DIFFICULTY,
                   t.BASE_PRICE,
                   t.DURATION_DAYS,
                   t.MIN_DIVE_COUNT,
                   t.FEATURED_FLAG,
                   tds.DIVE_ORDER
              FROM TOUR_DIVE_SITES tds
              JOIN TOURS t ON tds.TOUR_ID = t.TOUR_ID
             WHERE tds.SITE_ID = p_site_id
               AND t.STATUS = 'ACTIVE'
             ORDER BY t.TOUR_NAME;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20399 AND -20300 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20301, 'ダイブサイト詳細取得中にエラーが発生しました: ' || SQLERRM);
    END GET_DIVE_SITE_DETAIL;

END PKG_DIVE_SITE;
/
