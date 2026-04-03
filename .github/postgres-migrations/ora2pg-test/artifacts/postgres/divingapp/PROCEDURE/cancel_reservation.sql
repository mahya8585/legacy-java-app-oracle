-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.524438

CREATE OR REPLACE PROCEDURE divingapp.cancel_reservation(
    IN p_reservation_id BIGINT,
    IN p_customer_id BIGINT,
    IN p_cancel_reason VARCHAR DEFAULT NULL,
    INOUT o_refund_amount NUMERIC DEFAULT NULL,
    INOUT o_result_code BIGINT DEFAULT NULL,
    INOUT o_result_msg VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_res_customer_id BIGINT;
    v_res_status VARCHAR(20);
    v_total_price NUMERIC;
    v_num_participants BIGINT;
    v_schedule_id BIGINT;
    v_tour_date TIMESTAMP;
    v_days_until BIGINT;
    v_refund_rate NUMERIC;
BEGIN
    SELECT r.customer_id, r.status, r.total_price,
           r.num_participants, r.schedule_id, ts.tour_date
      INTO v_res_customer_id, v_res_status, v_total_price,
           v_num_participants, v_schedule_id, v_tour_date
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE r.reservation_id = p_reservation_id;

    IF v_res_customer_id <> p_customer_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'この予約はご自身の予約ではありません。';
    END IF;

    IF v_res_status <> 'CONFIRMED' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'この予約はキャンセルできません。ステータス=' || v_res_status;
    END IF;

    v_days_until := date_trunc('day', v_tour_date)::date - current_date;

    IF v_days_until >= 30 THEN
        v_refund_rate := 1.00;
    ELSIF v_days_until >= 14 THEN
        v_refund_rate := 0.70;
    ELSIF v_days_until >= 7 THEN
        v_refund_rate := 0.50;
    ELSIF v_days_until >= 3 THEN
        v_refund_rate := 0.30;
    ELSE
        v_refund_rate := 0.00;
    END IF;

    o_refund_amount := trunc(v_total_price * v_refund_rate);

    UPDATE divingapp.reservations
       SET status        = 'CANCELLED',
           cancel_reason = p_cancel_reason,
           refund_amount = o_refund_amount,
           updated_at    = CURRENT_TIMESTAMP
     WHERE reservation_id = p_reservation_id;

    UPDATE divingapp.tour_schedules
       SET remaining_seats = remaining_seats + v_num_participants,
           status = CASE
                        WHEN status = 'FULL' THEN 'OPEN'
                        ELSE status
                    END,
           version    = version + 1,
           updated_at = CURRENT_TIMESTAMP
     WHERE schedule_id = v_schedule_id;

    COMMIT;

    o_result_code := 0;
    o_result_msg  := '予約をキャンセルしました。返金額=' || o_refund_amount
                     || '（返金率' || (v_refund_rate * 100) || '%、ツアー' || v_days_until || '日前）';

EXCEPTION
    WHEN others THEN
        ROLLBACK;
        RAISE;
END;
$$;