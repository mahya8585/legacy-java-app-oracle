CREATE OR REPLACE PACKAGE PKG_DIVING_LOG AS
    -- 顧客別ダイビングログ一覧
    PROCEDURE GET_CUSTOMER_LOGS(
        p_customer_id   IN  NUMBER,
        p_page          IN  NUMBER DEFAULT 1,
        p_page_size     IN  NUMBER DEFAULT 20,
        o_logs          OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );

    -- ダイビングログ登録・更新
    PROCEDURE SAVE_DIVING_LOG(
        p_log_id        IN OUT NUMBER,
        p_customer_id   IN  NUMBER,
        p_site_id       IN  NUMBER,
        p_reservation_id IN NUMBER DEFAULT NULL,
        p_dive_date     IN  DATE,
        p_max_depth     IN  NUMBER,
        p_dive_time     IN  NUMBER,
        p_water_temp    IN  NUMBER,
        p_visibility    IN  NUMBER,
        p_weather       IN  VARCHAR2,
        p_buddy         IN  VARCHAR2,
        p_notes         IN  CLOB,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );
END PKG_DIVING_LOG;
/
