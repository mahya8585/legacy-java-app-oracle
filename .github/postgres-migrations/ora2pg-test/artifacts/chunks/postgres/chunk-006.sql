-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/DIVING_LOGS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/TABLE/RESERVATION_OPTIONS.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RESERVATIONS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_reservations_status ON divingapp.reservations (status);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_RESERVATIONS_SCHEDULE.sql
CREATE INDEX IF NOT EXISTS idx_reservations_schedule ON divingapp.reservations (schedule_id);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/INDEX/IDX_TS_STATUS.sql
CREATE INDEX IF NOT EXISTS idx_ts_status ON divingapp.tour_schedules (status);

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
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

-- MIGRATION_MAPPING: ORACLE=DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
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