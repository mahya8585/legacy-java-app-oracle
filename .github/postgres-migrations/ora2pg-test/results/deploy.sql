-- Oracle → PostgreSQL Migration Deployment Script
-- Generated: 2026-04-03T15:26:09.560834
-- Migration Project: ora2pg-test
-- Total Objects: 57
-- PostgreSQL Version: 15+
--
-- This script contains the complete migrated schema in dependency order.
-- Execute this script against your target PostgreSQL database.
--
-- IMPORTANT: 
-- - Review this script before execution
-- - Ensure target database has appropriate permissions
-- - Consider running in a transaction for safety
--
-- BEGIN MIGRATION DEPLOYMENT
-- ==========================================

BEGIN;

-- Migration deployment started
DO $$
BEGIN
    RAISE NOTICE 'Starting Oracle → PostgreSQL migration deployment at %', NOW();
END $$;

-- divingapp.divingapp (SCHEMA)
-- Source: artifacts\postgres\divingapp\SCHEMA\divingapp.sql
CREATE SCHEMA IF NOT EXISTS divingapp;

-- schema.divingapp (SCHEMA)
-- Source: artifacts\postgres\schema\SCHEMA\divingapp.sql
CREATE SCHEMA IF NOT EXISTS divingapp;

-- divingapp.seq_admin_users (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_admin_users.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_admin_users
    INCREMENT BY 1
    START WITH 2
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_customers (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_customers.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_customers
    INCREMENT BY 1
    MINVALUE 1
    START WITH 11
    NO CYCLE;

-- divingapp.seq_dive_sites (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_dive_sites.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_dive_sites
    INCREMENT BY 1
    MINVALUE 1
    START WITH 31
    NO CYCLE;

-- divingapp.seq_diving_logs (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_diving_logs.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_diving_logs
    INCREMENT BY 1
    MINVALUE 1
    START WITH 1
    NO CYCLE;

-- divingapp.seq_instructors (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_instructors.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_instructors
    INCREMENT BY 1
    START WITH 11
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_news (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_news.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_news
    INCREMENT BY 1
    START WITH 11
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_options_master (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_options_master.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_options_master
    INCREMENT BY 1
    START WITH 10
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_report_alerts (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_report_alerts.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_report_alerts
    INCREMENT BY 1
    MINVALUE 1
    START WITH 1
    NO CYCLE;

-- divingapp.seq_report_cache (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_report_cache.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_report_cache
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_reservation_options (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_reservation_options.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_reservation_options
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_reservations (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_reservations.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_reservations
    INCREMENT BY 1
    MINVALUE 1
    START WITH 1
    NO CYCLE;

-- divingapp.seq_tour_schedules (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_tour_schedules.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_tour_schedules
    INCREMENT BY 1
    START WITH 52
    MINVALUE 1
    NO CYCLE;

-- divingapp.seq_tours (SEQUENCE)
-- Source: artifacts\postgres\divingapp\SEQUENCE\seq_tours.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_tours
    INCREMENT BY 1
    MINVALUE 1
    START WITH 21
    NO CYCLE;

-- divingapp.admin_users (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\admin_users.sql
CREATE TABLE IF NOT EXISTS divingapp.admin_users (
    admin_id BIGINT NOT NULL,
    username VARCHAR(100) NOT NULL,
    password_hash BYTEA NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'ADMIN',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    last_login_at TIMESTAMP(6),
    created_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_admin_users PRIMARY KEY (admin_id),
    CONSTRAINT uk_admin_users_username UNIQUE (username)
);

-- divingapp.customers (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\customers.sql
CREATE TABLE IF NOT EXISTS divingapp.customers (
    customer_id BIGINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    password_hash BYTEA NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name_kana VARCHAR(100),
    first_name_kana VARCHAR(100),
    phone VARCHAR(20),
    birth_date TIMESTAMP,
    license_level VARCHAR(100),
    dive_count BIGINT DEFAULT 0,
    emergency_contact VARCHAR(200),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uk_customers_email UNIQUE (email)
);

-- divingapp.dive_sites (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\dive_sites.sql
CREATE TABLE IF NOT EXISTS divingapp.dive_sites (
    site_id BIGINT NOT NULL,
    site_name VARCHAR(200) NOT NULL,
    area VARCHAR(100) NOT NULL,
    description TEXT,
    max_depth NUMERIC(5,1),
    water_temperature_min NUMERIC(4,1),
    water_temperature_max NUMERIC(4,1),
    difficulty VARCHAR(20),
    marine_life VARCHAR(1000),
    access_info VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_ds_difficulty CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    CONSTRAINT pk_dive_sites PRIMARY KEY (site_id)
);

-- divingapp.tours (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\tours.sql
CREATE TABLE IF NOT EXISTS divingapp.tours (
    tour_id BIGINT NOT NULL,
    tour_name VARCHAR(200) NOT NULL,
    description TEXT,
    area VARCHAR(100) NOT NULL,
    difficulty VARCHAR(20) NOT NULL,
    max_participants BIGINT NOT NULL,
    base_price BIGINT NOT NULL,
    duration_days BIGINT DEFAULT 1 NOT NULL,
    min_dive_count BIGINT DEFAULT 0,
    featured_flag CHAR(1) DEFAULT 'N' NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_tours_difficulty CHECK (difficulty IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT')),
    CONSTRAINT ck_tours_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'DELETED')),
    CONSTRAINT ck_tours_featured CHECK (featured_flag IN ('Y', 'N')),
    CONSTRAINT pk_tours PRIMARY KEY (tour_id)
);

-- divingapp.tour_schedules (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\tour_schedules.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_schedules (
    schedule_id BIGINT NOT NULL,
    tour_id BIGINT NOT NULL,
    tour_date TIMESTAMP NOT NULL,
    start_time VARCHAR(5),
    remaining_seats BIGINT NOT NULL,
    status VARCHAR(20) DEFAULT 'OPEN' NOT NULL,
    version BIGINT DEFAULT 0 NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_ts_status CHECK (status IN ('OPEN', 'FULL', 'CLOSED', 'CANCELLED')),
    CONSTRAINT pk_tour_schedules PRIMARY KEY (schedule_id),
    CONSTRAINT fk_ts_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id)
);

-- divingapp.reservations (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\reservations.sql
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

-- divingapp.diving_logs (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\diving_logs.sql
CREATE TABLE IF NOT EXISTS divingapp.diving_logs (
	log_id BIGINT NOT NULL,
	customer_id BIGINT NOT NULL,
	site_id BIGINT,
	reservation_id BIGINT,
	dive_date TIMESTAMP NOT NULL,
	max_depth NUMERIC(5,1),
	dive_time BIGINT,
	water_temp NUMERIC(4,1),
	visibility NUMERIC(4,1),
	weather VARCHAR(50),
	buddy VARCHAR(100),
	notes TEXT,
	created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
	CONSTRAINT pk_diving_logs PRIMARY KEY (log_id),
	CONSTRAINT fk_dl_customer FOREIGN KEY (customer_id) REFERENCES divingapp.customers (customer_id),
	CONSTRAINT fk_dl_site FOREIGN KEY (site_id) REFERENCES divingapp.dive_sites (site_id),
	CONSTRAINT fk_dl_reservation FOREIGN KEY (reservation_id) REFERENCES divingapp.reservations (reservation_id)
);

-- divingapp.instructors (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\instructors.sql
CREATE TABLE IF NOT EXISTS divingapp.instructors (
    instructor_id BIGINT NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    certification VARCHAR(200),
    experience_years BIGINT,
    specialty VARCHAR(200),
    profile TEXT,
    photo_url VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_instructors PRIMARY KEY (instructor_id)
);

-- divingapp.news (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\news.sql
CREATE TABLE IF NOT EXISTS divingapp.news (
    news_id BIGINT NOT NULL,
    title VARCHAR(300) NOT NULL,
    content TEXT NOT NULL,
    category VARCHAR(50),
    publish_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'PUBLISHED' NOT NULL,
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_news_status CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    CONSTRAINT pk_news PRIMARY KEY (news_id)
);

-- divingapp.options_master (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\options_master.sql
CREATE TABLE IF NOT EXISTS divingapp.options_master (
    option_id BIGINT NOT NULL,
    option_name VARCHAR(200) NOT NULL,
    option_category VARCHAR(50) NOT NULL,
    unit_price BIGINT NOT NULL,
    description VARCHAR(500),
    status VARCHAR(20) DEFAULT 'ACTIVE' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT ck_om_category CHECK (option_category IN ('RENTAL', 'TRANSPORT', 'PHOTO', 'INSURANCE', 'OTHER')),
    CONSTRAINT pk_options_master PRIMARY KEY (option_id)
);

-- divingapp.report_alerts (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\report_alerts.sql
CREATE TABLE IF NOT EXISTS divingapp.report_alerts (
    alert_id BIGINT NOT NULL,
    alert_type VARCHAR(50) NOT NULL,
    severity VARCHAR(10) NOT NULL,
    metric_name VARCHAR(100) NOT NULL,
    current_value NUMERIC(15,2),
    threshold_value NUMERIC(15,2),
    deviation NUMERIC(10,4),
    message VARCHAR(500),
    detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'NEW' NOT NULL,
    CONSTRAINT ck_ra_severity CHECK (severity IN ('HIGH', 'MEDIUM', 'LOW')),
    CONSTRAINT ck_ra_status CHECK (status IN ('NEW', 'ACKNOWLEDGED', 'RESOLVED')),
    CONSTRAINT pk_report_alerts PRIMARY KEY (alert_id)
);

-- divingapp.report_cache (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\report_cache.sql
CREATE TABLE IF NOT EXISTS divingapp.report_cache (
    cache_id BIGINT NOT NULL,
    report_key VARCHAR(100) NOT NULL,
    section VARCHAR(50) NOT NULL,
    report_date TIMESTAMP,
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC(15,2),
    dimension1 VARCHAR(200),
    dimension2 VARCHAR(200),
    dimension3 VARCHAR(200),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_report_cache PRIMARY KEY (cache_id)
);

-- divingapp.reservation_options (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\reservation_options.sql
CREATE TABLE IF NOT EXISTS divingapp.reservation_options (
	res_option_id BIGINT NOT NULL,
	reservation_id BIGINT NOT NULL,
	option_id BIGINT NOT NULL,
	quantity BIGINT DEFAULT 1 NOT NULL,
	subtotal BIGINT NOT NULL,
	CONSTRAINT pk_reservation_options PRIMARY KEY (res_option_id),
	CONSTRAINT fk_ro_reservation FOREIGN KEY (reservation_id) REFERENCES divingapp.reservations (reservation_id),
	CONSTRAINT fk_ro_option FOREIGN KEY (option_id) REFERENCES divingapp.options_master (option_id)
);

-- divingapp.tour_dive_sites (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\tour_dive_sites.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_dive_sites (
    tour_id BIGINT NOT NULL,
    site_id BIGINT NOT NULL,
    dive_order BIGINT DEFAULT 1,
    CONSTRAINT pk_tour_dive_sites PRIMARY KEY (tour_id, site_id),
    CONSTRAINT fk_tds_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id),
    CONSTRAINT fk_tds_site FOREIGN KEY (site_id)
        REFERENCES divingapp.dive_sites (site_id)
);

-- divingapp.tour_instructors (TABLE)
-- Source: artifacts\postgres\divingapp\TABLE\tour_instructors.sql
CREATE TABLE IF NOT EXISTS divingapp.tour_instructors (
    tour_id BIGINT NOT NULL,
    instructor_id BIGINT NOT NULL,
    role VARCHAR(50) DEFAULT 'GUIDE',
    CONSTRAINT pk_tour_instructors PRIMARY KEY (tour_id, instructor_id),
    CONSTRAINT fk_ti_tour FOREIGN KEY (tour_id)
        REFERENCES divingapp.tours (tour_id),
    CONSTRAINT fk_ti_instructor FOREIGN KEY (instructor_id)
        REFERENCES divingapp.instructors (instructor_id)
);

-- divingapp.idx_customers_status (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_customers_status.sql
CREATE INDEX IF NOT EXISTS idx_customers_status ON divingapp.customers (status);

-- divingapp.idx_dl_customer (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_dl_customer.sql
CREATE INDEX IF NOT EXISTS idx_dl_customer ON divingapp.diving_logs (customer_id);

-- divingapp.idx_dl_dive_date (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_dl_dive_date.sql
CREATE INDEX IF NOT EXISTS idx_dl_dive_date ON divingapp.diving_logs (dive_date);

-- divingapp.idx_ds_area (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ds_area.sql
CREATE INDEX IF NOT EXISTS idx_ds_area ON divingapp.dive_sites (area);

-- divingapp.idx_news_publish (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_news_publish.sql
CREATE INDEX IF NOT EXISTS idx_news_publish ON divingapp.news (publish_date, status);

-- divingapp.idx_ra_detected (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ra_detected.sql
CREATE INDEX IF NOT EXISTS idx_ra_detected ON divingapp.report_alerts (detected_at, status);

-- divingapp.idx_ra_severity (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ra_severity.sql
CREATE INDEX IF NOT EXISTS idx_ra_severity ON divingapp.report_alerts (severity, status);

-- divingapp.idx_rc_generated (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_rc_generated.sql
CREATE INDEX IF NOT EXISTS idx_rc_generated ON divingapp.report_cache (generated_at);

-- divingapp.idx_rc_key_section (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_rc_key_section.sql
CREATE INDEX IF NOT EXISTS idx_rc_key_section ON divingapp.report_cache (report_key, section);

-- divingapp.idx_reservations_customer (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_reservations_customer.sql
CREATE INDEX IF NOT EXISTS idx_reservations_customer ON divingapp.reservations (customer_id);

-- divingapp.idx_reservations_schedule (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_reservations_schedule.sql
CREATE INDEX IF NOT EXISTS idx_reservations_schedule ON divingapp.reservations (schedule_id);

-- divingapp.idx_reservations_status (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_reservations_status.sql
CREATE INDEX IF NOT EXISTS idx_reservations_status ON divingapp.reservations (status);

-- divingapp.idx_ro_reservation (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ro_reservation.sql
CREATE INDEX IF NOT EXISTS idx_ro_reservation ON divingapp.reservation_options (reservation_id);

-- divingapp.idx_tours_area (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_tours_area.sql
CREATE INDEX IF NOT EXISTS idx_tours_area ON divingapp.tours (area);

-- divingapp.idx_tours_difficulty (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_tours_difficulty.sql
CREATE INDEX IF NOT EXISTS idx_tours_difficulty ON divingapp.tours (difficulty);

-- divingapp.idx_tours_featured (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_tours_featured.sql
CREATE INDEX IF NOT EXISTS idx_tours_featured ON divingapp.tours (featured_flag);

-- divingapp.idx_tours_status (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_tours_status.sql
CREATE INDEX IF NOT EXISTS idx_tours_status ON divingapp.tours (status);

-- divingapp.idx_ts_status (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ts_status.sql
CREATE INDEX IF NOT EXISTS idx_ts_status ON divingapp.tour_schedules (status);

-- divingapp.idx_ts_tour_date (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ts_tour_date.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_date ON divingapp.tour_schedules (tour_date);

-- divingapp.idx_ts_tour_id (INDEX)
-- Source: artifacts\postgres\divingapp\INDEX\idx_ts_tour_id.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_id ON divingapp.tour_schedules (tour_id);

-- index.idx_customers_status (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_customers_status.sql
CREATE INDEX IF NOT EXISTS idx_customers_status ON divingapp.customers (status);

-- index.idx_dl_customer (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_dl_customer.sql
CREATE INDEX IF NOT EXISTS idx_dl_customer ON divingapp.diving_logs (customer_id);

-- index.idx_dl_dive_date (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_dl_dive_date.sql
CREATE INDEX IF NOT EXISTS idx_dl_dive_date ON divingapp.diving_logs (dive_date);

-- index.idx_ds_area (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ds_area.sql
CREATE INDEX IF NOT EXISTS idx_ds_area ON divingapp.dive_sites (area);

-- index.idx_news_publish (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_news_publish.sql
CREATE INDEX IF NOT EXISTS idx_news_publish ON divingapp.news (publish_date, status);

-- index.idx_ra_detected (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ra_detected.sql
CREATE INDEX IF NOT EXISTS idx_ra_detected ON divingapp.report_alerts (detected_at, status);

-- index.idx_ra_severity (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ra_severity.sql
CREATE INDEX IF NOT EXISTS idx_ra_severity ON divingapp.report_alerts (severity, status);

-- index.idx_rc_generated (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_rc_generated.sql
CREATE INDEX IF NOT EXISTS idx_rc_generated ON divingapp.report_cache (generated_at);

-- index.idx_rc_key_section (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_rc_key_section.sql
CREATE INDEX IF NOT EXISTS idx_rc_key_section ON divingapp.report_cache (report_key, section);

-- index.idx_reservations_customer (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_reservations_customer.sql
CREATE INDEX IF NOT EXISTS idx_reservations_customer ON divingapp.reservations (customer_id);

-- index.idx_reservations_schedule (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_reservations_schedule.sql
CREATE INDEX IF NOT EXISTS idx_reservations_schedule ON divingapp.reservations (schedule_id);

-- index.idx_reservations_status (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_reservations_status.sql
CREATE INDEX IF NOT EXISTS idx_reservations_status ON divingapp.reservations (status);

-- index.idx_ro_reservation (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ro_reservation.sql
CREATE INDEX IF NOT EXISTS idx_ro_reservation ON divingapp.reservation_options (reservation_id);

-- index.idx_tours_area (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_tours_area.sql
CREATE INDEX IF NOT EXISTS idx_tours_area ON divingapp.tours (area);

-- index.idx_tours_difficulty (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_tours_difficulty.sql
CREATE INDEX IF NOT EXISTS idx_tours_difficulty ON divingapp.tours (difficulty);

-- index.idx_tours_featured (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_tours_featured.sql
CREATE INDEX IF NOT EXISTS idx_tours_featured ON divingapp.tours (featured_flag);

-- index.idx_tours_status (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_tours_status.sql
CREATE INDEX IF NOT EXISTS idx_tours_status ON divingapp.tours (status);

-- index.idx_ts_status (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ts_status.sql
CREATE INDEX IF NOT EXISTS idx_ts_status ON divingapp.tour_schedules (status);

-- index.idx_ts_tour_date (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ts_tour_date.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_date ON divingapp.tour_schedules (tour_date);

-- index.idx_ts_tour_id (INDEX)
-- Source: artifacts\postgres\index\INDEX\idx_ts_tour_id.sql
CREATE INDEX IF NOT EXISTS idx_ts_tour_id ON divingapp.tour_schedules (tour_id);

-- divingapp.calc_total_price (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\calc_total_price.sql
CREATE OR REPLACE FUNCTION divingapp.calc_total_price(
    p_schedule_id BIGINT,
    p_num_participants BIGINT,
    p_option_ids VARCHAR DEFAULT NULL,
    p_option_quantities VARCHAR DEFAULT NULL
) RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_base_price NUMERIC;
    v_total NUMERIC := 0;
    v_opt_id BIGINT;
    v_opt_qty BIGINT;
    v_unit_price NUMERIC;
    v_opt_count BIGINT := 0;
    v_qty_count BIGINT := 0;
BEGIN
    SELECT t.base_price
      INTO v_base_price
      FROM divingapp.tour_schedules ts
      JOIN divingapp.tours t ON ts.tour_id = t.tour_id
     WHERE ts.schedule_id = p_schedule_id;

    v_total := v_base_price * p_num_participants;

    IF p_option_ids IS NOT NULL AND length(btrim(p_option_ids)) > 0 THEN
        v_opt_count := array_length(regexp_split_to_array(p_option_ids, '\\s*,\\s*'), 1);
        v_qty_count := array_length(regexp_split_to_array(COALESCE(p_option_quantities, '1'), '\\s*,\\s*'), 1);

        FOR i IN 1..v_opt_count LOOP
            v_opt_id := NULLIF(btrim((regexp_split_to_array(p_option_ids, '\\s*,\\s*'))[i]), '')::BIGINT;

            IF i <= v_qty_count AND p_option_quantities IS NOT NULL THEN
                v_opt_qty := NULLIF(btrim((regexp_split_to_array(p_option_quantities, '\\s*,\\s*'))[i]), '')::BIGINT;
            ELSE
                v_opt_qty := 1;
            END IF;

            IF v_opt_qty IS NULL OR v_opt_qty <= 0 THEN
                v_opt_qty := 1;
            END IF;

            SELECT unit_price
              INTO v_unit_price
              FROM divingapp.options_master
             WHERE option_id = v_opt_id
               AND status = 'ACTIVE';

            v_total := v_total + (v_unit_price * v_opt_qty);
        END LOOP;
    END IF;

    RETURN v_total;
EXCEPTION
    WHEN no_data_found THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定されたスケジュールが見つかりません。SCHEDULE_ID=' || p_schedule_id;
    WHEN others THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '料金計算中にエラーが発生しました: ' || SQLERRM;
END;
$$;

-- divingapp.get_customer_logs (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_customer_logs.sql
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

-- divingapp.get_dive_site_detail_related_tours (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_dive_site_detail_related_tours.sql
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

-- divingapp.get_dive_site_detail_site (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_dive_site_detail_site.sql
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

-- divingapp.get_dive_sites (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_dive_sites.sql
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

-- divingapp.get_instructor_detail (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_instructor_detail.sql
CREATE OR REPLACE FUNCTION divingapp.get_instructor_detail(
	p_instructor_id BIGINT,
	OUT o_instructor refcursor,
	OUT o_tours refcursor
)
RETURNS record
LANGUAGE plpgsql
AS $$
BEGIN
	OPEN o_instructor FOR
		SELECT instructor_id,
			   last_name,
			   first_name,
			   certification,
			   experience_years,
			   specialty,
			   profile,
			   photo_url,
			   status,
			   created_at,
			   updated_at
		  FROM divingapp.instructors
		 WHERE instructor_id = p_instructor_id;

	OPEN o_tours FOR
		SELECT DISTINCT
			   t.tour_id,
			   t.tour_name,
			   t.area,
			   t.difficulty,
			   t.max_participants,
			   t.base_price,
			   t.duration_days,
			   ti.role
		  FROM divingapp.tour_instructors ti
		  JOIN divingapp.tours t
			ON t.tour_id = ti.tour_id
		 WHERE ti.instructor_id = p_instructor_id
		   AND t.status = 'ACTIVE'
		   AND EXISTS (
			   SELECT 1
				 FROM divingapp.tour_schedules ts
				WHERE ts.tour_id = t.tour_id
				  AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
				  AND ts.status IN ('OPEN', 'FULL')
		   )
		 ORDER BY t.tour_name;
END;
$$;

-- divingapp.get_instructors (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\get_instructors.sql
CREATE OR REPLACE FUNCTION divingapp.get_instructors()
RETURNS refcursor
LANGUAGE plpgsql
AS $$
DECLARE
	o_instructors refcursor;
BEGIN
	OPEN o_instructors FOR
		SELECT instructor_id,
			   last_name,
			   first_name,
			   certification,
			   experience_years,
			   specialty,
			   profile,
			   photo_url,
			   status,
			   created_at,
			   updated_at
		  FROM divingapp.instructors
		 WHERE status = 'ACTIVE'
		 ORDER BY experience_years DESC;

	RETURN o_instructors;
END;
$$;

-- divingapp.pkg_customer_authenticate (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_customer_authenticate.sql
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

-- divingapp.pkg_customer_get_all_customers (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_customer_get_all_customers.sql
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

-- divingapp.pkg_customer_get_customer_info (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_customer_get_customer_info.sql
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

-- divingapp.pkg_customer_register_customer (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_customer_register_customer.sql
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

-- divingapp.pkg_customer_update_profile (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_customer_update_profile.sql
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

-- divingapp.pkg_news_get_latest_news (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_news_get_latest_news.sql
CREATE OR REPLACE FUNCTION divingapp.pkg_news_get_latest_news(
    p_limit BIGINT DEFAULT 5,
    p_category VARCHAR DEFAULT NULL
)
RETURNS SETOF divingapp.news
LANGUAGE plpgsql
AS $$
BEGIN
    IF COALESCE(p_limit, 5) < 1 THEN
        p_limit := 5;
    END IF;

    RETURN QUERY
    SELECT n.*
    FROM divingapp.news n
    WHERE n.status = 'PUBLISHED'
      AND n.publish_date <= date_trunc('day', CURRENT_TIMESTAMP)
      AND (p_category IS NULL OR n.category = p_category)
    ORDER BY n.publish_date DESC, n.news_id DESC
    LIMIT p_limit;
END;
$$;

-- divingapp.pkg_news_save_news (FUNCTION)
-- Source: artifacts\postgres\divingapp\FUNCTION\pkg_news_save_news.sql
CREATE OR REPLACE FUNCTION divingapp.pkg_news_save_news(
    p_news_id_in BIGINT,
    p_title VARCHAR,
    p_content TEXT,
    p_category VARCHAR,
    p_publish_date TIMESTAMP,
    p_status VARCHAR
)
RETURNS TABLE (p_news_id BIGINT, o_result_code BIGINT, o_result_msg VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    p_news_id := p_news_id_in;

    -- タイトル必須チェック
    IF p_title IS NULL OR length(btrim(p_title)) = 0 THEN
        o_result_code := -20601;
        o_result_msg  := 'タイトルは必須です';
        RETURN;
    END IF;

    -- コンテンツ必須チェック
    IF p_content IS NULL THEN
        o_result_code := -20602;
        o_result_msg  := '本文は必須です';
        RETURN;
    END IF;

    IF p_news_id IS NULL THEN
        -- ============================
        -- 新規登録
        -- ============================
        p_news_id := nextval('divingapp.seq_news');

        INSERT INTO divingapp.news (
            news_id,
            title,
            content,
            category,
            publish_date,
            status,
            created_at,
            updated_at
        ) VALUES (
            p_news_id,
            btrim(p_title),
            p_content,
            p_category,
            COALESCE(p_publish_date, date_trunc('day', CURRENT_TIMESTAMP)),
            COALESCE(p_status, 'DRAFT'),
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

        o_result_code := 0;
        o_result_msg  := 'ニュースを登録しました';
        RETURN;
    ELSE
        -- ============================
        -- 更新（存在チェック付き）
        -- ============================
        SELECT COUNT(*)
        INTO v_count
        FROM divingapp.news n
        WHERE n.news_id = p_news_id;

        IF v_count = 0 THEN
            o_result_code := -20603;
            o_result_msg  := '指定されたニュースが見つかりません (NEWS_ID=' || p_news_id || ')';
            RETURN;
        END IF;

        UPDATE divingapp.news n
        SET title        = btrim(p_title),
            content      = p_content,
            category     = p_category,
            publish_date = COALESCE(p_publish_date, n.publish_date),
            status       = COALESCE(p_status, n.status),
            updated_at   = CURRENT_TIMESTAMP
        WHERE n.news_id = p_news_id;

        o_result_code := 0;
        o_result_msg  := 'ニュースを更新しました';
        RETURN;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        o_result_code := -20699;
        o_result_msg  := 'ニュース保存中にエラーが発生しました: ' || SQLERRM;
        RETURN;
END;
$$;

-- divingapp.cancel_reservation (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\cancel_reservation.sql
CREATE OR REPLACE PROCEDURE divingapp.cancel_reservation(
    IN p_reservation_id BIGINT,
    IN p_customer_id BIGINT,
    IN p_cancel_reason VARCHAR DEFAULT NULL,
    INOUT o_refund_amount NUMERIC DEFAULT NULL,
    INOUT o_result_code BIGINT DEFAULT NULL,
    INOUT o_result_msg VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_res_customer_id BIGINT;
    v_res_status VARCHAR(20);
    v_total_price NUMERIC;
    v_num_participants BIGINT;
    v_schedule_id BIGINT;
    v_tour_date TIMESTAMP;
    v_days_until BIGINT;
    v_refund_rate NUMERIC;
BEGIN
    SELECT r.customer_id, r.status, r.total_price,
           r.num_participants, r.schedule_id, ts.tour_date
      INTO v_res_customer_id, v_res_status, v_total_price,
           v_num_participants, v_schedule_id, v_tour_date
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE r.reservation_id = p_reservation_id;

    IF v_res_customer_id <> p_customer_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'この予約はご自身の予約ではありません。';
    END IF;

    IF v_res_status <> 'CONFIRMED' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'この予約はキャンセルできません。ステータス=' || v_res_status;
    END IF;

    v_days_until := date_trunc('day', v_tour_date)::date - current_date;

    IF v_days_until >= 30 THEN
        v_refund_rate := 1.00;
    ELSIF v_days_until >= 14 THEN
        v_refund_rate := 0.70;
    ELSIF v_days_until >= 7 THEN
        v_refund_rate := 0.50;
    ELSIF v_days_until >= 3 THEN
        v_refund_rate := 0.30;
    ELSE
        v_refund_rate := 0.00;
    END IF;

    o_refund_amount := trunc(v_total_price * v_refund_rate);

    UPDATE divingapp.reservations
       SET status        = 'CANCELLED',
           cancel_reason = p_cancel_reason,
           refund_amount = o_refund_amount,
           updated_at    = CURRENT_TIMESTAMP
     WHERE reservation_id = p_reservation_id;

    UPDATE divingapp.tour_schedules
       SET remaining_seats = remaining_seats + v_num_participants,
           status = CASE
                        WHEN status = 'FULL' THEN 'OPEN'
                        ELSE status
                    END,
           version    = version + 1,
           updated_at = CURRENT_TIMESTAMP
     WHERE schedule_id = v_schedule_id;

    COMMIT;

    o_result_code := 0;
    o_result_msg  := '予約をキャンセルしました。返金額=' || o_refund_amount
                     || '（返金率' || (v_refund_rate * 100) || '%、ツアー' || v_days_until || '日前）';

EXCEPTION
    WHEN others THEN
        ROLLBACK;
        RAISE;
END;
$$;

-- divingapp.create_reservation (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\create_reservation.sql
CREATE OR REPLACE PROCEDURE divingapp.create_reservation(
    IN p_customer_id BIGINT,
    IN p_schedule_id BIGINT,
    IN p_num_participants BIGINT,
    IN p_option_ids VARCHAR DEFAULT NULL,
    IN p_option_quantities VARCHAR DEFAULT NULL,
    IN p_notes VARCHAR DEFAULT NULL,
    INOUT o_reservation_id BIGINT DEFAULT NULL,
    INOUT o_total_price NUMERIC DEFAULT NULL,
    INOUT o_result_code BIGINT DEFAULT NULL,
    INOUT o_result_msg VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_schedule_status VARCHAR(20);
    v_remaining_seats BIGINT;
    v_version BIGINT;
    v_tour_id BIGINT;
    v_opt_id BIGINT;
    v_opt_qty BIGINT;
    v_unit_price NUMERIC;
    v_opt_count BIGINT := 0;
    v_qty_count BIGINT := 0;
    v_updated BIGINT;
BEGIN
    IF p_customer_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '顧客IDは必須です。';
    END IF;
    IF p_schedule_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'スケジュールIDは必須です。';
    END IF;
    IF p_num_participants IS NULL OR p_num_participants <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '参加人数は1名以上を指定してください。';
    END IF;

    SELECT ts.status, ts.remaining_seats, ts.version, ts.tour_id
      INTO v_schedule_status, v_remaining_seats, v_version, v_tour_id
      FROM divingapp.tour_schedules ts
     WHERE ts.schedule_id = p_schedule_id
     FOR UPDATE NOWAIT;

    IF v_schedule_status <> 'OPEN' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'このスケジュールは予約受付停止中です。ステータス=' || v_schedule_status;
    END IF;

    IF v_remaining_seats < p_num_participants THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '残席数が不足しています。残席=' || v_remaining_seats || ', 要求=' || p_num_participants;
    END IF;

    o_total_price := divingapp.calc_total_price(p_schedule_id, p_num_participants, p_option_ids, p_option_quantities);

    SELECT nextval('divingapp.seq_reservations') INTO o_reservation_id;

    INSERT INTO divingapp.reservations (
        reservation_id, customer_id, schedule_id,
        num_participants, total_price, status,
        notes, created_at, updated_at
    ) VALUES (
        o_reservation_id, p_customer_id, p_schedule_id,
        p_num_participants, o_total_price, 'CONFIRMED',
        p_notes, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
    );

    IF p_option_ids IS NOT NULL AND length(btrim(p_option_ids)) > 0 THEN
        v_opt_count := array_length(regexp_split_to_array(p_option_ids, '\\s*,\\s*'), 1);
        v_qty_count := array_length(regexp_split_to_array(COALESCE(p_option_quantities, '1'), '\\s*,\\s*'), 1);

        FOR i IN 1..v_opt_count LOOP
            v_opt_id := NULLIF(btrim((regexp_split_to_array(p_option_ids, '\\s*,\\s*'))[i]), '')::BIGINT;

            IF i <= v_qty_count AND p_option_quantities IS NOT NULL THEN
                v_opt_qty := NULLIF(btrim((regexp_split_to_array(p_option_quantities, '\\s*,\\s*'))[i]), '')::BIGINT;
            ELSE
                v_opt_qty := 1;
            END IF;

            IF v_opt_qty IS NULL OR v_opt_qty <= 0 THEN
                v_opt_qty := 1;
            END IF;

            SELECT unit_price INTO v_unit_price
              FROM divingapp.options_master
             WHERE option_id = v_opt_id
               AND status = 'ACTIVE';

            INSERT INTO divingapp.reservation_options (
                res_option_id, reservation_id, option_id,
                quantity, subtotal
            ) VALUES (
                nextval('divingapp.seq_reservation_options'), o_reservation_id, v_opt_id,
                v_opt_qty, v_unit_price * v_opt_qty
            );
        END LOOP;
    END IF;

    UPDATE divingapp.tour_schedules
       SET remaining_seats = remaining_seats - p_num_participants,
           status = CASE
                        WHEN remaining_seats - p_num_participants = 0 THEN 'FULL'
                        ELSE status
                    END,
           version    = version + 1,
           updated_at = CURRENT_TIMESTAMP
     WHERE schedule_id = p_schedule_id
       AND version = v_version;

    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '他のユーザーによって予約が更新されました。再度お試しください。';
    END IF;

    COMMIT;

    o_result_code := 0;
    o_result_msg  := '予約が完了しました。予約ID=' || o_reservation_id;

EXCEPTION
    WHEN lock_not_available THEN
        ROLLBACK;
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '他のユーザーによってスケジュールがロックされています。再度お試しください。';
    WHEN others THEN
        ROLLBACK;
        RAISE;
END;
$$;

-- divingapp.delete_tour (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\delete_tour.sql
CREATE OR REPLACE PROCEDURE divingapp.delete_tour(
    IN p_tour_id NUMERIC,
    OUT o_result_code NUMERIC,
    OUT o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
    v_future_res NUMERIC;
BEGIN
    -- ツアー存在チェック
    SELECT COUNT(*)
      INTO v_count
      FROM divingapp.tours
     WHERE tour_id = p_tour_id
       AND status <> 'DELETED';

    IF v_count = 0 THEN
        RAISE EXCEPTION '削除対象のツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
    END IF;

    -- 未来の確定済み予約があるかチェック
    SELECT COUNT(*)
      INTO v_future_res
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE ts.tour_id = p_tour_id
       AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
       AND r.status = 'CONFIRMED';

    IF v_future_res > 0 THEN
        RAISE EXCEPTION '確定済みの予約が%件存在するため削除できません。先に予約をキャンセルしてください。', v_future_res USING ERRCODE = 'P0001';
    END IF;

    -- 論理削除
    UPDATE divingapp.tours
       SET status     = 'DELETED',
           updated_at = CURRENT_TIMESTAMP
     WHERE tour_id = p_tour_id;

    o_result_code := 0;
    o_result_msg  := 'ツアーを削除しました。TOUR_ID=' || p_tour_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー削除中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;

-- divingapp.generate_dashboard_report (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\generate_dashboard_report.sql
CREATE OR REPLACE PROCEDURE divingapp.generate_dashboard_report(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_sales_trend refcursor DEFAULT NULL,
    INOUT o_area_matrix refcursor DEFAULT NULL,
    INOUT o_instructor_kpi refcursor DEFAULT NULL,
    INOUT o_customer_segment refcursor DEFAULT NULL,
    INOUT o_cancel_analysis refcursor DEFAULT NULL,
    INOUT o_anomaly_alerts refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_date_from     timestamp;
    v_date_to       timestamp;
    v_prev_year     numeric;
    v_report_key    varchar(100);
    v_alert_count   numeric := 0;
BEGIN
    -- -------------------------------------------------------
    -- 入力バリデーション
    -- -------------------------------------------------------
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    v_prev_year  := p_year - 1;
    v_report_key := 'DASHBOARD_' || to_char(p_year) || '_' || COALESCE(to_char(p_month), 'ALL');

    IF p_month IS NOT NULL THEN
        v_date_from := to_date(p_year::text || '-' || lpad(p_month::text, 2, '0') || '-01', 'YYYY-MM-DD');
        v_date_to   := (date_trunc('month', v_date_from) + interval '1 month - 1 day')::date;
    ELSE
        v_date_from := to_date(p_year::text || '-01-01', 'YYYY-MM-DD');
        v_date_to   := to_date(p_year::text || '-12-31', 'YYYY-MM-DD');
    END IF;

    -- =========================================================
    -- セクション1: 売上推移分析
    -- CONNECT BY でカレンダー生成 → LEFT JOIN でゼロ埋め
    -- LAG で前月比、サブクエリで前年同月比、RATIO_TO_REPORT で構成比
    -- SUM OVER ROWS UNBOUNDED PRECEDING で累計
    -- =========================================================
    OPEN o_sales_trend FOR
        WITH RECURSIVE calendar AS (
            SELECT 1 AS cal_month
            UNION ALL
            SELECT cal_month + 1
              FROM calendar
             WHERE cal_month < 12
        ),
        current_year_sales AS (
            SELECT EXTRACT(MONTH FROM ts.tour_date)                    AS sale_month,
                   COUNT(DISTINCT r.reservation_id)                   AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS revenue,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants ELSE 0 END
                   ), 0)                                              AS participants,
                   COUNT(CASE WHEN r.status = 'CANCELLED' THEN 1 END) AS cancel_count
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
             GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        ),
        prev_year_sales AS (
            SELECT EXTRACT(MONTH FROM ts.tour_date)                    AS sale_month,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS revenue
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = v_prev_year
             GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        ),
        combined AS (
            SELECT c.cal_month                                        AS report_month,
                   COALESCE(cur.reservation_count, 0)                 AS reservation_count,
                   COALESCE(cur.revenue, 0)                           AS revenue,
                   COALESCE(cur.participants, 0)                      AS participants,
                   COALESCE(cur.cancel_count, 0)                      AS cancel_count,
                   LAG(COALESCE(cur.revenue, 0), 1) OVER (
                       ORDER BY c.cal_month
                   )                                                  AS prev_month_revenue,
                   COALESCE(prev.revenue, 0)                          AS yoy_revenue,
                   SUM(COALESCE(cur.revenue, 0)) OVER (
                       ORDER BY c.cal_month
                       ROWS UNBOUNDED PRECEDING
                   )                                                  AS cumulative_revenue,
                   (COALESCE(cur.revenue, 0) / NULLIF(SUM(COALESCE(cur.revenue, 0)) OVER (), 0))
                                                                      AS share_rate
              FROM calendar c
              LEFT JOIN current_year_sales cur ON cur.sale_month = c.cal_month
              LEFT JOIN prev_year_sales prev   ON prev.sale_month = c.cal_month
             WHERE (p_month IS NULL OR c.cal_month = p_month)
        )
        SELECT report_month,
               reservation_count,
               revenue,
               participants,
               cancel_count,
               prev_month_revenue,
               CASE
                   WHEN prev_month_revenue IS NULL OR prev_month_revenue = 0 THEN NULL
                   ELSE ROUND((revenue - prev_month_revenue)
                              / prev_month_revenue * 100, 1)
               END                                                    AS mom_change_rate,
               yoy_revenue,
               CASE
                   WHEN yoy_revenue = 0 THEN NULL
                   ELSE ROUND((revenue - yoy_revenue)
                              / yoy_revenue * 100, 1)
               END                                                    AS yoy_change_rate,
               cumulative_revenue,
               ROUND(share_rate * 100, 1)                             AS share_pct,
               CASE
                   WHEN prev_month_revenue IS NULL              THEN 'N/A'
                   WHEN revenue > prev_month_revenue * 1.05     THEN 'UP'
                   WHEN revenue < prev_month_revenue * 0.95     THEN 'DOWN'
                   ELSE 'FLAT'
               END                                                    AS trend
          FROM combined
         ORDER BY report_month;

    -- =========================================================
    -- セクション2: エリア × 難易度クロス集計
    -- PIVOT で難易度を列展開、GROUPING SETS で小計/総計
    -- =========================================================
    OPEN o_area_matrix FOR
        SELECT COALESCE(area_name, '【合計】')                         AS area,
               COALESCE(difficulty, '小計')                            AS difficulty,
               grouping_level,
               reservation_count,
               total_revenue,
               avg_participants,
               beginner_count,
               intermediate_count,
               advanced_count,
               expert_count,
               CASE
                   WHEN total_revenue = 0 THEN 0
                   ELSE ROUND(beginner_rev / NULLIF(total_revenue, 0) * 100, 1)
               END                                                    AS beginner_rev_pct,
               CASE
                   WHEN total_revenue = 0 THEN 0
                   ELSE ROUND(advanced_rev / NULLIF(total_revenue, 0) * 100, 1)
               END                                                    AS advanced_rev_pct
          FROM (
            SELECT CASE grouping_id(t.area, t.difficulty)
                       WHEN 0 THEN t.area
                       WHEN 1 THEN t.area
                       WHEN 3 THEN NULL
                   END                                                AS area_name,
                   CASE grouping_id(t.area, t.difficulty)
                       WHEN 0 THEN t.difficulty
                       WHEN 1 THEN NULL
                       WHEN 3 THEN NULL
                   END                                                AS difficulty,
                   grouping_id(t.area, t.difficulty)                  AS grouping_level,
                   COUNT(r.reservation_id)                            AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS total_revenue,
                   ROUND(COALESCE(AVG(r.num_participants), 0), 1)      AS avg_participants,
                   COUNT(CASE WHEN t.difficulty = 'BEGINNER'
                              THEN r.reservation_id END)              AS beginner_count,
                   COUNT(CASE WHEN t.difficulty = 'INTERMEDIATE'
                              THEN r.reservation_id END)              AS intermediate_count,
                   COUNT(CASE WHEN t.difficulty = 'ADVANCED'
                              THEN r.reservation_id END)              AS advanced_count,
                   COUNT(CASE WHEN t.difficulty = 'EXPERT'
                              THEN r.reservation_id END)              AS expert_count,
                   COALESCE(SUM(
                       CASE WHEN t.difficulty = 'BEGINNER'
                                 AND r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS beginner_rev,
                   COALESCE(SUM(
                       CASE WHEN t.difficulty = 'ADVANCED'
                                 AND r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS advanced_rev
              FROM divingapp.tours t
              JOIN divingapp.tour_schedules ts ON ts.tour_id = t.tour_id
              LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
             WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
               AND ts.status <> 'CANCELLED'
             GROUP BY GROUPING SETS (
                 (t.area, t.difficulty),
                 (t.area),
                 ()
             )
          ) s
         ORDER BY CASE WHEN grouping_level = 3 THEN 1 ELSE 0 END,
                  area_name NULLS LAST,
                  CASE difficulty
                      WHEN 'BEGINNER' THEN 1
                      WHEN 'INTERMEDIATE' THEN 2
                      WHEN 'ADVANCED' THEN 3
                      WHEN 'EXPERT' THEN 4
                      ELSE 5
                  END NULLS LAST;

    -- =========================================================
    -- セクション3: インストラクターKPI
    -- 5テーブル結合 + LISTAGG + 相関サブクエリ(リピート率)
    -- + DENSE_RANK / PERCENT_RANK / スカラーサブクエリ
    -- =========================================================
    OPEN o_instructor_kpi FOR
        WITH instructor_base AS (
            SELECT i.instructor_id,
                   i.last_name || ' ' || i.first_name                 AS instructor_name,
                   i.certification,
                   i.experience_years,
                   COUNT(DISTINCT ts.schedule_id)                     AS schedule_count,
                   COUNT(DISTINCT r.reservation_id)                   AS reservation_count,
                   COUNT(DISTINCT r.customer_id)                      AS unique_customers,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS total_revenue,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants ELSE 0 END
                   ), 0)                                              AS total_participants,
                   ROUND(COALESCE(AVG(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.num_participants END
                   ), 0), 1)                                          AS avg_participants
              FROM divingapp.instructors i
              JOIN divingapp.tour_instructors ti ON ti.instructor_id = i.instructor_id
              JOIN divingapp.tours t            ON t.tour_id = ti.tour_id
              JOIN divingapp.tour_schedules ts  ON ts.tour_id = t.tour_id
              LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
             WHERE i.status = 'ACTIVE'
               AND EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
             GROUP BY i.instructor_id, i.last_name, i.first_name,
                      i.certification, i.experience_years
        ),
        instructor_areas AS (
            SELECT ti.instructor_id,
                   string_agg(DISTINCT t.area, ', ' ORDER BY t.area)  AS area_list
              FROM divingapp.tour_instructors ti
              JOIN divingapp.tours t ON t.tour_id = ti.tour_id
             WHERE t.status = 'ACTIVE'
             GROUP BY ti.instructor_id
        )
        SELECT ib.instructor_name,
               ib.certification,
               ib.experience_years,
               ib.schedule_count,
               ib.reservation_count,
               ib.unique_customers,
               ib.total_revenue,
               ib.total_participants,
               ib.avg_participants,
               DENSE_RANK() OVER (
                   ORDER BY ib.total_revenue DESC
               )                                                      AS revenue_rank,
               ROUND(PERCENT_RANK() OVER (
                   ORDER BY ib.avg_participants
               ) * 100, 1)                                            AS participant_percentile,
               ROUND((ib.total_revenue / NULLIF(SUM(ib.total_revenue) OVER (), 0)) * 100, 1)
                                                                      AS revenue_share_pct,
               COALESCE(ia.area_list, '-')                            AS area_list,
               -- 相関サブクエリ: リピート率（同一インストラクターのツアーに2回以上予約した顧客の割合）
               CASE
                   WHEN ib.unique_customers = 0 THEN 0
                   ELSE ROUND(
                       (SELECT COUNT(DISTINCT repeat_cust.customer_id)
                          FROM (
                              SELECT r2.customer_id,
                                     COUNT(DISTINCT r2.reservation_id) AS visit_count
                                FROM divingapp.reservations r2
                                JOIN divingapp.tour_schedules ts2 ON ts2.schedule_id = r2.schedule_id
                                JOIN divingapp.tour_instructors ti2 ON ti2.tour_id = ts2.tour_id
                               WHERE ti2.instructor_id = ib.instructor_id
                                 AND r2.status IN ('CONFIRMED', 'COMPLETED')
                               GROUP BY r2.customer_id
                              HAVING COUNT(DISTINCT r2.reservation_id) >= 2
                          ) repeat_cust
                       ) / NULLIF(ib.unique_customers, 0) * 100
                   , 1)
               END                                                    AS repeat_rate,
               -- スカラーサブクエリ: 直近3ヶ月の稼働日数
               (SELECT COUNT(DISTINCT ts3.tour_date)
                  FROM divingapp.tour_schedules ts3
                  JOIN divingapp.tour_instructors ti3 ON ti3.tour_id = ts3.tour_id
                 WHERE ti3.instructor_id = ib.instructor_id
                   AND ts3.tour_date >= (current_timestamp - interval '3 months')
                   AND ts3.tour_date <= current_timestamp
                   AND ts3.status <> 'CANCELLED'
               )                                                      AS recent_active_days
          FROM instructor_base ib
          LEFT JOIN instructor_areas ia ON ia.instructor_id = ib.instructor_id
         ORDER BY revenue_rank;

    -- =========================================================
    -- セクション4: 顧客セグメント分析（RFM + NTILE）
    -- CTE でRFM指標算出 → NTILEで4分位スコアリング
    -- → 多段CASEでセグメント分類 → セグメント別集計
    -- =========================================================
    OPEN o_customer_segment FOR
        WITH customer_rfm AS (
            SELECT c.customer_id,
                   c.last_name || ' ' || c.first_name                 AS customer_name,
                   c.license_level,
                   c.dive_count,
                   -- Recency: 最終予約からの経過月数（小さいほど良い）
                   COALESCE(ROUND(((EXTRACT(YEAR FROM age(current_timestamp, MAX(ts.tour_date))) * 12)
                                    + EXTRACT(MONTH FROM age(current_timestamp, MAX(ts.tour_date)))
                                    + (EXTRACT(DAY FROM age(current_timestamp, MAX(ts.tour_date))) / 30.0))::numeric, 1), 99)
                                                                    AS recency_months,
                   -- Frequency: 有効予約回数
                   COUNT(DISTINCT CASE
                       WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                       THEN r.reservation_id END)                     AS frequency,
                   -- Monetary: 累計利用金額
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price ELSE 0 END
                   ), 0)                                              AS monetary,
                   -- キャンセル率
                   CASE
                       WHEN COUNT(r.reservation_id) = 0 THEN 0
                       ELSE ROUND(
                           COUNT(CASE WHEN r.status = 'CANCELLED'
                                      THEN 1 END)::numeric
                           / COUNT(r.reservation_id) * 100, 1)
                   END                                                AS cancel_rate
              FROM divingapp.customers c
              LEFT JOIN divingapp.reservations r      ON r.customer_id = c.customer_id
              LEFT JOIN divingapp.tour_schedules ts   ON ts.schedule_id = r.schedule_id
             WHERE c.status = 'ACTIVE'
             GROUP BY c.customer_id, c.last_name, c.first_name,
                      c.license_level, c.dive_count
        ),
        rfm_scored AS (
            SELECT cr.*,
                   -- NTILEで4分位（4=最良、1=最低）
                   -- Recencyは逆順（経過月数が小さいほうが良い → DESC）
                   NTILE(4) OVER (ORDER BY recency_months DESC)       AS r_score,
                   NTILE(4) OVER (ORDER BY frequency ASC)            AS f_score,
                   NTILE(4) OVER (ORDER BY monetary ASC)             AS m_score
              FROM customer_rfm cr
             WHERE cr.frequency > 0 OR cr.monetary > 0
                    OR cr.recency_months < 99
        ),
        rfm_segment AS (
            SELECT rs.*,
                   -- 複合スコア（重み付け: R×3 + F×2 + M×1、最大=24）
                   (rs.r_score * 3 + rs.f_score * 2 + rs.m_score)     AS composite_score,
                   CASE
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 21
                           THEN 'VIP'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 16
                           THEN 'LOYAL'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 11
                           THEN 'ACTIVE'
                       WHEN (rs.r_score * 3 + rs.f_score * 2 + rs.m_score) >= 7
                           THEN 'LIGHT'
                       ELSE 'DORMANT'
                   END                                                AS segment
              FROM rfm_scored rs
        )
        SELECT seg.segment,
               seg.segment_order,
               seg.customer_count,
               ROUND((seg.customer_count / NULLIF(SUM(seg.customer_count) OVER (), 0)) * 100, 1)
                                                                      AS share_pct,
               seg.avg_monetary                                       AS avg_ltv,
               seg.avg_dive_count,
               seg.avg_frequency,
               seg.avg_cancel_rate,
               seg.total_revenue,
               seg.avg_recency_months,
               LAG(seg.customer_count, 1) OVER (
                   ORDER BY seg.segment_order
               )                                                      AS prev_segment_count,
               seg.customer_count - COALESCE(LAG(seg.customer_count, 1) OVER (
                   ORDER BY seg.segment_order
               ), seg.customer_count)                                 AS count_diff
          FROM (
            SELECT segment,
                   CASE segment
                       WHEN 'VIP' THEN 1
                       WHEN 'LOYAL' THEN 2
                       WHEN 'ACTIVE' THEN 3
                       WHEN 'LIGHT' THEN 4
                       WHEN 'DORMANT' THEN 5
                       ELSE 6
                   END                                                AS segment_order,
                   COUNT(*)                                           AS customer_count,
                   ROUND(AVG(monetary), 0)                            AS avg_monetary,
                   ROUND(AVG(dive_count), 0)                          AS avg_dive_count,
                   ROUND(AVG(frequency), 1)                           AS avg_frequency,
                   ROUND(AVG(cancel_rate), 1)                         AS avg_cancel_rate,
                   SUM(monetary)                                      AS total_revenue,
                   ROUND(AVG(recency_months), 1)                      AS avg_recency_months
              FROM rfm_segment
             GROUP BY segment
          ) seg
         ORDER BY seg.segment_order;

    -- =========================================================
    -- セクション5: キャンセル傾向・損失分析
    -- CONNECT BY で日数帯生成 → キャンセル日数帯別集計
    -- → 自己結合で前月比 → 移動平均・移動標準偏差 → アラート
    -- =========================================================
    OPEN o_cancel_analysis FOR
        WITH RECURSIVE day_ranges AS (
            SELECT 1 AS range_id,
                   '0-2日前'::text AS day_range_label,
                   0::int AS range_min,
                   2::int AS range_max
            UNION ALL
            SELECT 2, '3-6日前', 3, 6
            UNION ALL
            SELECT 3, '7-13日前', 7, 13
            UNION ALL
            SELECT 4, '14-29日前', 14, 29
            UNION ALL
            SELECT 5, '30日以上前', 30, 9999
        ),
        cancel_data AS (
            SELECT r.reservation_id,
                   r.total_price,
                   r.refund_amount,
                   EXTRACT(MONTH FROM ts.tour_date)                   AS tour_month,
                   CASE EXTRACT(ISODOW FROM r.updated_at)
                       WHEN 1 THEN '月'
                       WHEN 2 THEN '火'
                       WHEN 3 THEN '水'
                       WHEN 4 THEN '木'
                       WHEN 5 THEN '金'
                       WHEN 6 THEN '土'
                       WHEN 7 THEN '日'
                   END                                               AS cancel_dow,
                   GREATEST(
                       (ts.tour_date::date - r.updated_at::date), 0
                   )                                                 AS days_before
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
             WHERE r.status = 'CANCELLED'
               AND EXTRACT(YEAR FROM ts.tour_date) = p_year
               AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
        ),
        range_summary AS (
            SELECT dr.range_id,
                   dr.day_range_label,
                   COUNT(cd.reservation_id)                           AS cancel_count,
                   COALESCE(SUM(cd.total_price), 0)                   AS loss_amount,
                   COALESCE(SUM(cd.refund_amount), 0)                 AS refund_amount,
                   COALESCE(SUM(cd.total_price - cd.refund_amount), 0) AS net_revenue
              FROM day_ranges dr
              LEFT JOIN cancel_data cd
                ON cd.days_before BETWEEN dr.range_min AND dr.range_max
             GROUP BY dr.range_id, dr.day_range_label
        ),
        monthly_cancel AS (
            SELECT cd.tour_month,
                   COUNT(*)                                           AS cancel_count,
                   SUM(cd.total_price)                                AS loss_amount
              FROM cancel_data cd
             GROUP BY cd.tour_month
        ),
        monthly_trend AS (
            SELECT mc.tour_month,
                   mc.cancel_count,
                   mc.loss_amount,
                   LAG(mc.cancel_count, 1) OVER (
                       ORDER BY mc.tour_month
                   )                                                  AS prev_month_count,
                   AVG(mc.cancel_count) OVER (
                       ORDER BY mc.tour_month
                       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
                   )                                                  AS moving_avg_3m,
                   STDDEV(mc.cancel_count) OVER (
                       ORDER BY mc.tour_month
                       ROWS BETWEEN 5 PRECEDING AND CURRENT ROW
                   )                                                  AS moving_stddev_6m
              FROM monthly_cancel mc
        ),
        dow_summary AS (
            SELECT cd.cancel_dow,
                   COUNT(*)                                           AS dow_count,
                   ROUND((COUNT(*)::numeric / NULLIF(SUM(COUNT(*)) OVER (), 0)) * 100, 1)
                                                                      AS dow_pct
              FROM cancel_data cd
             GROUP BY cd.cancel_dow
        )
        SELECT 'RANGE' AS analysis_type,
               rs.range_id                                             AS sort_key,
               rs.day_range_label                                      AS dimension,
               rs.cancel_count,
               rs.loss_amount,
               rs.refund_amount,
               rs.net_revenue,
               NULL::numeric                                           AS mom_change,
               NULL::numeric                                           AS moving_avg,
               NULL::numeric                                           AS moving_stddev,
               NULL::text                                              AS alert_flag
          FROM range_summary rs
        UNION ALL
        SELECT 'MONTHLY' AS analysis_type,
               mt.tour_month                                           AS sort_key,
               mt.tour_month::text || '月'                              AS dimension,
               mt.cancel_count,
               mt.loss_amount,
               NULL::numeric                                           AS refund_amount,
               NULL::numeric                                           AS net_revenue,
               CASE
                   WHEN mt.prev_month_count IS NULL OR mt.prev_month_count = 0 THEN NULL
                   ELSE ROUND(
                       (mt.cancel_count - mt.prev_month_count)::numeric
                       / mt.prev_month_count * 100, 1)
               END                                                     AS mom_change,
               ROUND(mt.moving_avg_3m::numeric, 1)                     AS moving_avg,
               ROUND(mt.moving_stddev_6m::numeric, 2)                  AS moving_stddev,
               CASE
                   WHEN mt.moving_stddev_6m > 0
                        AND mt.cancel_count > mt.moving_avg_3m
                            + (2 * mt.moving_stddev_6m)
                   THEN 'ANOMALY'
                   ELSE 'NORMAL'
               END                                                     AS alert_flag
          FROM monthly_trend mt
        UNION ALL
        SELECT 'DOW' AS analysis_type,
               CASE ds.cancel_dow
                   WHEN '月' THEN 1
                   WHEN '火' THEN 2
                   WHEN '水' THEN 3
                   WHEN '木' THEN 4
                   WHEN '金' THEN 5
                   WHEN '土' THEN 6
                   WHEN '日' THEN 7
                   ELSE 8
               END                                                     AS sort_key,
               ds.cancel_dow                                           AS dimension,
               ds.dow_count                                            AS cancel_count,
               NULL::numeric                                           AS loss_amount,
               NULL::numeric                                           AS refund_amount,
               NULL::numeric                                           AS net_revenue,
               NULL::numeric                                           AS mom_change,
               NULL::numeric                                           AS moving_avg,
               NULL::numeric                                           AS moving_stddev,
               CASE
                   WHEN ds.dow_pct > 25 THEN 'HIGH'
                   ELSE 'NORMAL'
               END                                                     AS alert_flag
          FROM dow_summary ds
         ORDER BY analysis_type, sort_key;

    -- =========================================================
    -- セクション6: 異常検知 + MERGE INTO REPORT_CACHE
    --              + INSERT INTO REPORT_ALERTS
    -- WITH句で全セクション主要指標をUNION ALL統合
    -- Z-score計算 → 異常値判定 → MERGE + INSERT
    -- =========================================================

    WITH all_metrics AS (
        SELECT 'SALES' AS section,
               ('REVENUE_M' || EXTRACT(MONTH FROM ts.tour_date))::text AS metric_name,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price ELSE 0 END
               ), 0)                                                  AS metric_value,
               to_char(EXTRACT(MONTH FROM ts.tour_date), 'FM99')       AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
        UNION ALL
        SELECT 'AREA' AS section,
               'AREA_REVENUE' AS metric_name,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price ELSE 0 END
               ), 0)                                                  AS metric_value,
               t.area                                                 AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.tours t
          JOIN divingapp.tour_schedules ts ON ts.tour_id = t.tour_id
          LEFT JOIN divingapp.reservations r ON r.schedule_id = ts.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY t.area
        UNION ALL
        SELECT 'CANCEL' AS section,
               ('CANCEL_COUNT_M' || EXTRACT(MONTH FROM ts.tour_date))::text AS metric_name,
               COUNT(*)::numeric                                      AS metric_value,
               to_char(EXTRACT(MONTH FROM ts.tour_date), 'FM99')       AS dim1,
               NULL::text                                             AS dim2
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON ts.schedule_id = r.schedule_id
         WHERE r.status = 'CANCELLED'
           AND EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
    ),
    upserted AS (
        INSERT INTO divingapp.report_cache(
            report_key, section, report_date,
            metric_name, metric_value, dimension1, dimension2, generated_at
        )
        SELECT v_report_key,
               section,
               current_date,
               metric_name,
               metric_value,
               dim1,
               dim2,
               current_timestamp
          FROM all_metrics
        ON CONFLICT (report_key, section, metric_name)
        DO UPDATE SET metric_value = EXCLUDED.metric_value,
                      dimension1   = EXCLUDED.dimension1,
                      dimension2   = EXCLUDED.dimension2,
                      report_date  = EXCLUDED.report_date,
                      generated_at = EXCLUDED.generated_at
        RETURNING 1
    )
    SELECT 1 INTO v_alert_count FROM upserted LIMIT 1;

    INSERT INTO divingapp.report_alerts (
        alert_type, severity, metric_name,
        current_value, threshold_value, deviation, message,
        detected_at, status
    )
    SELECT section,
           CASE
               WHEN ABS(z_score) > 3 THEN 'HIGH'
               WHEN ABS(z_score) > 2 THEN 'MEDIUM'
               ELSE 'LOW'
           END                                                     AS severity,
           metric_name,
           metric_value,
           avg_value,
           ROUND(z_score, 4),
           CASE
               WHEN z_score > 2 THEN
                   metric_name || 'が平均(' || ROUND(avg_value, 0)
                   || ')を大幅に上回っています（Z=' || ROUND(z_score, 2) || '）'
               WHEN z_score < -2 THEN
                   metric_name || 'が平均(' || ROUND(avg_value, 0)
                   || ')を大幅に下回っています（Z=' || ROUND(z_score, 2) || '）'
               ELSE
                   metric_name || 'は正常範囲内です'
           END,
           current_timestamp,
           'NEW'
      FROM (
        SELECT section,
               metric_name,
               metric_value,
               AVG(metric_value) OVER (PARTITION BY section)         AS avg_value,
               STDDEV(metric_value) OVER (PARTITION BY section)      AS stddev_value,
               CASE
                   WHEN STDDEV(metric_value) OVER (PARTITION BY section) = 0
                   THEN 0
                   ELSE (metric_value - AVG(metric_value) OVER (PARTITION BY section))
                        / STDDEV(metric_value) OVER (PARTITION BY section)
               END                                                   AS z_score
          FROM divingapp.report_cache
         WHERE report_key = v_report_key
      ) z
     WHERE ABS(z_score) > 2;

    OPEN o_anomaly_alerts FOR
        SELECT ra.alert_id,
               ra.alert_type,
               ra.severity,
               ra.metric_name,
               ra.current_value,
               ra.threshold_value,
               ra.deviation,
               ra.message,
               ra.detected_at,
               ra.status,
               DENSE_RANK() OVER (
                   ORDER BY CASE ra.severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END,
                            ra.detected_at DESC
               )                                                      AS alert_rank,
               COUNT(*) OVER ()                                       AS total_alerts,
               COUNT(*) OVER (PARTITION BY ra.severity)               AS severity_count,
               ROUND((COUNT(*) OVER (PARTITION BY ra.severity)::numeric / NULLIF(COUNT(*) OVER ()::numeric, 0)) * 100, 1)
                                                                      AS severity_dist_pct
          FROM divingapp.report_alerts ra
         WHERE ra.status = 'NEW'
           AND ra.detected_at >= (current_timestamp - interval '10 minutes')
         ORDER BY CASE ra.severity WHEN 'HIGH' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'LOW' THEN 3 ELSE 4 END,
                  ra.detected_at DESC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = 'ダッシュボードレポート生成中にエラーが発生しました: ' || SQLERRM;
END;
$$;

-- divingapp.get_all_reservations (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_all_reservations.sql
CREATE OR REPLACE PROCEDURE divingapp.get_all_reservations(
    IN p_status VARCHAR DEFAULT NULL,
    IN p_date_from TIMESTAMP DEFAULT NULL,
    IN p_date_to TIMESTAMP DEFAULT NULL,
    IN p_page BIGINT DEFAULT 1,
    IN p_page_size BIGINT DEFAULT 20,
    INOUT o_reservations REFCURSOR DEFAULT NULL,
    INOUT o_total_count BIGINT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset BIGINT;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*)
      INTO o_total_count
      FROM divingapp.reservations r
      JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
     WHERE (p_status IS NULL OR r.status = p_status)
       AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
       AND (p_date_to IS NULL OR ts.tour_date <= p_date_to);

    IF o_reservations IS NULL THEN
        o_reservations := 'o_reservations';
    END IF;
    OPEN o_reservations FOR
        SELECT reservation_id,
               customer_id,
               customer_name,
               email,
               num_participants,
               total_price,
               reservation_status,
               refund_amount,
               reserved_at,
               tour_id,
               tour_name,
               tour_date,
               start_time
          FROM (
            SELECT r.reservation_id,
                   r.customer_id,
                   c.last_name || ' ' || c.first_name AS customer_name,
                   c.email,
                   r.num_participants,
                   r.total_price,
                   r.status AS reservation_status,
                   r.refund_amount,
                   r.created_at AS reserved_at,
                   t.tour_id,
                   t.tour_name,
                   ts.tour_date,
                   ts.start_time,
                   row_number() OVER (ORDER BY r.created_at DESC) AS rn
              FROM divingapp.reservations r
              JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
              JOIN divingapp.tours t ON ts.tour_id = t.tour_id
              JOIN divingapp.customers c ON r.customer_id = c.customer_id
             WHERE (p_status IS NULL OR r.status = p_status)
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
          ) s
         WHERE s.rn > v_offset
           AND s.rn <= v_offset + p_page_size;
END;
$$;

-- divingapp.get_customer_reservations (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_customer_reservations.sql
CREATE OR REPLACE PROCEDURE divingapp.get_customer_reservations(
    IN p_customer_id BIGINT,
    IN p_status VARCHAR DEFAULT NULL,
    INOUT o_reservations REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF o_reservations IS NULL THEN
        o_reservations := 'o_reservations';
    END IF;
    OPEN o_reservations FOR
        SELECT r.reservation_id,
               r.num_participants,
               r.total_price,
               r.status AS reservation_status,
               r.refund_amount,
               r.created_at AS reserved_at,
               t.tour_id,
               t.tour_name,
               t.area,
               ts.tour_date,
               ts.start_time
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
          JOIN divingapp.tours t ON ts.tour_id = t.tour_id
         WHERE r.customer_id = p_customer_id
           AND (p_status IS NULL OR r.status = p_status)
         ORDER BY r.created_at DESC;
END;
$$;

-- divingapp.get_featured_tours (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_featured_tours.sql
CREATE OR REPLACE PROCEDURE divingapp.get_featured_tours(
    IN p_limit NUMERIC,
    INOUT o_tours refcursor
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit NUMERIC;
BEGIN
    v_limit := COALESCE(p_limit, 6);

    IF o_tours IS NULL THEN
        o_tours := 'get_featured_tours_' || pg_backend_pid() || '_' || txid_current();
    END IF;

    OPEN o_tours FOR
        SELECT t.tour_id,
               t.tour_name,
               t.area,
               t.difficulty,
               t.base_price,
               t.duration_days,
               t.min_dive_count,
               t.created_at
          FROM divingapp.tours t
         WHERE t.featured_flag = 'Y'
           AND t.status = 'ACTIVE'
         ORDER BY t.created_at DESC
         LIMIT v_limit::int;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'おすすめツアー取得中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;

-- divingapp.get_monthly_sales (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_monthly_sales.sql
CREATE OR REPLACE PROCEDURE divingapp.get_monthly_sales(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    OPEN o_report FOR
        SELECT p_year                                              AS report_year,
               EXTRACT(MONTH FROM ts.tour_date)                    AS report_month,
               COUNT(r.reservation_id)                             AS total_reservations,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.total_price
                        ELSE 0
                   END
               ), 0)                                               AS total_revenue,
               COUNT(
                   CASE WHEN r.status = 'CANCELLED'
                        THEN 1
                   END
               )                                                   AS cancelled_count
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts
            ON ts.schedule_id = r.schedule_id
          JOIN divingapp.tours t
            ON t.tour_id = ts.tour_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
         GROUP BY EXTRACT(MONTH FROM ts.tour_date)
         ORDER BY report_month;
END;
$$;

-- divingapp.get_occupancy_rate (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_occupancy_rate.sql
CREATE OR REPLACE PROCEDURE divingapp.get_occupancy_rate(
    IN p_year numeric,
    IN p_month numeric DEFAULT NULL,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_year IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '年は必須です';
    END IF;

    IF p_month IS NOT NULL AND (p_month < 1 OR p_month > 12) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '月は1〜12の範囲で指定してください';
    END IF;

    OPEN o_report FOR
        SELECT t.tour_name,
               t.area,
               COUNT(DISTINCT ts.schedule_id)                      AS schedule_count,
               COALESCE(SUM(t.max_participants), 0)                AS total_capacity,
               COALESCE(SUM(
                   CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                        THEN r.num_participants
                        ELSE 0
                   END
               ), 0)                                               AS total_booked,
               CASE
                   WHEN COALESCE(SUM(t.max_participants), 0) = 0 THEN 0
                   ELSE ROUND(
                       COALESCE(SUM(
                           CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                                THEN r.num_participants
                                ELSE 0
                           END
                       ), 0)
                       / SUM(t.max_participants) * 100
                   , 1)
               END                                                 AS occupancy_rate
          FROM divingapp.tours t
          JOIN divingapp.tour_schedules ts
            ON ts.tour_id = t.tour_id
          LEFT JOIN divingapp.reservations r
            ON r.schedule_id = ts.schedule_id
         WHERE EXTRACT(YEAR FROM ts.tour_date) = p_year
           AND (p_month IS NULL OR EXTRACT(MONTH FROM ts.tour_date) = p_month)
           AND ts.status <> 'CANCELLED'
         GROUP BY t.tour_id, t.tour_name, t.area
         ORDER BY occupancy_rate DESC;
END;
$$;

-- divingapp.get_reservation_detail (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_reservation_detail.sql
CREATE OR REPLACE PROCEDURE divingapp.get_reservation_detail(
    IN p_reservation_id BIGINT,
    INOUT o_reservation REFCURSOR DEFAULT NULL,
    INOUT o_options REFCURSOR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count BIGINT;
BEGIN
    SELECT COUNT(*) INTO v_count
      FROM divingapp.reservations
     WHERE reservation_id = p_reservation_id;

    IF v_count = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0001', MESSAGE = '指定された予約が見つかりません。予約ID=' || p_reservation_id;
    END IF;

    IF o_reservation IS NULL THEN
        o_reservation := 'o_reservation';
    END IF;
    OPEN o_reservation FOR
        SELECT r.reservation_id,
               r.customer_id,
               r.schedule_id,
               r.num_participants,
               r.total_price,
               r.status AS reservation_status,
               r.cancel_reason,
               r.refund_amount,
               r.notes,
               r.created_at AS reserved_at,
               r.updated_at,
               t.tour_id,
               t.tour_name,
               t.area,
               t.difficulty,
               t.base_price,
               ts.tour_date,
               ts.start_time,
               ts.status AS schedule_status
          FROM divingapp.reservations r
          JOIN divingapp.tour_schedules ts ON r.schedule_id = ts.schedule_id
          JOIN divingapp.tours t ON ts.tour_id = t.tour_id
         WHERE r.reservation_id = p_reservation_id;

    IF o_options IS NULL THEN
        o_options := 'o_options';
    END IF;
    OPEN o_options FOR
        SELECT ro.res_option_id,
               ro.option_id,
               om.option_name,
               om.option_category,
               om.unit_price,
               ro.quantity,
               ro.subtotal
          FROM divingapp.reservation_options ro
          JOIN divingapp.options_master om ON ro.option_id = om.option_id
         WHERE ro.reservation_id = p_reservation_id
         ORDER BY om.option_category, om.option_name;
END;
$$;

-- divingapp.get_tour_detail (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_tour_detail.sql
CREATE OR REPLACE PROCEDURE divingapp.get_tour_detail(
    IN p_tour_id NUMERIC,
    INOUT o_tour refcursor,
    INOUT o_sites refcursor,
    INOUT o_instructors refcursor,
    INOUT o_schedules refcursor
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
BEGIN
    -- ツアー存在チェック
    SELECT COUNT(*)
      INTO v_count
      FROM divingapp.tours
     WHERE tour_id = p_tour_id
       AND status <> 'DELETED';

    IF v_count = 0 THEN
        RAISE EXCEPTION '指定されたツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
    END IF;

    -- ツアー基本情報
    IF o_tour IS NULL THEN
        o_tour := 'get_tour_detail_tour_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_tour FOR
        SELECT t.tour_id,
               t.tour_name,
               t.description,
               t.area,
               t.difficulty,
               t.max_participants,
               t.base_price,
               t.duration_days,
               t.min_dive_count,
               t.featured_flag,
               t.status,
               t.created_at,
               t.updated_at
          FROM divingapp.tours t
         WHERE t.tour_id = p_tour_id;

    -- 関連ダイブサイト
    IF o_sites IS NULL THEN
        o_sites := 'get_tour_detail_sites_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_sites FOR
        SELECT ds.site_id,
               ds.site_name,
               ds.area,
               ds.max_depth,
               ds.difficulty,
               ds.marine_life,
               tds.dive_order
          FROM divingapp.tour_dive_sites tds
          JOIN divingapp.dive_sites ds ON tds.site_id = ds.site_id
         WHERE tds.tour_id = p_tour_id
           AND ds.status = 'ACTIVE'
         ORDER BY tds.dive_order;

    -- 担当インストラクター
    IF o_instructors IS NULL THEN
        o_instructors := 'get_tour_detail_instructors_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_instructors FOR
        SELECT i.instructor_id,
               i.last_name,
               i.first_name,
               i.certification,
               i.experience_years,
               i.specialty,
               i.photo_url,
               ti.role
          FROM divingapp.tour_instructors ti
          JOIN divingapp.instructors i ON ti.instructor_id = i.instructor_id
         WHERE ti.tour_id = p_tour_id
           AND i.status = 'ACTIVE'
         ORDER BY ti.role, i.last_name;

    -- 今後のスケジュール（未来日のみ、日付順）
    IF o_schedules IS NULL THEN
        o_schedules := 'get_tour_detail_schedules_' || pg_backend_pid() || '_' || txid_current();
    END IF;
    OPEN o_schedules FOR
        SELECT ts.schedule_id,
               ts.tour_date,
               ts.start_time,
               ts.remaining_seats,
               ts.status
          FROM divingapp.tour_schedules ts
         WHERE ts.tour_id = p_tour_id
           AND ts.tour_date >= date_trunc('day', CURRENT_TIMESTAMP)
           AND ts.status IN ('OPEN', 'FULL')
         ORDER BY ts.tour_date ASC;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー詳細取得中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;

-- divingapp.get_tour_popularity (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\get_tour_popularity.sql
CREATE OR REPLACE PROCEDURE divingapp.get_tour_popularity(
    IN p_date_from timestamp DEFAULT NULL,
    IN p_date_to timestamp DEFAULT NULL,
    IN p_limit numeric DEFAULT 10,
    INOUT o_report refcursor DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_limit numeric := COALESCE(p_limit, 10);
BEGIN
    IF v_limit < 1 THEN
        v_limit := 10;
    END IF;

    OPEN o_report FOR
        SELECT *
          FROM (
            SELECT t.tour_name,
                   t.area,
                   COUNT(r.reservation_id)                         AS reservation_count,
                   COALESCE(SUM(
                       CASE WHEN r.status IN ('CONFIRMED', 'COMPLETED')
                            THEN r.total_price
                            ELSE 0
                       END
                   ), 0)                                           AS total_revenue,
                   ROUND(COALESCE(AVG(r.num_participants), 0), 1)   AS avg_participants,
                   RANK() OVER (
                       ORDER BY COUNT(r.reservation_id) DESC
                   )                                               AS popularity_rank
              FROM divingapp.tours t
              JOIN divingapp.tour_schedules ts
                ON ts.tour_id = t.tour_id
              JOIN divingapp.reservations r
                ON r.schedule_id = ts.schedule_id
             WHERE r.status IN ('CONFIRMED', 'COMPLETED')
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to   IS NULL OR ts.tour_date <= p_date_to)
             GROUP BY t.tour_id, t.tour_name, t.area
          ) s
         WHERE popularity_rank <= v_limit
         ORDER BY popularity_rank;
END;
$$;

-- divingapp.save_tour (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\save_tour.sql
CREATE OR REPLACE PROCEDURE divingapp.save_tour(
    INOUT p_tour_id NUMERIC,
    IN p_tour_name VARCHAR,
    IN p_description TEXT,
    IN p_area VARCHAR,
    IN p_difficulty VARCHAR,
    IN p_max_participants NUMERIC,
    IN p_base_price NUMERIC,
    IN p_duration_days NUMERIC,
    IN p_min_dive_count NUMERIC,
    IN p_featured_flag CHAR,
    OUT o_result_code NUMERIC,
    OUT o_result_msg VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_count NUMERIC;
BEGIN
    -- 必須項目バリデーション
    IF p_tour_name IS NULL OR length(btrim(p_tour_name)) = 0 THEN
        RAISE EXCEPTION 'ツアー名は必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_area IS NULL OR length(btrim(p_area)) = 0 THEN
        RAISE EXCEPTION 'エリアは必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_difficulty IS NULL THEN
        RAISE EXCEPTION '難易度は必須です。' USING ERRCODE = 'P0001';
    END IF;
    IF p_difficulty NOT IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') THEN
        RAISE EXCEPTION '難易度の値が不正です: %', p_difficulty USING ERRCODE = 'P0001';
    END IF;
    IF p_max_participants IS NULL OR p_max_participants <= 0 THEN
        RAISE EXCEPTION '最大参加人数は1以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;
    IF p_base_price IS NULL OR p_base_price < 0 THEN
        RAISE EXCEPTION '基本料金は0以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;
    IF p_duration_days IS NULL OR p_duration_days <= 0 THEN
        RAISE EXCEPTION '日数は1以上を指定してください。' USING ERRCODE = 'P0001';
    END IF;

    IF p_tour_id IS NULL THEN
        -- 新規登録
        SELECT nextval('divingapp.seq_tours') INTO p_tour_id;

        INSERT INTO divingapp.tours (
            tour_id, tour_name, description, area, difficulty,
            max_participants, base_price, duration_days,
            min_dive_count, featured_flag, status,
            created_at, updated_at
        ) VALUES (
            p_tour_id, p_tour_name, p_description, p_area, p_difficulty,
            p_max_participants, p_base_price, p_duration_days,
            COALESCE(p_min_dive_count, 0), COALESCE(p_featured_flag, 'N'), 'ACTIVE',
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );

        o_result_code := 0;
        o_result_msg  := 'ツアーを登録しました。TOUR_ID=' || p_tour_id;
    ELSE
        -- 更新：存在チェック
        SELECT COUNT(*)
          INTO v_count
          FROM divingapp.tours
         WHERE tour_id = p_tour_id
           AND status <> 'DELETED';

        IF v_count = 0 THEN
            RAISE EXCEPTION '更新対象のツアーが見つかりません。TOUR_ID=%', p_tour_id USING ERRCODE = 'P0001';
        END IF;

        UPDATE divingapp.tours
           SET tour_name        = p_tour_name,
               description      = p_description,
               area             = p_area,
               difficulty       = p_difficulty,
               max_participants = p_max_participants,
               base_price       = p_base_price,
               duration_days    = p_duration_days,
               min_dive_count   = COALESCE(p_min_dive_count, 0),
               featured_flag    = COALESCE(p_featured_flag, 'N'),
               updated_at       = CURRENT_TIMESTAMP
         WHERE tour_id = p_tour_id;

        o_result_code := 0;
        o_result_msg  := 'ツアーを更新しました。TOUR_ID=' || p_tour_id;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー保存中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;

-- divingapp.search_tours (PROCEDURE)
-- Source: artifacts\postgres\divingapp\PROCEDURE\search_tours.sql
CREATE OR REPLACE PROCEDURE divingapp.search_tours(
    IN p_area VARCHAR,
    IN p_difficulty VARCHAR,
    IN p_date_from TIMESTAMP,
    IN p_date_to TIMESTAMP,
    IN p_price_min NUMERIC,
    IN p_price_max NUMERIC,
    IN p_duration_days NUMERIC,
    IN p_keyword VARCHAR,
    IN p_page NUMERIC,
    IN p_page_size NUMERIC,
    INOUT o_tours refcursor,
    OUT o_total_count NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset NUMERIC;
    v_page NUMERIC;
    v_page_size NUMERIC;
BEGIN
    v_page := COALESCE(p_page, 1);
    v_page_size := COALESCE(p_page_size, 10);
    v_offset := (v_page - 1) * v_page_size;

    -- 総件数取得
    SELECT COUNT(DISTINCT t.tour_id)
      INTO o_total_count
      FROM divingapp.tours t
      LEFT JOIN divingapp.tour_schedules ts ON t.tour_id = ts.tour_id
     WHERE t.status = 'ACTIVE'
       AND (p_area IS NULL OR t.area LIKE '%' || p_area || '%')
       AND (p_difficulty IS NULL OR t.difficulty = p_difficulty)
       AND (p_duration_days IS NULL OR t.duration_days = p_duration_days)
       AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
       AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
       AND (p_price_min IS NULL OR t.base_price >= p_price_min)
       AND (p_price_max IS NULL OR t.base_price <= p_price_max)
       AND (
            p_keyword IS NULL
            OR UPPER(t.tour_name) LIKE '%' || UPPER(p_keyword) || '%'
            OR POSITION(UPPER(p_keyword) IN UPPER(COALESCE(t.description::text, ''))) > 0
       );

    -- ページネーション付きツアー一覧
    IF o_tours IS NULL THEN
        o_tours := 'search_tours_' || pg_backend_pid() || '_' || txid_current();
    END IF;

    OPEN o_tours FOR
        SELECT *
          FROM (
            SELECT DISTINCT
                   t.tour_id,
                   t.tour_name,
                   t.description,
                   t.area,
                   t.difficulty,
                   t.max_participants,
                   t.base_price,
                   t.duration_days,
                   t.min_dive_count,
                   t.featured_flag,
                   t.status,
                   t.created_at,
                   ROW_NUMBER() OVER (ORDER BY t.created_at DESC) AS rn
              FROM divingapp.tours t
              LEFT JOIN divingapp.tour_schedules ts ON t.tour_id = ts.tour_id
             WHERE t.status = 'ACTIVE'
               AND (p_area IS NULL OR t.area LIKE '%' || p_area || '%')
               AND (p_difficulty IS NULL OR t.difficulty = p_difficulty)
               AND (p_duration_days IS NULL OR t.duration_days = p_duration_days)
               AND (p_date_from IS NULL OR ts.tour_date >= p_date_from)
               AND (p_date_to IS NULL OR ts.tour_date <= p_date_to)
               AND (p_price_min IS NULL OR t.base_price >= p_price_min)
               AND (p_price_max IS NULL OR t.base_price <= p_price_max)
               AND (
                    p_keyword IS NULL
                    OR UPPER(t.tour_name) LIKE '%' || UPPER(p_keyword) || '%'
                    OR POSITION(UPPER(p_keyword) IN UPPER(COALESCE(t.description::text, ''))) > 0
               )
          ) s
         WHERE s.rn > v_offset
           AND s.rn <= v_offset + v_page_size;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ツアー検索中にエラーが発生しました: %', SQLERRM USING ERRCODE = 'P0001';
END;
$$;


-- Migration deployment completed
DO $$
BEGIN
  RAISE NOTICE 'Oracle → PostgreSQL migration deployment completed successfully at %', NOW();
END $$;

COMMIT;

-- END MIGRATION DEPLOYMENT
-- ==========================================
-- 
-- Migration deployment script generated by Oracle Migration Service
-- For support and documentation, visit: https://github.com/microsoft/vscode-postgresql
