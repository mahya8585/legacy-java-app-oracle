
  CREATE OR REPLACE EDITIONABLE PACKAGE "DIVINGAPP"."PKG_TOUR" AS
    -- ツアー検索（条件付き動的WHERE）
    PROCEDURE SEARCH_TOURS(
        p_area          IN  VARCHAR2 DEFAULT NULL,
        p_difficulty    IN  VARCHAR2 DEFAULT NULL,
        p_date_from     IN  DATE     DEFAULT NULL,
        p_date_to       IN  DATE     DEFAULT NULL,
        p_price_min     IN  NUMBER   DEFAULT NULL,
        p_price_max     IN  NUMBER   DEFAULT NULL,
        p_duration_days IN  NUMBER   DEFAULT NULL,
        p_keyword       IN  VARCHAR2 DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 10,
        o_tours         OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );

    -- ツアー詳細取得
    PROCEDURE GET_TOUR_DETAIL(
        p_tour_id       IN  NUMBER,
        o_tour          OUT SYS_REFCURSOR,
        o_sites         OUT SYS_REFCURSOR,
        o_instructors   OUT SYS_REFCURSOR,
        o_schedules     OUT SYS_REFCURSOR
    );

    -- おすすめツアー取得
    PROCEDURE GET_FEATURED_TOURS(
        p_limit         IN  NUMBER DEFAULT 6,
        o_tours         OUT SYS_REFCURSOR
    );

    -- ツアー保存（登録・更新）
    PROCEDURE SAVE_TOUR(
        p_tour_id       IN OUT NUMBER,
        p_tour_name     IN  VARCHAR2,
        p_description   IN  CLOB,
        p_area          IN  VARCHAR2,
        p_difficulty    IN  VARCHAR2,
        p_max_participants IN NUMBER,
        p_base_price    IN  NUMBER,
        p_duration_days IN  NUMBER,
        p_min_dive_count IN NUMBER,
        p_featured_flag IN  CHAR,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );

    -- ツアー論理削除
    PROCEDURE DELETE_TOUR(
        p_tour_id       IN  NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );
