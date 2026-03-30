CREATE OR REPLACE PACKAGE BODY PKG_REPORT AS

    -- =========================================================
    -- 月別売上集計レポート
    -- 指定年（+任意の月）の予約データを月ごとに集計する
    -- =========================================================
    PROCEDURE GET_MONTHLY_SALES(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    ) IS
    BEGIN
        IF p_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20500, '年は必須です');
        END IF;

        IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
            RAISE_APPLICATION_ERROR(-20501, '月は1〜12の範囲で指定してください');
        END IF;

        OPEN o_report FOR
            SELECT p_year                                              AS REPORT_YEAR,
                   EXTRACT(MONTH FROM ts.TOUR_DATE)                    AS REPORT_MONTH,
                   COUNT(r.RESERVATION_ID)                             AS TOTAL_RESERVATIONS,
                   NVL(SUM(
                       CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                            THEN r.TOTAL_PRICE
                            ELSE 0
                       END
                   ), 0)                                               AS TOTAL_REVENUE,
                   COUNT(
                       CASE WHEN r.STATUS = 'CANCELLED'
                            THEN 1
                       END
                   )                                                   AS CANCELLED_COUNT
              FROM RESERVATIONS r
              JOIN TOUR_SCHEDULES ts
                ON ts.SCHEDULE_ID = r.SCHEDULE_ID
              JOIN TOURS t
                ON t.TOUR_ID = ts.TOUR_ID
             WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
             GROUP BY EXTRACT(MONTH FROM ts.TOUR_DATE)
             ORDER BY REPORT_MONTH;
    END GET_MONTHLY_SALES;

    -- =========================================================
    -- ツアー別人気ランキング
    -- 指定期間内の予約件数でツアーをランク付けする
    -- =========================================================
    PROCEDURE GET_TOUR_POPULARITY(
        p_date_from     IN  DATE DEFAULT NULL,
        p_date_to       IN  DATE DEFAULT NULL,
        p_limit         IN  NUMBER DEFAULT 10,
        o_report        OUT SYS_REFCURSOR
    ) IS
        v_limit NUMBER := NVL(p_limit, 10);
    BEGIN
        IF v_limit < 1 THEN
            v_limit := 10;
        END IF;

        OPEN o_report FOR
            SELECT *
              FROM (
                SELECT t.TOUR_NAME,
                       t.AREA,
                       COUNT(r.RESERVATION_ID)                         AS RESERVATION_COUNT,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE
                                ELSE 0
                           END
                       ), 0)                                           AS TOTAL_REVENUE,
                       ROUND(NVL(AVG(r.NUM_PARTICIPANTS), 0), 1)       AS AVG_PARTICIPANTS,
                       RANK() OVER (
                           ORDER BY COUNT(r.RESERVATION_ID) DESC
                       )                                               AS POPULARITY_RANK
                  FROM TOURS t
                  JOIN TOUR_SCHEDULES ts
                    ON ts.TOUR_ID = t.TOUR_ID
                  JOIN RESERVATIONS r
                    ON r.SCHEDULE_ID = ts.SCHEDULE_ID
                 WHERE r.STATUS IN ('CONFIRMED', 'COMPLETED')
                   AND (p_date_from IS NULL OR ts.TOUR_DATE >= p_date_from)
                   AND (p_date_to   IS NULL OR ts.TOUR_DATE <= p_date_to)
                 GROUP BY t.TOUR_ID, t.TOUR_NAME, t.AREA
              )
             WHERE POPULARITY_RANK <= v_limit
             ORDER BY POPULARITY_RANK;
    END GET_TOUR_POPULARITY;

    -- =========================================================
    -- 稼働率レポート
    -- 各ツアーの定員に対する予約実績の割合を算出する
    -- =========================================================
    PROCEDURE GET_OCCUPANCY_RATE(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    ) IS
    BEGIN
        IF p_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20502, '年は必須です');
        END IF;

        IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
            RAISE_APPLICATION_ERROR(-20503, '月は1〜12の範囲で指定してください');
        END IF;

        OPEN o_report FOR
            SELECT t.TOUR_NAME,
                   t.AREA,
                   COUNT(DISTINCT ts.SCHEDULE_ID)                      AS SCHEDULE_COUNT,
                   NVL(SUM(t.MAX_PARTICIPANTS), 0)                     AS TOTAL_CAPACITY,
                   NVL(SUM(
                       CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                            THEN r.NUM_PARTICIPANTS
                            ELSE 0
                       END
                   ), 0)                                               AS TOTAL_BOOKED,
                   CASE
                       WHEN NVL(SUM(t.MAX_PARTICIPANTS), 0) = 0 THEN 0
                       ELSE ROUND(
                           NVL(SUM(
                               CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                    THEN r.NUM_PARTICIPANTS
                                    ELSE 0
                               END
                           ), 0)
                           / SUM(t.MAX_PARTICIPANTS) * 100
                       , 1)
                   END                                                 AS OCCUPANCY_RATE
              FROM TOURS t
              JOIN TOUR_SCHEDULES ts
                ON ts.TOUR_ID = t.TOUR_ID
              LEFT JOIN RESERVATIONS r
                ON r.SCHEDULE_ID = ts.SCHEDULE_ID
             WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
               AND ts.STATUS != 'CANCELLED'
             GROUP BY t.TOUR_ID, t.TOUR_NAME, t.AREA
             ORDER BY OCCUPANCY_RATE DESC;
    END GET_OCCUPANCY_RATE;

END PKG_REPORT;
/
