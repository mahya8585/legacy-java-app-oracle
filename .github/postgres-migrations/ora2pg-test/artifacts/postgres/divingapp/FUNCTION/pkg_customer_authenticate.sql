-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:03.743461

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
CREATE OR REPLACE FUNCTION divingapp.pkg_customer_authenticate(
    p_email VARCHAR,
    p_password VARCHAR
)
RETURNS TABLE(
    o_customer_id BIGINT,
    o_result_code BIGINT,
    o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_stored_hash BYTEA;
    v_input_hash BYTEA;
    v_status VARCHAR(20);
BEGIN
    -- 入力バリデーション
    IF p_email IS NULL OR length(btrim(p_email)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'メールアドレスは必須です。';
    END IF;
    IF p_password IS NULL OR length(btrim(p_password)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'パスワードは必須です。';
    END IF;

    -- 顧客検索
    BEGIN
        SELECT c.customer_id, c.password_hash, c.status
          INTO o_customer_id, v_stored_hash, v_status
          FROM divingapp.customers c
         WHERE c.email = p_email;
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
    v_input_hash := digest(convert_to(p_password, 'UTF8'), 'sha256');

    IF v_stored_hash = v_input_hash THEN
        o_result_code := 0;
        o_result_msg  := '認証に成功しました。';
    ELSE
        o_customer_id := NULL;
        o_result_code := -1;
        o_result_msg  := 'メールアドレスまたはパスワードが正しくありません。';
    END IF;

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '認証処理中にエラーが発生しました: ' || SQLERRM;
END;
$$;