END PKG_TOUR;
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DIVINGAPP"."PKG_TOUR" AS

    -- =========================================================================
    -- ツアー検索（動的WHERE構築 + ページネーション）
    -- =========================================================================
    PROCEDURE SEARCH_TOURS(
        p_area          IN  VARCHAR2 DEFAULT NULL,
        p_difficulty    IN  VARCHAR2 DEFAULT NULL,
        p_date_from     IN  DATE     DEFAULT NULL,
        p_date_to       IN  DATE     DEFAULT NULL,
        p_price_min     IN  NUMBER   DEFAULT NULL,
        p_price_max     IN  NUMBER   DEFAULT NULL,
        p_duration_days IN  NUMBER   DEFAULT NULL,
        p_keyword       IN  VARCHAR2 DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 10,
        o_tours         OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    ) IS
        v_offset  NUMBER;
    BEGIN
        v_offset := (p_page - 1) * p_page_size;

        -- 総件数取得
        SELECT COUNT(DISTINCT t.TOUR_ID)
          INTO o_total_count
          FROM TOURS t
          LEFT JOIN TOUR_SCHEDULES ts ON t.TOUR_ID = ts.TOUR_ID
         WHERE t.STATUS = 'ACTIVE'
           AND (p_area IS NULL OR t.AREA LIKE '%' || p_area || '%')
           AND (p_difficulty IS NULL OR t.DIFFICULTY = p_difficulty)
           AND (p_duration_days IS NULL OR t.DURATION_DAYS = p_duration_days)
           AND (p_date_from IS NULL OR ts.TOUR_DATE >= p_date_from)
           AND (p_date_to IS NULL OR ts.TOUR_DATE <= p_date_to)
           AND (p_price_min IS NULL OR t.BASE_PRICE >= p_price_min)
           AND (p_price_max IS NULL OR t.BASE_PRICE <= p_price_max)
           AND (p_keyword IS NULL
                OR UPPER(t.TOUR_NAME) LIKE '%' || UPPER(p_keyword) || '%'
                OR DBMS_LOB.INSTR(UPPER(t.DESCRIPTION), UPPER(p_keyword)) > 0);

        -- ページネーション付きツアー一覧
        OPEN o_tours FOR
            SELECT *
              FROM (
                SELECT DISTINCT
                       t.TOUR_ID,
                       t.TOUR_NAME,
                       t.DESCRIPTION,
                       t.AREA,
                       t.DIFFICULTY,
                       t.MAX_PARTICIPANTS,
                       t.BASE_PRICE,
                       t.DURATION_DAYS,
                       t.MIN_DIVE_COUNT,
                       t.FEATURED_FLAG,
                       t.STATUS,
                       t.CREATED_AT,
                       ROW_NUMBER() OVER (ORDER BY t.CREATED_AT DESC) AS RN
                  FROM TOURS t
                  LEFT JOIN TOUR_SCHEDULES ts ON t.TOUR_ID = ts.TOUR_ID
                 WHERE t.STATUS = 'ACTIVE'
                   AND (p_area IS NULL OR t.AREA LIKE '%' || p_area || '%')
                   AND (p_difficulty IS NULL OR t.DIFFICULTY = p_difficulty)
                   AND (p_duration_days IS NULL OR t.DURATION_DAYS = p_duration_days)
                   AND (p_date_from IS NULL OR ts.TOUR_DATE >= p_date_from)
                   AND (p_date_to IS NULL OR ts.TOUR_DATE <= p_date_to)
                   AND (p_price_min IS NULL OR t.BASE_PRICE >= p_price_min)
                   AND (p_price_max IS NULL OR t.BASE_PRICE <= p_price_max)
                   AND (p_keyword IS NULL
                        OR UPPER(t.TOUR_NAME) LIKE '%' || UPPER(p_keyword) || '%'
                        OR DBMS_LOB.INSTR(UPPER(t.DESCRIPTION), UPPER(p_keyword)) > 0)
              )
             WHERE RN > v_offset
               AND RN <= v_offset + p_page_size;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20001, 'ツアー検索中にエラーが発生しました: ' || SQLERRM);
    END SEARCH_TOURS;

    -- =========================================================================
    -- ツアー詳細取得（4カーソル返却）
    -- =========================================================================
    PROCEDURE GET_TOUR_DETAIL(
        p_tour_id       IN  NUMBER,
        o_tour          OUT SYS_REFCURSOR,
        o_sites         OUT SYS_REFCURSOR,
        o_instructors   OUT SYS_REFCURSOR,
        o_schedules     OUT SYS_REFCURSOR
    ) IS
        v_count NUMBER;
    BEGIN
        -- ツアー存在チェック
        SELECT COUNT(*) INTO v_count
          FROM TOURS
         WHERE TOUR_ID = p_tour_id
           AND STATUS <> 'DELETED';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20010, '指定されたツアーが見つかりません。TOUR_ID=' || p_tour_id);
        END IF;

        -- ツアー基本情報
        OPEN o_tour FOR
            SELECT t.TOUR_ID,
                   t.TOUR_NAME,
                   t.DESCRIPTION,
                   t.AREA,
                   t.DIFFICULTY,
                   t.MAX_PARTICIPANTS,
                   t.BASE_PRICE,
                   t.DURATION_DAYS,
                   t.MIN_DIVE_COUNT,
                   t.FEATURED_FLAG,
                   t.STATUS,
                   t.CREATED_AT,
                   t.UPDATED_AT
              FROM TOURS t
             WHERE t.TOUR_ID = p_tour_id;

        -- 関連ダイブサイト
        OPEN o_sites FOR
            SELECT ds.SITE_ID,
                   ds.SITE_NAME,
                   ds.AREA,
                   ds.MAX_DEPTH,
                   ds.DIFFICULTY,
                   ds.MARINE_LIFE,
                   tds.DIVE_ORDER
              FROM TOUR_DIVE_SITES tds
              JOIN DIVE_SITES ds ON tds.SITE_ID = ds.SITE_ID
             WHERE tds.TOUR_ID = p_tour_id
               AND ds.STATUS = 'ACTIVE'
             ORDER BY tds.DIVE_ORDER;

        -- 担当インストラクター
        OPEN o_instructors FOR
            SELECT i.INSTRUCTOR_ID,
                   i.LAST_NAME,
                   i.FIRST_NAME,
                   i.CERTIFICATION,
                   i.EXPERIENCE_YEARS,
                   i.SPECIALTY,
                   i.PHOTO_URL,
                   ti.ROLE
              FROM TOUR_INSTRUCTORS ti
              JOIN INSTRUCTORS i ON ti.INSTRUCTOR_ID = i.INSTRUCTOR_ID
             WHERE ti.TOUR_ID = p_tour_id
               AND i.STATUS = 'ACTIVE'
             ORDER BY ti.ROLE, i.LAST_NAME;

        -- 今後のスケジュール（未来日のみ、日付順）
        OPEN o_schedules FOR
            SELECT ts.SCHEDULE_ID,
                   ts.TOUR_DATE,
                   ts.START_TIME,
                   ts.REMAINING_SEATS,
                   ts.STATUS
              FROM TOUR_SCHEDULES ts
             WHERE ts.TOUR_ID = p_tour_id
               AND ts.TOUR_DATE >= TRUNC(SYSDATE)
               AND ts.STATUS IN ('OPEN', 'FULL')
             ORDER BY ts.TOUR_DATE ASC;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20099 AND -20001 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20002, 'ツアー詳細取得中にエラーが発生しました: ' || SQLERRM);
    END GET_TOUR_DETAIL;

    -- =========================================================================
    -- おすすめツアー取得
    -- =========================================================================
    PROCEDURE GET_FEATURED_TOURS(
        p_limit         IN  NUMBER DEFAULT 6,
        o_tours         OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN o_tours FOR
            SELECT t.TOUR_ID,
                   t.TOUR_NAME,
                   t.AREA,
                   t.DIFFICULTY,
                   t.BASE_PRICE,
                   t.DURATION_DAYS,
                   t.MIN_DIVE_COUNT,
                   t.CREATED_AT
              FROM TOURS t
             WHERE t.FEATURED_FLAG = 'Y'
               AND t.STATUS = 'ACTIVE'
             ORDER BY t.CREATED_AT DESC
             FETCH FIRST p_limit ROWS ONLY;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20003, 'おすすめツアー取得中にエラーが発生しました: ' || SQLERRM);
    END GET_FEATURED_TOURS;

    -- =========================================================================
    -- ツアー保存（登録・更新）
    -- =========================================================================
    PROCEDURE SAVE_TOUR(
        p_tour_id       IN OUT NUMBER,
        p_tour_name     IN  VARCHAR2,
        p_description   IN  CLOB,
        p_area          IN  VARCHAR2,
        p_difficulty    IN  VARCHAR2,
        p_max_participants IN NUMBER,
        p_base_price    IN  NUMBER,
        p_duration_days IN  NUMBER,
        p_min_dive_count IN NUMBER,
        p_featured_flag IN  CHAR,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    ) IS
        v_count NUMBER;
    BEGIN
        -- 必須項目バリデーション
        IF p_tour_name IS NULL OR LENGTH(TRIM(p_tour_name)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'ツアー名は必須です。');
        END IF;
        IF p_area IS NULL OR LENGTH(TRIM(p_area)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20021, 'エリアは必須です。');
        END IF;
        IF p_difficulty IS NULL THEN
            RAISE_APPLICATION_ERROR(-20022, '難易度は必須です。');
        END IF;
        IF p_difficulty NOT IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') THEN
            RAISE_APPLICATION_ERROR(-20023, '難易度の値が不正です: ' || p_difficulty);
        END IF;
        IF p_max_participants IS NULL OR p_max_participants <= 0 THEN
            RAISE_APPLICATION_ERROR(-20024, '最大参加人数は1以上を指定してください。');
        END IF;
        IF p_base_price IS NULL OR p_base_price < 0 THEN
            RAISE_APPLICATION_ERROR(-20025, '基本料金は0以上を指定してください。');
        END IF;
        IF p_duration_days IS NULL OR p_duration_days <= 0 THEN
            RAISE_APPLICATION_ERROR(-20026, '日数は1以上を指定してください。');
        END IF;

        IF p_tour_id IS NULL THEN
            -- 新規登録
            SELECT SEQ_TOURS.NEXTVAL INTO p_tour_id FROM DUAL;

            INSERT INTO TOURS (
                TOUR_ID, TOUR_NAME, DESCRIPTION, AREA, DIFFICULTY,
                MAX_PARTICIPANTS, BASE_PRICE, DURATION_DAYS,
                MIN_DIVE_COUNT, FEATURED_FLAG, STATUS,
                CREATED_AT, UPDATED_AT
            ) VALUES (
                p_tour_id, p_tour_name, p_description, p_area, p_difficulty,
                p_max_participants, p_base_price, p_duration_days,
                NVL(p_min_dive_count, 0), NVL(p_featured_flag, 'N'), 'ACTIVE',
                SYSTIMESTAMP, SYSTIMESTAMP
            );

            o_result_code := 0;
            o_result_msg  := 'ツアーを登録しました。TOUR_ID=' || p_tour_id;
        ELSE
            -- 更新：存在チェック
            SELECT COUNT(*) INTO v_count
              FROM TOURS
             WHERE TOUR_ID = p_tour_id
               AND STATUS <> 'DELETED';

            IF v_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20030, '更新対象のツアーが見つかりません。TOUR_ID=' || p_tour_id);
            END IF;

            UPDATE TOURS
               SET TOUR_NAME       = p_tour_name,
                   DESCRIPTION     = p_description,
                   AREA            = p_area,
                   DIFFICULTY      = p_difficulty,
                   MAX_PARTICIPANTS = p_max_participants,
                   BASE_PRICE      = p_base_price,
                   DURATION_DAYS   = p_duration_days,
                   MIN_DIVE_COUNT  = NVL(p_min_dive_count, 0),
                   FEATURED_FLAG   = NVL(p_featured_flag, 'N'),
                   UPDATED_AT      = SYSTIMESTAMP
             WHERE TOUR_ID = p_tour_id;

            o_result_code := 0;
            o_result_msg  := 'ツアーを更新しました。TOUR_ID=' || p_tour_id;
        END IF;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20099 AND -20001 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20004, 'ツアー保存中にエラーが発生しました: ' || SQLERRM);
    END SAVE_TOUR;

    -- =========================================================================
    -- ツアー論理削除
    -- =========================================================================
    PROCEDURE DELETE_TOUR(
        p_tour_id       IN  NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    ) IS
        v_count         NUMBER;
        v_future_res    NUMBER;
    BEGIN
        -- ツアー存在チェック
        SELECT COUNT(*) INTO v_count
          FROM TOURS
         WHERE TOUR_ID = p_tour_id
           AND STATUS <> 'DELETED';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20040, '削除対象のツアーが見つかりません。TOUR_ID=' || p_tour_id);
        END IF;

        -- 未来の確定済み予約があるかチェック
        SELECT COUNT(*) INTO v_future_res
          FROM RESERVATIONS r
          JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
         WHERE ts.TOUR_ID = p_tour_id
           AND ts.TOUR_DATE >= TRUNC(SYSDATE)
           AND r.STATUS = 'CONFIRMED';

        IF v_future_res > 0 THEN
            RAISE_APPLICATION_ERROR(-20041,
                '確定済みの予約が' || v_future_res || '件存在するため削除できません。先に予約をキャンセルしてください。');
        END IF;

        -- 論理削除
        UPDATE TOURS
           SET STATUS     = 'DELETED',
               UPDATED_AT = SYSTIMESTAMP
         WHERE TOUR_ID = p_tour_id;

        COMMIT;

        o_result_code := 0;
        o_result_msg  := 'ツアーを削除しました。TOUR_ID=' || p_tour_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20099 AND -20001 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20005, 'ツアー削除中にエラーが発生しました: ' || SQLERRM);
    END DELETE_TOUR;

END PKG_TOUR;