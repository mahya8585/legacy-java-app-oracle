-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_REPORT.sql
CREATE OR REPLACE PROCEDURE divingapp.get_monthly_sales(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    OPEN o_report FOR
        SELECT p_year                                              AS report_year,
               EXTRACT(MONTH FROM ts.tour_date)                    AS report_month,
               COUNT(r.reservation_id)                             AS total_reservations,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price
                        ELSE 0
                   END
               ), 0)                                               AS total_revenue,
               COUNT(
                   CASE WHEN r.status = 'CANCELLED'
                        THEN 1
                   END
               )                                                   AS cancelled_count
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts
            ON ts.schedule_id = r.schedule_id
          JOIN divingapp.tours t
            ON t.tour_id = ts.tour_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
         ORDER BY report_month;
END;
$$;

CREATE OR REPLACE PROCEDURE divingapp.get_tour_popularity(
    IN p_date_from timestamp DEFAULT NULL,
    IN p_date_to timestamp DEFAULT NULL,
    IN p_limit numeric DEFAULT 10,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit numeric := COALESCE(p_limit, 10);
BEGIN
    IF v_limit < 1 THEN
        v_limit := 10;
    END IF;

    OPEN o_report FOR
        SELECT *
          FROM (
            SELECT t.tour_name,
                   t.area,
                   COUNT(r.reservation_id)                         AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price
                            ELSE 0
                       END
                   ), 0)                                           AS total_revenue,
                   ROUND(COALESCE(AVG(r.num_participants), 0), 1)   AS avg_participants,
                   RANK() OVER (
                       ORDER BY COUNT(r.reservation_id) DESC
                   )                                               AS popularity_rank
              FROM divingapp.tours t
              JOIN divingapp.tour_schedules ts
                ON ts.tour_id = t.tour_id
              JOIN divingapp.reservations r
                ON r.schedule_id = ts.schedule_id
             WHERE r.status IN ('CONFIRMED', 'COMPLETED')
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to   IS NULL OR ts.tour_date <= p_date_to)
             GROUP BY t.tour_id, t.tour_name, t.area
          ) s
         WHERE popularity_rank <= v_limit
         ORDER BY popularity_rank;
END;
$$;

CREATE OR REPLACE PROCEDURE divingapp.get_occupancy_rate(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    OPEN o_report FOR
        SELECT t.tour_name,
               t.area,
               COUNT(DISTINCT ts.schedule_id)                      AS schedule_count,
               COALESCE(SUM(t.max_participants), 0)                AS total_capacity,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.num_participants
                        ELSE 0
                   END
               ), 0)                                               AS total_booked,
               CASE
                   WHEN COALESCE(SUM(t.max_participants), 0) = 0 THEN 0
                   ELSE ROUND(
                       COALESCE(SUM(
                           CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                                THEN r.num_participants
                                ELSE 0
                           END
                       ), 0)
                       / SUM(t.max_participants) * 100
                   , 1)
               END                                                 AS occupancy_rate
          FROM divingapp.tours t
          JOIN divingapp.tour_schedules ts
            ON ts.tour_id = t.tour_id
          LEFT JOIN divingapp.reservations r
            ON r.schedule_id = ts.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
           AND ts.status <> 'CANCELLED'
         GROUP BY t.tour_id, t.tour_name, t.area
         ORDER BY occupancy_rate DESC;
END;
$$;

