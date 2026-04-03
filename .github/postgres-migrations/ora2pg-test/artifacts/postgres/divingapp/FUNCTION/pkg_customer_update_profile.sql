-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:03.758522

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

    RETURN;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'プロフィール更新中にエラーが発生しました: ' || SQLERRM;
END;
$$;