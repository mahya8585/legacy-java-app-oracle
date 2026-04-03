-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_REPORT.sql
-- Generated at: 2026-04-03T15:26:04.340021

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