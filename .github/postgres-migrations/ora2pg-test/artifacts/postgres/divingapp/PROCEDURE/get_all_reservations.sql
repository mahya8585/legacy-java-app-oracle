-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.628207

CREATE OR REPLACE PROCEDURE divingapp.get_all_reservations(
    IN p_status VARCHAR DEFAULT NULL,
    IN p_date_from TIMESTAMP DEFAULT NULL,
    IN p_date_to TIMESTAMP DEFAULT NULL,
    IN p_page BIGINT DEFAULT 1,
    IN p_page_size BIGINT DEFAULT 20,
    INOUT o_reservations REFCURSOR DEFAULT NULL,
    INOUT o_total_count BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*)
      INTO o_total_count
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE (p_status IS NULL OR r.status = p_status)
       AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
       AND (p_date_to IS NULL OR ts.tour_date <= p_date_to);

    IF o_reservations IS NULL THEN
        o_reservations := 'o_reservations';
    END IF;
    OPEN o_reservations FOR
        SELECT reservation_id,
               customer_id,
               customer_name,
               email,
               num_participants,
               total_price,
               reservation_status,
               refund_amount,
               reserved_at,
               tour_id,
               tour_name,
               tour_date,
               start_time
          FROM (
            SELECT r.reservation_id,
                   r.customer_id,
                   c.last_name || ' ' || c.first_name AS customer_name,
                   c.email,
                   r.num_participants,
                   r.total_price,
                   r.status AS reservation_status,
                   r.refund_amount,
                   r.created_at AS reserved_at,
                   t.tour_id,
                   t.tour_name,
                   ts.tour_date,
                   ts.start_time,
                   row_number() OVER (ORDER BY r.created_at DESC) AS rn
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
              JOIN divingapp.tours t ON ts.tour_id = t.tour_id
              JOIN divingapp.customers c ON r.customer_id = c.customer_id
             WHERE (p_status IS NULL OR r.status = p_status)
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
          ) s
         WHERE s.rn > v_offset
           AND s.rn <= v_offset + p_page_size;
END;
$$;