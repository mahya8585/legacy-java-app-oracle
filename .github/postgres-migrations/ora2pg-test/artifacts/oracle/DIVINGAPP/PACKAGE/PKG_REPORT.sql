
  CREATE OR REPLACE EDITIONABLE PACKAGE "DIVINGAPP"."PKG_REPORT" AS
    -- 月別売上集計レポート
    PROCEDURE GET_MONTHLY_SALES(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    );

    -- ツアー別人気ランキング
    PROCEDURE GET_TOUR_POPULARITY(
        p_date_from     IN  DATE DEFAULT NULL,
        p_date_to       IN  DATE DEFAULT NULL,
        p_limit         IN  NUMBER DEFAULT 10,
        o_report        OUT SYS_REFCURSOR
    );

    -- 稼働率レポート
    PROCEDURE GET_OCCUPANCY_RATE(
        p_year          IN  NUMBER,
        p_month         IN  NUMBER DEFAULT NULL,
        o_report        OUT SYS_REFCURSOR
    );

    -- 包括的ダッシュボードレポート生成
    -- 売上推移・エリア×難易度クロス集計・インストラクターKPI・
    -- 顧客セグメント・キャンセル傾向・異常検知アラートを一括生成
    PROCEDURE GENERATE_DASHBOARD_REPORT(
        p_year              IN  NUMBER,
        p_month             IN  NUMBER DEFAULT NULL,
        o_sales_trend       OUT SYS_REFCURSOR,
        o_area_matrix       OUT SYS_REFCURSOR,
        o_instructor_kpi    OUT SYS_REFCURSOR,
        o_customer_segment  OUT SYS_REFCURSOR,
        o_cancel_analysis   OUT SYS_REFCURSOR,
        o_anomaly_alerts    OUT SYS_REFCURSOR
    );
