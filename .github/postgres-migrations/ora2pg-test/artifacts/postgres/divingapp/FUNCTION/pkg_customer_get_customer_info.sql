-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:03.760030

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