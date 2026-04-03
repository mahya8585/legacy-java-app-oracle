-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.625044

CREATE OR REPLACE PROCEDURE divingapp.get_customer_reservations(
    IN p_customer_id BIGINT,
    IN p_status VARCHAR DEFAULT NULL,
    INOUT o_reservations REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF o_reservations IS NULL THEN
        o_reservations := 'o_reservations';
    END IF;
    OPEN o_reservations FOR
        SELECT r.reservation_id,
               r.num_participants,
               r.total_price,
               r.status AS reservation_status,
               r.refund_amount,
               r.created_at AS reserved_at,
               t.tour_id,
               t.tour_name,
               t.area,
               ts.tour_date,
               ts.start_time
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
          JOIN divingapp.tours t ON ts.tour_id = t.tour_id
         WHERE r.customer_id = p_customer_id
           AND (p_status IS NULL OR r.status = p_status)
         ORDER BY r.created_at DESC;
END;
$$;