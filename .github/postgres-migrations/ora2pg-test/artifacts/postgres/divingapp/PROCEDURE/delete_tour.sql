-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (PROCEDURE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_TOUR.sql
-- Generated at: 2026-04-03T15:26:04.315894

CREATE OR REPLACE PROCEDURE divingapp.delete_tour(
    IN p_tour_id NUMERIC,
    OUT o_result_code NUMERIC,
    OUT o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
    v_future_res NUMERIC;
BEGIN
    -- ツアー存在チェック
    SELECT COUNT(*)
      INTO v_count
      FROM divingapp.tours
     WHERE tour_id = p_tour_id
       AND status <> 'DELETED';

    IF v_count = 0 THEN
        RAISE EXCEPTION '削除対象のツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
    END IF;

    -- 未来の確定済み予約があるかチェック
    SELECT COUNT(*)
      INTO v_future_res
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE ts.tour_id = p_tour_id
       AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
       AND r.status = 'CONFIRMED';

    IF v_future_res > 0 THEN
        RAISE EXCEPTION '確定済みの予約が%件存在するため削除できません。先に予約をキャンセルしてください。', v_future_res USING ERRCODE = 'P0001';
    END IF;

    -- 論理削除
    UPDATE divingapp.tours
       SET status     = 'DELETED',
           updated_at = CURRENT_TIMESTAMP
     WHERE tour_id = p_tour_id;

    o_result_code := 0;
    o_result_msg  := 'ツアーを削除しました。TOUR_ID=' || p_tour_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー削除中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;