CREATE OR REPLACE PROCEDURE divingapp.generate_dashboard_report(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_sales_trend refcursor DEFAULT NULL,
    INOUT o_area_matrix refcursor DEFAULT NULL,
    INOUT o_instructor_kpi refcursor DEFAULT NULL,
    INOUT o_customer_segment refcursor DEFAULT NULL,
    INOUT o_cancel_analysis refcursor DEFAULT NULL,
    INOUT o_anomaly_alerts refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_date_from     timestamp;
    v_date_to       timestamp;
    v_prev_year     numeric;
    v_report_key    varchar(100);
    v_alert_count   numeric := 0;
BEGIN
    -- -------------------------------------------------------
    -- 入力バリデーション
    -- -------------------------------------------------------
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    v_prev_year  := p_year - 1;
    v_report_key := 'DASHBOARD_' || to_char(p_year) || '_' || COALESCE(to_char(p_month), 'ALL');

    IF p_month IS NOT NULL THEN
        v_date_from := to_date(p_year::text || '-' || lpad(p_month::text, 2, '0') || '-01', 'YYYY-MM-DD');
        v_date_to   := (date_trunc('month', v_date_from) + interval '1 month - 1 day')::date;
    ELSE
        v_date_from := to_date(p_year::text || '-01-01', 'YYYY-MM-DD');
        v_date_to   := to_date(p_year::text || '-12-31', 'YYYY-MM-DD');
    END IF;

    -- =========================================================
    -- セクション1: 売上推移分析
    -- CONNECT BY でカレンダー生成 → LEFT JOIN でゼロ埋め
    -- LAG で前月比、サブクエリで前年同月比、RATIO_TO_REPORT で構成比
    -- SUM OVER ROWS UNBOUNDED PRECEDING で累計
    -- =========================================================
    OPEN o_sales_trend FOR
        WITH RECURSIVE calendar AS (
            SELECT 1 AS cal_month
            UNION ALL
            SELECT cal_month + 1
              FROM calendar
             WHERE cal_month < 12
        ),
        current_year_sales AS (
            SELECT EXTRACT(MONTH FROM ts.tour_date)                    AS sale_month,
                   COUNT(DISTINCT r.reservation_id)                   AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS revenue,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants ELSE 0 END
                   ), 0)                                              AS participants,
                   COUNT(CASE WHEN r.status = 'CANCELLED' THEN 1 END) AS cancel_count
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
             GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        ),
        prev_year_sales AS (
            SELECT EXTRACT(MONTH FROM ts.tour_date)                    AS sale_month,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS revenue
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = v_prev_year
             GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        ),
        combined AS (
            SELECT c.cal_month                                        AS report_month,
                   COALESCE(cur.reservation_count, 0)                 AS reservation_count,
                   COALESCE(cur.revenue, 0)                           AS revenue,
                   COALESCE(cur.participants, 0)                      AS participants,
                   COALESCE(cur.cancel_count, 0)                      AS cancel_count,
                   LAG(COALESCE(cur.revenue, 0), 1) OVER (
                       ORDER BY c.cal_month
                   )                                                  AS prev_month_revenue,
                   COALESCE(prev.revenue, 0)                          AS yoy_revenue,
                   SUM(COALESCE(cur.revenue, 0)) OVER (
                       ORDER BY c.cal_month
                       ROWS UNBOUNDED PRECEDING
                   )                                                  AS cumulative_revenue,
                   (COALESCE(cur.revenue, 0) / NULLIF(SUM(COALESCE(cur.revenue, 0)) OVER (), 0))
                                                                      AS share_rate
              FROM calendar c
              LEFT JOIN current_year_sales cur ON cur.sale_month = c.cal_month
              LEFT JOIN prev_year_sales prev   ON prev.sale_month = c.cal_month
             WHERE (p_month IS NULL OR c.cal_month = p_month)
        )
        SELECT report_month,
               reservation_count,
               revenue,
               participants,
               cancel_count,
               prev_month_revenue,
               CASE
                   WHEN prev_month_revenue IS NULL OR prev_month_revenue = 0 THEN NULL
                   ELSE ROUND((revenue - prev_month_revenue)
                              / prev_month_revenue * 100, 1)
               END                                                    AS mom_change_rate,
               yoy_revenue,
               CASE
                   WHEN yoy_revenue = 0 THEN NULL
                   ELSE ROUND((revenue - yoy_revenue)
                              / yoy_revenue * 100, 1)
               END                                                    AS yoy_change_rate,
               cumulative_revenue,
               ROUND(share_rate * 100, 1)                             AS share_pct,
               CASE
                   WHEN prev_month_revenue IS NULL              THEN 'N/A'
                   WHEN revenue > prev_month_revenue * 1.05     THEN 'UP'
                   WHEN revenue < prev_month_revenue * 0.95     THEN 'DOWN'
                   ELSE 'FLAT'
               END                                                    AS trend
          FROM combined
         ORDER BY report_month;

    -- =========================================================
    -- セクション2: エリア × 難易度クロス集計
    -- PIVOT で難易度を列展開、GROUPING SETS で小計/総計
    -- =========================================================
    OPEN o_area_matrix FOR
        SELECT COALESCE(area_name, '【合計】')                         AS area,
               COALESCE(difficulty, '小計')                            AS difficulty,
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
               END                                                    AS beginner_rev_pct,
               CASE
                   WHEN total_revenue = 0 THEN 0
                   ELSE ROUND(advanced_rev / NULLIF(total_revenue, 0) * 100, 1)
               END                                                    AS advanced_rev_pct
          FROM (
            SELECT CASE grouping_id(t.area, t.difficulty)
                       WHEN 0 THEN t.area
                       WHEN 1 THEN t.area
                       WHEN 3 THEN NULL
                   END                                                AS area_name,
                   CASE grouping_id(t.area, t.difficulty)
                       WHEN 0 THEN t.difficulty
                       WHEN 1 THEN NULL
                       WHEN 3 THEN NULL
                   END                                                AS difficulty,
                   grouping_id(t.area, t.difficulty)                  AS grouping_level,
                   COUNT(r.reservation_id)                            AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS total_revenue,
                   ROUND(COALESCE(AVG(r.num_participants), 0), 1)      AS avg_participants,
                   COUNT(CASE WHEN t.difficulty = 'BEGINNER'
                              THEN r.reservation_id END)              AS beginner_count,
                   COUNT(CASE WHEN t.difficulty = 'INTERMEDIATE'
                              THEN r.reservation_id END)              AS intermediate_count,
                   COUNT(CASE WHEN t.difficulty = 'ADVANCED'
                              THEN r.reservation_id END)              AS advanced_count,
                   COUNT(CASE WHEN t.difficulty = 'EXPERT'
                              THEN r.reservation_id END)              AS expert_count,
                   COALESCE(SUM(
                       CASE WHEN t.difficulty = 'BEGINNER'
                                 AND r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS beginner_rev,
                   COALESCE(SUM(
                       CASE WHEN t.difficulty = 'ADVANCED'
                                 AND r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS advanced_rev
              FROM divingapp.tours t
              JOIN divingapp.tour_schedules ts ON ts.tour_id = t.tour_id
              LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
               AND ts.status <> 'CANCELLED'
             GROUP BY GROUPING SETS (
                 (t.area, t.difficulty),
                 (t.area),
                 ()
             )
          ) s
         ORDER BY CASE WHEN grouping_level = 3 THEN 1 ELSE 0 END,
                  area_name NULLS LAST,
                  CASE difficulty
                      WHEN 'BEGINNER' THEN 1
                      WHEN 'INTERMEDIATE' THEN 2
                      WHEN 'ADVANCED' THEN 3
                      WHEN 'EXPERT' THEN 4
                      ELSE 5
                  END NULLS LAST;

    -- =========================================================
    -- セクション3: インストラクターKPI
    -- 5テーブル結合 + LISTAGG + 相関サブクエリ(リピート率)
    -- + DENSE_RANK / PERCENT_RANK / スカラーサブクエリ
    -- =========================================================
    OPEN o_instructor_kpi FOR
        WITH instructor_base AS (
            SELECT i.instructor_id,
                   i.last_name || ' ' || i.first_name                 AS instructor_name,
                   i.certification,
                   i.experience_years,
                   COUNT(DISTINCT ts.schedule_id)                     AS schedule_count,
                   COUNT(DISTINCT r.reservation_id)                   AS reservation_count,
                   COUNT(DISTINCT r.customer_id)                      AS unique_customers,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS total_revenue,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants ELSE 0 END
                   ), 0)                                              AS total_participants,
                   ROUND(COALESCE(AVG(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants END
                   ), 0), 1)                                          AS avg_participants
              FROM divingapp.instructors i
              JOIN divingapp.tour_instructors ti ON ti.instructor_id = i.instructor_id
              JOIN divingapp.tours t            ON t.tour_id = ti.tour_id
              JOIN divingapp.tour_schedules ts  ON ts.tour_id = t.tour_id
              LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
             WHERE i.status = 'ACTIVE'
               AND EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
             GROUP BY i.instructor_id, i.last_name, i.first_name,
                      i.certification, i.experience_years
        ),
        instructor_areas AS (
            SELECT ti.instructor_id,
                   string_agg(DISTINCT t.area, ', ' ORDER BY t.area)  AS area_list
              FROM divingapp.tour_instructors ti
              JOIN divingapp.tours t ON t.tour_id = ti.tour_id
             WHERE t.status = 'ACTIVE'
             GROUP BY ti.instructor_id
        )
        SELECT ib.instructor_name,
               ib.certification,
               ib.experience_years,
               ib.schedule_count,
               ib.reservation_count,
               ib.unique_customers,
               ib.total_revenue,
               ib.total_participants,
               ib.avg_participants,
               DENSE_RANK() OVER (
                   ORDER BY ib.total_revenue DESC
               )                                                      AS revenue_rank,
               ROUND(PERCENT_RANK() OVER (
                   ORDER BY ib.avg_participants
               ) * 100, 1)                                            AS participant_percentile,
               ROUND((ib.total_revenue / NULLIF(SUM(ib.total_revenue) OVER (), 0)) * 100, 1)
                                                                      AS revenue_share_pct,
               COALESCE(ia.area_list, '-')                            AS area_list,
               -- 相関サブクエリ: リピート率（同一インストラクターのツアーに2回以上予約した顧客の割合）
               CASE
                   WHEN ib.unique_customers = 0 THEN 0
                   ELSE ROUND(
                       (SELECT COUNT(DISTINCT repeat_cust.customer_id)
                          FROM (
                              SELECT r2.customer_id,
                                     COUNT(DISTINCT r2.reservation_id) AS visit_count
                                FROM divingapp.reservations r2
                                JOIN divingapp.tour_schedules ts2 ON ts2.schedule_id = r2.schedule_id
                                JOIN divingapp.tour_instructors ti2 ON ti2.tour_id = ts2.tour_id
                               WHERE ti2.instructor_id = ib.instructor_id
                                 AND r2.status IN ('CONFIRMED', 'COMPLETED')
                               GROUP BY r2.customer_id
                              HAVING COUNT(DISTINCT r2.reservation_id) >= 2
                          ) repeat_cust
                       ) / NULLIF(ib.unique_customers, 0) * 100
                   , 1)
               END                                                    AS repeat_rate,
               -- スカラーサブクエリ: 直近3ヶ月の稼働日数
               (SELECT COUNT(DISTINCT ts3.tour_date)
                  FROM divingapp.tour_schedules ts3
                  JOIN divingapp.tour_instructors ti3 ON ti3.tour_id = ts3.tour_id
                 WHERE ti3.instructor_id = ib.instructor_id
                   AND ts3.tour_date >= (current_timestamp - interval '3 months')
                   AND ts3.tour_date <= current_timestamp
                   AND ts3.status <> 'CANCELLED'
               )                                                      AS recent_active_days
          FROM instructor_base ib
          LEFT JOIN instructor_areas ia ON ia.instructor_id = ib.instructor_id
         ORDER BY revenue_rank;

    -- =========================================================
    -- セクション4: 顧客セグメント分析（RFM + NTILE）
    -- CTE でRFM指標算出 → NTILEで4分位スコアリング
    -- → 多段CASEでセグメント分類 → セグメント別集計
    -- =========================================================
    OPEN o_customer_segment FOR
        WITH customer_rfm AS (
            SELECT c.customer_id,
                   c.last_name || ' ' || c.first_name                 AS customer_name,
                   c.license_level,
                   c.dive_count,
                   -- Recency: 最終予約からの経過月数（小さいほど良い）
                   COALESCE(ROUND(((EXTRACT(YEAR FROM age(current_timestamp, MAX(ts.tour_date))) * 12)
                                    + EXTRACT(MONTH FROM age(current_timestamp, MAX(ts.tour_date)))
                                    + (EXTRACT(DAY FROM age(current_timestamp, MAX(ts.tour_date))) / 30.0))::numeric, 1), 99)
                                                                    AS recency_months,
                   -- Frequency: 有効予約回数
                   COUNT(DISTINCT CASE
                       WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                       THEN r.reservation_id END)                     AS frequency,
                   -- Monetary: 累計利用金額
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS monetary,
                   -- キャンセル率
                   CASE
                       WHEN COUNT(r.reservation_id) = 0 THEN 0
                       ELSE ROUND(
                           COUNT(CASE WHEN r.status = 'CANCELLED'
                                      THEN 1 END)::numeric
                           / COUNT(r.reservation_id) * 100, 1)
                   END                                                AS cancel_rate
              FROM divingapp.customers c
              LEFT JOIN divingapp.reservations r      ON r.customer_id = c.customer_id
              LEFT JOIN divingapp.tour_schedules ts   ON ts.schedule_id = r.schedule_id
             WHERE c.status = 'ACTIVE'
             GROUP BY c.customer_id, c.last_name, c.first_name,
                      c.license_level, c.dive_count
        ),
        rfm_scored AS (
            SELECT cr.*,
                   -- NTILEで4分位（4=最良、1=最低）
                   -- Recencyは逆順（経過月数が小さいほうが良い → DESC）
                   NTILE(4) OVER (ORDER BY recency_months DESC)       AS r_score,
                   NTILE(4) OVER (ORDER BY frequency ASC)            AS f_score,
                   NTILE(4) OVER (ORDER BY monetary ASC)             AS m_score
              FROM customer_rfm cr
             WHERE cr.frequency > 0 OR cr.monetary > 0
                    OR cr.recency_months < 99
        ),
        rfm_segment AS (
            SELECT rs.*,
                   -- 複合スコア（重み付け: R×3 + F×2 + M×1、最大=24）
                   (rs.r_score * 3 + rs.f_score * 2 + rs.m_score)     AS composite_score,
                   CASE
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 21
                           THEN 'VIP'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 16
                           THEN 'LOYAL'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 11
                           THEN 'ACTIVE'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 7
                           THEN 'LIGHT'
                       ELSE 'DORMANT'
                   END                                                AS segment
              FROM rfm_scored rs
        )
        SELECT seg.segment,
               seg.segment_order,
               seg.customer_count,
               ROUND((seg.customer_count / NULLIF(SUM(seg.customer_count) OVER (), 0)) * 100, 1)
                                                                      AS share_pct,
               seg.avg_monetary                                       AS avg_ltv,
               seg.avg_dive_count,
               seg.avg_frequency,
               seg.avg_cancel_rate,
               seg.total_revenue,
               seg.avg_recency_months,
               LAG(seg.customer_count, 1) OVER (
                   ORDER BY seg.segment_order
               )                                                      AS prev_segment_count,
               seg.customer_count - COALESCE(LAG(seg.customer_count, 1) OVER (
                   ORDER BY seg.segment_order
               ), seg.customer_count)                                 AS count_diff
          FROM (
            SELECT segment,
                   CASE segment
                       WHEN 'VIP' THEN 1
                       WHEN 'LOYAL' THEN 2
                       WHEN 'ACTIVE' THEN 3
                       WHEN 'LIGHT' THEN 4
                       WHEN 'DORMANT' THEN 5
                       ELSE 6
                   END                                                AS segment_order,
                   COUNT(*)                                           AS customer_count,
                   ROUND(AVG(monetary), 0)                            AS avg_monetary,
                   ROUND(AVG(dive_count), 0)                          AS avg_dive_count,
                   ROUND(AVG(frequency), 1)                           AS avg_frequency,
                   ROUND(AVG(cancel_rate), 1)                         AS avg_cancel_rate,
                   SUM(monetary)                                      AS total_revenue,
                   ROUND(AVG(recency_months), 1)                      AS avg_recency_months
              FROM rfm_segment
             GROUP BY segment
          ) seg
         ORDER BY seg.segment_order;

    -- =========================================================
    -- セクション5: キャンセル傾向・損失分析
    -- CONNECT BY で日数帯生成 → キャンセル日数帯別集計
    -- → 自己結合で前月比 → 移動平均・移動標準偏差 → アラート
    -- =========================================================
    OPEN o_cancel_analysis FOR
        WITH RECURSIVE day_ranges AS (
            SELECT 1 AS range_id,
                   '0-2日前'::text AS day_range_label,
                   0::int AS range_min,
                   2::int AS range_max
            UNION ALL
            SELECT 2, '3-6日前', 3, 6
            UNION ALL
            SELECT 3, '7-13日前', 7, 13
            UNION ALL
            SELECT 4, '14-29日前', 14, 29
            UNION ALL
            SELECT 5, '30日以上前', 30, 9999
        ),
        cancel_data AS (
            SELECT r.reservation_id,
                   r.total_price,
                   r.refund_amount,
                   EXTRACT(MONTH FROM ts.tour_date)                   AS tour_month,
                   CASE EXTRACT(ISODOW FROM r.updated_at)
                       WHEN 1 THEN '月'
                       WHEN 2 THEN '火'
                       WHEN 3 THEN '水'
                       WHEN 4 THEN '木'
                       WHEN 5 THEN '金'
                       WHEN 6 THEN '土'
                       WHEN 7 THEN '日'
                   END                                               AS cancel_dow,
                   GREATEST(
                       (ts.tour_date::date - r.updated_at::date), 0
                   )                                                 AS days_before
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE r.status = 'CANCELLED'
               AND EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
        ),
        range_summary AS (
            SELECT dr.range_id,
                   dr.day_range_label,
                   COUNT(cd.reservation_id)                           AS cancel_count,
                   COALESCE(SUM(cd.total_price), 0)                   AS loss_amount,
                   COALESCE(SUM(cd.refund_amount), 0)                 AS refund_amount,
                   COALESCE(SUM(cd.total_price - cd.refund_amount), 0) AS net_revenue
              FROM day_ranges dr
              LEFT JOIN cancel_data cd
                ON cd.days_before BETWEEN dr.range_min AND dr.range_max
             GROUP BY dr.range_id, dr.day_range_label
        ),
        monthly_cancel AS (
            SELECT cd.tour_month,
                   COUNT(*)                                           AS cancel_count,
                   SUM(cd.total_price)                                AS loss_amount
              FROM cancel_data cd
             GROUP BY cd.tour_month
        ),
        monthly_trend AS (
            SELECT mc.tour_month,
                   mc.cancel_count,
                   mc.loss_amount,
                   LAG(mc.cancel_count, 1) OVER (
                       ORDER BY mc.tour_month
                   )                                                  AS prev_month_count,
                   AVG(mc.cancel_count) OVER (
                       ORDER BY mc.tour_month
                       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                   )                                                  AS moving_avg_3m,
                   STDDEV(mc.cancel_count) OVER (
                       ORDER BY mc.tour_month
                       ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
                   )                                                  AS moving_stddev_6m
              FROM monthly_cancel mc
        ),
        dow_summary AS (
            SELECT cd.cancel_dow,
                   COUNT(*)                                           AS dow_count,
                   ROUND((COUNT(*)::numeric / NULLIF(SUM(COUNT(*)) OVER (), 0)) * 100, 1)
                                                                      AS dow_pct
              FROM cancel_data cd
             GROUP BY cd.cancel_dow
        )
        SELECT 'RANGE' AS analysis_type,
               rs.range_id                                             AS sort_key,
               rs.day_range_label                                      AS dimension,
               rs.cancel_count,
               rs.loss_amount,
               rs.refund_amount,
               rs.net_revenue,
               NULL::numeric                                           AS mom_change,
               NULL::numeric                                           AS moving_avg,
               NULL::numeric                                           AS moving_stddev,
               NULL::text                                              AS alert_flag
          FROM range_summary rs
        UNION ALL
        SELECT 'MONTHLY' AS analysis_type,
               mt.tour_month                                           AS sort_key,
               mt.tour_month::text || '月'                              AS dimension,
               mt.cancel_count,
               mt.loss_amount,
               NULL::numeric                                           AS refund_amount,
               NULL::numeric                                           AS net_revenue,
               CASE
                   WHEN mt.prev_month_count IS NULL OR mt.prev_month_count = 0 THEN NULL
                   ELSE ROUND(
                       (mt.cancel_count - mt.prev_month_count)::numeric
                       / mt.prev_month_count * 100, 1)
               END                                                     AS mom_change,
               ROUND(mt.moving_avg_3m::numeric, 1)                     AS moving_avg,
               ROUND(mt.moving_stddev_6m::numeric, 2)                  AS moving_stddev,
               CASE
                   WHEN mt.moving_stddev_6m > 0
                        AND mt.cancel_count > mt.moving_avg_3m
                            + (2 * mt.moving_stddev_6m)
                   THEN 'ANOMALY'
                   ELSE 'NORMAL'
               END                                                     AS alert_flag
          FROM monthly_trend mt
        UNION ALL
        SELECT 'DOW' AS analysis_type,
               CASE ds.cancel_dow
                   WHEN '月' THEN 1
                   WHEN '火' THEN 2
                   WHEN '水' THEN 3
                   WHEN '木' THEN 4
                   WHEN '金' THEN 5
                   WHEN '土' THEN 6
                   WHEN '日' THEN 7
                   ELSE 8
               END                                                     AS sort_key,
               ds.cancel_dow                                           AS dimension,
               ds.dow_count                                            AS cancel_count,
               NULL::numeric                                           AS loss_amount,
               NULL::numeric                                           AS refund_amount,
               NULL::numeric                                           AS net_revenue,
               NULL::numeric                                           AS mom_change,
               NULL::numeric                                           AS moving_avg,
               NULL::numeric                                           AS moving_stddev,
               CASE
                   WHEN ds.dow_pct > 25 THEN 'HIGH'
                   ELSE 'NORMAL'
               END                                                     AS alert_flag
          FROM dow_summary ds
         ORDER BY analysis_type, sort_key;

    -- =========================================================
    -- セクション6: 異常検知 + MERGE INTO REPORT_CACHE
    --              + INSERT INTO REPORT_ALERTS
    -- WITH句で全セクション主要指標をUNION ALL統合
    -- Z-score計算 → 異常値判定 → MERGE + INSERT
    -- =========================================================

    WITH all_metrics AS (
        SELECT 'SALES' AS section,
               ('REVENUE_M' || EXTRACT(MONTH FROM ts.tour_date))::text AS metric_name,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price ELSE 0 END
               ), 0)                                                  AS metric_value,
               to_char(EXTRACT(MONTH FROM ts.tour_date), 'FM99')       AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        UNION ALL
        SELECT 'AREA' AS section,
               'AREA_REVENUE' AS metric_name,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price ELSE 0 END
               ), 0)                                                  AS metric_value,
               t.area                                                 AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.tours t
          JOIN divingapp.tour_schedules ts ON ts.tour_id = t.tour_id
          LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY t.area
        UNION ALL
        SELECT 'CANCEL' AS section,
               ('CANCEL_COUNT_M' || EXTRACT(MONTH FROM ts.tour_date))::text AS metric_name,
               COUNT(*)::numeric                                      AS metric_value,
               to_char(EXTRACT(MONTH FROM ts.tour_date), 'FM99')       AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
         WHERE r.status = 'CANCELLED'
           AND EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
    ),
    upserted AS (
        INSERT INTO divingapp.report_cache(
            report_key, section, report_date,
            metric_name, metric_value, dimension1, dimension2, generated_at
        )
        SELECT v_report_key,
               section,
               current_date,
               metric_name,
               metric_value,
               dim1,
               dim2,
               current_timestamp
          FROM all_metrics
        ON CONFLICT (report_key, section, metric_name)
        DO UPDATE SET metric_value = EXCLUDED.metric_value,
                      dimension1   = EXCLUDED.dimension1,
                      dimension2   = EXCLUDED.dimension2,
                      report_date  = EXCLUDED.report_date,
                      generated_at = EXCLUDED.generated_at
        RETURNING 1
    )
    SELECT 1 INTO v_alert_count FROM upserted LIMIT 1;

    INSERT INTO divingapp.report_alerts (
        alert_type, severity, metric_name,
        current_value, threshold_value, deviation, message,
        detected_at, status
    )
    SELECT section,
           CASE
               WHEN ABS(z_score) > 3 THEN 'HIGH'
               WHEN ABS(z_score) > 2 THEN 'MEDIUM'
               ELSE 'LOW'
           END                                                     AS severity,
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
           current_timestamp,
           'NEW'
      FROM (
        SELECT section,
               metric_name,
               metric_value,
               AVG(metric_value) OVER (PARTITION BY section)         AS avg_value,
               STDDEV(metric_value) OVER (PARTITION BY section)      AS stddev_value,
               CASE
                   WHEN STDDEV(metric_value) OVER (PARTITION BY section) = 0
                   THEN 0
                   ELSE (metric_value - AVG(metric_value) OVER (PARTITION BY section))
                        / STDDEV(metric_value) OVER (PARTITION BY section)
               END                                                   AS z_score
          FROM divingapp.report_cache
         WHERE report_key = v_report_key
      ) z
     WHERE ABS(z_score) > 2;

    OPEN o_anomaly_alerts FOR
        SELECT ra.alert_id,
               ra.alert_type,
               ra.severity,
               ra.metric_name,
               ra.current_value,
               ra.threshold_value,
               ra.deviation,
               ra.message,
               ra.detected_at,
               ra.status,
               DENSE_RANK() OVER (
                   ORDER BY CASE ra.severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END,
                            ra.detected_at DESC
               )                                                      AS alert_rank,
               COUNT(*) OVER ()                                       AS total_alerts,
               COUNT(*) OVER (PARTITION BY ra.severity)               AS severity_count,
               ROUND((COUNT(*) OVER (PARTITION BY ra.severity)::numeric / NULLIF(COUNT(*) OVER ()::numeric, 0)) * 100, 1)
                                                                      AS severity_dist_pct
          FROM divingapp.report_alerts ra
         WHERE ra.status = 'NEW'
           AND ra.detected_at >= (current_timestamp - interval '10 minutes')
         ORDER BY CASE ra.severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END,
                  ra.detected_at DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'ダッシュボードレポート生成中にエラーが発生しました: ' || SQLERRM;
END;
$$;