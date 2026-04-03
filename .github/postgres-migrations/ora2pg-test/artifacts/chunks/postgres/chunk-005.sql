-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/RESERVATIONS.sql
CREATE TABLE IF NOT EXISTS divingapp.reservations (
    reservation_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    schedule_id BIGINT NOT NULL,
    num_participants BIGINT NOT NULL,
    total_price BIGINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CONFIRMED',
    cancel_reason VARCHAR(500),
    refund_amount BIGINT DEFAULT 0,
    notes VARCHAR(1000),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_res_status CHECK (status IN ('CONFIRMED', 'CANCELLED', 'COMPLETED', 'NO_SHOW')),
    CONSTRAINT pk_reservations PRIMARY KEY (reservation_id),
    CONSTRAINT fk_res_customer FOREIGN KEY (customer_id)
        REFERENCES divingapp.customers (customer_id),
    CONSTRAINT fk_res_schedule FOREIGN KEY (schedule_id)
        REFERENCES divingapp.tour_schedules (schedule_id)
);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TS_TOUR_DATE.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_date ON divingapp.tour_schedules (tour_date);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TS_TOUR_ID.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_id ON divingapp.tour_schedules (tour_id);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_sites(
    p_area VARCHAR DEFAULT NULL,
    p_difficulty VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    site_id BIGINT,
    site_name VARCHAR,
    area VARCHAR,
    description VARCHAR,
    max_depth BIGINT,
    water_temperature_min BIGINT,
    water_temperature_max BIGINT,
    difficulty VARCHAR,
    marine_life VARCHAR,
    access_info VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT ds.site_id,
           ds.site_name,
           ds.area,
           ds.description,
           ds.max_depth,
           ds.water_temperature_min,
           ds.water_temperature_max,
           ds.difficulty,
           ds.marine_life,
           ds.access_info,
           ds.created_at,
           ds.updated_at
      FROM divingapp.dive_sites ds
     WHERE ds.status = 'ACTIVE'
       AND (p_area IS NULL OR ds.area = p_area)
       AND (p_difficulty IS NULL OR ds.difficulty = p_difficulty)
     ORDER BY ds.area, ds.site_name;
END;
$$;

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_site_detail_site(
    p_site_id BIGINT
)
RETURNS TABLE (
    site_id BIGINT,
    site_name VARCHAR,
    area VARCHAR,
    description VARCHAR,
    max_depth BIGINT,
    water_temperature_min BIGINT,
    water_temperature_max BIGINT,
    difficulty VARCHAR,
    marine_life VARCHAR,
    access_info VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM divingapp.dive_sites ds
     WHERE ds.site_id = p_site_id
       AND ds.status = 'ACTIVE';

    IF v_count = 0 THEN
        RAISE EXCEPTION '指定されたダイブサイトが見つかりません。SITE_ID=%', p_site_id
            USING ERRCODE = 'P0001';
    END IF;

    RETURN QUERY
    SELECT ds.site_id,
           ds.site_name,
           ds.area,
           ds.description,
           ds.max_depth,
           ds.water_temperature_min,
           ds.water_temperature_max,
           ds.difficulty,
           ds.marine_life,
           ds.access_info,
           ds.created_at,
           ds.updated_at
      FROM divingapp.dive_sites ds
     WHERE ds.site_id = p_site_id;
END;
$$;

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_DIVE_SITE.sql
CREATE OR REPLACE FUNCTION divingapp.get_dive_site_detail_related_tours(
    p_site_id BIGINT
)
RETURNS TABLE (
    tour_id BIGINT,
    tour_name VARCHAR,
    area VARCHAR,
    difficulty VARCHAR,
    base_price BIGINT,
    duration_days BIGINT,
    min_dive_count BIGINT,
    featured_flag VARCHAR,
    dive_order BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.tour_id,
           t.tour_name,
           t.area,
           t.difficulty,
           t.base_price,
           t.duration_days,
           t.min_dive_count,
           t.featured_flag,
           tds.dive_order
      FROM divingapp.tour_dive_sites tds
      JOIN divingapp.tours t
        ON tds.tour_id = t.tour_id
     WHERE tds.site_id = p_site_id
       AND t.status = 'ACTIVE'
     ORDER BY t.tour_name;
END;
$$;