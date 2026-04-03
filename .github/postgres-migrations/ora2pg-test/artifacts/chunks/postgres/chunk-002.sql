-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_REPORT_CACHE.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_report_cache
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NO CYCLE;

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/SEQUENCE/SEQ_RESERVATION_OPTIONS.sql
CREATE SEQUENCE IF NOT EXISTS divingapp.seq_reservation_options
    INCREMENT BY 1
    START WITH 1
    MINVALUE 1
    NO CYCLE;

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/CUSTOMERS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/REPORT_ALERTS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOURS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_DS_AREA.sql
CREATE INDEX IF NOT EXISTS idx_ds_area ON divingapp.dive_sites (area);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RC_GENERATED.sql
CREATE INDEX IF NOT EXISTS idx_rc_generated ON divingapp.report_cache (generated_at);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RC_KEY_SECTION.sql
CREATE INDEX IF NOT EXISTS idx_rc_key_section ON divingapp.report_cache (report_key, section);