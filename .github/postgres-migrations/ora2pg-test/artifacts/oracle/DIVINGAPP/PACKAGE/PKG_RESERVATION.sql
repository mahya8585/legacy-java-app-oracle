
  CREATE OR REPLACE EDITIONABLE PACKAGE "DIVINGAPP"."PKG_RESERVATION" AS
    -- 予約登録（残席チェック、料金計算、楽観ロック）
    PROCEDURE CREATE_RESERVATION(
        p_customer_id       IN  NUMBER,
        p_schedule_id       IN  NUMBER,
        p_num_participants  IN  NUMBER,
        p_option_ids        IN  VARCHAR2 DEFAULT NULL,
        p_option_quantities IN  VARCHAR2 DEFAULT NULL,
        p_notes             IN  VARCHAR2 DEFAULT NULL,
        o_reservation_id    OUT NUMBER,
        o_total_price       OUT NUMBER,
        o_result_code       OUT NUMBER,
        o_result_msg        OUT VARCHAR2
    );

    -- 予約キャンセル（キャンセルポリシー判定、返金額計算）
    PROCEDURE CANCEL_RESERVATION(
        p_reservation_id    IN  NUMBER,
        p_customer_id       IN  NUMBER,
        p_cancel_reason     IN  VARCHAR2 DEFAULT NULL,
        o_refund_amount     OUT NUMBER,
        o_result_code       OUT NUMBER,
        o_result_msg        OUT VARCHAR2
    );

    -- 予約詳細取得
    PROCEDURE GET_RESERVATION_DETAIL(
        p_reservation_id    IN  NUMBER,
        o_reservation       OUT SYS_REFCURSOR,
        o_options           OUT SYS_REFCURSOR
    );

    -- 顧客別予約一覧
    PROCEDURE GET_CUSTOMER_RESERVATIONS(
        p_customer_id       IN  NUMBER,
        p_status            IN  VARCHAR2 DEFAULT NULL,
        o_reservations      OUT SYS_REFCURSOR
    );

    -- 合計料金計算ファンクション
    FUNCTION CALC_TOTAL_PRICE(
        p_schedule_id       IN  NUMBER,
        p_num_participants  IN  NUMBER,
        p_option_ids        IN  VARCHAR2 DEFAULT NULL,
        p_option_quantities IN  VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;

    -- 管理用：全予約一覧
    PROCEDURE GET_ALL_RESERVATIONS(
        p_status        IN  VARCHAR2 DEFAULT NULL,
        p_date_from     IN  DATE     DEFAULT NULL,
        p_date_to       IN  DATE     DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 20,
        o_reservations  OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );
END PKG_RESERVATION;
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "DIVINGAPP"."PKG_RESERVATION" AS

    -- =========================================================================
    -- 合計料金計算ファンクション
    -- =========================================================================
    FUNCTION CALC_TOTAL_PRICE(
        p_schedule_id       IN  NUMBER,
        p_num_participants  IN  NUMBER,
        p_option_ids        IN  VARCHAR2 DEFAULT NULL,
        p_option_quantities IN  VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS
        v_base_price    NUMBER;
        v_total         NUMBER := 0;
        v_opt_id        NUMBER;
        v_opt_qty       NUMBER;
        v_unit_price    NUMBER;
        v_opt_count     NUMBER := 0;
        v_qty_count     NUMBER := 0;
    BEGIN
        -- スケジュールからツアーの基本料金を取得
        SELECT t.BASE_PRICE
          INTO v_base_price
          FROM TOUR_SCHEDULES ts
          JOIN TOURS t ON ts.TOUR_ID = t.TOUR_ID
         WHERE ts.SCHEDULE_ID = p_schedule_id;

        -- 基本料金 × 参加人数
        v_total := v_base_price * p_num_participants;

        -- オプション料金の加算
        IF p_option_ids IS NOT NULL AND LENGTH(TRIM(p_option_ids)) > 0 THEN
            -- オプション数のカウント
            v_opt_count := REGEXP_COUNT(p_option_ids, '[^,]+');
            v_qty_count := REGEXP_COUNT(NVL(p_option_quantities, '1'), '[^,]+');

            FOR i IN 1 .. v_opt_count LOOP
                -- カンマ区切りからi番目を抽出
                v_opt_id := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_option_ids, '[^,]+', 1, i)));

                -- 数量取得（指定がなければ1）
                IF i <= v_qty_count AND p_option_quantities IS NOT NULL THEN
                    v_opt_qty := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_option_quantities, '[^,]+', 1, i)));
                ELSE
                    v_opt_qty := 1;
                END IF;

                IF v_opt_qty <= 0 THEN
                    v_opt_qty := 1;
                END IF;

                -- オプション単価取得
                BEGIN
                    SELECT UNIT_PRICE
                      INTO v_unit_price
                      FROM OPTIONS_MASTER
                     WHERE OPTION_ID = v_opt_id
                       AND STATUS = 'ACTIVE';
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        RAISE_APPLICATION_ERROR(-20110,
                            '無効なオプションIDです: ' || v_opt_id);
                END;

                v_total := v_total + (v_unit_price * v_opt_qty);
            END LOOP;
        END IF;

        RETURN v_total;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20111, '指定されたスケジュールが見つかりません。SCHEDULE_ID=' || p_schedule_id);
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20199 AND -20100 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20112, '料金計算中にエラーが発生しました: ' || SQLERRM);
    END CALC_TOTAL_PRICE;

    -- =========================================================================
    -- 予約登録（残席チェック + 楽観ロック + オプション登録）
    -- =========================================================================
    PROCEDURE CREATE_RESERVATION(
        p_customer_id       IN  NUMBER,
        p_schedule_id       IN  NUMBER,
        p_num_participants  IN  NUMBER,
        p_option_ids        IN  VARCHAR2 DEFAULT NULL,
        p_option_quantities IN  VARCHAR2 DEFAULT NULL,
        p_notes             IN  VARCHAR2 DEFAULT NULL,
        o_reservation_id    OUT NUMBER,
        o_total_price       OUT NUMBER,
        o_result_code       OUT NUMBER,
        o_result_msg        OUT VARCHAR2
    ) IS
        v_schedule_status   VARCHAR2(20);
        v_remaining_seats   NUMBER;
        v_version           NUMBER;
        v_tour_id           NUMBER;
        v_opt_id            NUMBER;
        v_opt_qty           NUMBER;
        v_unit_price        NUMBER;
        v_opt_count         NUMBER := 0;
        v_qty_count         NUMBER := 0;
        v_updated           NUMBER;
    BEGIN
        -- 入力バリデーション
        IF p_customer_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20100, '顧客IDは必須です。');
        END IF;
        IF p_schedule_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20101, 'スケジュールIDは必須です。');
        END IF;
        IF p_num_participants IS NULL OR p_num_participants <= 0 THEN
            RAISE_APPLICATION_ERROR(-20102, '参加人数は1名以上を指定してください。');
        END IF;

        -- スケジュール取得（SELECT FOR UPDATE で楽観ロック）
        BEGIN
            SELECT ts.STATUS, ts.REMAINING_SEATS, ts.VERSION, ts.TOUR_ID
              INTO v_schedule_status, v_remaining_seats, v_version, v_tour_id
              FROM TOUR_SCHEDULES ts
             WHERE ts.SCHEDULE_ID = p_schedule_id
               FOR UPDATE NOWAIT;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20103, '指定されたスケジュールが見つかりません。SCHEDULE_ID=' || p_schedule_id);
        END;

        -- スケジュールステータス確認
        IF v_schedule_status <> 'OPEN' THEN
            RAISE_APPLICATION_ERROR(-20104, 'このスケジュールは予約受付停止中です。ステータス=' || v_schedule_status);
        END IF;

        -- 残席チェック
        IF v_remaining_seats < p_num_participants THEN
            RAISE_APPLICATION_ERROR(-20105,
                '残席数が不足しています。残席=' || v_remaining_seats || ', 要求=' || p_num_participants);
        END IF;

        -- 合計料金計算
        o_total_price := CALC_TOTAL_PRICE(p_schedule_id, p_num_participants, p_option_ids, p_option_quantities);

        -- 予約レコード登録
        SELECT SEQ_RESERVATIONS.NEXTVAL INTO o_reservation_id FROM DUAL;

        INSERT INTO RESERVATIONS (
            RESERVATION_ID, CUSTOMER_ID, SCHEDULE_ID,
            NUM_PARTICIPANTS, TOTAL_PRICE, STATUS,
            NOTES, CREATED_AT, UPDATED_AT
        ) VALUES (
            o_reservation_id, p_customer_id, p_schedule_id,
            p_num_participants, o_total_price, 'CONFIRMED',
            p_notes, SYSTIMESTAMP, SYSTIMESTAMP
        );

        -- オプション登録
        IF p_option_ids IS NOT NULL AND LENGTH(TRIM(p_option_ids)) > 0 THEN
            v_opt_count := REGEXP_COUNT(p_option_ids, '[^,]+');
            v_qty_count := REGEXP_COUNT(NVL(p_option_quantities, '1'), '[^,]+');

            FOR i IN 1 .. v_opt_count LOOP
                v_opt_id := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_option_ids, '[^,]+', 1, i)));

                IF i <= v_qty_count AND p_option_quantities IS NOT NULL THEN
                    v_opt_qty := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_option_quantities, '[^,]+', 1, i)));
                ELSE
                    v_opt_qty := 1;
                END IF;

                IF v_opt_qty <= 0 THEN
                    v_opt_qty := 1;
                END IF;

                SELECT UNIT_PRICE INTO v_unit_price
                  FROM OPTIONS_MASTER
                 WHERE OPTION_ID = v_opt_id
                   AND STATUS = 'ACTIVE';

                INSERT INTO RESERVATION_OPTIONS (
                    RES_OPTION_ID, RESERVATION_ID, OPTION_ID,
                    QUANTITY, SUBTOTAL
                ) VALUES (
                    SEQ_RESERVATION_OPTIONS.NEXTVAL, o_reservation_id, v_opt_id,
                    v_opt_qty, v_unit_price * v_opt_qty
                );
            END LOOP;
        END IF;

        -- 残席数の更新（楽観ロック：VERSIONチェック）
        UPDATE TOUR_SCHEDULES
           SET REMAINING_SEATS = REMAINING_SEATS - p_num_participants,
               STATUS = CASE
                            WHEN REMAINING_SEATS - p_num_participants = 0 THEN 'FULL'
                            ELSE STATUS
                        END,
               VERSION    = VERSION + 1,
               UPDATED_AT = SYSTIMESTAMP
         WHERE SCHEDULE_ID = p_schedule_id
           AND VERSION = v_version;

        v_updated := SQL%ROWCOUNT;
        IF v_updated = 0 THEN
            RAISE_APPLICATION_ERROR(-20106, '他のユーザーによって予約が更新されました。再度お試しください。');
        END IF;

        COMMIT;

        o_result_code := 0;
        o_result_msg  := '予約が完了しました。予約ID=' || o_reservation_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20199 AND -20100 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20107, '予約登録中にエラーが発生しました: ' || SQLERRM);
    END CREATE_RESERVATION;

    -- =========================================================================
    -- 予約キャンセル（キャンセルポリシー判定 + 返金額計算）
    -- =========================================================================
    PROCEDURE CANCEL_RESERVATION(
        p_reservation_id    IN  NUMBER,
        p_customer_id       IN  NUMBER,
        p_cancel_reason     IN  VARCHAR2 DEFAULT NULL,
        o_refund_amount     OUT NUMBER,
        o_result_code       OUT NUMBER,
        o_result_msg        OUT VARCHAR2
    ) IS
        v_res_customer_id   NUMBER;
        v_res_status        VARCHAR2(20);
        v_total_price       NUMBER;
        v_num_participants  NUMBER;
        v_schedule_id       NUMBER;
        v_tour_date         DATE;
        v_days_until        NUMBER;
        v_refund_rate       NUMBER;
    BEGIN
        -- 予約情報取得
        BEGIN
            SELECT r.CUSTOMER_ID, r.STATUS, r.TOTAL_PRICE,
                   r.NUM_PARTICIPANTS, r.SCHEDULE_ID, ts.TOUR_DATE
              INTO v_res_customer_id, v_res_status, v_total_price,
                   v_num_participants, v_schedule_id, v_tour_date
              FROM RESERVATIONS r
              JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
             WHERE r.RESERVATION_ID = p_reservation_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20120, '指定された予約が見つかりません。予約ID=' || p_reservation_id);
        END;

        -- 所有者チェック
        IF v_res_customer_id <> p_customer_id THEN
            RAISE_APPLICATION_ERROR(-20121, 'この予約はご自身の予約ではありません。');
        END IF;

        -- ステータスチェック
        IF v_res_status <> 'CONFIRMED' THEN
            RAISE_APPLICATION_ERROR(-20122, 'この予約はキャンセルできません。ステータス=' || v_res_status);
        END IF;

        -- キャンセルポリシー判定
        v_days_until := TRUNC(v_tour_date) - TRUNC(SYSDATE);

        IF v_days_until >= 30 THEN
            v_refund_rate := 1.00;    -- 100%返金
        ELSIF v_days_until >= 14 THEN
            v_refund_rate := 0.70;    -- 70%返金
        ELSIF v_days_until >= 7 THEN
            v_refund_rate := 0.50;    -- 50%返金
        ELSIF v_days_until >= 3 THEN
            v_refund_rate := 0.30;    -- 30%返金
        ELSE
            v_refund_rate := 0.00;    -- 返金なし
        END IF;

        o_refund_amount := TRUNC(v_total_price * v_refund_rate);

        -- 予約ステータス更新
        UPDATE RESERVATIONS
           SET STATUS        = 'CANCELLED',
               CANCEL_REASON = p_cancel_reason,
               REFUND_AMOUNT = o_refund_amount,
               UPDATED_AT    = SYSTIMESTAMP
         WHERE RESERVATION_ID = p_reservation_id;

        -- 残席数の復旧
        UPDATE TOUR_SCHEDULES
           SET REMAINING_SEATS = REMAINING_SEATS + v_num_participants,
               STATUS = CASE
                            WHEN STATUS = 'FULL' THEN 'OPEN'
                            ELSE STATUS
                        END,
               VERSION    = VERSION + 1,
               UPDATED_AT = SYSTIMESTAMP
         WHERE SCHEDULE_ID = v_schedule_id;

        COMMIT;

        o_result_code := 0;
        o_result_msg  := '予約をキャンセルしました。返金額=' || o_refund_amount
                         || '（返金率' || (v_refund_rate * 100) || '%、ツアー' || v_days_until || '日前）';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20199 AND -20100 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20123, '予約キャンセル中にエラーが発生しました: ' || SQLERRM);
    END CANCEL_RESERVATION;

    -- =========================================================================
    -- 予約詳細取得
    -- =========================================================================
    PROCEDURE GET_RESERVATION_DETAIL(
        p_reservation_id    IN  NUMBER,
        o_reservation       OUT SYS_REFCURSOR,
        o_options           OUT SYS_REFCURSOR
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
          FROM RESERVATIONS
         WHERE RESERVATION_ID = p_reservation_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20130, '指定された予約が見つかりません。予約ID=' || p_reservation_id);
        END IF;

        -- 予約情報 + ツアー・スケジュール結合
        OPEN o_reservation FOR
            SELECT r.RESERVATION_ID,
                   r.CUSTOMER_ID,
                   r.SCHEDULE_ID,
                   r.NUM_PARTICIPANTS,
                   r.TOTAL_PRICE,
                   r.STATUS AS RESERVATION_STATUS,
                   r.CANCEL_REASON,
                   r.REFUND_AMOUNT,
                   r.NOTES,
                   r.CREATED_AT AS RESERVED_AT,
                   r.UPDATED_AT,
                   t.TOUR_ID,
                   t.TOUR_NAME,
                   t.AREA,
                   t.DIFFICULTY,
                   t.BASE_PRICE,
                   ts.TOUR_DATE,
                   ts.START_TIME,
                   ts.STATUS AS SCHEDULE_STATUS
              FROM RESERVATIONS r
              JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
              JOIN TOURS t ON ts.TOUR_ID = t.TOUR_ID
             WHERE r.RESERVATION_ID = p_reservation_id;

        -- 予約オプション
        OPEN o_options FOR
            SELECT ro.RES_OPTION_ID,
                   ro.OPTION_ID,
                   om.OPTION_NAME,
                   om.OPTION_CATEGORY,
                   om.UNIT_PRICE,
                   ro.QUANTITY,
                   ro.SUBTOTAL
              FROM RESERVATION_OPTIONS ro
              JOIN OPTIONS_MASTER om ON ro.OPTION_ID = om.OPTION_ID
             WHERE ro.RESERVATION_ID = p_reservation_id
             ORDER BY om.OPTION_CATEGORY, om.OPTION_NAME;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20199 AND -20100 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20131, '予約詳細取得中にエラーが発生しました: ' || SQLERRM);
    END GET_RESERVATION_DETAIL;

    -- =========================================================================
    -- 顧客別予約一覧
    -- =========================================================================
    PROCEDURE GET_CUSTOMER_RESERVATIONS(
        p_customer_id       IN  NUMBER,
        p_status            IN  VARCHAR2 DEFAULT NULL,
        o_reservations      OUT SYS_REFCURSOR
    ) IS
    BEGIN
        OPEN o_reservations FOR
            SELECT r.RESERVATION_ID,
                   r.NUM_PARTICIPANTS,
                   r.TOTAL_PRICE,
                   r.STATUS AS RESERVATION_STATUS,
                   r.REFUND_AMOUNT,
                   r.CREATED_AT AS RESERVED_AT,
                   t.TOUR_ID,
                   t.TOUR_NAME,
                   t.AREA,
                   ts.TOUR_DATE,
                   ts.START_TIME
              FROM RESERVATIONS r
              JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
              JOIN TOURS t ON ts.TOUR_ID = t.TOUR_ID
             WHERE r.CUSTOMER_ID = p_customer_id
               AND (p_status IS NULL OR r.STATUS = p_status)
             ORDER BY r.CREATED_AT DESC;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20140, '顧客予約一覧取得中にエラーが発生しました: ' || SQLERRM);
    END GET_CUSTOMER_RESERVATIONS;

    -- =========================================================================
    -- 管理用：全予約一覧（ページネーション + フィルター）
    -- =========================================================================
    PROCEDURE GET_ALL_RESERVATIONS(
        p_status        IN  VARCHAR2 DEFAULT NULL,
        p_date_from     IN  DATE     DEFAULT NULL,
        p_date_to       IN  DATE     DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 20,
        o_reservations  OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    ) IS
        v_offset NUMBER;
    BEGIN
        v_offset := (p_page - 1) * p_page_size;

        -- 総件数
        SELECT COUNT(*)
          INTO o_total_count
          FROM RESERVATIONS r
          JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
         WHERE (p_status IS NULL OR r.STATUS = p_status)
           AND (p_date_from IS NULL OR ts.TOUR_DATE >= p_date_from)
           AND (p_date_to IS NULL OR ts.TOUR_DATE <= p_date_to);

        -- ページネーション付き一覧
        OPEN o_reservations FOR
            SELECT *
              FROM (
                SELECT r.RESERVATION_ID,
                       r.CUSTOMER_ID,
                       c.LAST_NAME || ' ' || c.FIRST_NAME AS CUSTOMER_NAME,
                       c.EMAIL,
                       r.NUM_PARTICIPANTS,
                       r.TOTAL_PRICE,
                       r.STATUS AS RESERVATION_STATUS,
                       r.REFUND_AMOUNT,
                       r.CREATED_AT AS RESERVED_AT,
                       t.TOUR_ID,
                       t.TOUR_NAME,
                       ts.TOUR_DATE,
                       ts.START_TIME,
                       ROW_NUMBER() OVER (ORDER BY r.CREATED_AT DESC) AS RN
                  FROM RESERVATIONS r
                  JOIN TOUR_SCHEDULES ts ON r.SCHEDULE_ID = ts.SCHEDULE_ID
                  JOIN TOURS t ON ts.TOUR_ID = t.TOUR_ID
                  JOIN CUSTOMERS c ON r.CUSTOMER_ID = c.CUSTOMER_ID
                 WHERE (p_status IS NULL OR r.STATUS = p_status)
                   AND (p_date_from IS NULL OR ts.TOUR_DATE >= p_date_from)
                   AND (p_date_to IS NULL OR ts.TOUR_DATE <= p_date_to)
              )
             WHERE RN > v_offset
               AND RN <= v_offset + p_page_size;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20141, '予約一覧取得中にエラーが発生しました: ' || SQLERRM);
    END GET_ALL_RESERVATIONS;

END PKG_RESERVATION;