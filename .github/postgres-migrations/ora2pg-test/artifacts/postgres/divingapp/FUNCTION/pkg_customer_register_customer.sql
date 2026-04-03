-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:03.757513

CREATE OR REPLACE FUNCTION divingapp.pkg_customer_register_customer(
    p_email VARCHAR,
    p_password VARCHAR,
    p_last_name VARCHAR,
    p_first_name VARCHAR,
    p_last_name_kana VARCHAR DEFAULT NULL,
    p_first_name_kana VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL,
    p_birth_date TIMESTAMP DEFAULT NULL,
    p_license_level VARCHAR DEFAULT NULL
)
RETURNS TABLE(
    o_customer_id BIGINT,
    o_result_code BIGINT,
    o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_email_count BIGINT;
    v_password_hash BYTEA;
BEGIN
    -- 必須項目バリデーション
    IF p_email IS NULL OR length(btrim(p_email)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'メールアドレスは必須です。';
    END IF;
    IF p_password IS NULL OR length(p_password) < 8 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'パスワードは8文字以上で入力してください。';
    END IF;
    IF p_last_name IS NULL OR length(btrim(p_last_name)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '姓は必須です。';
    END IF;
    IF p_first_name IS NULL OR length(btrim(p_first_name)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '名は必須です。';
    END IF;

    -- メールアドレス重複チェック
    SELECT count(*) INTO v_email_count
      FROM divingapp.customers c
     WHERE c.email = p_email;

    IF v_email_count > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'このメールアドレスは既に登録されています。';
    END IF;

    -- パスワードハッシュ生成（SHA-256）
    v_password_hash := digest(convert_to(p_password, 'UTF8'), 'sha256');

    -- 顧客レコード登録
    SELECT nextval('divingapp.seq_customers') INTO o_customer_id;

    INSERT INTO divingapp.customers (
        customer_id, email, password_hash,
        last_name, first_name,
        last_name_kana, first_name_kana,
        phone, birth_date, license_level,
        dive_count, status,
        created_at, updated_at
    ) VALUES (
        o_customer_id, p_email, v_password_hash,
        p_last_name, p_first_name,
        p_last_name_kana, p_first_name_kana,
        p_phone, p_birth_date, p_license_level,
        0, 'ACTIVE',
        CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    o_result_code := 0;
    o_result_msg  := '顧客登録が完了しました。顧客ID=' || o_customer_id;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客登録中にエラーが発生しました: ' || SQLERRM;
END;
$$;