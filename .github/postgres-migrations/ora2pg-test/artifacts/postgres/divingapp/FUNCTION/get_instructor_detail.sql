-- PostgreSQL DDL for {oracle_object["owner"]}.{oracle_object["name"]} (FUNCTION)
-- Generated from Oracle → PostgreSQL migration
-- Mapping type: one_to_one
-- Oracle source: DIVINGAPP/PACKAGE/PKG_INSTRUCTOR.sql
-- Generated at: 2026-04-03T15:26:04.293857

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