-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_INSTRUCTORS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_DIVE_SITES.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/TOUR_SCHEDULES.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_CUSTOMERS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_customers_status ON divingapp.customers (status);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RA_DETECTED.sql
CREATE INDEX IF NOT EXISTS idx_ra_detected ON divingapp.report_alerts (detected_at, status);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RA_SEVERITY.sql
CREATE INDEX IF NOT EXISTS idx_ra_severity ON divingapp.report_alerts (severity, status);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_AREA.sql
CREATE INDEX IF NOT EXISTS idx_tours_area ON divingapp.tours (area);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_DIFFICULTY.sql
CREATE INDEX IF NOT EXISTS idx_tours_difficulty ON divingapp.tours (difficulty);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_FEATURED.sql
CREATE INDEX IF NOT EXISTS idx_tours_featured ON divingapp.tours (featured_flag);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TOURS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_tours_status ON divingapp.tours (status);