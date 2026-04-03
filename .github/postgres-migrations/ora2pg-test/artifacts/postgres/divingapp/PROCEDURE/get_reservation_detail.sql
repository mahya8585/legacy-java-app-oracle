-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.611000

CREATE OR REPLACE PROCEDURE divingapp.get_reservation_detail(
    IN p_reservation_id BIGINT,
    INOUT o_reservation REFCURSOR DEFAULT NULL,
    INOUT o_options REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM divingapp.reservations
     WHERE reservation_id = p_reservation_id;

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定された予約が見つかりません。予約ID=' || p_reservation_id;
    END IF;

    IF o_reservation IS NULL THEN
        o_reservation := 'o_reservation';
    END IF;
    OPEN o_reservation FOR
        SELECT r.reservation_id,
               r.customer_id,
               r.schedule_id,
               r.num_participants,
               r.total_price,
               r.status AS reservation_status,
               r.cancel_reason,
               r.refund_amount,
               r.notes,
               r.created_at AS reserved_at,
               r.updated_at,
               t.tour_id,
               t.tour_name,
               t.area,
               t.difficulty,
               t.base_price,
               ts.tour_date,
               ts.start_time,
               ts.status AS schedule_status
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
          JOIN divingapp.tours t ON ts.tour_id = t.tour_id
         WHERE r.reservation_id = p_reservation_id;

    IF o_options IS NULL THEN
        o_options := 'o_options';
    END IF;
    OPEN o_options FOR
        SELECT ro.res_option_id,
               ro.option_id,
               om.option_name,
               om.option_category,
               om.unit_price,
               ro.quantity,
               ro.subtotal
          FROM divingapp.reservation_options ro
          JOIN divingapp.options_master om ON ro.option_id = om.option_id
         WHERE ro.reservation_id = p_reservation_id
         ORDER BY om.option_category, om.option_name;
END;
$$;