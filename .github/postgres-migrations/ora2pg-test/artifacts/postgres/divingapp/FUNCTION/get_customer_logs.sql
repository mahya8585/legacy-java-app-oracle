-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_DIVING_LOG.sql
-- Generated at: 2026-04-03T15:26:04.360393

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVING_LOG.sql
CREATE OR REPLACE FUNCTION divingapp.get_customer_logs(
    p_customer_id BIGINT,
    p_page BIGINT DEFAULT 1,
    p_page_size BIGINT DEFAULT 20
) RETURNS TABLE (
    log_id BIGINT,
    customer_id BIGINT,
    site_id BIGINT,
    site_name VARCHAR,
    site_area VARCHAR,
    reservation_id BIGINT,
    dive_date TIMESTAMP,
    max_depth NUMERIC,
    dive_time NUMERIC,
    water_temp NUMERIC,
    visibility NUMERIC,
    weather VARCHAR,
    buddy VARCHAR,
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    total_count BIGINT
) AS $$
DECLARE
    v_page BIGINT := COALESCE(p_page, 1);
    v_page_size BIGINT := COALESCE(p_page_size, 20);
    v_offset BIGINT;
    v_total_count BIGINT;
BEGIN
    -- 入力バリデーション
    IF p_customer_id IS NULL THEN
        RAISE EXCEPTION '顧客IDは必須です' USING ERRCODE = 'P2040';
    END IF;

    IF v_page < 1 THEN
        v_page := 1;
    END IF;
    IF v_page_size < 1 OR v_page_size > 100 THEN
        v_page_size := 20;
    END IF;

    v_offset := (v_page - 1) * v_page_size;

    -- 総件数取得
    SELECT COUNT(*)
      INTO v_total_count
      FROM divingapp.diving_logs dl
     WHERE dl.customer_id = p_customer_id;

    RETURN QUERY
    SELECT dl.log_id,
           dl.customer_id,
           dl.site_id,
           ds.site_name,
           ds.area AS site_area,
           dl.reservation_id,
           dl.dive_date,
           dl.max_depth,
           dl.dive_time,
           dl.water_temp,
           dl.visibility,
           dl.weather,
           dl.buddy,
           dl.notes,
           dl.created_at,
           dl.updated_at,
           v_total_count AS total_count
      FROM divingapp.diving_logs dl
      LEFT JOIN divingapp.dive_sites ds
        ON ds.site_id = dl.site_id
     WHERE dl.customer_id = p_customer_id
     ORDER BY dl.dive_date DESC, dl.log_id DESC
     OFFSET v_offset LIMIT v_page_size;
END;
$$ LANGUAGE plpgsql;