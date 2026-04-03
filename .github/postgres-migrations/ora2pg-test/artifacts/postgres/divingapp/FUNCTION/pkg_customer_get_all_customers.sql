-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_CUSTOMER.sql
-- Generated at: 2026-04-03T15:26:03.762040

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