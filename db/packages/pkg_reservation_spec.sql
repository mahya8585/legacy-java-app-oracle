CREATE OR REPLACE PACKAGE PKG_RESERVATION AS
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
/