END PKG_REPORT;
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DIVINGAPP"."PKG_REPORT" AS

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

    -- =========================================================
    -- 包括的ダッシュボードレポート生成
    -- 6つのSYS_REFCURSORで以下を返却:
    --   1) 売上推移分析（前月比・前年同月比・累計・構成比）
    --   2) エリア×難易度クロス集計（PIVOT + GROUPING SETS）
    --   3) インストラクターKPI（リピート率・売上ランク）
    --   4) 顧客セグメント（RFM分析 + NTILE）
    --   5) キャンセル傾向・損失分析（移動平均・標準偏差）
    --   6) 異常検知アラート（Z-score + MERGE + INSERT）
    -- =========================================================
    PROCEDURE GENERATE_DASHBOARD_REPORT(
        p_year              IN  NUMBER,
        p_month             IN  NUMBER DEFAULT NULL,
        o_sales_trend       OUT SYS_REFCURSOR,
        o_area_matrix       OUT SYS_REFCURSOR,
        o_instructor_kpi    OUT SYS_REFCURSOR,
        o_customer_segment  OUT SYS_REFCURSOR,
        o_cancel_analysis   OUT SYS_REFCURSOR,
        o_anomaly_alerts    OUT SYS_REFCURSOR
    ) IS
        v_date_from     DATE;
        v_date_to       DATE;
        v_prev_year     NUMBER;
        v_report_key    VARCHAR2(100);
        v_alert_count   NUMBER := 0;
    BEGIN
        -- -------------------------------------------------------
        -- 入力バリデーション
        -- -------------------------------------------------------
        IF p_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20510, '年は必須です');
        END IF;

        IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
            RAISE_APPLICATION_ERROR(-20511, '月は1〜12の範囲で指定してください');
        END IF;

        v_prev_year  := p_year - 1;
        v_report_key := 'DASHBOARD_' || TO_CHAR(p_year) || '_' || NVL(TO_CHAR(p_month), 'ALL');

        IF p_month IS NOT NULL THEN
            v_date_from := TO_DATE(p_year || '-' || LPAD(p_month, 2, '0') || '-01', 'YYYY-MM-DD');
            v_date_to   := LAST_DAY(v_date_from);
        ELSE
            v_date_from := TO_DATE(p_year || '-01-01', 'YYYY-MM-DD');
            v_date_to   := TO_DATE(p_year || '-12-31', 'YYYY-MM-DD');
        END IF;

        -- =========================================================
        -- セクション1: 売上推移分析
        -- CONNECT BY でカレンダー生成 → LEFT JOIN でゼロ埋め
        -- LAG で前月比、サブクエリで前年同月比、RATIO_TO_REPORT で構成比
        -- SUM OVER ROWS UNBOUNDED PRECEDING で累計
        -- =========================================================
        OPEN o_sales_trend FOR
            WITH calendar AS (
                SELECT LEVEL AS cal_month
                  FROM DUAL
               CONNECT BY LEVEL <= 12
            ),
            current_year_sales AS (
                SELECT EXTRACT(MONTH FROM ts.TOUR_DATE)                    AS sale_month,
                       COUNT(DISTINCT r.RESERVATION_ID)                    AS reservation_count,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS revenue,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.NUM_PARTICIPANTS ELSE 0 END
                       ), 0)                                               AS participants,
                       COUNT(CASE WHEN r.STATUS = 'CANCELLED' THEN 1 END)  AS cancel_count
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                 GROUP BY EXTRACT(MONTH FROM ts.TOUR_DATE)
            ),
            prev_year_sales AS (
                SELECT EXTRACT(MONTH FROM ts.TOUR_DATE)                    AS sale_month,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS revenue
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = v_prev_year
                 GROUP BY EXTRACT(MONTH FROM ts.TOUR_DATE)
            ),
            combined AS (
                SELECT c.cal_month                                         AS REPORT_MONTH,
                       NVL(cur.reservation_count, 0)                       AS RESERVATION_COUNT,
                       NVL(cur.revenue, 0)                                 AS REVENUE,
                       NVL(cur.participants, 0)                            AS PARTICIPANTS,
                       NVL(cur.cancel_count, 0)                            AS CANCEL_COUNT,
                       LAG(NVL(cur.revenue, 0), 1) OVER (
                           ORDER BY c.cal_month
                       )                                                   AS PREV_MONTH_REVENUE,
                       NVL(prev.revenue, 0)                                AS YOY_REVENUE,
                       SUM(NVL(cur.revenue, 0)) OVER (
                           ORDER BY c.cal_month
                           ROWS UNBOUNDED PRECEDING
                       )                                                   AS CUMULATIVE_REVENUE,
                       RATIO_TO_REPORT(NVL(cur.revenue, 0)) OVER ()       AS SHARE_RATE
                  FROM calendar c
                  LEFT JOIN current_year_sales cur ON cur.sale_month = c.cal_month
                  LEFT JOIN prev_year_sales prev   ON prev.sale_month = c.cal_month
                 WHERE (p_month IS NULL OR c.cal_month = p_month)
            )
            SELECT REPORT_MONTH,
                   RESERVATION_COUNT,
                   REVENUE,
                   PARTICIPANTS,
                   CANCEL_COUNT,
                   PREV_MONTH_REVENUE,
                   CASE
                       WHEN PREV_MONTH_REVENUE IS NULL OR PREV_MONTH_REVENUE = 0 THEN NULL
                       ELSE ROUND((REVENUE - PREV_MONTH_REVENUE)
                                  / PREV_MONTH_REVENUE * 100, 1)
                   END                                                     AS MOM_CHANGE_RATE,
                   YOY_REVENUE,
                   CASE
                       WHEN YOY_REVENUE = 0 THEN NULL
                       ELSE ROUND((REVENUE - YOY_REVENUE)
                                  / YOY_REVENUE * 100, 1)
                   END                                                     AS YOY_CHANGE_RATE,
                   CUMULATIVE_REVENUE,
                   ROUND(SHARE_RATE * 100, 1)                              AS SHARE_PCT,
                   CASE
                       WHEN PREV_MONTH_REVENUE IS NULL                THEN 'N/A'
                       WHEN REVENUE > PREV_MONTH_REVENUE * 1.05       THEN 'UP'
                       WHEN REVENUE < PREV_MONTH_REVENUE * 0.95       THEN 'DOWN'
                       ELSE 'FLAT'
                   END                                                     AS TREND
              FROM combined
             ORDER BY REPORT_MONTH;

        -- =========================================================
        -- セクション2: エリア × 難易度クロス集計
        -- PIVOT で難易度を列展開、GROUPING SETS で小計/総計
        -- =========================================================
        OPEN o_area_matrix FOR
            SELECT NVL(area_name, '【合計】')                              AS AREA,
                   NVL(difficulty, '小計')                                 AS DIFFICULTY,
                   grouping_level,
                   reservation_count,
                   total_revenue,
                   avg_participants,
                   beginner_count,
                   intermediate_count,
                   advanced_count,
                   expert_count,
                   CASE
                       WHEN total_revenue = 0 THEN 0
                       ELSE ROUND(beginner_rev / NULLIF(total_revenue, 0) * 100, 1)
                   END                                                     AS BEGINNER_REV_PCT,
                   CASE
                       WHEN total_revenue = 0 THEN 0
                       ELSE ROUND(advanced_rev / NULLIF(total_revenue, 0) * 100, 1)
                   END                                                     AS ADVANCED_REV_PCT
              FROM (
                SELECT CASE GROUPING_ID(t.AREA, t.DIFFICULTY)
                           WHEN 0 THEN t.AREA
                           WHEN 1 THEN t.AREA
                           WHEN 3 THEN NULL
                       END                                                 AS area_name,
                       CASE GROUPING_ID(t.AREA, t.DIFFICULTY)
                           WHEN 0 THEN t.DIFFICULTY
                           WHEN 1 THEN NULL
                           WHEN 3 THEN NULL
                       END                                                 AS difficulty,
                       GROUPING_ID(t.AREA, t.DIFFICULTY)                   AS grouping_level,
                       COUNT(r.RESERVATION_ID)                             AS reservation_count,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS total_revenue,
                       ROUND(NVL(AVG(r.NUM_PARTICIPANTS), 0), 1)           AS avg_participants,
                       COUNT(CASE WHEN t.DIFFICULTY = 'BEGINNER'
                                  THEN r.RESERVATION_ID END)               AS beginner_count,
                       COUNT(CASE WHEN t.DIFFICULTY = 'INTERMEDIATE'
                                  THEN r.RESERVATION_ID END)               AS intermediate_count,
                       COUNT(CASE WHEN t.DIFFICULTY = 'ADVANCED'
                                  THEN r.RESERVATION_ID END)               AS advanced_count,
                       COUNT(CASE WHEN t.DIFFICULTY = 'EXPERT'
                                  THEN r.RESERVATION_ID END)               AS expert_count,
                       NVL(SUM(
                           CASE WHEN t.DIFFICULTY = 'BEGINNER'
                                     AND r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS beginner_rev,
                       NVL(SUM(
                           CASE WHEN t.DIFFICULTY = 'ADVANCED'
                                     AND r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS advanced_rev
                  FROM TOURS t
                  JOIN TOUR_SCHEDULES ts ON ts.TOUR_ID = t.TOUR_ID
                  LEFT JOIN RESERVATIONS r ON r.SCHEDULE_ID = ts.SCHEDULE_ID
                 WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                   AND ts.STATUS != 'CANCELLED'
                 GROUP BY GROUPING SETS (
                     (t.AREA, t.DIFFICULTY),
                     (t.AREA),
                     ()
                 )
              )
             ORDER BY CASE WHEN grouping_level = 3 THEN 1 ELSE 0 END,
                      area_name NULLS LAST,
                      DECODE(difficulty, 'BEGINNER', 1, 'INTERMEDIATE', 2,
                             'ADVANCED', 3, 'EXPERT', 4, 5) NULLS LAST;

        -- =========================================================
        -- セクション3: インストラクターKPI
        -- 5テーブル結合 + LISTAGG + 相関サブクエリ(リピート率)
        -- + DENSE_RANK / PERCENT_RANK / スカラーサブクエリ
        -- =========================================================
        OPEN o_instructor_kpi FOR
            WITH instructor_base AS (
                SELECT i.INSTRUCTOR_ID,
                       i.LAST_NAME || ' ' || i.FIRST_NAME                  AS INSTRUCTOR_NAME,
                       i.CERTIFICATION,
                       i.EXPERIENCE_YEARS,
                       COUNT(DISTINCT ts.SCHEDULE_ID)                      AS SCHEDULE_COUNT,
                       COUNT(DISTINCT r.RESERVATION_ID)                    AS RESERVATION_COUNT,
                       COUNT(DISTINCT r.CUSTOMER_ID)                       AS UNIQUE_CUSTOMERS,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS TOTAL_REVENUE,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.NUM_PARTICIPANTS ELSE 0 END
                       ), 0)                                               AS TOTAL_PARTICIPANTS,
                       ROUND(NVL(AVG(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.NUM_PARTICIPANTS END
                       ), 0), 1)                                           AS AVG_PARTICIPANTS
                  FROM INSTRUCTORS i
                  JOIN TOUR_INSTRUCTORS ti ON ti.INSTRUCTOR_ID = i.INSTRUCTOR_ID
                  JOIN TOURS t            ON t.TOUR_ID = ti.TOUR_ID
                  JOIN TOUR_SCHEDULES ts  ON ts.TOUR_ID = t.TOUR_ID
                  LEFT JOIN RESERVATIONS r ON r.SCHEDULE_ID = ts.SCHEDULE_ID
                 WHERE i.STATUS = 'ACTIVE'
                   AND EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                 GROUP BY i.INSTRUCTOR_ID, i.LAST_NAME, i.FIRST_NAME,
                          i.CERTIFICATION, i.EXPERIENCE_YEARS
            ),
            instructor_areas AS (
                SELECT ti.INSTRUCTOR_ID,
                       LISTAGG(DISTINCT t.AREA, ', ')
                           WITHIN GROUP (ORDER BY t.AREA)                  AS AREA_LIST
                  FROM TOUR_INSTRUCTORS ti
                  JOIN TOURS t ON t.TOUR_ID = ti.TOUR_ID
                 WHERE t.STATUS = 'ACTIVE'
                 GROUP BY ti.INSTRUCTOR_ID
            )
            SELECT ib.INSTRUCTOR_NAME,
                   ib.CERTIFICATION,
                   ib.EXPERIENCE_YEARS,
                   ib.SCHEDULE_COUNT,
                   ib.RESERVATION_COUNT,
                   ib.UNIQUE_CUSTOMERS,
                   ib.TOTAL_REVENUE,
                   ib.TOTAL_PARTICIPANTS,
                   ib.AVG_PARTICIPANTS,
                   DENSE_RANK() OVER (
                       ORDER BY ib.TOTAL_REVENUE DESC
                   )                                                       AS REVENUE_RANK,
                   ROUND(PERCENT_RANK() OVER (
                       ORDER BY ib.AVG_PARTICIPANTS
                   ) * 100, 1)                                             AS PARTICIPANT_PERCENTILE,
                   ROUND(RATIO_TO_REPORT(ib.TOTAL_REVENUE) OVER () * 100, 1)
                                                                           AS REVENUE_SHARE_PCT,
                   NVL(ia.AREA_LIST, '-')                                  AS AREA_LIST,
                   -- 相関サブクエリ: リピート率（同一インストラクターのツアーに2回以上予約した顧客の割合）
                   CASE
                       WHEN ib.UNIQUE_CUSTOMERS = 0 THEN 0
                       ELSE ROUND(
                           (SELECT COUNT(DISTINCT repeat_cust.CUSTOMER_ID)
                              FROM (
                                  SELECT r2.CUSTOMER_ID,
                                         COUNT(DISTINCT r2.RESERVATION_ID) AS visit_count
                                    FROM RESERVATIONS r2
                                    JOIN TOUR_SCHEDULES ts2 ON ts2.SCHEDULE_ID = r2.SCHEDULE_ID
                                    JOIN TOUR_INSTRUCTORS ti2 ON ti2.TOUR_ID = ts2.TOUR_ID
                                   WHERE ti2.INSTRUCTOR_ID = ib.INSTRUCTOR_ID
                                     AND r2.STATUS IN ('CONFIRMED', 'COMPLETED')
                                   GROUP BY r2.CUSTOMER_ID
                                  HAVING COUNT(DISTINCT r2.RESERVATION_ID) >= 2
                              ) repeat_cust
                           ) / NULLIF(ib.UNIQUE_CUSTOMERS, 0) * 100
                       , 1)
                   END                                                     AS REPEAT_RATE,
                   -- スカラーサブクエリ: 直近3ヶ月の稼働日数
                   (SELECT COUNT(DISTINCT ts3.TOUR_DATE)
                      FROM TOUR_SCHEDULES ts3
                      JOIN TOUR_INSTRUCTORS ti3 ON ti3.TOUR_ID = ts3.TOUR_ID
                     WHERE ti3.INSTRUCTOR_ID = ib.INSTRUCTOR_ID
                       AND ts3.TOUR_DATE >= ADD_MONTHS(SYSDATE, -3)
                       AND ts3.TOUR_DATE <= SYSDATE
                       AND ts3.STATUS != 'CANCELLED'
                   )                                                       AS RECENT_ACTIVE_DAYS
              FROM instructor_base ib
              LEFT JOIN instructor_areas ia ON ia.INSTRUCTOR_ID = ib.INSTRUCTOR_ID
             ORDER BY REVENUE_RANK;

        -- =========================================================
        -- セクション4: 顧客セグメント分析（RFM + NTILE）
        -- CTE でRFM指標算出 → NTILEで4分位スコアリング
        -- → 多段CASEでセグメント分類 → セグメント別集計
        -- =========================================================
        OPEN o_customer_segment FOR
            WITH customer_rfm AS (
                SELECT c.CUSTOMER_ID,
                       c.LAST_NAME || ' ' || c.FIRST_NAME                  AS CUSTOMER_NAME,
                       c.LICENSE_LEVEL,
                       c.DIVE_COUNT,
                       -- Recency: 最終予約からの経過月数（小さいほど良い）
                       NVL(ROUND(MONTHS_BETWEEN(
                           SYSDATE,
                           MAX(ts.TOUR_DATE)
                       ), 1), 99)                                          AS RECENCY_MONTHS,
                       -- Frequency: 有効予約回数
                       COUNT(DISTINCT CASE
                           WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                           THEN r.RESERVATION_ID END)                      AS FREQUENCY,
                       -- Monetary: 累計利用金額
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS MONETARY,
                       -- キャンセル率
                       CASE
                           WHEN COUNT(r.RESERVATION_ID) = 0 THEN 0
                           ELSE ROUND(
                               COUNT(CASE WHEN r.STATUS = 'CANCELLED'
                                          THEN 1 END)
                               / COUNT(r.RESERVATION_ID) * 100, 1)
                       END                                                 AS CANCEL_RATE
                  FROM CUSTOMERS c
                  LEFT JOIN RESERVATIONS r      ON r.CUSTOMER_ID = c.CUSTOMER_ID
                  LEFT JOIN TOUR_SCHEDULES ts   ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE c.STATUS = 'ACTIVE'
                 GROUP BY c.CUSTOMER_ID, c.LAST_NAME, c.FIRST_NAME,
                          c.LICENSE_LEVEL, c.DIVE_COUNT
            ),
            rfm_scored AS (
                SELECT cr.*,
                       -- NTILEで4分位（4=最良、1=最低）
                       -- Recencyは逆順（経過月数が小さいほうが良い → DESC）
                       NTILE(4) OVER (ORDER BY RECENCY_MONTHS DESC)        AS R_SCORE,
                       NTILE(4) OVER (ORDER BY FREQUENCY ASC)              AS F_SCORE,
                       NTILE(4) OVER (ORDER BY MONETARY ASC)               AS M_SCORE
                  FROM customer_rfm cr
                 WHERE cr.FREQUENCY > 0 OR cr.MONETARY > 0
                        OR cr.RECENCY_MONTHS < 99
            ),
            rfm_segment AS (
                SELECT rs.*,
                       -- 複合スコア（重み付け: R×3 + F×2 + M×1、最大=24）
                       (rs.R_SCORE * 3 + rs.F_SCORE * 2 + rs.M_SCORE)     AS COMPOSITE_SCORE,
                       CASE
                           WHEN (rs.R_SCORE * 3 + rs.F_SCORE * 2 + rs.M_SCORE) >= 21
                               THEN 'VIP'
                           WHEN (rs.R_SCORE * 3 + rs.F_SCORE * 2 + rs.M_SCORE) >= 16
                               THEN 'LOYAL'
                           WHEN (rs.R_SCORE * 3 + rs.F_SCORE * 2 + rs.M_SCORE) >= 11
                               THEN 'ACTIVE'
                           WHEN (rs.R_SCORE * 3 + rs.F_SCORE * 2 + rs.M_SCORE) >= 7
                               THEN 'LIGHT'
                           ELSE 'DORMANT'
                       END                                                 AS SEGMENT
                  FROM rfm_scored rs
            )
            SELECT seg.SEGMENT,
                   seg.SEGMENT_ORDER,
                   seg.CUSTOMER_COUNT,
                   ROUND(RATIO_TO_REPORT(seg.CUSTOMER_COUNT) OVER () * 100, 1)
                                                                           AS SHARE_PCT,
                   seg.AVG_MONETARY                                        AS AVG_LTV,
                   seg.AVG_DIVE_COUNT,
                   seg.AVG_FREQUENCY,
                   seg.AVG_CANCEL_RATE,
                   seg.TOTAL_REVENUE,
                   seg.AVG_RECENCY_MONTHS,
                   LAG(seg.CUSTOMER_COUNT, 1) OVER (
                       ORDER BY seg.SEGMENT_ORDER
                   )                                                       AS PREV_SEGMENT_COUNT,
                   seg.CUSTOMER_COUNT - NVL(LAG(seg.CUSTOMER_COUNT, 1) OVER (
                       ORDER BY seg.SEGMENT_ORDER
                   ), seg.CUSTOMER_COUNT)                                  AS COUNT_DIFF
              FROM (
                SELECT SEGMENT,
                       DECODE(SEGMENT,
                           'VIP', 1, 'LOYAL', 2, 'ACTIVE', 3,
                           'LIGHT', 4, 'DORMANT', 5, 6
                       )                                                   AS SEGMENT_ORDER,
                       COUNT(*)                                            AS CUSTOMER_COUNT,
                       ROUND(AVG(MONETARY), 0)                             AS AVG_MONETARY,
                       ROUND(AVG(DIVE_COUNT), 0)                           AS AVG_DIVE_COUNT,
                       ROUND(AVG(FREQUENCY), 1)                            AS AVG_FREQUENCY,
                       ROUND(AVG(CANCEL_RATE), 1)                          AS AVG_CANCEL_RATE,
                       SUM(MONETARY)                                       AS TOTAL_REVENUE,
                       ROUND(AVG(RECENCY_MONTHS), 1)                       AS AVG_RECENCY_MONTHS
                  FROM rfm_segment
                 GROUP BY SEGMENT
              ) seg
             ORDER BY seg.SEGMENT_ORDER;

        -- =========================================================
        -- セクション5: キャンセル傾向・損失分析
        -- CONNECT BY で日数帯生成 → キャンセル日数帯別集計
        -- → 自己結合で前月比 → 移動平均・移動標準偏差 → アラート
        -- =========================================================
        OPEN o_cancel_analysis FOR
            WITH day_ranges AS (
                SELECT LEVEL AS range_id,
                       DECODE(LEVEL,
                           1, '0-2日前',
                           2, '3-6日前',
                           3, '7-13日前',
                           4, '14-29日前',
                           5, '30日以上前'
                       )                                                   AS DAY_RANGE_LABEL,
                       DECODE(LEVEL, 1, 0, 2, 3, 3, 7, 4, 14, 5, 30)      AS RANGE_MIN,
                       DECODE(LEVEL, 1, 2, 2, 6, 3, 13, 4, 29, 5, 9999)   AS RANGE_MAX
                  FROM DUAL
               CONNECT BY LEVEL <= 5
            ),
            cancel_data AS (
                SELECT r.RESERVATION_ID,
                       r.TOTAL_PRICE,
                       r.REFUND_AMOUNT,
                       EXTRACT(MONTH FROM ts.TOUR_DATE)                    AS TOUR_MONTH,
                       TO_CHAR(r.UPDATED_AT, 'DY', 'NLS_DATE_LANGUAGE=JAPANESE')
                                                                           AS CANCEL_DOW,
                       GREATEST(
                           TRUNC(ts.TOUR_DATE) - TRUNC(r.UPDATED_AT), 0
                       )                                                   AS DAYS_BEFORE
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE r.STATUS = 'CANCELLED'
                   AND EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
            ),
            range_summary AS (
                SELECT dr.range_id,
                       dr.DAY_RANGE_LABEL,
                       COUNT(cd.RESERVATION_ID)                            AS CANCEL_COUNT,
                       NVL(SUM(cd.TOTAL_PRICE), 0)                         AS LOSS_AMOUNT,
                       NVL(SUM(cd.REFUND_AMOUNT), 0)                       AS REFUND_AMOUNT,
                       NVL(SUM(cd.TOTAL_PRICE - cd.REFUND_AMOUNT), 0)      AS NET_REVENUE
                  FROM day_ranges dr
                  LEFT JOIN cancel_data cd
                    ON cd.DAYS_BEFORE BETWEEN dr.RANGE_MIN AND dr.RANGE_MAX
                 GROUP BY dr.range_id, dr.DAY_RANGE_LABEL
            ),
            monthly_cancel AS (
                SELECT cd.TOUR_MONTH,
                       COUNT(*)                                            AS CANCEL_COUNT,
                       SUM(cd.TOTAL_PRICE)                                 AS LOSS_AMOUNT
                  FROM cancel_data cd
                 GROUP BY cd.TOUR_MONTH
            ),
            monthly_trend AS (
                SELECT mc.TOUR_MONTH,
                       mc.CANCEL_COUNT,
                       mc.LOSS_AMOUNT,
                       LAG(mc.CANCEL_COUNT, 1) OVER (
                           ORDER BY mc.TOUR_MONTH
                       )                                                   AS PREV_MONTH_COUNT,
                       AVG(mc.CANCEL_COUNT) OVER (
                           ORDER BY mc.TOUR_MONTH
                           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                       )                                                   AS MOVING_AVG_3M,
                       STDDEV(mc.CANCEL_COUNT) OVER (
                           ORDER BY mc.TOUR_MONTH
                           ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
                       )                                                   AS MOVING_STDDEV_6M
                  FROM monthly_cancel mc
            ),
            dow_summary AS (
                SELECT cd.CANCEL_DOW,
                       COUNT(*)                                            AS DOW_COUNT,
                       ROUND(RATIO_TO_REPORT(COUNT(*)) OVER () * 100, 1)   AS DOW_PCT
                  FROM cancel_data cd
                 GROUP BY cd.CANCEL_DOW
            )
            SELECT 'RANGE' AS ANALYSIS_TYPE,
                   rs.range_id                                             AS SORT_KEY,
                   rs.DAY_RANGE_LABEL                                      AS DIMENSION,
                   rs.CANCEL_COUNT,
                   rs.LOSS_AMOUNT,
                   rs.REFUND_AMOUNT,
                   rs.NET_REVENUE,
                   NULL                                                    AS MOM_CHANGE,
                   NULL                                                    AS MOVING_AVG,
                   NULL                                                    AS MOVING_STDDEV,
                   NULL                                                    AS ALERT_FLAG
              FROM range_summary rs
            UNION ALL
            SELECT 'MONTHLY' AS ANALYSIS_TYPE,
                   mt.TOUR_MONTH                                           AS SORT_KEY,
                   mt.TOUR_MONTH || '月'                                   AS DIMENSION,
                   mt.CANCEL_COUNT,
                   mt.LOSS_AMOUNT,
                   NULL                                                    AS REFUND_AMOUNT,
                   NULL                                                    AS NET_REVENUE,
                   CASE
                       WHEN mt.PREV_MONTH_COUNT IS NULL OR mt.PREV_MONTH_COUNT = 0 THEN NULL
                       ELSE ROUND(
                           (mt.CANCEL_COUNT - mt.PREV_MONTH_COUNT)
                           / mt.PREV_MONTH_COUNT * 100, 1)
                   END                                                     AS MOM_CHANGE,
                   ROUND(mt.MOVING_AVG_3M, 1)                              AS MOVING_AVG,
                   ROUND(mt.MOVING_STDDEV_6M, 2)                           AS MOVING_STDDEV,
                   CASE
                       WHEN mt.MOVING_STDDEV_6M > 0
                            AND mt.CANCEL_COUNT > mt.MOVING_AVG_3M
                                + (2 * mt.MOVING_STDDEV_6M)
                       THEN 'ANOMALY'
                       ELSE 'NORMAL'
                   END                                                     AS ALERT_FLAG
              FROM monthly_trend mt
            UNION ALL
            SELECT 'DOW' AS ANALYSIS_TYPE,
                   DECODE(ds.CANCEL_DOW,
                       '月', 1, '火', 2, '水', 3, '木', 4,
                       '金', 5, '土', 6, '日', 7, 8
                   )                                                       AS SORT_KEY,
                   ds.CANCEL_DOW                                           AS DIMENSION,
                   ds.DOW_COUNT                                            AS CANCEL_COUNT,
                   NULL                                                    AS LOSS_AMOUNT,
                   NULL                                                    AS REFUND_AMOUNT,
                   NULL                                                    AS NET_REVENUE,
                   NULL                                                    AS MOM_CHANGE,
                   NULL                                                    AS MOVING_AVG,
                   NULL                                                    AS MOVING_STDDEV,
                   CASE
                       WHEN ds.DOW_PCT > 25 THEN 'HIGH'
                       ELSE 'NORMAL'
                   END                                                     AS ALERT_FLAG
              FROM dow_summary ds
             ORDER BY ANALYSIS_TYPE, SORT_KEY;

        -- =========================================================
        -- セクション6: 異常検知 + MERGE INTO REPORT_CACHE
        --              + INSERT INTO REPORT_ALERTS
        -- WITH句で全セクション主要指標をUNION ALL統合
        -- Z-score計算 → 異常値判定 → MERGE + INSERT
        -- =========================================================

        -- まず全指標を集約してキャッシュ AND アラートを生成
        MERGE INTO REPORT_CACHE rc
        USING (
            WITH all_metrics AS (
                -- 月次売上指標
                SELECT 'SALES' AS section,
                       'REVENUE_M' || EXTRACT(MONTH FROM ts.TOUR_DATE)     AS metric_name,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0)                                               AS metric_value,
                       TO_CHAR(EXTRACT(MONTH FROM ts.TOUR_DATE))           AS dim1,
                       NULL                                                AS dim2
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                 GROUP BY EXTRACT(MONTH FROM ts.TOUR_DATE)
                UNION ALL
                -- エリア別売上指標
                SELECT 'AREA' AS section,
                       'AREA_REVENUE' AS metric_name,
                       NVL(SUM(
                           CASE WHEN r.STATUS IN ('CONFIRMED', 'COMPLETED')
                                THEN r.TOTAL_PRICE ELSE 0 END
                       ), 0) AS metric_value,
                       t.AREA AS dim1,
                       NULL AS dim2
                  FROM TOURS t
                  JOIN TOUR_SCHEDULES ts ON ts.TOUR_ID = t.TOUR_ID
                  LEFT JOIN RESERVATIONS r ON r.SCHEDULE_ID = ts.SCHEDULE_ID
                 WHERE EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                 GROUP BY t.AREA
                UNION ALL
                -- キャンセル月次件数
                SELECT 'CANCEL' AS section,
                       'CANCEL_COUNT_M' || EXTRACT(MONTH FROM ts.TOUR_DATE) AS metric_name,
                       COUNT(*) AS metric_value,
                       TO_CHAR(EXTRACT(MONTH FROM ts.TOUR_DATE)) AS dim1,
                       NULL AS dim2
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON ts.SCHEDULE_ID = r.SCHEDULE_ID
                 WHERE r.STATUS = 'CANCELLED'
                   AND EXTRACT(YEAR FROM ts.TOUR_DATE) = p_year
                   AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.TOUR_DATE) = p_month)
                 GROUP BY EXTRACT(MONTH FROM ts.TOUR_DATE)
            )
            SELECT v_report_key                                            AS report_key,
                   section,
                   metric_name,
                   metric_value,
                   dim1,
                   dim2,
                   SYSDATE                                                 AS report_date
              FROM all_metrics
        ) src
        ON (rc.REPORT_KEY = src.report_key
            AND rc.SECTION = src.section
            AND rc.METRIC_NAME = src.metric_name)
        WHEN MATCHED THEN
            UPDATE SET rc.METRIC_VALUE = src.metric_value,
                       rc.DIMENSION1   = src.dim1,
                       rc.DIMENSION2   = src.dim2,
                       rc.REPORT_DATE  = src.report_date,
                       rc.GENERATED_AT = SYSTIMESTAMP
        WHEN NOT MATCHED THEN
            INSERT (CACHE_ID, REPORT_KEY, SECTION, REPORT_DATE,
                    METRIC_NAME, METRIC_VALUE, DIMENSION1, DIMENSION2, GENERATED_AT)
            VALUES (SEQ_REPORT_CACHE.NEXTVAL, src.report_key, src.section,
                    src.report_date, src.metric_name, src.metric_value,
                    src.dim1, src.dim2, SYSTIMESTAMP);

        -- 異常値検出してアラートをINSERT
        INSERT INTO REPORT_ALERTS (
            ALERT_ID, ALERT_TYPE, SEVERITY, METRIC_NAME,
            CURRENT_VALUE, THRESHOLD_VALUE, DEVIATION, MESSAGE,
            DETECTED_AT, STATUS
        )
        SELECT SEQ_REPORT_ALERTS.NEXTVAL,
               section,
               CASE
                   WHEN ABS(z_score) > 3 THEN 'HIGH'
                   WHEN ABS(z_score) > 2 THEN 'MEDIUM'
                   ELSE 'LOW'
               END                                                         AS severity,
               metric_name,
               metric_value,
               avg_value,
               ROUND(z_score, 4),
               CASE
                   WHEN z_score > 2 THEN
                       metric_name || 'が平均(' || ROUND(avg_value, 0)
                       || ')を大幅に上回っています（Z=' || ROUND(z_score, 2) || '）'
                   WHEN z_score < -2 THEN
                       metric_name || 'が平均(' || ROUND(avg_value, 0)
                       || ')を大幅に下回っています（Z=' || ROUND(z_score, 2) || '）'
                   ELSE
                       metric_name || 'は正常範囲内です'
               END,
               SYSTIMESTAMP,
               'NEW'
          FROM (
            SELECT section,
                   metric_name,
                   metric_value,
                   AVG(metric_value) OVER (
                       PARTITION BY section
                   )                                                       AS avg_value,
                   STDDEV(metric_value) OVER (
                       PARTITION BY section
                   )                                                       AS stddev_value,
                   CASE
                       WHEN STDDEV(metric_value) OVER (
                                PARTITION BY section
                            ) = 0
                       THEN 0
                       ELSE (metric_value - AVG(metric_value) OVER (
                                PARTITION BY section
                            ))
                            / STDDEV(metric_value) OVER (
                                PARTITION BY section
                            )
                   END                                                     AS z_score
              FROM REPORT_CACHE
             WHERE REPORT_KEY = v_report_key
          )
         WHERE ABS(z_score) > 2;

        SELECT COUNT(*) INTO v_alert_count
          FROM REPORT_ALERTS
         WHERE STATUS = 'NEW'
           AND DETECTED_AT >= SYSTIMESTAMP - INTERVAL '1' MINUTE;

        COMMIT;

        -- 最終カーソル: 直近生成されたアラート一覧
        OPEN o_anomaly_alerts FOR
            SELECT ra.ALERT_ID,
                   ra.ALERT_TYPE,
                   ra.SEVERITY,
                   ra.METRIC_NAME,
                   ra.CURRENT_VALUE,
                   ra.THRESHOLD_VALUE,
                   ra.DEVIATION,
                   ra.MESSAGE,
                   ra.DETECTED_AT,
                   ra.STATUS,
                   DENSE_RANK() OVER (
                       ORDER BY DECODE(ra.SEVERITY, 'HIGH', 1, 'MEDIUM', 2, 'LOW', 3, 4),
                                ra.DETECTED_AT DESC
                   )                                                       AS ALERT_RANK,
                   COUNT(*) OVER ()                                        AS TOTAL_ALERTS,
                   COUNT(*) OVER (PARTITION BY ra.SEVERITY)                AS SEVERITY_COUNT,
                   ROUND(RATIO_TO_REPORT(1) OVER (
                       PARTITION BY ra.SEVERITY
                   ) * 100, 1)                                             AS SEVERITY_DIST_PCT
              FROM REPORT_ALERTS ra
             WHERE ra.STATUS = 'NEW'
               AND ra.DETECTED_AT >= SYSTIMESTAMP - INTERVAL '10' MINUTE
             ORDER BY DECODE(ra.SEVERITY, 'HIGH', 1, 'MEDIUM', 2, 'LOW', 3, 4),
                      ra.DETECTED_AT DESC;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20529 AND -20510 THEN
                RAISE;
            ELSE
                RAISE_APPLICATION_ERROR(-20529,
                    'ダッシュボードレポート生成中にエラーが発生しました: ' || SQLERRM);
            END IF;
    END GENERATE_DASHBOARD_REPORT;

END PKG_REPORT;