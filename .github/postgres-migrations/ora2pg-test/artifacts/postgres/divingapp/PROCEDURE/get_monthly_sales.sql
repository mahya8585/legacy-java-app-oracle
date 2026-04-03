-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_REPORT.sql
-- Generated at: 2026-04-03T15:26:04.336003

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