-- PostgreSQL DDL for divingapp.pkg_reservation (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: unknown_type
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:02.114237

CREATE OR REPLACE FUNCTION divingapp.calc_total_price(
    p_schedule_id BIGINT,
    p_num_participants BIGINT,
    p_option_ids VARCHAR DEFAULT NULL,
    p_option_quantities VARCHAR DEFAULT NULL
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_price NUMERIC;
    v_total NUMERIC := 0;
    v_opt_id BIGINT;
    v_opt_qty BIGINT;
    v_unit_price NUMERIC;
    v_opt_count BIGINT := 0;
    v_qty_count BIGINT := 0;
BEGIN
    SELECT t.base_price
      INTO v_base_price
      FROM divingapp.tour_schedules ts
      JOIN divingapp.tours t ON ts.tour_id = t.tour_id
     WHERE ts.schedule_id = p_schedule_id;

    v_total := v_base_price * p_num_participants;

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

            SELECT unit_price
              INTO v_unit_price
              FROM divingapp.options_master
             WHERE option_id = v_opt_id
               AND status = 'ACTIVE';

            v_total := v_total + (v_unit_price * v_opt_qty);
        END LOOP;
    END IF;

    RETURN v_total;
EXCEPTION
    WHEN no_data_found THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定されたスケジュールが見つかりません。SCHEDULE_ID=' || p_schedule_id;
    WHEN others THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '料金計算中にエラーが発生しました: ' || SQLERRM;
END;
$$;

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