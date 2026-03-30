CREATE OR REPLACE PACKAGE BODY PKG_CUSTOMER AS

    -- =========================================================================
    -- ログイン認証（DBMS_CRYPTO SHA-256）
    -- =========================================================================
    PROCEDURE AUTHENTICATE(
        p_email         IN  VARCHAR2,
        p_password      IN  VARCHAR2,
        o_customer_id   OUT NUMBER,
        o_result_code   OUT NUMBER,
        o_result_msg    OUT VARCHAR2
    ) IS
        v_stored_hash   RAW(64);
        v_input_hash    RAW(64);
        v_status        VARCHAR2(20);
    BEGIN
        -- 入力バリデーション
        IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20200, 'メールアドレスは必須です。');
        END IF;
        IF p_password IS NULL OR LENGTH(TRIM(p_password)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20201, 'パスワードは必須です。');
        END IF;

        -- 顧客検索
        BEGIN
            SELECT CUSTOMER_ID, PASSWORD_HASH, STATUS
              INTO o_customer_id, v_stored_hash, v_status
              FROM CUSTOMERS
             WHERE EMAIL = p_email;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                o_customer_id := NULL;
                o_result_code := -1;
                o_result_msg  := 'メールアドレスまたはパスワードが正しくありません。';
                RETURN;
        END;

        -- アカウントステータスチェック
        IF v_status <> 'ACTIVE' THEN
            o_customer_id := NULL;
            o_result_code := -2;
            o_result_msg  := 'アカウントが無効です。管理者にお問い合わせください。';
            RETURN;
        END IF;

        -- パスワードハッシュ比較
        v_input_hash := DBMS_CRYPTO.HASH(
            UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'),
            DBMS_CRYPTO.HASH_SH256
        );

        IF v_stored_hash = v_input_hash THEN
            o_result_code := 0;
            o_result_msg  := '認証に成功しました。';
        ELSE
            o_customer_id := NULL;
            o_result_code := -1;
            o_result_msg  := 'メールアドレスまたはパスワードが正しくありません。';
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20299 AND -20200 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20210, '認証処理中にエラーが発生しました: ' || SQLERRM);
    END AUTHENTICATE;

    -- =========================================================================
    -- 顧客新規登録
    -- =========================================================================
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
    ) IS
        v_email_count   NUMBER;
        v_password_hash RAW(64);
    BEGIN
        -- 必須項目バリデーション
        IF p_email IS NULL OR LENGTH(TRIM(p_email)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20220, 'メールアドレスは必須です。');
        END IF;
        IF p_password IS NULL OR LENGTH(p_password) < 8 THEN
            RAISE_APPLICATION_ERROR(-20221, 'パスワードは8文字以上で入力してください。');
        END IF;
        IF p_last_name IS NULL OR LENGTH(TRIM(p_last_name)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20222, '姓は必須です。');
        END IF;
        IF p_first_name IS NULL OR LENGTH(TRIM(p_first_name)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20223, '名は必須です。');
        END IF;

        -- メールアドレス重複チェック
        SELECT COUNT(*) INTO v_email_count
          FROM CUSTOMERS
         WHERE EMAIL = p_email;

        IF v_email_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20224, 'このメールアドレスは既に登録されています。');
        END IF;

        -- パスワードハッシュ生成（SHA-256）
        v_password_hash := DBMS_CRYPTO.HASH(
            UTL_I18N.STRING_TO_RAW(p_password, 'AL32UTF8'),
            DBMS_CRYPTO.HASH_SH256
        );

        -- 顧客レコード登録
        SELECT SEQ_CUSTOMERS.NEXTVAL INTO o_customer_id FROM DUAL;

        INSERT INTO CUSTOMERS (
            CUSTOMER_ID, EMAIL, PASSWORD_HASH,
            LAST_NAME, FIRST_NAME,
            LAST_NAME_KANA, FIRST_NAME_KANA,
            PHONE, BIRTH_DATE, LICENSE_LEVEL,
            DIVE_COUNT, STATUS,
            CREATED_AT, UPDATED_AT
        ) VALUES (
            o_customer_id, p_email, v_password_hash,
            p_last_name, p_first_name,
            p_last_name_kana, p_first_name_kana,
            p_phone, p_birth_date, p_license_level,
            0, 'ACTIVE',
            SYSTIMESTAMP, SYSTIMESTAMP
        );

        COMMIT;

        o_result_code := 0;
        o_result_msg  := '顧客登録が完了しました。顧客ID=' || o_customer_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20299 AND -20200 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20225, '顧客登録中にエラーが発生しました: ' || SQLERRM);
    END REGISTER_CUSTOMER;

    -- =========================================================================
    -- プロフィール更新
    -- =========================================================================
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
    ) IS
        v_count NUMBER;
    BEGIN
        -- 顧客存在チェック
        SELECT COUNT(*) INTO v_count
          FROM CUSTOMERS
         WHERE CUSTOMER_ID = p_customer_id
           AND STATUS = 'ACTIVE';

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20230, '顧客が見つかりません。顧客ID=' || p_customer_id);
        END IF;

        -- バリデーション
        IF p_last_name IS NULL OR LENGTH(TRIM(p_last_name)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20231, '姓は必須です。');
        END IF;
        IF p_first_name IS NULL OR LENGTH(TRIM(p_first_name)) = 0 THEN
            RAISE_APPLICATION_ERROR(-20232, '名は必須です。');
        END IF;

        -- プロフィール更新
        UPDATE CUSTOMERS
           SET LAST_NAME        = p_last_name,
               FIRST_NAME       = p_first_name,
               LAST_NAME_KANA   = p_last_name_kana,
               FIRST_NAME_KANA  = p_first_name_kana,
               PHONE            = p_phone,
               BIRTH_DATE       = p_birth_date,
               LICENSE_LEVEL    = p_license_level,
               EMERGENCY_CONTACT = p_emergency_contact,
               UPDATED_AT       = SYSTIMESTAMP
         WHERE CUSTOMER_ID = p_customer_id;

        COMMIT;

        o_result_code := 0;
        o_result_msg  := 'プロフィールを更新しました。';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            IF SQLCODE BETWEEN -20299 AND -20200 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20233, 'プロフィール更新中にエラーが発生しました: ' || SQLERRM);
    END UPDATE_PROFILE;

    -- =========================================================================
    -- 顧客情報取得
    -- =========================================================================
    PROCEDURE GET_CUSTOMER_INFO(
        p_customer_id   IN  NUMBER,
        o_customer      OUT SYS_REFCURSOR
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
          FROM CUSTOMERS
         WHERE CUSTOMER_ID = p_customer_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20240, '顧客が見つかりません。顧客ID=' || p_customer_id);
        END IF;

        OPEN o_customer FOR
            SELECT CUSTOMER_ID,
                   EMAIL,
                   LAST_NAME,
                   FIRST_NAME,
                   LAST_NAME_KANA,
                   FIRST_NAME_KANA,
                   PHONE,
                   BIRTH_DATE,
                   LICENSE_LEVEL,
                   DIVE_COUNT,
                   EMERGENCY_CONTACT,
                   STATUS,
                   CREATED_AT,
                   UPDATED_AT
              FROM CUSTOMERS
             WHERE CUSTOMER_ID = p_customer_id;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE BETWEEN -20299 AND -20200 THEN
                RAISE;
            END IF;
            RAISE_APPLICATION_ERROR(-20241, '顧客情報取得中にエラーが発生しました: ' || SQLERRM);
    END GET_CUSTOMER_INFO;

    -- =========================================================================
    -- 管理用：顧客一覧（キーワード検索 + ステータスフィルター + ページネーション）
    -- =========================================================================
    PROCEDURE GET_ALL_CUSTOMERS(
        p_keyword       IN  VARCHAR2 DEFAULT NULL,
        p_status        IN  VARCHAR2 DEFAULT NULL,
        p_page          IN  NUMBER   DEFAULT 1,
        p_page_size     IN  NUMBER   DEFAULT 20,
        o_customers     OUT SYS_REFCURSOR,
        o_total_count   OUT NUMBER
    ) IS
        v_offset NUMBER;
    BEGIN
        v_offset := (p_page - 1) * p_page_size;

        -- 総件数
        SELECT COUNT(*)
          INTO o_total_count
          FROM CUSTOMERS
         WHERE (p_status IS NULL OR STATUS = p_status)
           AND (p_keyword IS NULL
                OR UPPER(LAST_NAME || FIRST_NAME) LIKE '%' || UPPER(p_keyword) || '%'
                OR UPPER(LAST_NAME_KANA || FIRST_NAME_KANA) LIKE '%' || UPPER(p_keyword) || '%'
                OR UPPER(EMAIL) LIKE '%' || UPPER(p_keyword) || '%');

        -- ページネーション付き一覧
        OPEN o_customers FOR
            SELECT *
              FROM (
                SELECT CUSTOMER_ID,
                       EMAIL,
                       LAST_NAME,
                       FIRST_NAME,
                       LAST_NAME_KANA,
                       FIRST_NAME_KANA,
                       PHONE,
                       LICENSE_LEVEL,
                       DIVE_COUNT,
                       STATUS,
                       CREATED_AT,
                       ROW_NUMBER() OVER (ORDER BY CREATED_AT DESC) AS RN
                  FROM CUSTOMERS
                 WHERE (p_status IS NULL OR STATUS = p_status)
                   AND (p_keyword IS NULL
                        OR UPPER(LAST_NAME || FIRST_NAME) LIKE '%' || UPPER(p_keyword) || '%'
                        OR UPPER(LAST_NAME_KANA || FIRST_NAME_KANA) LIKE '%' || UPPER(p_keyword) || '%'
                        OR UPPER(EMAIL) LIKE '%' || UPPER(p_keyword) || '%')
              )
             WHERE RN > v_offset
               AND RN <= v_offset + p_page_size;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20250, '顧客一覧取得中にエラーが発生しました: ' || SQLERRM);
    END GET_ALL_CUSTOMERS;

END PKG_CUSTOMER;
/
