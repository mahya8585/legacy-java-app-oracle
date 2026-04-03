-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
-- Generated at: 2026-04-03T15:26:04.391694

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_RESERVATION.sql
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