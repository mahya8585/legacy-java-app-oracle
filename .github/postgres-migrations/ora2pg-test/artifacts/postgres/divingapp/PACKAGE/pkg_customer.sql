-- PostgreSQL DDL for divingapp.pkg_customer (PACKAGE)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: unknown_type
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:01.988621

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
          INTO STRICT o_customer_id, v_stored_hash, v_status
          FROM divingapp.customers c
         WHERE c.email = p_email;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            o_customer_id := NULL;
            o_result_code := -1;
            o_result_msg  := 'メールアドレスまたはパスワードが正しくありません。';
            RETURN NEXT;
            RETURN;
    END;

    -- アカウントステータスチェック
    IF v_status <> 'ACTIVE' THEN
        o_customer_id := NULL;
        o_result_code := -2;
        o_result_msg  := 'アカウントが無効です。管理者にお問い合わせください。';
        RETURN NEXT;
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

    RETURN NEXT;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '認証処理中にエラーが発生しました: ' || SQLERRM;
END;
$$;

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

    RETURN NEXT;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客登録中にエラーが発生しました: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE FUNCTION divingapp.pkg_customer_update_profile(
    p_customer_id BIGINT,
    p_last_name VARCHAR,
    p_first_name VARCHAR,
    p_last_name_kana VARCHAR,
    p_first_name_kana VARCHAR,
    p_phone VARCHAR,
    p_birth_date TIMESTAMP,
    p_license_level VARCHAR,
    p_emergency_contact VARCHAR
)
RETURNS TABLE(
    o_result_code BIGINT,
    o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    -- 顧客存在チェック
    SELECT count(*) INTO v_count
      FROM divingapp.customers c
     WHERE c.customer_id = p_customer_id
       AND c.status = 'ACTIVE';

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客が見つかりません。顧客ID=' || p_customer_id;
    END IF;

    -- バリデーション
    IF p_last_name IS NULL OR length(btrim(p_last_name)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '姓は必須です。';
    END IF;
    IF p_first_name IS NULL OR length(btrim(p_first_name)) = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '名は必須です。';
    END IF;

    -- プロフィール更新
    UPDATE divingapp.customers c
       SET last_name         = p_last_name,
           first_name        = p_first_name,
           last_name_kana    = p_last_name_kana,
           first_name_kana   = p_first_name_kana,
           phone             = p_phone,
           birth_date        = p_birth_date,
           license_level     = p_license_level,
           emergency_contact = p_emergency_contact,
           updated_at        = CURRENT_TIMESTAMP
     WHERE c.customer_id = p_customer_id;

    o_result_code := 0;
    o_result_msg  := 'プロフィールを更新しました。';

    RETURN NEXT;
    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'プロフィール更新中にエラーが発生しました: ' || SQLERRM;
END;
$$;

CREATE OR REPLACE FUNCTION divingapp.pkg_customer_get_customer_info(
    p_customer_id BIGINT
)
RETURNS TABLE(
    customer_id BIGINT,
    email VARCHAR,
    last_name VARCHAR,
    first_name VARCHAR,
    last_name_kana VARCHAR,
    first_name_kana VARCHAR,
    phone VARCHAR,
    birth_date TIMESTAMP,
    license_level VARCHAR,
    dive_count BIGINT,
    emergency_contact VARCHAR,
    status VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT count(*) INTO v_count
      FROM divingapp.customers c
     WHERE c.customer_id = p_customer_id;

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客が見つかりません。顧客ID=' || p_customer_id;
    END IF;

    RETURN QUERY
    SELECT c.customer_id,
           c.email,
           c.last_name,
           c.first_name,
           c.last_name_kana,
           c.first_name_kana,
           c.phone,
           c.birth_date,
           c.license_level,
           c.dive_count,
           c.emergency_contact,
           c.status,
           c.created_at,
           c.updated_at
      FROM divingapp.customers c
     WHERE c.customer_id = p_customer_id;
END;
$$;

CREATE OR REPLACE FUNCTION divingapp.pkg_customer_get_all_customers(
    p_keyword VARCHAR DEFAULT NULL,
    p_status VARCHAR DEFAULT NULL,
    p_page BIGINT DEFAULT 1,
    p_page_size BIGINT DEFAULT 20
)
RETURNS TABLE(
    customer_id BIGINT,
    email VARCHAR,
    last_name VARCHAR,
    first_name VARCHAR,
    last_name_kana VARCHAR,
    first_name_kana VARCHAR,
    phone VARCHAR,
    license_level VARCHAR,
    dive_count BIGINT,
    status VARCHAR,
    created_at TIMESTAMP,
    total_count BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset BIGINT;
    v_total_count BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- 総件数
    SELECT count(*)
      INTO v_total_count
      FROM divingapp.customers c
     WHERE (p_status IS NULL OR c.status = p_status)
       AND (
            p_keyword IS NULL
            OR upper(coalesce(c.last_name, '') || coalesce(c.first_name, '')) LIKE '%' || upper(p_keyword) || '%'
            OR upper(coalesce(c.last_name_kana, '') || coalesce(c.first_name_kana, '')) LIKE '%' || upper(p_keyword) || '%'
            OR upper(c.email) LIKE '%' || upper(p_keyword) || '%'
       );

    RETURN QUERY
    SELECT sub.customer_id,
           sub.email,
           sub.last_name,
           sub.first_name,
           sub.last_name_kana,
           sub.first_name_kana,
           sub.phone,
           sub.license_level,
           sub.dive_count,
           sub.status,
           sub.created_at,
           v_total_count AS total_count
      FROM (
            SELECT c.customer_id,
                   c.email,
                   c.last_name,
                   c.first_name,
                   c.last_name_kana,
                   c.first_name_kana,
                   c.phone,
                   c.license_level,
                   c.dive_count,
                   c.status,
                   c.created_at
              FROM divingapp.customers c
             WHERE (p_status IS NULL OR c.status = p_status)
               AND (
                    p_keyword IS NULL
                    OR upper(coalesce(c.last_name, '') || coalesce(c.first_name, '')) LIKE '%' || upper(p_keyword) || '%'
                    OR upper(coalesce(c.last_name_kana, '') || coalesce(c.first_name_kana, '')) LIKE '%' || upper(p_keyword) || '%'
                    OR upper(c.email) LIKE '%' || upper(p_keyword) || '%'
               )
             ORDER BY c.created_at DESC
             OFFSET v_offset
             LIMIT p_page_size
      ) sub;
END;
$$;