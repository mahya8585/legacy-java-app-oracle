-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.393769

CREATE OR REPLACE PROCEDURE divingapp.create_reservation(
    IN p_customer_id BIGINT,
    IN p_schedule_id BIGINT,
    IN p_num_participants BIGINT,
    IN p_option_ids VARCHAR DEFAULT NULL,
    IN p_option_quantities VARCHAR DEFAULT NULL,
    IN p_notes VARCHAR DEFAULT NULL,
    INOUT o_reservation_id BIGINT DEFAULT NULL,
    INOUT o_total_price NUMERIC DEFAULT NULL,
    INOUT o_result_code BIGINT DEFAULT NULL,
    INOUT o_result_msg VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_schedule_status VARCHAR(20);
    v_remaining_seats BIGINT;
    v_version BIGINT;
    v_tour_id BIGINT;
    v_opt_id BIGINT;
    v_opt_qty BIGINT;
    v_unit_price NUMERIC;
    v_opt_count BIGINT := 0;
    v_qty_count BIGINT := 0;
    v_updated BIGINT;
BEGIN
    IF p_customer_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客IDは必須です。';
    END IF;
    IF p_schedule_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'スケジュールIDは必須です。';
    END IF;
    IF p_num_participants IS NULL OR p_num_participants <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '参加人数は1名以上を指定してください。';
    END IF;

    SELECT ts.status, ts.remaining_seats, ts.version, ts.tour_id
      INTO v_schedule_status, v_remaining_seats, v_version, v_tour_id
      FROM divingapp.tour_schedules ts
     WHERE ts.schedule_id = p_schedule_id
     FOR UPDATE NOWAIT;

    IF v_schedule_status <> 'OPEN' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'このスケジュールは予約受付停止中です。ステータス=' || v_schedule_status;
    END IF;

    IF v_remaining_seats < p_num_participants THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '残席数が不足しています。残席=' || v_remaining_seats || ', 要求=' || p_num_participants;
    END IF;

    o_total_price := divingapp.calc_total_price(p_schedule_id, p_num_participants, p_option_ids, p_option_quantities);

    SELECT nextval('divingapp.seq_reservations') INTO o_reservation_id;

    INSERT INTO divingapp.reservations (
        reservation_id, customer_id, schedule_id,
        num_participants, total_price, status,
        notes, created_at, updated_at
    ) VALUES (
        o_reservation_id, p_customer_id, p_schedule_id,
        p_num_participants, o_total_price, 'CONFIRMED',
        p_notes, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    IF p_option_ids IS NOT NULL AND length(btrim(p_option_ids)) > 0 THEN
        v_opt_count := array_length(regexp_split_to_array(p_option_ids, '\\s*,\\s*'), 1);
        v_qty_count := array_length(regexp_split_to_array(COALESCE(p_option_quantities, '1'), '\\s*,\\s*'), 1);

        FOR i IN 1..v_opt_count LOOP
            v_opt_id := NULLIF(btrim((regexp_split_to_array(p_option_ids, '\\s*,\\s*'))[i]), '')::BIGINT;

            IF i <= v_qty_count AND p_option_quantities IS NOT NULL THEN
                v_opt_qty := NULLIF(btrim((regexp_split_to_array(p_option_quantities, '\\s*,\\s*'))[i]), '')::BIGINT;
            ELSE
                v_opt_qty := 1;
            END IF;

            IF v_opt_qty IS NULL OR v_opt_qty <= 0 THEN
                v_opt_qty := 1;
            END IF;

            SELECT unit_price INTO v_unit_price
              FROM divingapp.options_master
             WHERE option_id = v_opt_id
               AND status = 'ACTIVE';

            INSERT INTO divingapp.reservation_options (
                res_option_id, reservation_id, option_id,
                quantity, subtotal
            ) VALUES (
                nextval('divingapp.seq_reservation_options'), o_reservation_id, v_opt_id,
                v_opt_qty, v_unit_price * v_opt_qty
            );
        END LOOP;
    END IF;

    UPDATE divingapp.tour_schedules
       SET remaining_seats = remaining_seats - p_num_participants,
           status = CASE
                        WHEN remaining_seats - p_num_participants = 0 THEN 'FULL'
                        ELSE status
                    END,
           version    = version + 1,
           updated_at = CURRENT_TIMESTAMP
     WHERE schedule_id = p_schedule_id
       AND version = v_version;

    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '他のユーザーによって予約が更新されました。再度お試しください。';
    END IF;

    COMMIT;

    o_result_code := 0;
    o_result_msg  := '予約が完了しました。予約ID=' || o_reservation_id;

EXCEPTION
    WHEN lock_not_available THEN
        ROLLBACK;
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '他のユーザーによってスケジュールがロックされています。再度お試しください。';
    WHEN others THEN
        ROLLBACK;
        RAISE;
END;
$$;