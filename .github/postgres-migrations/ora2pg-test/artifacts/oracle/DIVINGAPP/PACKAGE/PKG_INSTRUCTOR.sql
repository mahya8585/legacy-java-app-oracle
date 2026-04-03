
  CREATE OR REPLACE EDITIONABLE PACKAGE "DIVINGAPP"."PKG_INSTRUCTOR" AS
    -- インストラクター一覧
    PROCEDURE GET_INSTRUCTORS(
        o_instructors   OUT SYS_REFCURSOR
    );

    -- インストラクター詳細+担当ツアー
    PROCEDURE GET_INSTRUCTOR_DETAIL(
        p_instructor_id IN  NUMBER,
        o_instructor    OUT SYS_REFCURSOR,
        o_tours         OUT SYS_REFCURSOR
    );
END PKG_INSTRUCTOR;
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DIVINGAPP"."PKG_INSTRUCTOR" AS

    -- =========================================================
    -- インストラクター一覧取得
    -- ACTIVE なインストラクターを経験年数の降順で返す
    -- =========================================================
    PROCEDURE GET_INSTRUCTORS(
        o_instructors   OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN o_instructors FOR
            SELECT INSTRUCTOR_ID,
                   LAST_NAME,
                   FIRST_NAME,
                   CERTIFICATION,
                   EXPERIENCE_YEARS,
                   SPECIALTY,
                   PROFILE,
                   PHOTO_URL,
                   STATUS,
                   CREATED_AT,
                   UPDATED_AT
              FROM INSTRUCTORS
             WHERE STATUS = 'ACTIVE'
             ORDER BY EXPERIENCE_YEARS DESC;
    END GET_INSTRUCTORS;

    -- =========================================================
    -- インストラクター詳細 + 担当ツアー取得
    -- o_instructor : 指定IDのインストラクター1行
    -- o_tours      : そのインストラクターが担当する
    --               ACTIVE ツアー（将来日程があるもの）
    -- =========================================================
    PROCEDURE GET_INSTRUCTOR_DETAIL(
        p_instructor_id IN  NUMBER,
        o_instructor    OUT SYS_REFCURSOR,
        o_tours         OUT SYS_REFCURSOR
    ) IS
    BEGIN
        -- インストラクター本体
        OPEN o_instructor FOR
            SELECT INSTRUCTOR_ID,
                   LAST_NAME,
                   FIRST_NAME,
                   CERTIFICATION,
                   EXPERIENCE_YEARS,
                   SPECIALTY,
                   PROFILE,
                   PHOTO_URL,
                   STATUS,
                   CREATED_AT,
                   UPDATED_AT
              FROM INSTRUCTORS
             WHERE INSTRUCTOR_ID = p_instructor_id;

        -- 担当ツアー（ACTIVE かつ将来のスケジュールが存在するもの）
        OPEN o_tours FOR
            SELECT DISTINCT
                   t.TOUR_ID,
                   t.TOUR_NAME,
                   t.AREA,
                   t.DIFFICULTY,
                   t.MAX_PARTICIPANTS,
                   t.BASE_PRICE,
                   t.DURATION_DAYS,
                   ti.ROLE
              FROM TOUR_INSTRUCTORS ti
              JOIN TOURS t
                ON t.TOUR_ID = ti.TOUR_ID
             WHERE ti.INSTRUCTOR_ID = p_instructor_id
               AND t.STATUS = 'ACTIVE'
               AND EXISTS (
                   SELECT 1
                     FROM TOUR_SCHEDULES ts
                    WHERE ts.TOUR_ID = t.TOUR_ID
                      AND ts.TOUR_DATE >= TRUNC(SYSDATE)
                      AND ts.STATUS IN ('OPEN', 'FULL')
               )
             ORDER BY t.TOUR_NAME;
    END GET_INSTRUCTOR_DETAIL;

END PKG_INSTRUCTOR;