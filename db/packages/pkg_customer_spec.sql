CREATE OR REPLACE PACKAGE PKG_CUSTOMER AS
    -- ログイン認証
    PROCEDURE AUTHENTICATE(
        p_email         IN  VARCHAR2,
        p_password      IN  VARCHAR2,
        o_customer_id   OUT NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );

    -- 顧客新規登録
    PROCEDURE REGISTER_CUSTOMER(
        p_email         IN  VARCHAR2,
        p_password      IN  VARCHAR2,
        p_last_name     IN  VARCHAR2,
        p_first_name    IN  VARCHAR2,
        p_last_name_kana  IN VARCHAR2 DEFAULT NULL,
        p_first_name_kana IN VARCHAR2 DEFAULT NULL,
        p_phone         IN  VARCHAR2 DEFAULT NULL,
        p_birth_date    IN  DATE     DEFAULT NULL,
        p_license_level IN  VARCHAR2 DEFAULT NULL,
        o_customer_id   OUT NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );

    -- プロフィール更新
    PROCEDURE UPDATE_PROFILE(
        p_customer_id   IN  NUMBER,
        p_last_name     IN  VARCHAR2,
        p_first_name    IN  VARCHAR2,
        p_last_name_kana  IN VARCHAR2,
        p_first_name_kana IN VARCHAR2,
        p_phone         IN  VARCHAR2,
        p_birth_date    IN  DATE,
        p_license_level IN  VARCHAR2,
        p_emergency_contact IN VARCHAR2,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    );

    -- 顧客情報取得
    PROCEDURE GET_CUSTOMER_INFO(
        p_customer_id   IN  NUMBER,
        o_customer      OUT SYS_REFCURSOR
    );

    -- 管理用：顧客一覧
    PROCEDURE GET_ALL_CUSTOMERS(
        p_keyword       IN  VARCHAR2 DEFAULT NULL,
        p_status        IN  VARCHAR2 DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 20,
        o_customers     OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    );
END PKG_CUSTOMER;
/
