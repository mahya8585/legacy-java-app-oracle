-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_REPORT.sql
-- Generated at: 2026-04-03T15:26:04.338012

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